param([Parameter(Mandatory)][string]$Version)
$ErrorActionPreference = 'Stop'
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Expected a three-part numeric version' }
Set-Location (Split-Path $PSScriptRoot -Parent)

$publish = Join-Path $PWD 'artifacts/publish'
$dist = Join-Path $PWD 'dist'
if (Test-Path $publish) { Remove-Item $publish -Recurse -Force }
if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item $dist -ItemType Directory -Force | Out-Null

# Check that even an existing developer configuration cannot enter publish output.
$localConfig = Join-Path $PWD 'Attendance/appsettings.local.json'
if (Test-Path $localConfig) { throw 'Use a clean checkout without local credentials' }
try {
    '{"WeatherApi":{"ApiKey":"ci-do-not-publish"}}' | Set-Content $localConfig
    dotnet publish Attendance/Attendance.csproj -c Release -r win-x64 --self-contained true -o $publish "-p:Version=$Version" -p:DebugType=None -p:DebugSymbols=false -p:ContinuousIntegrationBuild=true
    if ($LASTEXITCODE -ne 0) { throw 'dotnet publish failed' }
} finally {
    Remove-Item $localConfig -ErrorAction SilentlyContinue
}

$config = Get-Content (Join-Path $publish 'appsettings.json') -Raw | ConvertFrom-Json
if ($config.WeatherApi.ApiKey -ne '' -or $config.WeatherApi.ApiHost -ne 'https://your-qweather-api-host') {
    throw 'Published weather configuration is not sanitized'
}
$privateFiles = Get-ChildItem $publish -Recurse -File | Where-Object {
    $_.Name -match '(?i)(\.local\.json$|\.pdb$|\.db(?:-shm|-wal)?$|\.sqlite3?$|^\.env|^id_rsa$|^id_ed25519$)'
}
if ($privateFiles) { throw 'Private or debug files found in publish output' }
if (!(Test-Path (Join-Path $publish 'Attendance.exe'))) { throw 'Missing application executable' }
if (!(Test-Path (Join-Path $publish 'Resources/chinese-gushiwen/guwen/guwen0-1000.json'))) {
    throw 'Missing bundled poetry data'
}

$iscc = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6/ISCC.exe'
if (!(Test-Path $iscc)) { throw 'Inno Setup 6 compiler is required' }
& $iscc "/DAppVersion=$Version" packaging/installer.iss
if ($LASTEXITCODE -ne 0) { throw 'Installer compilation failed' }

# Install outside the payload directory so runtime databases never enter the package.
$installed = Join-Path $env:RUNNER_TEMP 'attendance-install-test'
$installer = Join-Path $dist 'AttendanceInstaller.exe'
$setup = Start-Process $installer -ArgumentList @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', "/DIR=`"$installed`"") -Wait -PassThru
if ($setup.ExitCode -ne 0) { throw "Silent installation failed: $($setup.ExitCode)" }
$exe = Join-Path $installed 'Attendance.exe'
if ((Get-FileHash $exe).Hash -ne (Get-FileHash (Join-Path $publish 'Attendance.exe')).Hash) {
    throw 'Installed executable does not match verified build'
}
if (Test-Path (Join-Path $installed 'appsettings.local.json')) { throw 'Installer contains local credentials' }
$app = Start-Process $exe -WorkingDirectory $installed -PassThru
try {
    Start-Sleep -Seconds 15
    $app.Refresh()
    if ($app.HasExited) { throw "Application exited during startup: $($app.ExitCode)" }
    if ($app.MainWindowHandle -eq 0) { throw 'Application did not open its main window' }
    Write-Host 'PASS: installer, configuration, executable hash and Windows GUI startup'
} finally {
    if (!$app.HasExited) { Stop-Process -Id $app.Id -Force }
}
$hash = (Get-FileHash $installer -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  AttendanceInstaller.exe" | Set-Content (Join-Path $dist 'SHA256SUMS.txt') -Encoding ascii
