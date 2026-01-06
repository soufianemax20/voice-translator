@echo off
chcp 65001 >nul
cls

color 0B

echo ========================================================================
echo    VOICETRANSLATOR - INSTALLATION COMPLETE AUTOMATIQUE
echo ========================================================================
echo.

REM Naviguer vers le dossier du projet
cd /d "%~dp0"

echo Dossier du projet : %CD%
echo.

REM ========================================================================
REM ETAPE 1 : Verifier Flutter
REM ========================================================================
echo ========================================================================
echo ETAPE 1/4 : Verification de Flutter
echo ========================================================================
echo.

where flutter >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Flutter est deja installe!
    flutter --version
    echo.
    goto install_deps
)

echo [!] Flutter n'est pas installe
echo.
echo Ouvrons le site pour installer Flutter...
timeout /t 3 /nobreak >nul

REM Ouvrir les pages d'installation
start https://docs.flutter.dev/get-started/install/windows
start https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip

echo.
echo Instructions :
echo   1. Telechargez Flutter SDK
echo   2. Extrayez dans C:\src\flutter
echo   3. Ajoutez C:\src\flutter\bin au PATH
echo   4. Fermez ce terminal et ouvrez-en un nouveau
echo   5. Relancez ce script
echo.
pause
exit

REM ========================================================================
REM ETAPE 2 : Installer les dependances
REM ========================================================================
:install_deps
echo ========================================================================
echo ETAPE 2/4 : Installation des dependances
echo ========================================================================
echo.

echo Installation des packages Flutter...
flutter pub get

if %errorlevel% neq 0 (
    echo [ERREUR] Installation des dependances echouee!
    pausexit /b 1
)

echo.
echo [OK] Dependances installees!
echo.

REM ========================================================================
REM ETAPE 3 : Flutter Doctor
REM ========================================================================
echo ========================================================================
echo ETAPE 3/4 : Diagnostic Flutter
echo ========================================================================
echo.

flutter doctor

echo.

REM ========================================================================
REM ETAPE 4 : Verifier les appareils
REM ========================================================================
echo ========================================================================
echo ETAPE 4/4 : Appareils disponibles
echo ========================================================================
echo.

flutter devices

echo.
echo ========================================================================
echo [OK] Installation terminee!
echo ========================================================================
echo.
echo Votre projet VoiceTranslator est pret!
echo.
echo Prochaines etapes :
echo.
echo [1] Lancer sur Web (Chrome) - Recommande
echo [2] Lancer sur Android
echo [3] Quitter
echo.
set /p choice="Votre choix : "

if "%choice%"=="1" goto launch_web
if "%choice%"=="2" goto launch_android
goto end

:launch_web
echo.
echo Lancement sur Chrome...
echo Hot Reload active - Modifiez le code et voyez les changements!
echo.
flutter run -d chrome --web-port=8080
goto end

:launch_android
echo.
echo Lancement sur Android...
echo.
flutter run
goto end

:end
echo.
echo ========================================================================
echo Merci d'avoir utilise VoiceTranslator!
echo ========================================================================
echo.
pause
