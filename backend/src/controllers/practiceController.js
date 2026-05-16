import { finishSession, startSession, submitAnswer } from '../services/practiceService.js';

export async function createPracticeSession(req, res, next) {
  try {
    const data = await startSession(req.body.articleId);
    res.status(201).json({ code: 0, msg: '请求成功', data });
  } catch (error) {
    next(error);
  }
}

export async function createPracticeAnswer(req, res, next) {
  try {
    const data = await submitAnswer(req.params.id, req.body);
    res.json({ code: 0, msg: '请求成功', data });
  } catch (error) {
    next(error);
  }
}

export async function finishPracticeSession(req, res, next) {
  try {
    const data = await finishSession(req.params.id);
    res.json({ code: 0, msg: '请求成功', data });
  } catch (error) {
    next(error);
  }
}
