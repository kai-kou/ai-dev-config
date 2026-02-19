# Claude Code 固有設定

Claude Code（`~/.claude/`）にデプロイされるスキル・エージェント定義のリファレンスリポジトリ。

## 配置構成

```
claude-code/
├── agents/              # エージェント定義（30個）→ ~/.claude/agents/
├── hooks/               # Hooksスクリプト（5個）→ ~/.claude/hooks/
├── skills-catalog.md    # スキルカタログ（42個の一覧）
└── README.md            # 本ファイル
```

## デプロイ先

| リソース | ソース | デプロイ先 |
|---------|--------|-----------|
| エージェント | `claude-code/agents/` | `~/.claude/agents/` |
| Hooks | `claude-code/hooks/` | `~/.claude/hooks/` |
| スキル | `~/.claude/skills/`（直接管理） | — |
| 共有ペルソナ | `persona/` | `~/.claude/agents/`（名前が同じものはagentsとして利用） |

## 同期手順

プロジェクトルートの `scripts/sync-home.sh` で双方向同期を管理する。

```bash
# 差分確認
./scripts/sync-home.sh diff

# Pull: ~/.claude/agents/ → claude-code/agents/（スプリント後の逆同期）
./scripts/sync-home.sh pull

# Push: claude-code/agents/ → ~/.claude/agents/（デプロイ）
./scripts/sync-home.sh push

# ruler apply + Push 一括実行
./scripts/sync-home.sh apply
```

### 運用フロー

```
スプリント中に ~/.claude/agents/ が改善される
  → スプリント終了後: ./scripts/sync-home.sh pull（逆同期）
  → コミット & push
  → 次回デプロイ時: ./scripts/sync-home.sh apply（ruler + push）
```

## Hooksについて

Claude Code Hooks は `~/.claude/settings.json` の `hooks` セクションで設定し、
対応するシェルスクリプトを `~/.claude/hooks/` に配置する。

### 現在のHooks一覧

| Hook | イベント | matcher | スクリプト | 説明 |
|------|---------|---------|-----------|------|
| 通知（入力待ち） | Notification | `""` | `notify.sh` | macOS通知でユーザーに入力待ちを通知 |
| 通知（完了） | Stop | `""` | `notify.sh` | macOS通知で応答完了を通知 |
| Push前チェック | PreToolUse | `Bash` | `pre-push-check.sh` | git pushコマンドを検出し、変更内容・リスクを表示 |
| 機密ファイル保護 | PreToolUse | `Edit\|Write` | `protect-sensitive-files.sh` | .env/credentials等への書き込みをブロック |
| コンパクション再注入 | SessionStart | `compact` | `compact-reinject.sh` | コンテキスト圧縮後にプロジェクト情報を再注入 |
| 自動Lintチェック | PostToolUse | `Edit\|Write` | `post-edit-lint.sh` | ファイル編集後にMarkdown構文チェックを実行 |

### デプロイ手順

```bash
# Hooks スクリプトのデプロイ
cp claude-code/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

settings.json の hooks セクションは `~/.claude/settings.json` に直接設定する。
リポジトリの `.claude/settings.json` はプロジェクト固有設定のみ管理。

## スキルについて

Claude Code スキル（42個）は `~/.claude/skills/` に直接配置・管理している。
スキルは日常的に追加・修正されるため、リポジトリへのフルコピーではなく
`skills-catalog.md` でカタログ管理する方針とする。

スキルの追加・変更時は `skills-catalog.md` のカタログも更新すること。
