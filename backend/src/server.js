import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDB } from './config/db.js';
import { router as apiRouter } from './routes/apiRoutes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());

// Routes
app.use('/api', apiRouter);

// Root
app.get('/', (req, res) => {
  res.json({
    name: 'FixIt - Home Services Backend API',
    version: '1.0.0',
    documentation: '/api/health',
    endpoints: [
      '/api/cities',
      '/api/categories',
      '/api/services',
      '/api/bookings',
      '/api/providers',
      '/api/settings/platformFee',
      '/api/admin/analytics',
    ],
  });
});

// Centralized Error Handler
app.use((err, req, res, next) => {
  console.error(`[Error] ${err.stack}`);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

import { fileURLToPath } from 'node:url';

export { app };

// Initialize Database & Start Server only when executed directly
const isMainModule = process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1];
if (isMainModule) {
  connectDB().then(() => {
    app.listen(PORT, () => {
      console.log(`===============================================`);
      console.log(`  FixIt Backend Server running on port ${PORT}`);
      console.log(`  Health Check: http://localhost:${PORT}/api/health`);
      console.log(`===============================================`);
    });
  });
}
