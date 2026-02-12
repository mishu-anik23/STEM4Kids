require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { sequelize, testConnection } = require('./config/database');
const { redisClient } = require('./config/redis');

// Import routes
const authRoutes = require('./routes/authRoutes');
const progressRoutes = require('./routes/progressRoutes');
const leaderboardRoutes = require('./routes/leaderboardRoutes');

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:3001',
    credentials: true
  }
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: ['http://localhost:3001', 'http://127.0.0.1:3001', 'http://localhost:8080', 'http://127.0.0.1:8080', /^https?:\/\/localhost:\d+$/, /^https?:\/\/127\.0\.0\.1:\d+$/],
  credentials: true
}));
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Too many requests from this IP, please try again later.'
});

app.use('/api/', limiter);

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/leaderboard', leaderboardRoutes);

// Socket.io for real-time leaderboard updates
io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`);

  // Join leaderboard room
  socket.on('join-leaderboard', (data) => {
    const { type } = data; // 'global' or 'weekly'
    socket.join(`leaderboard-${type}`);
    console.log(`User ${socket.id} joined ${type} leaderboard`);
  });

  // Leave leaderboard room
  socket.on('leave-leaderboard', (data) => {
    const { type } = data;
    socket.leave(`leaderboard-${type}`);
  });

  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.id}`);
  });
});

// Make io accessible to controllers
app.set('io', io);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Start server
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    console.log('Starting server initialization...');
    
    // Test database connection
    console.log('Testing database connection...');
    await testConnection();
    console.log('✅ Database connection established successfully');
    
    // Sync database models (in development)
    if (process.env.NODE_ENV === 'development') {
      console.log('Syncing database models...');
      await sequelize.sync({ alter: true });
      console.log('✅ Database models synchronized');
    }

    console.log(`Attempting to listen on port ${PORT}...`);
    // Start server
    server.listen(PORT, () => {
      console.log(`
╔═══════════════════════════════════════════╗
║   🎮 STEM Learning Game API Server       ║
║                                           ║
║   Environment: ${process.env.NODE_ENV?.padEnd(27) || 'development'.padEnd(27)}║
║   Port: ${PORT.toString().padEnd(34)}║
║   Database: Connected                    ║
║   Redis: Connected                       ║
║                                           ║
║   🚀 Server is running!                  ║
╚═══════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    console.error('Error stack:', error.stack);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  
  server.close(() => {
    console.log('Server closed');
  });

  await sequelize.close();
  await redisClient.quit();
  
  process.exit(0);
});

startServer();

module.exports = { app, server, io };
