CREATE TABLE `articles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `level` tinyint unsigned NOT NULL COMMENT '文章等级：1短句，2长句，3短文，4长文',
  `title` varchar(120) NOT NULL COMMENT '文章标题',
  `chinese_text` text NOT NULL COMMENT '中文原文',
  `english_text` text NOT NULL COMMENT '英文原文',
  `word_count` int unsigned NOT NULL COMMENT '英文单词数量',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_articles_level` (`level`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章主表';

CREATE TABLE `stardict` (
  `id` int NOT NULL AUTO_INCREMENT,
  `word` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sw` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phonetic` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `definition` mediumtext COLLATE utf8mb4_unicode_ci,
  `translation` text COLLATE utf8mb4_unicode_ci,
  `pos` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `collins` smallint DEFAULT '0',
  `oxford` smallint DEFAULT '0',
  `tag` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bnc` int DEFAULT NULL,
  `frq` int DEFAULT NULL,
  `exchange` text COLLATE utf8mb4_unicode_ci,
  `detail` text COLLATE utf8mb4_unicode_ci,
  `audio` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `word_unique` (`word`),
  KEY `sw_word` (`sw`,`word`),
  KEY `collins_index` (`collins`),
  KEY `oxford_index` (`oxford`),
  KEY `tag_index` (`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=770612 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
