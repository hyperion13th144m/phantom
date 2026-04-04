# skull 実装計画書
## 1. 目的

skull は、Elasticsearch 上の特許文書に対して、付加的な管理データを検索・編集・保存・再同期・リストアするための Web アプリケーションである。

主な役割は次のとおり。

- Elasticsearch を検索し、対象文書を見つける
- 文書ごとの付加データを閲覧・編集する
- 付加データを SQLite に保存する
- 付加データを Elasticsearch に反映する
- Elasticsearch 反映失敗時の状態を管理する
- Elasticsearch 再作成時に SQLite 正本から metadata を復元する

## 2. 背景と位置づけ
既存プロジェクトとの関係は次のとおり。

- panther
  - XML から JSON を生成し、Elasticsearch に登録する
- joker
  - Elasticsearch を検索するフロントエンド
- skull
  - Elasticsearch 文書に対する付加データ管理 UI

skull は joker と責務を分離し、検索閲覧系と管理編集系を分けるための独立プロジェクトとする。

## 3. スコープ
### 3.1 対象機能

今回実装対象とする機能は次のとおり。

- 検索一覧画面
- 文書詳細画面
- metadata 単票編集
- metadata 一括更新
- SQLite 保存
- Elasticsearch 同期
- sync_status 管理
- 未同期一覧画面
- 再同期 API / UI
- restore API / UI
- restore 実行履歴
- restore job 詳細表示

### 3.2 今回は対象外

今回は以下は対象外とする。

- 認証・認可
- 複数ユーザー管理
- 監査ログの厳密運用
- バックグラウンドジョブ基盤
- 自動再試行バッチ
- restore job の failed のみ再実行
- 検索条件保存
- ページを跨いだ選択保持

## 4. 技術スタック
### 4.1 言語
- TypeScript
### 4.2 フレームワーク
- Next.js App Router
### 4.3 UI
- React
- Tailwind CSS
### 4.4 データベース
- SQLite
- better-sqlite3
- drizzle-orm
### 4.5 検索・更新先
- Elasticsearch
- @elastic/elasticsearch
### 4.6 バリデーション
- Zod

## 5. 基本設計方針
### 5.1 データの正本
- SQLite を正本とする
- Elasticsearch は検索用・表示用・同期先とする

### 5.2 更新フロー

metadata 保存時は次の順で処理する。

1. SQLite に保存
1. 履歴保存
1. sync_status を pending にする
1. Elasticsearch に反映
1. 成功時は success
1. 失敗時は failed

### 5.3 リストア方針

Elasticsearch 再作成時は、sync_status に関係なく SQLite から metadata を再投入する。

ただし前提として、先に panther で本文ドキュメントを Elasticsearch に再登録しておく必要がある。

## 6. 管理対象 metadata

1文書あたり、最低限次の metadata を扱う。

- assignees: string[]
- tags: string[]
- extraNumbers: string[]
- memo: string
- checked: boolean

Elasticsearch への反映対象も同じとする。

## 7. 画面一覧
### 7.1 /search

用途:

- Elasticsearch の検索
- 検索結果の一覧表示
- metadata の確認
- 一括更新
- sync status の確認

主な機能:

- キーワード検索
- ページング
- 一覧表示
- 複数選択
- tags / assignees / extraNumbers 追加
- memo 追記
- checked 一括更新

### 7.2 /docs/[docId]

用途:

- 文書詳細確認
- metadata 単票編集
- sync 状態確認
- 個別再同期

主な機能:

- ES 本文表示
- metadata 編集フォーム
- 保存
- sync status 表示
- エラー表示
- 再同期ボタン

### 7.3 /sync-status

用途:

- pending / failed の一覧確認
- 未同期文書の再同期
- restore 実行

主な機能:

- pending / failed 一覧
- エラー確認
- 選択再同期
- failed 全件再同期
- pending 全件再同期
- restore パネル
- restore 履歴への導線

### 7.4 /restore-jobs

用途:

- restore 実行履歴の確認

主な機能:

- job 一覧
- 件数表示
- ステータス表示
- 詳細画面への遷移

### 7.5 /restore-jobs/[jobId]

用途:

- restore job 詳細の確認

主な機能:

- request 内容表示
- 成否件数表示
- item ごとの結果表示
- 失敗 docId の確認

## 8. API 一覧
### 8.1 検索系
- GET /api/search
- GET /api/docs/[docId]
- GET /api/metadata/[docId]

### 8.2 保存系
- PUT /api/metadata/[docId]
- POST /api/metadata/bulk

### 8.3 同期系
- POST /api/metadata/sync
- GET /api/metadata/sync-status
### 8.4 リストア系
- POST /api/metadata/restore
- GET /api/metadata/restore-jobs
- GET /api/metadata/restore-jobs/[jobId]

## 9. SQLite テーブル設計
### 9.1 document_metadata

用途:

- metadata 正本

主なカラム:

- doc_id
- assignees_json
- tags_json
- extra_numbers_json
- memo
- checked
- created_at
- updated_at

### 9.2 metadata_history

用途:

- metadata 更新履歴

主なカラム:

- id
- doc_id
- operation
- before_json
- after_json
- created_at

### 9.3 metadata_sync_status

用途:

- Elasticsearch 同期状態管理

主なカラム:

- doc_id
- sync_status
- error_message
- retry_count
- last_attempted_at
- last_succeeded_at
- created_at
- updated_at

状態値:

- pending
- success
- failed

### 9.4 metadata_restore_jobs

用途:

- restore 実行履歴

主なカラム:

- id
- job_type
- target_mode
- request_json
- status
- requested_count
- succeeded_count
- failed_count
- total_available
- started_at
- finished_at
- created_at
- updated_at

状態値:

- running
- completed
- partial
- failed

### 9.5 metadata_restore_job_items

用途:

- restore job 内の docId 別実行結果

主なカラム:

- id
- job_id
- doc_id
- ok
- error_message
- created_at

## 10. ディレクトリ構成
```bash
skull/
├─ sqlite/
│  └─ skull.db
├─ src/
│  ├─ app/
│  │  ├─ search/page.tsx
│  │  ├─ docs/[docId]/page.tsx
│  │  ├─ sync-status/page.tsx
│  │  ├─ restore-jobs/page.tsx
│  │  ├─ restore-jobs/[jobId]/page.tsx
│  │  └─ api/
│  │     ├─ search/route.ts
│  │     ├─ docs/[docId]/route.ts
│  │     ├─ metadata/[docId]/route.ts
│  │     ├─ metadata/bulk/route.ts
│  │     ├─ metadata/sync/route.ts
│  │     ├─ metadata/sync-status/route.ts
│  │     ├─ metadata/restore/route.ts
│  │     ├─ metadata/restore-jobs/route.ts
│  │     └─ metadata/restore-jobs/[jobId]/route.ts
│  ├─ components/
│  │  ├─ search/
│  │  ├─ metadata/
│  │  ├─ sync/
│  │  ├─ restore/
│  │  └─ document/
│  ├─ lib/
│  │  ├─ db/
│  │  ├─ es/
│  │  ├─ services/
│  │  ├─ validators/
│  │  └─ types/
│  └─ styles/
├─ scripts/
│  └─ init-db.ts
└─ docs/
   └─ implementation-plan.md
```

## 11. 実装順序
### Phase 1: 基盤
- Next.js プロジェクト作成
- package 導入
- .env.local 整備
- SQLite 初期化スクリプト作成
- Drizzle schema 作成
- Elasticsearch client 作成

成果物:

- 起動可能な空プロジェクト
- DB 作成可能

### Phase 2: metadata 正本と単票編集
- document_metadata
- metadata_history
- metadata repository
- PUT /api/metadata/[docId]
- GET /api/metadata/[docId]
- 詳細画面 metadata editor

成果物:

- 1件編集して SQLite に保存できる
- Elasticsearch に単票反映できる

### Phase 3: 検索と一覧
- GET /api/search
- 検索画面
- Elasticsearch 本文表示
- SQLite metadata マージ表示
- 詳細画面本文表示

成果物:

- 検索して一覧表示
- 詳細画面へ遷移
- metadata 状態確認

### Phase 4: 一括更新
- POST /api/metadata/bulk
- 一括編集ツールバー
- 複数選択 UI

成果物:

- tags / assignees / extraNumbers / checked / memo の一括更新

### Phase 5: sync_status
- metadata_sync_status
- 保存時の pending / success / failed 更新
- POST /api/metadata/sync
- GET /api/metadata/sync-status
- 未同期一覧画面

成果物:

- 未同期確認
- 再同期
- failed/pending の管理

### Phase 6: restore
- POST /api/metadata/restore
- restore panel
- bulk restore
- success を含めた再投入

成果物:

- ES 再作成後の metadata リストア

### Phase 7: restore 履歴
- metadata_restore_jobs
- metadata_restore_job_items
- restore job 記録
- /restore-jobs
- /restore-jobs/[jobId]

成果物:

- restore の実行履歴確認
- failed docId の追跡

## 12. 重要な運用ルール
### 12.1 ES 全削除後の復旧手順
1. panther で本文文書を Elasticsearch に再登録
1. skull の restore を実行
1. 必要に応じて failed item を確認

### 12.2 sync と restore の使い分け
- sync
  - pending / failed の再送
- restore
  - SQLite 正本から ES へ再投入
  - success を含めて対象にできる

## 13. エラー処理方針
### 13.1 単票保存
- SQLite 保存失敗: API エラー
- ES 同期失敗: SQLite 保存は成功、sync_status は failed

### 13.2 一括更新
- 文書単位で成功/失敗を分離
- 失敗は sync_status に反映
- 結果は docId 単位で返す

### 13.3 restore
- job を作成してから実行
- item ごとに成功/失敗を記録
- ジョブ全体は completed / partial / failed に分類

## 14. 性能方針
### 14.1 Elasticsearch 更新
- 単票保存: 単件 update
- 一括更新: bulk update
- 再同期: bulk update
- restore: bulk update

### 14.2 batchSize 初期値
- 推奨初期値: 200

### 14.3 ページサイズ
- 検索一覧: 20
- 未同期一覧: 100
- restore jobs: 50

## 15. テスト方針
### 15.1 単体テスト対象
- validator
- metadata merge ロジック
- sync service
- restore service

### 15.2 手動確認シナリオ
1. 単票保存できる
1. 検索一覧に metadata が出る
1. 一括更新できる
1. ES を止めた状態で保存すると failed になる
1. 再同期で success に戻る
1. ES 再作成後に restore できる
1. restore 履歴が残る

## 16. 初期リリース条件

初期リリースでは、次を満たせばよい。

- SQLite に metadata が保存できる
- Elasticsearch に metadata が反映できる
- 未同期状態が見える
- 再同期できる
- restore できる
- restore 履歴が確認できる

## 17. 将来拡張候補
- 認証・権限制御
- restore job 失敗分のみ再実行
- sync / restore 共通ジョブ基盤
- 自動再送バッチ
- 検索条件で sync_status フィルタ
- 検索一覧から個別再同期
- metadata 削除系一括更新
- audit log 強化
- 通知機能

## 18. 実装着手時のチェック項目

着手前に次を確認する。

- ES index 名
- docId == ES _id の保証
- ES 側 metadata フィールド名
- SQLite 保存パス
- .env.local の値
- panther の再登録手順
- restore 時の batchSize 初期値

## 19. 最終結論

skull は、TypeScript / Next.js / SQLite / Elasticsearch 構成で、
SQLite 正本・ES 同期先 の方針で実装する。

初期実装では、

- 検索
- metadata 編集
- 一括更新
- sync_status
- 再同期
- restore
- restore 履歴

までを対象とし、
実運用しながら必要な機能を追加していく。