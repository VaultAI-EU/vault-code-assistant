# VaultAI Coding Assistant - Stratégie de Fork Continue.dev

**Date**: 15 octobre 2025  
**Auteur**: Analyse Continue.dev → VaultAI  
**Objectif**: Créer un fork maintenable de Continue.dev pour VaultAI avec souveraineté des données

---

## 📋 Table des Matières

1. [Executive Summary](#executive-summary)
2. [Architecture Continue.dev](#architecture-continuedev)
3. [Stratégie de Fork Maintenable](#stratégie-de-fork-maintenable)
4. [Plan de Setup Initial](#plan-de-setup-initial)
5. [Guide de Rebranding](#guide-de-rebranding)
6. [Workflow de Release & Marketplace](#workflow-de-release--marketplace)
7. [Roadmap d'Évolution](#roadmap-dévolution)
8. [Checklist de Validation](#checklist-de-validation)

---

## 🎯 Executive Summary

### Le Défi

Créer un fork de Continue.dev pour VaultAI qui :
- ✅ Reste synchronisable avec les updates upstream Continue.dev
- ✅ Permet le rebranding complet (nom, icônes, marketplace)
- ✅ Offre un point d'intégration clair pour les features VaultAI custom
- ✅ Est distribuable via VS Code Marketplace et JetBrains Plugin Marketplace

### La Solution Recommandée

**Architecture "Feature Flag + Overlay"**
- Fork propre avec Git upstream configuré
- Modifications isolées dans des fichiers dédiés VaultAI
- Feature flags pour basculer entre Continue et VaultAI
- Layer de configuration VaultAI qui surcharge les defaults Continue

**Résultat**: Un fork qui peut pull upstream régulièrement sans conflits majeurs, tout en évoluant indépendamment.

---

## 🏗️ Architecture Continue.dev

### Structure du Monorepo

```
continue/
├── core/                      # 🧠 Logique métier partagée (LLM, RAG, indexing)
│   ├── llm/                   # Providers LLM (OpenAI, Anthropic, Ollama...)
│   ├── context/               # Context providers (codebase, docs, terminal...)
│   ├── indexing/              # Codebase indexing & embeddings
│   ├── config/                # ⚠️ Configuration defaults (POINT CLÉ VAULTAI)
│   │   ├── default.ts         # Config par défaut Continue
│   │   ├── yaml/              # Parsing config YAML
│   │   └── load.ts            # Chargement configuration
│   └── autocomplete/          # Autocomplete engine
│
├── gui/                       # 🎨 Interface React (chat, settings, history)
│   ├── src/
│   │   ├── components/        # Composants UI
│   │   ├── pages/             # Pages (AddNewModel, Settings...)
│   │   └── styles/            # Theme & styles
│   └── public/                # ⚠️ Assets (logos, icons) (POINT CLÉ VAULTAI)
│
├── extensions/
│   ├── vscode/                # 🔌 Extension VS Code
│   │   ├── src/               # Code TypeScript extension
│   │   ├── media/             # ⚠️ Icons, images (POINT CLÉ VAULTAI)
│   │   ├── package.json       # ⚠️ Metadata extension (POINT CLÉ VAULTAI)
│   │   └── scripts/           # Build & package scripts
│   │
│   └── intellij/              # 🔌 Plugin JetBrains
│       ├── src/main/kotlin/   # Code Kotlin plugin
│       ├── src/main/resources/# ⚠️ Resources (icons, META-INF) (POINT CLÉ VAULTAI)
│       ├── build.gradle.kts   # ⚠️ Config Gradle (POINT CLÉ VAULTAI)
│       └── gradle.properties  # ⚠️ Metadata plugin (POINT CLÉ VAULTAI)
│
├── packages/                  # 📦 Packages internes
│   ├── config-types/          # Types TypeScript config
│   ├── config-yaml/           # Parser YAML config
│   ├── llm-info/              # Info modèles LLM
│   └── openai-adapters/       # Adaptateurs OpenAI
│
└── binary/                    # 🖥️ CLI & binary core
```

### Points d'Entrée Critiques

#### 1. **Configuration Defaults** (`core/config/`)
**Pourquoi c'est important** : C'est ici que Continue définit les modèles par défaut, les providers, etc.

**Fichiers clés** :
- `core/config/default.ts` - Configuration par défaut Continue
- `core/config/yaml/default.ts` - Config YAML par défaut
- `core/config/load.ts` - Logique de chargement config

**Stratégie VaultAI** : Créer `core/config/vaultai-default.ts` avec vos defaults

#### 2. **Extension VS Code** (`extensions/vscode/`)
**Fichiers de branding** :
- `package.json` - Nom, publisher, description, icon
- `media/icon.png` - Icône principale
- `media/sidebar-icon.png` - Icône sidebar

**Points d'intégration** :
- `src/extension.ts` - Entry point extension
- `src/activation/` - Logique d'activation

#### 3. **Plugin JetBrains** (`extensions/intellij/`)
**Fichiers de branding** :
- `build.gradle.kts` - Nom plugin, version, publisher
- `gradle.properties` - Metadata
- `src/main/resources/META-INF/plugin.xml` - Descripteur plugin
- `src/main/resources/icons/` - Icônes

**Points d'intégration** :
- `src/main/kotlin/.../ContinueExtensionPlugin.kt` - Entry point

#### 4. **GUI React** (`gui/`)
**Fichiers de branding** :
- `src/pages/AddNewModel/` - Configuration modèles
- `src/components/mainInput/` - Input chat
- `src/styles/theme.ts` - Thème & couleurs
- `public/` - Logos & assets

---

## 🔄 Stratégie de Fork Maintenable

### Option Recommandée : **"Feature Flag + Overlay Pattern"**

Cette approche permet de :
- ✅ Pull upstream Continue.dev sans conflits
- ✅ Rebrand complet vers VaultAI
- ✅ Ajouter des features custom sans polluer le code Continue
- ✅ Maintenir la compatibilité avec les updates Continue

### Architecture du Fork

```
vault-code-assistant/ (fork de continue)
│
├── .git/
│   └── config                  # 2 remotes: origin (VaultAI) + upstream (Continue)
│
├── vaultai/                    # 🆕 Dossier VaultAI-specific
│   ├── config/
│   │   ├── default.ts          # Config defaults VaultAI (modèles, endpoints...)
│   │   ├── branding.ts         # Constants branding (nom, URLs, couleurs...)
│   │   └── features.ts         # Feature flags VaultAI
│   │
│   ├── providers/              # 🆕 VaultAI LLM provider custom
│   │   └── VaultAIProvider.ts  # Provider pour instances VaultAI on-premise
│   │
│   ├── assets/                 # Assets VaultAI (logos, icons...)
│   │   ├── icons/
│   │   │   ├── icon.png
│   │   │   └── sidebar-icon.png
│   │   └── branding/
│   │       └── logo.svg
│   │
│   └── extensions/             # Overlays pour extensions
│       ├── vscode/
│       │   └── package.overlay.json  # Metadata VaultAI pour VS Code
│       └── intellij/
│           └── gradle.overlay.properties
│
├── core/
│   ├── config/
│   │   ├── default.ts          # ⚠️ MODIFIÉ: importe vaultai/config si flag activé
│   │   └── load.ts             # ⚠️ MODIFIÉ: check VAULTAI_MODE env var
│   └── llm/llms/
│       └── index.ts            # ⚠️ MODIFIÉ: enregistre VaultAIProvider
│
├── extensions/vscode/
│   ├── package.json            # ⚠️ GÉNÉRÉ: merge avec vaultai/extensions/vscode/package.overlay.json
│   └── media/                  # ⚠️ SYMLINK vers vaultai/assets/icons/
│
└── scripts/
    └── vaultai/                # 🆕 Scripts build VaultAI
        ├── apply-branding.sh   # Applique le branding VaultAI
        ├── build-vscode.sh     # Build extension VS Code VaultAI
        └── build-intellij.sh   # Build plugin JetBrains VaultAI
```

### Workflow Git avec Upstream

```bash
# 1. Fork initial
git clone https://github.com/VaultAI/vault-code-assistant.git
cd vault-code-assistant

# 2. Ajouter Continue.dev comme upstream
git remote add upstream https://github.com/continuedev/continue.git
git remote set-url --push upstream DISABLE  # Empêche push accidentel

# 3. Créer branche VaultAI main
git checkout -b vaultai-main

# 4. Pull updates upstream (régulièrement)
git fetch upstream
git checkout main
git merge upstream/main --no-commit  # Review conflicts
git commit -m "Merge upstream Continue v1.x.x"

# 5. Merge dans branche VaultAI
git checkout vaultai-main
git merge main  # Résoudre conflits si nécessaire
```

### Gestion des Conflits

**Zones de conflits probables** :
1. `package.json` (extensions) - Résolu par overlay pattern
2. `core/config/default.ts` - Résolu par feature flag
3. `gui/public/` assets - Résolu par symlinks vers `vaultai/assets/`

**Stratégie de résolution** :
- **Conflits mineurs** (whitespace, imports) → Accepter upstream
- **Conflits metadata** (noms, URLs) → Forcer VaultAI
- **Conflits logique** → Review manuelle + test

---

## 🚀 Plan de Setup Initial

### Phase 1 : Fork & Configuration Git (Jour 1)

#### 1.1 Créer le Fork GitHub

```bash
# Sur GitHub
# 1. Forker https://github.com/continuedev/continue
# 2. Renommer le repo en "vault-code-assistant"

# Localement
git clone https://github.com/VaultAI/vault-code-assistant.git
cd vault-code-assistant

# Ajouter upstream
git remote add upstream https://github.com/continuedev/continue.git
git remote set-url --push upstream DISABLE
git fetch upstream

# Vérifier
git remote -v
# origin    https://github.com/VaultAI/vault-code-assistant.git (fetch)
# origin    https://github.com/VaultAI/vault-code-assistant.git (push)
# upstream  https://github.com/continuedev/continue.git (fetch)
# upstream  DISABLE (push)
```

#### 1.2 Setup Environnement de Développement

**Prérequis** :
- Node.js 20.19.0 LTS minimum (use NVM)
- npm ou pnpm
- VS Code
- IntelliJ IDEA (pour plugin JetBrains)

```bash
# Utiliser la version Node correcte
nvm use  # Lit .nvmrc (version 20.19.0)

# Installer Vite globalement
npm install -g vite

# Installer dépendances (à la racine)
npm install

# Installer dépendances GUI
cd gui && npm install && cd ..

# Installer dépendances VS Code extension
cd extensions/vscode && npm install && cd ../..

# Installer dépendances core
cd core && npm install && cd ..
```

### Phase 2 : Build & Test Continue Original (Jour 1-2)

**Objectif** : S'assurer que le fork fonctionne AVANT toute modification

#### 2.1 Build VS Code Extension

```bash
# Ouvrir VS Code dans le repo
code .

# Via VS Code Tasks
# Cmd/Ctrl+Shift+P → "Tasks: Run Task" → "install-all-dependencies"

# Lancer en mode debug
# F5 ou "Run and Debug" → "Launch extension"
# Cela ouvre une nouvelle fenêtre VS Code avec l'extension installée
```

**Test Checklist VS Code** :
- [ ] L'icône Continue apparaît dans la sidebar
- [ ] Le chat s'ouvre correctement
- [ ] Peut configurer un modèle (ex: Ollama local)
- [ ] L'autocomplete fonctionne
- [ ] Le mode Edit (Cmd/Ctrl+I) fonctionne

#### 2.2 Build JetBrains Plugin

```bash
cd extensions/intellij

# Build avec Gradle
./gradlew buildPlugin

# Le plugin est généré dans build/distributions/
# Fichier .zip à installer dans IntelliJ

# Lancer en mode dev
./gradlew runIde
# Cela ouvre IntelliJ avec le plugin installé
```

**Test Checklist JetBrains** :
- [ ] L'icône Continue apparaît dans le panel droit
- [ ] Le chat s'ouvre correctement
- [ ] Peut configurer un modèle
- [ ] L'autocomplete fonctionne

**⚠️ STOP POINT** : Ne passez PAS à la phase 3 avant que Continue original fonctionne 100% en local !

### Phase 3 : Créer l'Infrastructure VaultAI (Jour 3-4)

#### 3.1 Créer le dossier `vaultai/`

```bash
# À la racine du repo
mkdir -p vaultai/{config,providers,assets/{icons,branding},extensions/{vscode,intellij}}

# Créer les fichiers de base
touch vaultai/config/{default.ts,branding.ts,features.ts}
touch vaultai/providers/VaultAIProvider.ts
touch vaultai/extensions/vscode/package.overlay.json
touch vaultai/extensions/intellij/gradle.overlay.properties
```

#### 3.2 Définir le Branding VaultAI

**Fichier** : `vaultai/config/branding.ts`

```typescript
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
    vscode: "https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-assistant",
    jetbrains: "https://plugins.jetbrains.com/plugin/XXXXX-vaultai-assistant"
  },
  
  // Support
  bugs: "https://github.com/VaultAI/vault-code-assistant/issues",
  email: "support@vaultai.eu",
  
  // Description
  displayName: "VaultAI - On-premise AI Code Assistant",
  description: "Assistant de code IA on-premise pour entreprises avec souveraineté des données",
  tagline: "Code faster with AI, keep your data sovereign",
  
  // Couleurs (pour themes)
  colors: {
    primary: "#0066FF",      // Bleu VaultAI
    secondary: "#00CCAA",    // Accent
    background: "#1E1E1E",   // Dark theme
  }
} as const;

// Feature Flags VaultAI
export const VAULTAI_FEATURES = {
  enableVaultAIProvider: true,           // Provider VaultAI on-premise
  enableContinueProviders: true,         // Garder providers Continue (OpenAI, Anthropic...)
  enableTelemetry: false,                // ⚠️ Disable telemetry Continue
  enableOnPremiseRAG: false,             // TODO: Future RAG VaultAI
  requireAuthentication: false,          // TODO: Future auth VaultAI
} as const;

export type VaultAIBranding = typeof VAULTAI_BRANDING;
export type VaultAIFeatures = typeof VAULTAI_FEATURES;
```

#### 3.3 Créer la Configuration Default VaultAI

**Fichier** : `vaultai/config/default.ts`

```typescript
import { ConfigYaml } from "@continuedev/config-yaml";
import { VAULTAI_BRANDING } from "./branding";

/**
 * Configuration par défaut VaultAI
 * 
 * Cette config est utilisée lors du premier lancement
 * Elle pointe vers une instance VaultAI on-premise par défaut
 */
export const vaultaiDefaultConfig: ConfigYaml = {
  name: "VaultAI Default Config",
  version: "1.0.0",
  schema: "v1",
  
  models: [
    {
      // Exemple : pointer vers VaultAI instance on-premise par défaut
      title: "VaultAI Chat (GPT-4)",
      provider: "vaultai",
      model: "gpt-4",
      apiBase: "https://api.vaultai.local/v1",  // URL instance on-premise
      apiKey: "",  // L'utilisateur devra la configurer
    },
    {
      title: "VaultAI Autocomplete",
      provider: "vaultai",
      model: "gpt-3.5-turbo",
      apiBase: "https://api.vaultai.local/v1",
      apiKey: "",
    }
  ],
  
  // Context providers (inchangé pour l'instant)
  contextProviders: [],
  
  // Custom prompts VaultAI (optionnel)
  systemMessage: `You are VaultAI Coding Assistant, an AI coding assistant focused on privacy and data sovereignty. 
You help developers write better code while ensuring their data never leaves their infrastructure.`,
};

/**
 * Fonction pour merger avec config Continue si besoin
 */
export function getVaultAIConfig(continueConfig?: ConfigYaml): ConfigYaml {
  if (!continueConfig) {
    return vaultaiDefaultConfig;
  }
  
  // Merge logic (VaultAI defaults + user custom config)
  return {
    ...continueConfig,
    name: vaultaiDefaultConfig.name,
    models: [
      ...vaultaiDefaultConfig.models,
      ...(continueConfig.models || [])
    ]
  };
}
```

#### 3.4 Créer le Provider VaultAI

**Fichier** : `vaultai/providers/VaultAIProvider.ts`

```typescript
import { LLMOptions, ModelProvider } from "../../core/index.js";
import OpenAI from "../../core/llm/llms/OpenAI.js";

/**
 * VaultAI Provider
 * 
 * Provider pour se connecter aux instances VaultAI on-premise
 * Compatible OpenAI API (VaultAI expose une API OpenAI-compatible)
 */
class VaultAI extends OpenAI {
  static providerName: ModelProvider = "vaultai";
  static defaultOptions: Partial<LLMOptions> = {
    apiBase: "https://api.vaultai.local/v1",  // URL par défaut (modifiable)
    model: "gpt-4",
  };

  // VaultAI utilise le même protocole qu'OpenAI
  // Donc on hérite de OpenAI et on override juste ce qui est nécessaire
  
  constructor(options: LLMOptions) {
    super(options);
    
    // Custom headers pour VaultAI (si nécessaire)
    this.requestOptions = {
      ...this.requestOptions,
      headers: {
        ...this.requestOptions?.headers,
        "X-VaultAI-Version": "1.0",
        "X-Client": "VaultAI-Coding-Assistant"
      }
    };
  }

  // Override pour logging/telemetry VaultAI (optionnel)
  protected async _streamChat(
    messages: any[],
    signal: AbortSignal,
    options: any
  ): Promise<any> {
    console.log("[VaultAI] Streaming chat to on-premise instance:", this.apiBase);
    return super._streamChat(messages, signal, options);
  }
}

export default VaultAI;
```

### Phase 4 : Intégrer VaultAI dans Continue Core (Jour 4-5)

#### 4.1 Enregistrer le Provider VaultAI

**Fichier** : `core/llm/llms/index.ts`

```typescript
// ... imports existants ...
import VaultAI from "../../../vaultai/providers/VaultAIProvider.js";  // 🆕

export const LLMs = [
  // ... providers existants (OpenAI, Anthropic, etc.) ...
  VaultAI,  // 🆕 Ajouter VaultAI
];
```

#### 4.2 Modifier le Chargement de Config

**Fichier** : `core/config/load.ts`

```typescript
// ... imports existants ...
import { defaultConfig } from "./default.js";
import { vaultaiDefaultConfig, getVaultAIConfig } from "../../vaultai/config/default.js";  // 🆕
import { VAULTAI_FEATURES } from "../../vaultai/config/branding.js";  // 🆕

// ... code existant ...

export async function loadFullConfigNode(
  ide: IDE,
  workspaceDir: string | undefined,
  // ... autres params
): Promise<ContinueConfig> {
  
  // 🆕 Check si mode VaultAI activé
  const isVaultAIMode = process.env.VAULTAI_MODE === "true" || VAULTAI_FEATURES.enableVaultAIProvider;
  
  // ... logique de chargement existante ...
  
  // 🆕 Utiliser config VaultAI ou Continue selon le mode
  const baseConfig = isVaultAIMode 
    ? vaultaiDefaultConfig 
    : defaultConfig;
  
  // ... reste du code ...
}
```

**Note** : Cette modification est minimaliste pour éviter les conflits lors des merges upstream

### Phase 5 : Rebranding Assets (Jour 5)

#### 5.1 Créer les Assets VaultAI

**Assets nécessaires** :
1. **Icon principale** (512x512px) : `vaultai/assets/icons/icon.png`
2. **Icon sidebar** (64x64px, transparent) : `vaultai/assets/icons/sidebar-icon.png`
3. **Logo SVG** : `vaultai/assets/branding/logo.svg`

**Guidelines design** :
- Style moderne, pro, sécurisé
- Couleurs VaultAI (bleu #0066FF)
- Symbole : vault/coffre-fort + IA/code

#### 5.2 Symlinks vers Assets (évite duplication)

```bash
# VS Code
cd extensions/vscode/media
mv icon.png icon.png.continue-backup         # Backup original
mv sidebar-icon.png sidebar-icon.png.continue-backup
ln -s ../../../vaultai/assets/icons/icon.png icon.png
ln -s ../../../vaultai/assets/icons/sidebar-icon.png sidebar-icon.png

# JetBrains
cd extensions/intellij/src/main/resources/icons
# Backup et créer symlinks similaires
```

---

## 🎨 Guide de Rebranding

### Étape 1 : VS Code Extension Rebranding

#### 1.1 Modifier `extensions/vscode/package.json`

**Approche** : Créer un overlay + script de merge

**Fichier** : `vaultai/extensions/vscode/package.overlay.json`

```json
{
  "name": "vaultai-assistant",
  "displayName": "VaultAI - On-premise AI Code Assistant",
  "description": "Assistant de code IA on-premise pour entreprises avec souveraineté des données",
  "version": "1.0.0",
  "publisher": "VaultAI",
  "author": "VaultAI SAS",
  "icon": "media/icon.png",
  "repository": {
    "type": "git",
    "url": "https://github.com/VaultAI/vault-code-assistant"
  },
  "bugs": {
    "url": "https://github.com/VaultAI/vault-code-assistant/issues",
    "email": "support@vaultai.eu"
  },
  "homepage": "https://vaultai.eu",
  "keywords": [
    "vaultai",
    "ai",
    "code assistant",
    "on-premise",
    "privacy",
    "sovereignty",
    "gpt",
    "claude"
  ]
}
```

**Script** : `scripts/vaultai/apply-branding.sh`

```bash
#!/bin/bash
# Apply VaultAI branding to extensions

set -e

echo "🎨 Applying VaultAI branding..."

# Merge VS Code package.json
echo "  → VS Code extension metadata"
node scripts/vaultai/merge-package-json.js \
  extensions/vscode/package.json \
  vaultai/extensions/vscode/package.overlay.json \
  extensions/vscode/package.json

# Symlink assets (déjà fait dans Phase 5)

echo "✅ VaultAI branding applied!"
```

**Script** : `scripts/vaultai/merge-package-json.js`

```javascript
#!/usr/bin/env node
/**
 * Merge package.json avec overlay VaultAI
 */
const fs = require('fs');
const path = require('path');

const [,, baseFile, overlayFile, outputFile] = process.argv;

const base = JSON.parse(fs.readFileSync(baseFile, 'utf8'));
const overlay = JSON.parse(fs.readFileSync(overlayFile, 'utf8'));

const merged = {
  ...base,
  ...overlay,
  // Merge arrays (keywords, etc.)
  keywords: [...new Set([...(base.keywords || []), ...(overlay.keywords || [])])],
};

fs.writeFileSync(outputFile, JSON.stringify(merged, null, 2));
console.log(`✅ Merged ${baseFile} + ${overlayFile} → ${outputFile}`);
```

#### 1.2 Modifier les Commandes & Menus

**Fichier** : `extensions/vscode/package.json` (section `contributes.commands`)

**Stratégie** : Search/replace dans overlay

```json
{
  "contributes": {
    "commands": [
      {
        "command": "vaultai.focusContinueInput",
        "title": "Add to Chat",
        "category": "VaultAI"
      }
      // ... autres commandes : rename continue.* → vaultai.*
    ],
    "viewsContainers": {
      "activitybar": [
        {
          "id": "vaultai",
          "title": "VaultAI",
          "icon": "media/sidebar-icon.png"
        }
      ]
    },
    "views": {
      "vaultai": [
        {
          "type": "webview",
          "id": "vaultai.vaultaiGUIView",
          "name": "VaultAI"
        }
      ]
    }
  }
}
```

**⚠️ Important** : Renommer `continue.*` → `vaultai.*` dans TOUS les IDs de commandes, views, contexts pour éviter conflits si utilisateur a Continue ET VaultAI installés

#### 1.3 Modifier le Code Extension

**Fichier** : `extensions/vscode/src/extension.ts`

**Changements minimaux** :
```typescript
// ... imports ...
import { VAULTAI_BRANDING } from "../../vaultai/config/branding.js";  // 🆕

export function activate(context: vscode.ExtensionContext) {
  console.log(`🚀 ${VAULTAI_BRANDING.name} is now active!`);  // 🆕
  
  // ... reste du code inchangé ...
  
  // Register commands avec prefix vaultai au lieu de continue
  const focusChatCommand = vscode.commands.registerCommand(
    "vaultai.focusContinueInput",  // 🆕 (was continue.focusContinueInput)
    () => {
      // ... logique ...
    }
  );
}
```

**Script de renommage automatique** : `scripts/vaultai/rename-commands.sh`

```bash
#!/bin/bash
# Rename all "continue.*" command IDs to "vaultai.*"

find extensions/vscode/src -type f -name "*.ts" -exec sed -i '' 's/"continue\./"vaultai\./g' {} \;
find extensions/vscode/package.json -exec sed -i '' 's/"continue\./"vaultai\./g' {} \;

echo "✅ Renamed all command IDs"
```

### Étape 2 : JetBrains Plugin Rebranding

#### 2.1 Modifier `extensions/intellij/gradle.properties`

```properties
# VaultAI Plugin Properties
pluginGroup = eu.vaultai
pluginName = VaultAI Coding Assistant
pluginVersion = 1.0.0

# Build configuration
platformVersion = 2024.1
```

#### 2.2 Modifier `extensions/intellij/build.gradle.kts`

```kotlin
// ... imports ...

val platformVersion: String by project
val pluginGroup: String by project
val pluginVersion: String by project

group = pluginGroup  // eu.vaultai
version = pluginVersion  // 1.0.0

// ... reste du fichier inchangé ...

intellijPlatform {
  pluginConfiguration {
    name = "VaultAI Coding Assistant"
    version = pluginVersion
    
    ideaVersion {
      sinceBuild = "241"
    }
  }
  
  publishing {
    token = environment("JETBRAINS_PUBLISH_TOKEN")
    channels = listOf("default")
  }
}
```

#### 2.3 Modifier `extensions/intellij/src/main/resources/META-INF/plugin.xml`

```xml
<idea-plugin>
  <id>eu.vaultai.coding-assistant</id>
  <name>VaultAI Coding Assistant</name>
  <vendor email="support@vaultai.eu" url="https://vaultai.eu">VaultAI SAS</vendor>

  <description><![CDATA[
    Assistant de code IA on-premise pour entreprises.<br/>
    <br/>
    VaultAI Coding Assistant vous permet de :<br/>
    - Coder plus vite avec l'IA directement dans votre IDE<br/>
    - Garder la souveraineté de vos données (100% on-premise)<br/>
    - Utiliser vos modèles IA internes<br/>
    <br/>
    Compatible avec vos instances VaultAI on-premise.
  ]]></description>

  <change-notes><![CDATA[
    <h2>1.0.0 - Initial Release</h2>
    <ul>
      <li>Chat IA intégré</li>
      <li>Autocomplete intelligent</li>
      <li>Edit inline avec IA</li>
      <li>Connexion aux instances VaultAI on-premise</li>
    </ul>
  ]]></change-notes>

  <!-- ... reste de la config ... -->
</idea-plugin>
```

### Étape 3 : GUI React Rebranding

#### 3.1 Modifier `gui/index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vaultai-logo.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>VaultAI Coding Assistant</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

#### 3.2 Modifier les Pages Settings

**Fichier** : `gui/src/pages/AddNewModel/configs/models.ts`

```typescript
// ... imports ...
import { VAULTAI_BRANDING } from "../../../../vaultai/config/branding.js";

// Ajouter VaultAI comme premier provider
export const MODEL_PACKAGES: ModelPackage[] = [
  // 🆕 VaultAI On-Premise
  {
    title: "VaultAI On-Premise",
    description: "Connectez-vous à votre instance VaultAI on-premise",
    provider: "vaultai",
    icon: "vaultai-icon.svg",
    tags: ["on-premise", "recommended"],
    models: [
      {
        model: "gpt-4",
        displayName: "GPT-4",
        contextLength: 8192,
      },
      {
        model: "gpt-3.5-turbo",
        displayName: "GPT-3.5 Turbo",
        contextLength: 4096,
      }
    ],
    collectInputFor: [
      {
        inputType: "text",
        key: "apiBase",
        label: "VaultAI API URL",
        placeholder: "https://api.vaultai.local/v1",
        defaultValue: "https://api.vaultai.local/v1",
        required: true
      },
      {
        inputType: "text",
        key: "apiKey",
        label: "API Key",
        placeholder: "sk-...",
        required: true
      }
    ]
  },
  
  // ... garder les autres providers Continue (OpenAI, Anthropic, etc.) ...
];
```

#### 3.3 Modifier le Thème

**Fichier** : `gui/src/styles/theme.ts`

```typescript
import { VAULTAI_BRANDING } from "../../../vaultai/config/branding.js";

// Override couleurs avec branding VaultAI
export const theme = {
  colors: {
    primary: VAULTAI_BRANDING.colors.primary,       // #0066FF
    secondary: VAULTAI_BRANDING.colors.secondary,   // #00CCAA
    background: VAULTAI_BRANDING.colors.background, // #1E1E1E
    // ... autres couleurs ...
  }
};
```

---

## 📦 Workflow de Release & Marketplace

### Prérequis Marketplace

#### VS Code Marketplace

**Compte requis** :
- Compte Microsoft/Azure DevOps
- Organisation Azure DevOps (ex: "VaultAI")
- Personal Access Token (PAT) avec scope "Marketplace (Manage)"

**Process** :
1. Aller sur https://marketplace.visualstudio.com/manage
2. Créer un publisher "VaultAI"
3. Générer un PAT sur https://dev.azure.com/VaultAI/_usersSettings/tokens

**Stockage sécurisé** : GitHub Secrets
```
VSCODE_MARKETPLACE_TOKEN = <votre PAT>
```

#### JetBrains Marketplace

**Compte requis** :
- Compte JetBrains
- Plugin developer account (gratuit)
- Token d'accès

**Process** :
1. Aller sur https://plugins.jetbrains.com/
2. "Upload Plugin" → Créer un nouveau plugin
3. Obtenir token sur https://plugins.jetbrains.com/author/me/tokens

**Stockage sécurisé** : GitHub Secrets
```
JETBRAINS_PUBLISH_TOKEN = <votre token>
```

### Build Scripts

#### VS Code Build

**Script** : `scripts/vaultai/build-vscode.sh`

```bash
#!/bin/bash
set -e

echo "🔨 Building VaultAI VS Code Extension..."

# 1. Clean
echo "  → Cleaning previous builds"
rm -rf extensions/vscode/build
rm -rf extensions/vscode/out

# 2. Apply VaultAI branding
echo "  → Applying VaultAI branding"
bash scripts/vaultai/apply-branding.sh

# 3. Build GUI
echo "  → Building GUI"
cd gui
npm run build
cd ..

# 4. Build Core
echo "  → Building Core"
cd core
npm run build
cd ..

# 5. Build Extension
echo "  → Building VS Code extension"
cd extensions/vscode
npm run esbuild-base -- --minify
cd ../..

# 6. Package VSIX
echo "  → Packaging VSIX"
cd extensions/vscode
npx @vscode/vsce package --out build/vaultai-assistant-${VERSION:-1.0.0}.vsix
cd ../..

echo "✅ VS Code extension built: extensions/vscode/build/vaultai-assistant-${VERSION:-1.0.0}.vsix"
```

**Utilisation** :
```bash
VERSION=1.0.0 bash scripts/vaultai/build-vscode.sh
```

#### JetBrains Build

**Script** : `scripts/vaultai/build-intellij.sh`

```bash
#!/bin/bash
set -e

echo "🔨 Building VaultAI JetBrains Plugin..."

# 1. Apply branding
echo "  → Applying VaultAI branding"
bash scripts/vaultai/apply-branding.sh

# 2. Build with Gradle
echo "  → Building plugin with Gradle"
cd extensions/intellij
./gradlew buildPlugin
cd ../..

echo "✅ JetBrains plugin built: extensions/intellij/build/distributions/"
ls -lh extensions/intellij/build/distributions/
```

### CI/CD avec GitHub Actions

**Fichier** : `.github/workflows/vaultai-release.yml`

```yaml
name: VaultAI Release

on:
  push:
    tags:
      - 'v*.*.*'  # Déclenché sur tags version (ex: v1.0.0)

env:
  NODE_VERSION: '20.19.0'

jobs:
  build-vscode:
    name: Build VS Code Extension
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Install dependencies
        run: |
          npm install
          cd gui && npm install && cd ..
          cd core && npm install && cd ..
          cd extensions/vscode && npm install && cd ../..
      
      - name: Build VS Code Extension
        env:
          VERSION: ${{ github.ref_name }}
        run: bash scripts/vaultai/build-vscode.sh
      
      - name: Upload VSIX artifact
        uses: actions/upload-artifact@v4
        with:
          name: vscode-extension
          path: extensions/vscode/build/*.vsix
      
      - name: Publish to VS Code Marketplace
        if: startsWith(github.ref, 'refs/tags/v')
        env:
          VSCE_PAT: ${{ secrets.VSCODE_MARKETPLACE_TOKEN }}
        run: |
          cd extensions/vscode
          npx @vscode/vsce publish --pat $VSCE_PAT

  build-jetbrains:
    name: Build JetBrains Plugin
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Build JetBrains Plugin
        run: bash scripts/vaultai/build-intellij.sh
      
      - name: Upload Plugin artifact
        uses: actions/upload-artifact@v4
        with:
          name: jetbrains-plugin
          path: extensions/intellij/build/distributions/*.zip
      
      - name: Publish to JetBrains Marketplace
        if: startsWith(github.ref, 'refs/tags/v')
        env:
          PUBLISH_TOKEN: ${{ secrets.JETBRAINS_PUBLISH_TOKEN }}
        run: |
          cd extensions/intellij
          ./gradlew publishPlugin

  create-release:
    name: Create GitHub Release
    needs: [build-vscode, build-jetbrains]
    runs-on: ubuntu-latest
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            vscode-extension/*.vsix
            jetbrains-plugin/*.zip
          body: |
            ## VaultAI Coding Assistant ${{ github.ref_name }}
            
            ### Downloads
            - **VS Code**: Installer `.vsix` ou via [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-assistant)
            - **JetBrains**: Installer `.zip` ou via [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/XXXXX-vaultai-assistant)
            
            ### Changelog
            Voir [CHANGELOG.md](https://github.com/VaultAI/vault-code-assistant/blob/main/CHANGELOG.md)
```

### Process de Release Manuel

#### 1. Préparer la Release

```bash
# 1. S'assurer qu'on est sur vaultai-main et à jour
git checkout vaultai-main
git pull origin vaultai-main

# 2. Merger les dernières updates upstream (optionnel)
git fetch upstream
git merge upstream/main

# 3. Bumper la version
npm version 1.0.0  # Ou minor/patch selon semver

# 4. Update CHANGELOG.md
# Ajouter les changements de cette version

# 5. Commit & Tag
git add .
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin vaultai-main --tags
```

#### 2. Build Local

```bash
# VS Code
VERSION=1.0.0 bash scripts/vaultai/build-vscode.sh

# JetBrains
bash scripts/vaultai/build-intellij.sh
```

#### 3. Test des Extensions

**VS Code** :
```bash
# Installer le VSIX en local
code --install-extension extensions/vscode/build/vaultai-assistant-1.0.0.vsix

# Tester dans une fenêtre VS Code
# Vérifier : branding, chat, autocomplete, connexion VaultAI
```

**JetBrains** :
```bash
# Dans IntelliJ IDEA
# Settings → Plugins → ⚙️ → Install Plugin from Disk
# Sélectionner extensions/intellij/build/distributions/vaultai-assistant-1.0.0.zip

# Tester : branding, chat, autocomplete
```

#### 4. Publish Manuellement

**VS Code** :
```bash
cd extensions/vscode
npx @vscode/vsce publish --pat <VOTRE_PAT>
```

**JetBrains** :
```bash
cd extensions/intellij
PUBLISH_TOKEN=<VOTRE_TOKEN> ./gradlew publishPlugin
```

#### 5. Créer GitHub Release

- Aller sur https://github.com/VaultAI/vault-code-assistant/releases
- "Draft a new release"
- Tag: v1.0.0
- Title: VaultAI Coding Assistant v1.0.0
- Description: Copier depuis CHANGELOG.md
- Attacher les fichiers .vsix et .zip
- Publish

---

## 🛣️ Roadmap d'Évolution

### Phase 0 : Fork Fonctionnel (Semaine 1-2) ✅

- [x] Fork Continue.dev
- [x] Setup Git avec upstream
- [x] Build Continue original en local
- [x] Tests VS Code + JetBrains

### Phase 1 : Rebranding (Semaine 2-3)

- [ ] Créer infrastructure `vaultai/`
- [ ] Définir branding (nom, logos, couleurs)
- [ ] Créer assets (icons, logos)
- [ ] Rebrand VS Code extension
- [ ] Rebrand JetBrains plugin
- [ ] Rebrand GUI React
- [ ] Tests complets rebranding

### Phase 2 : VaultAI Provider (Semaine 3-4)

- [ ] Implémenter `VaultAIProvider.ts`
- [ ] Tester connexion instance VaultAI on-premise
- [ ] Config par défaut pointant vers VaultAI
- [ ] UI pour configurer endpoint VaultAI
- [ ] Tests avec vrai backend VaultAI

### Phase 3 : Marketplace MVP (Semaine 4-5)

- [ ] Setup comptes marketplace (VS Code + JetBrains)
- [ ] Scripts de build automatisés
- [ ] CI/CD GitHub Actions
- [ ] Première release publique v1.0.0
- [ ] Documentation utilisateur

### Phase 4 : Features VaultAI Custom (Mois 2-3)

#### 4.1 Authentification Entreprise
- [ ] SSO integration (SAML, OAuth)
- [ ] RBAC (rôles utilisateurs)
- [ ] Audit logs

#### 4.2 RAG On-Premise
- [ ] Connecteur vers VaultAI RAG
- [ ] Indexation codebase entreprise
- [ ] Search sémantique dans knowledge base VaultAI

#### 4.3 Compliance & Governance
- [ ] Règles de sécurité configurables (ex: "ne jamais suggérer X")
- [ ] Blacklist de patterns de code
- [ ] Whitelist de dépendances autorisées
- [ ] Reporting pour admins IT

#### 4.4 Analytics Entreprise
- [ ] Dashboard usage pour admins
- [ ] Métriques productivité (lignes générées, temps gagné)
- [ ] ROI tracking

### Phase 5 : Scale & Industrialisation (Mois 4+)

- [ ] Support multi-instances VaultAI (dev/staging/prod)
- [ ] Profils de configuration par projet
- [ ] CLI pour admins (provisionning, config...)
- [ ] Plugins tiers (Jira, GitLab, etc.)

---

## ✅ Checklist de Validation

### Avant Release v1.0.0

#### Infrastructure
- [ ] Fork GitHub configuré avec upstream
- [ ] CI/CD GitHub Actions fonctionnel
- [ ] Secrets marketplace configurés
- [ ] Documentation README.md à jour

#### VS Code Extension
- [ ] Rebranding complet (nom, icônes, descriptions)
- [ ] Toutes les commandes renommées `vaultai.*`
- [ ] Chat fonctionnel
- [ ] Autocomplete fonctionnel
- [ ] Edit inline (Cmd/Ctrl+I) fonctionnel
- [ ] Configuration VaultAI provider OK
- [ ] Tests E2E passent
- [ ] Build .vsix sans erreurs
- [ ] Installation .vsix locale OK

#### JetBrains Plugin
- [ ] Rebranding complet
- [ ] Chat fonctionnel
- [ ] Autocomplete fonctionnel
- [ ] Configuration VaultAI provider OK
- [ ] Tests unitaires passent
- [ ] Build .zip sans erreurs
- [ ] Installation .zip locale OK

#### VaultAI Provider
- [ ] Connexion à instance VaultAI on-premise OK
- [ ] API calls fonctionnelles (chat, completion)
- [ ] Gestion erreurs (timeout, API down)
- [ ] Logs clairs pour debug

#### Documentation
- [ ] README.md pour utilisateurs
- [ ] Guide installation (VS Code + JetBrains)
- [ ] Guide configuration VaultAI instance
- [ ] FAQ (troubleshooting commun)
- [ ] CHANGELOG.md

#### Legal & Compliance
- [ ] LICENSE (Apache 2.0 maintenue)
- [ ] CONTRIBUTING.md adapté VaultAI
- [ ] Mentions Continue.dev (credit upstream)
- [ ] Privacy policy (pas de télémétrie)

#### Marketing
- [ ] Screenshots pour marketplace
- [ ] Vidéo démo (optionnel mais recommandé)
- [ ] Site web VaultAI mis à jour
- [ ] Annonce sur réseaux sociaux

---

## 📚 Resources & Next Steps

### Documentation Continue.dev à lire
- [CONTRIBUTING.md](https://github.com/continuedev/continue/blob/main/CONTRIBUTING.md)
- [Docs officielles](https://docs.continue.dev)
- [Architecture decisions](https://github.com/continuedev/continue/tree/main/docs)

### Tools Recommandés
- **VS Code** : Pour développer extension VS Code
- **IntelliJ IDEA** : Pour développer plugin JetBrains
- **NVM** : Pour gérer versions Node.js
- **Git GUI** : GitKraken ou Sourcetree (pour visualiser branches/merges)

### Community
- **Continue Discord** : Suivre pour updates upstream
- **VaultAI Discord/Slack** : Setup pour votre communauté d'utilisateurs

### Next Actions Immédiates

1. **Créer le fork GitHub** (5 min)
   ```bash
   # Sur GitHub.com
   # Fork https://github.com/continuedev/continue → VaultAI/vault-code-assistant
   ```

2. **Clone + setup upstream** (10 min)
   ```bash
   git clone https://github.com/VaultAI/vault-code-assistant.git
   cd vault-code-assistant
   git remote add upstream https://github.com/continuedev/continue.git
   git remote set-url --push upstream DISABLE
   ```

3. **Build Continue original** (30-60 min)
   ```bash
   nvm use
   npm install
   # Suivre Phase 2 du Plan de Setup
   ```

4. **Valider que Continue fonctionne** (30 min)
   - Tester chat, autocomplete, edit dans VS Code
   - Tester dans JetBrains si applicable

5. **Créer infrastructure VaultAI** (2-3h)
   - Suivre Phase 3 du Plan de Setup
   - Créer `vaultai/` folder + fichiers de base

6. **Premiers assets de branding** (1 jour)
   - Designer logos/icônes VaultAI
   - Définir couleurs & charte graphique

---

## 🎓 Bonnes Pratiques

### Git Workflow

```bash
# Routine mensuelle : sync upstream
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Puis merger dans vaultai-main
git checkout vaultai-main
git merge main
# Résoudre conflits si nécessaire
git push origin vaultai-main
```

### Avant Chaque Commit

```bash
# 1. Vérifier qu'on est sur la bonne branche
git branch

# 2. Vérifier les fichiers modifiés
git status

# 3. Build & test
npm run tsc:check  # TypeScript checks
npm test           # Unit tests

# 4. Commit avec message clair
git commit -m "feat(vaultai): add VaultAI provider authentication"
```

### Versioning Semver

- **Major (1.0.0 → 2.0.0)** : Breaking changes
- **Minor (1.0.0 → 1.1.0)** : Nouvelles features compatibles
- **Patch (1.0.0 → 1.0.1)** : Bug fixes

**Alignement avec Continue** :
- Si Continue passe de v1.3.x à v2.0.0 (breaking) → Review impact VaultAI
- Si Continue passe de v1.3.x à v1.4.0 (features) → Merge sans risque

### Tests Avant Release

**Checklist minimale** :
1. Build sans erreurs (VS Code + JetBrains)
2. Installation locale .vsix / .zip OK
3. Chat fonctionne avec VaultAI instance
4. Autocomplete fonctionne
5. Edit inline fonctionne
6. Configuration UI fonctionne

**Checklist complète** :
- Tous les tests automatisés passent
- Tests manuels sur Windows + macOS + Linux
- Tests avec plusieurs IDEs (VS Code, WebStorm, PyCharm, IntelliJ IDEA)
- Tests avec charge (autocomplete rapide, chat multi-messages)

---

## 🚨 Pièges à Éviter

### ❌ Ne PAS Faire

1. **Modifier directement les fichiers Continue core sans feature flag**
   - ❌ Éditer `core/config/default.ts` directement
   - ✅ Créer `vaultai/config/default.ts` + feature flag

2. **Hardcoder des strings VaultAI partout**
   - ❌ Strings "VaultAI" dispersées dans 50 fichiers
   - ✅ Centralisé dans `vaultai/config/branding.ts`

3. **Oublier de tester le merge upstream régulièrement**
   - ❌ Attendre 6 mois avant de merger upstream
   - ✅ Merger upstream tous les mois (même si pas de release immédiate)

4. **Renommer massivement les fichiers Continue**
   - ❌ Renommer `core/` en `vaultai-core/`
   - ✅ Garder la structure Continue, ajouter `vaultai/` folder

5. **Supprimer les providers Continue (OpenAI, Anthropic...)**
   - ❌ Garder uniquement VaultAI provider
   - ✅ Garder tous les providers (clients peuvent vouloir OpenAI + VaultAI)

### ✅ Best Practices

1. **Toujours tester upstream merge sur une branche séparée**
   ```bash
   git checkout -b test-upstream-merge
   git merge upstream/main
   # Tester builds, résoudre conflits
   # Si OK → merger dans main
   ```

2. **Documenter TOUS les changements VaultAI**
   - Fichier `VAULTAI_CHANGES.md` listant tous les fichiers modifiés
   - Permet de review lors des merges upstream

3. **Automatiser le branding**
   - Scripts pour appliquer/retirer le branding
   - Permet de tester Continue original vs VaultAI facilement

4. **Versioning indépendant**
   - VaultAI v1.0.0 peut être basé sur Continue v1.3.15
   - Pas besoin de synchroniser les versions

---

## 📞 Support

### Questions ?

- **GitHub Issues** : https://github.com/VaultAI/vault-code-assistant/issues
- **Email** : dev@vaultai.eu
- **Internal Slack** : #vaultai-coding-assistant

### Contributeurs

Ce document est maintenu par l'équipe VaultAI. Contributions bienvenues !

---

**Version**: 1.0  
**Dernière mise à jour**: 15 octobre 2025  
**Auteur**: Claude + Hugo (VaultAI)

