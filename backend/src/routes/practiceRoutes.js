import { Router } from 'express';
import {
  createPracticeAnswer,
  createPracticeSession,
  finishPracticeSession
} from '../controllers/practiceController.js';

export const practiceRoutes = Router();

practiceRoutes.post('/practice-sessions', createPracticeSession);
practiceRoutes.post('/practice-sessions/:id/answers', createPracticeAnswer);
practiceRoutes.post('/practice-sessions/:id/finish', finishPracticeSession);
