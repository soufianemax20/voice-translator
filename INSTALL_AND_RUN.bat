@echo off
chcp 65001 >nul
cls

color 0B

echo ╔═══════════════════════════════════════════════════════════════╗
echo ║   🎯 VoiceTranslator - Installation et Démarrage Complet 🎯  ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo 📋 Ce script va :
echo    1. Vérifier Flutter
echo    2. Nettoyer le projet
echo    3. Installer les dépendances
echo    4. Lancer l'application sur Chrome
echo    5. Ouvrir automatiquement le navigateur
echo.
pause

cd /d "%~dp0"

REM ══════════════════════════════════════════════════════════════
REM Étape 1 : Vérifier Flutter
REM ══════════════════════════════════════════════════════════════
echo.
echo ══════════════════════════════════════════════════════════════
echo 🔍 Vérification de Flutter...
echo ══════════════════════════════════════════════════════════════
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé!
    echo.
    echo 💡 Voulez-vous installer Flutter maintenant ? (O/N)
    set /p install_flutter=
    if /i "%install_flutter%"=="O" (
        echo.
        echo 📥 Téléchargement de Flutter...
        echo 🌐 Ouvrir https://docs.flutter.dev/get-started/install/windows
        start https://docs.flutter.dev/get-started/install/windows
    )
    echo.
    pause
    exit /b 1
)
echo ✅ Flutter trouvé!
flutter --version
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 2 : Nettoyer le projet
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 🧹 Nettoyage du projet...
echo ══════════════════════════════════════════════════════════════
flutter clean
echo ✅ Nettoyage terminé!
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 3 : Installer les dépendances
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 📦 Installation des dépendances...
echo ══════════════════════════════════════════════════════════════
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Erreur lors de l'installation!
    pause
    exit /b 1
)
echo ✅ Dépendances installées!
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 4 : Analyser le code
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 🔍 Analyse du code...
echo ══════════════════════════════════════════════════════════════
flutter analyze
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 5 : Lancer l'application
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 🚀 Lancement de l'application...
echo ══════════════════════════════════════════════════════════════
echo.
echo 🌐 Mode : Web (Chrome)
echo 🔥 Hot Reload : Activé
echo 📱 Port : http://localhost:50000
echo.
echo ⏳ Démarrage en cours...
timeout /t 3 /nobreak >nul

REM Lancer l'application
start "VoiceTranslator Flutter" cmd /c "flutter run -d chrome --web-port=50000"

REM Attendre le démarrage
echo.
echo ⏳ Attente du démarrage du serveur (15 secondes)...
timeout /t 15 /nobreak

REM Ouvrir le navigateur
echo.
echo 🌐 Ouverture automatique du navigateur...
start http://localhost:50000

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║              ✅ Application lancée avec succès! ✅             ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo 📱 URL : http://localhost:50000
echo 🔄 Hot Reload activé - Modifiez le code et sauvegardez
echo 🛑 Pour arrêter : Fermez la fenêtre Flutter
echo.
echo 📖 Documentation : README.md
echo 🚀 Profitez de VoiceTranslator!
echo.

pause
