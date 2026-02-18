# Cursor カスタム設定 Git管理 要件定義書

**プロジェクト**: cursor-agents-skills
**作成日**: 2026-02-05
**最終更新**: 2026-02-13（SPRINT-005 T005: 調査ドキュメントから正式要件定義書へ改修）
**ステータス**: 運用中

---

## 1. プロジェクト概要

### 1.1 目的

Cursor IDE のカスタム設定（Agents / Skills / Commands / Rules / Persona）を GitHub リポジトリで一元管理し、以下を実現する。

- **バージョン管理**: 設定変更の履歴追跡とロールバック
- **可搬性**: 複数マシン間での設定共有
- **バックアップ**: 設定の消失リスク軽減
- **透明性**: 設定資産の可視化と棚卸し

### 1.2 スコープ

| 対象 | 管理ディレクトリ | 同期先 | 説明 |
|------|-----------------|--------|------|
| Agents | `agents/` | `~/.cursor/agents/` | カスタムサブエージェント定義 |
| Skills | `skills/` | `~/.cursor/skills/` | ユーザー独自スキル定義 |
| Commands | `commands/` | `~/.cursor/commands/` | スラッシュコマンド定義 |
| Rules | `rules/` | `~/.cursor/rules/` | グローバルルール（.mdc） |
| Persona | `persona/` | ※同期対象外 | Slack投稿用の人格設定 |

**スコープ外**:
- `~/.cursor/skills-cursor/`（Cursor公式スキル。アップデートで変更される）
- `~/.cursor/mcp.json`（APIキー等の機密情報を含む可能性）
- `~/.cursor/extensions/`（拡張機能バイナリ）
- `~/.cursor/projects/`（プロジェクト固有キャッシュ）
- `.cursor/rules/`（各プロジェクトのワークスペースルール。プロジェクト側で管理）

### 1.3 ステークホルダー

| ステークホルダー | 役割 | 利用シーン |
|-----------------|------|-----------|
| リポジトリ管理者（kai.ko） | 設定の追加・変更・同期 | 日常的な Cursor カスタマイズ |
| 将来の利用者 | 設定のクローン・適用 | 新環境セットアップ時 |
| AI Agent（Cursor内） | 設定の参照・提案 | スプリント実行時の自動読み込み |

---

## 2. 現状分析（As-Is）

### 2.1 技術的背景

Cursor IDE は `~/.cursor/` 配下にカスタム設定を配置する仕組みを持つ。

```
~/.cursor/
├── agents/              # カスタムサブエージェント定義 ★管理対象
├── skills/              # ユーザー独自スキル ★管理対象
├── skills-cursor/       # Cursor公式スキル（更新される可能性あり）
├── commands/            # スラッシュコマンド定義 ★管理対象
├── rules/               # グローバルルール ★管理対象
├── mcp.json             # MCPサーバー設定
├── argv.json            # VS Code起動引数
├── ide_state.json       # IDE状態（動的に変化）
├── projects/            # プロジェクト固有キャッシュ
├── extensions/          # 拡張機能
└── ...
```

### 2.2 技術的制約

| 制約 | 詳細 | 対応策 |
|------|------|--------|
| シンボリックリンク非対応 | Cursor の Agent Skills 機能はシンボリックリンクを認識しない | rsync による同期で対応 |
| `~/.cursor/` 直接リポジトリ化不可 | 動的ファイル（ide_state.json等）が多数存在 | 別ディレクトリでリポジトリ管理 |
| 同期の手動性 | 変更後に手動で rsync を実行する必要がある | 同期スクリプトの整備（T201で対応予定） |

### 2.3 アーキテクチャ決定記録

| 決定事項 | 選択 | 検討した代替案 | 決定理由 |
|---------|------|-------------|---------|
| リポジトリ構成 | 統合リポジトリ（1つ） | 個別リポジトリ（agents/skills別） | 一元管理の見通しの良さ、関連変更の同時コミット |
| 同期方式 | rsync `--delete` | シンボリックリンク、手動コピー | Cursor制約でsymlink不可。rsyncは差分同期で高速 |
| リポジトリ配置 | `~/dev/01_active/cursor-agents-skills` | `~/.cursor/` 内 | 動的ファイルとの混在を避けるため |
| ルール管理 | グローバルルールのみ | ワークスペースルールも含む | ワークスペースルールは各プロジェクト側で管理すべき |

---

## 3. 管理対象の詳細

### 3.1 Agents（サブエージェント定義）

- **配置**: `agents/`
- **ファイル形式**: Markdown（`.md`）、YAMLフロントマター付き
- **構成**: トップレベル定義（オーケストレータ）+ サブフォルダ（サブエージェント）
- **現在の登録数**: 12 トップレベル定義、35 サブエージェント定義

| エージェント | サブエージェント数 | 説明 |
|-------------|------------------|------|
| sprint-master | 3 | スプリント管理（planner, review-runner, retro） |
| chat-history-analyzer | 3 | チャット履歴分析・設定提案 |
| slide-generator | 3 | スライド画像生成 |
| document-review-all | 8 | ドキュメント多軸レビュー |
| pre-push-review | 5 | Push前コードレビュー |
| requirement-definition | 6 | 要件定義書自動生成 |
| regression-guard | 0 | デグレ防止分析 |
| cursor-times-agent | 0 | Slack分報投稿 |
| mtg-reporter | 0 | MTG報告サマリー生成 |
| project-analyzer | 3 | プロジェクト進捗分析 |
| project-manager | 0 | プロジェクトライフサイクル管理 |

### 3.2 Skills（スキル定義）

- **配置**: `skills/{skill-name}/SKILL.md`
- **ファイル形式**: Markdown（`.md`）、YAMLフロントマター付き
- **現在の登録数**: 15ファイル（12スキル + 参照ドキュメント）

| スキル | 説明 | カテゴリ |
|--------|------|---------|
| po-assistant | PO判断補佐 | スプリント管理 |
| sp-estimator | SP見積もり | スプリント管理 |
| sprint-coder | コーディング担当 | スプリント実行 |
| sprint-documenter | ドキュメンテーション担当 | スプリント実行 |
| sprint-tester | テスト生成・検証 | スプリント実行 |
| sprint-researcher | 技術リサーチ | スプリント実行 |
| sprint-mentor | 実装計画立案 | スプリント実行 |
| sprint-reviewer | コードレビュー | 品質保証 |
| sprint-refactorer | リファクタリング | 品質保証 |
| chat-history-analyzer | チャット履歴分析 | ユーティリティ |
| infographic-generator | インフォグラフィック生成 | ユーティリティ |
| cursor-times-agent | Slack分報投稿 | コミュニケーション |

### 3.3 Commands（スラッシュコマンド）

- **配置**: `commands/{command-name}.md`
- **ファイル形式**: Markdown（`.md`）
- **現在の登録数**: 24コマンド

| カテゴリ | コマンド数 | 例 |
|---------|----------|-----|
| スプリント管理 | 3 | sprint-start, sprint-end, sprint-status |
| タスク管理 | 4 | task-add, task-update, milestone-update, status-change |
| プロジェクト管理 | 2 | project-new, project-list-sync |
| レポート・分析 | 7 | mtg-report, weekly-review, analyze, dashboard, today 等 |
| ツール | 8 | slack-post, pre-push, doc-review, infographic, slides 等 |

### 3.4 Rules（グローバルルール）

- **配置**: `rules/{rule-name}.mdc`
- **ファイル形式**: MDC（YAMLフロントマター + Markdown）
- **現在の登録数**: 2ルール

| ルール | 適用条件 | 説明 |
|--------|---------|------|
| regression-prevention.mdc | alwaysApply: true | デグレ防止3段階防御モデル |
| story-point-guide.mdc | tasks.md, milestones.md等 | SP見積もり4軸評価ガイド |

### 3.5 Persona（人格設定）

- **配置**: `persona/{member-name}.md`
- **用途**: cursor-times-agent によるSlack分報投稿の人格設定
- **同期**: `~/.cursor/` への同期対象外（プロジェクト固有設定）
- **現在の登録数**: 9名

| 名前 | ペルソナ | 用途 |
|------|---------|------|
| kuro.md | くろ（デフォルト） | 一般タスク完了時の投稿 |
| sprint-coder.md | — | sprint-coder担当タスクの投稿 |
| sprint-documenter.md | — | sprint-documenter担当タスクの投稿 |
| sprint-master.md | — | スプリント全体完了時の投稿 |
| 他5名 | — | 各Skill担当時の投稿 |

---

## 4. 機能要件

### FR-01: バージョン管理

| ID | 要件 | 優先度 | ステータス |
|----|------|--------|-----------|
| FR-01-1 | Agents/Skills/Commands/Rulesの変更をGitで追跡できること | P0 | ✅ 実装済み |
| FR-01-2 | コミット単位で変更内容が明確であること | P1 | ✅ 実装済み |
| FR-01-3 | 任意のコミットにロールバックできること | P1 | ✅ Git標準機能 |

### FR-02: 同期

| ID | 要件 | 優先度 | ステータス |
|----|------|--------|-----------|
| FR-02-1 | リポジトリから `~/.cursor/` への同期ができること | P0 | ✅ rsync手動実行 |
| FR-02-2 | 同期時にリポジトリに存在しないファイルが削除されること | P1 | ✅ `--delete` オプション |
| FR-02-3 | 同期前にdry-runで差分確認ができること | P1 | ✅ rsync `-avn` |
| FR-02-4 | 同期スクリプトがワンコマンドで実行できること | P2 | ⬜ T201で対応予定 |

### FR-03: ドキュメンテーション

| ID | 要件 | 優先度 | ステータス |
|----|------|--------|-----------|
| FR-03-1 | 各Agent/Skillの用途・使い方が文書化されていること | P2 | ⬜ T101で対応予定 |
| FR-03-2 | 新規Agent/Skillの追加手順が文書化されていること | P2 | ⬜ T103で対応予定 |
| FR-03-3 | セットアップ手順が文書化されていること | P2 | ⬜ T104で対応予定 |
| FR-03-4 | 使用例・チュートリアルがあること | P3 | ⬜ T102で対応予定 |

### FR-04: 品質管理

| ID | 要件 | 優先度 | ステータス |
|----|------|--------|-----------|
| FR-04-1 | YAMLフロントマターの構文が正しいこと | P1 | ✅ 手動確認 |
| FR-04-2 | ファイルパス参照が有効であること | P1 | ✅ 手動確認 |
| FR-04-3 | CIによる自動バリデーションがあること | P3 | ⬜ T202で対応予定 |
| FR-04-4 | 自動テストが整備されていること | P3 | ⬜ T203で対応予定 |

---

## 5. 非機能要件

### NFR-01: 保守性

| ID | 要件 | 基準 |
|----|------|------|
| NFR-01-1 | ファイル命名規則の一貫性 | kebab-case（例: `sprint-coder`, `pre-push-review`） |
| NFR-01-2 | ディレクトリ構成の規約 | Agent: `agents/{name}.md` + `agents/{name}/sub.md`、Skill: `skills/{name}/SKILL.md` |
| NFR-01-3 | YAMLフロントマターの標準化 | 全定義ファイルに `name`, `description` 必須 |

### NFR-02: 可搬性

| ID | 要件 | 基準 |
|----|------|------|
| NFR-02-1 | 環境依存パスの排除 | ハードコードされた絶対パスを含まない（ユーザーホーム参照は `~` または `$HOME`） |
| NFR-02-2 | 機密情報の排除 | APIキー、トークン、内部URLを含まない |

### NFR-03: 整合性

| ID | 要件 | 基準 |
|----|------|------|
| NFR-03-1 | リポジトリと `~/.cursor/` の一致性 | 同期後に差分がゼロであること |
| NFR-03-2 | Agent/Skill間の参照整合性 | 参照先のファイルが実在すること |

---

## 6. 同期フロー

### 6.1 基本フロー

```
[リポジトリで編集] → [git add/commit/push] → [rsync で ~/.cursor/ に同期]
```

### 6.2 同期対象マッピング

| リポジトリ | ~/.cursor/ | rsyncオプション |
|-----------|-----------|----------------|
| `agents/` | `~/.cursor/agents/` | `-av --delete` |
| `skills/` | `~/.cursor/skills/` | `-av --delete` |
| `commands/` | `~/.cursor/commands/` | `-av --delete` |
| `rules/` | `~/.cursor/rules/` | `-av --delete` |

### 6.3 同期タイミング

| タイミング | トリガー | 方式 |
|-----------|---------|------|
| スプリント完了後 | PO承認 → commit&push → rsync | 手動（sync-to-cursor-home.mdc ルールで確認） |
| 緊急修正時 | 直接編集 → commit&push → rsync | 手動 |
| 将来（T201完了後） | ワンコマンド実行 | sync-to-cursor.sh スクリプト |

### 6.4 注意事項

- `--delete` オプションにより、リポジトリに存在しないファイルは `~/.cursor/` 側から削除される
- 同期前に必ず `rsync -avn --delete`（dry-run）で差分を確認すること
- `persona/` は同期対象外（プロジェクト固有設定のため）

---

## 7. ファイル命名規約

### 7.1 共通規約

| 項目 | 規約 | 例 |
|------|------|-----|
| ファイル名 | kebab-case | `sprint-coder.md`, `pre-push-review.md` |
| ディレクトリ名 | kebab-case | `chat-history-analyzer/`, `slide-generator/` |
| スキル定義ファイル | `SKILL.md`（大文字固定） | `skills/sprint-coder/SKILL.md` |
| ルールファイル | `.mdc` 拡張子 | `regression-prevention.mdc` |

### 7.2 YAMLフロントマター

**Agent定義（必須フィールド）**:
```yaml
---
name: "{agent-name}"
description: "{1行の説明}"
model: "{使用モデル}"
is_background: {true/false}
---
```

**Skill定義（必須フィールド）**:
```yaml
---
name: "{skill-name}"
description: "{1行の説明}"
---
```

**Rule定義（必須フィールド）**:
```yaml
---
description: "{ルールの説明}"
globs: "{適用対象のファイルパターン}"
alwaysApply: {true/false}
---
```

---

## 8. マイルストーンとタスク対応

| マイルストーン | 関連要件 | 期限 | ステータス |
|--------------|---------|------|-----------|
| M1: リポジトリ構造整備 | FR-01（バージョン管理）、FR-02-1〜3（同期基盤） | 2026-02-28 | 🔄 進行中 |
| M2: ドキュメント整備 | FR-03（ドキュメンテーション全般） | 2026-03-31 | ⬜ 未着手 |
| M3: 自動化・CI | FR-02-4（同期自動化）、FR-04-3〜4（CI/テスト） | 2026-04-30 | ⬜ 未着手 |

---

## 9. リスクと対策

| リスク | 影響度 | 発生確率 | 対策 |
|--------|--------|---------|------|
| Cursorアップデートによる構造変更 | 高 | 中 | `skills-cursor/` を管理対象外とし、公式変更の影響を限定 |
| rsync `--delete` による意図しないファイル削除 | 高 | 低 | dry-run必須化（sync-to-cursor-home.mdc ルールで強制） |
| 機密情報の混入 | 高 | 低 | `.gitignore` で除外 + PR時のセキュリティチェック |
| 同期忘れ | 中 | 中 | スプリント完了時のsync-to-cursor-home.mdc ルールで確認 |
| シンボリックリンク対応（Cursor側） | 低 | 不明 | 対応されたらrsyncからsymlinkに移行検討 |

---

## 10. 将来の拡張計画

| 項目 | 概要 | 対応時期 |
|------|------|---------|
| 同期スクリプト自動化 | `sync-to-cursor.sh` でワンコマンド同期 | M3（Phase 3） |
| GitHub Actions CI | YAML構文・ファイルパス参照の自動バリデーション | M3（Phase 3） |
| 自動テスト | Agent/Skill定義の整合性テスト | M3（Phase 3） |
| シンボリックリンク移行 | Cursor対応後にrsyncからsymlinkに移行 | Cursor対応次第 |
| 多マシン対応 | GitHub経由の設定共有フロー整備 | 必要時 |

---

## 付録A: 初期調査記録（2026-02-05）

> 以下はプロジェクト開始前の調査結果。アーキテクチャ決定（Section 2.3）の根拠として保持。

### A.1 `~/.cursor` 直接リポジトリ化の評価

**結論: 不採用**

| ファイル/フォルダ | 性質 | リポジトリ管理 |
|---|---|---|
| `ide_state.json` | 動的に変化 | ❌ 不適切 |
| `argv.json` | マシン固有のID含む | ❌ 不適切 |
| `projects/` | 大容量キャッシュ | ❌ 不適切 |
| `extensions/` | バイナリ | ❌ 不適切 |
| `agents/` | ユーザー定義 | ✅ 適切 |
| `skills/` | ユーザー定義 | ✅ 適切 |

### A.2 シンボリックリンクの評価

**結論: 不採用（Cursor制約）**

- Cursor の Agent Skills 機能はシンボリックリンクを認識しない（2026-02時点）
- Cursor Forum で機能リクエストとして議論中
- 参考: [Cursor Forum: Agent Skills and Symlinks](https://forum.cursor.com/t/agent-skills-must-see-symlinks/150093)

### A.3 リポジトリ構成の比較

| 案 | 構成 | 採用 | 理由 |
|----|------|------|------|
| 案1: 統合リポジトリ | agents + skills を1つのリポジトリ | ✅ 採用 | 一元管理、関連変更の同時コミット |
| 案2: 個別リポジトリ | agents, skills を別リポジトリ | ❌ | 管理コスト増、クロスリファレンス困難 |

---

## 更新履歴

| 日付 | 変更内容 |
|------|---------|
| 2026-02-05 | 初版作成（調査ドキュメントとして） |
| 2026-02-13 | SPRINT-005 T005: 正式要件定義書に改修。管理対象の詳細化、機能/非機能要件の定義、同期フローの明文化、命名規約の整理、初期調査を付録に移動 |
