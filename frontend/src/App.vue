<template>
  <main class="shell">
    <div
      v-if="showReward"
      class="reward-overlay"
      :class="{ hiding: rewardHiding }"
      @click="dismissReward"
    >
      <div class="reward-rays" aria-hidden="true"></div>
      <div class="reward-confetti" aria-hidden="true">
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
      </div>
      <div class="reward-card">
        <div class="reward-medal" aria-hidden="true">✓</div>
        <p class="reward-kicker">Good Work</p>
        <strong>{{ resultMessage }}</strong>
      </div>
    </div>

    <section class="topbar">
      <div>
        <p class="eyebrow">English Practice</p>
        <h1>英语文章练习系统</h1>
      </div>
      <div class="status-pill">自由输入</div>
    </section>

    <section class="workspace">
      <aside class="article-panel">
        <div class="filter-row">
          <label for="level">等级</label>
          <select id="level" v-model="selectedLevel" @change="loadArticles">
            <option value="">全部</option>
            <option value="1">一级 短句</option>
            <option value="2">二级 长句</option>
            <option value="3">三级 短文</option>
            <option value="4">四级 长文</option>
          </select>
        </div>

        <div class="article-list">
          <button
            v-for="article in articles"
            :key="article.id"
            class="article-item"
            :class="{ active: currentArticle?.id === article.id }"
            type="button"
            @click="selectArticle(article.id)"
          >
            <span>{{ article.title }}</span>
            <small>{{ levelName(article.level) }} · {{ article.word_count }}词</small>
          </button>
        </div>
      </aside>

      <section class="practice-panel">
        <div v-if="loading" class="empty-state">加载中</div>
        <div v-else-if="!currentArticle" class="empty-state">请选择一篇文章</div>
        <template v-else>
          <div class="article-copy">
            <div>
              <h2>{{ currentArticle.title }}</h2>
              <p class="meta">{{ levelName(currentArticle.level) }} · {{ currentArticle.word_count }} 个单词</p>
            </div>
            <div class="copy-grid">
              <article>
                <h3>中文</h3>
                <p>{{ currentArticle.chinese_text }}</p>
              </article>
              <article :class="{ locked: !result }">
                <h3>英文</h3>
                <p v-if="result">{{ currentArticle.english_text }}</p>
                <p v-else class="locked-copy">提交后显示完整英文</p>
                <div v-if="result && submittedInput" class="submitted-answer">
                  <h3>我的输入</h3>
                  <p>{{ submittedInput }}</p>
                </div>
              </article>
            </div>
          </div>

          <div class="practice-box">
            <div class="progress-row">
              <span>{{ result ? '已提交' : hasStarted ? '输入中' : '未开始' }}</span>
              <progress :value="progressValue" max="1"></progress>
              <button
                v-if="!result"
                class="start-button"
                type="button"
                :disabled="!sessionId || (hasStarted && (!currentInput.trim() || submitting))"
                @click="hasStarted ? submitPractice() : startPractice()"
              >
                {{ hasStarted ? (submitting ? '提交中' : '提交') : '开始' }}
              </button>
              <button v-else class="start-button" type="button" @click="restartPractice">
                重新开始
              </button>
            </div>

            <template v-if="!result">
              <div class="word-card">
                <div class="word-marker">输入你记得的英文单词，不要求顺序</div>
                <div class="typing-row">
                  <div
                    class="rich-input"
                    :class="{ disabled: !sessionId || !hasStarted }"
                    @click="focusAnswerInput"
                  >
                    <textarea
                      ref="answerInput"
                      v-model="currentInput"
                      class="free-answer-input"
                      autocomplete="off"
                      placeholder="例如：teacher windows"
                      :disabled="!sessionId || !hasStarted"
                      @input="handleTyping"
                      @keydown.enter.exact.prevent="submitPractice"
                    ></textarea>
                  </div>
                </div>
              </div>
            </template>

            <div v-else class="result-panel">
              <div class="result-message">{{ resultMessage }}</div>
            </div>
          </div>
        </template>

        <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
      </section>
    </section>
  </main>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref } from 'vue';

const articles = ref([]);
const selectedLevel = ref('');
const currentArticle = ref(null);
const sessionId = ref(null);
const currentInput = ref('');
const submittedInput = ref('');
const hasStarted = ref(false);
const loading = ref(false);
const submitting = ref(false);
const errorMessage = ref('');
const result = ref(null);
const answerInput = ref(null);
const showReward = ref(false);
const rewardHiding = ref(false);
let rewardTimer = null;

const tokens = computed(() => currentArticle.value?.tokens || []);
const progressValue = computed(() => (result.value ? 1 : 0));
const allCorrect = computed(
  () =>
    Boolean(result.value) &&
    result.value.correctCount === tokens.value.length &&
    result.value.meaningCorrectButNotApplicableCount === 0 &&
    result.value.incorrectCount === 0
);
const resultMessage = computed(() => {
  if (!result.value) return '';
  if (result.value.correctCount === 0) {
    return '本次没有输入正确的单词，请再接再励';
  }
  if (allCorrect.value) {
    return '恭喜，正确输入了所有单词';
  }
  return `恭喜，正确输入了${formatChineseCount(result.value.correctCount)}个单词`;
});

async function api(path, options = {}) {
  const response = await fetch(path, {
    headers: { 'Content-Type': 'application/json' },
    ...options
  });
  const payload = await response.json();
  if (!response.ok || payload.code !== 0) {
    throw new Error(payload.msg || '请求失败');
  }
  return payload.data;
}

async function loadArticles() {
  errorMessage.value = '';
  const query = selectedLevel.value ? `?level=${selectedLevel.value}` : '';
  articles.value = await api(`/api/articles${query}`);
}

async function selectArticle(articleId) {
  loading.value = true;
  errorMessage.value = '';
  result.value = null;
  submittedInput.value = '';
  try {
    currentArticle.value = await api(`/api/articles/${articleId}`);
    await resetPracticeSession(articleId);
  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    loading.value = false;
  }
}

async function restartPractice() {
  if (!currentArticle.value) return;
  loading.value = true;
  errorMessage.value = '';
  try {
    await resetPracticeSession(currentArticle.value.id);
  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    loading.value = false;
  }
}

async function resetPracticeSession(articleId) {
  const session = await api('/api/practice-sessions', {
    method: 'POST',
    body: JSON.stringify({ articleId })
  });
  sessionId.value = session.sessionId;
  currentInput.value = '';
  submittedInput.value = '';
  hasStarted.value = false;
  result.value = null;
}

async function startPractice() {
  if (!sessionId.value || hasStarted.value || result.value) return;
  hasStarted.value = true;
  await nextTick();
  answerInput.value?.focus();
}

async function submitPractice() {
  if (submitting.value) return;
  const currentAnswer = currentInput.value.trim();
  if (!sessionId.value || !currentAnswer) return;
  submitting.value = true;
  errorMessage.value = '';
  try {
    const summary = buildLocalSummary(currentAnswer);
    await api(`/api/practice-sessions/${sessionId.value}/finish`, {
      method: 'POST',
      body: JSON.stringify(summary)
    });
    result.value = summary;
    submittedInput.value = currentAnswer;
    hasStarted.value = false;
    if (summary.correctCount > 0) {
      openReward();
    }
  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    submitting.value = false;
    if (!result.value) {
      await nextTick();
      answerInput.value?.focus();
    }
  }
}

function openReward() {
  clearRewardTimer();
  rewardHiding.value = false;
  showReward.value = true;
}

function dismissReward() {
  if (!showReward.value || rewardHiding.value) return;
  rewardHiding.value = true;
  rewardTimer = setTimeout(() => {
    showReward.value = false;
    rewardHiding.value = false;
    rewardTimer = null;
  }, 500);
}

function handleGlobalKeydown() {
  dismissReward();
}

function clearRewardTimer() {
  if (!rewardTimer) return;
  clearTimeout(rewardTimer);
  rewardTimer = null;
}

function handleTyping() {
  if (!hasStarted.value) return;
  errorMessage.value = '';
}

async function focusAnswerInput() {
  if (!hasStarted.value || result.value) return;
  await nextTick();
  answerInput.value?.focus();
}

function buildLocalSummary(answerText) {
  const remainingTargetCounts = buildTargetCounts();
  const inputWords = splitInputWords(answerText);
  const answers = inputWords.map((word) => {
    const normalizedWord = normalizeWord(word);
    const remainingCount = remainingTargetCounts.get(normalizedWord) || 0;
    const isCorrect = remainingCount > 0;
    if (isCorrect) {
      remainingTargetCounts.set(normalizedWord, remainingCount - 1);
    }
    return {
      articleTokenId: null,
      tokenOrder: null,
      targetWord: '',
      userInput: word,
      resultStatus: isCorrect ? 'correct' : 'incorrect',
      aiReason: '',
      phonetic: '',
      translation: ''
    };
  });
  const correctCount = answers.filter((item) => item.resultStatus === 'correct').length;
  const incorrectCount = answers.length - correctCount;
  return {
    correctCount,
    meaningCorrectButNotApplicableCount: 0,
    incorrectCount,
    answers
  };
}

function buildTargetCounts() {
  const counts = new Map();
  tokens.value.forEach((token) => {
    const word = normalizeWord(token.target_word);
    if (!word) return;
    counts.set(word, (counts.get(word) || 0) + 1);
  });
  return counts;
}

function splitInputWords(value) {
  return String(value || '')
    .split(/\s+/)
    .map((word) => word.trim())
    .filter((word) => normalizeWord(word));
}

function levelName(level) {
  return {
    1: '一级 短句',
    2: '二级 长句',
    3: '三级 短文',
    4: '四级 长文'
  }[level];
}

function normalizeWord(value) {
  return String(value || '')
    .trim()
    .replace(/[.,!?;:"'()[\]{}]/g, '')
    .toLowerCase();
}

function formatChineseCount(count) {
  const digits = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  if (count === 2) return '两';
  if (count >= 0 && count < 10) return digits[count];
  if (count === 10) return '十';
  if (count > 10 && count < 20) return `十${digits[count % 10]}`;
  if (count >= 20 && count < 100 && count % 10 === 0) return `${digits[Math.floor(count / 10)]}十`;
  if (count >= 20 && count < 100) {
    return `${digits[Math.floor(count / 10)]}十${digits[count % 10]}`;
  }
  return String(count);
}

onMounted(async () => {
  window.addEventListener('keydown', handleGlobalKeydown);
  try {
    await loadArticles();
  } catch (error) {
    errorMessage.value = error.message;
  }
});

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleGlobalKeydown);
  clearRewardTimer();
});
</script>
