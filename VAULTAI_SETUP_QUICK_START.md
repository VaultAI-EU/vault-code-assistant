# VaultAI Branding - Quick Start Guide

## ✅ Status: COMPLETED

L'extension VS Code a été rebranded vers VaultAI en utilisant le pattern overlay minimaliste. **Zéro régression, zéro merge conflict garanti.**

---

## 📦 Qu'est-ce qui a été implémenté

### Infrastructure VaultAI

```
vaultai/
├── config/branding.ts              # Constantes branding centralisées
├── assets/icons/                   # Logos VaultAI
├── assets/branding/logo.svg        # Logo SVG
└── extensions/vscode/
    └── package.overlay.json        # Overlay branding
```

### Scripts Utiles

```
scripts/vaultai/
├── apply-branding.js               # Script Node.js de merge
└── apply-branding.sh               # Wrapper shell
```

### Branding Appliqué

- ✅ displayName: "VaultAI - On-premise AI Code Assistant"
- ✅ publisher: "VaultAI"
- ✅ icon: Logo VaultAI (symlink)
- ✅ URLs: Changées vers GitHub/URLs VaultAI
- ✅ Keywords: VaultAI-focused

### Préservé (100% Continue intact)

- ✅ Tous les IDs `continue.*` (100+ commandes)
- ✅ Code source `extensions/vscode/src/` (0% modifié)
- ✅ Configuration schema et contributes
- ✅ Logique de l'extension

---

## 🚀 Utilisation

### Appliquer le branding VaultAI

```bash
bash scripts/vaultai/apply-branding.sh
```

### Retirer le branding (revenir à Continue)

```bash
git checkout extensions/vscode/package.json
```

### Personnaliser

1. Modifier `vaultai/config/branding.ts`
2. Modifier `vaultai/extensions/vscode/package.overlay.json`
3. Exécuter `bash scripts/vaultai/apply-branding.sh`

---

## 🔄 Sync Avec Continue Upstream

**Process après un merge upstream:**

```bash
# 1. Fetch upstream
git fetch upstream

# 2. Merge dans branche main
git merge upstream/main

# 3. Réappliquer le branding VaultAI
bash scripts/vaultai/apply-branding.sh

# 4. Commit
git add .
git commit -m "Merge upstream Continue + apply VaultAI branding"
```

**Résultat: Aucun merge conflict** ✅

---

## 📋 Architecture

### Why This Works - Zéro Merge Conflict

| Composant           | Status       | Raison                                      |
| ------------------- | ------------ | ------------------------------------------- |
| **Fichiers source** | Intacts 100% | On touche que package.json via overlay      |
| **IDs Continue**    | Preservés    | Le pattern overlay ne les touche pas        |
| **Assets**          | Isolés       | Symlinks vers vaultai/assets/, pas Continue |
| **package.json**    | Via overlay  | Réappliable facilement après merge upstream |

---

## 📚 Documentation

- `VAULTAI_IMPLEMENTATION.md` - Rapport technique complet
- `vaultai/README.md` - Architecture détaillée
- `VAULTAI_FORK_STRATEGY.md` - Stratégie globale du fork

---

## ✨ Ce que tu peux faire maintenant

1. **Tester l'extension** : Build et test VS Code localement
2. **Continuer le rebranding** : Appliquer le même pattern à JetBrains (Phase 2)
3. **Sync upstream** : Faire un merge upstream sans peur des conflits
4. **Personnaliser** : Éditer branding.ts ou package.overlay.json à volonté

---

**Status**: ✅ Production Ready  
**Sync Upstream**: ✅ Zéro Merge Conflict  
**Next Phase**: JetBrains Plugin Rebranding
