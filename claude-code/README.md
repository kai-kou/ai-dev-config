# Claude Code 固有設定

Claude Code（`~/.claude/`）にデプロイされるスキル・エージェント定義のリファレンスリポジトリ。

## 配置構成

```
claude-code/
├── agents/              # エージェント定義（11個）→ ~/.claude/agents/
├── skills-catalog.md    # スキルカタログ（42個の一覧）
└── README.md            # 本ファイル
```

## デプロイ先

| リソース | ソース | デプロイ先 |
|---------|--------|-----------|
| エージェント | `claude-code/agents/` | `~/.claude/agents/` |
| スキル | `~/.claude/skills/`（直接管理） | — |
| 共有ペルソナ | `shared/persona/` | `~/.claude/agents/`（名前が同じものはagentsとして利用） |

## 同期手順

```bash
# エージェント定義を同期
rsync -av claude-code/agents/ ~/.claude/agents/

# 逆方向: デプロイ済み→リポジトリへバックアップ
rsync -av ~/.claude/agents/ claude-code/agents/
```

## スキルについて

Claude Code スキル（42個）は `~/.claude/skills/` に直接配置・管理している。
スキルは日常的に追加・修正されるため、リポジトリへのフルコピーではなく
`skills-catalog.md` でカタログ管理する方針とする。

スキルの追加・変更時は `skills-catalog.md` のカタログも更新すること。
