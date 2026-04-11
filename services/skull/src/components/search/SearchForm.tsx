"use client";

import { useRef } from "react";
import type { SearchAggregations } from "@/lib/types/metadata";

type SearchFormProps = {
    initialQ: string;
    initialSize: number;
    initialApplicants?: string;
    initialInventors?: string;
    initialLaw?: string;
    initialDocumentName?: string;
    initialTags?: string;
    initialAssignees?: string;
    aggregations?: SearchAggregations;
};

type FilterSelectProps = {
    id: string;
    label: string;
    options: string[];
    selected: string[];
    hiddenRef: React.RefObject<HTMLInputElement | null>;
    selectRef: React.RefObject<HTMLSelectElement | null>;
};

function FilterSelect({ id, label, options, selected, hiddenRef, selectRef }: FilterSelectProps) {
    if (options.length === 0) return null;
    return (
        <div className="space-y-1">
            <label htmlFor={id} className="block text-xs font-medium text-gray-600">
                {label}
            </label>
            <select
                ref={selectRef}
                id={id}
                multiple
                defaultValue={selected}
                onChange={(e) => {
                    const vals = Array.from(e.target.selectedOptions).map((o) => o.value);
                    if (hiddenRef.current) hiddenRef.current.value = vals.join(",");
                }}
                className="w-full rounded-lg border px-3 py-1.5 text-sm outline-none focus:ring h-28"
            >
                {options.map((opt) => (
                    <option key={opt} value={opt}>{opt}</option>
                ))}
            </select>
        </div>
    );
}

export default function SearchForm({
    initialQ,
    initialSize,
    initialApplicants = "",
    initialInventors = "",
    initialLaw = "",
    initialDocumentName = "",
    initialTags = "",
    initialAssignees = "",
    aggregations,
}: SearchFormProps) {
    const formRef = useRef<HTMLFormElement>(null);

    const applicantsRef = useRef<HTMLInputElement>(null);
    const inventorsRef = useRef<HTMLInputElement>(null);
    const lawRef = useRef<HTMLInputElement>(null);
    const documentNameRef = useRef<HTMLInputElement>(null);
    const tagsRef = useRef<HTMLInputElement>(null);
    const assigneesRef = useRef<HTMLInputElement>(null);

    const applicantsSelectRef = useRef<HTMLSelectElement>(null);
    const inventorsSelectRef = useRef<HTMLSelectElement>(null);
    const lawSelectRef = useRef<HTMLSelectElement>(null);
    const documentNameSelectRef = useRef<HTMLSelectElement>(null);
    const tagsSelectRef = useRef<HTMLSelectElement>(null);
    const assigneesSelectRef = useRef<HTMLSelectElement>(null);

    const toSelected = (csv: string) => csv ? csv.split(",").map((v) => v.trim()).filter(Boolean) : [];

    function clearAllFilters() {
        const selectRefs = [applicantsSelectRef, inventorsSelectRef, lawSelectRef, documentNameSelectRef, tagsSelectRef, assigneesSelectRef];
        const hiddenRefs = [applicantsRef, inventorsRef, lawRef, documentNameRef, tagsRef, assigneesRef];

        for (const ref of selectRefs) {
            if (ref.current) {
                for (const opt of Array.from(ref.current.options)) {
                    opt.selected = false;
                }
            }
        }
        for (const ref of hiddenRefs) {
            if (ref.current) ref.current.value = "";
        }

        formRef.current?.submit();
    }

    const hasFilter = [initialApplicants, initialInventors, initialLaw, initialDocumentName, initialTags, initialAssignees].some(Boolean);

    return (
        <form
            ref={formRef}
            action={`${process.env.NEXT_PUBLIC_BASE_PATH}/search`}
            method="GET"
            className="rounded-xl border bg-white p-4 shadow-sm"
        >
            <div className="grid gap-4 md:grid-cols-[1fr_140px_120px]">
                <div className="space-y-2">
                    <label htmlFor="q" className="block text-sm font-medium">
                        キーワード
                    </label>
                    <input
                        id="q"
                        name="q"
                        defaultValue={initialQ}
                        placeholder="例: battery electrode"
                        className="w-full rounded-lg border px-3 py-2 outline-none focus:ring"
                    />
                </div>

                <div className="space-y-2">
                    <label htmlFor="size" className="block text-sm font-medium">
                        件数
                    </label>
                    <select
                        id="size"
                        name="size"
                        defaultValue={String(initialSize)}
                        className="w-full rounded-lg border px-3 py-2"
                    >
                        <option value="10">10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>

                <div className="flex items-end">
                    <button
                        type="submit"
                        className="w-full rounded-lg border px-4 py-2 font-medium hover:bg-gray-50"
                    >
                        検索
                    </button>
                </div>
            </div>

            {aggregations && (
                <>
                    <div className="mt-4 grid gap-3 md:grid-cols-2 lg:grid-cols-3">
                        <FilterSelect
                            id="applicants-select"
                            label="出願人（複数選択可）"
                            options={aggregations.applicants}
                            selected={toSelected(initialApplicants)}
                            hiddenRef={applicantsRef}
                            selectRef={applicantsSelectRef}
                        />
                        <FilterSelect
                            id="inventors-select"
                            label="発明者（複数選択可）"
                            options={aggregations.inventors}
                            selected={toSelected(initialInventors)}
                            hiddenRef={inventorsRef}
                            selectRef={inventorsSelectRef}
                        />
                        <FilterSelect
                            id="law-select"
                            label="法域（複数選択可）"
                            options={aggregations.law}
                            selected={toSelected(initialLaw)}
                            hiddenRef={lawRef}
                            selectRef={lawSelectRef}
                        />
                        <FilterSelect
                            id="documentName-select"
                            label="書類名（複数選択可）"
                            options={aggregations.documentName}
                            selected={toSelected(initialDocumentName)}
                            hiddenRef={documentNameRef}
                            selectRef={documentNameSelectRef}
                        />
                        <FilterSelect
                            id="tags-select"
                            label="タグ（複数選択可）"
                            options={aggregations.tags}
                            selected={toSelected(initialTags)}
                            hiddenRef={tagsRef}
                            selectRef={tagsSelectRef}
                        />
                        <FilterSelect
                            id="assignees-select"
                            label="担当者（複数選択可）"
                            options={aggregations.assignees}
                            selected={toSelected(initialAssignees)}
                            hiddenRef={assigneesRef}
                            selectRef={assigneesSelectRef}
                        />
                    </div>

                    {hasFilter && (
                        <div className="mt-3 flex justify-end">
                            <button
                                type="button"
                                onClick={clearAllFilters}
                                className="rounded-lg border px-4 py-1.5 text-sm hover:bg-gray-50"
                            >
                                絞り込みをすべて解除
                            </button>
                        </div>
                    )}
                </>
            )}

            {/* hidden inputs — フォームサブミット時に値を運ぶ */}
            <input ref={applicantsRef}   type="hidden" name="applicants"   defaultValue={initialApplicants} />
            <input ref={inventorsRef}    type="hidden" name="inventors"    defaultValue={initialInventors} />
            <input ref={lawRef}          type="hidden" name="law"          defaultValue={initialLaw} />
            <input ref={documentNameRef} type="hidden" name="documentName" defaultValue={initialDocumentName} />
            <input ref={tagsRef}         type="hidden" name="tags"         defaultValue={initialTags} />
            <input ref={assigneesRef}    type="hidden" name="assignees"    defaultValue={initialAssignees} />
            <input type="hidden" name="page" value="1" />
        </form>
    );
}
