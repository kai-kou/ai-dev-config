---
sprint:
  id: "SPRINT-012"
  project: "ai-dev-config"
  date: "2026-02-19"
  status: "completed"
  execution_mode: "sequential"
  autonomous: false
backlog:
  total_tasks: 4
  total_sp: 8
  completed_tasks: 4
  completed_sp: 8
  sp_completion_rate: 100
  waves: 0
---

# スプリントバックログ

**スプリント**: SPRINT-012（M4: Claude Code Hooks導入設計・実装 + try-stock同期）
**プロジェクト**: ai-dev-config
**日付**: 2026-02-19
**ステータス**: completed

---

## スプリント目標

> M4継続 — Claude Code Hooks（T306）の導入設計・実装を実施。既存hook scriptsのリポジトリ管理化、新規Hooks追加（SessionStart compact再注入 + PostToolUse auto-lint）、ドキュメント作成を行う。併せてtry-stock同期修正（TRY-015完了移動・TRY-017登録）を先行回収。

---

## バックログ

| # | タスクID | タスク名 | SP | 優先度 | 担当 | ステータス | 備考 |
|---|---------|---------|-----|--------|------|-----------|------|
| 1 | HOUSEKEEP-1 | try-stock同期修正（TRY-015→Completed移動、TRY-017登録） | 1 | P1 | sprint-documenter | ✅ | TRY-015→Completed、TRY-017→Pending登録、集計値更新済み |
| 2 | T306-A | Hooks scripts のリポジトリ管理化（claude-code/hooks/ に既存3スクリプト登録 + デプロイ手順整備） | 2 | P1 | sprint-coder | ✅ | 3ファイル登録、README.mdにHooksセクション・デプロイ手順追加 |
| 3 | T306-B | 新規Hooks追加（SessionStart compact再注入 + PostToolUse auto-lint） | 3 | P1 | sprint-coder | ✅ | compact-reinject.sh + post-edit-lint.sh 作成・デプロイ・settings.json更新 |
| 4 | T306-C | Hooks設定ドキュメント作成 & T306完了 | 2 | P2 | sprint-documenter | ✅ | HOOKS.md作成、tasks.md T306✅、milestones.md M4 85%更新 |

### SP集計

| 項目 | 値 |
|------|-----|
| 計画SP合計 | 8 |
| 完了SP合計 | 8 |
| SP消化率 | 100% |
| タスク数 | 4 / 4 |
| 実行モード | 逐次 |

### 粒度チェック（逐次モード）

- [x] SP合計 ≤ 21（推奨: 5〜13）→ 8 ✅
- [x] タスク数 ≤ 10（推奨: 3〜7）→ 4 ✅
- [x] 推定所要時間 ≤ 4時間（推奨: 15分〜2時間）→ 約1〜1.5時間

---

## 入力元

- **milestones.md**: M4（Anthropicベストプラクティス準拠・Claude Code高度化）
- **tasks.md**: Phase 4 タスク T306
- **前回スプリント**: SPRINT-011（M4 移植完了、SP9消化率100%）
- **前回レトロ**: TRY-017未登録、TRY-015 try-stock未同期
- **既存Hooks**: ~/.claude/settings.json + ~/.claude/hooks/（3スクリプト）

---

## タスク実行順序と根拠

### 1. HOUSEKEEP-1（try-stock同期修正）を最初に実行

**理由**: 2スプリント分の同期漏れを解消。ハウスキーピングは本タスク前に完了させる原則。

**完了条件**:
- [ ] TRY-015をPendingからCompletedに移動（実装済み: SPRINT-011 TRY-015タスク）
- [ ] TRY-017をPendingに新規登録
- [ ] YAMLフロントマター集計値を再計算

### 2. T306-A（Hooksリポジトリ管理化）を2番目に実行

**理由**: 既存scriptsをリポジトリ管理下に置くことで、T306-Bの新規追加時に一貫した管理ができる。

**完了条件**:
- [ ] `claude-code/hooks/` ディレクトリ作成
- [ ] 既存3スクリプトをコピー（notify.sh, pre-push-check.sh, protect-sensitive-files.sh）
- [ ] デプロイ手順を docs/ またはREADMEに記載

### 3. T306-B（新規Hooks追加）を3番目に実行

**理由**: リポジトリ管理化完了後に新規Hooksを追加・テスト。

**完了条件**:
- [ ] SessionStart(compact) hook: コンパクション後のコンテキスト再注入スクリプト作成
- [ ] PostToolUse(Edit|Write) hook: 自動Lintチェックスクリプト作成（Markdown構文チェック等）
- [ ] `~/.claude/settings.json` のhooksセクション更新
- [ ] `~/.claude/hooks/` に新規スクリプトをデプロイ

### 4. T306-C（Hooksドキュメント作成 & T306完了）を最後に実行

**理由**: 実装完了後にドキュメント化。T306全体の完了判定。

**完了条件**:
- [ ] Hooks一覧ドキュメント作成（全hookイベント・設定方法・スクリプト説明）
- [ ] tasks.md T306ステータスを✅に更新
- [ ] milestones.md M4進捗率を更新

---

## Slack投稿記録

| タスクID | 担当Skill | 投稿結果 | 投稿手段 | 備考 |
|---------|----------|---------|---------|------|
| HOUSEKEEP-1 | sprint-documenter | | | |
| T306-A | sprint-coder | | | |
| T306-B | sprint-coder | | | |
| T306-C | sprint-documenter | | | |

---

## スコープ変更記録

（なし）

---

## POの承認

- [x] PO承認済み（2026-02-19 14:18）
