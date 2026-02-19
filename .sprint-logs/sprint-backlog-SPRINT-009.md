---
sprint:
  id: "SPRINT-009"
  project: "ai-dev-config"
  date: "2026-02-19"
  status: "completed"
  execution_mode: "sequential"
  autonomous: false
backlog:
  total_tasks: 3
  total_sp: 16
  completed_tasks: 3
  completed_sp: 16
  sp_completion_rate: 100
  waves: 0
---

# スプリントバックログ

**スプリント**: SPRINT-009（M4: Skillエラーハンドリング + document-review-all移植）
**プロジェクト**: ai-dev-config
**日付**: 2026-02-19
**ステータス**: completed

---

## スプリント目標

> M4継続 — document-review-all の Claude Code Agent 移植（フェーズA: Agent定義ファイル群の作成 + フェーズB: 統合・修正計画Agent+並列制御）と Skill エラーハンドリング追加を実施し、移植基盤の品質を底上げする。

---

## バックログ

| # | タスクID | タスク名 | SP | 優先度 | 担当 | ステータス | 備考 |
|---|---------|---------|-----|--------|------|-----------|------|
| 1 | T304 | Skillエラーハンドリング・トラブルシューティングセクション追加 | 3 | P2 | sprint-coder | ✅ | 3件追加（project-analyzer/sprint-coder/po-assistant）+ランタイムデプロイ完了 |
| 2 | T311-A | document-review-all移植 フェーズA（オケ+7レビュー軸Agent定義） | 5 | P1 | sprint-coder | ✅ | 8ファイル作成完了。doc-review.md(オケ)+7軸Agent |
| 3 | T311-B | document-review-all移植 フェーズB（統合・修正計画Agent+並列制御+デプロイ） | 8 | P1 | sprint-coder | ✅ | 統合Agent2件作成+tools最小権限修正+品質チェック全項目クリア+10ファイルデプロイ完了 |

### SP集計

| 項目 | 値 |
|------|-----|
| 計画SP合計 | 16 |
| 完了SP合計 | 16 |
| SP消化率 | 100% |
| タスク数 | 3 / 3 |
| 実行モード | 逐次 |

### 粒度チェック（逐次モード）

- [x] SP合計 ≤ 21（推奨: 5〜13）→ 16 ⚠️ 推奨超だが21以内
- [x] タスク数 ≤ 10（推奨: 3〜7）→ 3 ✅
- [ ] 推定所要時間 ≤ 4時間（推奨: 15分〜2時間）→ 約2〜3時間

---

## 入力元

- **milestones.md**: M4（Anthropicベストプラクティス準拠・Claude Code高度化）
- **tasks.md**: Phase 4 タスク T304, T311
- **移植仕様書**: `docs/agent-migration-guide.md`（§3: T311）
- **前回スプリント**: SPRINT-008（M4 P1タスク2件完了、SP16消化率100%）
- **SPRINT-008 レトロ**: T304先行実施で移植品質向上の可能性。T311/T312は分割スプリント推奨

---

## タスク実行順序と根拠

### 1. T304（Skillエラーハンドリング追加）を最初に実行

**理由**: SPRINT-008のTryで「T311/T312の前にエラーハンドリング追加を実施すると移植品質が向上する」と指摘。エラーハンドリングパターンを先に確立し、T311移植時に組み込む

**完了条件**:
- [ ] SP3以上の主要スキルにエラーハンドリングセクションを追加
- [ ] トラブルシューティングガイドのテンプレートを定義
- [ ] 既存スキルの品質向上に寄与

### 2. T311-A（document-review-all移植 フェーズA）を2番目に実行

**理由**: オーケストレータと7レビュー軸のAgent定義ファイルを作成。SPRINT-008で確立した移植パターンを適用

**成果物（8ファイル）**:
- `claude-code/agents/doc-review.md`（オーケストレータ）
- `claude-code/agents/doc-review-strategy.md`
- `claude-code/agents/doc-review-logic-mece.md`
- `claude-code/agents/doc-review-execution.md`
- `claude-code/agents/doc-review-perspective.md`
- `claude-code/agents/doc-review-readability.md`
- `claude-code/agents/doc-review-humanize.md`
- `claude-code/agents/doc-review-risk.md`

**完了条件**:
- [ ] YAML frontmatter が Claude Code 形式に準拠
- [ ] `tools` がAgent責務に対して最小権限
- [ ] サブエージェントのファイル名が `doc-review-{role}.md` 形式
- [ ] 各レビュー軸の評価観点・プロンプトが移植済み
- [ ] リポジトリの `claude-code/agents/` に管理コピーを配置

### 3. T311-B（document-review-all移植 フェーズB）を3番目に実行

**理由**: 統合Agent2件と並列実行制御を実装。E2Eの品質チェックとデプロイを完了

**成果物（2ファイル + オケ更新）**:
- `claude-code/agents/doc-review-integrate.md`（統合Agent）
- `claude-code/agents/doc-review-revision-plan.md`（修正計画Agent）
- `claude-code/agents/doc-review.md`（並列制御フロー追記）

**完了条件**:
- [ ] 統合Agentが7軸の結果を正しく集約
- [ ] 修正計画Agentが具体的なアクションプランを生成
- [ ] Batch 1（4並列）→ Batch 2（3並列）→ 統合 → 修正計画のフローが動作
- [ ] 品質チェックリスト（移植ガイド§7）全項目クリア
- [ ] `~/.claude/agents/` にデプロイ完了
- [ ] 既存 Skill `/doc-review` との関係性が整理済み

---

## スコープ変更記録

（なし）

---

## POの承認

- [x] PO承認済み（2026-02-19 01:31）
