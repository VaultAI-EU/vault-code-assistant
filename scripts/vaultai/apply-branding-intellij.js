#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const xml2js = require("xml2js");

console.log("🎨 Applying VaultAI branding to IntelliJ extension...\n");

const rootDir = path.join(__dirname, "../..");
const pluginXmlPath = path.join(
  rootDir,
  "extensions/intellij/src/main/resources/META-INF/plugin.xml",
);
const gradlePropsPath = path.join(
  rootDir,
  "extensions/intellij/gradle.properties",
);
const pluginOverlayPath = path.join(
  rootDir,
  "vaultai/extensions/intellij/plugin.overlay.xml",
);
const gradleOverlayPath = path.join(
  rootDir,
  "vaultai/extensions/intellij/gradle.overlay.properties",
);

// Function to parse properties file
function parseProperties(content) {
  const props = {};
  const lines = content.split("\n");
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith("#")) {
      const [key, ...valueParts] = trimmed.split("=");
      if (key && valueParts.length > 0) {
        props[key.trim()] = valueParts.join("=").trim();
      }
    }
  }
  return props;
}

// Function to apply properties overlay
function applyPropertiesOverlay(originalPath, overlayPath) {
  console.log(`📖 Reading: ${originalPath}`);
  const originalContent = fs.readFileSync(originalPath, "utf8");
  const originalProps = parseProperties(originalContent);

  console.log(`🔧 Reading: ${overlayPath}`);
  const overlayContent = fs.readFileSync(overlayPath, "utf8");
  const overlayProps = parseProperties(overlayContent);

  // Apply overlay
  for (const [key, value] of Object.entries(overlayProps)) {
    if (originalProps[key] !== value) {
      console.log(`  ✅ Updated: ${key}`);
      originalProps[key] = value;
    }
  }

  // Write back
  let output = "";
  for (const [key, value] of Object.entries(originalProps)) {
    output += `${key}=${value}\n`;
  }

  fs.writeFileSync(originalPath, output);
  console.log(`✨ VaultAI branding applied to gradle.properties!\n`);
}

// Function to apply XML overlay
async function applyXmlOverlay(originalPath, overlayPath) {
  console.log(`📖 Reading: ${originalPath}`);
  const originalXml = fs.readFileSync(originalPath, "utf8");

  console.log(`🔧 Reading: ${overlayPath}`);
  const overlayXml = fs.readFileSync(overlayPath, "utf8");

  const parser = new xml2js.Parser();
  const builder = new xml2js.Builder({
    xmldec: {
      version: "1.0",
      encoding: "UTF-8",
    },
    renderOpts: {
      pretty: true,
      indent: "    ",
    },
  });

  try {
    const originalDoc = await parser.parseStringPromise(originalXml);
    const overlayDoc = await parser.parseStringPromise(overlayXml);

    // Apply overlay fields
    if (overlayDoc["idea-plugin"].id) {
      console.log(`  ✅ Updated: id`);
      originalDoc["idea-plugin"].id = overlayDoc["idea-plugin"].id;
    }
    if (overlayDoc["idea-plugin"].name) {
      console.log(`  ✅ Updated: name`);
      originalDoc["idea-plugin"].name = overlayDoc["idea-plugin"].name;
    }
    if (overlayDoc["idea-plugin"].vendor) {
      console.log(`  ✅ Updated: vendor`);
      originalDoc["idea-plugin"].vendor = overlayDoc["idea-plugin"].vendor;
    }
    if (overlayDoc["idea-plugin"]["change-notes"]) {
      console.log(`  ✅ Updated: change-notes`);
      originalDoc["idea-plugin"]["change-notes"] =
        overlayDoc["idea-plugin"]["change-notes"];
    }

    // Build and write
    const outputXml = builder.buildObject(originalDoc);
    fs.writeFileSync(originalPath, outputXml);
    console.log(`✨ VaultAI branding applied to plugin.xml!\n`);
  } catch (error) {
    console.error("\n❌ Error applying XML branding:", error.message);
    process.exit(1);
  }
}

// Main execution
(async () => {
  try {
    await applyXmlOverlay(pluginXmlPath, pluginOverlayPath);
    applyPropertiesOverlay(gradlePropsPath, gradleOverlayPath);
    console.log("🎉 All branding applied successfully!");
  } catch (error) {
    console.error("\n❌ Error:", error.message);
    process.exit(1);
  }
})();
