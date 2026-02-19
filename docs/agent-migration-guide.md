---
title: Cursor Agent → Claude Code Agent 移植ガイド
created: 2026-02-18
updated: 2026-02-19
targets: [T310, T311, T312, T313]
total_sp: 42
---

# Cursor Agent → Claude Code Agent 移植ガイド

本ドキュメントは、Cursor Agent を Claude Code Agent 形式に移植するための変換仕様書。
スプリント実行時にこのファイルを参照して作業すること。

---

## 1. 共通変換ルール

### 1.1 YAML Frontmatter 変換テーブル

| Cursor形式 | Claude Code形式 | 変換ルール |
|-----------|----------------|-----------|
| `name` | `name` | そのまま維持 |
| `description` | `description` | そのまま維持（What+When+Triggerパターン推奨） |
| `model: opus-4.6` | `model: opus` | `opus-4.6` → `opus`, `sonnet-4.5` → `sonnet` に正規化 |
| `is_background` | （削除） | Claude Codeでは Task tool 側で `run_in_background` 指定 |
| （なし） | `maxTurns` | 新規追加。オーケストレータ: 30, サブエージェント: 15-20 |
| （なし） | `tools` | 新規追加。下記ツールマッピング参照 |
| （なし） | `memory` | オーケストレータのみ必要に応じて `memory: user` |

### 1.2 ツールマッピングと選択ガイド

#### 役割別の推奨 tools パターン

| Agent役割 | tools 設定 | 選択根拠 |
|----------|-----------|---------|
| オーケストレータ（読み書き両方） | `[Read, Glob, Grep, Bash, Edit, Write]` | Task tool でサブエージェント起動 + 最終出力の書き込み |
| 分析・レビュー系（読み取り専用） | `[Read, Glob, Grep]` | コードを読んで分析するだけ。変更権限不要 |
| 修正・統合系（書き込みあり） | `[Read, Glob, Grep, Bash, Edit, Write]` | 分析結果に基づきファイルを修正・生成 |
| ヒアリング・対話系 | `[Read, Glob, Grep]` | ユーザーとの対話が中心。ファイル参照のみ |
| コマンド実行が必要な系 | `[Read, Glob, Grep, Bash]` | git/npm等のコマンド実行が必要だが書き込み不要 |

#### tools 選択の判断フロー

```
Q1: Agentはファイルを新規作成 or 編集する必要がある？
  → Yes: Edit, Write を追加
  → No: 次へ

Q2: Agentはシェルコマンド（git, npm等）を実行する必要がある？
  → Yes: Bash を追加
  → No: 次へ

Q3: Agentはコードやドキュメントを読んで分析するだけ？
  → Yes: [Read, Glob, Grep] のみ（最小権限）
```

#### 最小権限の原則

- **デフォルトは `[Read, Glob, Grep]`**（読み取り専用）から始める
- 必要なツールだけを追加する。「念のため全ツール付与」は避ける
- Bash は外部コマンド実行が明確に必要な場合のみ追加
- Edit/Write はファイル変更が責務に含まれる場合のみ追加

### 1.3 サブエージェント参照の変換

**Cursor形式**（Agent内パス参照）:
```
→ /pre-push-review/security-check を Task tool で起動
```

**Claude Code形式**（Task tool subagent_type）:
```
→ Task tool: subagent_type="pre-push-review-security" で起動
```

注意:
- Claude Code の subagent_type はファイル名（拡張子なし）と一致する
- サブエージェントは `~/.claude/agents/` 直下にフラットに配置（サブディレクトリ不可）
- 命名規則: `{親agent}-{sub-agent}.md`（例: `pre-push-review-security-check.md`）

### 1.4 並列実行の変換

**Cursor形式**:
```
Task tool で最大4つ同時起動
```

**Claude Code形式**:
```
Task tool で複数の subagent_type を同時に起動（同一メッセージ内で複数 Task 呼び出し）
```

概念は同じ。記法がClaude Code Task tool のパラメータ形式に変わるだけ。

### 1.5 配置先

| 種類 | パス |
|------|------|
| Agent定義ファイル | `~/.claude/agents/{agent-name}.md` |
| リポジトリ管理コピー | `claude-code/agents/{agent-name}.md`（このリポジトリ） |

### 1.6 デプロイ手順とサンドボックス制約

#### Claude Code Agent のデプロイ

Claude Code のサンドボックスモードでは `~/.claude/agents/` への書き込みが許可されているため、
sprint-coder が直接 `~/.claude/agents/` にファイルを配置できる。

```
手順:
1. リポジトリ側 `claude-code/agents/` にAgent定義を作成（管理コピー）
2. `~/.claude/agents/` に同一ファイルをデプロイ（ランタイム配置）
3. Claude Code が subagent_type として認識することを確認
```

#### Cursor向けデプロイが必要なケース

`src/` 配下のファイル（Cursor Agent/Skill/Rules）を変更した場合、Cursor環境へのデプロイには `deploy.sh` の実行が必要。
Claude Code のサンドボックスでは Cursor のホームディレクトリ（`~/.cursor/`）への書き込みが制限されるため、
PO が手動で `deploy.sh` を実行する必要がある。

```
制約事項:
- Claude Code → ~/.claude/agents/ : サンドボックス内で直接書き込み可能
- Claude Code → ~/.cursor/ : サンドボックス制限により直接書き込み不可
- src/ 変更を含むスプリントでは、コミット&push後にPOが deploy.sh を実行
```

### 1.7 移植完了条件チェックリスト

移植タスクの完了報告前に、以下の全項目を確認すること。

| # | チェック項目 | 確認方法 |
|---|------------|---------|
| 1 | YAML Frontmatter が Claude Code 形式に準拠 | §1.1 変換テーブルとの照合 |
| 2 | `tools` が Agent 責務に対して最小権限 | §1.2 判断フローで検証 |
| 3 | サブエージェントのファイル名が `{親agent}-{role}.md` 形式 | §1.3 命名規則との照合 |
| 4 | リポジトリ管理コピーを `claude-code/agents/` に配置 | `ls claude-code/agents/{agent-name}*.md` |
| 5 | **ランタイムデプロイ完了**: `~/.claude/agents/` に配置 | `ls ~/.claude/agents/{agent-name}*.md` |
| 6 | Claude Code が subagent_type として認識可能 | Task tool で起動テスト |
| 7 | 関連ドキュメント（tasks.md / milestones.md）の進捗反映 | フロントマター集計値の再計算 |

**特に重要**: #5（ランタイムデプロイ）は見落としやすい。リポジトリへの配置（#4）だけでは Claude Code から利用できない。

---

## 2. T310: pre-push-review 移植仕様

### 基本情報
- **SP**: 8
- **ソース**: `cursor/agents/pre-push-review.md`
- **サブエージェント**: `cursor/agents/pre-push-review/` 配下 6ファイル

### Cursor側 Frontmatter
```yaml
name: pre-push-review
description: GitHubリモートリポジトリにPushする前にワークディレクトリを精査し、問題を自動修正するオーケストレーター。
model: opus-4.6
is_background: false
```

### Claude Code 変換後 Frontmatter
```yaml
name: pre-push-review
description: GitHubリモートリポジトリにPushする前にワークディレクトリを精査し、問題を自動修正するオーケストレーター。「Push前にレビュー」「コードをチェック」と言われたら使用。
model: opus
maxTurns: 30
tools: [Read, Glob, Grep, Bash, Edit, Write]
```

### サブエージェント一覧と変換

| Cursorサブエージェント | Claude Code Agent名 | tools | maxTurns |
|---------------------|---------------------|-------|----------|
| `security-check.md` | `pre-push-review-security-check.md` | `[Read, Glob, Grep]` | 15 |
| `code-quality.md` | `pre-push-review-code-quality.md` | `[Read, Glob, Grep]` | 15 |
| `git-hygiene.md` | `pre-push-review-git-hygiene.md` | `[Read, Glob, Grep, Bash]` | 15 |
| `documentation.md` | `pre-push-review-documentation.md` | `[Read, Glob, Grep]` | 15 |
| `dependency-check.md` | `pre-push-review-dependency-check.md` | `[Read, Glob, Grep, Bash]` | 15 |
| `integrate-and-fix.md` | `pre-push-review-integrate-and-fix.md` | `[Read, Glob, Grep, Bash, Edit, Write]` | 20 |

### ワークフロー
```
Phase 1: 5チェックを並列起動（Task tool × 5）
  → security-check, code-quality, git-hygiene, documentation, dependency-check
Phase 2: 結果統合 + 自動修正（integrate-and-fix）
Phase 3: ユーザーへ報告
```

### 変換時の注意点
- git diff, git status 等のコマンドは Bash tool 経由で実行
- 既存の Claude Code Skill `/pre-push-review` との整合性を確認
  - Skill はメイン会話で実行、Agent は Team/Task で起動される別物
  - 両方共存可能だが、ロジックの重複に注意

---

## 3. T311: document-review-all 移植仕様

### 基本情報
- **SP**: 13（分割実装推奨）
- **ソース**: `cursor/agents/document-review-all.md`
- **サブエージェント**: `cursor/agents/document-review/` 配下 9ファイル

### Cursor側 Frontmatter
```yaml
name: document-review-all
description: ドキュメントを7つの専門軸で並列レビューし、統合して修正計画書を作成するオーケストレーター。
model: opus-4.6
is_background: false
```

### Claude Code 変換後 Frontmatter
```yaml
name: document-review-all
description: ドキュメントを7つの専門軸で並列レビューし、統合修正計画書を作成するオーケストレーター。「ドキュメントレビュー」「文書レビュー」と言われたら使用。
model: opus
maxTurns: 30
tools: [Read, Glob, Grep, Bash, Edit, Write]
```

### サブエージェント一覧と変換

| Cursorサブエージェント | Claude Code Agent名 | tools | maxTurns | 並列Batch |
|---------------------|---------------------|-------|----------|----------|
| `review-strategy.md` | `doc-review-strategy.md` | `[Read, Glob, Grep]` | 15 | Batch 1 |
| `review-logic-mece.md` | `doc-review-logic-mece.md` | `[Read, Glob, Grep]` | 15 | Batch 1 |
| `review-execution.md` | `doc-review-execution.md` | `[Read, Glob, Grep]` | 15 | Batch 1 |
| `review-perspective.md` | `doc-review-perspective.md` | `[Read, Glob, Grep]` | 15 | Batch 1 |
| `review-readability.md` | `doc-review-readability.md` | `[Read, Glob, Grep]` | 15 | Batch 2 |
| `review-humanize.md` | `doc-review-humanize.md` | `[Read, Glob, Grep]` | 15 | Batch 2 |
| `review-risk.md` | `doc-review-risk.md` | `[Read, Glob, Grep]` | 15 | Batch 2 |
| `review-integrate.md` | `doc-review-integrate.md` | `[Read, Glob, Grep, Edit, Write]` | 20 | 統合 |
| `revision-plan.md` | `doc-review-revision-plan.md` | `[Read, Glob, Grep, Edit, Write]` | 20 | 最終 |

### ワークフロー
```
Phase 1: Batch 1 — 4軸並列レビュー（Task tool × 4）
  → strategy, logic-mece, execution, perspective
Phase 2: Batch 2 — 3軸並列レビュー（Task tool × 3）
  → readability, humanize, risk
Phase 3: 統合（review-integrate）
Phase 4: 修正計画書作成（revision-plan）
Phase 5: ユーザーへ報告
```

### 変換時の注意点
- Cursor版はモデル選定ルール（各軸に最適モデル指定）がある → Claude Code Agent の `model` フィールドで個別指定可能
- 既存 Skill `/doc-review` との関係性を整理
- サブエージェント命名: `doc-review-*` とプレフィックス短縮（`document-review-all-*` は長すぎる）

### 分割実装案（SP13 → 2フェーズ）
- **フェーズA（SP5）**: オーケストレータ + 7レビュー軸のAgent定義ファイル作成
- **フェーズB（SP8）**: 統合・修正計画Agent + 並列実行制御 + E2Eテスト

---

## 4. T312: requirement-definition 移植仕様

### 基本情報
- **SP**: 13（分割実装推奨）
- **ソース**: `cursor/agents/requirement-definition.md`
- **サブエージェント**: `cursor/agents/requirement-definition/` 配下 8ファイル

### Cursor側 Frontmatter
```yaml
name: requirement-definition
description: あらゆるプロジェクトの要件定義書をMarkdown形式で作成するオーケストレーター。ヒアリング→分析→文書化→レビューの全工程を自動化。
model: opus-4.6
is_background: false
```

### Claude Code 変換後 Frontmatter
```yaml
name: requirement-definition
description: あらゆるプロジェクトの要件定義書をMarkdown形式で作成するオーケストレーター。「要件定義」「要件定義書作成」と言われたら使用。
model: opus
maxTurns: 30
tools: [Read, Glob, Grep, Bash, Edit, Write]
memory: user
```

### サブエージェント一覧と変換

| Cursorサブエージェント | Claude Code Agent名 | tools | maxTurns | Step |
|---------------------|---------------------|-------|----------|------|
| `hearing-facilitator.md` | `reqdef-hearing.md` | `[Read, Glob, Grep]` | 20 | Step 1 |
| `context-analyzer.md` | `reqdef-context.md` | `[Read, Glob, Grep]` | 15 | Step 2 |
| `stakeholder-mapper.md` | `reqdef-stakeholder.md` | `[Read, Glob, Grep]` | 15 | Step 2 |
| `scope-definer.md` | `reqdef-scope.md` | `[Read, Glob, Grep]` | 15 | Step 2 |
| `risk-constraint-analyzer.md` | `reqdef-risk.md` | `[Read, Glob, Grep]` | 15 | Step 2 |
| `document-composer.md` | `reqdef-composer.md` | `[Read, Glob, Grep, Edit, Write]` | 20 | Step 3 |
| `humanize-editor.md` | `reqdef-humanize.md` | `[Read, Glob, Grep, Edit, Write]` | 15 | Step 4 |
| `final-integrator.md` | `reqdef-integrator.md` | `[Read, Glob, Grep, Edit, Write]` | 20 | Step 6 |

### ワークフロー
```
Step 0: 入力確認（オーケストレータ直接処理）
Step 1: ヒアリング（reqdef-hearing）→ [ユーザーゲート]
Step 2: 4並列分析（Task tool × 4）
  → context, stakeholder, scope, risk
Step 3: ドラフト作成（reqdef-composer）→ [ユーザーゲート]
Step 4: ヒューマナイズ（reqdef-humanize）
Step 5: レビュー（オーケストレータ直接処理）→ [ユーザーゲート]
Step 6: 最終統合（reqdef-integrator）
```

### 変換時の注意点
- ユーザーゲート（3箇所）: Claude Code では AskUserQuestion tool で実装
- セッション再開ロジック: Claude Code の `memory: user` で状態保持。中間成果物をファイルに保存する設計が必要
- フレームワーク自動選定ロジック: オーケストレータ本文内に条件分岐として記述
- 既存 Skill `/requirement-definition` との関係性整理

### 分割実装案（SP13 → 2フェーズ）
- **フェーズA（SP5）**: オーケストレータ + 8サブエージェント定義ファイル作成
- **フェーズB（SP8）**: ユーザーゲート制御 + セッション再開ロジック + E2Eテスト

### リスク事項
- セッション再開ロジックの実装可否を事前調査すること（sprint-researcher推奨）
- Claude Code の `memory: user` の仕様制約を確認

---

## 5. T313: project-analyzer 移植仕様

### 基本情報
- **SP**: 8
- **ソース**: `cursor/agents/project-analyzer.md`
- **サブエージェント**: `cursor/agents/project-analyzer/` 配下 3ファイル

### Cursor側 Frontmatter
```yaml
name: project-analyzer
description: プロジェクトの進捗分析、ダッシュボード生成、レポート作成を実行するオーケストレーター。
model: sonnet-4.5
is_background: false
```

### Claude Code 変換後 Frontmatter
```yaml
name: project-analyzer
description: プロジェクトの進捗分析・ダッシュボード生成・レポート作成を実行するオーケストレーター。「進捗分析」「プロジェクト分析」「ダッシュボード更新」と言われたら使用。
model: sonnet
maxTurns: 25
tools: [Read, Glob, Grep, Bash, Edit, Write]
```

### サブエージェント一覧と変換

| Cursorサブエージェント | Claude Code Agent名 | tools | maxTurns |
|---------------------|---------------------|-------|----------|
| `scan-project.md` | `project-analyzer-scan.md` | `[Read, Glob, Grep]` | 15 |
| `generate-dashboard.md` | `project-analyzer-dashboard.md` | `[Read, Glob, Grep, Edit, Write]` | 15 |
| `generate-report.md` | `project-analyzer-report.md` | `[Read, Glob, Grep, Edit, Write]` | 15 |

### ワークフロー
```
Phase 1: モード判定（オーケストレータ直接処理）
  → 4モード: 今日のタスク / 棚卸し / 週次レビュー / 月次分析
Phase 2: 並列スキャン（Task tool × N、最大4並列）
  → scan-project を各プロジェクトに対して起動
Phase 3: 集約 → dashboard or report 生成
  → generate-dashboard / generate-report
Phase 4: ユーザーへ報告
```

### 変換時の注意点
- `model: sonnet-4.5` → `model: sonnet`（他3つは opus）
- 並列スキャンのプロジェクト数は動的（`~/dev/01_active/` 配下の数に依存）
- 既存 Skill `/analyze`, `/dashboard`, `/today`, `/weekly-review` との関係性整理
  - これらSkillの機能を包含するオーケストレータとして設計

---

## 6. スプリント配置推奨案

### 案A: 2スプリント（安定型 + 集中型）

| Sprint | タスク | SP | 特徴 |
|--------|--------|-----|------|
| Sprint N | T310(SP8) + T313(SP8) | 16 | 中規模2件。並列パターン習得 |
| Sprint N+1 | T311(SP13) | 13 | 大規模1件集中。7軸レビュー |
| Sprint N+2 | T312(SP13) | 13 | 大規模1件集中。セッション再開 |

### 案B: 3スプリント（均等分散型）

| Sprint | タスク | SP | 特徴 |
|--------|--------|-----|------|
| Sprint N | T310(SP8) + T313(SP8) | 16 | 中規模2件 |
| Sprint N+1 | T311-A(SP5) + T312-A(SP5) | 10 | 大規模2件のフェーズA |
| Sprint N+2 | T311-B(SP8) + T312-B(SP8) | 16 | 大規模2件のフェーズB |

### 推奨: 案A
- 理由: T310+T313 で変換パターンを確立した後、T311/T312 に集中できる
- T310+T313 完了後の知見を T311/T312 に活かせる（学習効果）

---

## 7. 品質チェックリスト（各タスク完了時に使用）

- [ ] YAML frontmatter が Claude Code 形式に準拠している
- [ ] `tools` が Agent の責務に対して最小限の権限になっている
- [ ] サブエージェントのファイル名が `{prefix}-{role}.md` 形式で統一されている
- [ ] オーケストレータからサブエージェントへの Task 委譲が正しく記述されている
- [ ] 並列実行の制御フロー（Phase/Batch）が明確に記述されている
- [ ] 既存 Skill（`/command` 形式）との重複・整合性が確認済み
- [ ] `~/.claude/agents/` に配置して Claude Code で `subagent_type` として認識されることを確認
- [ ] リポジトリの `claude-code/agents/` にも管理コピーを配置

---

## 8. 参照ファイル一覧

### ソース（Cursor Agent）
| ファイル | パス |
|---------|------|
| pre-push-review | `cursor/agents/pre-push-review.md` + `cursor/agents/pre-push-review/` |
| document-review-all | `cursor/agents/document-review-all.md` + `cursor/agents/document-review/` |
| requirement-definition | `cursor/agents/requirement-definition.md` + `cursor/agents/requirement-definition/` |
| project-analyzer | `cursor/agents/project-analyzer.md` + `cursor/agents/project-analyzer/` |

### ターゲット形式の参考（既存 Claude Code Agent）
| ファイル | 参考ポイント |
|---------|------------|
| `~/.claude/agents/sprint-master.md` | オーケストレータの構造、memory: user |
| `~/.claude/agents/sprint-coder.md` | サブエージェントの構造、tools 制限 |
| `~/.claude/agents/sprint-reviewer.md` | 読み取り専用Agent（tools: [Read, Glob, Grep]） |
| `~/.claude/agents/times-agent.md` | 軽量Agent（model: haiku, maxTurns: 10） |

### プロジェクト管理
| ファイル | パス |
|---------|------|
| タスク管理 | `scrum/tasks.md`（T310-T313） |
| マイルストーン | `scrum/milestones.md`（M4） |
| 本ドキュメント | `docs/agent-migration-guide.md` |
