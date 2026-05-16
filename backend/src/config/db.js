import mysql from 'mysql2/promise';
import { env } from './env.js';

export const pool = mysql.createPool({
  host: env.mysql.host,
  port: env.mysql.port,
  user: env.mysql.user,
  password: env.mysql.password,
  database: env.mysql.database,
  charset: env.mysql.charset,
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: true
});
