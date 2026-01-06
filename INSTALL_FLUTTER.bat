@echo off
chcp 65001 >nul
cls

color 0C

echo ╔════════════════════════════════════════════════════════════╗
echo ║         🔧 Installation de Flutter - Windows 🔧           ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

echo Ce script va vous guider pour installer Flutter sur Windows
echo.
echo ══════════════════════════════════════════════════════════════
echo Options d'installation :
echo ══════════════════════════════════════════════════════════════
echo.
echo [1] Téléchargement manuel (Recommandé)
echo [2] Ouvrir la documentation officielle
echo [3] Vérifier si Flutter est déjà installé
echo [4] Ajouter Flutter au PATH
echo [0] Annuler
echo.
set /p choice="Votre choix : "

if "%choice%"=="1" goto manual
if "%choice%"=="2" goto docs
if "%choice%"=="3" goto check
if "%choice%"=="4" goto addpath
goto end

:manual
echo.
echo ══════════════════════════════════════════════════════════════
echo 📥 Téléchargement manuel de Flutter
echo ══════════════════════════════════════════════════════════════
echo.
echo 📋 Étapes à suivre :
echo.
echo 1. Le lien de téléchargement va s'ouvrir dans votre navigateur
echo 2. Téléchargez le fichier ZIP de Flutter
echo 3. Extrayez-le dans C:\src\flutter
echo 4. Ajoutez C:\src\flutter\bin au PATH
echo.
echo 🌐 Ouverture du lien de téléchargement...
timeout /t 3 /nobreak >nul
start https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip
echo.
echo 📖 Ouverture de la documentation...
timeout /t 2 /nobreak >nul
start https://docs.flutter.dev/get-started/install/windows
echo.
echo ✅ Après l'installation, exécutez l'option [4] pour ajouter au PATH
pause
goto end

:docs
echo.
echo 🌐 Ouverture de la documentation officielle...
start https://docs.flutter.dev/get-started/install/windows
echo.
echo ✅ Suivez les instructions sur le site officiel
pause
goto end

:check
echo.
echo ══════════════════════════════════════════════════════════════
echo 🔍 Vérification de Flutter...
echo ══════════════════════════════════════════════════════════════
echo.
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé ou pas dans le PATH
    echo.
    echo 💡 Installez Flutter avec l'option [1] ou [2]
) else (
    echo ✅ Flutter est installé!
    echo.
    flutter --version
    echo.
    echo 📊 Vérification complète du système...
    flutter doctor
)
echo.
pause
goto end

:addpath
echo.
echo ══════════════════════════════════════════════════════════════
echo 🛠️ Ajout de Flutter au PATH
echo ══════════════════════════════════════════════════════════════
echo.
echo 📝 Emplacement de Flutter (par défaut: C:\src\flutter\bin)
set /p flutter_path="Entrez le chemin complet de flutter\bin : "

if "%flutter_path%"=="" set flutter_path=C:\src\flutter\bin

echo.
echo ⚙️ Ajout de %flutter_path% au PATH utilisateur...
echo.

REM Ajouter au PATH utilisateur
setx PATH "%PATH%;%flutter_path%"

echo.
echo ✅ PATH mis à jour!
echo.
echo ⚠️  IMPORTANT : Vous devez :
echo    1. Fermer TOUTES les fenêtres de commande
echo    2. Ouvrir une NOUVELLE fenêtre
echo    3. Taper "flutter --version" pour vérifier
echo.
pause
goto end

:end
echo.
echo Fermeture...
timeout /t 2
exit
