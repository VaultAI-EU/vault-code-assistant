#!/usr/bin/env node
/**
 * VaultAI Branding Application Script
 *
 * Merge le fichier overlay VaultAI dans extensions/vscode/package.json
 * UNIQUEMENT les fields de branding, sans toucher aux autres configurations.
 *
 * Usage: node scripts/vaultai/apply-branding.js
 */

const fs = require("fs");
const path = require("path");

const projectRoot = path.resolve(__dirname, "../..");
const packageJsonPath = path.join(
  projectRoot,
  "extensions/vscode/package.json",
);
const overlayPath = path.join(
  projectRoot,
  "vaultai/extensions/vscode/package.overlay.json",
);

console.log("🎨 Applying VaultAI branding to VS Code extension...\n");

try {
  // Lire et parser les fichiers
  console.log(`📖 Reading: ${packageJsonPath}`);
  const packageJsonContent = fs.readFileSync(packageJsonPath, "utf8");
  const packageJson = JSON.parse(packageJsonContent);

  console.log(`🔧 Reading: ${overlayPath}`);
  const overlayContent = fs.readFileSync(overlayPath, "utf8");
  const overlay = JSON.parse(overlayContent);

  console.log("");

  // Fields à merger (uniquement les champs de branding)
  const brandingFields = [
    "displayName",
    "description",
    "publisher",
    "author",
    "icon",
    "homepage",
    "keywords",
  ];

  // Merger les fields de branding
  brandingFields.forEach((field) => {
    if (overlay.hasOwnProperty(field)) {
      packageJson[field] = overlay[field];
      console.log(`  ✅ Updated: ${field}`);
    }
  });

  // Merger les nested objects (repository, bugs)
  if (overlay.repository) {
    packageJson.repository = overlay.repository;
    console.log(`  ✅ Updated: repository`);
  }

  if (overlay.bugs) {
    packageJson.bugs = overlay.bugs;
    console.log(`  ✅ Updated: bugs`);
  }

  // Écrire le package.json modifié (avec validation)
  const outputJson = JSON.stringify(packageJson, null, 2) + "\n";

  // Valider que le JSON est correct avant d'écrire
  try {
    JSON.parse(outputJson);
  } catch (parseError) {
    console.error("\n❌ Error: Generated JSON is invalid!");
    console.error(parseError.message);
    process.exit(1);
  }

  fs.writeFileSync(packageJsonPath, outputJson);

  console.log(`\n✨ VaultAI branding applied successfully!`);
  console.log(`📝 Modified: ${packageJsonPath}\n`);
} catch (error) {
  console.error("\n❌ Error applying branding:", error.message);
  process.exit(1);
}
