"use client";

type SaveButtonProps = {
    pending: boolean;
};

export default function SaveButton({ pending }: SaveButtonProps) {
    return (
        <button
            type="submit"
            disabled={pending}
            className="rounded-lg border px-4 py-2 font-medium hover:bg-gray-50 disabled:opacity-50"
        >
            {pending ? "保存中..." : "保存"}
        </button>
    );
}