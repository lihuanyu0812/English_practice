import fs from 'node:fs';
import path from 'node:path';
import { env } from '../config/env.js';
import { formatShanghaiDate, formatShanghaiDateTime } from './time.js';

const logDir = path.join(env.projectRoot, 'logs');
const sensitiveKeys = new Set(['password', 'token', 'phone', 'id_card', 'apikey', 'authorization']);

function maskSensitive(value) {
  if (Array.isArray(value)) return value.map(maskSensitive);
  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [
        key,
        sensitiveKeys.has(key.toLowerCase()) ? '***' : maskSensitive(item)
      ])
    );
  }
  return value;
}

function write(level, payload) {
  fs.mkdirSync(logDir, { recursive: true });
  const filePath = path.join(logDir, `log_${formatShanghaiDate()}.log`);
  const line = JSON.stringify({
    timestamp: formatShanghaiDateTime(),
    level,
    ...maskSensitive(payload)
  });
  fs.appendFileSync(filePath, `${line}\n`, 'utf8');
}

export const logger = {
  info(payload) {
    write('info', payload);
  },
  warn(payload) {
    write('warn', payload);
  },
  error(payload) {
    write('error', payload);
  },
  debug(payload) {
    write('debug', payload);
  }
};
