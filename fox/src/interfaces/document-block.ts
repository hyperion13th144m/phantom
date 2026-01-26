/** text-blocks.json のトップレベル */
export type TextBlocksRoot = DocumentBlock[];

/** -----------------------------
        特許文書のブロック定義
 * ---------------------------- */

/* 特許文書のタグ名 */
const documentTags = [
    "pat-app-doc",
    "description",
    "claims",
    "abstract",
    "drawings",
    "jp:foreign-language-description",
    "jp:foreign-language-claims",
    "jp:foreign-language-abstract",
    "jp:foreign-language-drawings",
    "pat-rspns",
    "pat-amnd",
    "pat-etc",
    "notice-pat-exam",
    "notice-pat-exam-rn",
] as const;
export type DocumentTag = typeof documentTags[number];

/** 文書ブロックの基本型 */
export interface DocumentBlock {
    tag: DocumentTag;
    jpTag?: string;
    indentLevel?: string;
    text?: string;
    blocks?: Block[];
}

/* 特許願 */
interface PatAppDocBlock extends DocumentBlock {
    tag: 'pat-app-doc';
    blocks: BibliographicBlock[];
}


/* 特許請求の範囲 */
interface ClaimsDocBlock extends DocumentBlock {
    tag: 'claims';
    jpTag: string;
    indentLevel: string;
    blocks: ClaimBlock[];
}

/* 明細書 */
interface DescriptionDocBlock extends DocumentBlock {
    tag: 'description';
    jpTag: string;
    indentLevel: string;
    blocks: DescriptionBlock[];
}

/* 図面 */
export interface DrawingsDocBlock extends DocumentBlock {
    tag: "drawings";
    jpTag: string;
    indentLevel: string;
    blocks: FiguresContainerBlock[];
}

/* 要約書 */
export interface AbstractDocBlock extends DocumentBlock {
    tag: 'abstract';
    jpTag: string;
    indentLevel: string;
    text: string;
}

/** 外国語書面出願：外国語明細書等 */
export interface ForeignDocumentBlock extends DocumentBlock {
    tag: "jp:foreign-language-description" |
    "jp:foreign-language-claims" |
    "jp:foreign-language-abstract" |
    "jp:foreign-language-drawings";
    indentLevel: string;
    blocks: ParagraphBlock[];
}

/* 意見書・弁明書 */
export interface PatResponseBlock extends DocumentBlock {
    tag: "pat-rspns";
    blocks: BibliographicBlock[];
}

/* 補正書 */
export interface PatAmndBlock extends DocumentBlock {
    tag: "pat-amnd";
    blocks: BibliographicBlock[];
}

/* 上申書 */
export interface PatEtcBlock extends DocumentBlock {
    tag: "pat-etc";
    blocks: BibliographicBlock[];
}

/* 特許査定・拒絶査定・拒絶理由通知書 */
export interface isNoticePatExam extends DocumentBlock {
    tag: "notice-pat-exam" | "notice-pat-exam-rn";
    blocks: FigureBlock[];
}

/** 多くのブロックで共通する最小フィールド */
export interface BaseBlock {
    tag: string;
    blocks: Block[];
}

export interface UnknownBlock {
    //tag: Exclude<string, DocumentTag>;
    tag: string;
    [key: string]: unknown;
}


/** -----------------------------
 *  特許請求の範囲（claims） の子ブロック
 * ---------------------------- */

export interface ClaimBlock extends BaseBlock {
    tag: "claim";
    jpTag: string;
    number: string;
    indentLevel: string;
    isIndependent: boolean;
    blocks: ClaimTextBlock[];
}

export interface ClaimTextBlock extends BaseBlock {
    tag: "claim-text";
    blocks: ParagraphItem[];
}

/** -----------------------------
 *  明細書（description） の子ブロック
 * ---------------------------- */
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
    indentLevel: string;
    blocks: ParagraphBlock[];
}

/** 発明の名称 */
export interface InventionTitleBlock extends BaseBlock {
    tag: "invention-title";
    jpTag: string;
    indentLevel: string;
    blocks: InlineText[];
}
export type DescriptionBlock = CommonDescriptionBlock | InventionTitleBlock;



/** -----------------------------
 *  段落関連ブロック
 * ---------------------------- */

export interface ParagraphBlock extends BaseBlock {
    tag: "paragraph";
    jpTag: string
    number: string;
    indentLevel: string;
    blocks: ParagraphItem[];
}

export type ParagraphItem = InlineText | PatcitBlock |
    FigRefBlock | FiguresContainerBlock;

/** インラインテキスト（paragraph 内で出現） */
export interface InlineText extends BaseBlock {
    tag: "text" | "sub" | "sup" | "underline";
    text: string;
    isLastSentence: boolean;
}

/** 先行文献引用（paragraph 内で出現） */
export interface PatcitBlock extends BaseBlock {
    tag: "patcit" | "nplcit";
    jpTag: string;
    number: string;
    text: string;
    indentLevel: string;
}

/** 図参照（paragraph 内で出現） */
export interface FigRefBlock extends BaseBlock {
    tag: "figref";
    jpTag: string;
    number: string;
    text: string;
    indentLevel: string;
}

/** -----------------------------
 *  画像関連ブロック
 * ---------------------------- */

export interface ImageContainerBlock extends BaseBlock {
    tag: "figures" | "tables" | "equations" | "chemical-formulas" | "other-images";
    number?: string;
    jpTag?: string;
    indentLevel: string;
    alt?: string;
    representative?: boolean;
    images: ImageSrcBlock[];
}

export interface FiguresContainerBlock extends ImageContainerBlock {
    tag: "figures";
    number: string;
    jpTag: string;
    indentLevel: string;
    images: ImageSrcBlock[];
}

export interface OtherImagesContainerBlock extends ImageContainerBlock {
    tag: "other-images";
    indentLevel: string;
    images: ImageSrcBlock[];
}

export interface ImageSrcBlock {
    src: string;
    width: number;
    height: number;
    kind: "figures" | "tables" | "equations" | "chemical-formulas" | "other-images" | "unknown";
    sizeTag: "thumbnail" | "middle" | "large";
}

/** -----------------------------
 *  書誌事項関連ブロック
 *  特許願、意見書、補正書、上申書など出願系
 * ---------------------------- */
// jpTag o, convertedText o / jpTag o, text o, convertedText x
// あわせた。renderer は、 convertedText ?? text を使う。
const bibliographicTags1 = [
    "jp:document-code",
    "jp:doc-number",
    "jp:account",
    "jp:fee",
    "jp:document-name",
    "jp:application-reference",
    "jp:article",
    "jp:date",
    "jp:country",
    "jp:application-section",
    "jp:addressed-to-person",
    "jp:file-reference-id",
    "jp:registered-number",
    "jp:name",
    "jp:dispatch-number",
    "jp:ipc",
    "jp:text",
    "jp:general-power-of-attorney-id",
    "jp:original-language-of-name",
    "jp:doc-number",
    "jp:proof-means",
    "jp:citation",
    "jp:dtext",
    "jp:phone",
    "jp:share",
    "jp:share-rate",
    "jp:law-of-industrial-regenerate",
] as const;
type BibliographicItemTags1 = typeof bibliographicTags1[number];
export interface BibliographicBlock1 extends BaseBlock {
    tag: BibliographicItemTags1;
    jpTag: string;
    text: string;
    convertedText?: string;
    indentLevel: string;
}

const bibliographicTags2 = [
    "jp:indication-of-case-article",
    "jp:applicant",
    "jp:agent",
    "jp:attorney",
    "jp:inventor",
    "jp:charge-article",
    "jp:submission-object-list-article",
    "jp:earlier-app",
    "jp:parent-application-article",
    "jp:priority-claim"
] as const;
type BibliographicItemTags2 = typeof bibliographicTags2[number];
export interface BibliographicBlock2 extends BaseBlock {
    tag: BibliographicItemTags2;
    jpTag: string;
    indentLevel: string;
    blocks: BibliographicBlock[];
}

const bibliographicTags3 = [
    "jp:applicants",
    "jp:agents",
    "jp:inventors",
    "jp:attorney-change-article",
    "jp:special-mention-matter-article",
    "jp:declaration-priority-ear-app",
    "jp:priority-claims",
] as const;
type BibliographicItemTags3 = typeof bibliographicTags3[number];
export interface BibliographicBlock3 extends BaseBlock {
    tag: BibliographicItemTags3;
    jpTag: string;
    indentLevel: string;
    blocks: BibliographicBlock[];
}

const bibliographicTags4 = [
    "jp:opinion-contents-article",
] as const;
type BibliographicItemTags4 = typeof bibliographicTags4[number];
export interface BibliographicBlock4 extends BaseBlock {
    tag: BibliographicItemTags4;
    jpTag: string;
    indentLevel: string;
    blocks: ParagraphBlock[];
}

export type BibliographicBlock = BibliographicBlock1 | BibliographicBlock2 | BibliographicBlock3 | BibliographicBlock4;














/***********************************
       型ガード関連 
***********************************/

// --- 型ガードの汎用ファクトリー関数 ---
// K は判定に使うキー、V はその値
function createTypeGuard<T extends object, K extends keyof T>(
    key: K,
    value: T[K]
): (obj: unknown) => obj is T {
    return (obj: unknown): obj is T =>
        typeof obj === 'object' &&
        obj !== null &&
        key in obj &&
        (obj as T)[key] === value;
}

// --- 文書関連の型ガードを生成 ---
export const documentTypeGuards = {
    isPatAppDoc: createTypeGuard<PatAppDocBlock, 'tag'>('tag', 'pat-app-doc'),
    isAbstract: createTypeGuard<AbstractDocBlock, 'tag'>('tag', 'abstract'),
    isDescription: createTypeGuard<DescriptionDocBlock, 'tag'>('tag', 'description'),
    isClaims: createTypeGuard<ClaimsDocBlock, 'tag'>('tag', 'claims'),
    isDrawings: createTypeGuard<DrawingsDocBlock, 'tag'>('tag', 'drawings'),
    isForeignDescription: createTypeGuard<ForeignDocumentBlock, 'tag'>('tag', 'jp:foreign-language-description'),
    isForeignClaims: createTypeGuard<ForeignDocumentBlock, 'tag'>('tag', 'jp:foreign-language-claims'),
    isForeignAbstract: createTypeGuard<ForeignDocumentBlock, 'tag'>('tag', 'jp:foreign-language-abstract'),
    isForeignDrawings: createTypeGuard<ForeignDocumentBlock, 'tag'>('tag', 'jp:foreign-language-drawings'),
    isPatResponse: createTypeGuard<DocumentBlock, 'tag'>('tag', 'pat-rspns'),
    isPatAmendment: createTypeGuard<DocumentBlock, 'tag'>('tag', 'pat-amnd'),
    isPatEtc: createTypeGuard<DocumentBlock, 'tag'>('tag', 'pat-etc'),
    isNoticePatExam: createTypeGuard<DocumentBlock, 'tag'>('tag', 'notice-pat-exam'),
    isNoticePatExamRn: createTypeGuard<DocumentBlock, 'tag'>('tag', 'notice-pat-exam-rn'),
    isUnknownDocumentBlock: (block: unknown): block is UnknownBlock => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }

        return !documentTags.includes((block as any).tag);
    }
}

// --- 明細書関連の型ガードを生成 ---
export const descriptionTypeGuards = {
    isInventionTitle: createTypeGuard<InventionTitleBlock, 'tag'>('tag', 'invention-title'),
    isParagraph: createTypeGuard<ParagraphBlock, 'tag'>('tag', 'paragraph'),
    isCommonDescriptionBlock: (block: unknown): block is CommonDescriptionBlock => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return commonDescriptionTags.includes((block as any).tag);
    },
    isUnknownDescriptionBlock: (block: unknown): block is UnknownBlock => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }

        return ![
            ...commonDescriptionTags,
            "paragraph",
            "invention-title"
        ].includes((block as any).tag);
    }
}

// --- 段落関連の型ガードを生成 ---
export const paragraphItemTypeGuards = {
    isTables: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'tables'),
    isEquations: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'equations'),
    isChemicalFormulas: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'chemical-formulas'),
    isOtherImages: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'other-images'),
    isTextBlock: createTypeGuard<InlineText, 'tag'>('tag', 'text'),
    isSubBlock: createTypeGuard<InlineText, 'tag'>('tag', 'sub'),
    isSupBlock: createTypeGuard<InlineText, 'tag'>('tag', 'sup'),
    isUnderlineBlock: createTypeGuard<InlineText, 'tag'>('tag', 'underline'),
    isFigRefBlock: createTypeGuard<FigRefBlock, 'tag'>('tag', 'figref'),
    isPatcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'patcit'),
    isNplcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'nplcit'),
    isUnknownParagraphItemBlock: (block: unknown): block is UnknownBlock => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }

        return ![
            "text",
            "sub",
            "sup",
            "underline",
            "figref",
            "patcit",
            "nplcit",
            "figures",
            "tables",
            "equations",
            "chemical-formulas",
            "other-images"
        ].includes((block as any).tag);
    }
}

// --- 書誌事項関連の型ガードを生成 ---
export const bibliographicTypeGuards = {
    isBibliographicBlock1: (block: unknown): block is BibliographicBlock1 => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return bibliographicTags1.includes((block as any).tag);
    },
    isBibliographicBlock2: (block: unknown): block is BibliographicBlock2 => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return bibliographicTags2.includes((block as any).tag);
    },
    isBibliographicBlock3: (block: unknown): block is BibliographicBlock3 => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return bibliographicTags3.includes((block as any).tag);
    },
    isBibliographicBlock4: (block: unknown): block is BibliographicBlock4 => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return bibliographicTags4.includes((block as any).tag);
    },
    isUnknownBibliographicBlock: (block: unknown): block is UnknownBlock => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }

        return ![
            ...bibliographicTags1,
            ...bibliographicTags2,
            ...bibliographicTags3,
            ...bibliographicTags4
        ].includes((block as any).tag);
    }
}




/** tag で判別する総称 Block（必要に応じて随時拡張してください） */
export type Block =
    ApplicationFormBlock
    | ApplicationFormItemBlock
    | InventionTitleBlock
    | CommonDescriptionBlock
    | ParagraphBlock
    | ClaimBlock
    | ClaimTextBlock
    | FigRefBlock
    | PatcitBlock
    | PatResponseBlock
    | UnknownBlock;


//export interface ApplicationFormBlock extends BaseBlock {
//    tag: "applicationForm";
//    blocks: ApplicationFormItemBlock[];
//}
//
interface ApplicationFormItemBlock extends BaseBlock {
    tag: string;
    text?: string;
    convertedText?: string;
    blocks: ApplicationFormItemBlock[];
}

