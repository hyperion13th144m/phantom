/** text-blocks.json のトップレベル */
export interface TextBlocksJson {
    blocks: Block[];
}

/** -----------------------------
 *  共通ユーティリティ
 * ---------------------------- */

/** JSON上は "0" や "1" のように文字列になっている */
export type IndentLevelString = string;

/** "0001" / "1" など、数字っぽいが文字列 */
export type NumberString = string;

/** "true"/"false" が文字列で入っている */
export type BoolString = "true" | "false";

/** 多くのブロックで共通する最小フィールド */
export interface BaseBlock {
    tag: string;
    jpTag: string;
    indentLevel: IndentLevelString;
}

/** tag で判別する総称 Block（必要に応じて随時拡張してください） */
export type Block =
    | ApplicationFormBlock
    | DescriptionBlock
    | TechnicalFieldBlock
    | BackgroundArtBlock
    | CitationListBlock
    | SummaryOfInventionBlock
    | DisclosureBlock
    | DescriptionOfDrawingsBlock
    | DescriptionOfEmbodimentsBlock
    | BestModeBlock
    | IndustrialApplicabilityBlock
    | SequenceListTextBlock
    | ReferenceSignsListBlock
    | ReferenceToDepositedBiologicalMaterialBlock
    | ClaimsBlock
    | AbstractBlock
    | DrawingsBlock
    | ParagraphBlock
    | ClaimBlock
    | ClaimTextBlock
    | FigureBlock
    | TablesBlock
    | MathsBlock
    | ChemistryBlock
    | TextRun
    | FigRefBlock
    | PatcitBlock
    | PatentLiteratureBlock
    | NonPatentLiteratureBlock
    | TechProblemBlock
    | TechSolutionBlock
    | AdvantageousEffectsBlock
    | EmbodimentExampleBlock
    | ModeForInventionBlock
    | UnknownBlock;

/** 想定外 tag が来ても落ちないためのフォールバック */
export interface UnknownBlock extends BaseBlock {
    tag: Exclude<string, KnownTag>;
    [key: string]: unknown;
}

/** 既知 tag の集合（必要に応じて増やす） */
export type KnownTag =
    | "application"
    | "description"
    | "inventionTitle"
    | "technicalField"
    | "backgroundArt"
    | "citationList"
    | "patentLiterature"
    | "nonPatentLiterature"
    | "summaryOfInvention"
    | "disclosure"
    | "techProblem"
    | "techSolution"
    | "advantageousEffects"
    | "descriptionOfDrawings"
    | "descriptionOfEmbodiments"
    | "bestMode"
    | "industrialApplicability"
    | "referenceSignsList"
    | "sequenceListText"
    | "referenceToDepositedBiologicalMaterial"
    | "claims"
    | "claim"
    | "claimText"
    | "abstract"
    | "drawings"
    | "paragraph"
    | "text"
    | "sub"
    | "sup"
    | "figref"
    | "patcit"
    | "embodimentExample"
    | "modeForInvention"
    | "figure"
    | "tables"
    | "maths"
    | "chemistry";

/** -----------------------------
 *  再帰の中心：paragraph / text runs
 * ---------------------------- */

export interface ParagraphBlock extends BaseBlock {
    tag: "paragraph";
    jpTag: string;
    number?: NumberString;
    indentLevel: IndentLevelString;
    blocks: InlineOrBlock[];
}

/** paragraph 内に出てくる inline 要素（text/sub/sup等） */
export type InlineOrBlock = TextRun | FigRefBlock | PatcitBlock | UnknownBlock;

/** 文章の最小単位：text/sub/sup/underline */
export type TextRun = TextBlock | SubBlock | SupBlock | UnderlineBlock;

export interface TextBlock extends BaseBlock {
    tag: "text";
    text: string;
    isLastSentence: BoolString; // "true" / "false"
}

export interface SubBlock extends BaseBlock {
    tag: "sub";
    text: string;
    isLastSentence: BoolString; // "true" / "false"
}

export interface SupBlock extends BaseBlock {
    tag: "sup";
    text: string;
    isLastSentence: BoolString; // "true" / "false"
}

export interface UnderlineBlock extends BaseBlock {
    tag: "underline";
    text: string;
    isLastSentence: BoolString; // "true" / "false"
}

/** 図参照（description-of-drawings などで出現） */
export interface FigRefBlock extends BaseBlock {
    tag: "figref";
    number: NumberString; // "1" など
    text: string;
}

/** 先行文献引用（citation-list 内で出現） */
export interface PatcitBlock extends BaseBlock {
    tag: "patcit" | "nplcit";
    number: NumberString; // "1" / "2"
    text: string;
}

/** -----------------------------
 *  特許出願願書系（application 配下）
 * ---------------------------- */
export interface ApplicationFormBlock extends BaseBlock {
    tag: "application";
    text?: string;
    convertedText?: string;
    blocks: Block[];
}

/** -----------------------------
 *  明細書系（description 配下）
 * ---------------------------- */

export interface DescriptionBlock extends BaseBlock {
    tag: "description";
    jpTag: string;
    blocks: Block[];
}

export interface InventionTitleBlock extends BaseBlock {
    tag: "inventionTitle";
    text: string;
    jpTag: string;
}

/** 【技術分野】 */
export interface TechnicalFieldBlock extends BaseBlock {
    tag: "technicalField";
    jpTag: string;
    blocks: ParagraphBlock[];
}

/** 【背景技術】 */
export interface BackgroundArtBlock extends BaseBlock {
    tag: "backgroundArt";
    blocks: ParagraphBlock[];
}

/** 【先行技術文献】 */
export interface CitationListBlock extends BaseBlock {
    tag: "citationList";
    blocks: PatentLiteratureBlock[];
}

/** 【特許文献】 */
export interface PatentLiteratureBlock extends BaseBlock {
    tag: "patentLiterature";
    blocks: ParagraphBlock[];
}

/** 【非特許文献】 */
export interface NonPatentLiteratureBlock extends BaseBlock {
    tag: "nonPatentLiterature";
    blocks: ParagraphBlock[];
}

/** 【発明の概要】 */
export interface SummaryOfInventionBlock extends BaseBlock {
    tag: "summaryOfInvention";
    blocks: (TechProblemBlock | TechSolutionBlock | AdvantageousEffectsBlock | UnknownBlock)[];
}

/** 【発明の開示】 */
export interface DisclosureBlock extends BaseBlock {
    tag: "disclosure";
    blocks: (TechProblemBlock | TechSolutionBlock | AdvantageousEffectsBlock | UnknownBlock)[];
}

export interface TechProblemBlock extends BaseBlock {
    tag: "techProblem";
    blocks: ParagraphBlock[];
}

export interface TechSolutionBlock extends BaseBlock {
    tag: "techSolution";
    blocks: ParagraphBlock[];
}

export interface AdvantageousEffectsBlock extends BaseBlock {
    tag: "advantageousEffects";
    blocks: ParagraphBlock[];
}

/** 【図面の簡単な説明】 */
export interface DescriptionOfDrawingsBlock extends BaseBlock {
    tag: "descriptionOfDrawings";
    blocks: ParagraphBlock[]; // paragraph 内に figref が入る
}

/** 【発明を実施するための形態】 */
export interface DescriptionOfEmbodimentsBlock extends BaseBlock {
    tag: "descriptionOfEmbodiments";
    blocks: (ParagraphBlock | EmbodimentExampleBlock | ModeForInventionBlock | UnknownBlock)[];
}

/** 【発明を実施するための最良の形態】 */
export interface BestModeBlock extends BaseBlock {
    tag: "bestMode";
    blocks: (ParagraphBlock | EmbodimentExampleBlock | ModeForInventionBlock | UnknownBlock)[];
}

/** 【実施例】 */
export interface EmbodimentExampleBlock extends BaseBlock {
    tag: "embodimentExample";
    number: NumberString; // "1" / "2"
    blocks: ParagraphBlock[];
}

/** 【実施例】 */
export interface ModeForInventionBlock extends BaseBlock {
    tag: "modeForInvention";
    number: NumberString; // "1" / "2"
    blocks: ParagraphBlock[];
}

/** 【産業上の利用可能性】 */
export interface IndustrialApplicabilityBlock extends BaseBlock {
    tag: "industrialApplicability";
    blocks: ParagraphBlock[];
}

/** 【符号の説明】 */
export interface ReferenceSignsListBlock extends BaseBlock {
    tag: "referenceSignsList";
    blocks: ParagraphBlock[];
}

/** 【配列表】 */
export interface SequenceListTextBlock extends BaseBlock {
    tag: "sequenceListText";
    blocks: ParagraphBlock[];
}

/** 【受託番号】 */
export interface ReferenceToDepositedBiologicalMaterialBlock extends BaseBlock {
    tag: "referenceToDepositedBiologicalMaterial";
    blocks: ParagraphBlock[];
}

/** -----------------------------
 *  特許請求の範囲（claims）
 * ---------------------------- */

export interface ClaimsBlock extends BaseBlock {
    tag: "claims";
    jpTag: string;
    indentLevel: IndentLevelString;
    blocks: ClaimBlock[];
}

export interface ClaimBlock extends BaseBlock {
    tag: "claim";
    jpTag: string;
    number: NumberString; // "1" / "2" ...
    indentLevel: IndentLevelString;
    isIndependent: BoolString; // "true" / "false"
    blocks: ClaimTextBlock[];
}

export interface ClaimTextBlock extends BaseBlock {
    tag: "claimText";

    blocks: TextRun[]; // 現状は text のみ
}

/** -----------------------------
 *  要約書（abstract）
 * ---------------------------- */

export interface AbstractBlock extends BaseBlock {
    tag: "abstract";
    text: string;
}

/** -----------------------------
 *  図面（drawings）
 * ---------------------------- */

export interface DrawingsBlock extends BaseBlock {
    tag: "drawings";
    jpTag: string;
    indentLevel: IndentLevelString;
    blocks: FigureBlock[];
}

export interface FigureBlock extends BaseBlock {
    tag: "figure";
    jpTag: string;
    number: NumberString; // "1" / "2" ...
    alt: string;
    representative: BoolString; // "false" など
    images: FigureImage[];
}

export interface FigureImage {
    src: string;
    width: NumberString;  // "300" など
    height: NumberString; // "300" など
    kind: "figure" | string;
    sizeTag: "thumbnail" | "middle" | "large" | string;
}

export interface TablesBlock extends BaseBlock {
    tag: "tables";
    jpTag: string;
    number: NumberString; // "1" / "2" ...
    images: FigureImage[];
}

export interface MathsBlock extends BaseBlock {
    tag: "maths";
    jpTag: string;
    number: NumberString; // "1" / "2" ...
    images: FigureImage[];
}

export interface ChemistryBlock extends BaseBlock {
    tag: "chemistry";
    jpTag: string;
    number: NumberString; // "1" / "2" ...
    images: FigureImage[];
}

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

// --- 各型専用の型ガードを生成 ---
export const checker = {
    isInventionTitle: createTypeGuard<InventionTitleBlock, 'tag'>('tag', 'inventionTitle'),
    isTechnicalField: createTypeGuard<TechnicalFieldBlock, 'tag'>('tag', 'technicalField'),
    isBackgroundArt: createTypeGuard<BackgroundArtBlock, 'tag'>('tag', 'backgroundArt'),
    isCitationList: createTypeGuard<CitationListBlock, 'tag'>('tag', 'citationList'),
    isPatentLiterature: createTypeGuard<PatentLiteratureBlock, 'tag'>('tag', 'patentLiterature'),
    isNonPatentLiterature: createTypeGuard<NonPatentLiteratureBlock, 'tag'>('tag', 'nonPatentLiterature'),
    isSummaryOfInvention: createTypeGuard<SummaryOfInventionBlock, 'tag'>('tag', 'summaryOfInvention'),
    isTechProblem: createTypeGuard<TechProblemBlock, 'tag'>('tag', 'techProblem'),
    isTechSolution: createTypeGuard<TechSolutionBlock, 'tag'>('tag', 'techSolution'),
    isAdvantageousEffects: createTypeGuard<AdvantageousEffectsBlock, 'tag'>('tag', 'advantageousEffects'),
    isDescriptionOfDrawings: createTypeGuard<DescriptionOfDrawingsBlock, 'tag'>('tag', 'descriptionOfDrawings'),
    isDescriptionOfEmbodiments: createTypeGuard<DescriptionOfEmbodimentsBlock, 'tag'>('tag', 'descriptionOfEmbodiments'),
    isBestMode: createTypeGuard<BestModeBlock, 'tag'>('tag', 'bestMode'),
    isIndustrialApplicability: createTypeGuard<IndustrialApplicabilityBlock, 'tag'>('tag', 'industrialApplicability'),
    isClaims: createTypeGuard<ClaimsBlock, 'tag'>('tag', 'claims'),
    isClaim: createTypeGuard<ClaimBlock, 'tag'>('tag', 'claim'),
    isClaimText: createTypeGuard<ClaimTextBlock, 'tag'>('tag', 'claimText'),
    isAbstract: createTypeGuard<AbstractBlock, 'tag'>('tag', 'abstract'),
    isDrawings: createTypeGuard<DrawingsBlock, 'tag'>('tag', 'drawings'),
    isFigure: createTypeGuard<FigureBlock, 'tag'>('tag', 'figure'),
    isTables: createTypeGuard<TablesBlock, 'tag'>('tag', 'tables'),
    isMaths: createTypeGuard<MathsBlock, 'tag'>('tag', 'maths'),
    isChemistry: createTypeGuard<ChemistryBlock, 'tag'>('tag', 'chemistry'),
    isParagraph: createTypeGuard<ParagraphBlock, 'tag'>('tag', 'paragraph'),
    isTextBlock: createTypeGuard<TextBlock, 'tag'>('tag', 'text'),
    isSubBlock: createTypeGuard<SubBlock, 'tag'>('tag', 'sub'),
    isSupBlock: createTypeGuard<SupBlock, 'tag'>('tag', 'sup'),
    isUnderlineBlock: createTypeGuard<UnderlineBlock, 'tag'>('tag', 'underline'),
    isFigRefBlock: createTypeGuard<FigRefBlock, 'tag'>('tag', 'figref'),
    isPatcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'patcit'),
    isNplcitBlock: createTypeGuard<PatcitBlock, 'tag'>('tag', 'nplcit'),
    isEmbodimentExample: createTypeGuard<EmbodimentExampleBlock, 'tag'>('tag', 'embodimentExample'),
    isModeForInvention: createTypeGuard<ModeForInventionBlock, 'tag'>('tag', 'modeForInvention'),
    isSequenceListText: createTypeGuard<SequenceListTextBlock, 'tag'>('tag', 'sequenceListText'),
    isReferenceSignsList: createTypeGuard<ReferenceSignsListBlock, 'tag'>('tag', 'referenceSignsList'),
    isReferenceToDepositedBiologicalMaterial: createTypeGuard<ReferenceToDepositedBiologicalMaterialBlock, 'tag'>('tag', 'referenceToDepositedBiologicalMaterial'),
    isDisclosure: createTypeGuard<DisclosureBlock, 'tag'>('tag', 'disclosure'),
}
