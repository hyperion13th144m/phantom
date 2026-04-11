import DbDumpRestorePanel from "@/components/db/DbDumpRestorePanel";

export default function DbPage() {
  return (
    <main className="mx-auto max-w-3xl p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div className="space-y-2">
          <h1 className="text-2xl font-bold">メタデータのデータベース管理</h1>
          <p className="text-sm text-gray-600">
            メタデータ用データベースのダンプ・リストアを行います。
          </p>
        </div>
      </div>

      <DbDumpRestorePanel />
    </main>
  );
}
