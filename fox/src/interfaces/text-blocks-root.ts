import type { ParagraphBlock } from "./paragraph";

/** text-blocks.json のトップレベル */
export type TextBlocksRoot = DocumentBlock[];

const documentTags = [
    "pat-app-doc",
    "description",
    "claims",
    "abstract",
    "drawings",
    "foreign-language-description",
    "foreign-language-claims",
    "foreign-language-abstract",
    "foreign-language-drawings",
    "pat-rspns",
    "pat-amnd",
    "pat-etc",
    "notice-pat-exam",
    "notice-pat-exam-rn",
] as const;
export type DocumentTag = typeof documentTags[number];
export interface DocumentBlock {
    tag: DocumentTag;
    jpTag?: string;
    indentLevel?: IndentLevelString;
    text?: string;
    blocks?: Block[];
}
interface PatAppDocBlock extends DocumentBlock {
    tag: 'pat-app-doc';
    blocks: Block[];
}
interface DefaultDocBlock extends DocumentBlock {
    tag: 'description' | 'claims' | 'drawings';
    jpTag: string;
    indentLevel: IndentLevelString;
    blocks: Block[];
}
export interface AbstractDocBlock extends DocumentBlock {
    tag: 'abstract';
    jpTag: string;
    indentLevel: IndentLevelString;
    text: string;
}
export const documentTypeGuards = {
    isPatAppDoc: createTypeGuard<PatAppDocBlock, 'tag'>('tag', 'pat-app-doc'),
    isDescription: createTypeGuard<DefaultDocBlock, 'tag'>('tag', 'description'),
    isClaims: createTypeGuard<DefaultDocBlock, 'tag'>('tag', 'claims'),
    isAbstract: createTypeGuard<AbstractDocBlock, 'tag'>('tag', 'abstract'),
    isDrawings: createTypeGuard<DefaultDocBlock, 'tag'>('tag', 'drawings'),
    isForeignDescription: createTypeGuard<DocumentBlock, 'tag'>('tag', 'foreign-language-description'),
    isForeignClaims: createTypeGuard<DocumentBlock, 'tag'>('tag', 'foreign-language-claims'),
    isForeignAbstract: createTypeGuard<DocumentBlock, 'tag'>('tag', 'foreign-language-abstract'),
    isForeignDrawings: createTypeGuard<DocumentBlock, 'tag'>('tag', 'foreign-language-drawings'),
    isPatResponse: createTypeGuard<DocumentBlock, 'tag'>('tag', 'pat-rspns'),
    isPatAmendment: createTypeGuard<DocumentBlock, 'tag'>('tag', 'pat-amnd'),
    isPatEtc: createTypeGuard<DocumentBlock, 'tag'>('tag', 'pat-etc'),
    isNoticePatExam: createTypeGuard<DocumentBlock, 'tag'>('tag', 'notice-pat-exam'),
    isNoticePatExamRn: createTypeGuard<DocumentBlock, 'tag'>('tag', 'notice-pat-exam-rn'),
}

/** -----------------------------
 *  共通ユーティリティ
 * ---------------------------- */

/** JSON上は "0" や "1" のように文字列になっている */
export type IndentLevelString = string;

/** "0001" / "1" など、数字っぽいが文字列 */
export type NumberString = string;

/** 多くのブロックで共通する最小フィールド */
export interface BaseBlock {
    tag: string;
    blocks: Block[];
}

/** tag で判別する総称 Block（必要に応じて随時拡張してください） */
export type Block =
    ApplicationFormBlock
    | ApplicationFormItemBlock
    | InventionTitleBlock
    | CommonDescriptionBlock
    | DescriptionOfDrawingsBlock
    | ParagraphBlock
    | ClaimBlock
    | ClaimTextBlock
    | FigureBlock
    | TablesBlock
    | MathsBlock
    | ChemistryBlock
    | ImageBlock
    | TextRun
    | FigRefBlock
    | PatcitBlock
    | PatentLiteratureBlock
    | NonPatentLiteratureBlock
    | PatResponseBlock
    | UnknownBlock;

/** 想定外 tag が来ても落ちないためのフォールバック */
export interface UnknownBlock extends BaseBlock {
    tag: Exclude<string, KnownTag>;
    [key: string]: unknown;
}

/** 既知 tag の集合（必要に応じて増やす） */
export type KnownTag =
    | "applicationForm"
    | "invention-title"
    | "technical-field"
    | "background-art"
    | "citation-list"
    | "patent-literature"
    | "non-patent-literature"
    | "summary-of-invention"
    | "disclosure"
    | "tech-problem"
    | "tech-solution"
    | "advantageous-effects"
    | "description-of-drawings"
    | "description-of-embodiments"
    | "best-mode"
    | "industrial-applicability"
    | "reference-signs-list"
    | "sequence-list-text"
    | "reference-to-deposited-biological-material"
    | "claim"
    | "claim-text"
    | "paragraph"
    | "text"
    | "sub"
    | "sup"
    | "figref"
    | "patcit"
    | "embodiment-example"
    | "mode-for-invention"
    | "figure"
    | "tables"
    | "maths"
    | "chemistry"
    | "image"
    | "pat-rspns";

/** -----------------------------
 *  再帰の中心：paragraph / text runs
 * ---------------------------- */

/** 文章の最小単位：text/sub/sup/underline */
export type TextRun = TextBlock;
export interface FigureBlock extends BaseBlock {
    tag: "figure";
    number: NumberString; // "1" / "2" ...
    alt: string;
    representative: boolean;
    images: ImageSrcBlock[];
}


export interface TextBlock extends BaseBlock {
    tag: "text";
    text: string;
    isLastSentence: boolean;
}
/** -----------------------------
 *  特許出願願書系
 *  TODO: 願書はinterface とjsonがあってないかも
 * ---------------------------- */
export interface ApplicationFormBlock extends BaseBlock {
    tag: "applicationForm";
    blocks: ApplicationFormItemBlock[];
}

export interface ApplicationFormItemBlock extends BaseBlock {
    tag: string;
    text?: string;
    convertedText?: string;
    blocks: ApplicationFormItemBlock[];
}

/** -----------------------------
 *  明細書系（description 配下）
 * ---------------------------- */

/** 【特許文献】 */
export interface PatentLiteratureBlock extends BaseBlock {
    tag: "patent-literature";
    blocks: ParagraphBlock[];
}

/** 【非特許文献】 */
export interface NonPatentLiteratureBlock extends BaseBlock {
    tag: "non-patent-literature";
    blocks: ParagraphBlock[];
}
/** 【図面の簡単な説明】 */
export interface DescriptionOfDrawingsBlock extends BaseBlock {
    tag: "description-of-drawings";
    blocks: ParagraphBlock[];
}


export interface InventionTitleBlock extends BaseBlock {
    tag: "invention-title";
    jpTag: string;
    indentLevel: IndentLevelString;
    blocks: TextBlock[];
}

const commonDescriptionTags = [
    "technical-field",
    "background-art",
    "citation-list",
    "patent-literature",
    "non-patent-literature",
    "summary-of-invention",
    "disclosure",
    "tech-problem",
    "tech-solution",
    "advantageous-effects",
    "description-of-drawings",
    "description-of-embodiments",
    "best-mode",
    "embodiment-example",
    "mode-for-invention",
    "industrial-applicability",
    "sequence-list-text",
    "reference-signs-list",
    "reference-to-deposited-biological-material",
] as const;
export type CommonDescriptionTag = typeof commonDescriptionTags[number];
export interface CommonDescriptionBlock extends BaseBlock {
    tag: CommonDescriptionTag;
    jpTag: string;
    indentLevel: IndentLevelString;
    blocks: ParagraphBlock[];
}
function isCommonDescriptionBlock(block: unknown): block is CommonDescriptionBlock {
    if (
        typeof block !== "object" ||
        block === null ||
        !("tag" in block) ||
        typeof (block as any).tag !== "string"
    ) {
        return false;
    }
    return commonDescriptionTags.includes((block as any).tag);
}

// --- 各型専用の型ガードを生成 ---
export const descriptionTypeGuards = {
    isInventionTitle: createTypeGuard<InventionTitleBlock, 'tag'>('tag', 'invention-title'),
    isCommonDescriptionBlock,
}

/** 【特許文献】 */
export interface PatentLiteratureBlock extends BaseBlock {
    tag: "patent-literature";
    blocks: ParagraphBlock[];
}

/** 【非特許文献】 */
export interface NonPatentLiteratureBlock extends BaseBlock {
    tag: "non-patent-literature";
    blocks: ParagraphBlock[];
}

/** 【図面の簡単な説明】 */
export interface DescriptionOfDrawingsBlock extends BaseBlock {
    tag: "description-of-drawings";
    blocks: ParagraphBlock[];
}
/** -----------------------------
 *  図面（drawings）
 * ---------------------------- */

export interface DrawingsBlock extends BaseBlock {
    tag: "drawings";
    blocks: FigureBlock[];
}

export interface FigureBlock extends BaseBlock {
    tag: "figure";
    number: NumberString; // "1" / "2" ...
    alt: string;
    representative: boolean;
    images: ImageSrcBlock[];
}


export interface ImageBlock extends BaseBlock {
    tag: "image";
    number: NumberString; // "1" / "2" ...
    indentLevel: IndentLevelString;
    images: ImageSrcBlock[];
}

export interface ImageSrcBlock {
    src: string;
    width: number;
    height: number;
    kind: "figure" | "table" | "math" | "chemistry" | "image" | "unknown";
    sizeTag: "thumbnail" | "middle" | "large";
}

/** -----------------------------
 *  外国語書面出願：外国語明細書
 * ---------------------------- */
export interface ForeignDescriptionBlock extends BaseBlock {
    tag: "foreign-language-description";
    blocks: ImageBlock[];
}

/** -----------------------------
 *  外国語書面出願：外国語特許請求の範囲
 * ---------------------------- */
export interface ForeignClaimsBlock extends BaseBlock {
    tag: "foreign-language-claims";
    blocks: ImageBlock[];
}

/** -----------------------------
 *  外国語書面出願：外国語要約書
 * ---------------------------- */
export interface ForeignAbstractBlock extends BaseBlock {
    tag: "foreign-language-abstract";
    blocks: ImageBlock[];
}

/** -----------------------------
 *  外国語書面出願：外国語図面
 * ---------------------------- */
export interface ForeignDrawingsBlock extends BaseBlock {
    tag: "foreign-language-drawings";
    blocks: ImageBlock[];
}

/** -----------------------------
 *  意見書・弁明書
 * ---------------------------- */

export interface PatResponseBlock extends BaseBlock {
    tag: "patRspns";
    blocks: FigureBlock[];
}

// --- 型ガードの汎用ファクトリー関数 ---
// K は判定に使うキー、V はその値
export function createTypeGuard<T extends object, K extends keyof T>(
    key: K,
    value: T[K]
): (obj: unknown) => obj is T {
    return (obj: unknown): obj is T =>
        typeof obj === 'object' &&
        obj !== null &&
        key in obj &&
        (obj as T)[key] === value;
}

// 願書の各項目は、tag が "jp:" で始まる。
const isApplicationFormItemBlock = (obj: unknown): obj is ApplicationFormItemBlock => {
    return typeof obj === 'object' &&
        obj !== null &&
        'tag' in obj &&
        typeof (obj as any).tag === 'string' &&
        (obj as any).tag.startsWith('jp:');
};

// --- 各型専用の型ガードを生成 ---
export const commonTypeGuards = {
    isApplicationForm: createTypeGuard<ApplicationFormBlock, 'tag'>('tag', 'applicationForm'),
    isInventionTitle: createTypeGuard<InventionTitleBlock, 'tag'>('tag', 'invention-title'),
    isPatentLiterature: createTypeGuard<PatentLiteratureBlock, 'tag'>('tag', 'patent-literature'),
    isNonPatentLiterature: createTypeGuard<NonPatentLiteratureBlock, 'tag'>('tag', 'non-patent-literature'),
    isDescriptionOfDrawings: createTypeGuard<DescriptionOfDrawingsBlock, 'tag'>('tag', 'description-of-drawings'),
    isFigure: createTypeGuard<FigureBlock, 'tag'>('tag', 'figure'),
    isImage: createTypeGuard<ImageBlock, 'tag'>('tag', 'image'),
    isParagraph: createTypeGuard<ParagraphBlock, 'tag'>('tag', 'paragraph'),
    isTextBlock: createTypeGuard<TextBlock, 'tag'>('tag', 'text'),
    isApplicationFormItemBlock,
}
