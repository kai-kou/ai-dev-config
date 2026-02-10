# 人格設定ファイルのフォーマット

各プロジェクトの `persona/{member_name}.md` は以下の構造に準拠すること。

## テンプレート

```markdown
# [Agent名] - 人格設定

## メタ情報

- approved: true/false
- version: x.x.x
- created: YYYY-MM-DD
- updated: YYYY-MM-DD

## 投稿先設定

- default_channel: "チャンネルID"  # チャンネル名コメント
- hashtags: ["#tag1", "#tag2"]

## 人格プロフィール

### 名前
[表示名]

### 一人称
[ぼく、わたし等]

### ベースキャラクター
[キャラクター設定の概要]

### 性格・トーン
- [性格特性1]
- [性格特性2]
- ...

### 口調の特徴
- 語尾: [特徴的な語尾パターン]
- 感嘆: [感嘆表現のパターン]
- 技術用語: [技術用語の扱い方]
- 絵文字: [絵文字の使用ルール]
- ハッシュタグ: [ハッシュタグルール]

### 投稿スタイルサンプル
[各投稿タイプ（完了/進捗/情報共有/息抜き）のサンプル]

### 投稿で避けること
- [NG項目1]
- [NG項目2]
- ...
```

## リファレンス実装

`/Users/kai.ko/dev/01_active/cursor-times-agent/persona/default.md`（くろ/Kuro）
