import { getArticleById, getTokenByOrder } from '../dao/articleDao.js';
import { completeSession, createSession, getSession } from '../dao/practiceDao.js';
import { httpError } from '../utils/httpError.js';
import { normalizeWord } from '../utils/normalize.js';

export async function startSession(articleId) {
  const article = await getArticleById(articleId);
  if (!article) {
    throw httpError(404, '文章不存在');
  }
  const sessionId = await createSession(articleId);
  return { sessionId, articleId: Number(articleId), status: 'in_progress' };
}

export async function submitAnswer(sessionId, { articleTokenId, userInput }) {
  if (!articleTokenId) {
    throw httpError(400, 'articleTokenId 不能为空');
  }
  if (!String(userInput || '').trim()) {
    throw httpError(400, 'userInput 不能为空');
  }

  const session = await getSession(sessionId);
  if (!session) {
    throw httpError(404, '练习记录不存在');
  }
  if (session.status !== 'in_progress') {
    throw httpError(400, '练习已结束，不能继续提交');
  }

  const token = await getTokenByOrder(session.article_id, articleTokenId);
  if (!token) {
    throw httpError(400, '单词不属于当前练习文章');
  }

  const resultStatus =
    normalizeWord(userInput) === normalizeWord(token.target_word) ? 'correct' : 'incorrect';

  return {
    articleTokenId: Number(articleTokenId),
    resultStatus
  };
}

export async function finishSession(sessionId, summaryInput = {}) {
  const session = await getSession(sessionId);
  if (!session) {
    throw httpError(404, '练习记录不存在');
  }
  if (session.status === 'completed') {
    return {
      correctCount: session.correct_count,
      meaningCorrectButNotApplicableCount: session.meaning_correct_but_not_applicable_count,
      incorrectCount: session.incorrect_count,
      answers: []
    };
  }

  const summary = parseSummary(summaryInput);
  await completeSession({
    sessionId,
    correctCount: summary.correctCount,
    meaningCount: summary.meaningCorrectButNotApplicableCount,
    incorrectCount: summary.incorrectCount
  });
  return summary;
}

function parseSummary(summaryInput) {
  const correctCount = parseCount(summaryInput.correctCount, 'correctCount');
  const meaningCorrectButNotApplicableCount = parseCount(
    summaryInput.meaningCorrectButNotApplicableCount,
    'meaningCorrectButNotApplicableCount'
  );
  const incorrectCount = parseCount(summaryInput.incorrectCount, 'incorrectCount');

  return {
    correctCount,
    meaningCorrectButNotApplicableCount,
    incorrectCount,
    answers: Array.isArray(summaryInput.answers) ? summaryInput.answers : []
  };
}

function parseCount(value, name) {
  const count = Number(value);
  if (!Number.isInteger(count) || count < 0) {
    throw httpError(400, `${name} 必须是非负整数`);
  }
  return count;
}
