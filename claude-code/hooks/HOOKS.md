# Claude Code Hooks 設定ガイド

Claude Code Hooks はツール実行のライフサイクルイベントに応じて
シェルスクリプトを自動実行する仕組み。

## 設定場所

- **グローバル**: `~/.claude/settings.json` の `hooks` セクション
- **プロジェクト**: `.claude/settings.json` の `hooks` セクション（プロジェクトルート）

## Hook イベント一覧

| イベント | 発火タイミング | 用途 |
|---------|--------------|------|
| SessionStart | セッション開始時 | コンテキスト注入、初期化処理 |
| PreToolUse | ツール実行前 | 入力検証、実行ブロック（exit 2） |
| PostToolUse | ツール実行後 | 出力検証、自動チェック |
| Notification | 入力待ち時 | ユーザー通知 |
| Stop | 応答完了時 | 完了通知、後処理 |

## 現在の設定

### SessionStart

| matcher | スクリプト | 説明 |
|---------|-----------|------|
| `compact` | `compact-reinject.sh` | コンパクション後にプロジェクトコンテキスト（ブランチ・コミット・スプリント情報）を再注入 |

### PreToolUse

| matcher | スクリプト | 説明 |
|---------|-----------|------|
| `Bash` | `pre-push-check.sh` | git pushコマンドを検出し、変更内容・ブランチ・リスクを確認表示 |
| `Edit\|Write` | `protect-sensitive-files.sh` | .env / credentials 等の機密ファイルへの書き込みをブロック（exit 2） |

### PostToolUse

| matcher | スクリプト | 説明 |
|---------|-----------|------|
| `Edit\|Write` | `post-edit-lint.sh` | 編集後の軽量Lintチェック（Markdown frontmatter / Shell構文 / JSON構文） |

### Notification / Stop

| matcher | スクリプト | 説明 |
|---------|-----------|------|
| `""` (全て) | `notify.sh` | macOS通知センター経由でユーザーに状態を通知 |

## スクリプト詳細

### compact-reinject.sh

コンパクション後に以下の情報をstdoutに出力し、Claudeのコンテキストに再注入する:

- プロジェクト名・ディレクトリ
- 現在のGitブランチ
- 直近5コミット
- スプリントバックログのID・ステータス
- 未コミット変更の有無

### post-edit-lint.sh

ファイル編集後に拡張子に応じた構文チェックを実行:

| 拡張子 | チェック内容 |
|--------|------------|
| `.md` | YAMLフロントマターの閉じ `---` の存在確認 |
| `.sh`, `.bash` | `bash -n` による構文チェック |
| `.json` | `jq empty` による構文検証 |

問題がある場合のみstderrに出力し、Claudeのコンテキストに追加される。

### pre-push-check.sh

`git push` コマンドを検出した場合にstdinからJSON入力を受け取り、
プッシュ対象のブランチ・変更内容・リスクを表示する。

### protect-sensitive-files.sh

`Edit` または `Write` ツールの対象ファイルパスを検査し、
機密ファイルパターン（`.env`, `credentials`, `secret` 等）に一致する場合は
exit code 2 でツール実行をブロックする。

### notify.sh

macOSの `osascript` を使用して通知センターにメッセージを表示する。
引数: `notify.sh <タイトル> <メッセージ> <サウンド名>`

## Hook の仕組み

- **入力**: stdin からJSON形式でツール情報を受け取る
- **出力**: stdout/stderr への出力はClaudeのコンテキストに追加される
- **終了コード**:
  - `0`: 正常（処理続行）
  - `2`: ブロック（ツール実行を中止）— PreToolUse のみ有効
  - その他: 警告として処理続行

## デプロイ手順

```bash
# リポジトリからランタイムへコピー
cp claude-code/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

settings.json の hooks セクションは `~/.claude/settings.json` に直接設定する。
