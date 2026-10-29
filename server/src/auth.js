const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'lumina_vault_ultra_secure_jwt_secret_key_2026';
const JWT_EXPIRES_IN = '7d';

// Generate cryptographically secure 6-digit numeric OTP
const generateOtpCode = () => {
  return crypto.randomInt(100000, 999999).toString();
};

// Hash OTP with SHA-256
const hashOtp = (email, code, type) => {
  return crypto
    .createHash('sha256')
    .update(`${email}:${code}:${type}:${JWT_SECRET}`)
    .digest('hex');
};

// Password Hashing
const hashPassword = async (plainPassword) => {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(plainPassword, salt);
};

const comparePassword = async (plainPassword, hash) => {
  return bcrypt.compare(plainPassword, hash);
};

// JWT Token Generation
const generateToken = (user) => {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      isVerified: user.is_verified === 1,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

// Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      status: 'error',
      message: 'Access denied: Authentication token required',
    });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({
        status: 'error',
        message: 'Invalid or expired session token',
      });
    }

    req.user = decoded;
    next();
  });
};

module.exports = {
  generateOtpCode,
  hashOtp,
  hashPassword,
  comparePassword,
  generateToken,
  authenticateToken,
};
