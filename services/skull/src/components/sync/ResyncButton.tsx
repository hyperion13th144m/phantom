"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

type ResyncButtonProps = {
    docId: string;
};

export default function ResyncButton({ docId }: ResyncButtonProps) {
    const router = useRouter();
    const [pending, setPending] = useState(false);
    const [message, setMessage] = useState<string>("");

    async function onClick() {
        setPending(true);
        setMessage("");

        try {
            const res = await fetch(`${process.env.NEXT_PUBLIC_BASE_PATH}/api/metadata/sync`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    docIds: [docId],
                }),
            });

            const json = await res.json();

            if (!res.ok) {
                throw new Error(json?.error ?? "再同期に失敗しました");
            }

            if (json.failed > 0) {
                setMessage(`再同期失敗: ${json.failed} 件`);
            } else {
                setMessage("再同期しました。");
            }

            router.refresh();
        } catch (error) {
            setMessage(
                error instanceof Error ? error.message : "再同期に失敗しました",
            );
        } finally {
            setPending(false);
        }
    }

    return (
        <div className="flex items-center gap-3">
            <button
                type="button"
                onClick={onClick}
                disabled={pending}
                className="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-gray-50 disabled:opacity-50"
            >
                {pending ? "再同期中..." : "再同期"}
            </button>
            {message ? <span className="text-sm text-gray-700">{message}</span> : null}
        </div>
    );
}