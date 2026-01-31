import { existsSync, mkdirSync } from 'fs';
import { createStream } from 'rotating-file-stream';

const LOG_DIR = '/var/log/fox';
const LOG_FILE = 'fox.log';
const MAX_SIZE = '128K'; // 128KB

// ログディレクトリが存在しない場合は作成
if (!existsSync(LOG_DIR)) {
    try {
        mkdirSync(LOG_DIR, { recursive: true });
    } catch (error) {
        console.error(`Failed to create log directory: ${LOG_DIR}`, error);
    }
}

// ローテーション設定付きストリームを作成
const stream = createStream(LOG_FILE, {
    path: LOG_DIR,
    size: MAX_SIZE,
    interval: '1d', // 1日ごとにもチェック
    compress: 'gzip', // ローテーション後のファイルを圧縮
});

// ログレベル
export enum LogLevel {
    ERROR = 'ERROR',
    WARN = 'WARN',
    INFO = 'INFO',
    DEBUG = 'DEBUG',
}

// ログフォーマット
const formatLog = (level: LogLevel, message: string, meta?: any): string => {
    const timestamp = new Date().toISOString();
    const metaStr = meta ? ` ${JSON.stringify(meta)}` : '';
    return `[${timestamp}] [${level}] ${message}${metaStr}\n`;
};

// ロガークラス
class Logger {
    private stream = stream;

    error(message: string, meta?: any) {
        const log = formatLog(LogLevel.ERROR, message, meta);
        this.stream.write(log);
        // 開発環境では標準エラー出力にも表示
        if (import.meta.env.DEV) {
            console.error(log.trim());
        }
    }

    warn(message: string, meta?: any) {
        const log = formatLog(LogLevel.WARN, message, meta);
        this.stream.write(log);
        if (import.meta.env.DEV) {
            console.warn(log.trim());
        }
    }

    info(message: string, meta?: any) {
        const log = formatLog(LogLevel.INFO, message, meta);
        this.stream.write(log);
        if (import.meta.env.DEV) {
            console.info(log.trim());
        }
    }

    debug(message: string, meta?: any) {
        const log = formatLog(LogLevel.DEBUG, message, meta);
        this.stream.write(log);
        if (import.meta.env.DEV) {
            console.debug(log.trim());
        }
    }

    // アクセスログ用
    access(req: Request, status: number, duration: number) {
        const url = new URL(req.url);
        const message = `${req.method} ${url.pathname} ${status} ${duration}ms`;
        this.info(message, {
            method: req.method,
            path: url.pathname,
            query: url.search,
            status,
            duration,
            userAgent: req.headers.get('user-agent'),
            ip: req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip'),
        });
    }
}

export const logger = new Logger();
