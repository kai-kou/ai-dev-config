---
name: chat-history-analyzer
description: CursorのチャットSQLite履歴を抽出・分析し、プロジェクトに特有のSubagent/Skill/Command/Ruleを提案するスキル。「チャット分析」「設定提案」「analyze-chat」と言われたら使用。
argument-hint: "[project-path]"
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
| ファイル変更 | 変更頻度・パターン・共変更クラスタ | 上位20ファイル |
| 設定ギャップ | 既存設定の未カバー領域 | 既存設定と照合 |

各パターンには**定量スコア**（信頼度0〜100点 + インパクト0〜100点）が付与される。

### 4. 既存設定チェック

プロジェクトと `~/.cursor/` の既存設定を確認し、重複しない提案を生成する。

### 5. レポート生成

`reports/chat-analysis-{YYYY-MM-DD}.md` に分析レポートを出力する。

レポートには以下が含まれる:
- 分析サマリー（会話数・メッセージ数・期間）
- 検出パターン（5軸 + 軸間クロス相関）
- 新規Subagent/Skill/Command/Rule提案（信頼度スコア・SP見積もり付き）
- 既存設定の改善提案
- 提案間依存分析と最適な実装順序
- 実装優先度ランキング

---

## 使用例

### 例1: 基本的な使い方（コマンド）

```
/analyze-chat
```

Cursorのチャット画面で `/analyze-chat` と入力するだけで、カレントプロジェクトのチャット履歴分析が開始される。

### 例2: 直接指示

```
このプロジェクトのチャット履歴を分析して、カスタム設定を提案してください
```

### 例3: 特定の観点に絞った分析

```
チャット履歴を分析して、特にワークフローの自動化提案に集中してください
```

### 例4: 既存設定の改善に焦点

```
チャット履歴を分析して、既存のSkill/Ruleの改善点を教えてください
```

### 出力例

分析完了後、`reports/chat-analysis-2026-02-13.md` のようなレポートが生成される:

```markdown
# Chat History Analysis Report

## プロジェクト: my-project
## 分析期間: 2026-01-15 〜 2026-02-13
## 分析会話数: 47件 / メッセージ数: 312件

## 提案一覧（総合優先度順）

### 新規Skill提案
| # | 名前 | 信頼度 | SP見積もり |
|---|------|--------|----------|
| 1 | test-generator | High (82点) | SP 3 |
| 2 | api-scaffolder | Medium (55点) | SP 5 |

### 新規Rule提案
| # | 名前 | 信頼度 | SP見積もり |
|---|------|--------|----------|
| 1 | import-order | High (75点) | SP 2 |
```

---

## データソース

| DB | パス | 内容 |
|----|------|------|
| Workspace State | `~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/state.vscdb` | 会話IDリスト |
| Global State | `~/Library/Application Support/Cursor/User/globalStorage/state.vscdb` | メッセージ本文 |
| AI Code Tracking | `~/.cursor/ai-tracking/ai-code-tracking.db` | ファイル変更追跡 |

## 依存スクリプト

| スクリプト | パス | 用途 |
|-----------|------|------|
| workspace_resolver.py | `scripts/workspace_resolver.py` | プロジェクト→ワークスペースハッシュ解決 |
| extract_chat_history.py | `scripts/extract_chat_history.py` | チャット履歴抽出・サマリー生成 |

---

## トラブルシューティング

→ 詳細: [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md)

よくある問題: ワークスペース未検出、WALロック、データ0件、大量データ処理、Pythonバージョン

---

## 制限事項

→ 詳細: [references/LIMITATIONS.md](references/LIMITATIONS.md)

- macOSのみサポート（Windows/Linux未対応）
- 増分分析なし（毎回全データ再分析）
- Cursor 0.45.x系で動作確認済み

---

## 前提条件

- Python 3.9+（macOS標準python3で動作確認済み）
- 外部パッケージ不要（標準ライブラリのみ使用: sqlite3, json, argparse）
- Cursorが対象プロジェクトで少なくとも1回以上使用されていること
- 分析精度を高めるには最低10会話以上の履歴があることが推奨

## 関連ファイル

| ファイル | パス | 役割 |
|---------|------|------|
| オーケストレータ | `agents/chat-history-analyzer.md` | 全体制御 |
| データ抽出Agent | `agents/chat-history-analyzer/chat-extractor.md` | Phase 1: 抽出 |
| パターン分析Agent | `agents/chat-history-analyzer/pattern-analyzer.md` | Phase 2: 5軸分析 |
| 設定提案Agent | `agents/chat-history-analyzer/config-proposer.md` | Phase 3: 提案生成 |
| コマンド | `commands/analyze-chat.md` | `/analyze-chat` コマンド |
