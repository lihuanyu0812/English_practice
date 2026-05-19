import { pool } from '../config/db.js';
import { assertDictionaryInfo, withDictionaryInfo } from '../utils/dictionary.js';

export async function listArticles(level) {
  const params = {};
  let sql = `
    SELECT id, level, title, chinese_text, english_text, word_count
    FROM study.articles
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
     FROM study.articles
     WHERE id = :id`,
    { id }
  );
  return rows[0] || null;
}

export async function getArticleTokens(articleId) {
  const article = await getArticleById(articleId);
  if (!article) return [];
  return getTokensForArticle(article);
}

export async function getTokensForArticle(article) {
  const words = splitEnglishWords(article.english_text);
  if (!words.length) return [];

  const uniqueWords = [...new Set(words.map((word) => word.toLowerCase()))];
  const params = Object.fromEntries(uniqueWords.map((word, index) => [`word${index}`, word]));
  const placeholders = uniqueWords.map((_, index) => `:word${index}`).join(', ');
  const [dictionaryRows] = await pool.execute(
    `SELECT
       word AS dictionary_word,
       LOWER(word) AS lookup_word,
       phonetic,
       pos,
       translation AS dictionary_translation
     FROM study.stardict
     WHERE LOWER(word) IN (${placeholders})`,
    params
  );
  const dictionaryByWord = new Map(dictionaryRows.map((row) => [row.lookup_word, row]));
  const rows = words.map((word, index) => ({
    id: index + 1,
    article_id: article.id,
    token_order: index + 1,
    target_word: word,
    ...dictionaryByWord.get(word.toLowerCase())
  }));
  assertDictionaryInfo(rows);
  return rows.map(withDictionaryInfo);
}

export async function getTokenByOrder(articleId, tokenOrder) {
  const article = await getArticleById(articleId);
  if (!article) return null;
  const tokens = await getTokensForArticle(article);
  return tokens.find((token) => Number(token.token_order) === Number(tokenOrder)) || null;
}

function splitEnglishWords(text) {
  return String(text || '').match(/[A-Za-z]+(?:[’'][A-Za-z]+)?/g) || [];
}
