@echo off
chcp 65001 >nul
cls

echo ╔════════════════════════════════════════════════════════════╗
echo ║     🚀 VoiceTranslator - Démarrage Automatique 🚀         ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Couleurs
color 0A

REM Naviguer vers le dossier du projet
cd /d "%~dp0"
echo 📂 Dossier actuel : %CD%
echo.

REM Étape 1 : Vérifier si Flutter est installé
echo ══════════════════════════════════════════════════════════════
echo 🔍 Étape 1/4 : Vérification de Flutter...
echo ══════════════════════════════════════════════════════════════
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé ou pas dans le PATH!
    echo.
    echo 📖 Pour installer Flutter, visitez :
    echo    https://docs.flutter.dev/get-started/install/windows
    echo.
    echo ⚠️  Ou exécutez : INSTALL_FLUTTER.bat
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Flutter trouvé!
    flutter --version
    echo.
)

REM Étape 2 : Installer les dépendances
echo ══════════════════════════════════════════════════════════════
echo 📦 Étape 2/4 : Installation des dépendances...
echo ══════════════════════════════════════════════════════════════
echo.
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Erreur lors de l'installation des dépendances!
    pause
    exit /b 1
)
echo.
echo ✅ Dépendances installées avec succès!
echo.

REM Étape 3 : Vérifier les appareils disponibles
echo ══════════════════════════════════════════════════════════════
echo 📱 Étape 3/4 : Vérification des appareils disponibles...
echo ══════════════════════════════════════════════════════════════
echo.
flutter devices
echo.

REM Étape 4 : Démarrer l'application sur Chrome
echo ══════════════════════════════════════════════════════════════
echo 🌐 Étape 4/4 : Démarrage de l'application sur Chrome...
echo ══════════════════════════════════════════════════════════════
echo.
echo 🚀 L'application va s'ouvrir dans votre navigateur...
echo.
echo ⚠️  Pour arrêter l'application, appuyez sur Ctrl+C
echo.
timeout /t 3 /nobreak >nul

REM Lancer Flutter sur Chrome
start "" flutter run -d chrome

REM Attendre quelques secondes pour que le serveur démarre
echo.
echo ⏳ Démarrage du serveur Flutter...
timeout /t 10 /nobreak

REM Ouvrir le navigateur automatiquement
echo.
echo 🌐 Ouverture automatique du navigateur...
start http://localhost:50000

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         ✅ Application démarrée avec succès! ✅            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 📖 L'application devrait s'ouvrir dans Chrome
echo 🔄 Le Hot Reload est activé (modifiez le code et sauvegardez)
echo 🛑 Pour arrêter : Fermez cette fenêtre ou Ctrl+C
echo.

pause
