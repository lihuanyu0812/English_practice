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

  const uniqueWords = [...new Set(words.map((word) => normalizeDictionaryKey(word)))];
  const params = Object.fromEntries(uniqueWords.map((word, index) => [`word${index}`, word]));
  const placeholders = uniqueWords.map((_, index) => `:word${index}`).join(', ');
  const [dictionaryRows] = await pool.execute(
    `SELECT
       word AS dictionary_word,
       LOWER(word) AS normalized_word,
       sw AS lookup_word,
       phonetic,
       pos,
       translation AS dictionary_translation
     FROM study.stardict
     WHERE sw IN (${placeholders})`,
    params
  );
  const dictionaryByWord = new Map();
  for (const row of dictionaryRows) {
    const existingRow = dictionaryByWord.get(row.lookup_word);
    if (!existingRow || row.normalized_word === row.lookup_word) {
      dictionaryByWord.set(row.lookup_word, row);
    }
  }
  const rows = words.map((word, index) => ({
    id: index + 1,
    article_id: article.id,
    token_order: index + 1,
    target_word: word,
    ...dictionaryByWord.get(normalizeDictionaryKey(word))
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

function normalizeDictionaryKey(word) {
  return String(word || '').replace(/[^A-Za-z0-9]/g, '').toLowerCase();
}
