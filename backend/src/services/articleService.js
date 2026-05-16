import { getArticleById, getArticleTokens, listArticles } from '../dao/articleDao.js';
import { httpError } from '../utils/httpError.js';

export async function findArticles(level) {
  if (level && !['1', '2', '3', '4'].includes(String(level))) {
    throw httpError(400, 'level 必须是 1、2、3、4');
  }
  return listArticles(level);
}

export async function findArticleDetail(id) {
  const article = await getArticleById(id);
  if (!article) {
    throw httpError(404, '文章不存在');
  }
  const tokens = await getArticleTokens(id);
  return { ...article, tokens };
}
