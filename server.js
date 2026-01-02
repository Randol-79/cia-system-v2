
// ============================================================================
// WEBSOCKET SETUP
// ============================================================================

const wsService = new WebSocketService(io);
wsService.initialize();

// Make io available to other modules
app.set('io', io);

// ============================================================================
// GRACEFUL SHUTDOWN
// ============================================================================

const gracefulShutdown = async (signal) => {
  logger.info(`${signal} received. Starting graceful shutdown...`);
  
  // Close server
  server.close(async () => {
    logger.info('HTTP server closed');
    
    try {
      if (process.env.SKIP_EXTERNAL === 'true') {
        logger.warn('SKIP_EXTERNAL=true: Skipping external resource shutdown');
      } else {
        // Close database connections
        await sequelize.close();
        logger.info('Database connections closed');

        // Close Redis connections
        const redis = require('./config/redis');
        await redis.quit();
        logger.info('Redis connections closed');

        // Stop background jobs
        const orchestrator = OrchestratorService.getInstance();
        await orchestrator.shutdown();
        logger.info('Background jobs stopped');
      }

      logger.info('Graceful shutdown completed');
      process.exit(0);
    } catch (error) {
      logger.error('Error during graceful shutdown:', error);
      process.exit(1);
    }
  });
  
  // Force shutdown after 30 seconds
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Uncaught exception handler
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  gracefulShutdown('UNCAUGHT_EXCEPTION');
});

// Unhandled promise rejection handler (don't shut down for Slack auth errors)
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection:', reason);
  // Don't shut down for Slack API errors with placeholder tokens
  if (reason?.code === 'slack_webapi_platform_error') {
    logger.warn('Ignoring Slack authentication error (using placeholder tokens)');
    return;
  }
  gracefulShutdown('UNHANDLED_REJECTION');
});

// ============================================================================
// SERVER STARTUP
// ============================================================================

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

const startServer = async () => {
  try {
    // Optionally skip external services for local development
    if (process.env.SKIP_EXTERNAL === 'true') {
      logger.warn('SKIP_EXTERNAL=true: Skipping database, redis, and orchestrator initialization');
    } else {
      // Test database connection
      await testConnection();
      logger.info('Database connection established');

      // Sync database models (only in development)
      if (process.env.NODE_ENV === 'development') {
        await sequelize.sync({ alter: false });
        logger.info('Database models synchronized');
      }

      // Initialize orchestrator service
      const orchestrator = OrchestratorService.getInstance();
      await orchestrator.initialize();
      logger.info('Orchestrator service initialized');
    }

    // Start server
    server.listen(PORT, HOST, () => {
      logger.info(`🚀 CIA System API Server running on http://${HOST}:${PORT}`);
      logger.info(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`📚 API Docs: http://${HOST}:${PORT}/api/docs`);
      logger.info(`❤️  Health Check: http://${HOST}:${PORT}/health`);
      
      // Log enabled integrations
      const integrations = [];
      if (process.env.ACCELO_CLIENT_ID) integrations.push('Accelo');
      if (process.env.SLACK_BOT_TOKEN) integrations.push('Slack');
      if (process.env.GOOGLE_CLIENT_ID) integrations.push('Google Analytics');
      if (process.env.FIREFLIES_API_KEY) integrations.push('Fireflies');
      logger.info(`🔌 Enabled Integrations: ${integrations.join(', ') || 'None'}`);
      // Write PID file for debugging when running locally
      try {
        const fs = require('fs');
        const pidPath = require('path').join(__dirname, 'server.pid');
        fs.writeFileSync(pidPath, String(process.pid));
        logger.info(`Wrote PID ${process.pid} to ${pidPath}`);
      } catch (e) {
        logger.warn('Failed to write PID file:', e.message);
      }
    });
    
  } catch (error) {
    console.error('FATAL ERROR during startup:', error);
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
if (require.main === module) {
  startServer();
}

module.exports = { app, server, io };
