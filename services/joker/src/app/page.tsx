import { redirect } from "next/navigation";

export default function Home() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">特許文書検索システム</h1>
      <ul>
        <li>簡易検索：キーワードで特許文書を検索します。</li>
        <li>書誌検索：書誌事項で特許文書を検索します。</li>
      </ul>
      <hr />
      <ul>
        <li>
          <a
            href="/skull"
            className="text-blue-500 hover:underline"
            target="_blank"
          >
            メタデータ編集
          </a>
          特許文書に担当者などを付加できます。
        </li>
        <li>
          <a
            href="/navi"
            target="_blank"
            className="text-blue-500 hover:underline"
          >
            管理画面
          </a>
          特許文書の収集、登録を行います。
        </li>
      </ul>
    </div>
  );
}
