# Find My Car - one-click APK build (Windows PowerShell 5.1+)
# - Finds or installs JDK 17+ and the Android SDK
# - Downloaded tools go to E:\android-build (or %LOCALAPPDATA%\parking-android-build if no E: drive)
# - Result: <parking>\dist\find-my-car.apk
# - Log:    <parking>\build-log.txt

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root    = Split-Path -Parent $PSScriptRoot
$Android = Join-Path $Root 'android'
$Log     = Join-Path $Root 'build-log.txt'
Set-Content -Path $Log -Value "=== Find My Car APK build $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -Encoding UTF8

function L([string]$m) {
    Write-Host $m
    Add-Content -Path $Log -Value $m -Encoding UTF8
}

function Run([string]$cmdline) {
    L "> $cmdline"
    & cmd /c "$cmdline 2>&1" | ForEach-Object { L "$_" }
    return $LASTEXITCODE
}

function Get-JavaMajor([string]$jh) {
    if (-not $jh) { return 0 }
    $exe = Join-Path $jh 'bin\java.exe'
    if (-not (Test-Path $exe)) { return 0 }
    $out = & cmd /c "`"$exe`" -version 2>&1"
    $line = ($out | Select-Object -First 1) -as [string]
    if ($line -match 'version "(\d+)(\.(\d+))?') {
        $m = [int]$matches[1]
        if ($m -eq 1 -and $matches[3]) { $m = [int]$matches[3] }
        return $m
    }
    return 0
}

function Download([string]$url, [string]$dest) {
    L "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

$code = 0
try {
    if (Test-Path 'E:\') { $Tools = 'E:\android-build' } else { $Tools = Join-Path $env:LOCALAPPDATA 'parking-android-build' }
    New-Item -ItemType Directory -Force -Path $Tools | Out-Null
    L "Tools folder: $Tools"

    # ---------- 1. Java 17+ ----------
    $java = $null
    $cands = @($env:JAVA_HOME,
               (Join-Path $env:ProgramFiles 'Android\Android Studio\jbr'),
               (Join-Path $Tools 'jdk'))
    foreach ($c in $cands) {
        $v = Get-JavaMajor $c
        if ($c) { L "Java check: $c -> $v" }
        if ($v -ge 17) { $java = $c; break }
    }
    if (-not $java) {
        L "JDK 17 not found. Installing Temurin 17..."
        $zip = Join-Path $Tools 'jdk17.zip'
        $tmp = Join-Path $Tools 'jdk-tmp'
        Download 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse' $zip
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        Expand-Archive -Path $zip -DestinationPath $tmp -Force
        $inner = Get-ChildItem $tmp -Directory | Select-Object -First 1
        $java = Join-Path $Tools 'jdk'
        if (Test-Path $java) { Remove-Item $java -Recurse -Force }
        Move-Item $inner.FullName $java
        Remove-Item $tmp -Recurse -Force
        Remove-Item $zip -Force
    }
    $env:JAVA_HOME = $java
    $env:Path = (Join-Path $java 'bin') + ';' + $env:Path
    L "Using JAVA_HOME=$java"

    # ---------- 2. Android SDK ----------
    $sdk = $null
    $sdkCands = @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT,
                  (Join-Path $env:LOCALAPPDATA 'Android\Sdk'),
                  (Join-Path $Tools 'sdk'))
    foreach ($c in $sdkCands) {
        if ($c -and ((Test-Path (Join-Path $c 'platforms')) -or (Test-Path (Join-Path $c 'cmdline-tools')))) { $sdk = $c; break }
    }
    if (-not $sdk) {
        L "Android SDK not found. Installing command-line tools..."
        $sdk = Join-Path $Tools 'sdk'
        $zip = Join-Path $Tools 'cmdline-tools.zip'
        $tmp = Join-Path $Tools 'clt-tmp'
        Download 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip' $zip
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        Expand-Archive -Path $zip -DestinationPath $tmp -Force
        New-Item -ItemType Directory -Force -Path (Join-Path $sdk 'cmdline-tools') | Out-Null
        $latest = Join-Path $sdk 'cmdline-tools\latest'
        if (Test-Path $latest) { Remove-Item $latest -Recurse -Force }
        Move-Item (Join-Path $tmp 'cmdline-tools') $latest
        Remove-Item $tmp -Recurse -Force
        Remove-Item $zip -Force
    }
    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk
    L "Using ANDROID_HOME=$sdk"

    $sdkm = Get-ChildItem -Path (Join-Path $sdk 'cmdline-tools') -Filter 'sdkmanager.bat' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($sdkm) {
        $s = $sdkm.FullName
        L "Accepting SDK licenses..."
        Run "(for /l %i in (1,1,40) do @echo y) | `"$s`" --sdk_root=`"$sdk`" --licenses" | Out-Null
        L "Installing SDK packages (platform 35, build-tools 35.0.0)..."
        $rc = Run "`"$s`" --sdk_root=`"$sdk`" `"platforms;android-35`" `"build-tools;35.0.0`" `"platform-tools`""
        if ($rc -ne 0) { throw "sdkmanager failed ($rc)" }
    } else {
        L "sdkmanager not found in SDK; Gradle will try to download missing parts."
    }

    # ---------- 3. Gradle build ----------
    $env:GRADLE_USER_HOME = Join-Path $Tools 'gradle-home'
    $sdkProp = 'sdk.dir=' + ($sdk -replace '\\', '\\' -replace ':', '\:')
    Set-Content -Path (Join-Path $Android 'local.properties') -Value $sdkProp -Encoding ASCII

    Push-Location $Android
    try {
        $rc = Run "gradlew.bat assembleDebug --no-daemon --console=plain"
    } finally { Pop-Location }
    if ($rc -ne 0) { throw "Gradle build failed ($rc)" }

    $apk = Join-Path $Android 'app\build\outputs\apk\debug\app-debug.apk'
    if (-not (Test-Path $apk)) { throw "APK not found: $apk" }
    $dist = Join-Path $Root 'dist'
    New-Item -ItemType Directory -Force -Path $dist | Out-Null
    Copy-Item $apk (Join-Path $dist 'find-my-car.apk') -Force
    L "SUCCESS: $(Join-Path $dist 'find-my-car.apk')"
}
catch {
    L "FAILED: $($_.Exception.Message)"
    $code = 1
}
L "BUILD_EXIT=$code"
exit $code
