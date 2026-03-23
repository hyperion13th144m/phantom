# テストガイド - Fox プロジェクト

このドキュメントは、`src/pages/docs/[docId]/index.astro` ページのテスト実装について説明します。

## セットアップ

テストは **Vitest** を使用して実装されています。

### インストール済み

以下のパッケージがすでにインストールされています:
- `vitest` - テストフレームワーク
- `@vitest/ui` - テスト結果の UI
- `chai` - アサーションライブラリ

## テスト実行方法

### すべてのテストを実行
```bash
npm test
```

### テストを監視モードで実行（ファイル変更時に自動実行）
```bash
npm test
# 実行中に 'a' でウォッチモード、'q' で終了
```

### テストUIで結果を確認
```bash
npm test:ui
```

### カバレッジレポートを生成
```bash
npm test:coverage
```

### HTMLフィクスチャ比較テストを実行
`test:compare` は `html/document.html` と `expected-html/document.html` を比較します。
先に最新のレンダリング結果を生成してから比較テストを実行してください。

```bash
# 1) フィクスチャJSONから html/document.html を再生成
npm run render:documents

# 2) expected-html/document.html との差分を検証
npm run test:compare
```

## テスト構成

### 1. ユニットテスト: `__tests__/unit/bibliography.test.ts`

**目的**: 数値フォーマットロジックのテスト

**テスト内容**:
- 国内出願番号フォーマット（例：`2023-001234`）
- PCT国際出願番号フォーマット（例：`PCT/JP2023/123456`）
- 不正な形式の処理
- 日付フォーマット処理

**実行例**:
```typescript
describe('formatApplicationNumber', () => {
  it('should format domestic patent application number correctly', () => {
    const result = formatApplicationNumber('patent', '2023001234');
    expect(result).toBe('特願2023-001234');
  });
  
  it('should format PCT application number correctly', () => {
    const result = formatApplicationNumber('patent', 'JP2023123456');
    expect(result).toBe('PCT/JP2023/123456');
  });
});
```

### 2. ドキュメントロジックテスト: `__tests__/unit/document-page.test.ts`

**目的**: ページレンダリングロジックのテスト

**テスト内容**:
- ドキュメントの並び替え順序（`PatAppDoc` → `ApplicationBody` → ...）
- 欠落したドキュメント型の処理
- 画像カルーセルの表示判定ロジック
- ページタイトルのフォーマット

**実行例**:
```typescript
it('should sort documents in the correct priority order', () => {
  const mockDocuments = [
    { _type: 'PatAmnd', id: 1 },
    { _type: 'PatAppDoc', id: 2 },
  ];
  
  const sortedJson = order
    .map((guard) => mockDocuments.find((doc) => guard(doc)))
    .filter((doc): doc is typeof mockDocuments[0] => doc !== undefined);
  
  expect(sortedJson[0]._type).toBe('PatAppDoc');
});
```

### 3. 統合テスト: `__tests__/integration/integration.test.ts`

**目的**: ページ全体の動作テスト（スケルトン）

**テスト内容**:
- HTML構造の検証
- ドキュメント読み込みの成功
- エラーハンドリング
- 画像が存在しない場合の動作

**注意**: 統合テストは現在、スケルトン実装です。実行するには以下が必要です:
- 開発サーバーの起動 (`npm run dev`)
- テストデータの準備

## テスト結果の解釈

実行結果の例:
```
 ✓ __tests__/unit/bibliography.test.ts (7 tests) 5ms
 ✓ __tests__/unit/document-page.test.ts (5 tests) 6ms
 ✓ __tests__/integration/integration.test.ts (9 tests) 12ms

 Test Files  3 passed (3)
      Tests  21 passed (21)
```

- ✓ = テスト成功
- × = テスト失敗
- Test Files = テストファイル数
- Tests = テストケース数

## テストの拡張方法

### 新しいテストケースを追加

1. 対応するテストファイルを開く
2. `describe` ブロック内に `it()` を追加
3. テストを実行して動作を確認

**例**:
```typescript
describe('New Feature', () => {
  it('should do something specific', () => {
    const result = myFunction('test');
    expect(result).toBe('expected');
  });
});
```

### ファイルシステムのモック化

実際のファイルを読み込む必要があるテストは、vitest の `vi.mock()` を使用:

```typescript
import { vi } from 'vitest';
import fs from 'node:fs/promises';

vi.mock('node:fs/promises', () => ({
  readFile: vi.fn(() => Promise.resolve('{"test": "data"}')),
}));
```

## トラブルシューティング

### テストが見つからない場合
`vitest.config.ts` の `include` パターンを確認:
```typescript
include: ['__tests__/**/*.test.ts'],
```

### パスエイリアスが動作しない
`vitest.config.ts` で `~` エイリアスが設定されています:
```typescript
resolve: {
  alias: {
    '~': resolve(__dirname, './src'),
  },
}
```

### モック化が機能しない
vitest では `vi.mock()` は**モジュールの最上部**で実行する必要があります。

## CI/CD統合

GitHub Actions や他の CI システムでテストを実行:

```yaml
- name: Run tests
  run: npm test -- --run

- name: Generate coverage
  run: npm run test:coverage
```

## 参考リンク

- [Vitest公式ドキュメント](https://vitest.dev/)
- [Chai アサーション](https://www.chaijs.com/)
- [Astro テストガイド](https://docs.astro.build/ja/guides/testing/)
