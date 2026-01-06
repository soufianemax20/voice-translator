# 📜 Guide des Scripts Batch - VoiceTranslator

## 🎯 Scripts Disponibles

### 1. 🚀 DOUBLE_CLICK_ME.bat
**Script principal interactif avec menu complet**

**✨ Recommandé pour démarrer!**

Double-cliquez sur ce fichier pour accéder au menu principal qui propose :
- Démarrage de l'application (Web/Android)
- Installation complète
- Nettoyage du projet
- Documentation
- Vérification Flutter

**Utilisation :**
```
Double-clic sur DOUBLE_CLICK_ME.bat
```

---

### 2. 🌐 START_APP.bat
**Démarrage standard de l'application sur Chrome**

Ce script :
- ✅ Vérifie que Flutter est installé
- ✅ Installe les dépendances (`flutter pub get`)
- ✅ Liste les appareils disponibles
- ✅ Lance l'application sur Chrome
- ✅ Ouvre automatiquement le navigateur sur `http://localhost:50000`

**Utilisation :**
```
Double-clic sur START_APP.bat
```

**Commande équivalente :**
```bash
flutter pub get
flutter run -d chrome
```

---

### 3. ⚡ QUICK_START_WEB.bat
**Démarrage ultra-rapide sur le Web**

Version optimisée pour un démarrage rapide :
- ⚡ Installation silencieuse des dépendances
- ⚡ Lance sur le port 8080
- ⚡ Ouvre automatiquement le navigateur
- ⚡ Ferme automatiquement après le lancement

**Utilisation :**
```
Double-clic sur QUICK_START_WEB.bat
```

**URL :** `http://localhost:8080`

---

### 4. 🔧 INSTALL_AND_RUN.bat
**Installation complète et lancement**

Script complet qui effectue :
- ✅ Vérification de Flutter
- ✅ Nettoyage avec `flutter clean`
- ✅ Installation des dépendances
- ✅ Analyse du code avec `flutter analyze`
- ✅ Lancement de l'application
- ✅ Ouverture automatique du navigateur

**Utilisation :**
```
Double-clic sur INSTALL_AND_RUN.bat
```

**Idéal pour :**
- Premier lancement
- Après mise à jour du code
- Si vous rencontrez des erreurs

---

### 5. 📱 RUN_ON_ANDROID.bat
**Lancement sur appareil/émulateur Android**

Ce script :
- ✅ Vérifie Flutter
- ✅ Installe les dépendances
- ✅ Liste les appareils Android disponibles
- ✅ Lance l'application sur Android

**Prérequis :**
- Téléphone Android connecté en USB avec mode développeur activé
- OU émulateur Android lancé depuis Android Studio

**Utilisation :**
```
Double-clic sur RUN_ON_ANDROID.bat
```

**Commande équivalente :**
```bash
flutter run
```

---

### 6. 💾 INSTALL_FLUTTER.bat
**Assistant d'installation de Flutter**

Menu interactif pour installer Flutter :

**Options :**
1. **Téléchargement manuel** - Ouvre les liens de téléchargement
2. **Documentation officielle** - Ouvre le guide d'installation
3. **Vérifier Flutter** - Teste si Flutter est installé
4. **Ajouter au PATH** - Configure la variable PATH

**Utilisation :**
```
Double-clic sur INSTALL_FLUTTER.bat
```

**Après installation :**
1. Fermez toutes les fenêtres de commande
2. Ouvrez une nouvelle fenêtre
3. Testez avec `flutter --version`

---

## 📋 Ordre Recommandé d'Utilisation

### 🆕 Premier Lancement (Flutter non installé)

```
1. INSTALL_FLUTTER.bat          → Installer Flutter
2. INSTALL_AND_RUN.bat          → Installation complète
3. [Profitez de l'application!]
```

### ✅ Flutter Déjà Installé

```
1. DOUBLE_CLICK_ME.bat          → Menu principal
   ou
   START_APP.bat                → Démarrage direct
```

### ⚡ Démarrage Rapide Quotidien

```
QUICK_START_WEB.bat             → Ultra-rapide
```

---

## 🎯 Cas d'Usage Spécifiques

### 🐛 J'ai des erreurs de dépendances
```
Exécutez : INSTALL_AND_RUN.bat

Ce script va :
- Nettoyer le projet (flutter clean)
- Réinstaller toutes les dépendances
- Analyser le code
- Relancer l'app
```

### 📱 Je veux tester sur mon téléphone Android
```
1. Activez le mode développeur sur votre téléphone
2. Activez le débogage USB
3. Connectez le téléphone en USB
4. Exécutez : RUN_ON_ANDROID.bat
```

### 🌐 Je veux juste voir l'interface rapidement
```
Exécutez : QUICK_START_WEB.bat

L'app va s'ouvrir dans Chrome en ~12 secondes
```

### 🔄 J'ai modifié le code et ça ne marche plus
```
Exécutez : INSTALL_AND_RUN.bat

Cela va tout nettoyer et réinstaller proprement
```

---

## ⚙️ Configuration des Ports

| Script | Port | URL |
|--------|------|-----|
| START_APP.bat | 50000 | http://localhost:50000 |
| QUICK_START_WEB.bat | 8080 | http://localhost:8080 |
| INSTALL_AND_RUN.bat | 50000 | http://localhost:50000 |

💡 **Astuce** : Si un port est occupé, modifiez `--web-port=XXXX` dans le script

---

## 🛠️ Personnalisation des Scripts

### Changer le port par défaut

Ouvrez le script avec un éditeur de texte et modifiez :
```batch
flutter run -d chrome --web-port=8080
```

### Changer le navigateur

Par défaut : Chrome (`-d chrome`)

Pour utiliser Edge :
```batch
flutter run -d edge
```

Pour utiliser le navigateur par défaut :
```batch
flutter run -d web-server
```

### Désactiver l'ouverture automatique du navigateur

Supprimez ou commentez la ligne :
```batch
REM start http://localhost:8080
```

---

## 🔧 Dépannage

### ❌ "Flutter n'est pas reconnu..."

**Solution :**
1. Exécutez `INSTALL_FLUTTER.bat`
2. Installez Flutter
3. Ajoutez au PATH (option 4 du script)
4. Fermez et rouvrez la fenêtre de commande

### ❌ "Erreur lors de l'installation des dépendances"

**Solution :**
```batch
# Exécutez manuellement :
flutter clean
flutter pub get
```

Ou utilisez `INSTALL_AND_RUN.bat` qui fait tout automatiquement.

### ❌ Le navigateur ne s'ouvre pas automatiquement

**Solution :**
1. Attendez que le message "Flutter app is running" apparaisse
2. Ouvrez manuellement : http://localhost:50000 ou http://localhost:8080

### ❌ "No devices found"

**Pour Android :**
- Vérifiez que le téléphone est connecté
- Activez le débogage USB
- Ou lancez un émulateur

**Pour Web :**
- Chrome devrait être détecté automatiquement
- Si non, installez Chrome

### ❌ Port déjà utilisé

**Solution :**
Modifiez le port dans le script :
```batch
flutter run -d chrome --web-port=9999
```

---

## 📊 Comparaison des Scripts

| Script | Rapidité | Complétude | Auto-Browser | Interactif |
|--------|----------|------------|--------------|------------|
| DOUBLE_CLICK_ME.bat | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | ✅ |
| START_APP.bat | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ | ❌ |
| QUICK_START_WEB.bat | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ | ❌ |
| INSTALL_AND_RUN.bat | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | ❌ |
| RUN_ON_ANDROID.bat | ⭐⭐⭐ | ⭐⭐⭐⭐ | ❌ | ❌ |
| INSTALL_FLUTTER.bat | ⭐⭐ | ⭐⭐⭐⭐⭐ | ❌ | ✅ |

---

## 💡 Conseils d'Utilisation

### Pour les Débutants
```
1. Utilisez DOUBLE_CLICK_ME.bat
2. Choisissez l'option appropriée dans le menu
3. Suivez les instructions à l'écran
```

### Pour les Développeurs Expérimentés
```
1. QUICK_START_WEB.bat pour développement rapide
2. Modifiez le code avec Hot Reload activé
3. Utilisez INSTALL_AND_RUN.bat si bugs
```

### Pour la Production
```
Utilisez les commandes manuelles dans COMMANDS.md
pour les builds production (APK, AAB, iOS)
```

---

## 🎨 Codes Couleur des Scripts

- **Vert (0A)** - START_APP.bat
- **Cyan (0B)** - INSTALL_AND_RUN.bat, DOUBLE_CLICK_ME.bat
- **Rouge (0C)** - INSTALL_FLUTTER.bat
- **Violet (0D)** - QUICK_START_WEB.bat
- **Jaune (0E)** - RUN_ON_ANDROID.bat

---

## 📚 Documentation Complémentaire

- **README.md** - Documentation générale
- **QUICK_START.md** - Guide de démarrage rapide
- **COMMANDS.md** - Toutes les commandes Flutter
- **ARCHITECTURE.md** - Architecture du projet

---

## ✅ Checklist Avant de Lancer

- [ ] Flutter installé (`flutter --version`)
- [ ] Visual Studio Code ou Android Studio installé (optionnel)
- [ ] Chrome installé (pour Web)
- [ ] Téléphone Android connecté (pour Android)
- [ ] Mode développeur activé (pour Android)
- [ ] Débogage USB activé (pour Android)

---

## 🚀 Démarrage Recommandé

**🎯 Le plus simple :**
```
Double-clic sur DOUBLE_CLICK_ME.bat → Choisissez l'option 1 ou 4
```

**⚡ Le plus rapide :**
```
Double-clic sur QUICK_START_WEB.bat
```

**🔧 Le plus complet :**
```
Double-clic sur INSTALL_AND_RUN.bat
```

---

**💡 Bon développement avec VoiceTranslator! 🎤**
