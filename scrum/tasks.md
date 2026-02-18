---
tasks:
  total: 38
  completed: 25
  in_progress: 0
  blocked: 0
  overall_progress: 66
---

# タスク管理

**プロジェクト**: Cursor Agents/Skills GitHub管理（cursor-agents-skills）
**最終更新**: 2026-02-18

---

## 優先度・ステータス凡例

### 優先度
- P0: 最優先（即座に着手）
- P1: 高優先度（今週中）
- P2: 中優先度（2週間以内）
- P3: 低優先度（適時）

### ステータス
- ⬜ 未着手
- 🔄 進行中
- ✅ 完了
- ⏸️ 保留
- ❌ キャンセル
- 🚫 ブロック

---

## 進捗サマリー

**全体**: 25/38 タスク完了 (66%)

### フェーズ別進捗
- Phase 1（リポジトリ整備）: 18/18 完了 (100%)
- Phase 2（ドキュメント整備）: 2/4 完了 (50%)
- Phase 3（自動化・CI）: 0/3 完了 (0%)
- Phase 4（Anthropicベストプラクティス準拠・高度化）: 5/13 完了 (38%)

---

## Phase 1: リポジトリ整備

### 期間: 2026-02

| ID | タスク | 優先度 | ステータス | 期限 | 備考 |
|----|--------|--------|-----------|------|------|
| T001 | リポジトリ構造設計・初期セットアップ | P0 | ✅ | 02/05 | 完了 |
| T002 | 既存Agent定義の登録（6件） | P0 | ✅ | 02/09 | 完了 |
| T003 | 既存Skill定義の登録（1件） | P1 | ✅ | 02/09 | 完了 |
| T004 | ~/.cursor/ との棚卸し・差分確認 | P1 | ✅ | 02/12 | SPRINT-001で完了 |
| T005 | 要件定義書の整備 | P2 | ✅ | 02/13 | SPRINT-005 SP3 |
| T006 | commands/ ディレクトリ作成 & 全コマンドファイル登録 | P1 | ✅ | 02/12 | SPRINT-001 |
| T007 | rules/ ディレクトリ作成 & グローバルルール登録 | P1 | ✅ | 02/12 | SPRINT-001 |
| T008 | sync-to-cursor-home.mdc 同期対象拡張 | P1 | ✅ | 02/12 | SPRINT-001 |
| T009 | README.md Commands/Rules セクション追加 | P1 | ✅ | 02/12 | SPRINT-001 |
| T010 | persona/ 最新メンバー定義の追加 | P1 | ✅ | 02/13 | SPRINT-002 |
| T011 | slide-generator.md のサブフォルダ方式改修 | P1 | ✅ | 02/13 | SPRINT-002 |
| T012 | google-slides-creator.md のサブフォルダ対応 | P1 | ✅ | 02/13 | SPRINT-002 |
| T013 | workspace_resolver.py + extract_chat_history.py 作成 | P1 | ✅ | 02/13 | SPRINT-003 SP5 |
| T014 | chat-history-analyzer Agent定義（オーケストレータ + 3サブAgent） | P1 | ✅ | 02/13 | SPRINT-003 SP3 |
| T015 | /analyze-chat コマンド定義 | P1 | ✅ | 02/13 | SPRINT-003 SP2 |
| T016 | パターン分析強化（pattern-analyzer.md改善） | P1 | ✅ | 02/13 | SPRINT-004 SP3 |
| T017 | 提案テンプレート改善（config-proposer.md改善） | P1 | ✅ | 02/13 | SPRINT-004 SP3 |
| T018 | SKILL.md整備（chat-history-analyzer） | P1 | ✅ | 02/13 | SPRINT-004 SP2 |

---

## Phase 2: ドキュメント整備

### 期間: 2026-03

| ID | タスク | 優先度 | ステータス | 期限 | 備考 |
|----|--------|--------|-----------|------|------|
| T101 | 各Agent/Skillの詳細README作成 | P2 | ⬜ | 03/14 | |
| T102 | 使用例・チュートリアル作成 | P2 | ⬜ | 03/21 | |
| T103 | CONTRIBUTING.md作成 | P3 | ✅ | 02/13 | SPRINT-005 SP2 |
| T104 | セットアップ手順書作成 | P2 | ✅ | 02/13 | SPRINT-005 SP2 |

---

## Phase 3: 自動化・CI

### 期間: 2026-04

| ID | タスク | 優先度 | ステータス | 期限 | 備考 |
|----|--------|--------|-----------|------|------|
| T201 | sync-to-cursor.sh 同期スクリプト作成 | P2 | ⬜ | 04/14 | |
| T202 | GitHub Actions バリデーション設定 | P3 | ⬜ | 04/21 | |
| T203 | 自動テスト整備 | P3 | ⬜ | 04/30 | |

---

## Phase 4: Anthropicベストプラクティス準拠・Claude Code高度化

### 期間: 2026-05〜06
### 根拠ドキュメント
- [Anthropic] The Complete Guide to Building Skills for Claude (PDF)
- [Qiita] Claude Code カスタマイズ完全ガイド (Boris Cherny)

| ID | タスク | 優先度 | ステータス | 期限 | 備考 |
|----|--------|--------|-----------|------|------|
| T301 | Skill YAML Frontmatter最適化（公式10フィールド準拠） | P1 | ✅ | 05/09 | SPRINT-006。Frontmatterリファレンス作成・argument-hint追加 |
| T302 | Skill Description最適化（What+When+Triggerパターン統一） | P1 | ✅ | 05/09 | SPRINT-006。What+When+Triggerパターン統一完了 |
| T303 | Progressive Disclosure構造化（references/scripts/assets導入） | P2 | ✅ | 02/18 | SPRINT-007。chat-history-analyzer分割、resume-screening references/整理 |
| T304 | Skillエラーハンドリング・トラブルシューティングセクション追加 | P2 | ⬜ | 05/23 | SP3以上のスキル対象 |
| T305 | Skillテストフレームワーク構築（トリガー/機能/性能テスト） | P2 | ⬜ | 05/23 | テストスイート設計・CI連携 |
| T306 | Claude Code Hooks導入設計・実装 | P2 | ⬜ | 05/30 | ライフサイクルフック活用 |
| T307 | settings.json Git管理・パーミッション最適化 | P1 | ✅ | 05/09 | SPRINT-006。Project/User分離・ワイルドカード正規化完了 |
| T308 | Status Lineカスタマイズ（スプリント情報表示） | P3 | ⬜ | 06/06 | |
| T309 | Skill作成テンプレート整備・品質監査チェックリスト | P2 | ✅ | 02/18 | SPRINT-007。skill-template.md + skill-quality-checklist.md作成 |
| T310 | Cursor Agent移植: pre-push-review → Claude Code Agent化 | P1 | ⬜ | — | SP8。仕様→docs/agent-migration-guide.md §2 |
| T311 | Cursor Agent移植: document-review-all → Claude Code Agent化 | P1 | ⬜ | — | SP13。仕様→docs/agent-migration-guide.md §3。分割実装推奨 |
| T312 | Cursor Agent移植: requirement-definition → Claude Code Agent化 | P1 | ⬜ | — | SP13。仕様→docs/agent-migration-guide.md §4。分割実装推奨 |
| T313 | Cursor Agent移植: project-analyzer → Claude Code Agent化 | P1 | ⬜ | — | SP8。仕様→docs/agent-migration-guide.md §5 |

---

## 今週の重点タスク

| ID | タスク | 優先度 | 期限 |
|----|--------|--------|------|
| T310 | Cursor Agent移植: pre-push-review → Claude Code Agent化 | P1 | — |
| T313 | Cursor Agent移植: project-analyzer → Claude Code Agent化 | P1 | — |

---

## タスク更新ルール

- タスク開始時: ステータスを 🔄 に更新
- タスク完了時: ステータスを ✅ に更新、完了日を記録
- ブロック発生時: ステータスを 🚫 に更新、備考にブロック理由を記載
- 新規追加時: 連番IDを付与、優先度と期限を設定
- YAMLフロントマターの集計値も更新すること
