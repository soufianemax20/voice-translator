# ╔══════════════════════════════════════════════════════════════╗
# ║  🚀 VoiceTranslator - Installation Automatique Complète    ║
# ╚══════════════════════════════════════════════════════════════╝

# Encodage UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 VoiceTranslator - Installation Automatique Complète    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectPath

Write-Host "📂 Dossier du projet : $projectPath" -ForegroundColor Yellow
Write-Host ""

# ══════════════════════════════════════════════════════════════
# Fonction : Vérifier Flutter
# ══════════════════════════════════════════════════════════════
function Test-FlutterInstalled {
    try {
        $flutterVersion = flutter --version 2>&1
        return $true
    } catch {
        return $false
    }
}

# ══════════════════════════════════════════════════════════════
# Fonction : Télécharger Flutter
# ══════════════════════════════════════════════════════════════
function Install-Flutter {
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📥 Téléchargement et Installation de Flutter" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"
    $downloadPath = "$env:TEMP\flutter_windows.zip"
    $installPath = "C:\src\flutter"
    
    Write-Host "🌐 URL de téléchargement : $flutterUrl" -ForegroundColor Gray
    Write-Host "📁 Destination : $installPath" -ForegroundColor Gray
    Write-Host ""
    
    # Créer le dossier C:\src
    if (-not (Test-Path "C:\src")) {
        Write-Host "📁 Création du dossier C:\src..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null
    }
    
    # Télécharger Flutter
    Write-Host "⏳ Téléchargement de Flutter SDK (~1.5 GB)..." -ForegroundColor Yellow
    Write-Host "   Cela peut prendre plusieurs minutes..." -ForegroundColor Gray
    Write-Host ""
    
    try {
        # Utiliser WebClient pour le téléchargement avec barre de progression
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($flutterUrl, $downloadPath)
        
        Write-Host "✅ Téléchargement terminé!" -ForegroundColor Green
        Write-Host ""
        
        # Extraire le ZIP
        Write-Host "📦 Extraction de l'archive..." -ForegroundColor Yellow
        Expand-Archive -Path $downloadPath -DestinationPath "C:\src" -Force
        
        Write-Host "✅ Extraction terminée!" -ForegroundColor Green
        Write-Host ""
        
        # Nettoyer
        Remove-Item $downloadPath -Force
        
        # Ajouter au PATH
        Write-Host "⚙️  Configuration du PATH..." -ForegroundColor Yellow
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $flutterBinPath = "$installPath\bin"
        
        if ($currentPath -notlike "*$flutterBinPath*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBinPath", "User")
            $env:Path += ";$flutterBinPath"
            Write-Host "✅ Flutter ajouté au PATH!" -ForegroundColor Green
        } else {
            Write-Host "✅ Flutter déjà dans le PATH!" -ForegroundColor Green
        }
        
        Write-Host ""
        return $true
        
    } catch {
        Write-Host "❌ Erreur lors du téléchargement : $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Solution alternative : Installation manuelle" -ForegroundColor Yellow
        Write-Host "   1. Visitez : https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Gray
        Write-Host "   2. Téléchargez Flutter SDK" -ForegroundColor Gray
        Write-Host "   3. Extrayez dans C:\src\flutter" -ForegroundColor Gray
        Write-Host "   4. Relancez ce script" -ForegroundColor Gray
        Write-Host ""
        
        # Ouvrir le navigateur
        Start-Process "https://docs.flutter.dev/get-started/install/windows"
        
        return $false
    }
}

# ══════════════════════════════════════════════════════════════
# ÉTAPE 1 : Vérifier Flutter
# ══════════════════════════════════════════════════════════════
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🔍 Étape 1/5 : Vérification de Flutter" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (Test-FlutterInstalled) {
    Write-Host "✅ Flutter est déjà installé!" -ForegroundColor Green
    flutter --version
    Write-Host ""
} else {
    Write-Host "❌ Flutter n'est pas installé" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "💡 Voulez-vous installer Flutter automatiquement ? (O/N)" -ForegroundColor Yellow
    $install = Read-Host
    
    if ($install -eq "O" -or $install -eq "o" -or $install -eq "Y" -or $install -eq "y") {
        $installed = Install-Flutter
        
        if (-not $installed) {
            Write-Host ""
            Write-Host "⚠️  Installation annulée ou échouée" -ForegroundColor Red
            Write-Host "   Veuillez installer Flutter manuellement et relancer ce script" -ForegroundColor Yellow
            Write-Host ""
            pause
            exit
        }
    } else {
        Write-Host ""
        Write-Host "⚠️  Flutter est requis pour continuer" -ForegroundColor Red
        Write-Host "   Installez Flutter et relancez ce script" -ForegroundColor Yellow
        Write-Host ""
        pause
        exit
    }
}

# ══════════════════════════════════════════════════════════════
# ÉTAPE 2 : Flutter Doctor
# ══════════════════════════════════════════════════════════════
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🏥 Étape 2/5 : Diagnostic Flutter" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

flutter doctor

Write-Host ""

# ══════════════════════════════════════════════════════════════
# ÉTAPE 3 : Nettoyer le projet
# ══════════════════════════════════════════════════════════════
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🧹 Étape 3/5 : Nettoyage du projet" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (Test-Path "build") {
    Write-Host "🗑️  Suppression du dossier build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
}

if (Test-Path ".dart_tool") {
    Write-Host "🗑️  Suppression du dossier .dart_tool..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue
}

Write-Host "✅ Nettoyage terminé!" -ForegroundColor Green
Write-Host ""

# ══════════════════════════════════════════════════════════════
# ÉTAPE 4 : Installer les dépendances
# ══════════════════════════════════════════════════════════════
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📦 Étape 4/5 : Installation des dépendances" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "⏳ Installation des packages Flutter..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Dépendances installées avec succès!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
    Write-Host "   Essayez manuellement : flutter pub get" -ForegroundColor Yellow
}

Write-Host ""

# ══════════════════════════════════════════════════════════════
# ÉTAPE 5 : Vérifier les appareils
# ══════════════════════════════════════════════════════════════
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📱 Étape 5/5 : Appareils disponibles" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

flutter devices

Write-Host ""

# ══════════════════════════════════════════════════════════════
# Résumé Final
# ══════════════════════════════════════════════════════════════
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ Installation et Préparation Terminées!" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host "🎉 Votre projet VoiceTranslator est prêt!" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Prochaines étapes :" -ForegroundColor Yellow
Write-Host ""
Write-Host "   [1] 🌐 Lancer sur Web (Chrome) - Recommandé" -ForegroundColor White
Write-Host "   [2] 📱 Lancer sur Android" -ForegroundColor White
Write-Host "   [3] 🖥️  Lancer sur Windows Desktop" -ForegroundColor White
Write-Host "   [0] ❌ Quitter" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Votre choix"

Write-Host ""

switch ($choice) {
    "1" {
        Write-Host "🌐 Lancement sur Chrome..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "✨ Hot Reload activé - Modifiez le code et voyez les changements instantanément!" -ForegroundColor Yellow
        Write-Host ""
        flutter run -d chrome --web-port=8080
    }
    "2" {
        Write-Host "📱 Lancement sur Android..." -ForegroundColor Cyan
        Write-Host ""
        flutter run
    }
    "3" {
        Write-Host "🖥️  Lancement sur Windows..." -ForegroundColor Cyan
        Write-Host ""
        flutter run -d windows
    }
    default {
        Write-Host "👋 À bientôt!" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Appuyez sur une touche pour terminer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
