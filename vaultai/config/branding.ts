/**
 * VaultAI Branding Constants
 *
 * Ce fichier centralise tous les éléments de branding VaultAI
 * pour faciliter le rebranding et éviter les hardcoded strings
 */

export const VAULTAI_BRANDING = {
  // Identité
  name: "VaultAI Coding Assistant",
  shortName: "VaultAI",
  publisher: "VaultAI",

  // URLs
  homepage: "https://vaultai.eu",
  docs: "https://docs.vaultai.eu/coding-assistant",
  github: "https://github.com/VaultAI/vault-code-assistant",
  marketplace: {
    vscode:
      "https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-assistant",
    jetbrains: "https://plugins.jetbrains.com/plugin/XXXXX-vaultai-assistant",
  },

  // Support
  bugs: "https://github.com/VaultAI/vault-code-assistant/issues",
  email: "support@vaultai.eu",

  // Description
  displayName: "VaultAI - On-premise AI Code Assistant",
  description:
    "Assistant de code IA on-premise pour entreprises avec souveraineté des données",
  shortDescription: "Code faster with AI, keep your data sovereign",

  // Couleurs (pour themes)
  colors: {
    primary: "#0066FF", // Bleu VaultAI
    secondary: "#00CCAA", // Accent
    background: "#1E1E1E", // Dark theme
  },
} as const;

// Feature Flags VaultAI
export const VAULTAI_FEATURES = {
  enableVaultAIProvider: true, // Provider VaultAI on-premise
  enableContinueProviders: true, // Garder providers Continue (OpenAI, Anthropic...)
  enableTelemetry: false, // ⚠️ Disable telemetry Continue
  enableOnPremiseRAG: false, // TODO: Future RAG VaultAI
  requireAuthentication: false, // TODO: Future auth VaultAI
} as const;

export type VaultAIBranding = typeof VAULTAI_BRANDING;
export type VaultAIFeatures = typeof VAULTAI_FEATURES;
