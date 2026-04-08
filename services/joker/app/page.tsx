import { redirect } from "next/navigation";

export default function Home() {
    return (
        <div className="flex h-screen w-screen items-center justify-center">
            <ul>
                <li>
                    <a
                        href="/skull/search"
                        className="text-blue-500 hover:underline"
                    >
                        メタデータ編集
                    </a>
                </li>
                <li>
                    <a
                        href="/navi"
                        className="text-blue-500 hover:underline"
                    >
                        管理画面
                    </a>
                </li>
            </ul>
        </div>
    );
}
