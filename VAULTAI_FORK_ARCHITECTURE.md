# VaultAI Fork Architecture - Complete Guide

**Status**: ✅ Production Ready  
**Date**: 16 octobre 2025  
**Maintainer**: VaultAI Team

---

## Executive Summary

VaultAI est un **fork maintenable de Continue.dev** qui peut être **customisé librement** sans créer de **merge conflicts** lors des syncs upstream.

**La clé**: Dual branches architecture avec documentation complète.

```
git branches:
┌─ main ────────────→ upstream/main (Continue)
│                     ✅ 100% Continue, zéro modification
│                     ✅ Sync automatique upstream
│
└─ vaultai-main ────  (VaultAI Customisé)
   ↓
   ✅ Toutes les modifications GUI
   ✅ Branding VaultAI
   ✅ Features custom VaultAI
   ✅ Peut être rebasé sur main régulièrement
```

---

## Architecture Fichiers

```
vault-code-assistant/
│
├── vaultai/                              # 🔴 TOUS les fichiers VaultAI ici
│   ├── config/
│   │   └── branding.ts                   # Constants branding centralisées
│   ├── assets/
│   │   ├── icons/
│   │   │   ├── icon.png
│   │   │   └── sidebar-icon.png
│   │   └── branding/
│   │       └── logo.svg
│   ├── extensions/vscode/
│   │   └── package.overlay.json          # Overlay pour VS Code metadata
│   ├── VAULTAI_CHANGES.md                # 🔑 DOCUMENTATION: Fichiers modifiés
│   └── ...
│
├── extensions/vscode/
│   ├── package.json                      # ✏️ MODIFIÉ (branding VaultAI)
│   ├── media/
│   │   ├── icon.png → vaultai/...       # Symlink
│   │   └── sidebar-icon.png → vaultai/.. # Symlink
│   └── src/                              # ✅ INTACT (100% Continue logic)
│
├── gui/src/                              # 🟡 PARTIELLEMENT MODIFIÉ
│   ├── pages/
│   │   ├── AddNewModel.tsx              # ✏️ MODIFIÉ (VaultAI provider)
│   │   ├── Settings.tsx                 # ✏️ MODIFIÉ (branding URLs)
│   │   └── ...
│   └── components/
│       ├── mainInput.tsx                 # ✏️ MODIFIÉ (branding strings)
│       └── ...
│
├── core/                                 # ✅ INTACT (100% Continue)
├── extensions/intellij/                  # ✅ INTACT (100% Continue)
├── extensions/cli/                       # ✅ INTACT (100% Continue)
│
└── scripts/vaultai/
    ├── apply-branding.js                # Script: applique branding extension
    ├── merge-upstream.sh                 # Script: guide pour merge upstream
    └── ...

```

### Pattern Important

✅ **Fichiers Continue JAMAIS modifiés**:

- `extensions/vscode/src/` (logique extension)
- `gui/src/` (mais branding strings changés)
- `core/` (logique métier)

✏️ **Fichiers customisés**:

- `extensions/vscode/package.json` (métadata, branding)
- `gui/src/pages/AddNewModel.tsx` (provider VaultAI custom)
- `gui/src/pages/Settings.tsx` (URLs branding)
- `gui/src/components/mainInput.tsx` (branding strings)

🔴 **Fichiers VaultAI (zéro conflit)**:

- Tout ce qui est dans `vaultai/`

---

## Stratégie: Pourquoi ça marche?

### Sans cette architecture (Cauchemar ❌)

```
git pull upstream/main
→ CONFLICT in extensions/vscode/package.json
→ CONFLICT in gui/src/pages/AddNewModel.tsx
→ CONFLICT in gui/src/components/mainInput.tsx
→ 🔥 Tout est messed up
```

### Avec cette architecture (Smooth ✅)

```
Branch main:
git pull upstream/main
→ ✅ Zéro conflit
→ Continue reste 100% original

Branch vaultai-main:
git merge main
→ 🟡 Quelques conflits possibles (documentés)
→ Mais faciles à résoudre (on sait exactement où on a modifié)
→ ✅ Merge réussi
```

---

## Workflow Jour-à-Jour

### Travailler sur VaultAI

```bash
# Checkout branche production
git checkout vaultai-main
git pull origin vaultai-main

# Modifier les fichiers
# ... code changes ...

# Commit
git add .
git commit -m "feat: Add custom VaultAI config UI"
git push origin vaultai-main
```

### Sync Mensuelle avec Continue

```bash
# Exécuter le script helper
bash scripts/vaultai/merge-upstream.sh

# Le script:
# 1. git pull upstream/main dans 'main'
# 2. Merge 'main' dans 'vaultai-main'
# 3. Guide pour résoudre les conflicts

# Si tout va bien:
git push origin vaultai-main
```

---

## Résoudre les Conflits

### Conflict Type 1: Branding Strings (Facile ✅)

```bash
# Fichier: gui/src/components/mainInput.tsx
<<<<<<< HEAD (vaultai-main)
const title = "VaultAI - Ask anything";
=======
const title = "Continue - Ask anything";
>>>>>>> main
```

**Solution**: Garder VaultAI (c'est notre customization)

```bash
const title = "VaultAI - Ask anything";
```

### Conflict Type 2: Continue améliore une section (Moyen ⚠️)

```bash
# Fichier: gui/src/pages/AddNewModel.tsx
# Continue a modifié le rendu du form...
<<<<<<< HEAD (vaultai-main)
// Notre custom VaultAI provider UI
<VaultAIProviderConfig />
=======
// Continue a complètement refactorisé ça
<ModernProviderSelector />
>>>>>>> main
```

**Solution**: Adapter notre custom à la nouvelle structure

```bash
<ModernProviderSelector>
  {/* Notre section VaultAI intégrée */}
  <VaultAIProviderConfig />
</ModernProviderSelector>
```

### Conflict Type 3: On ne sait pas (Rare 😅)

→ Lire `vaultai/VAULTAI_CHANGES.md` pour comprendre ce qu'on a modifié  
→ Chercher `<<<<<<< HEAD` pour voir les différences  
→ Tester que ça compile après fix  
→ Si vraiment bloqué: `git merge --abort` et demander help

---

## Branche Publishing

### Development Flow

```
vaultai-main (production)
     ↓
   build
     ↓
release tag (v1.0.0)
     ↓
publish to marketplace
```

### Never Publish from `main`

⚠️ **IMPORTANT**: Ne JAMAIS publier depuis `main` (Continue original)!

```bash
# ✅ BON: Publier depuis vaultai-main
git checkout vaultai-main
npm run package
# Publish à marketplace

# ❌ MAUVAIS: Publier depuis main
git checkout main
npm run package
# ⚠️ Va publier Continue branding, pas VaultAI!
```

---

## Guide Complet: Premier Upstream Merge

### Before (First Time)

Tu as les deux branches:

- `main`: sync Continue (jamais touché)
- `vaultai-main`: VaultAI customisé

### Execute

```bash
# 1. Lancer le script
bash scripts/vaultai/merge-upstream.sh

# 2. Si pas de conflit:
git push origin vaultai-main
# ✅ Fini!

# 3. Si conflits:
# Script t'aide et dit quoi faire...
# (lire VAULTAI_CHANGES.md)
# (résoudre les conflits)
npm run build  # Vérifier compilation
git add .
git commit -m "Merge upstream + resolve VaultAI customizations"
git push origin vaultai-main
```

### After

```
vaultai-main maintenant a:
✅ Tous les improvements Continue (bug fixes, features)
✅ Toutes les customizations VaultAI (préservées)
✅ Peut être mergé à nouveau dans 1 mois
```

---

## Maintenance Checklist

### Weekly

- [ ] Travailler sur `vaultai-main` normalement
- [ ] Committer tes changements VaultAI

### Monthly

- [ ] Exécuter `bash scripts/vaultai/merge-upstream.sh`
- [ ] Résoudre les conflits si nécessaire
- [ ] Tester que tout fonctionne
- [ ] Mettre à jour `vaultai/VAULTAI_CHANGES.md` si nouvelles modifications

### Quarterly

- [ ] Review `vaultai/VAULTAI_CHANGES.md` au complet
- [ ] Vérifier que toutes nos modifications y sont documentées
- [ ] Nettoyer les branches mortes

---

## FAQ

**Q: Pourquoi 2 branches et pas juste 1?**  
A: Parce que ça permet de garder `main` 100% propre (zéro modifications), ce qui facilite les syncs upstream. La vraie production c'est `vaultai-main`.

**Q: Et si Continue casse quelque chose dans un merge?**  
A: On teste avec `npm run build` et `F5` dans VS Code. Si ça casse, on peut rollback avec `git merge --abort`.

**Q: On peut ajouter des features custom?**  
A: Oui! C'est tout l'intérêt! Tu modifies `gui/src/pages/AddNewModel.tsx`, tu documentes dans `VAULTAI_CHANGES.md`, et tu pushes sur `vaultai-main`.

**Q: Continue me supprime un composant qu'on avait customisé?**  
A: Continue accepte la suppression, pas de conflit. Tu dois décider: garder notre version ou accepter la suppression Continue. **Always test** après.

**Q: On peut revert à Continue original?**  
A: Oui: `git checkout main`. Tu as toujours Continue pur en backup.

---

## Resources

- `vaultai/VAULTAI_CHANGES.md` - Documenter les modifications
- `scripts/vaultai/merge-upstream.sh` - Script merge helper
- `scripts/vaultai/apply-branding.js` - Script branding extension
- `vaultai/config/branding.ts` - Constants branding

---

## Support

**Questions?** Consulte:

1. Ce document (VAULTAI_FORK_ARCHITECTURE.md)
2. `vaultai/VAULTAI_CHANGES.md` (pour détails modifications)
3. `scripts/vaultai/merge-upstream.sh` (pour process merge)

**Bloqué?** → `git merge --abort` et relire ces docs.

---

**Version**: 1.0  
**Status**: ✅ Production Ready  
**Last Updated**: 16 octobre 2025
