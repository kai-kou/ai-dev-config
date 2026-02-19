---
milestones:
  total: 4
  completed: 1
  in_progress: 2
  overall_progress: 55
---

# マイルストーン管理

**プロジェクト**: Cursor Agents/Skills GitHub管理（cursor-agents-skills）
**最終更新**: 2026-02-19

---

## 全体スケジュール

```
【Phase 1: リポジトリ整備】              2026/02 〜 2026/02  ✅
【Phase 2: ドキュメント整備】            2026/03 〜 2026/03  🔄
【Phase 3: 自動化・CI】                 2026/04 〜 2026/04  ⬜
【Phase 4: ベストプラクティス準拠・高度化】 2026/05 〜 2026/06  ⬜
```

---

## 進捗サマリー

| マイルストーン | 期限 | ステータス | 進捗率 |
|--------------|------|-----------|--------|
| M1: リポジトリ構造整備・全Agent/Skill登録 | 2026-02-28 | ✅ 完了 | 100% |
| M2: ドキュメント整備・使用例作成 | 2026-03-31 | 🔄 進行中 | 33% |
| M3: 同期スクリプト・CI自動化 | 2026-04-30 | ⬜ 未着手 | 0% |
| M4: Anthropicベストプラクティス準拠・高度化 | 2026-06-30 | 🔄 進行中 | 85% |

**全体進捗**: 55%

---

## M1: リポジトリ構造整備・全Agent/Skill登録

**期限**: 2026-02-28
**ステータス**: ✅ 完了（SPRINT-005で完了確認）

### 完了条件
- [x] リポジトリ構造確立（agents/, skills/）
- [x] 既存Agentの登録（6件）
- [x] 既存Skillの登録（1件）
- [x] 全Agent/Skillの棚卸し完了（T004 SPRINT-001 + T005 要件定義書で全資産カタログ化）
- [x] ~/.cursor/ との差分確認・同期（T004 SPRINT-001で実施。rsync運用確立済み）

### 成果物
- [x] agents/ ディレクトリ（12 Agent定義 + 35 サブエージェント）
- [x] skills/ ディレクトリ（12 Skill定義）
- [x] 棚卸しリスト（docs/requirements-cursor-config-git-management.md Section 3 に全資産カタログ）

---

## M2: ドキュメント整備・使用例作成

**期限**: 2026-03-31
**ステータス**: 🔄 進行中

### 完了条件
- [ ] 各Agent/Skillの詳細READMEを作成
- [ ] 使用例・チュートリアルを作成
- [x] 新規Agent/Skill作成のコントリビューションガイド（T103 SPRINT-005）

### 成果物
- [ ] Agent/Skill別README
- [ ] 使用例ドキュメント
- [x] CONTRIBUTING.md（SPRINT-005 T103）
- [x] セットアップ手順書（docs/setup-guide.md, SPRINT-005 T104）

---

## M3: 同期スクリプト・CI自動化

**期限**: 2026-04-30
**ステータス**: ⬜ 未着手

### 完了条件
- [ ] sync-to-cursor.sh スクリプト作成
- [ ] GitHub Actions バリデーション設定
- [ ] 自動テスト整備

### 成果物
- [ ] 同期スクリプト
- [ ] CI/CD設定ファイル

---

## M4: Anthropicベストプラクティス準拠・Claude Code高度化

**期限**: 2026-06-30
**ステータス**: 🔄 進行中

### 根拠ドキュメント
- Anthropic公式「The Complete Guide to Building Skills for Claude」
- Qiita「Claude Code カスタマイズ完全ガイド」（Boris Cherny氏のアプローチ）

### 完了条件
- [x] 全42スキルのYAML FrontmatterがAnthropic標準に準拠（T301 SPRINT-006）
- [x] 全スキルのDescriptionがWhat+When+Triggerパターンに統一（T302 SPRINT-006）
- [x] 主要スキルにProgressive Disclosure構造（references/scripts/assets）導入（T303 SPRINT-007）
- [ ] スキルテストフレームワーク構築（トリガー/機能/性能テスト）
- [x] Claude Code Hooks導入（ライフサイクルイベント活用）（T306 SPRINT-012）
- [x] settings.jsonのGit管理体制確立（Project/User設定分離）（T307 SPRINT-006）
- [x] Skill作成テンプレート・品質監査チェックリスト整備（T309 SPRINT-007）
- [x] Cursor Agent → Claude Code Agent移植（T310-T313: pre-push-review✅, document-review-all✅, requirement-definition✅, project-analyzer✅ — 4/4完了）

### 成果物
- [x] 全42スキルのFrontmatter/Description改善（T301/T302 SPRINT-006）
- [ ] テストフレームワーク（triggering/functional/performance）
- [x] Hooks設定ファイル群（T306 SPRINT-012: 5スクリプト + HOOKS.md）
- [x] settings.json（Project/User分離）（T307 SPRINT-006）
- [x] Skill作成テンプレート・品質チェックリスト（T309 SPRINT-007）
- [x] Progressive Disclosure構造化（T303 SPRINT-007）
- [ ] Status Lineカスタマイズ設定
- [x] Claude Code Agent定義ファイル（T310✅ 7件 + T311✅ 10件 + T312✅ 9件 + T313✅ 4件 — 全30件移植完了）

---

## ステータス凡例

- ⬜ 未着手
- 🔄 進行中
- ✅ 完了
- ⏸️ 保留
- ⚠️ 遅延
