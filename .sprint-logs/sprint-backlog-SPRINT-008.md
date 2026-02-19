---
sprint:
  id: "SPRINT-008"
  project: "ai-dev-config"
  date: "2026-02-19"
  status: "completed"
  execution_mode: "sequential"
  autonomous: false
backlog:
  total_tasks: 2
  total_sp: 16
  completed_tasks: 2
  completed_sp: 16
  sp_completion_rate: 100
  waves: 0
---

# スプリントバックログ

**スプリント**: SPRINT-008（M4: Cursor Agent → Claude Code Agent移植 第1弾）
**プロジェクト**: ai-dev-config
**日付**: 2026-02-19
**ステータス**: completed

---

## スプリント目標

> M4継続 — Cursor AgentをClaude Code Agent形式に移植し、移植パターンを確立する。中規模2件（pre-push-review + project-analyzer）で変換ワークフローを検証

---

## バックログ

| # | タスクID | タスク名 | SP | 優先度 | 担当 | ステータス | 備考 |
|---|---------|---------|-----|--------|------|-----------|------|
| 1 | T313 | project-analyzer → Claude Code Agent化 | 8 | P1 | sprint-coder | ✅ | オケ+サブ3件。4ファイル作成・レビュー修正・~/.claude/agents/配置完了 |
| 2 | T310 | pre-push-review → Claude Code Agent化 | 8 | P1 | sprint-coder | ✅ | オケ+サブ6件。7ファイル作成・レビュー修正・~/.claude/agents/配置完了 |

### SP集計

| 項目 | 値 |
|------|-----|
| 計画SP合計 | 16 |
| 完了SP合計 | 16 |
| SP消化率 | 100% |
| タスク数 | 2 / 2 |
| 実行モード | 逐次 |

### 粒度チェック（逐次モード）

- [x] SP合計 ≤ 21（推奨: 5〜13）→ 16 ⚠️ 推奨超だが21以内
- [x] タスク数 ≤ 10（推奨: 3〜7）→ 2 ✅
- [ ] 推定所要時間 ≤ 4時間（推奨: 15分〜2時間）→ 約2〜3時間

---

## 入力元

- **milestones.md**: M4（Anthropicベストプラクティス準拠・Claude Code高度化）
- **tasks.md**: Phase 4 タスク T310, T313（全P1）
- **移植仕様書**: `docs/agent-migration-guide.md`（§2: T310, §5: T313）
- **前回スプリント**: SPRINT-007（M4 P2タスク2件完了、SP8消化率100%）
- **SPRINT-007 レトロ**: PO補佐がT304/T306を次候補提案 → 今回はP1のAgent移植を優先
- **今週の重点タスク**: T310, T313

---

## タスク実行順序と根拠

### 1. T313（project-analyzer移植）を最初に実行

**理由**: サブエージェント3件と少なく、移植パターン（Frontmatter変換・ツール設定・サブエージェント命名・ワークフロー記述）を確立しやすい。この知見をT310に横展開する

**成果物**:
- `claude-code/agents/project-analyzer.md`（オーケストレータ）
- `claude-code/agents/project-analyzer-scan.md`
- `claude-code/agents/project-analyzer-dashboard.md`
- `claude-code/agents/project-analyzer-report.md`

**完了条件**:
- [ ] YAML frontmatter が Claude Code 形式に準拠
- [ ] `tools` がAgent責務に対して最小権限
- [ ] サブエージェントのファイル名が `project-analyzer-{role}.md` 形式
- [ ] オーケストレータからサブエージェントへの Task 委譲が正しく記述
- [ ] 並列実行の制御フロー（Phase）が明確に記述
- [ ] 既存 Skill（`/analyze`, `/dashboard`, `/today`, `/weekly-review`）との関係性が整理済み
- [ ] リポジトリの `claude-code/agents/` に管理コピーを配置

### 2. T310（pre-push-review移植）を2番目に実行

**理由**: T313で確立した移植パターンを適用。サブエージェント6件の並列実行パターン（Phase 1: 5並列チェック → Phase 2: 統合修正）をClaude Code形式で実装

**成果物**:
- `claude-code/agents/pre-push-review.md`（オーケストレータ）
- `claude-code/agents/pre-push-review-security-check.md`
- `claude-code/agents/pre-push-review-code-quality.md`
- `claude-code/agents/pre-push-review-git-hygiene.md`
- `claude-code/agents/pre-push-review-documentation.md`
- `claude-code/agents/pre-push-review-dependency-check.md`
- `claude-code/agents/pre-push-review-integrate-and-fix.md`

**完了条件**:
- [ ] YAML frontmatter が Claude Code 形式に準拠
- [ ] `tools` がAgent責務に対して最小権限
- [ ] サブエージェントのファイル名が `pre-push-review-{role}.md` 形式
- [ ] 5並列チェック → 統合修正のワークフローが明確に記述
- [ ] 既存 Skill（`/pre-push-review`）との関係性が整理済み
- [ ] `claude-code/agents/` に管理コピーを配置
- [ ] 品質チェックリスト（移植ガイド§7）全項目クリア

---

## スコープ変更記録

（なし）

---

## POの承認

- [x] PO承認済み（2026-02-19 00:20）
