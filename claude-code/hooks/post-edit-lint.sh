#!/bin/bash
# Post-edit lint check hook for Claude Code
# PostToolUse(Edit|Write) で発火し、編集後のファイルに対して軽量チェックを実行する
#
# 機能:
# - Markdownファイル: YAMLフロントマター構文チェック
# - シェルスクリプト: 基本構文チェック（bash -n）
# - JSON/YAMLファイル: 構文チェック
# チェック結果をstdoutに出力し、Claudeのコンテキストに追加する

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# ファイルが存在しない場合はスキップ（削除操作の場合）
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
EXTENSION="${BASENAME##*.}"
ISSUES=""

case "$EXTENSION" in
  md)
    # Markdownファイル: YAMLフロントマターの基本チェック
    FIRST_LINE=$(head -1 "$FILE_PATH" 2>/dev/null || true)
    if [ "$FIRST_LINE" = "---" ]; then
      # フロントマターの閉じ --- を確認
      CLOSING=$(sed -n '2,${/^---$/=}' "$FILE_PATH" 2>/dev/null | head -1)
      if [ -z "$CLOSING" ]; then
        ISSUES="${ISSUES}YAML frontmatter: 閉じ --- が見つかりません\n"
      fi
    fi
    ;;
  sh|bash)
    # シェルスクリプト: 構文チェック
    SYNTAX_ERR=$(bash -n "$FILE_PATH" 2>&1 || true)
    if [ -n "$SYNTAX_ERR" ]; then
      ISSUES="${ISSUES}Shell syntax error: ${SYNTAX_ERR}\n"
    fi
    ;;
  json)
    # JSONファイル: 構文チェック
    if command -v jq &>/dev/null; then
      JSON_ERR=$(jq empty "$FILE_PATH" 2>&1 || true)
      if [ -n "$JSON_ERR" ]; then
        ISSUES="${ISSUES}JSON syntax error: ${JSON_ERR}\n"
      fi
    fi
    ;;
esac

# 問題がある場合のみ出力（Claudeのコンテキストに追加される）
if [ -n "$ISSUES" ]; then
  printf "post-edit-lint: %s\n%b" "$FILE_PATH" "$ISSUES" >&2
fi

exit 0
