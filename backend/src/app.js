import express from 'express';
import { articleRoutes } from './routes/articleRoutes.js';
import { practiceRoutes } from './routes/practiceRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';
import { requestLogger } from './middleware/requestLogger.js';

export function createApp() {
  const app = express();
  app.use(express.json({ limit: '1mb' }));
  app.use(requestLogger);
  app.get('/api/health', (_req, res) => {
    res.json({ code: 0, msg: 'ok' });
  });
  app.use('/api', articleRoutes);
  app.use('/api', practiceRoutes);
  app.use(errorHandler);
  return app;
}
