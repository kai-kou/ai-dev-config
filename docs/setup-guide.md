# セットアップ手順書

**プロジェクト**: ai-dev-config
**最終更新**: 2026-02-18

---

## 前提条件

| 項目 | 要件 |
|------|------|
| OS | macOS / Linux |
| Git | 2.x以上 |
| rsync | インストール済み（macOS標準搭載） |
| Node.js | 22+（Ruler CLI用） |
| Ruler | `npm install -g @intellectronica/ruler` |
| Cursor IDE | インストール済み（Cursor設定の同期に必要） |
| Claude Code | インストール済み（Claude Code設定の同期に必要） |
| GitHub | SSHキー設定済み、リポジトリへのアクセス権あり |

---

## 1. リポジトリのクローン

```bash
# 推奨配置先
git clone git@github.com:kai-kou/ai-dev-config.git ~/dev/01_active/ai-dev-config

# 任意の配置先でもOK
git clone git@github.com:kai-kou/ai-dev-config.git /path/to/your/preferred/location
```

**確認**:
```bash
cd ~/dev/01_active/ai-dev-config
ls
# claude-code/  cursor/  docs/  persona/  scripts/  README.md  ...
```

---

## 2. Ruler によるルール生成

```bash
cd ~/dev/01_active/ai-dev-config

# Claude Code + Cursor 向けにルール生成
ruler apply

# dry-run で確認
ruler apply --dry-run --verbose
```

---

## 3. Claude Code エージェントの同期

`scripts/sync-home.sh` で `claude-code/agents/` と `~/.claude/agents/` を双方向同期する。

### 3.1 差分確認

```bash
./scripts/sync-home.sh diff
```

### 3.2 同期コマンド

```bash
# Push: リポジトリ → ~/.claude（初回セットアップ・デプロイ時）
./scripts/sync-home.sh push

# Pull: ~/.claude → リポジトリ（スプリント後の逆同期）
./scripts/sync-home.sh pull

# ruler apply + Push 一括実行
./scripts/sync-home.sh apply
```

各コマンドは実行前に dry-run プレビューを表示し、確認プロンプトで承認後に実行される。

### 3.3 同期対象一覧

| リポジトリ側 | デプロイ先 | 内容 |
|-------------|-----------|------|
| `claude-code/agents/` | `~/.claude/agents/` | エージェント定義（11個） |

> **注意**: Claude Code スキル（42個）は `~/.claude/skills/` で直接管理。カタログは `claude-code/skills-catalog.md` を参照。

---

## 4. ~/.cursor/ への同期

### 4.1 同期前の差分確認（dry-run）

**必ず dry-run で差分を確認してから実行してください。**

```bash
# agents の差分確認
rsync -avn --delete ~/dev/01_active/ai-dev-config/cursor/agents/ ~/.cursor/agents/

# skills の差分確認
rsync -avn --delete ~/dev/01_active/ai-dev-config/cursor/skills/ ~/.cursor/skills/

# commands の差分確認
rsync -avn --delete ~/dev/01_active/ai-dev-config/cursor/commands/ ~/.cursor/commands/

# rules の差分確認（グローバルルール）
rsync -avn --delete ~/dev/01_active/ai-dev-config/cursor/rules/ ~/.cursor/rules/
```

**出力の読み方**:
- `>f+++++++++` — 新規作成されるファイル
- `>f..t......` — 更新されるファイル
- `*deleting` — 削除されるファイル ⚠️ 要注意

### 4.2 同期の実行

差分を確認して問題なければ、`n` を外して実行します。

```bash
rsync -av --delete ~/dev/01_active/ai-dev-config/cursor/agents/ ~/.cursor/agents/
rsync -av --delete ~/dev/01_active/ai-dev-config/cursor/skills/ ~/.cursor/skills/
rsync -av --delete ~/dev/01_active/ai-dev-config/cursor/commands/ ~/.cursor/commands/
rsync -av --delete ~/dev/01_active/ai-dev-config/cursor/rules/ ~/.cursor/rules/
```

### 4.3 同期対象一覧

| リポジトリ側 | ~/.cursor/ 側 | 内容 |
|-------------|--------------|------|
| `cursor/agents/` | `~/.cursor/agents/` | サブエージェント定義 |
| `cursor/skills/` | `~/.cursor/skills/` | スキル定義 |
| `cursor/commands/` | `~/.cursor/commands/` | スラッシュコマンド定義 |
| `cursor/rules/` | `~/.cursor/rules/` | グローバルルール |

> **注意**: `persona/` は同期対象外です。プロジェクト固有設定のため、リポジトリ内でのみ使用されます。

---

## 5. 同期の検証

### 5.1 Claude Code の検証

```bash
# 差分がないことを確認（出力が「全ファイル一致」なら成功）
./scripts/sync-home.sh diff
```

### 5.2 Cursor のファイル数確認

```bash
# 差分チェック（出力がなければ同期完了）
diff -rq ~/dev/01_active/ai-dev-config/cursor/agents/ ~/.cursor/agents/
diff -rq ~/dev/01_active/ai-dev-config/cursor/skills/ ~/.cursor/skills/
diff -rq ~/dev/01_active/ai-dev-config/cursor/commands/ ~/.cursor/commands/
diff -rq ~/dev/01_active/ai-dev-config/cursor/rules/ ~/.cursor/rules/
```

### 5.3 Cursor IDEでの確認

1. Cursor IDE を再起動（または設定のリロード）
2. チャットで `/` を入力し、同期したコマンドが表示されることを確認
3. チャットで Agent Skill が認識されていることを確認

---

## 6. 日常的な運用フロー

### 6.1 Claude Code エージェントの変更サイクル

```
スプリント中に ~/.claude/agents/ が改善される
  → スプリント終了後: ./scripts/sync-home.sh pull（逆同期）
  → git add / commit / push
  → 次回デプロイ時: ./scripts/sync-home.sh apply（ruler + push）
```

### 6.2 Cursor 設定を変更する場合

```
1. リポジトリ内の cursor/ 配下を編集
2. git add / commit / push
3. rsync で ~/.cursor/ に同期
```

> **重要**: `~/.cursor/` 側を直接編集しないでください。次回の rsync `--delete` 実行時に変更が消えます。

### 6.3 スプリント運用時

スプリント完了時に Cursor から同期確認が提示されます（`sync-to-cursor-home.mdc` ルールによる自動確認）。

### 6.4 他のマシンに設定を適用する場合

```bash
# 新しいマシンで
git clone git@github.com:kai-kou/ai-dev-config.git ~/dev/01_active/ai-dev-config
cd ~/dev/01_active/ai-dev-config

# Ruler でルール生成
ruler apply

# Claude Code エージェントをデプロイ
./scripts/sync-home.sh push

# Cursor 設定を同期
rsync -av --delete cursor/agents/ ~/.cursor/agents/
rsync -av --delete cursor/skills/ ~/.cursor/skills/
rsync -av --delete cursor/commands/ ~/.cursor/commands/
rsync -av --delete cursor/rules/ ~/.cursor/rules/
```

---

## 7. トラブルシューティング

### Q: rsync で "Permission denied" が出る

```bash
# ディレクトリの権限を確認
ls -la ~/.cursor/

# 必要に応じて権限を付与
chmod -R u+rw ~/.cursor/agents/
chmod -R u+rw ~/.cursor/skills/
chmod -R u+rw ~/.cursor/commands/
chmod -R u+rw ~/.cursor/rules/
```

### Q: 同期後も Cursor でコマンドが認識されない

1. Cursor IDE を完全に再起動してください
2. `~/.cursor/commands/` にファイルが存在するか確認:
   ```bash
   ls ~/.cursor/commands/
   ```
3. ファイルの拡張子が `.md` であることを確認

### Q: rsync `--delete` で意図しないファイルが削除されそう

1. 必ず dry-run（`-avn`）で先に確認してください
2. `*deleting` 行が表示された場合、そのファイルがリポジトリに存在しないことを意味します
3. リポジトリに追加し忘れたファイルがある場合は、先にリポジトリに追加してください

### Q: GitHub への SSH 接続がうまくいかない

```bash
# SSH 接続テスト
ssh -T git@github.com

# SSH キーの確認
ls -la ~/.ssh/
ssh-add -l
```

### Q: `~/.cursor/` ディレクトリが存在しない

Cursor IDE をインストール・起動すると自動的に作成されます。まず Cursor IDE を起動してください。

---

## 8. 同期対象外のファイルについて

以下のファイル/ディレクトリは意図的に同期対象外としています。

| ファイル/ディレクトリ | 理由 |
|--------------------|------|
| `persona/` | プロジェクト固有のSlack投稿用人格設定。`~/.cursor/` には不要 |
| `docs/` | プロジェクトドキュメント。`~/.cursor/` には不要 |
| `milestones.md` | プロジェクト管理ファイル |
| `tasks.md` | プロジェクト管理ファイル |
| `.sprint-logs/` | スプリントログ |
| `reports/` | レポートファイル |
| `README.md` | リポジトリ説明 |

---

## 関連ドキュメント

| ドキュメント | パス | 内容 |
|-------------|------|------|
| 要件定義書 | `docs/requirements-cursor-config-git-management.md` | プロジェクトの要件・設計 |
| README | `README.md` | プロジェクト概要・コンテンツ一覧 |
| 同期確認ルール | `.cursor/rules/sync-to-cursor-home.mdc` | スプリント完了時の同期確認ルール |
