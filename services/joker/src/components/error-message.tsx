"use client";

export const ErrorMessage: React.FC<{ err: string | null }> = ({ err }) => {
    return (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
            <div style={{ fontWeight: 700, marginBottom: 6 }}>エラー</div>
            <div style={{ whiteSpace: "pre-wrap" }}>{err}</div>
        </div>
    );
}

export default ErrorMessage;
