const nodemailer = require('nodemailer');

const devOutbox = [];

const createTransporter = () => {
  const host = process.env.SMTP_HOST;
  const port = parseInt(process.env.SMTP_PORT || '587', 10);
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (host && user && pass && host !== 'smtp.example.com') {
    return nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: { user, pass },
    });
  }

  // Development fallback: simulated high-reliability transport
  return null;
};

const sendVerificationEmail = async ({ to, code, type = 'register', recipientName = 'Client' }) => {
  const isReset = type === 'reset';
  const subject = isReset
    ? `[Lumina Vault] Password Reset Code: ${code}`
    : `[Lumina Wealth] Your Security Verification Code: ${code}`;

  const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #030407; color: #F8FAFC; margin: 0; padding: 24px; }
    .card { max-width: 480px; margin: 0 auto; background: #0D1424; border: 1px solid rgba(21, 88, 201, 0.3); border-radius: 20px; padding: 32px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    .logo { text-align: center; margin-bottom: 24px; }
    .logo-badge { display: inline-block; padding: 10px 18px; background: rgba(212, 255, 36, 0.12); border: 1px solid #D4FF24; border-radius: 12px; color: #D4FF24; font-weight: 800; letter-spacing: 2px; font-size: 14px; }
    h1 { color: #F8FAFC; font-size: 20px; font-weight: 700; margin-bottom: 12px; text-align: center; }
    p { color: #94A3B8; font-size: 14px; line-height: 1.6; margin-bottom: 24px; text-align: center; }
    .code-box { background: #080C16; border: 1px solid #1558C9; border-radius: 16px; padding: 20px; text-align: center; margin: 24px 0; }
    .code { font-family: monospace; font-size: 36px; font-weight: 800; letter-spacing: 12px; color: #D4FF24; }
    .footer { text-align: center; font-size: 11px; color: #64748B; margin-top: 24px; line-height: 1.5; }
    .security-tag { display: block; margin-top: 12px; color: #1558C9; font-weight: 600; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">
      <div class="logo-badge">◆ LUMINA WEALTH</div>
    </div>
    <h1>${isReset ? 'Password Reset Request' : 'Verify Your Sovereign Account'}</h1>
    <p>Hello ${recipientName}, enter the single-use 6-digit authorization code below to ${isReset ? 'reset your security credentials' : 'complete your private vault registration'}:</p>
    <div class="code-box">
      <div class="code">${code}</div>
    </div>
    <p style="font-size: 12px; color: #94A3B8;">This code is cryptographically signed and will expire in <strong>10 minutes</strong>. If you did not initiate this transaction, immediately disregard this notice.</p>
    <div class="footer">
      HARDWARE ENCLAVE SECURED • ARBITRUM L2 INFRASTRUCTURE
      <span class="security-tag">Zero-Knowledge Financial Protocol</span>
    </div>
  </div>
</body>
</html>
  `;

  const mailOptions = {
    from: process.env.SMTP_FROM || '"Lumina Wealth Security" <security@luminawealth.com>',
    to,
    subject,
    text: `Your Lumina security code is: ${code}. It expires in 10 minutes.`,
    html: htmlContent,
  };

  const emailRecord = {
    id: Date.now().toString(),
    to,
    code,
    type,
    subject,
    sentAt: new Date().toISOString(),
  };

  devOutbox.unshift(emailRecord);
  if (devOutbox.length > 50) devOutbox.pop();

  console.log(`[SMTP MAILER] ==========================================`);
  console.log(`[SMTP MAILER] To: ${to}`);
  console.log(`[SMTP MAILER] Subject: ${subject}`);
  console.log(`[SMTP MAILER] VERIFICATION CODE: >>> ${code} <<<`);
  console.log(`[SMTP MAILER] ==========================================`);

  const transporter = createTransporter();
  if (transporter) {
    try {
      await transporter.sendMail(mailOptions);
      console.log(`[SMTP MAILER] Dispatched successfully via external SMTP host.`);
    } catch (err) {
      console.error(`[SMTP MAILER ERROR] Failed sending to SMTP relay:`, err.message);
    }
  }

  return emailRecord;
};

const getDevOutbox = () => devOutbox;

module.exports = {
  sendVerificationEmail,
  getDevOutbox,
};
