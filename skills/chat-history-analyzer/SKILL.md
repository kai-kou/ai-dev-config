---
name: chat-history-analyzer
description: CursorのチャットSQLite履歴を抽出・分析し、プロジェクトに特有のSubagent/Skill/Command/Ruleを提案するスキル。「チャット分析」「設定提案」「analyze-chat」と言われたら使用。
---

# Chat History Analyzer - チャット履歴分析Skill

CursorのSQLiteデータベースからプロジェクト固有のチャット履歴を抽出・分析し、カスタム設定（Subagent / Skill / Command / Rule）を自動提案する。

## 使用タイミング

- 新しいプロジェクトの初期設定最適化
- 既存プロジェクトの設定改善
- 「チャット履歴を分析して」「設定を提案して」と言われた時
- `/analyze-chat` コマンド実行時

## 実行手順

### 1. データ抽出

Pythonスクリプトでチャット履歴を抽出する:

```bash
python3 {skills_path}/chat-history-analyzer/scripts/extract_chat_history.py \
  "{project_root}" \
  --output /tmp/chat-history-analysis.json \
  --verbose
```

`{skills_path}` は以下を順に探索:
1. `{project_root}/skills` （プロジェクト内）
2. `~/.cursor/skills` （グローバル）

### 2. データ読み込み

出力JSONを読み込み、以下を把握する:
- `summary`: 全体統計（会話数、メッセージ数、期間、使用モデル）
- `conversations`: 会話ごとのユーザーメッセージ
- `file_changes`: ファイル変更パターン
- `all_user_messages`: 全ユーザーメッセージ（分析用）

### 3. 5軸パターン分析

| 軸 | 分析内容 | 閾値 |
|----|---------|------|
| 頻出リクエスト | 繰り返し依頼されるタスクパターン | 3回以上 |
| ワークフロー | 複数ステップの作業シーケンス | 2会話以上で共通 |
| ドメイン特性 | 技術スタック・専門領域 | ファイル拡張子・キーワード |
| ファイル変更 | 変更頻度・パターン | 上位20ファイル |
| 設定ギャップ | 既存設定の未カバー領域 | 既存設定と照合 |

### 4. 既存設定チェック

プロジェクトと `~/.cursor/` の既存設定を確認し、重複しない提案を生成する。

### 5. レポート生成

`reports/chat-analysis-{YYYY-MM-DD}.md` に分析レポートを出力する。

## データソース

| DB | パス | 内容 |
|----|------|------|
| Workspace State | `~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/state.vscdb` | 会話IDリスト |
| Global State | `~/Library/Application Support/Cursor/User/globalStorage/state.vscdb` | メッセージ本文 |
| AI Code Tracking | `~/.cursor/ai-tracking/ai-code-tracking.db` | ファイル変更追跡 |

## 依存スクリプト

| スクリプト | パス | 用途 |
|-----------|------|------|
| workspace_resolver.py | `scripts/workspace_resolver.py` | プロジェクト→ワークスペース解決 |
| extract_chat_history.py | `scripts/extract_chat_history.py` | チャット履歴抽出 |

## 前提条件

- Python 3.9+（macOS標準python3で動作確認済み）
- 外部パッケージ不要（標準ライブラリのみ使用: sqlite3, json, argparse）
- Cursorが対象プロジェクトで少なくとも1回以上使用されていること
