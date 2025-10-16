# VaultAI Fork - Modifications vs Continue

**Date**: 16 octobre 2025  
**Branche**: `vaultai-main` (diverge de `main` qui reste en sync avec Continue upstream)  
**Stratégie**: Dual branches + comprehensive documentation pour faciliter les merges upstream

---

## Workflow Git Recommandé

```bash
# QUOTIDIEN: Travailler sur vaultai-main
git checkout vaultai-main
git pull origin vaultai-main

# MAINTENANCE MENSUELLE: Sync avec Continue
git fetch upstream
git checkout main
git pull upstream/main
git push origin main

# MERGE VaultAI: Incorporer les changements Continue
git checkout vaultai-main
git merge main

# Si conflits: Lire ce document pour comprendre ce qu'on change
# Puis résoudre intelligemment en gardant nos features + nouveautés Continue

git add .
git commit -m "Merge upstream Continue + resolve VaultAI customizations"
git push origin vaultai-main
```

---

## Architecture Branche

### `main` (Continue Original)

- ✅ **100% Continue**
- ✅ Sync automatique avec `upstream/main`
- ✅ Zéro modification VaultAI
- **Usage**: Pull bucket pour syncs upstream

### `vaultai-main` (VaultAI Customisé)

- ✅ **Based on `main` + VaultAI customizations**
- ✅ Contient toutes les modifications GUI
- ✅ Contient le branding VaultAI
- **Usage**: Production branch pour extensions VaultAI

---

## Fichiers Modifiés (IMPORTANT pour merges)

### ✅ VS Code Extension (Sûr - peu de conflits)

| Fichier                                    | Modifications      | Conflit Risk | Notes                               |
| ------------------------------------------ | ------------------ | ------------ | ----------------------------------- |
| `extensions/vscode/package.json`           | Branding strings   | 🟢 FAIBLE    | Via overlay pattern, peu de changes |
| `extensions/vscode/media/icon.png`         | Symlink → vaultai/ | 🟢 FAIBLE    | Symlink stable                      |
| `extensions/vscode/media/sidebar-icon.png` | Symlink → vaultai/ | 🟢 FAIBLE    | Symlink stable                      |

### 🟡 GUI React (Attention pendant merges)

| Fichier                            | Modifications              | Conflit Risk | Zones de Conflit                     |
| ---------------------------------- | -------------------------- | ------------ | ------------------------------------ |
| `gui/src/pages/AddNewModel.tsx`    | Custom VaultAI provider UI | 🟡 MOYEN     | Lignes 200-250 (model configuration) |
| `gui/src/components/mainInput.tsx` | Branding strings           | 🟡 MOYEN     | Lignes 50-100 (text labels)          |
| `gui/src/pages/Settings.tsx`       | VaultAI branding           | 🟡 MOYEN     | Lignes 100-150 (docs links)          |
| `gui/src/index.tsx`                | Branding constants import  | 🟢 FAIBLE    | Une seule ligne                      |

### ✅ Fichiers NON modifiés (Safe zone - zéro risque)

```
gui/src/pages/History.tsx       ← 100% Continue original
gui/src/pages/Editing.tsx        ← 100% Continue original
gui/src/components/Chat.tsx      ← 100% Continue original
core/                             ← 100% Continue original
extensions/intellij/             ← 100% Continue original
extensions/cli/                  ← 100% Continue original
```

---

## Modifications GUI Expliquées

### 1. Branding Strings Simples

**Fichiers**: `gui/src/pages/AddNewModel.tsx`, `gui/src/components/mainInput.tsx`

**Changements**:

```tsx
// AVANT (Continue)
"Configure your Continue instance";
"Continue will use these models...";
"Learn more at docs.continue.dev";

// APRÈS (VaultAI)
"Configure your VaultAI instance";
"VaultAI will use these models...";
"Learn more at docs.vaultai.eu";
```

**Impact sur merge**:

- 🟢 Faible si Continue change la structure (on adapte les lignes)
- 🟡 Moyen si Continue renomme les composants (vérifier les imports)

### 2. Custom VaultAI Provider UI

**Fichier**: `gui/src/pages/AddNewModel.tsx` (lignes ~200-250)

**Changements**:

```tsx
// NOUVEAU: Section VaultAI-spécifique
<VaultAIProviderConfiguration />;

// MODIFIÉ: Default model selection
defaultModel = "vaultai"; // était "gpt-4"
```

**Impact sur merge**:

- 🟡 Moyen: Continue peut ajouter de nouveaux providers
- Solution: Vérifier que notre section VaultAI reste séparée du reste

### 3. Documentation Links

**Fichier**: `gui/src/pages/Settings.tsx`

**Changements**:

```tsx
// AVANT
readMoreUrl: "https://docs.continue.dev/telemetry";

// APRÈS
readMoreUrl: "https://docs.vaultai.eu/telemetry";
```

**Impact sur merge**:

- 🟢 Très faible: c'est juste des URLs

---

## Stratégie de Merge Upstream

### Cas 1: Continue modifie un fichier qu'on a modifié

```bash
# SCENARIO: Continue modifie gui/src/pages/AddNewModel.tsx

git merge upstream/main
# ⚠️ CONFLICT in gui/src/pages/AddNewModel.tsx

# Solution:
# 1. Ouvrir le fichier et voir les conflits
# 2. Garder la STRUCTURE Continue (c'est important)
# 3. Réappliquer nos changements VaultAI dans cette nouvelle structure
# 4. Tester que tout compile

git add gui/src/pages/AddNewModel.tsx
git commit -m "Merge upstream + reapply VaultAI customizations"
```

### Cas 2: Continue renomme/réorganise un composant

```bash
# SCENARIO: Continue renomme AddNewModel.tsx → ModelConfiguration.tsx

# Il faut:
# 1. Accepter le renommage Continue
# 2. Réappliquer nos modifications au nouveau fichier
# 3. Tester

git rm gui/src/pages/AddNewModel.tsx
git add gui/src/pages/ModelConfiguration.tsx
# (puis réappliquer les modifications)
```

### Cas 3: Pas de conflit

```bash
git merge upstream/main
# ✅ Pas de conflit!
# Continuev s'est amélioré, nos customizations restent ✓
git push origin vaultai-main
```

---

## Commande Helper: `merge-upstream.sh`

Voir `scripts/vaultai/merge-upstream.sh` pour le script automatisé qui guide le processus.

---

## Checklist Avant Commit

Avant de faire un commit VaultAI sur `vaultai-main`:

- [ ] Code compile (`npm run build`)
- [ ] Extension fonctionne en local (`F5` dans VS Code)
- [ ] Pas de "Continue" visible si c'est du branding VaultAI
- [ ] Les modifcations sont bien documentées ici
- [ ] Si changement GUI: marquer le fichier dans ce document

---

## Fichiers VaultAI Infrastructure

Ces fichiers ne vont JAMAIS rentrer en conflit avec Continue (zéro risque):

```
vaultai/
├── config/branding.ts              ✅ Zéro conflit
├── assets/                          ✅ Zéro conflit
├── extensions/vscode/
│   └── package.overlay.json         ✅ Zéro conflit
├── gui/
│   └── branding-replacements.json   ✅ Zéro conflit
├── VAULTAI_CHANGES.md               ✅ Zéro conflit
└── ...
```

---

## FAQ Merge

**Q: Qu'est-ce qu'on fait si un upstream pull change quelque chose qu'on a rebranding?**  
A: On merge normalement, puis on réapplique nos changements branding au-dessus. Les deux cohabitent bien!

**Q: Continue a supprimé un fichier qu'on avait modifié?**  
A: Super! Ça veut dire Continue a refactorisé. On accepte leur suppression, pas de conflit.

**Q: On a cassé un merge, comment revenir?**  
A: `git merge --abort` puis on recommence en lisant ce document.

**Q: Combien de fois il faut merger upstream par an?**  
A: Idéalement tous les mois pour garder le fork frais. Plus tu attends, plus les conflits s'accumulent.

---

## Version Control

- **Last Updated**: 16 octobre 2025
- **VaultAI Version**: 1.0 (aligned with Continue v1.3.18)
- **Strategy**: Dual Branches + Comprehensive Documentation
- **Maintainer**: VaultAI Team
