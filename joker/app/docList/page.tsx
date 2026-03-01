"use client";

import { Suspense, useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import ErrorMessage from "@/app/components/error-message";
import SimpleInput from "@/app/components/simple-input";
import { formatApplicationNumber, formatDate } from "@/lib/helpers";

type DocResult = {
    docId: string;
    applicants: string[];
    fileReferenceId: string;
    submissionDate: string | number;
    dispatchDate: string | number;
    documentName: string;
    documentCode: string;
};

type GroupResult = {
    law: string;
    applicationNumber: string;
    docs: DocResult[];
};

type ApiResponse = GroupResult[];

function DocListPageContent() {
    const router = useRouter();
    const sp = useSearchParams();

    const inventors0 = sp.get("inventors") ?? "";
    const applicants0 = sp.get("applicants") ?? "";
    const applicationNumber0 = sp.get("applicationNumber") ?? "";
    const fileReferenceId0 = sp.get("fileReferenceId") ?? "";
    const law0 = sp.get("law") ?? "";

    const [inventors, setInventors] = useState(inventors0);
    const [applicants, setApplicants] = useState(applicants0);
    const [applicationNumber, setApplicationNumber] = useState(applicationNumber0);
    const [fileReferenceId, setFileReferenceId] = useState(fileReferenceId0);
    const [law, setLaw] = useState(law0);

    const [loading, setLoading] = useState(false);
    const [data, setData] = useState<ApiResponse | null>(null);
    const [err, setErr] = useState<string | null>(null);

    useEffect(() => {
        setInventors(inventors0);
        setApplicants(applicants0);
        setApplicationNumber(applicationNumber0);
        setFileReferenceId(fileReferenceId0);
        setLaw(law0);
    }, [inventors0, applicants0, applicationNumber0, fileReferenceId0, law0]);

    async function fetchDocList(params: {
        inventors?: string;
        applicants?: string;
        applicationNumber?: string;
        fileReferenceId?: string;
        law?: string;
    }) {
        const usp = new URLSearchParams();
        if (params.inventors?.trim()) usp.set("inventors", params.inventors.trim());
        if (params.applicants?.trim()) usp.set("applicants", params.applicants.trim());
        if (params.applicationNumber?.trim()) usp.set("applicationNumber", params.applicationNumber.trim());
        if (params.fileReferenceId?.trim()) usp.set("fileReferenceId", params.fileReferenceId.trim());
        if (params.law?.trim()) usp.set("law", params.law.trim());

        setLoading(true);
        setErr(null);

        try {
            const res = await fetch(`/api/docList?${usp.toString()}`);
            if (!res.ok) {
                const errData = await res.json();
                throw new Error(errData.message || "Failed to fetch documents");
            }
            const result = (await res.json()) as ApiResponse;
            setData(result);
        } catch (e: unknown) {
            setErr((e as Error)?.message ?? String(e));
            setData(null);
        } finally {
            setLoading(false);
        }
    }

    function handleSearch() {
        const usp = new URLSearchParams();
        if (inventors.trim()) usp.set("inventors", inventors.trim());
        if (applicants.trim()) usp.set("applicants", applicants.trim());
        if (applicationNumber.trim()) usp.set("applicationNumber", applicationNumber.trim());
        if (fileReferenceId.trim()) usp.set("fileReferenceId", fileReferenceId.trim());
        if (law.trim()) usp.set("law", law.trim());

        router.push(`/docList?${usp.toString()}`);
    }

    function handleKeyDown(e: React.KeyboardEvent) {
        if (e.key === "Enter") {
            handleSearch();
        }
    }

    useEffect(() => {
        if (
            inventors0.trim() ||
            applicants0.trim() ||
            applicationNumber0.trim() ||
            fileReferenceId0.trim() ||
            law0.trim()
        ) {
            fetchDocList({
                inventors: inventors0,
                applicants: applicants0,
                applicationNumber: applicationNumber0,
                fileReferenceId: fileReferenceId0,
                law: law0,
            });
        }
    }, [inventors0, applicants0, applicationNumber0, fileReferenceId0, law0]);

    const totalDocs = data?.reduce((sum, group) => sum + group.docs.length, 0) ?? 0;

    return (
        <div className="container mx-auto px-4 py-8">
            <h1 className="text-3xl font-bold mb-6">書誌検索</h1>
            <p className="text-sm text-gray-600 mb-4">項目内はスペース区切りで OR条件、項目間はAND条件で検索されます。</p>

            {/* 検索フォーム */}
            <div className="bg-white p-6 rounded-lg shadow-md mb-6">
                <div className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium mb-1">発明者</label>
                        <input
                            type="text"
                            value={inventors}
                            onChange={(e) => setInventors(e.target.value)}
                            onKeyDown={handleKeyDown}
                            placeholder="発明者名を入力..."
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-1">出願人</label>
                        <input
                            type="text"
                            value={applicants}
                            onChange={(e) => setApplicants(e.target.value)}
                            onKeyDown={handleKeyDown}
                            placeholder="出願人名を入力..."
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium mb-1">出願番号</label>
                            <input
                                type="text"
                                value={applicationNumber}
                                onChange={(e) => setApplicationNumber(e.target.value)}
                                onKeyDown={handleKeyDown}
                                placeholder="出願番号を入力..."
                                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium mb-1">整理番号</label>
                            <input
                                type="text"
                                value={fileReferenceId}
                                onChange={(e) => setFileReferenceId(e.target.value)}
                                onKeyDown={handleKeyDown}
                                placeholder="整理番号を入力..."
                                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                        </div>
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-1">法律種別</label>
                        <select
                            value={law}
                            onChange={(e) => setLaw(e.target.value)}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                            <option value="">なし</option>
                            <option value="patent">特許</option>
                            <option value="utilityModel">実用新案</option>
                        </select>
                    </div>

                    <button
                        onClick={handleSearch}
                        disabled={loading}
                        className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 disabled:bg-gray-400 transition"
                    >
                        {loading ? "検索中..." : "検索"}
                    </button>
                </div>
            </div>

            {/* エラーメッセージ */}
            {err && <ErrorMessage err={err} />}

            {/* 検索結果 */}
            {data && (
                <div className="space-y-6">
                    <div className="text-gray-600">
                        {data.length === 0 ? (
                            <p>検索結果がありません</p>
                        ) : (
                            <p>
                                {data.length}件の法律種別・出願番号の組み合わせが見つかりました（合計{totalDocs}件の文書）
                            </p>
                        )}
                    </div>

                    {data.map((group, groupIdx) => (
                        <div key={groupIdx} className="bg-white p-6 rounded-lg shadow-md border-l-4 border-blue-500">
                            <div className="mb-4">
                                <h2 className="text-xl font-semibold text-gray-800">
                                    {group.law || "（法律種別未設定）"}
                                </h2>
                                <p className="text-sm text-gray-600">
                                    出願番号: {formatApplicationNumber(group.law, group.applicationNumber) || "（未設定）"}
                                </p>
                                <p className="text-sm text-gray-500 mt-1">
                                    {group.docs.length}件の文書
                                </p>
                            </div>

                            <div className="space-y-3">
                                {group.docs.map((doc, docIdx) => (
                                    <div
                                        key={docIdx}
                                        className="bg-gray-50 p-4 rounded border border-gray-200 hover:shadow-md transition"
                                    >
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                                            <div>
                                                <span className="text-gray-600">文書ID</span>
                                                <p className="font-mono text-gray-800">{doc.docId}</p>
                                            </div>
                                            <div>
                                                <span className="text-gray-600">文書名</span>
                                                <p className="text-gray-800">{doc.documentName}</p>
                                            </div>
                                            <div>
                                                <span className="text-gray-600">整理番号</span>
                                                <p className="text-gray-800">{doc.fileReferenceId}</p>
                                            </div>
                                            <div>
                                                <span className="text-gray-600">文書コード</span>
                                                <p className="text-gray-800">{doc.documentCode}</p>
                                            </div>
                                            <div>
                                                <span className="text-gray-600">出願日</span>
                                                <p className="text-gray-800">
                                                    {formatDate(doc.submissionDate)}
                                                </p>
                                            </div>
                                            <div>
                                                <span className="text-gray-600">発送日</span>
                                                <p className="text-gray-800">
                                                    {formatDate(doc.dispatchDate)}
                                                </p>
                                            </div>
                                        </div>

                                        {doc.applicants && doc.applicants.length > 0 && (
                                            <div className="mt-3 pt-3 border-t border-gray-200">
                                                <span className="text-gray-600 text-sm">出願人</span>
                                                <div className="flex flex-wrap gap-2 mt-1">
                                                    {doc.applicants.map((applicant, appIdx) => (
                                                        <span
                                                            key={appIdx}
                                                            className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs"
                                                        >
                                                            {applicant}
                                                        </span>
                                                    ))}
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {loading && (
                <div className="flex justify-center items-center py-12">
                    <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
                </div>
            )}
        </div>
    );
}

export default function DocListPage() {
    return (
        <Suspense fallback={<div className="text-center py-8">読み込み中...</div>}>
            <DocListPageContent />
        </Suspense>
    );
}
