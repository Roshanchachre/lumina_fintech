const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { run, get, all } = require('../db');
const {
  generateOtpCode,
  hashOtp,
  hashPassword,
  comparePassword,
  generateToken,
} = require('../auth');
const { sendVerificationEmail, getDevOutbox } = require('../mailer');

const router = express.Router();

const OTP_EXPIRY_MS = 10 * 60 * 1000; // 10 minutes
const RESEND_COOLDOWN_MS = 60 * 1000;  // 60 seconds
const MAX_OTP_ATTEMPTS = 5;

// Email validation helper
const isValidEmail = (email) => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// 1. REGISTER
router.post('/register', async (req, res) => {
  try {
    const { email, password, fullName } = req.body;

    if (!email || !password || !fullName) {
      return res.status(400).json({
        status: 'error',
        message: 'Email, password, and full name are required.',
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        status: 'error',
        message: 'Please provide a valid email address.',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        status: 'error',
        message: 'Password must be at least 6 characters long.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const existingUser = await get('SELECT * FROM users WHERE email = ?', [normalizedEmail]);

    if (existingUser && existingUser.is_verified === 1) {
      return res.status(409).json({
        status: 'error',
        message: 'An account with this email already exists. Please log in.',
      });
    }

    const passwordHash = await hashPassword(password);
    let userId;

    if (existingUser && existingUser.is_verified === 0) {
      // Update existing unverified record
      userId = existingUser.id;
      await run(
        'UPDATE users SET full_name = ?, password_hash = ?, updated_at = datetime("now") WHERE id = ?',
        [fullName.trim(), passwordHash, userId]
      );
    } else {
      userId = uuidv4();
      await run(
        `INSERT INTO users (id, email, password_hash, full_name, avatar_url, is_verified, is_profile_completed)
         VALUES (?, ?, ?, ?, 'assets/avatars/boy_1.png', 0, 0)`,
        [userId, normalizedEmail, passwordHash, fullName.trim()]
      );

      // Create linked account wallet
      const accountId = uuidv4();
      const accountNumber = `LUM-${Math.floor(1000000000 + Math.random() * 9000000000)}`;
      await run(
        `INSERT INTO accounts (id, user_id, account_number, currency, balance)
         VALUES (?, ?, ?, 'USD', 128450.85)`,
        [accountId, userId, accountNumber]
      );
    }

    // Generate & record OTP
    const rawCode = generateOtpCode();
    const otpHash = hashOtp(normalizedEmail, rawCode, 'register');
    const now = Date.now();
    const expiresAt = now + OTP_EXPIRY_MS;

    // Invalidate old unverified OTPs for this user
    await run('UPDATE otps SET is_used = 1 WHERE email = ? AND type = "register"', [normalizedEmail]);

    await run(
      `INSERT INTO otps (id, email, otp_hash, type, attempts, expires_at, created_at, is_used)
       VALUES (?, ?, ?, 'register', 0, ?, ?, 0)`,
      [uuidv4(), normalizedEmail, otpHash, expiresAt, now]
    );

    // Send email via SMTP
    await sendVerificationEmail({
      to: normalizedEmail,
      code: rawCode,
      type: 'register',
      recipientName: fullName.trim(),
    });

    res.status(201).json({
      status: 'success',
      message: 'Account created. Verification code sent to email.',
      email: normalizedEmail,
      expiresInMinutes: 10,
    });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ status: 'error', message: 'Internal server error during registration.' });
  }
});

// 2. VERIFY OTP
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp, type = 'register' } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        status: 'error',
        message: 'Email and 6-digit verification code are required.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const cleanOtp = otp.toString().trim();

    // Fetch active OTP
    const otpRecord = await get(
      `SELECT * FROM otps WHERE email = ? AND type = ? AND is_used = 0 ORDER BY created_at DESC LIMIT 1`,
      [normalizedEmail, type]
    );

    if (!otpRecord) {
      return res.status(400).json({
        status: 'error',
        message: 'No active verification code found. Please request a new code.',
      });
    }

    const now = Date.now();
    if (now > otpRecord.expires_at) {
      await run('UPDATE otps SET is_used = 1 WHERE id = ?', [otpRecord.id]);
      return res.status(400).json({
        status: 'error',
        message: 'Verification code has expired. Please request a new code.',
      });
    }

    if (otpRecord.attempts >= MAX_OTP_ATTEMPTS) {
      await run('UPDATE otps SET is_used = 1 WHERE id = ?', [otpRecord.id]);
      return res.status(429).json({
        status: 'error',
        message: 'Maximum attempts exceeded. This code has been invalidated for security.',
      });
    }

    const expectedHash = hashOtp(normalizedEmail, cleanOtp, type);

    if (expectedHash !== otpRecord.otp_hash) {
      const remaining = MAX_OTP_ATTEMPTS - (otpRecord.attempts + 1);
      await run('UPDATE otps SET attempts = attempts + 1 WHERE id = ?', [otpRecord.id]);
      return res.status(400).json({
        status: 'error',
        message: `Incorrect code. ${remaining > 0 ? `${remaining} attempts remaining.` : 'Code locked.'}`,
      });
    }

    // Mark OTP used
    await run('UPDATE otps SET is_used = 1 WHERE id = ?', [otpRecord.id]);

    const user = await get('SELECT * FROM users WHERE email = ?', [normalizedEmail]);

    if (!user) {
      return res.status(404).json({ status: 'error', message: 'User account not found.' });
    }

    if (type === 'register') {
      // Mark user verified
      await run('UPDATE users SET is_verified = 1, updated_at = datetime("now") WHERE id = ?', [user.id]);
      user.is_verified = 1;

      const token = generateToken(user);

      return res.json({
        status: 'success',
        message: 'Email successfully verified.',
        token,
        user: {
          id: user.id,
          email: user.email,
          fullName: user.full_name,
          avatarUrl: user.avatar_url,
          phoneNumber: user.phone_number,
          bio: user.bio,
          tier: user.tier,
          isVerified: true,
          isProfileCompleted: user.is_profile_completed === 1,
        },
      });
    } else if (type === 'reset') {
      return res.json({
        status: 'success',
        message: 'Code verified. Proceed to password reset.',
        email: normalizedEmail,
        verifiedOtp: cleanOtp,
      });
    }
  } catch (err) {
    console.error('Verify OTP error:', err);
    res.status(500).json({ status: 'error', message: 'Internal server error verifying code.' });
  }
});

// 3. RESEND OTP
router.post('/resend-otp', async (req, res) => {
  try {
    const { email, type = 'register' } = req.body;

    if (!email) {
      return res.status(400).json({ status: 'error', message: 'Email is required.' });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await get('SELECT * FROM users WHERE email = ?', [normalizedEmail]);

    if (!user) {
      return res.status(404).json({ status: 'error', message: 'User account not found.' });
    }

    if (type === 'register' && user.is_verified === 1) {
      return res.status(400).json({ status: 'error', message: 'Account is already verified. Please log in.' });
    }

    // Check cooldown
    const latestOtp = await get(
      `SELECT * FROM otps WHERE email = ? AND type = ? ORDER BY created_at DESC LIMIT 1`,
      [normalizedEmail, type]
    );

    const now = Date.now();
    if (latestOtp && (now - latestOtp.created_at) < RESEND_COOLDOWN_MS) {
      const waitSeconds = Math.ceil((RESEND_COOLDOWN_MS - (now - latestOtp.created_at)) / 1000);
      return res.status(429).json({
        status: 'error',
        message: `Please wait ${waitSeconds}s before requesting another code.`,
        retryAfter: waitSeconds,
      });
    }

    // Invalidate previous OTPs
    await run('UPDATE otps SET is_used = 1 WHERE email = ? AND type = ?', [normalizedEmail, type]);

    const rawCode = generateOtpCode();
    const otpHash = hashOtp(normalizedEmail, rawCode, type);
    const expiresAt = now + OTP_EXPIRY_MS;

    await run(
      `INSERT INTO otps (id, email, otp_hash, type, attempts, expires_at, created_at, is_used)
       VALUES (?, ?, ?, ?, 0, ?, ?, 0)`,
      [uuidv4(), normalizedEmail, otpHash, type, expiresAt, now]
    );

    await sendVerificationEmail({
      to: normalizedEmail,
      code: rawCode,
      type,
      recipientName: user.full_name,
    });

    res.json({
      status: 'success',
      message: 'New verification code dispatched to your email.',
      email: normalizedEmail,
    });
  } catch (err) {
    console.error('Resend OTP error:', err);
    res.status(500).json({ status: 'error', message: 'Failed to resend verification code.' });
  }
});

// 4. LOGIN
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ status: 'error', message: 'Email and password are required.' });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await get('SELECT * FROM users WHERE email = ?', [normalizedEmail]);

    if (!user) {
      return res.status(401).json({ status: 'error', message: 'Invalid email or password.' });
    }

    const isMatch = await comparePassword(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ status: 'error', message: 'Invalid email or password.' });
    }

    // PREVENT UNVERIFIED USERS
    if (user.is_verified === 0) {
      return res.status(403).json({
        status: 'error',
        code: 'EMAIL_NOT_VERIFIED',
        message: 'Your email has not been verified yet. Please enter the verification code sent to your email.',
        email: user.email,
        fullName: user.full_name,
      });
    }

    const token = generateToken(user);

    res.json({
      status: 'success',
      message: 'Authentication successful.',
      token,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        avatarUrl: user.avatar_url,
        phoneNumber: user.phone_number,
        bio: user.bio,
        tier: user.tier,
        isVerified: true,
        isProfileCompleted: user.is_profile_completed === 1,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ status: 'error', message: 'Authentication service failure.' });
  }
});

// 5. FORGOT PASSWORD
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email || !isValidEmail(email)) {
      return res.status(400).json({ status: 'error', message: 'Please provide a valid email.' });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await get('SELECT * FROM users WHERE email = ?', [normalizedEmail]);

    if (!user) {
      // Generic response for security to avoid email enumeration
      return res.json({
        status: 'success',
        message: 'If an account exists with this email, a reset code has been sent.',
      });
    }

    const rawCode = generateOtpCode();
    const otpHash = hashOtp(normalizedEmail, rawCode, 'reset');
    const now = Date.now();
    const expiresAt = now + OTP_EXPIRY_MS;

    await run('UPDATE otps SET is_used = 1 WHERE email = ? AND type = "reset"', [normalizedEmail]);

    await run(
      `INSERT INTO otps (id, email, otp_hash, type, attempts, expires_at, created_at, is_used)
       VALUES (?, ?, ?, 'reset', 0, ?, ?, 0)`,
      [uuidv4(), normalizedEmail, otpHash, expiresAt, now]
    );

    await sendVerificationEmail({
      to: normalizedEmail,
      code: rawCode,
      type: 'reset',
      recipientName: user.full_name,
    });

    res.json({
      status: 'success',
      message: 'Password reset code dispatched to your email.',
      email: normalizedEmail,
    });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ status: 'error', message: 'Failed to process password reset.' });
  }
});

// 6. RESET PASSWORD
router.post('/reset-password', async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    if (!email || !otp || !newPassword) {
      return res.status(400).json({
        status: 'error',
        message: 'Email, verification code, and new password are required.',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        status: 'error',
        message: 'New password must be at least 6 characters long.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const cleanOtp = otp.toString().trim();

    // Verify OTP
    const expectedHash = hashOtp(normalizedEmail, cleanOtp, 'reset');
    const otpRecord = await get(
      `SELECT * FROM otps WHERE email = ? AND type = 'reset' AND otp_hash = ? AND is_used = 0`,
      [normalizedEmail, expectedHash]
    );

    if (!otpRecord) {
      return res.status(400).json({ status: 'error', message: 'Invalid or expired verification code.' });
    }

    if (Date.now() > otpRecord.expires_at) {
      return res.status(400).json({ status: 'error', message: 'Verification code has expired.' });
    }

    // Invalidate OTP
    await run('UPDATE otps SET is_used = 1 WHERE id = ?', [otpRecord.id]);

    const newHash = await hashPassword(newPassword);
    await run(
      'UPDATE users SET password_hash = ?, updated_at = datetime("now") WHERE email = ?',
      [newHash, normalizedEmail]
    );

    res.json({
      status: 'success',
      message: 'Password reset successfully. You can now log in with your new password.',
    });
  } catch (err) {
    console.error('Reset password error:', err);
    res.status(500).json({ status: 'error', message: 'Failed to reset password.' });
  }
});

// 7. DEV OUTBOX (Helper for development inspection)
router.get('/dev-mail', (req, res) => {
  res.json({
    status: 'success',
    outbox: getDevOutbox(),
  });
});

module.exports = router;
