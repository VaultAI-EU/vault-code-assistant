# 🚀 Publication Rapide sur VS Code Marketplace

## ⚡ Version courte (5 étapes essentielles)

### 1️⃣ Créer un compte éditeur (5 min)

```
1. Va sur https://marketplace.visualstudio.com/manage
2. Connecte-toi avec Microsoft
3. Crée un publisher avec ID : "VaultAI"
```

### 2️⃣ Créer un Personal Access Token (3 min)

```
1. Va sur https://dev.azure.com
2. User Settings → Personal Access Tokens → New Token
3. Nom : "VaultAI Publishing"
4. Scope : Marketplace → Manage
5. COPIE LE TOKEN !
```

### 3️⃣ Se connecter avec vsce (1 min)

```bash
vsce login VaultAI
# Colle ton token quand demandé
```

### 4️⃣ Publier ! (2 min)

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode
vsce publish
```

### 5️⃣ Vérifier (1 min)

```
https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant
```

---

## 📋 Checklist avant publication

- [ ] Extension testée localement (elle fonctionne)
- [ ] `vsce` installé (`npm install -g @vscode/vsce`)
- [ ] Compte éditeur créé sur marketplace.visualstudio.com
- [ ] Personal Access Token généré
- [ ] Token sauvegardé de manière sécurisée
- [ ] Connecté avec `vsce login VaultAI`

---

## 🎯 Utilisation du script automatisé

```bash
# Depuis extensions/vscode/
./scripts/publish-to-marketplace.sh patch   # 1.3.18 → 1.3.19
./scripts/publish-to-marketplace.sh minor   # 1.3.18 → 1.4.0
./scripts/publish-to-marketplace.sh major   # 1.3.18 → 2.0.0
```

Le script fait tout automatiquement :

- ✅ Rebuild complet (core + GUI + extension)
- ✅ Vérification du package
- ✅ Incrémentation de version
- ✅ Publication sur le Marketplace

---

## 📚 Documentation complète

Pour plus de détails, voir : `vaultai/PUBLISH_TO_MARKETPLACE.md`
