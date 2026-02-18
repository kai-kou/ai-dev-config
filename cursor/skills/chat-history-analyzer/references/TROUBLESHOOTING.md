# トラブルシューティング

## ワークスペースが見つからない

**症状**: `No workspace found for project path` エラー

**原因と対策**:
1. **Cursorで一度も開いたことがないプロジェクト**: Cursorでプロジェクトを一度開いてから再実行する
2. **プロジェクトパスが間違っている**: `pwd` でカレントディレクトリを確認する
3. **workspaceStorageが別の場所にある**: `ls ~/Library/Application\ Support/Cursor/User/workspaceStorage/` でディレクトリの存在を確認する

## SQLite DBが読み取れない（WALロック）

**症状**: `database is locked` エラー

**原因**: CursorがDBに書き込み中でWALロックが発生している

**対策**:
1. Cursorを一度終了してから再実行する（最も確実）
2. DBファイルをコピーしてから読み取る: `cp state.vscdb /tmp/state-copy.vscdb`
3. 数秒待ってからリトライする（一時的なロックの場合）

## 会話データが0件

**症状**: `No conversations found` メッセージ

**原因と対策**:
1. **新規プロジェクト**: チャット履歴が蓄積されてから再実行する（最低10会話推奨）
2. **Cursorバージョンアップ後**: DB構造が変更された可能性。スクリプトの更新が必要
3. **別のワークスペース**: 同じプロジェクトを複数のワークスペースで開いている場合、データが分散している可能性がある

## 分析データが大きすぎる

**症状**: 処理時間が長い、メモリ不足

**対策**: 抽出スクリプトにフィルタオプションを追加して実行する:

```bash
python3 extract_chat_history.py "{project_root}" \
  --output /tmp/chat-history-analysis.json \
  --max-conversations 50 \
  --max-messages 500 \
  --verbose
```

## Pythonバージョンエラー

**症状**: SyntaxError, ModuleNotFoundError

**対策**:
- Python 3.9以上が必要。`python3 --version` で確認する
- macOSの場合、標準の `python3` で動作確認済み
- pyenvを使用している場合: `pyenv shell 3.9` 以上を設定する
