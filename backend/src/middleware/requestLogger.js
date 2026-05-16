import { logger } from '../utils/logger.js';

export function requestLogger(req, res, next) {
  const startedAt = Date.now();
  res.on('finish', () => {
    logger.info({
      http_status: res.statusCode,
      code: res.statusCode < 400 ? 0 : res.statusCode,
      msg: res.statusCode < 400 ? '请求成功' : '请求失败',
      path: req.originalUrl,
      method: req.method,
      request_params: {
        query: req.query || {},
        body: req.body || {},
        path: req.params || {}
      },
      cost_ms: Date.now() - startedAt
    });
  });
  next();
}
