#Requires -Version 5.1
<#
  update_seed.ps1 - Download or update the DataWizard Seed from GitHub.
  Windows twin of update_seed.sh. Lives in _DataWizard\Seed\ and works from anywhere.

  Usage:
    powershell -ExecutionPolicy Bypass -File update_seed.ps1 [-Vault C:\path\to\vault]
    powershell -ExecutionPolicy Bypass -File update_seed.ps1 -InstallAutosync [-Hour 6] [-Vault C:\path\to\vault]
    powershell -ExecutionPolicy Bypass -File update_seed.ps1 -UninstallAutosync

  If run from within the Seed, auto-detects the vault root (two levels up).
  If run standalone (e.g. first install), pass -Vault explicitly.

  -InstallAutosync registers a Windows Scheduled Task that runs this script
  daily at -Hour (default 6:00) AND at every logon. StartWhenAvailable means
  a run missed while the machine was asleep or off fires as soon as the
  machine is next available - the computer does NOT need to be awake at the
  scheduled time to stay in sync. No admin rights required.

  Note: if your Seed is a git clone (Seed\.git exists), sync it with git
  instead of this script - the zip copy would leave the working tree dirty.

  Exit codes: 0 = updated/ok, 1 = error, 2 = already current, 3 = skipped (guard)
#>

[CmdletBinding()]
param(
    [string]$Vault = "",
    [switch]$InstallAutosync,
    [switch]$UninstallAutosync,
    [ValidateRange(0,23)][int]$Hour = 6
)

$ErrorActionPreference = 'Stop'

$RepoUrl = "https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip"
$TmpDir  = Join-Path $env:TEMP "dw-seed-update"
$TmpZip  = Join-Path $env:TEMP "dw-seed.zip"
$TaskName = "DataWizard Seed Update"

# --- Determine vault root ---
$VaultRoot = $Vault
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    # Script lives at _DataWizard\Seed\update_seed.ps1 ; vault root is two levels up.
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $VaultRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
}

$SeedDir = Join-Path $VaultRoot "_DataWizard\Seed"
$SyncLog = Join-Path $VaultRoot "_DataWizard\Seed Sync Log.md"
$VaultConfig = Join-Path $SeedDir "Vault Config.md"
$ScriptPath = Join-Path $SeedDir "update_seed.ps1"

function Get-VersionField {
    param([string]$File, [string]$Field)
    if (-not (Test-Path $File)) { return "unknown" }
    $match = Select-String -Path $File -Pattern ("^{0}:" -f [regex]::Escape($Field)) | Select-Object -First 1
    if ($null -eq $match) { return "unknown" }
    $val = ($match.Line -split ':', 2)[1].Trim()
    if ([string]::IsNullOrWhiteSpace($val)) { return "unknown" }
    return $val
}

function Write-LogEntry {
    param([string]$Message)
    if (-not (Test-Path $SyncLog)) {
        $today = Get-Date -Format 'yyyy-MM-dd'
        $header = @(
            "---"
            "title: Seed Sync Log"
            "type: project-doc"
            "created: $today"
            "updated: $today"
            "---"
            ""
            "# Seed Sync Log"
            ""
            "Reverse-chronological log of Seed sync events. Written automatically by update_seed.sh / update_seed.ps1 and visible in Obsidian."
            ""
            "---"
            ""
        )
        Set-Content -Path $SyncLog -Value $header -Encoding utf8
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $SyncLog -Value ("**{0}** - {1}" -f $timestamp, $Message) -Encoding utf8
    Write-Host $Message
}

function Test-Upstream {
    # The maintainer's Seed is the upstream source; auto-syncing it would
    # overwrite local edits. Guard: seed_role row containing 'upstream' in
    # the (untracked, user-specific) Vault Config.md.
    if (-not (Test-Path $VaultConfig)) { return $false }
    $match = Select-String -Path $VaultConfig -Pattern 'seed_role.*upstream' -Quiet
    return [bool]$match
}

# --- Uninstall autosync ---
if ($UninstallAutosync) {
    $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-LogEntry "Auto-sync uninstalled (Scheduled Task '$TaskName' removed)."
    } else {
        Write-Host "No Scheduled Task named '$TaskName' found - nothing to remove."
    }
    exit 0
}

# --- Install autosync ---
if ($InstallAutosync) {
    if (Test-Upstream) {
        Write-LogEntry "REFUSED: -InstallAutosync blocked. Vault Config marks this machine as the Seed upstream (seed_role: upstream)."
        exit 3
    }
    if (Test-Path (Join-Path $SeedDir ".git")) {
        Write-LogEntry "REFUSED: -InstallAutosync blocked. This Seed is a git clone - the zip sync would dirty the working tree. Sync it with git instead."
        exit 3
    }

    $timeString = "{0:00}:00" -f $Hour
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" -Vault `"{1}`"" -f $ScriptPath, $VaultRoot)
    $trigDaily = New-ScheduledTaskTrigger -Daily -At $timeString
    $trigLogon = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 15)

    Register-ScheduledTask -TaskName $TaskName -Action $action `
        -Trigger $trigDaily, $trigLogon -Settings $settings -Force | Out-Null

    # Verify it registered
    $check = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $check) {
        Write-LogEntry ("Auto-sync installed: daily at {0} + at logon, with catch-up when the machine wakes (Scheduled Task '{1}')." -f $timeString, $TaskName)
        Write-Host ""
        Write-Host "To remove later: powershell -ExecutionPolicy Bypass -File update_seed.ps1 -UninstallAutosync"
        exit 0
    } else {
        Write-LogEntry "ERROR: Scheduled Task registration did not verify. Open Task Scheduler and check for '$TaskName'."
        exit 1
    }
}

# --- Sync run below this point ---

if (Test-Upstream) {
    Write-LogEntry "SKIPPED: sync refused on the upstream (maintainer) machine per Vault Config seed_role."
    exit 3
}

if (Test-Path (Join-Path $SeedDir ".git")) {
    Write-LogEntry "SKIPPED: this Seed is a git clone. Sync it with git (fetch + fast-forward) instead of the zip copy."
    exit 3
}

# --- Capture current version (if Seed exists) ---
$OldVersion = ""
$OldPI = ""
$FreshInstall = $false
$SeedVersionFile = Join-Path $SeedDir "VERSION.md"

if (Test-Path $SeedVersionFile) {
    $OldVersion = Get-VersionField -File $SeedVersionFile -Field "seed"
    $OldPI      = Get-VersionField -File $SeedVersionFile -Field "project_instructions"
} else {
    $FreshInstall = $true
}

# --- Download from GitHub ---
Write-Host "Downloading DataWizard Seed from GitHub..."
if (Test-Path $TmpDir) { Remove-Item -Path $TmpDir -Recurse -Force }
if (Test-Path $TmpZip) { Remove-Item -Path $TmpZip -Force }

try {
    Invoke-WebRequest -Uri $RepoUrl -OutFile $TmpZip -UseBasicParsing
} catch {
    Write-LogEntry "ERROR: Failed to download from GitHub. Check network connection."
    exit 1
}

try {
    Expand-Archive -Path $TmpZip -DestinationPath $TmpDir -Force
} catch {
    Write-LogEntry "ERROR: Failed to unzip download."
    if (Test-Path $TmpDir) { Remove-Item -Path $TmpDir -Recurse -Force }
    if (Test-Path $TmpZip) { Remove-Item -Path $TmpZip -Force }
    exit 1
}

$ExtractRoot = Join-Path $TmpDir "DataWizard-main"

# --- Compare versions before copying ---
$NewVersionFile = Join-Path $ExtractRoot "VERSION.md"
$NewVersion = Get-VersionField -File $NewVersionFile -Field "seed"
$NewPI      = Get-VersionField -File $NewVersionFile -Field "project_instructions"

if ((-not $FreshInstall) -and ($OldVersion -eq $NewVersion)) {
    Write-LogEntry "Already current (Seed $OldVersion, PI $OldPI). No update needed."
    Remove-Item -Path $TmpDir -Recurse -Force
    Remove-Item -Path $TmpZip -Force
    exit 2
}

# --- Copy to Seed directory ---
# Get-ChildItem -Force includes dotfiles (e.g. .gitignore), mirroring the bash 'cp -R src/.'
if (-not (Test-Path $SeedDir)) { New-Item -ItemType Directory -Path $SeedDir -Force | Out-Null }
Get-ChildItem -Path $ExtractRoot -Force | Copy-Item -Destination $SeedDir -Recurse -Force

# --- Cleanup ---
Remove-Item -Path $TmpDir -Recurse -Force
Remove-Item -Path $TmpZip -Force

# --- Verify ---
if (-not (Test-Path (Join-Path $SeedDir "VERSION.md"))) {
    Write-LogEntry "ERROR: Update appeared to succeed but VERSION.md not found. Check $SeedDir."
    exit 1
}

# --- Log results ---
if ($FreshInstall) {
    Write-LogEntry "Fresh install complete. Seed $NewVersion, PI $NewPI."
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Paste Project Instructions into your Claude project settings."
    Write-Host "     Source: $SeedDir\DataWizard Project Instructions.md"
    Write-Host "  2. (Recommended) Turn on daily auto-sync:"
    Write-Host "     powershell -ExecutionPolicy Bypass -File `"$ScriptPath`" -InstallAutosync"
} else {
    Write-LogEntry "Updated: Seed $OldVersion -> $NewVersion, PI $OldPI -> $NewPI."
    if ($OldPI -ne $NewPI) {
        Write-LogEntry "ACTION REQUIRED: PI version changed ($OldPI -> $NewPI). Re-paste Project Instructions into Claude project settings."
        Write-Host ""
        Write-Host "!!! PROJECT INSTRUCTIONS CHANGED !!!"
        Write-Host "Re-paste from: $SeedDir\DataWizard Project Instructions.md"
    }
}

Write-Host ""
Write-Host "Seed updated successfully at $SeedDir"
exit 0
