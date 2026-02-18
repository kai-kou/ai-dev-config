---
project:
  name: "ai-dev-config"
  title: "AI開発ツール統合設定管理"
  status: active
  priority: medium
  created: "2026-02-05"
  updated: "2026-02-18"
  owner: "kai.ko"
  tags: [ai, cursor, claude-code, ruler, agents, skills, commands, rules]
  summary: "Cursor/Claude Codeの設定をRulerで統合管理"
  next_action: "Ruler運用定着・ツール固有設定の整理"
---

# AI Dev Config

AI開発ツール（Cursor / Claude Code）の設定を統合管理するリポジトリです。
[Ruler](https://github.com/intellectronica/ruler) CLIで共通ルールを管理し、各ツール向けの設定ファイルを自動生成します。

## ディレクトリ構造

```
ai-dev-config/
├── .ruler/                 # Ruler管理（Single Source of Truth）
│   ├── AGENTS.md           # 共通ルール（エントリポイント）
│   ├── regression-prevention.md  # デグレ防止ルール
│   ├── skills/             # 共有スキル（各ツールにコピー）
│   └── ruler.toml          # Ruler設定
├── cursor/                 # Cursor固有設定
│   ├── agents/             # サブエージェント定義（11個）
│   ├── commands/           # スラッシュコマンド（19個）
│   ├── skills/             # Cursor固有スキル（3個）
│   └── rules/              # Cursorルール（.mdc形式）
├── claude-code/            # Claude Code固有設定
│   ├── skills/             # Claude Code固有スキル
│   └── commands/           # Claude Codeコマンド
├── shared/                 # ツール横断共有リソース
│   ├── persona/            # ペルソナ定義（9個）
│   └── docs/               # ドキュメント
├── CLAUDE.md               # 生成物（ruler apply で自動生成）
├── AGENTS.md               # 生成物（ruler apply で自動生成）
└── README.md
```

## セットアップ

### 前提条件

- Node.js 22+
- [Ruler](https://github.com/intellectronica/ruler) (`npm install -g @intellectronica/ruler`)

### ルール生成

```bash
# Claude Code + Cursor 向けにルール生成
ruler apply

# 特定ツールのみ
ruler apply --agents claude
ruler apply --agents cursor

# dry-runで確認
ruler apply --dry-run --verbose
```

### ツール固有設定の同期

```bash
# Cursor設定の同期
rsync -av cursor/agents/ ~/.cursor/agents/
rsync -av cursor/commands/ ~/.cursor/commands/
rsync -av cursor/skills/ ~/.cursor/skills/
rsync -av cursor/rules/ ~/.cursor/rules/

# Claude Code設定の同期
rsync -av claude-code/skills/ ~/.claude/skills/
rsync -av claude-code/commands/ ~/.claude/commands/
```

## Ruler の仕組み

1. `.ruler/` 内の `.md` ファイルがルールのソース（Single Source of Truth）
2. `ruler apply` で各ツール向けの設定ファイルを自動生成
   - Claude Code: `CLAUDE.md`
   - Cursor: `AGENTS.md`
3. 生成物は `.gitignore` で除外（ソースのみバージョン管理）
4. `.ruler/skills/` に共有スキルを置くと、各ツールの skills ディレクトリに自動コピー

## 含まれるコンテンツ

### 共通ルール（.ruler/）

| ルール | 説明 |
|--------|------|
| `AGENTS.md` | コミット規律・スプリントワークフロー |
| `regression-prevention.md` | デグレ防止3段階防御モデル |

### Cursor固有（cursor/）

| カテゴリ | 数量 | 説明 |
|---------|------|------|
| Agents | 11個 | document-review, pre-push-review, requirement-definition 等 |
| Commands | 19個 | task-add, sprint-start, dashboard 等 |
| Skills | 3個 | chat-history-analyzer, infographic-generator, resume-screening |
| Rules | 1個 | regression-prevention.mdc（詳細版） |

### Claude Code固有（claude-code/）

Claude Code固有のスキル・コマンドは `~/.claude/skills/` に直接配置済み（41スキル）。
このディレクトリはリファレンス・バックアップ用。

## ライセンス

MIT License
