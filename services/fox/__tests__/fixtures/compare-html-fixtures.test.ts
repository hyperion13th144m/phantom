import * as cheerio from 'cheerio';
import fs from 'node:fs/promises';
import path from 'node:path';
import { describe, expect, it } from 'vitest';

type HtmlPair = {
    expectedPath: string;
    htmlPath: string;
};

const findHtmlPairs = async (rootDir: string): Promise<HtmlPair[]> => {
    const pairs: HtmlPair[] = [];
    const entries = await fs.readdir(rootDir, { withFileTypes: true });

    for (const entry of entries) {
        if (!entry.isDirectory()) {
            continue;
        }

        const fixtureDir = path.join(rootDir, entry.name);
        const expectedPath = path.join(fixtureDir, 'expected-html', 'document.html');
        const htmlPath = path.join(fixtureDir, 'html', 'document.html');

        try {
            await fs.access(expectedPath);
            await fs.access(htmlPath);
            pairs.push({ expectedPath, htmlPath });
        } catch {
            // 両ファイルが無い場合はスキップ
        }
    }

    return pairs;
};

const walkForFixtures = async (rootDir: string): Promise<HtmlPair[]> => {
    const pairs: HtmlPair[] = [];

    const walk = async (currentDir: string) => {
        const entries = await fs.readdir(currentDir, { withFileTypes: true });

        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            if (entry.isDirectory()) {
                const subPairs = await findHtmlPairs(fullPath);
                pairs.push(...subPairs);
                await walk(fullPath);
            }
        }
    };

    await walk(rootDir);
    return pairs;
};

interface ElementInfo {
    tag: string;
    className?: string;
    text: string;
    children: ElementInfo[];
}

const serializeElement = ($: cheerio.CheerioAPI, el: cheerio.Element): ElementInfo => {
    const $el = $(el);
    const tag = el.name;
    const className = $el.attr('class');
    const text = $el
        .contents()
        .filter(function () {
            return this.type === 'text';
        })
        .text()
        .trim();

    const children = $el
        .children()
        .map((_, child) => serializeElement($, child))
        .get();

    return {
        tag,
        className,
        text,
        children,
    };
};

const elementMatches = (
    pattern: ElementInfo,
    candidate: ElementInfo,
): boolean => {
    if (pattern.tag !== candidate.tag) {
        return false;
    }

    // class 名が一致するか（pattern の class が候補に含まれているか）
    if (pattern.className) {
        const patternClasses = pattern.className.split(/\s+/);
        const candidateClasses = (candidate.className || '').split(/\s+/);
        for (const patternClass of patternClasses) {
            if (patternClass && !candidateClasses.includes(patternClass)) {
                return false;
            }
        }
    }

    // テキストが一致するか（pattern のテキストが候補に含まれているか）
    // 空白は正規化して比較（複数行やインデントの違いを吸収）
    if (pattern.text) {
        const normalizeWhitespace = (text: string) => text.replace(/\s+/g, ' ').trim();
        if (!normalizeWhitespace(candidate.text).includes(normalizeWhitespace(pattern.text))) {
            return false;
        }
    }

    return true;
};

const findElementInTree = (pattern: ElementInfo, haystack: ElementInfo): boolean => {
    if (elementMatches(pattern, haystack)) {
        return true;
    }

    for (const child of haystack.children) {
        if (findElementInTree(pattern, child)) {
            return true;
        }
    }

    return false;
};

describe('HTML Fixture Comparison', () => {
    it('compares expected-html and html document pairs', async () => {
        const testDataRoot = '/test-data';
        const pairs = await walkForFixtures(testDataRoot);

        expect(pairs.length).toBeGreaterThan(0);

        for (const pair of pairs) {
            const expectedRaw = await fs.readFile(pair.expectedPath, 'utf-8');
            const htmlRaw = await fs.readFile(pair.htmlPath, 'utf-8');

            const $expected = cheerio.load(expectedRaw);
            const $html = cheerio.load(htmlRaw);

            const htmlRoot = serializeElement($html, $html.root()[0]);

            // expected から実際のコンテンツ要素を抽出（すべての実質的な要素）
            const expectedElements: ElementInfo[] = [];
            const getAllContentElements = (el: cheerio.Element) => {
                const $el = $expected(el);
                if (el.name && !['html', 'body'].includes(el.name)) {
                    expectedElements.push(serializeElement($expected, el));
                }
                $el.children().each((_, child) => {
                    getAllContentElements(child);
                });
            };
            getAllContentElements($expected.root()[0]);

            // expected のそれぞれの要素が html に存在するかを検証
            for (const expectedElement of expectedElements) {
                const found = findElementInTree(expectedElement, htmlRoot);
                expect(
                    found,
                    `Expected element not found in ${pair.htmlPath}: ${expectedElement.tag} (class: ${expectedElement.className})`,
                ).toBe(true);
            }
        }
    }, 60000);
});
