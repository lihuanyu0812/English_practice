# 英语文章练习系统

一个用于逐词输入练习的英语文章练习系统。第一版提供文章选择、逐词输入、3 秒提示、练习完成统计和 AI 语义判定。

## 功能

- 预置四个等级的中英文文章。
- 用户按顺序逐个输入英文单词。
- 当前单词超过 3 秒未输入完成时展示单词、词性、翻译、语法链接。
- 完成后统计完全正确、意思正确但不适用、错误数量。
- 非精确匹配答案通过 OpenAI Responses API 判定。

## 目录

- `docs/requirements.md`：需求文档
- `database/init.sql`：MySQL 初始化脚本
- `backend/`：Node.js 后端
- `frontend/`：Vue 前端
- `logs/`：运行日志目录
- `deploy.sh`：Docker Compose 部署脚本

## 配置

复制 `.env.example` 为 `.env` 并修改配置：

```env
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=9016

BACKEND_HOST=0.0.0.0
BACKEND_PORT=8016

MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_mysql_password
MYSQL_DATABASE=english_practice
MYSQL_CHARSET=utf8mb4

OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-5.4-mini
```

后端必须配置有效 `OPENAI_API_KEY` 才能完成非精确答案判定。若所有答案都完全正确，则不会调用 OpenAI。

## Docker 部署

```bash
chmod +x deploy.sh
./deploy.sh start
```

首次运行如果缺少 `.env`，脚本会从 `.env.example` 生成 `.env` 并提示先完成配置。

停止服务：

```bash
./deploy.sh stop
```

重启服务：

```bash
./deploy.sh restart
```

## 本地开发

后端：

```bash
cd backend
npm install
npm start
```

前端：

```bash
cd frontend
npm install
npm run dev
```

前端请求统一使用同源 `/api`，开发环境由 Vite 代理到后端。

## 测试

```bash
cd backend
npm test
```

## 日志

日志写入 `logs/log_yyyy-mm-dd.log`。每条日志是一行 JSON，时间使用 `Asia/Shanghai`，格式为 `yyyy-mm-dd hh24:mm:ss`。
