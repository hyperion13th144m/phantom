import fs from 'fs';
import pino from 'pino';
import createStream from 'pino-rotating-file-stream';

const logDir = '/var/log/fox';

// ログディレクトリが存在しない場合は作成
if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true, mode: 0o755 });
}

const rotatingStream = createStream({
    filename: 'fox.log',
    path: logDir,
    size: '1M', // 1mb でローテーション
    maxFiles: 10, // 10世代保持
});

export const logger = pino(
    {
        level: 'info',
        timestamp: pino.stdTimeFunctions.isoTime,
    },
    rotatingStream
);

export default logger;
