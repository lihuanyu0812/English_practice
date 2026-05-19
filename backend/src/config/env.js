import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '../../..');

dotenv.config({ path: path.join(projectRoot, '.env'), quiet: true });

function numberEnv(name, fallback) {
  const value = process.env[name];
  if (value === undefined || value === '') return fallback;
  const parsed = Number(value);
  if (Number.isNaN(parsed)) {
    throw new Error(`${name} 必须是数字`);
  }
  return parsed;
}

export const env = {
  projectRoot,
  backendHost: process.env.BACKEND_HOST || '0.0.0.0',
  backendPort: numberEnv('BACKEND_PORT', 8016),
  mysql: {
    host: process.env.MYSQL_HOST || '127.0.0.1',
    port: numberEnv('MYSQL_PORT', 3306),
    user: process.env.MYSQL_USER || 'root',
    password: process.env.MYSQL_PASSWORD || '',
    database: process.env.MYSQL_DATABASE || 'study',
    charset: process.env.MYSQL_CHARSET || 'utf8mb4'
  }
};
