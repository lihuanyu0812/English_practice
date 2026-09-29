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
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键，自增词条 ID',
  `word` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '单词名称，精确保留大小写和重音差异',
  `sw` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT 'strip-word 模糊匹配键，去除非字母数字后转小写，如 long-time/long time/longtime -> longtime',
  `phonetic` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '音标，以英语英标为主',
  `definition` mediumtext COLLATE utf8mb4_unicode_ci COMMENT '单词英文释义，每行一个释义',
  `translation` text COLLATE utf8mb4_unicode_ci COMMENT '单词中文释义，每行一个释义',
  `pos` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '词性或语料库位置比例，用 / 分割不同位置，如 n:46/v:54 表示名词46%、动词54%',
  `collins` smallint DEFAULT '0' COMMENT '柯林斯星级',
  `oxford` smallint DEFAULT '0' COMMENT '是否为牛津三千核心词汇',
  `tag` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '考试或分类标签，空格分割，如 zk=中考、gk=高考、cet4=四级、cet6=六级、ky=考研、toefl=托福、ielts=雅思、gre=GRE',
  `bnc` int DEFAULT NULL COMMENT '英国国家语料库 BNC 词频顺序，偏传统和历史语料',
  `frq` int DEFAULT NULL COMMENT '当代语料库词频顺序，偏近现代语料',
  `exchange` text COLLATE utf8mb4_unicode_ci COMMENT '词形变化，/ 分割，如 p=过去式、d=过去分词、i=现在分词、3=第三人称单数、r=比较级、t=最高级、s=名词复数、0=Lemma、1=Lemma 的变换形式',
  `detail` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON 扩展信息，字典形式保存例句',
  `audio` text COLLATE utf8mb4_unicode_ci COMMENT '读音音频 URL',
  PRIMARY KEY (`id`),
  UNIQUE KEY `word_unique` (`word`),
  KEY `sw_word` (`sw`,`word`),
  KEY `collins_index` (`collins`),
  KEY `oxford_index` (`oxford`),
  KEY `tag_index` (`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=770612 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ECDICT 英文到中文双解词典表，包含释义、考试标签、词频、词形变化和模糊匹配键';

CREATE TABLE `word_resembles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `word` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '源词项，来自 resemble.txt，可为单词、短语或带说明词项',
  `similar_word` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '同义词或近义词词项，来自 resemble.txt，可为单词、短语或带说明词项',
  `word_sw` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '源词项 strip-word 模糊匹配键',
  `similar_sw` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '同义词或近义词词项 strip-word 模糊匹配键',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_word_similar` (`word`,`similar_word`),
  KEY `idx_word` (`word`),
  KEY `idx_similar_word` (`similar_word`),
  KEY `idx_word_sw` (`word_sw`),
  KEY `idx_similar_sw` (`similar_sw`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ECDICT 近义词和同义词关系表，由 resemble.txt 多词组展开生成';

CREATE TABLE `word_morph_notes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `word` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '词条，来自 resemble.txt 单词说明组',
  `word_sw` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '词条 strip-word 模糊匹配键',
  `note` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '词形、时态或用法说明',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_word_note` (`word`,`note`(255)),
  KEY `idx_word` (`word`),
  KEY `idx_word_sw` (`word_sw`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ECDICT 词形、时态和用法说明表，用于保存 resemble.txt 单词说明组';

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
