SET NAMES utf8mb4;

DROP TABLE IF EXISTS practice_answers;
DROP TABLE IF EXISTS practice_sessions;
DROP TABLE IF EXISTS article_tokens;
DROP TABLE IF EXISTS articles;

CREATE TABLE articles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  level TINYINT UNSIGNED NOT NULL COMMENT '文章等级：1短句，2长句，3短文，4长文',
  title VARCHAR(120) NOT NULL COMMENT '文章标题',
  chinese_text TEXT NOT NULL COMMENT '中文原文',
  english_text TEXT NOT NULL COMMENT '英文原文',
  word_count INT UNSIGNED NOT NULL COMMENT '英文单词数量',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  INDEX idx_articles_level (level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章主表';

CREATE TABLE article_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  article_id BIGINT UNSIGNED NOT NULL COMMENT '引用 articles.id',
  token_order INT UNSIGNED NOT NULL COMMENT '单词顺序，从1开始',
  target_word VARCHAR(80) NOT NULL COMMENT '目标英文单词',
  part_of_speech VARCHAR(40) NOT NULL COMMENT '词性',
  translation VARCHAR(160) NOT NULL COMMENT '中文翻译',
  grammar_link VARCHAR(500) NOT NULL COMMENT '语法链接',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_article_token_order (article_id, token_order),
  INDEX idx_article_tokens_article_id (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章单词序列表';

CREATE TABLE practice_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  article_id BIGINT UNSIGNED NOT NULL COMMENT '引用 articles.id',
  status VARCHAR(20) NOT NULL DEFAULT 'in_progress' COMMENT '状态：in_progress/completed',
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  finished_at DATETIME NULL COMMENT '完成时间',
  correct_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '完全正确数量',
  meaning_correct_but_not_applicable_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '意思正确但不适用数量',
  incorrect_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '错误数量',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  INDEX idx_practice_sessions_article_id (article_id),
  INDEX idx_practice_sessions_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='练习记录';

CREATE TABLE practice_answers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  session_id BIGINT UNSIGNED NOT NULL COMMENT '引用 practice_sessions.id',
  article_token_id BIGINT UNSIGNED NOT NULL COMMENT '引用 article_tokens.id',
  user_input VARCHAR(120) NOT NULL COMMENT '用户输入',
  result_status VARCHAR(50) NOT NULL COMMENT '判定结果：correct/pending_review/meaning_correct_but_not_applicable/incorrect',
  ai_reason VARCHAR(500) NULL COMMENT 'AI判定理由',
  submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_session_token (session_id, article_token_id),
  INDEX idx_practice_answers_session_id (session_id),
  INDEX idx_practice_answers_article_token_id (article_token_id),
  INDEX idx_practice_answers_result_status (result_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='逐词答案';

INSERT INTO articles (id, level, title, chinese_text, english_text, word_count) VALUES
(1, 1, '清晨问候', '早上好，莉莉。', 'Good morning Lily', 3),
(2, 2, '学习习惯', '每天练习英语能让你的表达更加自然。', 'Practicing English every day can make your expression more natural', 10),
(3, 3, '安静的图书馆', '图书馆很安静。学生们坐在窗边读书。一位老师轻声帮助一个男孩理解故事。', 'The library is quiet. Students sit near the windows and read books. A teacher gently helps a boy understand the story.', 21),
(4, 4, '雨后的城市', '雨停后，城市显得清新而明亮。人们走出办公室，沿着湿润的街道慢慢回家。空气里有泥土和花的味道。', 'After the rain stopped, the city looked fresh and bright. People left their offices and walked slowly home along the wet streets. The air carried the smell of soil and flowers, and the evening lights reflected softly on the road.', 40);

INSERT INTO article_tokens (article_id, token_order, target_word, part_of_speech, translation, grammar_link) VALUES
(1, 1, 'Good', 'adjective', '好的', 'https://dictionary.cambridge.org/grammar/british-grammar/adjectives'),
(1, 2, 'morning', 'noun', '早晨', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(1, 3, 'Lily', 'proper noun', '莉莉', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns-proper-and-common-nouns'),

(2, 1, 'Practicing', 'gerund', '练习', 'https://dictionary.cambridge.org/grammar/british-grammar/verb-patterns-verb-infinitive-or-verb-ing'),
(2, 2, 'English', 'proper noun', '英语', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns-proper-and-common-nouns'),
(2, 3, 'every', 'determiner', '每个', 'https://dictionary.cambridge.org/grammar/british-grammar/determiners'),
(2, 4, 'day', 'noun', '天', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(2, 5, 'can', 'modal verb', '能', 'https://dictionary.cambridge.org/grammar/british-grammar/modals-and-modality'),
(2, 6, 'make', 'verb', '使得', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(2, 7, 'your', 'determiner', '你的', 'https://dictionary.cambridge.org/grammar/british-grammar/possessives-pronouns'),
(2, 8, 'expression', 'noun', '表达', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(2, 9, 'more', 'adverb', '更加', 'https://dictionary.cambridge.org/grammar/british-grammar/adverbs'),
(2, 10, 'natural', 'adjective', '自然的', 'https://dictionary.cambridge.org/grammar/british-grammar/adjectives'),

(3, 1, 'The', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(3, 2, 'library', 'noun', '图书馆', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(3, 3, 'is', 'verb', '是', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(3, 4, 'quiet', 'adjective', '安静的', 'https://dictionary.cambridge.org/grammar/british-grammar/adjectives'),
(3, 5, 'Students', 'noun', '学生们', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(3, 6, 'sit', 'verb', '坐', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(3, 7, 'near', 'preposition', '在附近', 'https://dictionary.cambridge.org/grammar/british-grammar/prepositions'),
(3, 8, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(3, 9, 'windows', 'noun', '窗户', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(3, 10, 'and', 'conjunction', '和', 'https://dictionary.cambridge.org/grammar/british-grammar/conjunctions'),
(3, 11, 'read', 'verb', '阅读', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(3, 12, 'books', 'noun', '书', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(3, 13, 'A', 'article', '一个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(3, 14, 'teacher', 'noun', '老师', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(3, 15, 'gently', 'adverb', '轻柔地', 'https://dictionary.cambridge.org/grammar/british-grammar/adverbs'),
(3, 16, 'helps', 'verb', '帮助', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(3, 17, 'a', 'article', '一个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(3, 18, 'boy', 'noun', '男孩', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(3, 19, 'understand', 'verb', '理解', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(3, 20, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(3, 21, 'story', 'noun', '故事', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),

(4, 1, 'After', 'preposition', '在之后', 'https://dictionary.cambridge.org/grammar/british-grammar/prepositions'),
(4, 2, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 3, 'rain', 'noun', '雨', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 4, 'stopped', 'verb', '停止了', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(4, 5, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 6, 'city', 'noun', '城市', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 7, 'looked', 'verb', '看起来', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(4, 8, 'fresh', 'adjective', '清新的', 'https://dictionary.cambridge.org/grammar/british-grammar/adjectives'),
(4, 9, 'and', 'conjunction', '和', 'https://dictionary.cambridge.org/grammar/british-grammar/conjunctions'),
(4, 10, 'bright', 'adjective', '明亮的', 'https://dictionary.cambridge.org/grammar/british-grammar/adjectives'),
(4, 11, 'People', 'noun', '人们', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 12, 'left', 'verb', '离开', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(4, 13, 'their', 'determiner', '他们的', 'https://dictionary.cambridge.org/grammar/british-grammar/possessives-pronouns'),
(4, 14, 'offices', 'noun', '办公室', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 15, 'and', 'conjunction', '和', 'https://dictionary.cambridge.org/grammar/british-grammar/conjunctions'),
(4, 16, 'walked', 'verb', '走', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(4, 17, 'slowly', 'adverb', '慢慢地', 'https://dictionary.cambridge.org/grammar/british-grammar/adverbs'),
(4, 18, 'home', 'adverb', '回家', 'https://dictionary.cambridge.org/grammar/british-grammar/adverbs'),
(4, 19, 'along', 'preposition', '沿着', 'https://dictionary.cambridge.org/grammar/british-grammar/prepositions'),
(4, 20, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 21, 'wet', 'adjective', '潮湿的', 'https://dictionary.cambridge.org/grammar/british-grammar/adjectives'),
(4, 22, 'streets', 'noun', '街道', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 23, 'The', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 24, 'air', 'noun', '空气', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 25, 'carried', 'verb', '带有', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(4, 26, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 27, 'smell', 'noun', '气味', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 28, 'of', 'preposition', '的', 'https://dictionary.cambridge.org/grammar/british-grammar/prepositions'),
(4, 29, 'soil', 'noun', '泥土', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 30, 'and', 'conjunction', '和', 'https://dictionary.cambridge.org/grammar/british-grammar/conjunctions'),
(4, 31, 'flowers', 'noun', '花', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 32, 'and', 'conjunction', '和', 'https://dictionary.cambridge.org/grammar/british-grammar/conjunctions'),
(4, 33, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 34, 'evening', 'noun', '傍晚', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 35, 'lights', 'noun', '灯光', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns'),
(4, 36, 'reflected', 'verb', '反射', 'https://dictionary.cambridge.org/grammar/british-grammar/verbs'),
(4, 37, 'softly', 'adverb', '柔和地', 'https://dictionary.cambridge.org/grammar/british-grammar/adverbs'),
(4, 38, 'on', 'preposition', '在上面', 'https://dictionary.cambridge.org/grammar/british-grammar/prepositions'),
(4, 39, 'the', 'article', '这个', 'https://dictionary.cambridge.org/grammar/british-grammar/articles'),
(4, 40, 'road', 'noun', '道路', 'https://dictionary.cambridge.org/grammar/british-grammar/nouns');
