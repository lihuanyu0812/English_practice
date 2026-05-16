import { findArticleDetail, findArticles } from '../services/articleService.js';

export async function getArticles(req, res, next) {
  try {
    const data = await findArticles(req.query.level);
    res.json({ code: 0, msg: '请求成功', data });
  } catch (error) {
    next(error);
  }
}

export async function getArticle(req, res, next) {
  try {
    const data = await findArticleDetail(req.params.id);
    res.json({ code: 0, msg: '请求成功', data });
  } catch (error) {
    next(error);
  }
}
