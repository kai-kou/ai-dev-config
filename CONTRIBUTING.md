# コントリビューションガイド

cursor-agents-skills リポジトリへの設定追加・変更の手順を説明します。

---

## ディレクトリ構成

```
cursor-agents-skills/
├── agents/                    # サブエージェント定義
│   ├── {agent-name}.md        # トップレベル（オーケストレータ）
│   └── {agent-name}/          # サブエージェント群（ある場合）
│       └── {sub-agent}.md
├── skills/                    # スキル定義
│   └── {skill-name}/
│       └── SKILL.md           # スキル定義ファイル（固定名）
├── commands/                  # スラッシュコマンド定義
│   └── {command-name}.md
├── rules/                     # グローバルルール
│   └── {rule-name}.mdc
├── persona/                   # Slack投稿用人格設定
│   └── {member-name}.md
└── docs/                      # プロジェクトドキュメント
```

---

## 命名規約

| 項目 | 規約 | 例 |
|------|------|-----|
| ファイル名 | kebab-case | `sprint-coder.md`, `pre-push-review.md` |
| ディレクトリ名 | kebab-case | `chat-history-analyzer/`, `slide-generator/` |
| Skill定義ファイル | `SKILL.md`（大文字固定） | `skills/my-skill/SKILL.md` |
| Rule拡張子 | `.mdc` | `my-rule.mdc` |
| その他 | `.md` | `my-agent.md`, `my-command.md` |

---

## 新規 Agent の追加

### 1. ファイルを作成

**サブエージェントなし（単一定義）**:
```
agents/my-agent.md
```

**サブエージェントあり（オーケストレータ + サブ）**:
```
agents/my-agent.md               # オーケストレータ
agents/my-agent/sub-agent-1.md   # サブエージェント
agents/my-agent/sub-agent-2.md
```

### 2. YAMLフロントマターを記述

```yaml
---
name: my-agent
description: このエージェントの1行説明
model: fast
is_background: false
---
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `name` | ✅ | エージェント名（kebab-case） |
| `description` | ✅ | 1行の説明 |
| `model` | ✅ | 使用モデル（`fast` 等） |
| `is_background` | ✅ | バックグラウンド実行かどうか |

### 3. 本文を記述

以下のセクションを含めてください:

- **目的**: エージェントが何をするか
- **ワークフロー**: 処理の流れ（フローチャート推奨）
- **入力/出力**: 期待する入力と生成する出力
- **連携先**: 他のAgent/Skillとの連携

### 4. README.md を更新

`README.md` の Agents テーブルに新しいエージェントを追加してください。

---

## 新規 Skill の追加

### 1. ディレクトリとファイルを作成

```bash
mkdir -p skills/my-skill
touch skills/my-skill/SKILL.md
```

> **重要**: スキル定義ファイルは必ず `SKILL.md`（大文字）にしてください。Cursor が自動認識するのはこの命名のみです。

### 2. YAMLフロントマターを記述

```yaml
---
name: my-skill
description: このスキルの1行説明。トリガー例も含める。「xxx」と言われたら使用。
---
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `name` | ✅ | スキル名（kebab-case） |
| `description` | ✅ | 1行の説明 + トリガー例 |

### 3. 本文を記述

以下のセクションを含めてください:

- **役割**: スキルの責務
- **作業フロー**: 処理の流れ
- **品質基準**: 出力の品質チェックリスト
- **連携先**: 他のAgent/Skillとの連携

### 4. README.md を更新

`README.md` の Skills テーブルに新しいスキルを追加してください。

### 5. 参照ファイルがある場合

スキルが参照する補助ファイルは `skills/my-skill/references/` に配置します:

```
skills/my-skill/
├── SKILL.md
└── references/
    ├── ERROR_HANDLING.md
    └── POSTING_FORMAT.md
```

---

## 新規 Command の追加

### 1. ファイルを作成

```bash
touch commands/my-command.md
```

### 2. コマンド定義を記述

```markdown
--- Cursor Command: my-command ---
コマンドの説明文

{引数名}: {引数の説明}

---

## コマンドの処理内容

1. ステップ1の説明
2. ステップ2の説明
3. ...

--- End Command ---
```

### 3. README.md を更新

`README.md` の Commands テーブルに新しいコマンドを追加してください。

---

## 新規 Rule の追加

### 1. ファイルを作成

```bash
touch rules/my-rule.mdc
```

### 2. YAMLフロントマターを記述

```yaml
---
description: このルールの説明
globs: "**/*.md"
alwaysApply: false
---
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `description` | ✅ | ルールの説明 |
| `globs` | 条件付き | 適用対象のファイルパターン（`alwaysApply: false` の場合に必要） |
| `alwaysApply` | ✅ | 常時適用するかどうか |

### 3. ルール本文を記述

MDC形式（Markdown + YAML frontmatter）で記述します。

### 4. README.md を更新

`README.md` の Rules テーブルに新しいルールを追加してください。

---

## ~/.cursor/ への同期

ファイルを追加・変更・削除したら、`~/.cursor/` への同期が必要です。

### dry-run で確認

```bash
rsync -avn --delete agents/ ~/.cursor/agents/
rsync -avn --delete skills/ ~/.cursor/skills/
rsync -avn --delete commands/ ~/.cursor/commands/
rsync -avn --delete rules/ ~/.cursor/rules/
```

### 同期を実行

```bash
rsync -av --delete agents/ ~/.cursor/agents/
rsync -av --delete skills/ ~/.cursor/skills/
rsync -av --delete commands/ ~/.cursor/commands/
rsync -av --delete rules/ ~/.cursor/rules/
```

> 詳細は [セットアップ手順書](docs/setup-guide.md) を参照してください。

---

## チェックリスト

新しいファイルを追加する際は、以下を確認してください:

- [ ] ファイル名が kebab-case になっている
- [ ] YAMLフロントマターに必須フィールドが含まれている
- [ ] Markdown の見出し階層が正しい（h1は1つ、以降は順序正しく）
- [ ] ファイルパスの参照先が実在する
- [ ] README.md の対応テーブルを更新した
- [ ] `~/.cursor/` への同期を実行した（または同期予定）

---

## 関連ドキュメント

| ドキュメント | パス | 内容 |
|-------------|------|------|
| README | `README.md` | プロジェクト概要・コンテンツ一覧 |
| セットアップ手順書 | `docs/setup-guide.md` | クローン・同期・検証の手順 |
| 要件定義書 | `docs/requirements-cursor-config-git-management.md` | プロジェクトの要件・設計 |
