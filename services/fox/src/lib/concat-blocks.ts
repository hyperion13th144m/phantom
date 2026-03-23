export const concatBlocks = (
    blocks: any[],
    condition: (block: any) => boolean,
): any[][] => {
    const result: any[][] = [];
    let currentGroup: any[] = [];
    blocks.forEach((block) => {
        if (condition(block)) {
            if (currentGroup.length > 0) {
                currentGroup.push(block);
                result.push(currentGroup);
                currentGroup = [];
            } else {
                result.push([block]);
            }
        } else {
            currentGroup.push(block);
        }
    });
    if (currentGroup.length > 0) {
        result.push(currentGroup);
    }
    return result;
};
