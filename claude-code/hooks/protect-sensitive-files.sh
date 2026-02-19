#!/bin/bash
# Sensitive file protection hook for Claude Code
# PreToolUse(Edit|Write) で機密ファイルへの書き込みをブロックする
#
# 保護対象:
# - .env ファイル（.env, .env.local, .env.production 等）
# - credentials / secrets ファイル
# - SSH鍵 / GPG鍵

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# 保護パターンチェック
BLOCKED_REASON=""

case "$BASENAME" in
  .env|.env.local|.env.production|.env.staging|.env.development)
    BLOCKED_REASON="環境変数ファイル (${BASENAME}) への直接編集はブロックされています"
    ;;
  credentials.json|secrets.json|service-account*.json)
    BLOCKED_REASON="認証情報ファイル (${BASENAME}) への直接編集はブロックされています"
    ;;
  id_rsa|id_ed25519|*.pem|*.key)
    BLOCKED_REASON="秘密鍵ファイル (${BASENAME}) への直接編集はブロックされています"
    ;;
esac

# パスパターンチェック
if [ -z "$BLOCKED_REASON" ]; then
  case "$FILE_PATH" in
    */.ssh/*)
      BLOCKED_REASON="SSH設定ディレクトリ内のファイルへの編集はブロックされています"
      ;;
    */.gnupg/*)
      BLOCKED_REASON="GPG設定ディレクトリ内のファイルへの編集はブロックされています"
      ;;
  esac
fi

if [ -n "$BLOCKED_REASON" ]; then
  echo "$BLOCKED_REASON" >&2
  exit 2
fi

exit 0
