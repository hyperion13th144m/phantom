# navi

`navi` は管理画面を提供する FastAPI サービスです。

## 現在の実装

- 管理対象プロジェクト一覧（Crow / Panther）
- プロジェクトごとのジョブ作成画面（雛形）
- まだ外部 REST API は呼び出しません（UI のみ）

## 今後の想定

- `services/crow` の API を使った crawling job 起動
- `services/panther` の API を使った upload job 起動
- 管理対象プロジェクトの追加
