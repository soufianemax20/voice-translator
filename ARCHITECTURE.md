# 🏗️ Architecture de l'Application VoiceTranslator

## 📊 Vue d'ensemble

```
flutter_voice_translator/
│
├── 📱 Frontend (Flutter)
│   ├── UI Layer (Widgets)
│   ├── Business Logic Layer (Providers)
│   └── Data Layer (Services & Models)
│
├── 🌐 Backend Services
│   ├── 11Labs API (STT & TTS)
│   └── AWS Translate (Translation)
│
└── 📦 Mobile Platforms
    ├── Android (Kotlin)
    └── iOS (Swift)
```

## 📁 Structure des Fichiers

```
flutter_voice_translator/
│
├── 📱 lib/
│   ├── main.dart                          # Point d'entrée de l'app
│   │
│   ├── 📊 models/
│   │   └── language.dart                  # Modèle de données des langues
│   │
│   ├── 🎭 providers/
│   │   ├── translation_provider.dart      # Gestion d'état de la traduction
│   │   └── audio_provider.dart            # Gestion d'état de l'audio
│   │
│   ├── 🖼️ screens/
│   │   └── translation_screen.dart        # Écran principal
│   │
│   ├── 🌐 services/
│   │   ├── elevenlabs_service.dart        # API 11Labs (STT/TTS)
│   │   └── aws_translate_service.dart     # API AWS Translate
│   │
│   └── 🧩 widgets/
│       ├── speaker_card.dart              # Carte de speaker
│       ├── language_swap_button.dart      # Bouton d'échange
│       ├── waveform_visualizer.dart       # Visualiseur audio
│       └── status_indicator.dart          # Indicateur de statut
│
├── 🤖 android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml        # Permissions & Config
│   │   │   └── kotlin/                    # Code natif Android
│   │   └── build.gradle                   # Config Gradle de l'app
│   ├── build.gradle                       # Config Gradle projet
│   ├── gradle.properties                  # Propriétés Gradle
│   └── settings.gradle                    # Settings Gradle
│
├── 🍎 ios/
│   └── Runner/
│       └── Info.plist                     # Permissions & Config iOS
│
├── 🔧 Configuration
│   ├── .env                               # Variables d'environnement
│   ├── .gitignore                         # Fichiers à ignorer
│   └── pubspec.yaml                       # Dépendances Flutter
│
└── 📚 Documentation
    ├── README.md                          # Documentation principale
    ├── QUICK_START.md                     # Guide de démarrage
    └── TODO.md                            # Fonctionnalités futures
```

## 🔄 Flux de Données

### 1️⃣ Enregistrement Audio
```
User Tap Mic
    ↓
AudioProvider.startRecording()
    ↓
Record Audio Bytes
    ↓
AudioProvider.stopRecording()
    ↓
Return Uint8List
```

### 2️⃣ Traduction Complète
```
Audio Bytes
    ↓
ElevenLabsService.speechToText()
    ↓
Text Transcript
    ↓
AWSTranslateService.translateText()
    ↓
Translated Text
    ↓
ElevenLabsService.textToSpeech()
    ↓
Audio Bytes
    ↓
AudioProvider.playAudio()
    ↓
User Hears Translation
```

### 3️⃣ Gestion d'État
```
User Interaction
    ↓
Provider (ChangeNotifier)
    ↓
notifyListeners()
    ↓
UI Rebuild (Consumer)
    ↓
Updated Interface
```

## 🎨 Composants UI

### SpeakerCard
- **Fonction** : Affiche les informations d'un speaker
- **Contient** :
  - Sélecteur de langue
  - Toggle genre (Male/Female)
  - Zone de texte
  - Bouton microphone
- **État** : Mis à jour par `TranslationProvider`

### LanguageSwapButton
- **Fonction** : Échange les langues entre speakers
- **Animation** : Rotation continue
- **Action** : `TranslationProvider.swapLanguages()`

### WaveformVisualizer
- **Fonction** : Visualise l'audio en temps réel
- **Données** : `AudioProvider.waveformData`
- **Affichage** : 50 barres animées

### StatusIndicator
- **Fonction** : Affiche le statut actuel
- **États** :
  - Ready to Translate
  - Transcribing...
  - Translating...
  - Generating speech...

## 🔌 Services API

### ElevenLabsService
```dart
+ speechToText(audioBytes, languageCode) → String?
+ textToSpeech(text, languageCode, gender) → Uint8List?
+ getVoices() → List<Voice>
```

**Endpoints** :
- `POST /v1/speech-to-text` - STT
- `POST /v1/text-to-speech/{voiceId}` - TTS
- `GET /v1/voices` - Liste des voix

### AWSTranslateService
```dart
+ translateText(text, sourceLang, targetLang) → String?
```

**Endpoint** :
- `POST https://translate.us-east-1.amazonaws.com/` - Translation

**Authentification** : AWS Signature V4

## 🎯 Providers

### TranslationProvider
**Responsabilités** :
- Gérer l'état des 2 speakers
- Orchestrer STT → Translate → TTS
- Échanger les langues
- Afficher les statuts

**Méthodes principales** :
```dart
+ setSpeaker1Language(Language)
+ setSpeaker2Language(Language)
+ swapLanguages()
+ processSpeaker1Audio(Uint8List)
+ processSpeaker2Audio(Uint8List)
```

### AudioProvider
**Responsabilités** :
- Gérer l'enregistrement audio
- Gérer la lecture audio
- Gérer les permissions
- Simuler la waveform

**Méthodes principales** :
```dart
+ requestPermission() → bool
+ startRecording() → bool
+ stopRecording() → Uint8List?
+ playAudio(Uint8List)
+ stopPlayback()
```

## 🎨 Design System

### Couleurs
```dart
Primary Orange:    #FF6B35
Secondary Teal:    #4ECDC4
Background Dark:   #0A0E27
Surface Dark:      #1A1F3A
Error Red:         #FF5252
```

### Typography
- **Font Family** : Inter (Google Fonts)
- **Poids** : 400, 500, 600, 700

### Espacements
- **Small** : 8px
- **Medium** : 16px
- **Large** : 24px
- **XLarge** : 32px

### Bordures
- **Radius Small** : 8px
- **Radius Medium** : 12px
- **Radius Large** : 20px
- **Radius XLarge** : 25px

## 🔐 Sécurité

### Variables d'Environnement
- ✅ Clés API dans `.env`
- ✅ `.env` dans `.gitignore`
- ❌ Jamais commiter les clés

### Permissions
- **Android** : `AndroidManifest.xml`
  - `RECORD_AUDIO`
  - `INTERNET`
  - `WRITE_EXTERNAL_STORAGE`

- **iOS** : `Info.plist`
  - `NSMicrophoneUsageDescription`
  - `NSSpeechRecognitionUsageDescription`

## 📊 Performance

### Optimisations
1. **Audio Streaming** : Enregistrement en chunks
2. **Lazy Loading** : Widgets à la demande
3. **Image Caching** : Cache des icônes
4. **State Management** : Provider efficace

### Métriques Cibles
- **Latence STT** : < 2s
- **Latence Traduction** : < 1s
- **Latence TTS** : < 3s
- **Total** : < 6s par traduction complète

## 🧪 Tests (À implémenter)

### Tests Unitaires
```dart
test_providers/
├── translation_provider_test.dart
└── audio_provider_test.dart

test_services/
├── elevenlabs_service_test.dart
└── aws_translate_service_test.dart
```

### Tests d'Intégration
```dart
integration_test/
└── app_test.dart
```

### Tests de Widgets
```dart
widget_test/
├── speaker_card_test.dart
├── language_swap_button_test.dart
└── waveform_visualizer_test.dart
```

## 🚀 Déploiement

### Android
1. Générer keystore
2. Configurer `key.properties`
3. Build APK/AAB
4. Upload sur Google Play

### iOS
1. Configurer signing dans Xcode
2. Build archive
3. Upload sur App Store Connect
4. Soumission pour review

## 📈 Évolutions Futures

1. **Backend Custom** : Remplacer APIs tierces
2. **WebSocket** : Streaming en temps réel
3. **ML Local** : Modèles on-device
4. **Multi-plateforme** : Web, Desktop

---

**Architecture construite pour la scalabilité et la maintenabilité** 🏗️
