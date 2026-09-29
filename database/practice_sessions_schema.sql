CREATE DATABASE IF NOT EXISTS `study`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `study`;

CREATE TABLE IF NOT EXISTS `practice_sessions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键，自增练习记录 ID',
  `article_id` bigint unsigned NOT NULL COMMENT '引用 articles.id',
  `status` varchar(20) NOT NULL DEFAULT 'in_progress' COMMENT '状态：in_progress/completed',
  `started_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  `finished_at` datetime DEFAULT NULL COMMENT '完成时间',
  `correct_count` int unsigned NOT NULL DEFAULT 0 COMMENT '完全正确数量',
  `meaning_correct_but_not_applicable_count` int unsigned NOT NULL DEFAULT 0 COMMENT '意思正确但不适用数量',
  `incorrect_count` int unsigned NOT NULL DEFAULT 0 COMMENT '错误数量',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_practice_sessions_article_id` (`article_id`),
  KEY `idx_practice_sessions_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='练习记录';
