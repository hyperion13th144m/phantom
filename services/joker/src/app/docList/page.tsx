"use client";

import { Suspense, useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import {
  DocListResults,
  DocListSearchForm,
  useDocListSearch,
} from "@/components/doc-list";
import ErrorMessage from "@/components/error-message";
import {
  buildDocListSearchParams,
  normalizeDocListQueryParams,
} from "@/lib/doc-list";
import type { DocListQueryParams } from "@/lib/doc-list/schema";

type DocListForm = Required<DocListQueryParams>;

type ActiveFilter = {
  key: keyof DocListForm;
  label: string;
  value: string;
};

const filterLabels: Record<keyof DocListForm, string> = {
  inventors: "発明者",
  applicants: "出願人",
  applicationNumber: "出願番号",
  fileReferenceId: "整理番号",
  law: "法律種別",
};

const lawLabels: Record<string, string> = {
  patent: "特許",
  utilityModel: "実用新案",
};

function toFormState(
  params: Partial<Record<keyof DocListQueryParams, string | null | undefined>>,
): DocListForm {
  const normalized = normalizeDocListQueryParams(params);

  return {
    inventors: normalized.inventors ?? "",
    applicants: normalized.applicants ?? "",
    applicationNumber: normalized.applicationNumber ?? "",
    fileReferenceId: normalized.fileReferenceId ?? "",
    law: normalized.law ?? "",
  };
}

function getActiveFilters(form: DocListForm): ActiveFilter[] {
  return (Object.entries(form) as Array<[keyof DocListForm, string]>)
    .filter(([, value]) => value.trim().length > 0)
    .map(([key, value]) => ({
      key,
      label: filterLabels[key],
      value: key === "law" ? (lawLabels[value] ?? value) : value,
    }));
}

type ContentProps = {
  initialForm: DocListForm;
};

function DocListPageSection({ initialForm }: ContentProps) {
  const router = useRouter();
  const [form, setForm] = useState<DocListForm>(initialForm);
  const { data, err, fetchDocList, isResultsCapped, loading, maxResults } =
    useDocListSearch();
  const activeFilters = useMemo(() => getActiveFilters(form), [form]);
  const hasActiveFilters = activeFilters.length > 0;
  const [isSearchFormCollapsed, setIsSearchFormCollapsed] = useState(
    Object.values(initialForm).some(Boolean),
  );

  function handleFieldChange(key: keyof DocListQueryParams, value: string) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleSearch() {
    const usp = buildDocListSearchParams(form);
    const query = usp.toString();
    router.push(query ? "/docList?" + query : "/docList");
    setIsSearchFormCollapsed(true);
  }

  function handleReset() {
    setForm({
      inventors: "",
      applicants: "",
      applicationNumber: "",
      fileReferenceId: "",
      law: "",
    });
    setIsSearchFormCollapsed(false);
    router.push("/docList");
  }

  function handleKeyDown(e: React.KeyboardEvent) {
    if (e.key === "Enter") {
      handleSearch();
    }
  }

  useEffect(() => {
    const normalized = normalizeDocListQueryParams(initialForm);

    if (Object.values(normalized).some(Boolean)) {
      fetchDocList(normalized);
    }
  }, [fetchDocList, initialForm]);

  return (
    <div className="min-h-screen bg-slate-100 px-4 py-8">
      <div className="mx-auto max-w-6xl">
        <div className="mb-8 rounded-3xl bg-red-50 px-6 py-8 text-black shadow-sm">
          <div className="max-w-3xl">
            <h1 className="mt-3 text-3xl font-semibold tracking-tight">
              書誌検索
            </h1>
            <p className="mt-3 text-sm leading-6 text-black">
              発明者、出願人、出願番号、整理番号、法律種別から関連文書をまとめて探せます。
              出願単位でグルーピングして、時系列で文書を確認できます。
            </p>
          </div>
        </div>

        <DocListSearchForm
          form={form}
          hasActiveFilters={hasActiveFilters}
          isCollapsed={isSearchFormCollapsed}
          loading={loading}
          onChange={handleFieldChange}
          onReset={handleReset}
          onSearch={handleSearch}
          onKeyDown={handleKeyDown}
          onToggleCollapse={() =>
            setIsSearchFormCollapsed((current) => !current)
          }
        />

        {hasActiveFilters && (
          <section className="mb-6 rounded-2xl border border-slate-200 bg-white px-5 py-4 shadow-sm">
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <div className="text-sm font-semibold text-slate-900">
                  現在の検索条件
                </div>
                <p className="mt-1 text-sm text-slate-600">
                  条件を確認しながら再検索できます。不要な条件はクリアして絞り込みを調整できます。
                </p>
              </div>
              <div className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
                {activeFilters.length} 条件
              </div>
            </div>
            <div className="mt-4 flex flex-wrap gap-2">
              {activeFilters.map((filter) => (
                <span
                  key={filter.key}
                  className="rounded-full border border-slate-200 bg-slate-50 px-3 py-1.5 text-xs font-medium text-slate-700"
                >
                  {filter.label}: {filter.value}
                </span>
              ))}
            </div>
          </section>
        )}

        {err && <ErrorMessage err={err} />}

        {data && (
          <DocListResults
            data={data}
            isResultsCapped={isResultsCapped}
            maxResults={maxResults}
          />
        )}

        {loading && (
          <div className="flex items-center justify-center py-12">
            <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-t-2 border-blue-600"></div>
          </div>
        )}
      </div>
    </div>
  );
}

function DocListPageContent() {
  const sp = useSearchParams();

  const initialForm = toFormState({
    inventors: sp.get("inventors"),
    applicants: sp.get("applicants"),
    applicationNumber: sp.get("applicationNumber"),
    fileReferenceId: sp.get("fileReferenceId"),
    law: sp.get("law"),
  });
  const searchKey = JSON.stringify(initialForm);

  return <DocListPageSection key={searchKey} initialForm={initialForm} />;
}

export default function DocListPage() {
  return (
    <Suspense fallback={<div className="py-8 text-center">読み込み中...</div>}>
      <DocListPageContent />
    </Suspense>
  );
}
