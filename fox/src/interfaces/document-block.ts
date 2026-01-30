/** text-blocks.json のトップレベル */
export type Block = DocumentBlock[];
export type DocumentBlock = PatAppDocBlock | ClaimsDocBlock |
    DescriptionDocBlock | DrawingsDocBlock | AbstractDocBlock |
    ForeignDocumentBlock |
    NoticePatExamBlock |
    PatResponseBlock | PatAmndBlock | PatEtcBlock;

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

/* 特許願 */
interface PatAppDocBlock {
    tag: 'pat-app-doc';
    blocks: BibliographicBlock[];
}

/* 特許請求の範囲 */
interface ClaimsDocBlock {
    tag: 'claims';
    jpTag: string;
    indentLevel: string;
    blocks: ClaimBlock[];
}

/* 明細書 */
interface DescriptionDocBlock {
    tag: 'description';
    jpTag: string;
    indentLevel: string;
    blocks: DescriptionBlock[];
}

/* 図面 */
export interface DrawingsDocBlock {
    tag: "drawings";
    jpTag: string;
    indentLevel: string;
    blocks: FiguresContainerBlock[];
}

/* 要約書 */
export interface AbstractDocBlock {
    tag: 'abstract';
    jpTag: string;
    indentLevel: string;
    text: string;
}

/** 外国語書面出願：外国語明細書等 */
export interface ForeignDocumentBlock {
    tag: "jp:foreign-language-description" |
    "jp:foreign-language-claims" |
    "jp:foreign-language-abstract" |
    "jp:foreign-language-drawings";
    indentLevel: string;
    blocks: ParagraphBlock[];
}

/* 意見書・弁明書 */
export interface PatResponseBlock {
    tag: "pat-rspns";
    blocks: BibliographicBlock[];
}

/* 補正書 */
export interface PatAmndBlock {
    tag: "pat-amnd";
    blocks: BibliographicBlock[];
}

/* 上申書 */
export interface PatEtcBlock {
    tag: "pat-etc";
    blocks: BibliographicBlock[];
}

/* 特許査定・拒絶査定・拒絶理由通知書 */
export interface NoticePatExamBlock {
    tag: "notice-pat-exam" | "notice-pat-exam-rn";
    blocks: NoticeBibliographicBlock[];
}

export interface UnknownBlock {
    tag: string;
    [key: string]: unknown;
}


/** -----------------------------
 *  特許請求の範囲（claims） の子ブロック
 * ---------------------------- */

export interface ClaimBlock {
    tag: "claim";
    jpTag: string;
    number: string;
    indentLevel: string;
    isIndependent: boolean;
    blocks: ClaimTextBlock[];
}

export interface ClaimTextBlock {
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
export interface CommonDescriptionBlock {
    tag: CommonDescriptionTag;
    jpTag: string;
    indentLevel: string;
    blocks: ParagraphBlock[];
}

/** 発明の名称 */
export interface InventionTitleBlock {
    tag: "invention-title";
    jpTag: string;
    indentLevel: string;
    blocks: InlineText[];
}
export type DescriptionBlock = CommonDescriptionBlock | InventionTitleBlock;



/** -----------------------------
 *  段落関連ブロック
 * ---------------------------- */

export interface ParagraphBlock {
    tag: "paragraph";
    jpTag: string
    number: string;
    indentLevel: string;
    blocks: ParagraphItem[];
}

export type ParagraphItem = InlineText | PatcitBlock |
    FigRefBlock | ImageContainerBlock;

/** インラインテキスト（paragraph 内で出現） */
export interface InlineText {
    tag: "text" | "sub" | "sup" | "underline";
    text: string;
    isLastSentence: boolean;
}

/** 先行文献引用（paragraph 内で出現） */
export interface PatcitBlock {
    tag: "patcit" | "nplcit";
    jpTag: string;
    number: string;
    text: string;
    indentLevel: string;
}

/** 図参照（paragraph 内で出現） */
export interface FigRefBlock {
    tag: "figref";
    jpTag: string;
    number: string;
    text: string;
    indentLevel: string;
}

/** -----------------------------
 *  画像関連ブロック
 * ---------------------------- */

export interface ImageContainerBlock {
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
    "jp:account",
    "jp:account-number", // 実データないためレンダリング結果は確認していない. 以下 X は同じいみ
    "jp:account-type",   // X
    "jp:addressed-to-person",
    "jp:application-section",
    "jp:article",
    "jp:citation",
    "jp:country",
    "jp:date",
    "jp:dispatch-number",
    "jp:doc-number",
    "jp:document-code",
    "jp:document-name",
    "jp:dtext",
    "jp:fee",
    "jp:file-reference-id",
    "jp:general-power-of-attorney-id",
    "jp:generated-access-code",
    "jp:ipc",
    "jp:ip-type",
    "jp:item-of-amendment",
    "jp:kind-of-accelerated-examination", // X
    "jp:kind-of-appeals", // X
    "jp:law-of-industrial-regenerate",
    "jp:name",
    "jp:name-of-new-depository", // X
    "jp:new-depository-number", // X
    "jp:num-claim-increase-amendment",
    "jp:notice-contents-group",
    "jp:office", // X
    "jp:office-address", // X
    "jp:office-in-japan", // X
    "jp:old-depository-number", // X   "jp:original-language-of-name",
    "jp:original-language-of-address",
    "jp:original-language-of-name",
    "jp:payment-years", // X
    "jp:phone",
    "jp:proof-means",
    "jp:registered-number",
    "jp:relation-attorney-special-matter", // X
    "jp:relation-of-case", // X
    "jp:representative-applicant", // X
    "jp:share",
    "jp:share-rate",
    "jp:text",
    "jp:way-of-amendment",
    "shutugan-kubun", // X
] as const;
type BibliographicItemTags1 = typeof bibliographicTags1[number];
export interface BibliographicBlock1 {
    tag: BibliographicItemTags1;
    jpTag: string;
    text: string;
    convertedText?: string;
    indentLevel: string;
}

const bibliographicTags2 = [
    "jp:agent",
    "jp:amendment-charge-article",
    "jp:amendment-group",
    "jp:appeal-article", // X
    "jp:applicant",
    "jp:attorney",
    "jp:charge-article",
    "jp:contents-of-amendment",
    "jp:earlier-app",
    "jp:indication-of-case-article",
    "jp:inventor",
    "jp:lawyer", // X
    "jp:parent-application-article",
    "jp:priority-claim",
    "jp:rejection-case-accept-notice-art", // X
    "jp:submission-object-list-article",
    // 補正対象としての明細書・請求の範囲の項目名を追加
    "claims",
] as const;
type BibliographicItemTags2 = typeof bibliographicTags2[number];
export interface BibliographicBlock2 {
    tag: BibliographicItemTags2;
    jpTag: string;
    indentLevel: string;
    blocks: BibliographicBlock[];
}

const bibliographicTags3 = [
    "jp:agents",
    "jp:amendment-article",
    "jp:applicants",
    "jp:application-reference",
    "jp:approval-column-article", // X
    "jp:attorney-change-article",
    "jp:declaration-priority-ear-app",
    "jp:priority-doc-location-info",
    "jp:inventors",
    "jp:list-group",
    "jp:nationality",
    "jp:payment",
    "jp:priority-claims",
    "jp:representative-group", // X
    "jp:special-mention-matter-article",
] as const;
type BibliographicItemTags3 = typeof bibliographicTags3[number];
export interface BibliographicBlock3 {
    tag: BibliographicItemTags3;
    blocks: BibliographicBlock[];
}

const bibliographicTags4 = [
    "jp:opinion-contents-article",
] as const;
type BibliographicItemTags4 = typeof bibliographicTags4[number];
export interface BibliographicBlock4 {
    tag: BibliographicItemTags4;
    jpTag: string;
    indentLevel: string;
    blocks: ParagraphBlock[];
}

const bibliographicTags5 = [
    "jp:item-content",
] as const;
type BibliographicItemTags5 = typeof bibliographicTags5[number];
export interface BibliographicBlocks5 {
    tag: BibliographicItemTags5;
    text: string;
}

export interface AmendmentClaimBlock {
    tag: "claim";
    jpTag: string;
    number: string;
    indentLevel: string;
    isIndependent: boolean;
    blocks: ClaimTextBlock[];
}

export interface AmendmentClaimTextBlock {
    tag: "claim-text";
    blocks: ParagraphItem[];
}
export type BibliographicBlock = BibliographicBlock1 | BibliographicBlock2 | BibliographicBlock3 | BibliographicBlock4 | BibliographicBlocks5 | ParagraphBlock | AmendmentClaimBlock;


/** -----------------------------
 *  書誌事項関連ブロック
 *  拒絶理由通知、拒絶査定、特許査定など発送系
 * ---------------------------- */
// jpTag o, convertedText o / jpTag o, text o, convertedText x
// あわせた。renderer は、 convertedText ?? text を使う。
const noticeBibliographicTags1 = [
    "invention-title",
    "jp:addressed-to-person-group",
    "jp:application-section",
    "jp:change-flag-invention-title",
    "jp:date",
    "jp:depository-ins-code",
    "jp:depository-number",
    "jp:doc-number",
    "jp:document-number",
    "jp:exceptions-to-lack-of-novelty",
    "jp:exist-of-reference-doc",
    "jp:fi",
    "jp:field-of-search",
    "jp:kind-of-application",
    "jp:number-of-claim",
    "jp:number-of-other-persons", // X
    "jp:patent-law-section30",
    "jp:patent-reference-group",
    "jp:payment-years", // X
    "jp:version-number", // X
] as const;
type NoticeBibliographicItemTags1 = typeof noticeBibliographicTags1[number];
export interface NoticeBibliographicBlock1 {
    tag: NoticeBibliographicItemTags1;
    jpTag: string;
    text: string;
    convertedText?: string;
    indentLevel: string;
}

const noticeBibliographicTags2 = [
    "jp:classification-article", // X
    "jp:contents-name", // X
    "jp:deposit",
    "jp:deposit-article",
    "jp:exceptions-to-lack-of-novelty-art",
    "jp:exceptions-to-lack-of-novelty-grp",
    "jp:fi-article",
    "jp:field-of-search-article",
    "jp:indication-of-case-article",
    "jp:invention-contents-article", // X
    "jp:ipc-article",
    "jp:patent-reference-article",
    "jp:reference-books-article",
    "jp:remark", // X 
] as const;
type NoticeBibliographicItemTags2 = typeof noticeBibliographicTags2[number];
export interface NoticeBibliographicBlock2 {
    tag: NoticeBibliographicItemTags2;
    jpTag: string;
    indentLevel: string;
    blocks?: BibliographicBlock[];
}

const noticeBibliographicTags3 = [
    "jp:application-reference",
    "jp:certification-column-article",
    "jp:certification-column-group",
    "jp:contents-part-article", // X
    "jp:document-id",
    "jp:drafting-date",
    "jp:final-decision-bibliog",
    "jp:final-decision-bibliog-rn",
    "jp:final-decision-body",
    "jp:final-decision-body-rn",
    "jp:final-decision-group",
    "jp:final-decision-group-rn",
    "jp:final-decision-memo",
    "jp:final-decision-memo-rn",
    "jp:heading", // X
    "jp:image-group",
    "jp:inquiry-article", // X
    "jp:inquiry-staff-group", // X
] as const;
type NoticeBibliographicItemTags3 = typeof noticeBibliographicTags3[number];
export interface NoticeBibliographicBlock3 {
    tag: NoticeBibliographicItemTags3;
    blocks: BibliographicBlock[];
}

const noticeBibliographicTags4 = [
    "jp:bibliog-in-ntc-pat-exam",
    "jp:bibliog-in-ntc-pat-exam-rn",
] as const;
type NoticeBibliographicItemTags4 = typeof noticeBibliographicTags4[number];

interface NoticeBibliographicBlock4 {
    tag: NoticeBibliographicItemTags4;
    blocks: BibliographicBlock[];
}

const noticeBibliographicTags5 = [
    "jp:conclusion-part-article",
    "jp:drafting-body",
] as const;
type NoticeBibliographicItemTags5 = typeof noticeBibliographicTags5[number];
export interface NoticeBibliographicBlock5 {
    tag: NoticeBibliographicItemTags5;
    blocks?: ParagraphBlock[];
}

const noticeBibliographicTags6 = [
    "jp:reconsideration-before-appeal",
    "jp:reference-books",
] as const;
type NoticeBibliographicItemTags6 = typeof noticeBibliographicTags6[number];
export interface NoticeBibliographicBlock6 {
    tag: NoticeBibliographicItemTags6;
    text: string;
}

interface NoticeDispatchControlArticleBlock {
    tag: "jp:dispatch-control-article";
    blocks: {
        tag: string;
        jpTag: string;
        text: string;
    }[];
}

interface NoticeDocumentNameBlock {
    tag: "jp:document-name";
    text: string;
}


interface NoticeFooterArticleBlock {
    tag: "jp:footer-article";
    blocks?: NoticeBibliographicBlock[];
}

interface NoticeCertificationGroupBlock {
    tag: "jp:certification-group";
    blocks: {
        tag: "jp:date" | "jp:official-title" | "jp:name";
        jpTag?: string;
        text: string;
        convertedText?: string;
    }[];
}

/* 実データがないので、jp:certification-group と同様の構造、レンダリングと仮定 */
interface NoticeInquiryStaffGroupBlock {
    tag: "jp:inquiry-staff-group";
    blocks: {
        tag: "jp:division" | "jp:name";
        text: string;
    }[];
}

interface NoticeDraftPersonGroupBlock {
    tag: "jp:draft-person-group";
    jpTag: string;
    blocks: {
        tag: "jp:name" | "jp:staff-code" | "jp:office-code";
        text: string;
        convertedText?: string;
    }[];
}

interface NoticeArticleGroupBlock {
    tag: "jp:article-group";
    jpTag: string;
    blocks: {
        tag: "jp:article";
        text: string;
    }[];
}

interface NoticeParentApplicationArticleBlock {
    tag: "jp:parent-application-article";
    jpTag: string;
    text?: string;
    blocks?: NoticeBibliographicBlock[];
}


/* 実データがないので、jp:certification-group と同様の構造、レンダリングと仮定 */
interface NoticeInclusionPaymentGroupBlock {
    tag: "jp:inclusion-payment-group";
    text: string;
    blocks: NoticeBibliographicBlock[];
}

export type NoticeBibliographicBlock = NoticeBibliographicBlock1 | NoticeBibliographicBlock2 |
    NoticeBibliographicBlock3 | NoticeBibliographicBlock4 | NoticeBibliographicBlock5 |
    NoticeBibliographicBlock6 |
    NoticeDispatchControlArticleBlock | NoticeDocumentNameBlock | NoticeFooterArticleBlock |
    NoticeDraftPersonGroupBlock | NoticeCertificationGroupBlock | NoticeInquiryStaffGroupBlock |
    NoticeArticleGroupBlock | NoticeInclusionPaymentGroupBlock |
    NoticeParentApplicationArticleBlock |
    ParagraphBlock | OtherImagesContainerBlock;



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

// タグのリストに基づいて型ガードを作成するヘルパー関数
function createTypeGuardWithTags<T>(tags: readonly string[]) {
    return (block: unknown): block is T => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return tags.includes((block as any).tag);
    };
}

// タグのリストに基づいて型ガードを作成するヘルパー関数
function createUnknownBlockWithTags<T>(tags: readonly string[]) {
    return (block: unknown): block is T => {
        if (
            typeof block !== "object" ||
            block === null ||
            !("tag" in block) ||
            typeof (block as any).tag !== "string"
        ) {
            return false;
        }
        return !tags.includes((block as any).tag);
    };
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
    isPatResponse: createTypeGuard<PatResponseBlock, 'tag'>('tag', 'pat-rspns'),
    isPatAmnd: createTypeGuard<PatAmndBlock, 'tag'>('tag', 'pat-amnd'),
    isPatEtc: createTypeGuard<PatEtcBlock, 'tag'>('tag', 'pat-etc'),
    isNoticePatExam: createTypeGuard<NoticePatExamBlock, 'tag'>('tag', 'notice-pat-exam'),
    isNoticePatExamRn: createTypeGuard<NoticePatExamBlock, 'tag'>('tag', 'notice-pat-exam-rn'),
    isUnknownDocumentBlock: createUnknownBlockWithTags<UnknownBlock>(documentTags),
}

// --- 明細書関連の型ガードを生成 ---
export const descriptionTypeGuards = {
    isInventionTitle: createTypeGuard<InventionTitleBlock, 'tag'>('tag', 'invention-title'),
    isParagraph: createTypeGuard<ParagraphBlock, 'tag'>('tag', 'paragraph'),
    isCommonDescriptionBlock: createTypeGuardWithTags<CommonDescriptionBlock>(commonDescriptionTags),
    isUnknownDescriptionBlock: createUnknownBlockWithTags<UnknownBlock>([
        ...commonDescriptionTags,
        "paragraph",
        "invention-title"
    ]),
}

// --- 段落関連の型ガードを生成 ---
export const paragraphItemTypeGuards = {
    isTables: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'tables'),
    isEquations: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'equations'),
    isChemicalFormulas: createTypeGuard<ImageContainerBlock, 'tag'>('tag', 'chemical-formulas'),
    isOtherImages: createTypeGuard<OtherImagesContainerBlock, 'tag'>('tag', 'other-images'),
    isTextBlock: createTypeGuard<InlineText, 'tag'>('tag', 'text'),
    isSubBlock: createTypeGuard<InlineText, 'tag'>('tag', 'sub'),
    isSupBlock: createTypeGuard<InlineText, 'tag'>('tag', 'sup'),
    isUnderlineBlock: createTypeGuard<InlineText, 'tag'>('tag', 'underline'),
    isFigRefBlock: createTypeGuard<FigRefBlock, 'tag'>('tag', 'figref'),
    isPatcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'patcit'),
    isNplcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'nplcit'),
    isUnknownParagraphItemBlock: createUnknownBlockWithTags<UnknownBlock>([
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
    ]),
}

// --- 書誌事項関連の型ガードを生成 ---
export const bibliographicTypeGuards = {
    isBibliographicBlock1: createTypeGuardWithTags<BibliographicBlock1>(bibliographicTags1),
    isBibliographicBlock2: createTypeGuardWithTags<BibliographicBlock2>(bibliographicTags2),
    isBibliographicBlock3: createTypeGuardWithTags<BibliographicBlock3>(bibliographicTags3),
    isBibliographicBlock4: createTypeGuardWithTags<BibliographicBlock4>(bibliographicTags4),
    isBibliographicBlock5: createTypeGuardWithTags<BibliographicBlocks5>(bibliographicTags5),
    isParagraph: createTypeGuard<ParagraphBlock, 'tag'>('tag', 'paragraph'),
    isAmendmentClaimBlock: createTypeGuard<AmendmentClaimBlock, 'tag'>('tag', 'claim'),
    isUnknownBibliographicBlock: createUnknownBlockWithTags<UnknownBlock>([
        "paragraph",
        "claim",
        ...bibliographicTags1,
        ...bibliographicTags2,
        ...bibliographicTags3,
        ...bibliographicTags4,
        ...bibliographicTags5
    ]),
}

// --- 発送系 書誌事項関連の型ガードを生成 ---
export const noticeBibliographicTypeGuards = {
    isNoticeDispatchControlArticleBlock: createTypeGuard<NoticeDispatchControlArticleBlock, 'tag'>('tag', 'jp:dispatch-control-article'),
    isNoticeDocumentNameBlock: createTypeGuard<NoticeDocumentNameBlock, 'tag'>('tag', 'jp:document-name'),
    isNoticeFooterArticleBlock: createTypeGuard<NoticeFooterArticleBlock, 'tag'>('tag', 'jp:footer-article'),
    isNoticeCertificationGroupBlock: createTypeGuard<NoticeCertificationGroupBlock, 'tag'>('tag', 'jp:certification-group'),
    isNoticeInquiryStaffGroupBlock: createTypeGuard<NoticeInquiryStaffGroupBlock, 'tag'>('tag', 'jp:inquiry-staff-group'),
    isNoticeDraftPersonGroupBlock: createTypeGuard<NoticeDraftPersonGroupBlock, 'tag'>('tag', 'jp:draft-person-group'),
    isNoticeArticleGroupBlock: createTypeGuard<NoticeArticleGroupBlock, 'tag'>('tag', 'jp:article-group'),
    isNoticeParentApplicationArticleBlock: createTypeGuard<NoticeParentApplicationArticleBlock, 'tag'>('tag', 'jp:parent-application-article'),
    isNoticeInclusionPaymentGroupBlock: createTypeGuard<NoticeInclusionPaymentGroupBlock, 'tag'>('tag', 'jp:inclusion-payment-group'),
    isNoticeBibliographicBlock1: createTypeGuardWithTags<NoticeBibliographicBlock1>(noticeBibliographicTags1),
    isNoticeBibliographicBlock2: createTypeGuardWithTags<NoticeBibliographicBlock2>(noticeBibliographicTags2),
    isNoticeBibliographicBlock3: createTypeGuardWithTags<NoticeBibliographicBlock3>(noticeBibliographicTags3),
    isNoticeBibliographicBlock4: createTypeGuardWithTags<NoticeBibliographicBlock4>(noticeBibliographicTags4),
    isNoticeBibliographicBlock5: createTypeGuardWithTags<NoticeBibliographicBlock5>(noticeBibliographicTags5),
    isNoticeBibliographicBlock6: createTypeGuardWithTags<NoticeBibliographicBlock6>(noticeBibliographicTags6),
    isUnknownNoticeBibliographicBlock: createUnknownBlockWithTags<UnknownBlock>([
        "jp:dispatch-control-article",
        "jp:document-name",
        "jp:certification-group",
        "jp:footer-article",
        "jp:draft-person-group",
        "jp:article-group",
        "jp:parent-application-article",
        "paragraph",
        "other-images",
        "jp:inclusion-payment-group", // X
        "jp:inquiry-staff-group", // X
        // paragraphItem の other-images を流用した。ゆえに、ここに追加しておく。
        // 本来的には jp:image-group の子要素(type NoticeBibliographicBlock)として
        //  other-images のinterface を作成すべき.
        ...noticeBibliographicTags1,
        ...noticeBibliographicTags2,
        ...noticeBibliographicTags3,
        ...noticeBibliographicTags4,
        ...noticeBibliographicTags5,
        ...noticeBibliographicTags6
    ]),
}
