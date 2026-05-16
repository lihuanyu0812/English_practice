import { Router } from 'express';
import { getArticle, getArticles } from '../controllers/articleController.js';

export const articleRoutes = Router();

articleRoutes.get('/articles', getArticles);
articleRoutes.get('/articles/:id', getArticle);
