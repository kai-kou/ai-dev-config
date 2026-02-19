---
sprint:
  id: "SPRINT-010"
  project: "ai-dev-config"
  date: "2026-02-19"
  status: "in_progress"
  execution_mode: "sequential"
  autonomous: false
backlog:
  total_tasks: 3
  total_sp: 8
  completed_tasks: 3
  completed_sp: 8
  sp_completion_rate: 100
  waves: 0
---

# スプリントバックログ

**スプリント**: SPRINT-010（M4: requirement-definition移植 フェーズA + Try回収）
**プロジェクト**: ai-dev-config
**日付**: 2026-02-19
**ステータス**: in_progress

---

## スプリント目標

> M4継続 — requirement-definition の Claude Code Agent 移植フェーズA（オーケストレータ + 8サブエージェント定義）を実施。前回Try（サンドボックス注意書き・tools選択ガイド）を先行回収し移植品質を底上げする。

---

## バックログ

| # | タスクID | タスク名 | SP | 優先度 | 担当 | ステータス | 備考 |
|---|---------|---------|-----|--------|------|-----------|------|
| 1 | TRY-011 | agent-migration-guideにデプロイ手順のサンドボックス注意書き追記 | 1 | P2 | sprint-documenter | ✅ | §1.6追加。サンドボックス制約・Cursorデプロイ手順を明記 |
| 2 | TRY-012 | Agent作成テンプレートのYAML frontmatterにtools選択ガイド追加 | 2 | P2 | sprint-documenter | ✅ | §1.2拡充。判断フロー・最小権限原則・5パターン追加 |
| 3 | T312-A | requirement-definition移植 フェーズA（オケ + 8サブエージェント定義） | 5 | P1 | sprint-coder | ✅ | 9ファイル作成完了。reqdef.md(オケ)+8サブAgent。品質チェック全項目クリア |

### SP集計

| 項目 | 値 |
|------|-----|
| 計画SP合計 | 8 |
| 完了SP合計 | 8 |
| SP消化率 | 100% |
| タスク数 | 3 / 3 |
| 実行モード | 逐次 |

### 粒度チェック（逐次モード）

- [x] SP合計 ≤ 21（推奨: 5〜13）→ 8 ✅
- [x] タスク数 ≤ 10（推奨: 3〜7）→ 3 ✅
- [x] 推定所要時間 ≤ 4時間（推奨: 15分〜2時間）→ 約1〜1.5時間

---

## 入力元

- **milestones.md**: M4（Anthropicベストプラクティス準拠・Claude Code高度化）
- **tasks.md**: Phase 4 タスク T312
- **移植仕様書**: `docs/agent-migration-guide.md`（§4: T312）
- **前回スプリント**: SPRINT-009（M4 P1タスク1件+P2タスク1件完了、SP16消化率100%）
- **try-stock.md**: TRY-011, TRY-012（SPRINT-009レトロ由来の改善）

---

## タスク実行順序と根拠

### 1. TRY-011（サンドボックス注意書き追記）を最初に実行

**理由**: agent-migration-guide.mdのデプロイ手順にClaude Codeサンドボックス制約の注意書きを追加。T312-A移植前にガイドを最新化する

**完了条件**:
- [ ] `docs/agent-migration-guide.md` のデプロイ関連セクションにサンドボックス注意書きを追記
- [ ] `~/.claude/agents/` へのデプロイがサンドボックスモードで可能であることを明記
- [ ] Cursor向け `deploy.sh` が必要なケースの説明を追加

### 2. TRY-012（tools選択ガイド追加）を2番目に実行

**理由**: Agent作成時のtools選択判断基準をテンプレートに追加。T312-Aの各サブエージェントに適切なtools設定を行う準備

**完了条件**:
- [ ] Agent定義テンプレートまたは移植ガイドにtools選択の判断基準を追記
- [ ] 役割別の推奨toolsパターン（読み取り専用/書き込みあり/Bash必要）を明記
- [ ] 既存の移植ガイド§1.2ツールマッピングとの整合性確認

### 3. T312-A（requirement-definition移植 フェーズA）を3番目に実行

**理由**: 改善済みガイド・テンプレートを参照しながら9ファイル（オケ1+サブ8）を移植

**成果物（9ファイル）**:
- `claude-code/agents/reqdef.md`（オーケストレータ）
- `claude-code/agents/reqdef-hearing.md`
- `claude-code/agents/reqdef-context.md`
- `claude-code/agents/reqdef-stakeholder.md`
- `claude-code/agents/reqdef-scope.md`
- `claude-code/agents/reqdef-risk.md`
- `claude-code/agents/reqdef-composer.md`
- `claude-code/agents/reqdef-humanize.md`
- `claude-code/agents/reqdef-integrator.md`

**完了条件**:
- [ ] YAML frontmatter が Claude Code 形式に準拠
- [ ] `tools` がAgent責務に対して最小権限
- [ ] サブエージェントのファイル名が `reqdef-{role}.md` 形式
- [ ] 各サブエージェントのプロンプトが移植済み
- [ ] リポジトリの `claude-code/agents/` に管理コピーを配置

---

## スコープ変更記録

（なし）

---

## POの承認

- [x] PO承認済み（2026-02-19 12:14）
