# セットアップ手順書

**プロジェクト**: cursor-agents-skills
**最終更新**: 2026-02-13（SPRINT-005 T104）

---

## 前提条件

| 項目 | 要件 |
|------|------|
| OS | macOS / Linux |
| Git | 2.x以上 |
| rsync | インストール済み（macOS標準搭載） |
| Cursor IDE | インストール済み |
| GitHub | SSHキー設定済み、リポジトリへのアクセス権あり |

---

## 1. リポジトリのクローン

```bash
# 推奨配置先
git clone git@github.com:kai-kou/cursor-agents-skills.git ~/dev/01_active/cursor-agents-skills

# 任意の配置先でもOK
git clone git@github.com:kai-kou/cursor-agents-skills.git /path/to/your/preferred/location
```

**確認**:
```bash
cd ~/dev/01_active/cursor-agents-skills
ls
# agents/  commands/  docs/  milestones.md  persona/  README.md  rules/  skills/  tasks.md
```

---

## 2. ~/.cursor/ への同期

### 2.1 同期前の差分確認（dry-run）

**必ず dry-run で差分を確認してから実行してください。**

```bash
# agents の差分確認
rsync -avn --delete ~/dev/01_active/cursor-agents-skills/agents/ ~/.cursor/agents/

# skills の差分確認
rsync -avn --delete ~/dev/01_active/cursor-agents-skills/skills/ ~/.cursor/skills/

# commands の差分確認
rsync -avn --delete ~/dev/01_active/cursor-agents-skills/commands/ ~/.cursor/commands/

# rules の差分確認（グローバルルール）
rsync -avn --delete ~/dev/01_active/cursor-agents-skills/rules/ ~/.cursor/rules/
```

**出力の読み方**:
- `>f+++++++++` — 新規作成されるファイル
- `>f..t......` — 更新されるファイル
- `*deleting` — 削除されるファイル ⚠️ 要注意

### 2.2 同期の実行

差分を確認して問題なければ、`n` を外して実行します。

```bash
# agents 同期
rsync -av --delete ~/dev/01_active/cursor-agents-skills/agents/ ~/.cursor/agents/

# skills 同期
rsync -av --delete ~/dev/01_active/cursor-agents-skills/skills/ ~/.cursor/skills/

# commands 同期
rsync -av --delete ~/dev/01_active/cursor-agents-skills/commands/ ~/.cursor/commands/

# rules 同期（グローバルルール）
rsync -av --delete ~/dev/01_active/cursor-agents-skills/rules/ ~/.cursor/rules/
```

### 2.3 同期対象一覧

| リポジトリ側 | ~/.cursor/ 側 | 内容 |
|-------------|--------------|------|
| `agents/` | `~/.cursor/agents/` | サブエージェント定義 |
| `skills/` | `~/.cursor/skills/` | スキル定義 |
| `commands/` | `~/.cursor/commands/` | スラッシュコマンド定義 |
| `rules/` | `~/.cursor/rules/` | グローバルルール |

> **注意**: `persona/` は `~/.cursor/` への同期対象外です。プロジェクト固有設定のため、リポジトリ内でのみ使用されます。

---

## 3. 同期の検証

### 3.1 ファイル数の確認

```bash
# リポジトリ側のファイル数
echo "=== リポジトリ ==="
echo -n "agents: "; find ~/dev/01_active/cursor-agents-skills/agents -type f | wc -l
echo -n "skills: "; find ~/dev/01_active/cursor-agents-skills/skills -type f | wc -l
echo -n "commands: "; find ~/dev/01_active/cursor-agents-skills/commands -type f | wc -l
echo -n "rules: "; find ~/dev/01_active/cursor-agents-skills/rules -type f | wc -l

# ~/.cursor/ 側のファイル数
echo "=== ~/.cursor ==="
echo -n "agents: "; find ~/.cursor/agents -type f | wc -l
echo -n "skills: "; find ~/.cursor/skills -type f | wc -l
echo -n "commands: "; find ~/.cursor/commands -type f | wc -l
echo -n "rules: "; find ~/.cursor/rules -type f | wc -l
```

両者のファイル数が一致していれば同期成功です。

### 3.2 差分がないことの確認

```bash
# 差分チェック（出力がなければ同期完了）
diff -rq ~/dev/01_active/cursor-agents-skills/agents/ ~/.cursor/agents/
diff -rq ~/dev/01_active/cursor-agents-skills/skills/ ~/.cursor/skills/
diff -rq ~/dev/01_active/cursor-agents-skills/commands/ ~/.cursor/commands/
diff -rq ~/dev/01_active/cursor-agents-skills/rules/ ~/.cursor/rules/
```

### 3.3 Cursor IDEでの確認

1. Cursor IDE を再起動（または設定のリロード）
2. チャットで `/` を入力し、同期したコマンドが表示されることを確認
3. チャットで Agent Skill が認識されていることを確認

---

## 4. 日常的な運用フロー

### 4.1 設定を変更する場合

```
1. リポジトリ内のファイルを編集
2. git add / commit / push
3. rsync で ~/.cursor/ に同期
```

> **重要**: `~/.cursor/` 側を直接編集しないでください。次回の rsync `--delete` 実行時に変更が消えます。

### 4.2 スプリント運用時

スプリント完了時に Cursor から同期確認が提示されます（`sync-to-cursor-home.mdc` ルールによる自動確認）。

```
🔄 ~/.cursor/ への同期が必要です。同期スクリプトを実行しますか？
```

承認すると、dry-run → 確認 → 実行 の流れで同期されます。

### 4.3 他のマシンに設定を適用する場合

```bash
# 新しいマシンで
git clone git@github.com:kai-kou/cursor-agents-skills.git ~/dev/01_active/cursor-agents-skills

# 同期実行（Section 2 と同じ手順）
rsync -av --delete ~/dev/01_active/cursor-agents-skills/agents/ ~/.cursor/agents/
rsync -av --delete ~/dev/01_active/cursor-agents-skills/skills/ ~/.cursor/skills/
rsync -av --delete ~/dev/01_active/cursor-agents-skills/commands/ ~/.cursor/commands/
rsync -av --delete ~/dev/01_active/cursor-agents-skills/rules/ ~/.cursor/rules/
```

---

## 5. トラブルシューティング

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

## 6. 同期対象外のファイルについて

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
