/** text-blocks.json のトップレベル */
export type TextBlocksRoot = Block[];

/** -----------------------------
 *  共通ユーティリティ
 * ---------------------------- */

/** JSON上は "0" や "1" のように文字列になっている */
export type IndentLevelString = string;

/** "0001" / "1" など、数字っぽいが文字列 */
export type NumberString = string;

export interface ContainerBlock {
    tag: string;
    blocks: Block[];
}

/** 多くのブロックで共通する最小フィールド */
export interface BaseBlock extends ContainerBlock {
    jpTag: string;
    indentLevel: IndentLevelString;
    blocks: Block[];
}

/** tag で判別する総称 Block（必要に応じて随時拡張してください） */
export type Block =
    ApplicationFormBlock
    | DescriptionBlock
    | ClaimsBlock
    | AbstractBlock
    | DrawingsBlock
    | ForeignDescriptionBlock
    | ForeignClaimsBlock
    | ForeignAbstractBlock
    | ForeignDrawingsBlock
    | ApplicationFormItemBlock
    | InventionTitleBlock
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
    | "applicationForm"
    | "claims"
    | "abstract"
    | "drawings"
    | "foreign-language-description"
    | "foreign-language-claims"
    | "foreign-language-abstract"
    | "foreign-language-drawings"
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
    | "claim"
    | "claimText"
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
    | "chemistry"
    | "image";

/** -----------------------------
 *  再帰の中心：paragraph / text runs
 * ---------------------------- */

export interface ParagraphBlock extends BaseBlock {
    tag: "paragraph";
    number?: NumberString;
    blocks: Inline[];
}

/** paragraph 内に出てくる inline 要素（text/sub/sup等） */
export type Inline = TextRun | FigRefBlock | PatcitBlock | UnknownBlock;

/** 文章の最小単位：text/sub/sup/underline */
export type TextRun = TextBlock | SubBlock | SupBlock | UnderlineBlock;

export interface TextBlock extends BaseBlock {
    tag: "text";
    text: string;
    isLastSentence: boolean;
}

export interface SubBlock extends BaseBlock {
    tag: "sub";
    text: string;
    isLastSentence: boolean;
}

export interface SupBlock extends BaseBlock {
    tag: "sup";
    text: string;
    isLastSentence: boolean;
}

export interface UnderlineBlock extends BaseBlock {
    tag: "underline";
    text: string;
    isLastSentence: boolean;
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

export interface DescriptionBlock extends BaseBlock {
    tag: "description";
    blocks: Block[];
}

export interface InventionTitleBlock extends BaseBlock {
    tag: "inventionTitle";
    text: string;
}

/** 【技術分野】 */
export interface TechnicalFieldBlock extends BaseBlock {
    tag: "technicalField";
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
    blocks: PatentLiteratureBlock[] | NonPatentLiteratureBlock[];
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

/** 【発明が解決しようとする課題】 */
export interface TechProblemBlock extends BaseBlock {
    tag: "techProblem";
    blocks: ParagraphBlock[];
}

/** 【課題を発明する手段】 */
export interface TechSolutionBlock extends BaseBlock {
    tag: "techSolution";
    blocks: ParagraphBlock[];
}

/** 【発明の効果】 */
export interface AdvantageousEffectsBlock extends BaseBlock {
    tag: "advantageousEffects";
    blocks: ParagraphBlock[];
}

/** 【図面の簡単な説明】 */
export interface DescriptionOfDrawingsBlock extends BaseBlock {
    tag: "descriptionOfDrawings";
    blocks: ParagraphBlock[];
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
    blocks: ClaimBlock[];
}

export interface ClaimBlock extends BaseBlock {
    tag: "claim";
    number: NumberString; // "1" / "2" ...
    isIndependent: boolean;
    blocks: ClaimTextBlock[];
}

export interface ClaimTextBlock extends BaseBlock {
    tag: "claimText";
    blocks: TextRun[];
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
    blocks: FigureBlock[];
}

export interface FigureBlock extends BaseBlock {
    tag: "figure";
    number: NumberString; // "1" / "2" ...
    alt: string;
    representative: boolean;
    images: ImageSrcBlock[];
}

export interface TablesBlock extends BaseBlock {
    tag: "tables";
    number: NumberString; // "1" / "2" ...
    images: ImageSrcBlock[];
}

export interface MathsBlock extends BaseBlock {
    tag: "maths";
    number: NumberString; // "1" / "2" ...
    images: ImageSrcBlock[];
}

export interface ChemistryBlock extends BaseBlock {
    tag: "chemistry";
    number: NumberString; // "1" / "2" ...
    images: ImageSrcBlock[];
}

export interface ImageBlock extends BaseBlock {
    tag: "image";
    number: NumberString; // "1" / "2" ...
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

// 願書は、tag が "jp:~" で始まる。
const isApplicationFormItemBlock = (obj: unknown): obj is ApplicationFormItemBlock => {
    return typeof obj === 'object' &&
        obj !== null &&
        'tag' in obj &&
        typeof (obj as any).tag === 'string' &&
        (obj as any).tag.startsWith('jp:');
};

// --- 各型専用の型ガードを生成 ---
export const checker = {
    isApplicationForm: createTypeGuard<ApplicationFormBlock, 'tag'>('tag', 'applicationForm'),
    isClaims: createTypeGuard<ClaimsBlock, 'tag'>('tag', 'claims'),
    isAbstract: createTypeGuard<AbstractBlock, 'tag'>('tag', 'abstract'),
    isDrawings: createTypeGuard<DrawingsBlock, 'tag'>('tag', 'drawings'),
    isForeignDescription: createTypeGuard<ForeignDescriptionBlock, 'tag'>('tag', 'foreign-language-description'),
    isForeignClaims: createTypeGuard<ForeignClaimsBlock, 'tag'>('tag', 'foreign-language-claims'),
    isForeignAbstract: createTypeGuard<ForeignAbstractBlock, 'tag'>('tag', 'foreign-language-abstract'),
    isForeignDrawings: createTypeGuard<ForeignDrawingsBlock, 'tag'>('tag', 'foreign-language-drawings'),
    isDescription: createTypeGuard<DescriptionBlock, 'tag'>('tag', 'description'),
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
    isClaim: createTypeGuard<ClaimBlock, 'tag'>('tag', 'claim'),
    isClaimText: createTypeGuard<ClaimTextBlock, 'tag'>('tag', 'claimText'),
    isFigure: createTypeGuard<FigureBlock, 'tag'>('tag', 'figure'),
    isTables: createTypeGuard<TablesBlock, 'tag'>('tag', 'tables'),
    isMaths: createTypeGuard<MathsBlock, 'tag'>('tag', 'maths'),
    isChemistry: createTypeGuard<ChemistryBlock, 'tag'>('tag', 'chemistry'),
    isImage: createTypeGuard<ImageBlock, 'tag'>('tag', 'image'),
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
    isApplicationFormItemBlock,
}
