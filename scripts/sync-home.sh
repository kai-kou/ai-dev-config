#!/usr/bin/env zsh
# sync-home.sh — ai-dev-config <-> ~/.claude 双方向同期スクリプト
# Ruler CLI のワークフローを補完し、agents/skills の同期を管理する
#
# Usage:
#   ./scripts/sync-home.sh pull   # ~/.claude → ai-dev-config（逆同期）
#   ./scripts/sync-home.sh push   # ai-dev-config → ~/.claude（デプロイ）
#   ./scripts/sync-home.sh diff   # 差分確認のみ（変更なし）
#   ./scripts/sync-home.sh apply  # ruler apply + push を一括実行

set -euo pipefail

# --- 定数定義 ---
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_HOME="${HOME}/.claude"

# 同期対象の定義（ソース側パス : デプロイ先パス）
declare -A SYNC_TARGETS=(
  ["agents"]="${PROJECT_ROOT}/claude-code/agents/:${CLAUDE_HOME}/agents/"
)

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- ヘルパー関数 ---

log_info()  { echo -e "${BLUE}[info]${NC} $1" }
log_ok()    { echo -e "${GREEN}[ok]${NC} $1" }
log_warn()  { echo -e "${YELLOW}[warn]${NC} $1" }
log_error() { echo -e "${RED}[error]${NC} $1" }

show_usage() {
  echo "Usage: $0 {pull|push|diff|apply}"
  echo ""
  echo "Commands:"
  echo "  pull   ~/.claude → ai-dev-config（実環境の変更をリポジトリに取り込む）"
  echo "  push   ai-dev-config → ~/.claude（リポジトリからデプロイ）"
  echo "  diff   差分確認のみ（変更なし）"
  echo "  apply  ruler apply + push を一括実行"
  exit 1
}

# 差分チェック（1カテゴリ分）
# $1: カテゴリ名, $2: プロジェクト側パス, $3: ホーム側パス
check_diff() {
  local category="$1"
  local project_path="$2"
  local home_path="$3"
  local has_diff=false

  echo ""
  log_info "=== ${category} ==="

  # 両方のディレクトリが存在するか確認
  if [[ ! -d "$project_path" ]]; then
    log_warn "プロジェクト側が存在しません: ${project_path}"
    return 1
  fi
  if [[ ! -d "$home_path" ]]; then
    log_warn "ホーム側が存在しません: ${home_path}"
    return 1
  fi

  # プロジェクト側のみに存在するファイル
  for f in "${project_path}"*.md; do
    [[ -f "$f" ]] || continue
    local basename="$(basename "$f")"
    if [[ ! -f "${home_path}${basename}" ]]; then
      log_warn "プロジェクトのみ: ${basename}"
      has_diff=true
    fi
  done

  # ホーム側のみに存在するファイル
  for f in "${home_path}"*.md; do
    [[ -f "$f" ]] || continue
    local basename="$(basename "$f")"
    if [[ ! -f "${project_path}${basename}" ]]; then
      log_warn "ホームのみ: ${basename}"
      has_diff=true
    fi
  done

  # 内容の差分チェック
  local diff_count=0
  local same_count=0
  for f in "${project_path}"*.md; do
    [[ -f "$f" ]] || continue
    local basename="$(basename "$f")"
    local home_file="${home_path}${basename}"
    [[ -f "$home_file" ]] || continue

    if ! diff -q "$f" "$home_file" > /dev/null 2>&1; then
      local lines_changed=$(diff "$f" "$home_file" 2>/dev/null | grep -c '^[<>]' || true)
      echo -e "  ${YELLOW}差分あり${NC}: ${basename} (${lines_changed} 行)"
      has_diff=true
      diff_count=$((diff_count + 1))
    else
      same_count=$((same_count + 1))
    fi
  done

  if [[ "$has_diff" == false ]]; then
    log_ok "全ファイル一致 (${same_count} files)"
  else
    log_info "一致: ${same_count}, 差分: ${diff_count}"
  fi
}

# rsync 実行（1カテゴリ分）
# $1: ソース, $2: デスティネーション, $3: dry-run flag
do_sync() {
  local src="$1"
  local dst="$2"
  local dry_run="${3:-false}"

  local rsync_opts=(-av --include='*.md' --exclude='*')
  if [[ "$dry_run" == true ]]; then
    rsync_opts+=(--dry-run)
  fi

  rsync "${rsync_opts[@]}" "$src" "$dst"
}

# --- メインコマンド ---

cmd_diff() {
  log_info "差分チェック開始"
  for category in "${(@k)SYNC_TARGETS}"; do
    local paths="${SYNC_TARGETS[$category]}"
    local project_path="${paths%%:*}"
    local home_path="${paths##*:}"
    check_diff "$category" "$project_path" "$home_path"
  done
  echo ""
  log_info "差分チェック完了（変更なし）"
}

cmd_pull() {
  log_info "Pull: ~/.claude → ai-dev-config"
  echo ""

  # まず差分を表示
  cmd_diff

  echo ""
  log_info "--- rsync プレビュー (dry-run) ---"
  for category in "${(@k)SYNC_TARGETS}"; do
    local paths="${SYNC_TARGETS[$category]}"
    local project_path="${paths%%:*}"
    local home_path="${paths##*:}"
    log_info "[${category}] ${home_path} → ${project_path}"
    do_sync "$home_path" "$project_path" true
  done

  echo ""
  echo -n "実行しますか？ [y/N]: "
  read -r confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    log_info "キャンセルしました"
    return 0
  fi

  for category in "${(@k)SYNC_TARGETS}"; do
    local paths="${SYNC_TARGETS[$category]}"
    local project_path="${paths%%:*}"
    local home_path="${paths##*:}"
    log_info "[${category}] 同期実行中..."
    do_sync "$home_path" "$project_path" false
  done

  log_ok "Pull 完了"
}

cmd_push() {
  log_info "Push: ai-dev-config → ~/.claude"
  echo ""

  log_info "--- rsync プレビュー (dry-run) ---"
  for category in "${(@k)SYNC_TARGETS}"; do
    local paths="${SYNC_TARGETS[$category]}"
    local project_path="${paths%%:*}"
    local home_path="${paths##*:}"
    log_info "[${category}] ${project_path} → ${home_path}"
    do_sync "$project_path" "$home_path" true
  done

  echo ""
  echo -n "実行しますか？ [y/N]: "
  read -r confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    log_info "キャンセルしました"
    return 0
  fi

  for category in "${(@k)SYNC_TARGETS}"; do
    local paths="${SYNC_TARGETS[$category]}"
    local project_path="${paths%%:*}"
    local home_path="${paths##*:}"
    log_info "[${category}] 同期実行中..."
    do_sync "$project_path" "$home_path" false
  done

  log_ok "Push 完了"
}

cmd_apply() {
  log_info "Ruler apply + Push 一括実行"
  echo ""

  # Step 1: ruler apply
  log_info "Step 1: ruler apply"
  if command -v ruler > /dev/null 2>&1; then
    (cd "$PROJECT_ROOT" && ruler apply --verbose)
  else
    log_error "ruler コマンドが見つかりません"
    return 1
  fi

  echo ""

  # Step 2: push
  log_info "Step 2: agents を ~/.claude にデプロイ"
  cmd_push
}

# --- エントリポイント ---

case "${1:-}" in
  diff)  cmd_diff  ;;
  pull)  cmd_pull  ;;
  push)  cmd_push  ;;
  apply) cmd_apply ;;
  *)     show_usage ;;
esac
