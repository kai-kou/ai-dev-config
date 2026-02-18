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

## スキルについて

Claude Code スキル（42個）は `~/.claude/skills/` に直接配置・管理している。
スキルは日常的に追加・修正されるため、リポジトリへのフルコピーではなく
`skills-catalog.md` でカタログ管理する方針とする。

スキルの追加・変更時は `skills-catalog.md` のカタログも更新すること。
