type NodeFs = typeof import("fs");
type NodePath = typeof import("path");

type NodeModules = {
  fs: NodeFs;
  path: NodePath;
};

let cachedNodeModules: NodeModules | null | undefined;

function getNodeModules(): NodeModules | null {
  if (cachedNodeModules !== undefined) {
    return cachedNodeModules;
  }

  if (typeof window !== "undefined") {
    cachedNodeModules = null;
    return cachedNodeModules;
  }

  try {
    const dynamicRequire = Function(
      "return typeof require !== \"undefined\" ? require : null;",
    )() as ((id: string) => unknown) | null;

    if (!dynamicRequire) {
      cachedNodeModules = null;
      return cachedNodeModules;
    }

    cachedNodeModules = {
      fs: dynamicRequire("fs") as NodeFs,
      path: dynamicRequire("path") as NodePath,
    };

    return cachedNodeModules;
  } catch {
    cachedNodeModules = null;
    return cachedNodeModules;
  }
}

const LOG_DIR = "/var/log/joker";
const MAX_LOG_SIZE = 128 * 1024;

function getLogFile(nodeModules: NodeModules): string {
  return nodeModules.path.join(LOG_DIR, "joker.log");
}

function ensureLogDir(nodeModules: NodeModules) {
  try {
    if (!nodeModules.fs.existsSync(LOG_DIR)) {
      nodeModules.fs.mkdirSync(LOG_DIR, { recursive: true, mode: 0o755 });
    }
  } catch (error) {
    console.error("Failed to create log directory:", error);
  }
}

function rotateLogFile(nodeModules: NodeModules, logFile: string) {
  try {
    if (!nodeModules.fs.existsSync(logFile)) {
      return;
    }

    const stats = nodeModules.fs.statSync(logFile);
    if (stats.size < MAX_LOG_SIZE) {
      return;
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const rotatedFile = nodeModules.path.join(LOG_DIR, `joker.log.${timestamp}`);
    nodeModules.fs.renameSync(logFile, rotatedFile);

    const files = nodeModules.fs
      .readdirSync(LOG_DIR)
      .filter((file) => file.startsWith("joker.log."))
      .sort()
      .reverse();

    if (files.length > 10) {
      files.slice(10).forEach((file) => {
        nodeModules.fs.unlinkSync(nodeModules.path.join(LOG_DIR, file));
      });
    }
  } catch (error) {
    console.error("Failed to rotate log file:", error);
  }
}

function writeLog(level: string, message: string, data?: unknown) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    level,
    message,
    ...(data !== undefined ? { data } : {}),
  };
  const logLine = JSON.stringify(logEntry) + "\n";
  const nodeModules = getNodeModules();

  if (nodeModules) {
    const logFile = getLogFile(nodeModules);

    try {
      ensureLogDir(nodeModules);
      rotateLogFile(nodeModules, logFile);
      nodeModules.fs.appendFileSync(logFile, logLine, { mode: 0o644 });
    } catch (error) {
      console.error("Failed to write log:", error);
    }
  }

  if (process.env.NODE_ENV !== "production" || !nodeModules) {
    console.log(logLine.trim());
  }
}

export const logger = {
  info: (message: string, data?: unknown) => writeLog("INFO", message, data),
  error: (message: string, data?: unknown) => writeLog("ERROR", message, data),
  warn: (message: string, data?: unknown) => writeLog("WARN", message, data),
  debug: (message: string, data?: unknown) => writeLog("DEBUG", message, data),
};
