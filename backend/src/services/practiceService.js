import { getArticleById, getArticleTokens, getTokenById } from '../dao/articleDao.js';
import {
  completeSession,
  createSession,
  getSession,
  listAnswersForSession,
  updateAnswerReview,
  upsertAnswer
} from '../dao/practiceDao.js';
import { httpError } from '../utils/httpError.js';
import { normalizeWord } from '../utils/normalize.js';
import { judgeMeaning } from './openaiJudgeService.js';

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

  const token = await getTokenById(articleTokenId);
  if (!token || Number(token.article_id) !== Number(session.article_id)) {
    throw httpError(400, '单词不属于当前练习文章');
  }

  const resultStatus =
    normalizeWord(userInput) === normalizeWord(token.target_word) ? 'correct' : 'pending_review';

  await upsertAnswer({
    sessionId,
    articleTokenId,
    userInput: String(userInput).trim(),
    resultStatus
  });

  return {
    articleTokenId: Number(articleTokenId),
    resultStatus
  };
}

export async function finishSession(sessionId) {
  const session = await getSession(sessionId);
  if (!session) {
    throw httpError(404, '练习记录不存在');
  }
  if (session.status === 'completed') {
    const answers = await listAnswersForSession(sessionId);
    return buildSummary(answers);
  }

  const article = await getArticleById(session.article_id);
  const tokens = await getArticleTokens(session.article_id);
  const answers = await listAnswersForSession(sessionId);

  if (answers.length !== tokens.length) {
    throw httpError(400, `练习尚未完成：已提交 ${answers.length}/${tokens.length} 个单词`);
  }

  for (const answer of answers.filter((item) => item.result_status === 'pending_review')) {
    const judgement = await judgeMeaning({
      articleEnglishText: article.english_text,
      targetWord: answer.target_word,
      translation: answer.translation,
      userInput: answer.user_input
    });
    await updateAnswerReview(answer.id, judgement.resultStatus, judgement.reason);
    answer.result_status = judgement.resultStatus;
    answer.ai_reason = judgement.reason;
  }

  const summary = buildSummary(answers);
  await completeSession({
    sessionId,
    correctCount: summary.correctCount,
    meaningCount: summary.meaningCorrectButNotApplicableCount,
    incorrectCount: summary.incorrectCount
  });
  return summary;
}

function buildSummary(answers) {
  const correctCount = answers.filter((item) => item.result_status === 'correct').length;
  const meaningCorrectButNotApplicableCount = answers.filter(
    (item) => item.result_status === 'meaning_correct_but_not_applicable'
  ).length;
  const incorrectCount = answers.filter((item) => item.result_status === 'incorrect').length;

  return {
    correctCount,
    meaningCorrectButNotApplicableCount,
    incorrectCount,
    answers: answers.map((item) => ({
      articleTokenId: item.article_token_id,
      tokenOrder: item.token_order,
      targetWord: item.target_word,
      userInput: item.user_input,
      resultStatus: item.result_status,
      aiReason: item.ai_reason,
      partOfSpeech: item.part_of_speech,
      translation: item.translation,
      grammarLink: item.grammar_link
    }))
  };
}
