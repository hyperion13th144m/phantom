import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import fs from 'node:fs/promises';
import path from 'node:path';
import { describe, expect, it, vi } from 'vitest';
import storageConfig from '~/interfaces/generated/config/storage-config.json';

vi.mock('~/lib/path-funcs', async (importOriginal) => {
    const original = await importOriginal<typeof import('~/lib/path-funcs')>();
    return {
        ...original,
        getImageUrl: async () => ({
            url: '/images/mock.png',
            width: 120,
            height: 80,
            alt: 'mock image',
        }),
    };
});

import ApplicationBody from '~/components/document/ApplicationBody.astro';
import AttachingDocument from '~/components/document/AttachingDocument.astro';
import CpyNtcPtE from '~/components/document/CpyNtcPtE.astro';
import CpyNtcPtERn from '~/components/document/CpyNtcPtERn.astro';
import CpyNtcPtF from '~/components/document/CpyNtcPtF.astro';
import PatAmnd from '~/components/document/PatAmnd.astro';
import PatAppDoc from '~/components/document/PatAppDoc.astro';
import PatEtc from '~/components/document/PatEtc.astro';
import PatRspn from '~/components/document/PatRspn.astro';
import { isApplicationBody } from '~/interfaces/generated/application-body.guard';
import { isAttachingDocument } from '~/interfaces/generated/attaching-document.guard';
import { isCpyNtcPtERn } from '~/interfaces/generated/cpy-ntc-pt-e-rn.guard';
import { isCpyNtcPtE } from '~/interfaces/generated/cpy-ntc-pt-e.guard';
import { isCpyNtcPtF } from '~/interfaces/generated/cpy-ntc-pt-f.guard';
import { isPatAmnd } from '~/interfaces/generated/pat-amnd.guard';
import { isPatAppDoc } from '~/interfaces/generated/pat-appd.guard';
import { isPatEtc } from '~/interfaces/generated/pat-etc.guard';
import { isPatRspn } from '~/interfaces/generated/pat-rspn.guard';

type Fixture = {
    inputPath: string;
    outputHtmlPath: string;
};

type Target = {
    dirName: string;
    component: any;
    guard: (value: unknown) => boolean;
    storagePrefix: string;
    expectedTag: string;
};

const targets: Target[] = [
    { dirName: 'ApplicationBody', component: ApplicationBody, guard: isApplicationBody, storagePrefix: 'appd', expectedTag: 'application-body' },
    { dirName: 'AttachingDocument', component: AttachingDocument, guard: isAttachingDocument, storagePrefix: 'amnd', expectedTag: 'attaching-document' },
    { dirName: 'CpyNtcPtE', component: CpyNtcPtE, guard: isCpyNtcPtE, storagePrefix: 'notice', expectedTag: 'cpy-ntc-pt-e' },
    { dirName: 'CpyNtcPtERn', component: CpyNtcPtERn, guard: isCpyNtcPtERn, storagePrefix: 'notice', expectedTag: 'cpy-ntc-pt-e-rn' },
    { dirName: 'CpyNtcPtF', component: CpyNtcPtF, guard: isCpyNtcPtF, storagePrefix: 'notice', expectedTag: 'cpy-ntc-pt-f' },
    { dirName: 'PatAmnd', component: PatAmnd, guard: isPatAmnd, storagePrefix: 'amnd', expectedTag: 'pat-amnd' },
    { dirName: 'PatAppDoc', component: PatAppDoc, guard: isPatAppDoc, storagePrefix: 'appd', expectedTag: 'pat-appd' },
    { dirName: 'PatEtc', component: PatEtc, guard: isPatEtc, storagePrefix: 'etc', expectedTag: 'pat-etc' },
    { dirName: 'PatRspn', component: PatRspn, guard: isPatRspn, storagePrefix: 'rspn', expectedTag: 'pat-rspn' },
];

const devMap = storageConfig.devMap as Record<string, string>;

const walkForDocumentJson = async (rootDir: string): Promise<string[]> => {
    const files: string[] = [];

    const walk = async (currentDir: string) => {
        const entries = await fs.readdir(currentDir, { withFileTypes: true });

        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            if (entry.isDirectory()) {
                await walk(fullPath);
            } else if (entry.isFile() && entry.name === 'document.json' && path.basename(path.dirname(fullPath)) === 'json') {
                files.push(fullPath);
            }
        }
    };

    await walk(rootDir);
    return files;
};

const buildFixture = (inputPath: string): Fixture => {
    const fixtureDir = path.dirname(path.dirname(inputPath));
    return {
        inputPath,
        outputHtmlPath: path.join(fixtureDir, 'html', 'document.html'),
    };
};

const exists = async (p: string): Promise<boolean> => {
    try {
        await fs.access(p);
        return true;
    } catch {
        return false;
    }
};

const resolveDocId = (target: Target, inputPath: string, testDataRoot: string): string => {
    const relative = path.relative(testDataRoot, inputPath);
    const parts = relative.split(path.sep);
    const caseName = parts.length >= 4 ? parts[1] : '';
    const exactSuffix = caseName ? `${target.storagePrefix}/${caseName}` : '';

    if (exactSuffix) {
        const exact = Object.entries(devMap).find(([, value]) => value === exactSuffix);
        if (exact) {
            return exact[0];
        }
    }

    const fallback = Object.entries(devMap).find(([, value]) => value.startsWith(`${target.storagePrefix}/`));
    if (fallback) {
        return fallback[0];
    }

    throw new Error(`No docId found in devMap for ${target.dirName}: ${inputPath}`);
};

describe('Render document fixtures html', () => {
    it('renders all document types under ../test-data/fox', async () => {
        const repoRoot = path.resolve(__dirname, '../..');
        const testDataRoot = path.resolve(repoRoot, '../test-data/fox');
        const container = await AstroContainer.create();

        let renderedCount = 0;

        for (const target of targets) {
            const targetRoot = path.join(testDataRoot, target.dirName);
            if (!(await exists(targetRoot))) {
                continue;
            }

            const jsonFiles = await walkForDocumentJson(targetRoot);
            for (const inputPath of jsonFiles) {
                const raw = await fs.readFile(inputPath, 'utf-8');
                const parsed = JSON.parse(raw);

                const guardOk = target.guard(parsed);
                const tagOk = typeof parsed?.tag === 'string' && parsed.tag === target.expectedTag;
                if (!guardOk && !tagOk) {
                    throw new Error(`Invalid schema for ${target.dirName}: ${inputPath}`);
                }

                const html = await container.renderToString(target.component, {
                    params: {
                        docId: resolveDocId(target, inputPath, testDataRoot),
                    },
                    props: {
                        document: parsed,
                    },
                });

                const fixture = buildFixture(inputPath);
                await fs.mkdir(path.dirname(fixture.outputHtmlPath), { recursive: true });
                await fs.writeFile(fixture.outputHtmlPath, `${html.trim()}\n`, 'utf-8');

                renderedCount += 1;
            }
        }

        expect(renderedCount).toBeGreaterThan(0);
    }, 120000);
});
