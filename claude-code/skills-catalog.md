# Claude Code スキルカタログ

デプロイ先: `~/.claude/skills/`
スキル総数: 42個

## Frontmatter リファレンス

### Skill Frontmatter（SKILL.md）

```yaml
---
name: my-skill                         # 推奨。lowercase/numbers/hyphens、最大64文字
description: "[What]. [When/Trigger]." # 推奨。最大1024文字。What+When+Triggerパターン
argument-hint: "[args]"                # 任意。オートコンプリート時のヒント
disable-model-invocation: false        # 任意。trueでClaude自動起動を禁止
user-invocable: true                   # 任意。falseで/メニュー非表示
allowed-tools: Read, Grep, Glob        # 任意。実行中に許可するツール
model: claude-sonnet-4-6              # 任意。使用モデル
context: fork                          # 任意。"fork"でサブエージェント実行
agent: Explore                         # 任意。context:fork時のエージェントタイプ
hooks: {}                              # 任意。スキルスコープのライフサイクルフック
---
```

### Agent Frontmatter（`~/.claude/agents/`）

```yaml
---
name: my-agent                         # 必須。subagent_typeとして参照される
description: "[What]. [When/Trigger]." # 必須。エージェント選択の判断に使用
model: sonnet                          # 推奨。sonnet|opus|haiku
maxTurns: 20                           # 推奨。最大APIラウンドトリップ数
tools: [Read, Glob, Grep]              # 推奨。最小権限原則で設定
memory: user                           # 任意。永続メモリの有効化
---
```

### Description パターン（What + When + Trigger）

- ユーザー起動型: `[What]. [Context]. 「trigger」と言われたら使用。`
- 内部サブエージェント: `[What]. [Details]. [parent]の[Phase]で呼び出される。`

### Progressive Disclosure（スキル構造化）

SKILL.mdが肥大化する場合（目安: 150行超）、補助情報を `references/` に分離する:

```
skills/my-skill/
├── SKILL.md              # コア定義（使用タイミング・ワークフロー・使用例）
├── scripts/              # 実行スクリプト（ある場合）
└── references/            # 補助ファイル
    ├── TROUBLESHOOTING.md # トラブルシューティング
    ├── LIMITATIONS.md     # 制限事項・既知の問題
    ├── CRITERIA.md        # 評価基準・判定ロジック
    └── TEMPLATE.md        # 出力テンプレート
```

- SKILL.mdには概要とリンクのみ残し、詳細は参照ファイルに委譲
- 参照ファイルは自己完結（単独で理解可能）であること
- 新規スキル作成時のテンプレート: [docs/skill-template.md](../docs/skill-template.md)
- 品質チェック: [docs/skill-quality-checklist.md](../docs/skill-quality-checklist.md)

## 日常ワークフロー（5個）

| スキル | コマンド | 説明 |
|--------|---------|------|
| today | `/today` | 今日対応すべきタスクを全activeプロジェクトからスキャン |
| weekly-review | `/weekly-review` | 今週の振り返りと来週の計画を作成 |
| mtg-report | `/mtg-report` | MTG進捗報告を全activeプロジェクトについて作成 |
| slack-post | `/slack-post` | セッション内容をSlack分報に投稿 |
| times-agent | `/times-agent` | タスク完了時の振り返りをSlack分報に投稿 |

## プロジェクト管理（9個）

| スキル | コマンド | 説明 |
|--------|---------|------|
| project-new | `/project-new` | 新規プロジェクトを作成 |
| task-add | `/task-add` | タスクを追加 |
| task-update | `/task-update` | タスクのステータスを変更 |
| milestone-update | `/milestone-update` | マイルストーンのステータス更新 |
| status-change | `/status-change` | プロジェクトのステータス変更・フォルダ移動 |
| dashboard | `/dashboard` | DASHBOARD.mdを最新状態に更新 |
| analyze | `/analyze` | プロジェクトの進捗を詳細に分析 |
| inventory | `/inventory` | 全プロジェクトの棚卸し |
| project-list-sync | `/project-list-sync` | PROJECT_STATUS.mdをフォルダ実態に同期 |

## スプリント管理（8個）

| スキル | コマンド | 説明 |
|--------|---------|------|
| sprint-start | `/sprint-start` | スプリントを開始（プランニング→タスク実行） |
| sprint-status | `/sprint-status` | 現在のスプリント進捗とSP集計を表示 |
| sprint-end | `/sprint-end` | スプリントを終了（レビュー→レトロスペクティブ） |
| sprint-dashboard | `/sprint-dashboard` | 過去スプリント実績の横断分析 |
| sprint-master | `/sprint-master` | スプリント全体オーケストレーション |
| sprint-init | `/sprint-init` | プロジェクトのスプリント開発基盤を初期化・最新化 |
| meta-retro | `/meta-retro` | 複数スプリントの横断分析レポート |
| team-status | `/team-status` | チームメンバーの稼働状態・スプリント進捗 |
| try-list | `/try-list` | Tryストック一覧と棚卸し判定 |

## スプリントタスク実行 — Flower 5段階モデル（9個）

| スキル | コマンド | Flower Phase | 説明 |
|--------|---------|-------------|------|
| sprint-researcher | `/sprint-researcher` | Phase 1: Research | 技術調査・ベストプラクティス調査 |
| sprint-coder | `/sprint-coder` | Phase 2: Code | コーディング（新規/修正/リファクタリング） |
| sprint-mentor | `/sprint-mentor` | Phase 3: Plan | 実装計画の立案と自己批判 |
| sprint-tester | `/sprint-tester` | Phase 4: Test | テスト生成・検証 |
| sprint-reviewer | `/sprint-reviewer` | Phase 5: Review | コードレビュー（第三者視点） |
| sprint-documenter | `/sprint-documenter` | — | ドキュメント作成・更新 |
| sprint-refactorer | `/sprint-refactorer` | — | コードリファクタリング |
| po-assistant | `/po-assistant` | Planning | PO判断補佐・タスク優先度提案 |
| sp-estimator | `/sp-estimator` | Planning | SP見積もり（4軸評価） |

## 品質・レビュー（4個）

| スキル | コマンド | 説明 |
|--------|---------|------|
| pre-push | `/pre-push` | Push前に5軸でレビュー |
| pre-push-review | `/pre-push-review` | Push前にワークディレクトリを精査・自動修正 |
| regression-guard | `/regression-guard` | 変更影響分析とデグレ防止 |
| doc-review | `/doc-review` | ドキュメントを7軸で並列レビュー |

## ドキュメント・コンテンツ生成（4個）

| スキル | コマンド | 説明 |
|--------|---------|------|
| requirement-definition | `/requirement-definition` | 要件定義書をMarkdownで作成 |
| slides | `/slides` | Marpプレゼンテーションスライド作成 |
| infographic | `/infographic` | グラレコ風インフォグラフィック画像生成 |
| resume-screening | `/resume-screening` | 候補者の書類選考分析 |

## ユーティリティ（2個）

| スキル | コマンド | 説明 |
|--------|---------|------|
| analyze-chat | `/analyze-chat` | セッションログを分析しカスタム設定を提案 |
| slack-enable | `/slack-enable` | プロジェクトでSlack分報の自動投稿を有効化 |
