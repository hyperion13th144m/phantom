import type { ParagraphItem } from "./paragraph";
import { type BaseBlock, type IndentLevelString, type NumberString } from "./text-blocks-root";

/** -----------------------------
 *  特許請求の範囲（claims）
 * ---------------------------- */
export interface ClaimBlock extends BaseBlock {
    tag: "claim";
    jpTag: string;
    number: NumberString; // "1" / "2" ...
    indentLevel: IndentLevelString;
    isIndependent: boolean;
    blocks: ClaimTextBlock[];
}

export interface ClaimTextBlock extends BaseBlock {
    tag: "claim-text";
    blocks: ParagraphItem[];
}

