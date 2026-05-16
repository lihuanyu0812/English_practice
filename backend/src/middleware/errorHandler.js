import { logger } from '../utils/logger.js';

export function errorHandler(err, req, res, _next) {
  const status = err.statusCode || 500;
  logger.error({
    http_status: status,
    code: status,
    msg: err.message || '系统异常',
    path: req.originalUrl,
    method: req.method,
    request_params: {
      query: req.query || {},
      body: req.body || {},
      path: req.params || {}
    }
  });
  res.status(status).json({
    code: status,
    msg: err.publicMessage || err.message || '系统异常'
  });
}
