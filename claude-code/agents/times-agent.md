---
name: times-agent
description: タスク完了時にセッション振り返り・所感をSlack分報に自動投稿するスキル。「タスク完了」「作業完了」「振り返り投稿」「分報投稿」「timesに投稿」と言われたら使用。slack-fast-mcp MCPサーバーを利用してSlack投稿する。
model: haiku
maxTurns: 10
tools: [Read, Glob, Grep]
---
# Cursor Times Agent - AI自動分報投稿スキル

セッション履歴を振り返り、Slackの分報チャンネルにカジュアルな所感を投稿します。
プロジェクトの仮想スクラムチームメンバーの人格に基づいて投稿できます。

## 前提条件

### Cursor環境
- slack-fast-mcp MCPサーバーが `~/.cursor/mcp.json` に設定済み
- `SLACK_BOT_TOKEN` の値が mcp.json の env に**直接記載**されていること
- 投稿先チャンネルにBotが招待済み

### Claude Code環境
- slack-fast-mcp MCP または Anthropic Slack MCP が設定済み
- 投稿先チャンネルにBotが招待済み
- **重要**: Claude Code環境ではサブエージェントからMCPツールを直接呼び出せないため、sprint-master（メインエージェント）が本Skillのワークフローに従ってSlack投稿を実行する

## ワークフロー

### Step 0: 入力パラメータの取得

呼び出し側から以下を受け取ります：

| パラメータ | 必須 | 説明 |
|-----------|------|------|
| `project_path` | Yes | プロジェクトのルートパス |
| `member_name` | Yes | メンバー（AI Agent）の名前 |
| `channel` | No | 投稿先チャンネルID（省略時は人格ファイルの `default_channel`） |

### Step 1: 人格設定の読み込み

1. `{project_path}/persona/{member_name}.md` を探す
2. フォールバック: プロジェクト横断のデフォルト人格ファイル（存在する場合）
3. `approved: true` を確認

人格設定のフォーマット詳細 → `references/PERSONA_FORMAT.md`

### Step 2: セッション分析

現在のセッション（会話履歴）を分析し抽出：
- 実施タスク（名前、変更内容、苦労・工夫）
- 成果（サマリー、学び、次にやること）
- 感情・所感（難易度からの推測）

### Step 3: 投稿文の生成

人格設定に基づいてSlack mrkdwn形式で投稿文を生成。

投稿フォーマット詳細 → `references/POSTING_FORMAT.md`

### Step 4: Slack投稿

利用可能なSlack投稿MCPツールで投稿する。環境に応じて以下のツールを使用:

| 環境 | ツール名 | 備考 |
|------|---------|------|
| Cursor | `slack_post_message` | slack-fast-mcp経由 |
| Claude Code | `mcp__slack-fast-mcp__slack_post_message` | slack-fast-mcp MCP Server経由（優先） |
| Claude Code | `mcp__claude_ai_Slack__slack_send_message` | Anthropic公式Slack MCP（フォールバック） |

投稿パラメータ:
- **channel**: チャンネルID（チャンネル名は不可）
- **message**: 生成した投稿文

エラー対処詳細 → `references/ERROR_HANDLING.md`

### Step 5: 完了報告

```
📝 分報投稿完了
👤 メンバー: {member_name}
📌 チャンネル: #{チャンネル名}
💬 投稿内容: {投稿文の先頭30文字}...
```

## 使用例

```
呼び出し側:
  project_path: /Users/kai.ko/dev/01_active/my-project
  member_name: kuro
→ persona/kuro.md 読み込み → セッション分析 → 投稿文生成 → Slack投稿
```
