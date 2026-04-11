import Link from "next/link";

export default function Home() {
  return (
    <main className="mx-auto max-w-7xl p-6" >
      <div className="space-y-2">
        <h1 className="text-2xl font-bold">メタデータ管理サービス</h1>
        <p className="text-sm text-gray-600">
          特許文書のメタデータを検索・編集したり、データベースの管理を行うためのサービスです。
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Link
          href="/search"
          className="block rounded-lg border p-6 hover:bg-gray-50"
        >
          <h2 className="text-lg font-semibold">メタデータ編集</h2>
          <p className="text-sm text-gray-600 mt-1">
            特許文書を検索し、付加データを一覧確認・一括更新します。
          </p>
        </Link>

        <Link
          href="/sync-status"
          className="block rounded-lg border p-6 hover:bg-gray-50"
        >
          <h2 className="text-lg font-semibold">再同期/レストア</h2>
          <p className="text-sm text-gray-600 mt-1">
            特許文書の再同期状況を確認し、必要に応じて再同期やレストアを行います。
          </p>
        </Link>

        <Link
          href="/db"
          className="block rounded-lg border p-6 hover:bg-gray-50"
        >
          <h2 className="text-lg font-semibold">バックアップ</h2>
          <p className="text-sm text-gray-600 mt-1">
            メタデータ用データベースのダンプ・リストアを行います。
          </p>
        </Link>
      </div>

      <footer className="mt-12 text-center text-sm text-gray-500">
        <div className="flex gap-5 justify-center">
          <a href="/" target="_blank">特許文書検索</a>
          <a href="/navi" target="_blank">特許文書管理</a>
        </div>
      </footer>
    </main>
  );
}
