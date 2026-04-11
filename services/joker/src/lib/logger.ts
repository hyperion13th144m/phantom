// Edge Runtimeではfsモジュールが使えないため、Node.js環境でのみインポート
let fs: typeof import('fs') | null = null;
let path: typeof import('path') | null = null;

try {
    fs = require('fs');
    path = require('path');
} catch {
    // Edge Runtimeなどでfsが使えない場合は無視
}

const LOG_DIR = '/var/log/joker';
const LOG_FILE = path ? path.join(LOG_DIR, 'joker.log') : '/var/log/joker/joker.log';
const MAX_LOG_SIZE = 128 * 1024; // 128KB

// ログディレクトリを作成
function ensureLogDir() {
    if (!fs) return;
    try {
        if (!fs.existsSync(LOG_DIR)) {
            fs.mkdirSync(LOG_DIR, { recursive: true, mode: 0o755 });
        }
    } catch (error) {
        // 開発環境などでディレクトリ作成できない場合は無視
        console.error('Failed to create log directory:', error);
    }
}

// ログファイルのローテーション
function rotateLogFile() {
    if (!fs || !path) return;
    try {
        if (!fs.existsSync(LOG_FILE)) {
            return;
        }

        const stats = fs.statSync(LOG_FILE);
        if (stats.size >= MAX_LOG_SIZE) {
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            const rotatedFile = path.join(LOG_DIR, `joker.log.${timestamp}`);
            fs.renameSync(LOG_FILE, rotatedFile);

            // 古いログファイルを削除（10個以上保持しない）
            const files = fs.readdirSync(LOG_DIR)
                .filter(f => f.startsWith('joker.log.'))
                .sort()
                .reverse();

            if (files.length > 10) {
                files.slice(10).forEach(f => {
                    fs!.unlinkSync(path!.join(LOG_DIR, f));
                });
            }
        }
    } catch (error) {
        console.error('Failed to rotate log file:', error);
    }
}

// ログ書き込み
function writeLog(level: string, message: string, data?: any) {
    const timestamp = new Date().toISOString();
    const logEntry = {
        timestamp,
        level,
        message,
        ...(data && { data })
    };

    const logLine = JSON.stringify(logEntry) + '\n';

    // Node.js環境の場合のみファイルに書き込み
    if (fs) {
        try {
            ensureLogDir();
            rotateLogFile();
            fs.appendFileSync(LOG_FILE, logLine, { mode: 0o644 });
        } catch (error) {
            console.error('Failed to write log:', error);
        }
    }

    // 開発環境またはEdge Runtimeではコンソールに出力
    if (process.env.NODE_ENV !== 'production' || !fs) {
        console.log(logLine.trim());
    }
}

export const logger = {
    info: (message: string, data?: any) => writeLog('INFO', message, data),
    error: (message: string, data?: any) => writeLog('ERROR', message, data),
    warn: (message: string, data?: any) => writeLog('WARN', message, data),
    debug: (message: string, data?: any) => writeLog('DEBUG', message, data),
};
