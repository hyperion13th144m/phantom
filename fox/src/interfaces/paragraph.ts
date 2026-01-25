import type { BaseBlock, IndentLevelString, NumberString } from "./text-blocks-root";
import { createTypeGuard } from "./text-blocks-root";

export interface ParagraphBlock extends BaseBlock {
    tag: "paragraph";
    jpTag: string
    number: NumberString;
    indentLevel: IndentLevelString;
    blocks: ParagraphItem[];
}
export interface InlineText extends BaseBlock {
    tag: "text" | "sub" | "sup" | "underline";
    text: string;
    isLastSentence: boolean;
}

export interface InlineImageBlock extends BaseBlock {
    tag: "tables" | "maths" | "chemistry";
    number: NumberString; // "1" / "2" ...
    jpTag: string;
    indentLevel: IndentLevelString;
    images: ImageSrcBlock[];
}

/** 先行文献引用（citation-list 内で出現） */
export interface PatcitBlock extends BaseBlock {
    tag: "patcit" | "nplcit";
    jpTag: string;
    number: NumberString; // "1" / "2"
    text: string;
    indentLevel: IndentLevelString;
}

/** 図参照（description-of-drawings などで出現） */
export interface FigRefBlock extends BaseBlock {
    tag: "figref";
    jpTag: string;
    number: NumberString; // "1" など
    text: string;
    indentLevel: IndentLevelString;
}

export interface ImageSrcBlock {
    src: string;
    width: number;
    height: number;
    kind: "figure" | "table" | "math" | "chemistry" | "image" | "unknown";
    sizeTag: "thumbnail" | "middle" | "large";
}

export type ParagraphItem = InlineText | InlineImageBlock |
    FigRefBlock | PatcitBlock;

// --- 各型専用の型ガードを生成 ---
export const paragraphTypeGuards = {
    isParagraph: createTypeGuard<ParagraphBlock, 'tag'>('tag', 'paragraph'),
    isTables: createTypeGuard<InlineImageBlock, 'tag'>('tag', 'tables'),
    isMaths: createTypeGuard<InlineImageBlock, 'tag'>('tag', 'maths'),
    isChemistry: createTypeGuard<InlineImageBlock, 'tag'>('tag', 'chemistry'),
    isTextBlock: createTypeGuard<InlineText, 'tag'>('tag', 'text'),
    isSubBlock: createTypeGuard<InlineText, 'tag'>('tag', 'sub'),
    isSupBlock: createTypeGuard<InlineText, 'tag'>('tag', 'sup'),
    isUnderlineBlock: createTypeGuard<InlineText, 'tag'>('tag', 'underline'),
    isFigRefBlock: createTypeGuard<FigRefBlock, 'tag'>('tag', 'figref'),
    isPatcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'patcit'),
    isNplcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'nplcit'),
}
