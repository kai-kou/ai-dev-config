# AI Dev Config - 共通ルール

AI開発ツール（Cursor / Claude Code）の共通ルール定義。
Ruler CLIで各ツール向け設定ファイルに自動展開される。

## コミット規律

- コミットメッセージは変更の「なぜ」を記述すること
- 1つのコミットには1つの目的の変更のみ含めること
- WIP状態でのプッシュは避けること
- セキュリティに関わるファイル（.env、credentials等）をコミットしないこと

## スプリントワークフロー

- スプリント管理の中核: `~/dev/01_active/ai-scrum-framework/`
- スプリント開始/終了は `/sprint-start`, `/sprint-end` コマンドで操作
- 日次確認は `/today` コマンドで実施
- 週次振り返りは `/weekly-review` コマンドで実施
