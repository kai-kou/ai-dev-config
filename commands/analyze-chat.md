このプロジェクトのCursorチャット履歴を分析して、カスタム設定（Subagent / Skill / Command / Rule）を提案してください。

## 分析手順

### Step 1: データ抽出

以下のPythonスクリプトを実行してチャット履歴を抽出してください:

```bash
python3 skills/chat-history-analyzer/scripts/extract_chat_history.py \
  "{project_root}" \
  --output /tmp/chat-history-analysis.json \
  --verbose
```

`skills/` が見つからない場合は `~/.cursor/skills/` から探してください。

### Step 2: 抽出データの読み込み

出力された `/tmp/chat-history-analysis.json` を読み込み、内容を把握してください。

### Step 3: 5軸パターン分析

以下の5軸でチャット履歴を分析してください:

1. **頻出リクエストパターン**: ユーザーが繰り返し依頼するタスクは何か
2. **ワークフローパターン**: 複数ステップの作業シーケンスがあるか
3. **ドメイン・技術スタック**: プロジェクト固有の技術領域は何か
4. **ファイル変更傾向**: どのファイルがどんなパターンで変更されるか
5. **既存設定ギャップ**: 現在の設定でカバーされていない領域はどこか

### Step 4: 既存設定の確認

プロジェクト内（および ~/.cursor/ 配下）の既存設定を確認し、重複しない提案を作成してください:
- `agents/` のAgent定義一覧
- `skills/` のSkill定義一覧
- `commands/` のCommand定義一覧
- `rules/` のRule定義一覧

### Step 5: 設定提案レポートの生成

分析結果を統合し、以下のフォーマットでレポートを出力してください:

```
reports/chat-analysis-{YYYY-MM-DD}.md
```

レポートには以下を含めてください:
- 分析サマリー（会話数、メッセージ数、期間）
- 発見されたパターン
- 新規Subagent提案（信頼度・根拠付き）
- 新規Skill提案（信頼度・根拠付き）
- 新規Command提案（信頼度・根拠付き）
- 新規Rule提案（信頼度・根拠付き）
- 既存設定の改善提案
- 実装優先度

### Step 6: POへの提示

レポートの要約を提示し、どの提案を実装するかPOに確認してください。

## 参照

- Agent定義: `agents/chat-history-analyzer.md`
- Pythonスクリプト: `skills/chat-history-analyzer/scripts/`
