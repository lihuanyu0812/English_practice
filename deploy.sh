#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${PROJECT_DIR}/.env"
ENV_TEMPLATE_FILE="${PROJECT_DIR}/.env.example"
ACTION="${1:-start}"
COMPOSE_CMD=""
COMPOSE_ANSI_MODE="${COMPOSE_ANSI_MODE:-never}"

check_command() {
  local cmd="$1"
  local message="$2"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "错误: ${message}"
    exit 1
  fi
}

load_env() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    if [[ -f "${ENV_TEMPLATE_FILE}" ]]; then
      cp "${ENV_TEMPLATE_FILE}" "${ENV_FILE}"
      echo "已自动生成 ${ENV_FILE}。请先完成配置后重试。"
      exit 1
    fi
    echo "错误: 缺少 ${ENV_FILE} 和 ${ENV_TEMPLATE_FILE}，请先创建 .env 配置文件。"
    exit 1
  fi
  set -a
  source "${ENV_FILE}"
  set +a
}

resolve_compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
    return
  fi
  echo "错误: 未找到 Docker Compose，请安装 docker compose 插件或 docker-compose。"
  exit 1
}

check_docker_ready() {
  check_command docker "未安装 Docker，请先安装 Docker。"
  if ! docker info >/dev/null 2>&1; then
    echo "错误: Docker daemon 不可用，请先启动 Docker Desktop 或 Docker 服务。"
    exit 1
  fi
  resolve_compose_cmd
}

compose_exec() {
  COMPOSE_ANSI="${COMPOSE_ANSI_MODE}" COMPOSE_PROGRESS=plain ${COMPOSE_CMD} --ansi "${COMPOSE_ANSI_MODE}" -f "${PROJECT_DIR}/docker-compose.yml" "$@"
}

build_images() {
  compose_exec build --pull --no-cache backend frontend
  echo "前后端镜像已全量重建（--pull --no-cache）"
}

start_services() {
  local app_public_url="${APP_PUBLIC_URL:-http://localhost:9016}"
  local backend_public_url="${BACKEND_PUBLIC_URL:-http://localhost:${BACKEND_PORT:-8016}}"
  check_docker_ready
  build_images
  compose_exec up -d --no-build --force-recreate --remove-orphans
  echo "启动成功"
  echo "前端地址: ${app_public_url}"
  echo "后端地址: ${backend_public_url}"
}

stop_services() {
  check_docker_ready
  compose_exec down --remove-orphans
  printf "\n"
  echo "服务已停止并清理项目容器网络"
}

case "${ACTION}" in
  start)
    load_env
    start_services
    ;;
  stop)
    stop_services
    ;;
  restart)
    stop_services
    load_env
    start_services
    ;;
  *)
    echo "用法: ./deploy.sh [start|stop|restart]"
    exit 1
    ;;
esac
