#!/bin/bash
# Pre-push check hook for Claude Code
# PreToolUse(Bash) で git push コマンドを検出し、プッシュ前チェックを実施する
#
# 機能:
# - プッシュ対象コミットのサマリー表示
# - 高リスクファイル変更の警告
# - 未コミット変更の検出
# - ユーザー確認の要求（ask）

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git push コマンド以外は即座にパス
if ! echo "$COMMAND" | grep -qE 'git\s+push'; then
  exit 0
fi

# --- プッシュ前チェック開始 ---

CONTEXT=""
HAS_WARNING=false

# 1. 未コミット変更の検出
UNCOMMITTED=$(git status --short 2>/dev/null || true)
if [ -n "$UNCOMMITTED" ]; then
  CONTEXT="${CONTEXT}⚠️ 未コミット変更あり:\n${UNCOMMITTED}\n\n"
  HAS_WARNING=true
fi

# 2. プッシュ対象コミットの取得
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
REMOTE_BRANCH=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")

if [ -n "$REMOTE_BRANCH" ]; then
  # リモート追跡ブランチがある場合: 未プッシュコミットを表示
  UNPUSHED=$(git log "${REMOTE_BRANCH}..HEAD" --oneline 2>/dev/null || true)
  if [ -n "$UNPUSHED" ]; then
    COMMIT_COUNT=$(echo "$UNPUSHED" | wc -l | tr -d ' ')
    CONTEXT="${CONTEXT}📋 プッシュ対象 (${COMMIT_COUNT}コミット):\n${UNPUSHED}\n\n"

    # 3. 高リスクファイルの変更チェック
    CHANGED_FILES=$(git diff "${REMOTE_BRANCH}..HEAD" --name-only 2>/dev/null || true)
  else
    CONTEXT="${CONTEXT}✅ プッシュ対象のコミットはありません\n\n"
    CHANGED_FILES=""
  fi
else
  # リモート追跡ブランチがない場合（新規ブランチ）
  CONTEXT="${CONTEXT}📋 新規ブランチ: ${CURRENT_BRANCH}\n"
  UNPUSHED=$(git log --oneline -10 2>/dev/null || true)
  CONTEXT="${CONTEXT}最新10コミット:\n${UNPUSHED}\n\n"
  CHANGED_FILES=$(git diff HEAD~10..HEAD --name-only 2>/dev/null || true)
fi

# 4. 高リスクファイルパターンのチェック
if [ -n "$CHANGED_FILES" ]; then
  HIGH_RISK=""
  MEDIUM_RISK=""

  while IFS= read -r file; do
    case "$file" in
      *api/*|*routes/*|*models/*|*schema/*)
        HIGH_RISK="${HIGH_RISK}  🔴 ${file}\n"
        ;;
      *config/*|*.env*|*.yaml|*.toml|*auth/*|*security/*)
        HIGH_RISK="${HIGH_RISK}  🔴 ${file}\n"
        ;;
      *utils/*|*lib/*|*helpers/*|*templates/*|*rules/*)
        MEDIUM_RISK="${MEDIUM_RISK}  🟡 ${file}\n"
        ;;
    esac
  done <<< "$CHANGED_FILES"

  if [ -n "$HIGH_RISK" ]; then
    CONTEXT="${CONTEXT}🔴 高リスクファイル変更:\n${HIGH_RISK}\n"
    HAS_WARNING=true
  fi
  if [ -n "$MEDIUM_RISK" ]; then
    CONTEXT="${CONTEXT}🟡 中リスクファイル変更:\n${MEDIUM_RISK}\n"
  fi

  FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
  CONTEXT="${CONTEXT}📁 変更ファイル数: ${FILE_COUNT}\n"
fi

# 5. 結果出力
if [ "$HAS_WARNING" = true ]; then
  # 警告あり → ユーザー確認を要求（ask）
  REASON=$(printf "Pre-push チェック結果:\n\n%b\nプッシュを実行しますか？" "$CONTEXT")
  jq -n --arg reason "$REASON" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "ask",
      "permissionDecisionReason": $reason
    }
  }'
  exit 0
else
  # 警告なし → コンテキスト追加のみ（自動許可はしない、通常の許可フローに委ねる）
  REASON=$(printf "Pre-push チェック結果:\n\n%b" "$CONTEXT")
  jq -n --arg reason "$REASON" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "additionalContext": $reason
    }
  }'
  exit 0
fi
