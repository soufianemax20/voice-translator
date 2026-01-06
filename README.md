# 🎤 VoiceTranslator - Application Flutter

Application mobile de traduction vocale instantanée avec une interface ultra-moderne.

## ✨ Fonctionnalités

- 🎤 **Reconnaissance vocale en temps réel** via 11Labs Scribe V2 Realtime (~150ms latency)
- 🔄 **Traduction en temps réel** via AWS Translate
- 🔊 **Synthèse vocale premium** via 11Labs (TTS)
- 🌓 **Thème sombre élégant** avec animations fluides
- 🔀 **Échange de langues instantané**
- 📊 **Visualisation audio en temps réel**
- 🎯 **Support multi-langues** : English, Français, Español, العربية, Deutsch, Italiano, Português, 中文, 日本語, 한국어, Русский, हिन्दी
- 🎭 **Sélection de voix** : Masculine ou Féminine par langue
- ⚡ **Transcription instantanée** : Les mots apparaissent pendant que vous parlez!

## 📋 Prérequis

### Installation de Flutter

#### Windows
1. Téléchargez Flutter SDK : https://docs.flutter.dev/get-started/install/windows
2. Extrayez l'archive dans `C:\src\flutter`
3. Ajoutez `C:\src\flutter\bin` au PATH
4. Exécutez `flutter doctor` pour vérifier l'installation

#### macOS
```bash
# Avec Homebrew
brew install flutter

# Ou téléchargement manuel
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.x.x-stable.zip
unzip flutter_macos_arm64_3.x.x-stable.zip
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Linux
```bash
sudo snap install flutter --classic
```

### Vérification
```bash
flutter doctor
```

## 🚀 Installation

### 1. Installer les dépendances
```bash
cd "C:\Users\rapde\Desktop\INSTANT TRANSLAT\flutter_voice_translator"
flutter pub get
```

### 2. Configuration des API Keys

Les clés API sont déjà configurées dans le fichier `.env` :
- **11Labs API** : Pour STT et TTS
- **AWS Credentials** : Pour la traduction
- **AWS Region** : us-east-1

⚠️ **IMPORTANT** : Ne partagez jamais vos clés API publiquement!

### 3. Lancer l'application

#### Sur Android
```bash
# Connectez votre téléphone Android en mode debug ou lancez un émulateur
flutter run
```

#### Sur iOS
```bash
# Nécessite un Mac avec Xcode installé
flutter run
```

#### Sur Web (mode développement)
```bash
flutter run -d chrome
```

## 📱 Build de production

### Android (APK)
```bash
flutter build apk --release
# Le fichier APK sera dans : build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle pour Google Play)
```bash
flutter build appbundle --release
# Le fichier AAB sera dans : build/app/outputs/bundle/release/app-release.aab
```

### iOS (nécessite un Mac)
```bash
flutter build ios --release
# Ensuite ouvrez Xcode pour signer et distribuer
```

## 🎨 Architecture

```
lib/
├── main.dart                 # Point d'entrée
├── models/
│   └── language.dart        # Modèle de données des langues
├── providers/
│   ├── translation_provider.dart  # Gestion d'état traduction
│   └── audio_provider.dart       # Gestion d'état audio
├── screens/
│   └── translation_screen.dart   # Écran principal
├── services/
│   ├── elevenlabs_service.dart   # Service 11Labs API
│   └── aws_translate_service.dart # Service AWS Translate
└── widgets/
    ├── speaker_card.dart         # Carte de speaker
    ├── language_swap_button.dart # Bouton d'échange
    ├── waveform_visualizer.dart  # Visualiseur audio
    └── status_indicator.dart     # Indicateur de statut
```

## 🔧 Technologies utilisées

- **Flutter** 3.x
- **Provider** - Gestion d'état
- **11Labs API** - STT & TTS
- **AWS Translate** - Traduction
- **Google Fonts** - Typography
- **Flutter Animate** - Animations
- **Record** - Enregistrement audio
- **AudioPlayers** - Lecture audio

## 🌍 Langues supportées

| Langue | Code | Drapeau |
|--------|------|---------|
| English | en | 🇺🇸 |
| Français | fr | 🇫🇷 |
| Español | es | 🇪🇸 |
| العربية | ar | 🇸🇦 |
| Deutsch | de | 🇩🇪 |
| Italiano | it | 🇮🇹 |
| Português | pt | 🇵🇹 |
| 中文 | zh | 🇨🇳 |
| 日本語 | ja | 🇯🇵 |
| 한국어 | ko | 🇰🇷 |
| Русский | ru | 🇷🇺 |
| हिन्दी | hi | 🇮🇳 |

## 📖 Utilisation

1. **Sélectionnez les langues** pour chaque speaker
2. **Choisissez le genre de voix** (Masculin/Féminin)
3. **Appuyez sur le micro** pour commencer l'enregistrement
4. **Parlez** dans votre langue
5. **Arrêtez l'enregistrement** en appuyant à nouveau
6. **Écoutez la traduction** automatiquement générée
7. **Échangez les langues** avec le bouton central si nécessaire

## 🐛 Dépannage

### Problème : "Flutter not found"
```bash
# Vérifiez que Flutter est dans le PATH
echo $PATH  # Mac/Linux
echo %PATH%  # Windows
```

### Problème : Permissions audio refusées
- **Android** : Vérifiez que les permissions sont dans `AndroidManifest.xml`
- **iOS** : Vérifiez `Info.plist` et acceptez les permissions sur l'appareil

### Problème : Erreur de dépendances
```bash
flutter clean
flutter pub get
```

## 📄 Licence

© 2026 VoiceTranslator - Tous droits réservés

## 👨‍💻 Développé par

Application créée avec ❤️ en utilisant Flutter et les meilleures pratiques de développement mobile.

---

🌟 **Profitez de la traduction vocale instantanée!** 🌟
