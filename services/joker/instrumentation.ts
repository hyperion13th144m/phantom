import { logger } from "@/lib/logger";

export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    logger.info("Application started in standalone mode", {
      nodeVersion: process.version,
      env: process.env.NODE_ENV,
      platform: process.platform,
    });
  }
}
