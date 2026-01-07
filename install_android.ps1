# Script d'installation Automatique Android SDK (Version Lite Corrigée)
$SdkPath = "C:\AndroidSDK"
$FlutterPath = "$PSScriptRoot\flutter"

Write-Host "DEMARRAGE INSTALLATION ANDROID..." -ForegroundColor Green

# 1. Nettoyage
if (Test-Path $SdkPath) { 
    Write-Host "Suppression ancienne version..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $SdkPath -ErrorAction SilentlyContinue 
}
New-Item -ItemType Directory -Force -Path $SdkPath | Out-Null

# 2. Téléchargement
$Url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$ZipPath = "$SdkPath\tools.zip"

Write-Host "Telechargement des outils Android (150 Mo)..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath
} catch {
    Write-Error "Echec du telechargement. Verifiez votre connexion."
    exit
}

Write-Host "Extraction..." -ForegroundColor Cyan
Expand-Archive -Path $ZipPath -DestinationPath "$SdkPath\temp" -Force

# 3. Installation Structure
New-Item -ItemType Directory -Force -Path "$SdkPath\cmdline-tools\latest" | Out-Null
Move-Item -Path "$SdkPath\temp\cmdline-tools\*" -Destination "$SdkPath\cmdline-tools\latest" -Force
Remove-Item -Recurse -Force "$SdkPath\temp"
Remove-Item -Force $ZipPath

# 4. Installation Packages avec sdkmanager
Write-Host "Installation des composants (Cela peut prendre 2-3 minutes)..." -ForegroundColor Cyan
$SdkManager = "$SdkPath\cmdline-tools\latest\bin\sdkmanager.bat"
$Arguments = "platform-tools", "platforms;android-34", "build-tools;34.0.0"

# Accepter licences via echo y
cmd /c "echo y | `"$SdkManager`" $Arguments"

# 5. Configurer Flutter
Write-Host "Configuration de Flutter..." -ForegroundColor Cyan
& "$FlutterPath\bin\flutter" config --no-analytics
& "$FlutterPath\bin\flutter" config --android-sdk $SdkPath

Write-Host "Acceptation des licences..." -ForegroundColor Cyan
cmd /c "echo y | `"$FlutterPath\bin\flutter`" doctor --android-licenses"

Write-Host ""
Write-Host "INSTALLATION TERMINEE !" -ForegroundColor Green
Write-Host "Branchez votre telephone et lancez 'flutter run'" -ForegroundColor Yellow
Start-Sleep -Seconds 5
