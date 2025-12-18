/**
 * Utility to send messages to the IDE (VS Code or JetBrains)
 * This handles the detection of the environment and uses the appropriate method
 */

import { v4 as uuidv4 } from "uuid";

declare const vscode: any;

// Note: Window.postIntellijMessage is already declared in core/index.d.ts
// No need to redeclare it here

interface PostMessageToIdeParams {
  messageType: string;
  data: any;
  messageId?: string;
}

/**
 * Posts a message to the IDE, automatically detecting whether we're in
 * VS Code or JetBrains environment
 */
export function postMessageToIde({
  messageType,
  data,
  messageId,
}: PostMessageToIdeParams): boolean {
  // Ensure messageId is always defined
  const finalMessageId = messageId || uuidv4();

  // Check if we're in JetBrains by looking for postIntellijMessage
  if (
    typeof window !== "undefined" &&
    typeof window.postIntellijMessage === "function"
  ) {
    console.log(
      `[VAULTAI postMessage] Using JetBrains API for: ${messageType}`,
    );
    window.postIntellijMessage(messageType, data, finalMessageId);
    return true;
  }

  // Check if we're in VS Code
  if (typeof vscode !== "undefined" && vscode?.postMessage) {
    console.log(`[VAULTAI postMessage] Using VS Code API for: ${messageType}`);
    const msg: any = { messageType, data, messageId: finalMessageId };
    vscode.postMessage(msg);
    return true;
  }

  // Neither API is available
  console.error(
    `[VAULTAI postMessage] ERROR: Unable to send message - neither vscode nor postIntellijMessage available`,
    { messageType, data, messageId: finalMessageId },
  );
  return false;
}

/**
 * Checks if we're in a JetBrains environment
 */
export function isJetBrains(): boolean {
  return (
    typeof window !== "undefined" &&
    typeof window.postIntellijMessage === "function"
  );
}

/**
 * Checks if we're in a VS Code environment
 */
export function isVSCode(): boolean {
  return typeof vscode !== "undefined" && vscode?.postMessage !== undefined;
}
