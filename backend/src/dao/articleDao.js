import { pool } from '../config/db.js';

export async function listArticles(level) {
  const params = {};
  let sql = `
    SELECT id, level, title, chinese_text, english_text, word_count
    FROM articles
  `;
  if (level) {
    sql += ' WHERE level = :level';
    params.level = Number(level);
  }
  sql += ' ORDER BY level ASC, id ASC';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

export async function getArticleById(id) {
  const [rows] = await pool.execute(
    `SELECT id, level, title, chinese_text, english_text, word_count
     FROM articles
     WHERE id = :id`,
    { id }
  );
  return rows[0] || null;
}

export async function getArticleTokens(articleId) {
  const [rows] = await pool.execute(
    `SELECT id, article_id, token_order, target_word, part_of_speech, translation, grammar_link
     FROM article_tokens
     WHERE article_id = :articleId
     ORDER BY token_order ASC`,
    { articleId }
  );
  return rows;
}

export async function getTokenById(tokenId) {
  const [rows] = await pool.execute(
    `SELECT id, article_id, token_order, target_word, part_of_speech, translation, grammar_link
     FROM article_tokens
     WHERE id = :tokenId`,
    { tokenId }
  );
  return rows[0] || null;
}
