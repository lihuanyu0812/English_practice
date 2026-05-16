<template>
  <main class="shell">
    <section class="topbar">
      <div>
        <p class="eyebrow">English Practice</p>
        <h1>英语文章练习系统</h1>
      </div>
      <div class="status-pill">逐词输入</div>
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
              <article :class="{ locked: !allCorrect }">
                <h3>英文</h3>
                <p v-if="allCorrect">{{ currentArticle.english_text }}</p>
                <p v-else class="locked-copy">全部输入完成且完全正确后显示完整英文</p>
              </article>
            </div>
          </div>

          <div class="practice-box">
            <div class="progress-row">
              <span>进度 {{ currentIndex + 1 }} / {{ tokens.length }}</span>
              <progress :value="progressValue" :max="tokens.length"></progress>
              <button
                v-if="!result"
                class="start-button"
                type="button"
                :disabled="hasStarted"
                @click="startPractice"
              >
                {{ hasStarted ? '练习中' : '开始' }}
              </button>
              <button v-else class="start-button" type="button" @click="restartPractice">
                重新开始
              </button>
            </div>

            <template v-if="!result">
              <div class="word-card">
                <div class="word-marker">当前单词 #{{ currentToken?.token_order }}</div>
                <div class="typing-row">
                  <input
                    ref="answerInput"
                    v-model="sentenceInput"
                    autocomplete="off"
                    placeholder="连续输入，例如 good morning lily"
                    :disabled="!sessionId || !hasStarted"
                    @input="handleTyping"
                    @keydown.space.prevent="handleSpace"
                  />
                </div>
              </div>

              <div class="hint" :class="{ visible: showHint }">
                <div>
                  <span class="hint-label">单词</span>
                  <strong>{{ currentToken?.target_word }}</strong>
                </div>
                <div>
                  <span class="hint-label">词性</span>
                  <strong>{{ currentToken?.part_of_speech }}</strong>
                </div>
                <div>
                  <span class="hint-label">翻译</span>
                  <strong>{{ currentToken?.translation }}</strong>
                </div>
                <a :href="currentToken?.grammar_link" target="_blank" rel="noreferrer">查看语法</a>
              </div>
            </template>

            <div v-else class="result-panel">
              <div class="score-grid">
                <div>
                  <span>完全正确</span>
                  <strong>{{ result.correctCount }}</strong>
                </div>
                <div>
                  <span>意思正确但不适用</span>
                  <strong>{{ result.meaningCorrectButNotApplicableCount }}</strong>
                </div>
                <div>
                  <span>错误</span>
                  <strong>{{ result.incorrectCount }}</strong>
                </div>
              </div>
              <table>
                <thead>
                  <tr>
                    <th>#</th>
                    <th>目标词</th>
                    <th>输入</th>
                    <th>结果</th>
                    <th>说明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in result.answers" :key="item.articleTokenId">
                    <td>{{ item.tokenOrder }}</td>
                    <td>{{ item.targetWord }}</td>
                    <td>{{ item.userInput }}</td>
                    <td>{{ resultText(item.resultStatus) }}</td>
                    <td>{{ item.aiReason || item.translation }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
      </section>
    </section>
  </main>
</template>

<script setup>
import { computed, nextTick, onMounted, ref } from 'vue';

const articles = ref([]);
const selectedLevel = ref('');
const currentArticle = ref(null);
const sessionId = ref(null);
const currentIndex = ref(0);
const sentenceInput = ref('');
const hasStarted = ref(false);
const showHint = ref(false);
const loading = ref(false);
const submitting = ref(false);
const errorMessage = ref('');
const result = ref(null);
const answerInput = ref(null);
let hintTimer = null;

const tokens = computed(() => currentArticle.value?.tokens || []);
const currentToken = computed(() => tokens.value[currentIndex.value]);
const progressValue = computed(() => (result.value ? tokens.value.length : currentIndex.value));
const currentWord = computed(() => sentenceInput.value.split(' ').at(-1) || '');
const allCorrect = computed(
  () =>
    Boolean(result.value) &&
    result.value.correctCount === tokens.value.length &&
    result.value.meaningCorrectButNotApplicableCount === 0 &&
    result.value.incorrectCount === 0
);

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
  currentIndex.value = 0;
  sentenceInput.value = '';
  hasStarted.value = false;
  result.value = null;
  clearHintTimer();
}

async function startPractice() {
  if (!sessionId.value || hasStarted.value || result.value) return;
  hasStarted.value = true;
  resetHintTimer();
  await nextTick();
  answerInput.value?.focus();
}

async function submitCurrentWord() {
  if (submitting.value) return;
  const currentAnswer = currentWord.value.trim();
  if (!currentToken.value || !currentAnswer) return;
  submitting.value = true;
  errorMessage.value = '';
  try {
    await api(`/api/practice-sessions/${sessionId.value}/answers`, {
      method: 'POST',
      body: JSON.stringify({
        articleTokenId: currentToken.value.id,
        userInput: currentAnswer
      })
    });
    if (currentIndex.value + 1 >= tokens.value.length) {
      await finishPractice();
    } else {
      currentIndex.value += 1;
      sentenceInput.value = `${sentenceInput.value.trim()} `;
      if (hasStarted.value) {
        resetHintTimer();
      }
      await nextTick();
      answerInput.value?.focus();
    }
  } catch (error) {
    errorMessage.value = error.message;
  } finally {
    submitting.value = false;
    await nextTick();
    answerInput.value?.focus();
  }
}

function handleTyping(event) {
  if (!hasStarted.value) return;
  const normalizedValue = event.target.value.replace(/\s+/g, ' ');
  if (event.target.value !== normalizedValue) {
    sentenceInput.value = normalizedValue;
    event.target.value = normalizedValue;
  }
  syncCurrentIndexFromInput();

  resetHintTimer();

  if (isLastWordComplete()) {
    submitCurrentWord();
  }
}

function syncCurrentIndexFromInput() {
  const confirmedCount = sentenceInput.value.endsWith(' ')
    ? sentenceInput.value.trim().split(' ').filter(Boolean).length
    : Math.max(sentenceInput.value.trim().split(' ').filter(Boolean).length - 1, 0);
  currentIndex.value = Math.min(confirmedCount, Math.max(tokens.value.length - 1, 0));
}

async function handleSpace() {
  if (!hasStarted.value) return;
  await submitCurrentWord();
}

async function finishPractice() {
  clearHintTimer();
  result.value = await api(`/api/practice-sessions/${sessionId.value}/finish`, {
    method: 'POST',
    body: JSON.stringify({})
  });
}

function clearHintTimer() {
  clearTimeout(hintTimer);
  showHint.value = false;
}

function resetHintTimer() {
  clearHintTimer();
  showHint.value = false;
  hintTimer = setTimeout(() => {
    showHint.value = true;
  }, 3000);
}

function levelName(level) {
  return {
    1: '一级 短句',
    2: '二级 长句',
    3: '三级 短文',
    4: '四级 长文'
  }[level];
}

function resultText(status) {
  return {
    correct: '完全正确',
    meaning_correct_but_not_applicable: '意思正确但不适用',
    incorrect: '错误',
    pending_review: '待判定'
  }[status] || status;
}

function isLastWordComplete() {
  if (!currentToken.value || currentIndex.value + 1 !== tokens.value.length) {
    return false;
  }
  return currentWord.value.trim().toLowerCase() === currentToken.value.target_word.trim().toLowerCase();
}

onMounted(async () => {
  try {
    await loadArticles();
  } catch (error) {
    errorMessage.value = error.message;
  }
});
</script>
