import { paragraphItemTypeGuards, type Block } from "~/interfaces/document-block";

// ClaimText や Paragraph 下の連続する textBlock, subBlock, supBlock, underlineBlock をまとめる
// Paragraph 下のそれ以外のブロックは個別に扱う
export function concatBlocks(blocks: Block[]): Block[][] {
    const results = [];
    let currentGroup = [];
    for (let i = 0; i < blocks.length; i++) {
        const currentBlock = blocks[i];
        if (
            paragraphItemTypeGuards.isTextBlock(currentBlock) ||
            paragraphItemTypeGuards.isSubBlock(currentBlock) ||
            paragraphItemTypeGuards.isSupBlock(currentBlock) ||
            paragraphItemTypeGuards.isUnderlineBlock(currentBlock)
        ) {
            currentGroup.push(currentBlock);
            if (currentBlock.isLastSentence === true) {
                results.push(currentGroup);
                currentGroup = [];
            }
        } else {
            // その他のブロックは現在のグループを終了させてから追加
            if (currentGroup.length > 0) {
                results.push(currentGroup);
                currentGroup = [];
            }
            results.push([currentBlock]);
        }
    }
    return results;
}