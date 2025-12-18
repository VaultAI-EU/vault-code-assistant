═══════════════════════════════════════════════════════════════
  VAULTAI EXTENSIONS - LIRE AVANT D'INSTALLER
═══════════════════════════════════════════════════════════════

Ce dossier contient 3 fichiers :

┌─────────────────────────────────────────────────────────────┐
│ 1. continue-1.3.18.vsix (97 MB)                             │
│    Plateforme : macOS Apple Silicon (M1/M2/M3)              │
│    ❌ NE PAS UTILISER SUR WINDOWS                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 2. continue-win32-x64-1.3.18.vsix (167 MB)                  │
│    Plateforme : Windows 64-bit                               │
│    ✅ UTILISER CE FICHIER SI VOUS ÊTES SUR WINDOWS          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 3. vaultai-code-assistant-intellij-1.0.0-vaultai.zip        │
│    Pour : IntelliJ IDEA, PyCharm, WebStorm, etc.            │
└─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════
  INSTALLATION WINDOWS (VS CODE)
═══════════════════════════════════════════════════════════════

⚠️  IMPORTANT : Utiliser continue-win32-x64-1.3.18.vsix (167 MB)

Méthode 1 : Via PowerShell (Recommandée)
─────────────────────────────────────────

1. Ouvrir PowerShell

2. Si une ancienne version est installée, la désinstaller :
   
   code --uninstall-extension VaultAI.continue
   Remove-Item -Path "$env:USERPROFILE\.vscode\extensions\vaultai.continue-*" -Recurse -Force

3. Installer la nouvelle extension :
   
   code --install-extension "C:\chemin\vers\continue-win32-x64-1.3.18.vsix"
   
   (Remplacer par le vrai chemin du fichier)

4. Redémarrer VS Code complètement


Méthode 2 : Via l'interface VS Code
────────────────────────────────────

1. Ouvrir VS Code
2. Ctrl+Shift+P
3. Taper : Extensions: Install from VSIX...
4. Sélectionner : continue-win32-x64-1.3.18.vsix (167 MB)
5. Cliquer sur "Reload" quand demandé


═══════════════════════════════════════════════════════════════
  INSTALLATION MACOS (VS CODE)
═══════════════════════════════════════════════════════════════

⚠️  IMPORTANT : Utiliser continue-1.3.18.vsix (97 MB)

Terminal :
──────────

code --install-extension /chemin/vers/continue-1.3.18.vsix


═══════════════════════════════════════════════════════════════
  INSTALLATION JETBRAINS (IntelliJ, PyCharm, etc.)
═══════════════════════════════════════════════════════════════

Fichier : vaultai-code-assistant-intellij-1.0.0-vaultai.zip

1. Ouvrir IntelliJ IDEA / PyCharm / WebStorm / etc.
2. File > Settings > Plugins (ou Ctrl+Alt+S)
3. Cliquer sur l'icône ⚙️ (Settings)
4. Sélectionner "Install Plugin from Disk..."
5. Sélectionner le fichier .zip
6. Cliquer OK
7. Redémarrer l'IDE


═══════════════════════════════════════════════════════════════
  PROBLÈMES COURANTS
═══════════════════════════════════════════════════════════════

❌ Erreur : "node_sqlite3.node is not a valid Win32 application"

Cause : Vous avez installé la version macOS sur Windows

Solution : 
1. Désinstaller l'extension
2. Supprimer C:\Users\VOTRE_NOM\.vscode\extensions\vaultai.continue-*
3. Installer continue-win32-x64-1.3.18.vsix (167 MB)


❌ Extension ne charge pas / Interface n'apparaît pas

Solution :
1. Ctrl+Shift+P > "Developer: Reload Window"
2. Si ça ne marche pas, redémarrer VS Code complètement


❌ Commandes "continue.xxx not found"

Solution :
1. Vérifier que la bonne extension est installée (voir taille)
2. Redémarrer VS Code
3. Vérifier dans Extensions que VaultAI est activée


═══════════════════════════════════════════════════════════════
  VÉRIFICATION
═══════════════════════════════════════════════════════════════

Après installation, vérifier que ça fonctionne :

1. L'icône VaultAI apparaît dans la barre latérale gauche
2. Ouvrir un fichier code
3. Tester : Ctrl+L (ouvre le chat)
4. Tester : Ctrl+I (inline edit)


═══════════════════════════════════════════════════════════════
  SUPPORT
═══════════════════════════════════════════════════════════════

En cas de problème :
- Email : support@vaultai.eu
- Fournir : logs VS Code (Ctrl+Shift+P > "Developer: Show Logs")


═══════════════════════════════════════════════════════════════
Date : 3 novembre 2025
Version : 1.3.18
═══════════════════════════════════════════════════════════════
