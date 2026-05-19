import { pool } from '../config/db.js';

export async function createSession(articleId) {
  const [result] = await pool.execute(
    'INSERT INTO study.practice_sessions (article_id) VALUES (:articleId)',
    { articleId }
  );
  return result.insertId;
}

export async function getSession(sessionId) {
  const [rows] = await pool.execute(
    `SELECT
       id,
       article_id,
       status,
       started_at,
       finished_at,
       correct_count,
       meaning_correct_but_not_applicable_count,
       incorrect_count
     FROM study.practice_sessions
     WHERE id = :sessionId`,
    { sessionId }
  );
  return rows[0] || null;
}

export async function completeSession({ sessionId, correctCount, meaningCount, incorrectCount }) {
  await pool.execute(
    `UPDATE study.practice_sessions
     SET status = 'completed',
       finished_at = CURRENT_TIMESTAMP,
       correct_count = :correctCount,
       meaning_correct_but_not_applicable_count = :meaningCount,
       incorrect_count = :incorrectCount
     WHERE id = :sessionId`,
    { sessionId, correctCount, meaningCount, incorrectCount }
  );
}
