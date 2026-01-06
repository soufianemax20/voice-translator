# 🚀 Guide de Démarrage Rapide - VoiceTranslator

## ⚡ Installation Express

### Étape 1 : Installer Flutter

#### 🪟 Windows
```powershell
# Télécharger Flutter
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip" -OutFile "$env:USERPROFILE\Downloads\flutter.zip"

# Extraire
Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter.zip" -DestinationPath "C:\src"

# Ajouter au PATH (ajoutez cette ligne à votre profil PowerShell)
$env:Path += ";C:\src\flutter\bin"

# Vérifier l'installation
flutter doctor
```

#### 🍎 macOS
```bash
# Avec Homebrew
brew install flutter

# OU télécharger manuellement
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.16.0-stable.zip
unzip flutter_macos_arm64_3.16.0-stable.zip
sudo mv flutter /usr/local/
export PATH="$PATH:/usr/local/flutter/bin"

# Vérifier l'installation
flutter doctor
```

#### 🐧 Linux
```bash
# Avec snap
sudo snap install flutter --classic

# OU télécharger manuellement
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
sudo mv flutter /usr/local/
export PATH="$PATH:/usr/local/flutter/bin"

# Vérifier l'installation
flutter doctor
```

### Étape 2 : Installer les dépendances

```bash
cd "C:\Users\rapde\Desktop\INSTANT TRANSLAT\flutter_voice_translator"
flutter pub get
```

### Étape 3 : Préparer votre appareil

#### Pour Android
1. Activez le **Mode Développeur** sur votre téléphone Android
2. Activez le **Débogage USB**
3. Connectez votre téléphone via USB
4. Acceptez la demande d'autorisation de débogage

**Ou utilisez un émulateur :**
```bash
# Installer Android Studio
# Créer un AVD (Android Virtual Device)
flutter emulators --launch <emulator_id>
```

#### Pour iOS (Mac uniquement)
```bash
# Installer Xcode depuis l'App Store
# Installer les outils en ligne de commande
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Ouvrir le simulateur
open -a Simulator
```

### Étape 4 : Lancer l'application

```bash
# Vérifier les appareils connectés
flutter devices

# Lancer l'application
flutter run

# Ou spécifier un appareil
flutter run -d <device_id>
```

## 🎯 Commandes Utiles

### Développement
```bash
# Lancer en mode debug avec hot reload
flutter run

# Lancer en mode release
flutter run --release

# Lancer sur un appareil spécifique
flutter run -d android
flutter run -d chrome
flutter run -d windows
```

### Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle (pour Google Play)
flutter build appbundle --release

# iOS (Mac uniquement)
flutter build ios --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

### Maintenance
```bash
# Nettoyer le projet
flutter clean

# Obtenir les dépendances
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade

# Vérifier les problèmes
flutter doctor -v

# Analyser le code
flutter analyze
```

## 🔧 Résolution de Problèmes

### Problème : Flutter command not found
**Solution :**
```bash
# Ajouter Flutter au PATH
# Windows PowerShell
$env:Path += ";C:\src\flutter\bin"

# macOS/Linux Bash
export PATH="$PATH:/usr/local/flutter/bin"

# Ajouter de façon permanente dans ~/.bashrc ou ~/.zshrc
```

### Problème : Android licenses not accepted
**Solution :**
```bash
flutter doctor --android-licenses
# Accepter toutes les licences avec 'y'
```

### Problème : Gradle build failed
**Solution :**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problème : Permissions refusées sur mobile
**Solution :**
1. Désinstallez l'application
2. Réinstallez avec `flutter run`
3. Acceptez les permissions microphone lors du premier lancement

### Problème : Pod install failed (iOS)
**Solution :**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## 📱 Premier Lancement

1. **Acceptez les permissions** microphone
2. **Sélectionnez votre langue** pour le Speaker 1
3. **Sélectionnez la langue de traduction** pour le Speaker 2
4. **Choisissez le genre de voix** (optionnel)
5. **Appuyez sur le micro** 🎤 pour enregistrer
6. **Parlez** dans votre langue
7. **Arrêtez l'enregistrement** en appuyant à nouveau
8. **Écoutez la traduction** automatique! 🔊

## 🎨 Personnalisation

### Modifier les couleurs
Éditez `lib/main.dart` :
```dart
colorScheme: ColorScheme.dark(
  primary: const Color(0xFFFF6B35),  // Votre couleur principale
  secondary: const Color(0xFF4ECDC4), // Votre couleur secondaire
  // ...
),
```

### Ajouter une langue
Éditez `lib/models/language.dart` :
```dart
static const Language myLanguage = Language(
  name: 'My Language',
  nativeName: 'Native Name',
  code: 'xx',
  flag: '🏳️',
);
```

## 📊 Performance

Pour optimiser les performances :
```bash
# Build avec optimisations
flutter build apk --release --split-per-abi

# Analyser la taille de l'app
flutter build apk --analyze-size

# Profiler l'application
flutter run --profile
```

## 🌐 Support

- 📧 Email : support@voicetranslator.com
- 📖 Documentation : [README.md](README.md)
- 🐛 Issues : Créez un issue sur le repository

---

**Bon développement! 🚀**
