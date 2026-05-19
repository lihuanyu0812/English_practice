# 英语文章练习系统

一个用于英语单词输入练习的英语文章练习系统。第一版提供文章选择、自由输入和练习完成统计。

## 功能

- 从 MySQL `study.articles` 读取四个等级的中英文文章。
- 用户输入任意目标英文单词，不要求顺序，提交后统计正确数量。
- 单词音标、词性、翻译从 MySQL `study.stardict` 读取。
- 完成后统计正确输入数量，并写入 `study.practice_sessions`。

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
MYSQL_DATABASE=study
MYSQL_CHARSET=utf8mb4
```

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
