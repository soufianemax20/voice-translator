@echo off
chcp 65001 >nul
cls

color 0E

echo ╔════════════════════════════════════════════════════════════╗
echo ║      📱 VoiceTranslator - Lancement Android 📱            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM Vérifier Flutter
echo 🔍 Vérification de Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter non trouvé!
    pause
    exit /b 1
)
echo ✅ Flutter OK
echo.

REM Installer les dépendances si nécessaire
echo 📦 Installation des dépendances...
flutter pub get
echo.

REM Vérifier les appareils Android
echo ══════════════════════════════════════════════════════════════
echo 📱 Appareils Android disponibles :
echo ══════════════════════════════════════════════════════════════
flutter devices
echo.

echo ⚠️  Assurez-vous que :
echo    1. Votre téléphone Android est connecté en USB
echo    2. Le mode développeur est activé
echo    3. Le débogage USB est activé
echo    4. Vous avez accepté l'autorisation de débogage
echo.
echo 💡 Ou lancez un émulateur Android depuis Android Studio
echo.
pause

echo.
echo 🚀 Lancement sur Android...
echo ⏳ Cela peut prendre quelques minutes la première fois...
echo.

REM Lancer l'application
flutter run

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║              Application terminée                          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
pause
