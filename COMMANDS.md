# 🚀 Commandes Essentielles - VoiceTranslator

## 📦 Installation Initiale

### 1. Installer Flutter

#### Windows (PowerShell Admin)
```powershell
# Télécharger et extraire Flutter
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip" -OutFile "$env:USERPROFILE\Downloads\flutter.zip"
Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter.zip" -DestinationPath "C:\src"

# Ajouter au PATH (permanent)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "User")

# Vérifier
flutter doctor
```

#### macOS
```bash
# Avec Homebrew
brew install flutter

# Vérifier
flutter doctor
```

#### Linux
```bash
# Avec snap
sudo snap install flutter --classic

# Vérifier
flutter doctor
```

---

## 🛠️ Commandes de Développement

### Premier Lancement
```bash
# Naviguer vers le projet
cd "C:\Users\rapde\Desktop\INSTANT TRANSLAT\flutter_voice_translator"

# Installer les dépendances
flutter pub get

# Vérifier les appareils disponibles
flutter devices

# Lancer l'application
flutter run
```

### Développement Quotidien
```bash
# Lancer en mode debug avec hot reload
flutter run

# Lancer sur un appareil spécifique
flutter run -d <device_id>

# Lancer sur Android
flutter run -d android

# Lancer sur Chrome (web)
flutter run -d chrome

# Lancer en mode release
flutter run --release

# Lancer en mode profile (pour profiling)
flutter run --profile
```

### Nettoyage et Maintenance
```bash
# Nettoyer le projet
flutter clean

# Réinstaller les dépendances
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Vérifier l'état de Flutter
flutter doctor -v
```

---

## 📱 Build de Production

### Android

#### APK (pour distribution directe)
```bash
# Build APK standard
flutter build apk --release

# Build APK optimisé par architecture (réduit la taille)
flutter build apk --release --split-per-abi

# Fichiers générés :
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

#### App Bundle (pour Google Play Store)
```bash
# Build App Bundle
flutter build appbundle --release

# Fichier généré :
# build/app/outputs/bundle/release/app-release.aab
```

#### Installer l'APK sur appareil
```bash
# Installer l'APK
flutter install

# Ou avec adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS (Mac uniquement)

```bash
# Build iOS
flutter build ios --release

# Ouvrir dans Xcode pour signer et distribuer
open ios/Runner.xcworkspace

# Archive depuis Xcode :
# Product > Archive > Distribute App
```

### Web

```bash
# Build pour le web
flutter build web --release

# Fichiers générés dans : build/web/

# Tester localement
cd build/web
python -m http.server 8000
# Ouvrir http://localhost:8000
```

---

## 🔍 Debugging

### Logs et Debug
```bash
# Afficher les logs détaillés
flutter run -v

# Afficher uniquement les logs de l'app
flutter run --verbose

# Profiler les performances
flutter run --profile

# Observer les metrics
flutter run --observatory-port=8888
```

### DevTools
```bash
# Lancer DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Pendant que l'app tourne :
# Les DevTools seront accessibles via le lien affiché
```

### Tests
```bash
# Exécuter tous les tests
flutter test

# Exécuter un test spécifique
flutter test test/specific_test.dart

# Tests d'intégration
flutter test integration_test/app_test.dart

# Coverage
flutter test --coverage
```

---

## 🤖 Android Spécifique

### Gradle
```bash
# Nettoyer Gradle
cd android
./gradlew clean
cd ..

# Build avec Gradle directement
cd android
./gradlew assembleRelease
cd ..

# Voir les tâches disponibles
cd android
./gradlew tasks
cd ..
```

### Licences Android
```bash
# Accepter toutes les licences
flutter doctor --android-licenses
```

### Émulateurs
```bash
# Lister les émulateurs
flutter emulators

# Lancer un émulateur
flutter emulators --launch <emulator_id>

# Créer un émulateur (nécessite Android Studio)
# Android Studio > AVD Manager > Create Virtual Device
```

---

## 🍎 iOS Spécifique (Mac uniquement)

### Pod (CocoaPods)
```bash
# Installer les pods
cd ios
pod install
cd ..

# Nettoyer et réinstaller
cd ios
pod deintegrate
pod install
cd ..

# Mettre à jour les pods
cd ios
pod update
cd ..
```

### Simulateur
```bash
# Lister les simulateurs
xcrun simctl list devices

# Lancer un simulateur
open -a Simulator

# Démarrer un simulateur spécifique
xcrun simctl boot <device_id>
```

---

## 📊 Analyse et Performance

### Taille de l'App
```bash
# Analyser la taille
flutter build apk --analyze-size
flutter build appbundle --analyze-size
flutter build ios --analyze-size

# Voir le rapport détaillé
# Un rapport HTML sera généré et ouvert automatiquement
```

### Profiling
```bash
# Timeline trace
flutter run --profile --trace-startup

# Performance overlay
# Dans l'app running, appuyez sur 'P' dans le terminal

# Widget inspector
# Appuyez sur 'W' dans le terminal
```

### Benchmark
```bash
# Tester les performances
flutter drive --target=test_driver/app.dart --profile
```

---

## 🔧 Dépannage

### Problèmes Communs

#### Flutter Doctor Issues
```bash
# Vérifier les problèmes
flutter doctor -v

# Accepter les licences Android
flutter doctor --android-licenses

# Configurer VS Code
flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"
```

#### Build Échoue
```bash
# Solution 1 : Nettoyage complet
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run

# Solution 2 : Supprimer les caches
rm -rf build/
rm -rf .dart_tool/
flutter pub get

# Solution 3 : Mise à jour Flutter
flutter upgrade
```

#### Problèmes de Dépendances
```bash
# Nettoyer le cache pub
flutter pub cache repair

# Obtenir les dépendances en forçant
flutter pub get --force-upgrade

# Downgrade d'une dépendance spécifique
# Modifier la version dans pubspec.yaml puis :
flutter pub get
```

#### Problèmes de Permissions (Android)
```bash
# Vérifier que AndroidManifest.xml contient :
# <uses-permission android:name="android.permission.RECORD_AUDIO" />
# <uses-permission android:name="android.permission.INTERNET" />

# Réinstaller l'app
flutter clean
flutter run
```

---

## 🌐 Web Spécifique

### Build et Test Web
```bash
# Build web
flutter build web --release

# Build web avec wasm (expérimental)
flutter build web --wasm

# Servir localement
flutter run -d chrome

# Build avec un base href personnalisé
flutter build web --base-href=/myapp/
```

---

## 🚢 Déploiement

### Google Play Store (Android)
```bash
# 1. Build App Bundle
flutter build appbundle --release

# 2. Uploader sur Google Play Console
# https://play.google.com/console

# 3. Créer une release
# Internal Testing → Create Release → Upload AAB
```

### App Store (iOS)
```bash
# 1. Build iOS
flutter build ios --release

# 2. Ouvrir Xcode
open ios/Runner.xcworkspace

# 3. Archive et Upload
# Product > Archive
# Window > Organizer > Distribute App
```

### Web Hosting
```bash
# Build
flutter build web --release

# Deploy sur Firebase
firebase deploy --only hosting

# Deploy sur Netlify
# Drag & drop le dossier build/web/

# Deploy sur GitHub Pages
# Commit build/web/ vers branche gh-pages
```

---

## 📝 Configuration Projet

### Variables d'Environnement
```bash
# Le fichier .env contient déjà les clés API
# Pour modifier :
# 1. Ouvrir .env
# 2. Modifier les valeurs
# 3. Redémarrer l'app
```

### Version et Build Number
```yaml
# Dans pubspec.yaml, modifier :
version: 1.0.0+1
# Format : version_name+build_number

# Ensuite :
flutter clean
flutter pub get
```

---

## 🎨 Assets et Icônes

### Générer les Icônes d'App
```bash
# Installer flutter_launcher_icons
flutter pub add flutter_launcher_icons --dev

# Dans pubspec.yaml, ajouter :
# flutter_icons:
#   android: true
#   ios: true
#   image_path: "assets/icon.png"

# Générer les icônes
flutter pub run flutter_launcher_icons
```

### Générer les Splash Screens
```bash
# Installer flutter_native_splash
flutter pub add flutter_native_splash --dev

# Générer
flutter pub run flutter_native_splash:create
```

---

## 🔄 Git & Version Control

### Initialisation Git
```bash
# Initialiser git
git init

# Ajouter remote
git remote add origin <your-repo-url>

# Premier commit
git add .
git commit -m "Initial commit: VoiceTranslator app"
git push -u origin main
```

### .gitignore
```bash
# Le fichier .gitignore est déjà configuré
# Il ignore :
# - .env (clés API)
# - build/
# - .dart_tool/
# - Fichiers IDE
```

---

## 📚 Ressources

### Documentation
- Flutter Docs : https://docs.flutter.dev/
- Dart Docs : https://dart.dev/guides
- 11Labs API : https://elevenlabs.io/docs
- AWS Translate : https://docs.aws.amazon.com/translate/

### Outils
- Flutter DevTools : `flutter pub global run devtools`
- VS Code Flutter Extension
- Android Studio Flutter Plugin

---

## 🎯 Commandes Rapides (Quick Reference)

```bash
# Développement
flutter run                    # Lancer l'app
flutter pub get                # Installer dépendances
flutter clean                  # Nettoyer le projet
flutter doctor                 # Vérifier la config

# Build
flutter build apk             # Build Android APK
flutter build appbundle       # Build Android AAB
flutter build ios             # Build iOS (Mac)
flutter build web             # Build Web

# Tests & Debug
flutter test                  # Exécuter tests
flutter analyze               # Analyser le code
flutter run --profile         # Profiling

# Maintenance
flutter upgrade               # Mettre à jour Flutter
flutter pub upgrade           # Mettre à jour dépendances
```

---

**💡 Conseil** : Gardez ce fichier comme référence rapide pour toutes vos commandes Flutter!

**🚀 Prêt à développer!**
