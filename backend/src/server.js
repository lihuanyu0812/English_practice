import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './utils/logger.js';

const app = createApp();

app.listen(env.backendPort, env.backendHost, () => {
  logger.info({
    msg: '后端服务已启动',
    host: env.backendHost,
    port: env.backendPort
  });
});
