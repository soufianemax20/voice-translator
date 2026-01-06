# 🚀 Guide d'Installation Flutter pour Antigravity

## 📋 Installation Rapide de Flutter

### Option 1 : Installation Manuelle (Recommandé)

#### Étape 1 : Télécharger Flutter

1. **Téléchargez Flutter SDK** :
   - 🌐 [Lien direct ZIP](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip)
   - 📖 [Documentation officielle](https://docs.flutter.dev/get-started/install/windows)

2. **Extrayez le ZIP** :
   ```powershell
   # Créer le dossier
   mkdir C:\src
   
   # Extraire Flutter
   # (Utilisez l'explorateur ou Expand-Archive)
   ```

#### Étape 2 : Ajouter Flutter au PATH

**Méthode 1 : Variables d'environnement (Interface)**
1. Appuyez sur `Windows + R`
2. Tapez `sysdm.cpl` et appuyez sur Entrée
3. Allez dans l'onglet "Avancé"
4. Cliquez sur "Variables d'environnement"
5. Double-cliquez sur "Path" dans les variables utilisateur
6. Cliquez sur "Nouveau"
7. Ajoutez : `C:\src\flutter\bin`
8. Cliquez OK partout

**Méthode 2 : PowerShell (Temporaire)**
```powershell
$env:Path += ";C:\src\flutter\bin"
```

**Méthode 3 : PowerShell (Permanent)**
```powershell
[Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";C:\src\flutter\bin",
    "User"
)
```

#### Étape 3 : Vérifier l'installation

```powershell
# Ouvrir un NOUVEAU terminal
flutter --version
flutter doctor
```

#### Étape 4 : Accepter les licences

```powershell
flutter doctor --android-licenses
# Tapez 'y' pour accepter toutes les licences
```

---

### Option 2 : Installation Automatique avec Script

Double-cliquez sur : `SETUP_AND_RUN.bat`

Le script va :
1. Vérifier si Flutter est installé
2. Vous guider pour l'installation si nécessaire
3. Installer les dépendances automatiquement
4. Lancer l'application

---

## 🚀 Lancer l'Application avec Hot Reload

### Une fois Flutter installé :

```bash
cd "C:\Users\rapde\Desktop\INSTANT TRANSLAT\flutter_voice_translator"

# Installer les dépendances
flutter pub get

# Lancer sur Chrome (Hot Reload activé!)
flutter run -d chrome
```

### 🔥 Hot Reload - C'est Quoi?

**Hot Reload** permet de voir vos modifications de code **instantanément** sans redémarrer l'app!

**Comment l'utiliser :**
1. Lancez l'app avec `flutter run`
2. Modifiez n'importe quel fichier `.dart`
3. Sauvegardez (Ctrl+S)
4. **Les changements apparaissent immédiatement!** ⚡

**Raccourcis clavier :**
- `r` - Hot Reload (recharger le code)
- `R` - Hot Restart (redémarrer l'app)
- `q` - Quitter
- `h` - Aide
- `p` - Performance overlay
- `w` - Widget inspector

---

## 📱 Plateformes Disponibles

### 🌐 Web (Chrome) - **Le Plus Rapide**

```bash
flutter run -d chrome
```

**Avantages :**
- ✅ Pas besoin d'appareil
- ✅ Hot Reload ultra-rapide
- ✅ DevTools intégrés
- ✅ Parfait pour développement

### 📱 Android

```bash
# Avec appareil connecté
flutter run

# Ou spécifier l'appareil
flutter run -d <device-id>
```

**Prérequis :**
- Téléphone Android en mode développeur
- Débogage USB activé
- OU émulateur Android lancé

### 🖥️ Windows Desktop

```bash
flutter run -d windows
```

**Avantages :**
- ✅ App native Windows
- ✅ Performances optimales
- ✅ Pas besoin de navigateur

---

## 🔧 Commandes Utiles

### Développement
```bash
# Lancer avec Hot Reload
flutter run

# Nettoyer le projet
flutter clean

# Installer les dépendances
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade
```

### Debug
```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Vérifier Flutter
flutter doctor -v
```

### Build
```bash
# Build Web
flutter build web

# Build Android APK
flutter build apk

# Build Windows
flutter build windows
```

---

## 🎯 Workflow de Développement Recommandé

### 1️⃣ Premier Lancement

```bash
# 1. Installer Flutter (voir ci-dessus)

# 2. Naviguer vers le projet
cd "C:\Users\rapde\Desktop\INSTANT TRANSLAT\flutter_voice_translator"

# 3. Installer les dépendances
flutter pub get

# 4. Lancer sur Chrome
flutter run -d chrome
```

### 2️⃣ Développement avec Hot Reload

```bash
# Terminal 1 : Lancer l'app
flutter run -d chrome

# Terminal 2 (optionnel) : Watch des changements
# L'app se recharge automatiquement quand vous sauvegardez!
```

### 3️⃣ Modifier le Code

1. Ouvrez VS Code ou votre éditeur préféré
2. Modifiez les fichiers dans `lib/`
3. Sauvegardez (Ctrl+S)
4. **Voyez les changements instantanément!** ⚡

**Exemple de modification :**
```dart
// lib/main.dart
// Changez la couleur primaire
primaryColor: const Color(0xFFFF6B35), // Orange
// En
primaryColor: const Color(0xFF00BCD4), // Cyan

// Sauvegardez → Changement instantané!
```

---

## 🐛 Dépannage

### Problème : "flutter: command not found"

**Solution :**
```powershell
# Fermez TOUS les terminaux
# Ouvrez un NOUVEAU terminal
# Vérifiez :
where flutter

# Si vide, ajoutez au PATH
```

### Problème : "Waiting for another flutter command..."

**Solution :**
```bash
# Tuez les processus Flutter
taskkill /F /IM dart.exe
taskkill /F /IM flutter.exe

# Relancez
flutter run
```

### Problème : "No devices found"

**Solution Web :**
```bash
# Chrome devrait être détecté automatiquement
flutter devices

# Si non listé, installez Chrome
```

**Solution Android :**
```bash
# Vérifiez les appareils
adb devices

# Ou lancez un émulateur
flutter emulators
flutter emulators --launch <emulator-id>
```

### Problème : Erreur de dépendances

**Solution :**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

---

## 📊 Flutter DevTools

### Lancer DevTools

```bash
# Pendant que l'app tourne
flutter pub global activate devtools
flutter pub global run devtools
```

**Fonctionnalités :**
- 🎨 Widget Inspector - Explorer la hiérarchie des widgets
- 📊 Performance - Profiler les performances
- 🔍 Debugger - Debugger le code
- 📡 Network - Monitorer les requêtes
- 💾 Memory - Analyser la mémoire

---

## ✨ Conseils pour Antigravity

### Fichiers à Modifier Fréquemment

```
lib/
├── main.dart                    # Point d'entrée, thème
├── screens/
│   └── translation_screen.dart  # Écran principal, UI
├── widgets/
│   ├── speaker_card.dart        # Carte de speaker
│   └── waveform_visualizer.dart # Visualiseur audio
├── providers/
│   └── translation_provider.dart # Logique métier
└── services/
    ├── elevenlabs_service.dart  # API 11Labs (Scribe V2!)
    └── aws_translate_service.dart # API AWS
```

### Hot Reload vs Hot Restart

**Hot Reload (r)** - ⚡ Ultra-rapide
- Recharge le code
- Garde l'état de l'app
- **Utilisez pour:** Modifications UI, widgets, fonctions

**Hot Restart (R)** - 🔄 Rapide
- Redémarre l'app
- Réinitialise l'état
- **Utilisez pour:** Modifications main(), providers, global state

---

## 🎉 C'est Prêt!

**Pour commencer immédiatement :**

```bash
# Option 1 : Script automatique
SETUP_AND_RUN.bat

# Option 2 : Manuel
cd "C:\Users\rapde\Desktop\INSTANT TRANSLAT\flutter_voice_translator"
flutter pub get
flutter run -d chrome
```

**Profitez du Hot Reload et développez en temps réel! 🔥**

---

*Guide créé pour Antigravity  
Version: 1.0  
Date: 2026-01-06*
