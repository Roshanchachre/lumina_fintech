require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDb } = require('./db');
const authRoutes = require('./routes/auth');
const { router: userRoutes } = require('./routes/user');

const app = express();
const PORT = process.env.PORT || 4040;

app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[HTTP] ${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'Lumina Sovereign Wealth API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: `Endpoint ${req.method} ${req.url} not found.`,
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error occurred.',
  });
});

const startServer = async () => {
  try {
    await initDb();
    console.log('[DATABASE] SQLite Ledger & Auth schema initialized successfully.');

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`[LUMINA SERVER] 🚀 Microservice running at http://localhost:${PORT}`);
      console.log(`[LUMINA SERVER] Health status available at http://localhost:${PORT}/health`);
    });
  } catch (err) {
    console.error('[STARTUP ERROR] Failed to start Lumina API:', err);
    process.exit(1);
  }
};

startServer();

module.exports = app;
