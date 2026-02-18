---
name: infographic-generator
description: ファイルや文章をグラレコ風インフォグラフィック画像として出力する。「インフォグラフィックを作成」「スライドを画像化」「グラレコにして」と言われたら使用。GenerateImageツールを使って画像を生成する。
---

# インフォグラフィック・ジェネレーター

ファイルや文章をグラフィックレコーディング（グラレコ）風のインフォグラフィック画像として生成します。

## ワークフロー

### Step 1: コンテンツ分析

ユーザーから提供されたファイルまたは文章を読み込み、以下を分析：

1. **構成判定**
   - スライド構成（`---`区切りやMarp形式）→ 各スライドを個別画像として出力
   - 単一コンテンツ → 1枚のインフォグラフィックとして出力

2. **情報の解析**
   - 核となるデータと補足的な詳細を分類
   - デザインのトーン（色使い、装飾）を決定

3. **デザイン方針の策定**（複数画像の場合）
   - 統一されたデザインテーマを決定
   - カラーパレット、レイアウトパターンを固定

### Step 2: 画像生成

`GenerateImage`ツールを使用して画像を生成。

#### プロンプトテンプレート

```
Create a graphic recording (graphical facilitation) style infographic in Japanese.

[基本設定]
- Aspect ratio: 16:9 (or specified ratio)
- Style: Hand-drawn, sketch-like, warm and approachable
- Language: Japanese (日本語)
- Quality: High resolution, optimized for digital viewing

[デザイン要件]
- Information density: High, maximize use of space
- Layout: Use arrows, boxes, and flow indicators
- Typography: Varied sizes, maintain readability
- Decorations: Hand-drawn icons, illustrations, speech bubbles
- Tone: Professional yet creative

[コンテンツ]
Title: [タイトル]
Key points:
- [ポイント1]
- [ポイント2]
- [ポイント3]

[除外事項]
- No citation markers like [cite: N]
- No source tags or references

[統一デザイン要素]（複数画像の場合）
- Color palette: [指定色]
- Header/footer design: [統一パターン]
```

#### ファイル名規則

- 単一画像: `infographic_[コンテンツ名].png`
- 複数画像: `infographic_[コンテンツ名]_01.png`, `infographic_[コンテンツ名]_02.png`

### Step 3: 完了報告

```
✅ インフォグラフィック生成完了

📁 生成ファイル:
1. [ファイル名] - [タイトル/説明]
2. [ファイル名] - [タイトル/説明]

📊 統計:
- 総画像数: N枚
- 比率: 16:9
- デザインテーマ: [テーマ名]
```

## オプション

ユーザーが指定可能なオプション：

| オプション | 説明 | 例 |
|-----------|------|-----|
| `--ratio` | 画像比率 | `--ratio 4:3` |
| `--style` | デザインスタイル | `--style minimal` |
| `--theme` | カラーテーマ | `--theme dark` |

## 品質チェックリスト

生成前に確認：
- [ ] 情報が漏れなく含まれているか
- [ ] `[cite: N]`などの参照記号を除去したか
- [ ] 複数画像の場合、デザインが統一されているか

## 使用例

**例1: スライド資料の画像化**
```
ユーザー: プレゼン資料.md をインフォグラフィックにしてください
→ ファイルを読み込み → スライド構成を判定 → 各スライドをGenerateImageで画像化
```

**例2: テキストの画像化**
```
ユーザー: 以下の内容をグラレコにしてください
[テキスト内容]
→ テキストを解析 → 1枚のインフォグラフィックとして画像化
```

**例3: オプション指定**
```
ユーザー: 議事録.md を 4:3 比率でインフォグラフィック化
→ 指定比率でGenerateImage実行
```
