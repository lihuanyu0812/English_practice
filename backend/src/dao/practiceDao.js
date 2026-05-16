import { pool } from '../config/db.js';

export async function createSession(articleId) {
  const [result] = await pool.execute(
    'INSERT INTO practice_sessions (article_id) VALUES (:articleId)',
    { articleId }
  );
  return result.insertId;
}

export async function getSession(sessionId) {
  const [rows] = await pool.execute(
    `SELECT id, article_id, status, started_at, finished_at
     FROM practice_sessions
     WHERE id = :sessionId`,
    { sessionId }
  );
  return rows[0] || null;
}

export async function upsertAnswer({ sessionId, articleTokenId, userInput, resultStatus }) {
  await pool.execute(
    `INSERT INTO practice_answers (session_id, article_token_id, user_input, result_status)
     VALUES (:sessionId, :articleTokenId, :userInput, :resultStatus)
     ON DUPLICATE KEY UPDATE
       user_input = VALUES(user_input),
       result_status = VALUES(result_status),
       ai_reason = NULL,
       submitted_at = CURRENT_TIMESTAMP`,
    { sessionId, articleTokenId, userInput, resultStatus }
  );
}

export async function listAnswersForSession(sessionId) {
  const [rows] = await pool.execute(
    `SELECT
       pa.id,
       pa.session_id,
       pa.article_token_id,
       pa.user_input,
       pa.result_status,
       pa.ai_reason,
       at.token_order,
       at.target_word,
       at.part_of_speech,
       at.translation,
       at.grammar_link
     FROM practice_answers pa
     JOIN article_tokens at ON at.id = pa.article_token_id
     WHERE pa.session_id = :sessionId
     ORDER BY at.token_order ASC`,
    { sessionId }
  );
  return rows;
}

export async function updateAnswerReview(answerId, resultStatus, aiReason) {
  await pool.execute(
    `UPDATE practice_answers
     SET result_status = :resultStatus, ai_reason = :aiReason
     WHERE id = :answerId`,
    { answerId, resultStatus, aiReason }
  );
}

export async function completeSession({ sessionId, correctCount, meaningCount, incorrectCount }) {
  await pool.execute(
    `UPDATE practice_sessions
     SET status = 'completed',
       finished_at = CURRENT_TIMESTAMP,
       correct_count = :correctCount,
       meaning_correct_but_not_applicable_count = :meaningCount,
       incorrect_count = :incorrectCount
     WHERE id = :sessionId`,
    { sessionId, correctCount, meaningCount, incorrectCount }
  );
}
