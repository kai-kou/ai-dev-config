#!/bin/bash
# Compact context re-injection hook for Claude Code
# SessionStart(compact) で発火し、コンパクション後に重要コンテキストを再注入する
#
# 機能:
# - 現在のスプリント情報を再注入
# - 直近のGitコミットを再注入
# - プロジェクトの重要ファイルパスを再注入

set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

if [ -z "$CWD" ]; then
  exit 0
fi

PROJECT_NAME=$(basename "$CWD")

# --- コンテキスト再注入 ---

echo "=== コンパクション後コンテキスト再注入 ==="
echo ""

# 1. プロジェクト情報
echo "## プロジェクト: ${PROJECT_NAME}"
echo "## ディレクトリ: ${CWD}"
echo ""

# 2. 現在のブランチ
BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo "## ブランチ: ${BRANCH}"
echo ""

# 3. 直近5コミット
echo "## 直近コミット:"
git -C "$CWD" log --oneline -5 2>/dev/null || echo "(取得失敗)"
echo ""

# 4. スプリントバックログの確認
BACKLOG_FILE="${CWD}/.sprint-logs/sprint-backlog.md"
if [ -f "$BACKLOG_FILE" ]; then
  SPRINT_ID=$(grep -m1 'id:' "$BACKLOG_FILE" | sed 's/.*id: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' 2>/dev/null || echo "unknown")
  SPRINT_STATUS=$(grep -m1 'status:' "$BACKLOG_FILE" | sed 's/.*status: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' 2>/dev/null || echo "unknown")
  echo "## スプリント: ${SPRINT_ID} (${SPRINT_STATUS})"
fi
echo ""

# 5. 未コミット変更
UNCOMMITTED=$(git -C "$CWD" status --short 2>/dev/null || true)
if [ -n "$UNCOMMITTED" ]; then
  echo "## 未コミット変更あり:"
  echo "$UNCOMMITTED"
fi

echo ""
echo "=== 再注入完了 ==="

exit 0
