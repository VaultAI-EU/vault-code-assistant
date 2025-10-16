# VaultAI Coding Assistant - Fork Architecture

Ce dossier contient tous les éléments spécifiques à VaultAI pour rebrand Continue.dev en gardant la compatibilité totale avec les mises à jour upstream.

## Structure

```
vaultai/
├── config/
│   └── branding.ts                    # Constantes de branding centralisées
├── assets/
│   ├── icons/
│   │   ├── icon.png                   # Logo principal VS Code
│   │   └── sidebar-icon.png           # Icône sidebar VS Code
│   └── branding/
│       └── logo.svg                   # Logo SVG
└── extensions/
    ├── vscode/
    │   └── package.overlay.json       # Overlay branding VS Code
    └── intellij/
        └── (futur) gradle.overlay.properties
```

## Stratégie Overlay Minimaliste

Cette architecture utilise un pattern **overlay** qui permet de :

✅ **Zéro merge conflict** - on ne touche pas aux fichiers Continue
✅ **Maintenable** - les overlays JSON sont faciles à updater
✅ **Sûr** - changements isolés et réversibles
✅ **Syncronisable** - reste compatible avec les merges upstream

## Comment ça marche

### 1. Configuration Centralisée (`config/branding.ts`)

Toutes les constantes de branding VaultAI sont centralisées ici :

- Noms, URLs, emails
- Couleurs et design tokens
- Feature flags VaultAI

### 2. Assets Isolés (`assets/`)

Les logos et icônes VaultAI vivent ici, séparés des assets Continue.

Les symlinks dans `extensions/vscode/media/` pointent vers ces assets :

```bash
extensions/vscode/media/icon.png → ../../../vaultai/assets/icons/icon.png
```

### 3. Overlay Pattern (`extensions/vscode/package.overlay.json`)

Contient UNIQUEMENT les champs de branding à remplacer :

- `displayName`, `description`
- `publisher`, `author`
- `homepage`, `bugs`, `repository`
- `keywords`

### 4. Script d'Application (`scripts/vaultai/apply-branding.js`)

Le script merge l'overlay dans `extensions/vscode/package.json` de manière intelligente :

- Lit l'overlay et le package.json original
- Merge uniquement les champs branding
- Laisse intacts les IDs de commandes, configurations, etc.

## Usage

### Appliquer le branding VaultAI

```bash
# Via script shell
bash scripts/vaultai/apply-branding.sh

# Ou directement avec Node.js
node scripts/vaultai/apply-branding.js
```

### Retirer le branding et revenir à Continue

```bash
git checkout extensions/vscode/package.json
```

## Avantages pour les merges upstream

1. **Fichiers Continue intacts** - `extensions/vscode/src/`, `gui/`, `core/` etc. ne sont jamais modifiés
2. **Overlay JSON séparé** - `vaultai/extensions/vscode/package.overlay.json` ne rentre jamais en conflit avec `extensions/vscode/package.json`
3. **Assets isolés** - les symlinks pointent vers `vaultai/assets/`, pas vers les assets Continue
4. **IDs de commandes préservés** - tous les `continue.*` restent intacts, aucun conflit possible

## Workflow Git recommandé

```bash
# Sync avec Continue upstream
git fetch upstream
git merge upstream/main

# Le branding VaultAI n'est affecté par aucun conflit
# Car on ne modifie que l'overlay, pas le code Continue

# Appliquer le branding VaultAI après un merge
bash scripts/vaultai/apply-branding.sh

# Commit
git add .
git commit -m "Merge upstream Continue + apply VaultAI branding"
```

## Fichiers à éditer pour customiser

- **Branding & URLs** : `vaultai/config/branding.ts`
- **Metadata VS Code** : `vaultai/extensions/vscode/package.overlay.json`
- **Logos** : Placer dans `vaultai/assets/` (les symlinks se mettront à jour automatiquement)

## Points importants

⚠️ **NE PAS MODIFIER** :

- `extensions/vscode/src/` - utiliser feature flags si besoin
- `extensions/vscode/package.json` - toujours via l'overlay
- Les IDs de commandes `continue.*` - pour éviter les regressions

✅ **À MODIFIER** :

- `vaultai/config/branding.ts` - pour tous les éléments de branding
- `vaultai/extensions/vscode/package.overlay.json` - pour le metadata VS Code
- Les assets dans `vaultai/assets/`

## Future : Étendre à d'autres extensions

Le même pattern s'applique pour :

- JetBrains plugin : `vaultai/extensions/intellij/gradle.overlay.properties`
- GUI React : Configuration centralisée + imports de branding.ts

Voir `VAULTAI_FORK_STRATEGY.md` pour les détails complets.
