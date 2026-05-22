# Auto-elevation admin (fonctionne avec Run with PowerShell, double-clic, autounattend, etc.)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$host.UI.RawUI.WindowTitle = "SETUP"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"

Clear-Host

# ── Log setup ────────────────────────────────────────────────
$_scriptRoot = Split-Path -Parent $PSCommandPath
$_usbRoot    = Split-Path -Qualifier $_scriptRoot
$_logFile    = Join-Path $_usbRoot "iso-setup_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
Start-Transcript -Path $_logFile -Append -NoClobber | Out-Null
Write-Host "  [LOG] Session enregistree : $_logFile" -ForegroundColor DarkCyan
Write-Host ""


$ignoredVK = @(8,9,13,16,17,18,19,20,33,34,35,36,37,38,39,40,45,46,91,92,93,112,113,114,115,116,117,118,119,120,121,122,123,144,145)
$lineChar   = [char]0x2550

$ESC            = [char]27
$DESTR_DEFAULT  = "${ESC}[97m"
$DESTR_SELECTED = "${ESC}[31m"
$RESET          = "${ESC}[0m"

$devices = @(
    @{ name = "Zephyrus 4090    [ zephyrus ]"; folder = "zephyrus"; label = "ASUS ROG Zephyrus G16 2024 (RTX 4090 / Intel Core Ultra 9)" },
    @{ name = "OmniBook X Flip  [ omnibook ]"; folder = "omnibook"; label = "HP OmniBook X Flip"   },
    @{ name = "Elias Desktop    [ elidesk ]";  folder = "elidesk";  label = "PC fixe Elias"        },
    @{ name = "Lilou Desktop    [ lidesk ]";   folder = "lidesk";   label = "PC fixe Lilou"        }
)

$catalog = @(
    # Outils
    @{ name = "PowerToys";           type = "winget"; id = "Microsoft.PowerToys";         cat = "Outils" },
    @{ name = "Everything";          type = "winget"; id = "voidtools.Everything";        cat = "Outils" },
    @{ name = "7-Zip";               type = "winget"; id = "7zip.7zip";                   cat = "Outils" },
    @{ name = "Obsidian";            type = "winget"; id = "Obsidian.Obsidian";           cat = "Outils" },
    @{ name = "Raycast";             type = "winget"; id = "Raycast.Raycast";             cat = "Outils" },
    @{ name = "Rufus";               type = "winget"; id = "Rufus.Rufus";                 cat = "Outils" },
    @{ name = "WinSCP";              type = "winget"; id = "WinSCP.WinSCP";               cat = "Outils" },
    @{ name = "PuTTY";               type = "winget"; id = "PuTTY.PuTTY";                 cat = "Outils" },
    @{ name = "G Helper";            type = "winget"; id = "seerge.g-helper";             cat = "Outils" },
    @{ name = "Tailscale";           type = "winget"; id = "Tailscale.Tailscale";         cat = "Outils" },
    @{ name = "Syncthing";           type = "winget"; id = "Syncthing.Syncthing";         cat = "Outils" },
    @{ name = "LocalSend";           type = "winget"; id = "LocalSend.LocalSend";         cat = "Outils" },
    @{ name = "FileZilla";           type = "winget"; id = "TimKosse.FileZilla.Client";   cat = "Outils" },
    @{ name = "UniGetUI";            type = "winget"; id = "MartiCliment.UniGetUI";       cat = "Outils" },
    @{ name = "Sejda PDF";           type = "winget"; id = "Sejda.PDFDesktop";            cat = "Outils" },
    # Gaming
    @{ name = "Steam";               type = "winget"; id = "Valve.Steam";                 cat = "Gaming" },
    @{ name = "Epic Games Launcher"; type = "winget"; id = "EpicGames.EpicGamesLauncher"; cat = "Gaming" },
    @{ name = "Minecraft Launcher";  type = "winget"; id = "Mojang.MinecraftLauncher";    cat = "Gaming" },
    @{ name = "Lunar Client";        type = "winget"; id = "Moonsworth.LunarClient";      cat = "Gaming" },
    @{ name = "AZ Launcher";         type = "url";    url = "https://www.az-launcher.nz/goto/dl?arch=win"; cat = "Gaming" },
    @{ name = "sep:AZ";              type = "separator";                                   cat = "Gaming" },
    @{ name = "Logitech GHub";       type = "winget"; id = "Logitech.GHUB";               cat = "Gaming" },
    @{ name = "Roccat Swarm";        type = "winget"; id = "TurtleBeach.ROCCATSwarm";     cat = "Gaming" },
    @{ name = "SteelSeries GG";      type = "winget"; id = "SteelSeries.GG";              cat = "Gaming" },
    @{ name = "Razer Synapse";       type = "winget"; id = "Razer.RazerSynapse";          cat = "Gaming" },
    @{ name = "Signal RGB";          type = "winget"; id = "WhirlwindFX.SignalRgb";       cat = "Gaming" },
    # Web & Cloud
    @{ name = "Zen Browser";         type = "winget"; id = "Zen-Team.Zen-Browser";        cat = "Web & Cloud" },
    @{ name = "Google Chrome";       type = "winget"; id = "Google.Chrome";               cat = "Web & Cloud" },
    @{ name = "Firefox";             type = "winget"; id = "Mozilla.Firefox";             cat = "Web & Cloud" },
    @{ name = "sep:Firefox";         type = "separator";                                   cat = "Web & Cloud" },
    @{ name = "OneDrive";            type = "winget"; id = "Microsoft.OneDrive";          cat = "Web & Cloud" },
    @{ name = "Google Drive";        type = "winget"; id = "Google.GoogleDrive";          cat = "Web & Cloud" },
    @{ name = "Proton Drive";        type = "winget"; id = "Proton.ProtonDrive";          cat = "Web & Cloud" },
    @{ name = "Proton Pass";         type = "winget"; id = "Proton.ProtonPass";           cat = "Web & Cloud" },
    @{ name = "Proton Mail";         type = "winget"; id = "Proton.ProtonMail";           cat = "Web & Cloud" },
    @{ name = "sep:Proton";          type = "separator";                                   cat = "Web & Cloud" },
    @{ name = "Uninstall OneDrive";  type = "uninstall"; uninstall = "onedrive";          cat = "Web & Cloud" },
    # Social
    @{ name = "Slack";               type = "winget"; id = "SlackTechnologies.Slack";     cat = "Social" },
    @{ name = "Discord";             type = "winget"; id = "Discord.Discord";             cat = "Social" },
    @{ name = "WhatsApp";            type = "winget"; id = "WhatsApp.WhatsApp";           cat = "Social" },
    @{ name = "Thunderbird";         type = "winget"; id = "Mozilla.Thunderbird";         cat = "Social" },
    # Developpement
    @{ name = "VS Code";             type = "winget"; id = "Microsoft.VisualStudioCode";  cat = "Developpement" },
    @{ name = "Zed";                 type = "winget"; id = "ZedIndustries.Zed";           cat = "Developpement" },
    @{ name = "Git";                 type = "winget"; id = "Git.Git";                     cat = "Developpement" },
    @{ name = "Termius";             type = "winget"; id = "Termius.Termius";             cat = "Developpement" },
    @{ name = "Framer";              type = "winget"; id = "Framer.Framer";               cat = "Developpement" },
    @{ name = "Claude";              type = "winget"; id = "Anthropic.Claude";            cat = "Developpement" },
    @{ name = "Claude Code";         type = "winget"; id = "Anthropic.ClaudeCode";        cat = "Developpement" },
    @{ name = "Perplexity";          type = "winget"; id = "Perplexity.Comet";            cat = "Developpement" },
    # Media
    @{ name = "VLC";                 type = "winget"; id = "VideoLAN.VLC";                cat = "Media" },
    @{ name = "Plex";                type = "winget"; id = "Plex.Plex";                   cat = "Media" },
    @{ name = "Stremio";             type = "winget"; id = "Stremio.Stremio";             cat = "Media" },
    @{ name = "qBittorrent";         type = "winget"; id = "qBittorrent.qBittorrent";     cat = "Media" },
    @{ name = "TypeWhisper";         type = "url";    url = "https://github.com/TypeWhisper/typewhisper-win/releases/download/v0.7.0/TypeWhisper-win-x64-Setup.exe"; cat = "Media" },
    # Autres
    @{ name = "Office 2024 Home";    type = "url";    url = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Home2024Retail&platform=x64&language=fr-fr&version=O16GA"; cat = "Autres" },
    @{ name = "Microsoft Store";     type = "store";                                       cat = "Autres" },
    @{ name = "MAS Activation";      type = "mas";                                         cat = "Autres" },
    @{ name = "WinToys";             type = "winget"; id = "9P8LTPGCBZXD";                cat = "Autres" },
    @{ name = "Windhawk";            type = "winget"; id = "RamenSoftware.Windhawk";      cat = "Autres" },
    @{ name = "WinHance";            type = "winhance";                                    cat = "Autres" },
    @{ name = "sep:WinHance";        type = "separator";                                   cat = "Autres" },
    @{ name = "Uninstall OneNote";   type = "uninstall"; uninstall = "onenote";           cat = "Autres" }
)

$categoryOrder = @("Outils","Gaming","Web & Cloud","Social","Developpement","Media","Autres")

# ── Helpers ──────────────────────────────────────────────────

function Get-FullLine {
    $width = $host.UI.RawUI.WindowSize.Width - 4
    if ($width -lt 20) { $width = 20 }
    return ($lineChar.ToString() * $width)
}

function Read-KeyAny {
    while ($true) {
        $k = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($ignoredVK -contains $k.VirtualKeyCode) { continue }
        return $k
    }
}

function Read-KeyChoice {
    param([string[]]$validChars, [switch]$AllowEscape)
    while ($true) {
        $k = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($AllowEscape -and $k.VirtualKeyCode -eq 27) { return 'ESC' }
        if ($ignoredVK -contains $k.VirtualKeyCode) { continue }
        $c = $k.Character.ToString()
        if ($validChars -contains $c) { return $c }
    }
}

function Read-NumberChoice {
    param(
        [int]$Min = 1,
        [int]$Max = 99,
        [int]$TimeoutMs = 250,
        [switch]$AllowShortcutP,
        [switch]$AllowEscape
    )
    while ($true) {
        $k1  = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $c1  = $k1.Character.ToString()
        $vk1 = $k1.VirtualKeyCode

        if ($AllowEscape    -and $vk1 -eq 27) { return 'ESC' }
        if ($AllowShortcutP -and $vk1 -eq 80) { return 'P'   }
        if ($ignoredVK -contains $vk1)         { continue     }
        if ($c1 -notmatch '^[0-9]$')           { continue     }
        if ($c1 -eq '0')                        { continue     }

        $first = [int]$c1
        $possibleSecondDigits = @()
        for ($d = 0; $d -le 9; $d++) {
            $candidate = [int]("$c1$d")
            if ($candidate -ge $Min -and $candidate -le $Max) { $possibleSecondDigits += $d }
        }
        if ($possibleSecondDigits.Count -eq 0) {
            if ($first -ge $Min -and $first -le $Max) { return $first }
            continue
        }
        if ([Console]::KeyAvailable) {
            $k2  = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($AllowEscape -and $k2.VirtualKeyCode -eq 27) { return 'ESC' }
            if ($ignoredVK -contains $k2.VirtualKeyCode) {
                if ($first -ge $Min -and $first -le $Max) { return $first }
                continue
            }
            $c2  = $k2.Character.ToString()
            $vk2 = $k2.VirtualKeyCode
            if ($AllowShortcutP -and $vk2 -eq 80) { return 'P' }
            if ($c2 -match '^[0-9]$') {
                $num = [int]("$c1$c2")
                if ($num -ge $Min -and $num -le $Max) { return $num }
            }
            if ($first -ge $Min -and $first -le $Max) { return $first }
            continue
        }
        $deadline = [DateTime]::Now.AddMilliseconds($TimeoutMs)
        while ([DateTime]::Now -lt $deadline) {
            if ([Console]::KeyAvailable) {
                $k2  = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                if ($AllowEscape -and $k2.VirtualKeyCode -eq 27) { return 'ESC' }
                if ($ignoredVK -contains $k2.VirtualKeyCode) { continue }
                $c2  = $k2.Character.ToString()
                $vk2 = $k2.VirtualKeyCode
                if ($AllowShortcutP -and $vk2 -eq 80) { return 'P' }
                if ($c2 -match '^[0-9]$') {
                    $num = [int]("$c1$c2")
                    if ($num -ge $Min -and $num -le $Max) { return $num }
                    break
                }
                break
            }
            Start-Sleep -Milliseconds 10
        }
        if ($first -ge $Min -and $first -le $Max) { return $first }
    }
}

function Write-Header {
    param([string]$Title)
    Clear-Host
    Write-Host ""
    Write-Host "  MonSetup - Installation personnalisee" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
}

function Write-Success { param([string]$msg) Write-Host "  $msg" -ForegroundColor Green }
function Write-Fail    { param([string]$msg) Write-Host "  $msg" -ForegroundColor Red   }
function Write-Info    { param([string]$msg) Write-Host "  $msg" -ForegroundColor Gray  }
function Write-Step    { param([string]$msg) Write-Host "  $msg" -ForegroundColor Cyan  }
function Wait-Return   { $null = Read-KeyAny }

# ── Catalogue ────────────────────────────────────────────────

function Show-AppCatalog {
    param([bool[]]$selected)

    Write-Header "Applications"

    $catPerRow = 3
    $colWidth  = 38

    for ($r = 0; $r -lt $categoryOrder.Count; $r += $catPerRow) {

        $rowCats = @()
        for ($c = 0; $c -lt $catPerRow; $c++) {
            $ci = $r + $c
            $rowCats += if ($ci -lt $categoryOrder.Count) { $categoryOrder[$ci] } else { $null }
        }

        $lists = New-Object System.Collections.ArrayList
        foreach ($cat in $rowCats) {
            $apps = New-Object System.Collections.ArrayList
            if ($null -ne $cat) {
                for ($i = 0; $i -lt $catalog.Count; $i++) {
                    if ($catalog[$i].cat -eq $cat) { [void]$apps.Add(@{ idx = $i; app = $catalog[$i] }) }
                }
            }
            [void]$lists.Add($apps)
        }

        Write-Host "  " -NoNewline
        for ($c = 0; $c -lt $catPerRow; $c++) {
            if ($null -ne $rowCats[$c]) {
                $label = $rowCats[$c].PadRight($colWidth)
                Write-Host "${ESC}[1;34m${label}${RESET}" -NoNewline
            } else {
                Write-Host ("".PadRight($colWidth)) -NoNewline
            }
        }
        Write-Host ""

        $maxLines = 0
        foreach ($list in $lists) { if ($list.Count -gt $maxLines) { $maxLines = $list.Count } }

        for ($line = 0; $line -lt $maxLines; $line++) {
            Write-Host "  " -NoNewline
            for ($c = 0; $c -lt $catPerRow; $c++) {
                $list = $lists[$c]
                if ($line -lt $list.Count) {
                    $entry = $list[$line]
                    if ($entry.app.type -eq "separator") {
                        $refName = $entry.app.name -replace '^sep:', ''
                        $sepLen  = 4 + $refName.Length
                        $sepStr  = ("-" * $sepLen).PadRight($colWidth)
                        Write-Host "${ESC}[90m${sepStr}${RESET}" -NoNewline
                    } else {
                        $num  = ($entry.idx + 1).ToString().PadLeft(2, '0')
                        $text = "$num  $($entry.app.name)".PadRight($colWidth)
                        if ($entry.app.type -eq "uninstall") {
                            $ansi = if ($selected[$entry.idx]) { $DESTR_SELECTED } else { $DESTR_DEFAULT }
                            Write-Host "${ansi}${text}${RESET}" -NoNewline
                        } else {
                            $color = if ($selected[$entry.idx]) { 'Green' } else { 'White' }
                            Write-Host $text -ForegroundColor $color -NoNewline
                        }
                    }
                } else {
                    Write-Host ("".PadRight($colWidth)) -NoNewline
                }
            }
            Write-Host ""
        }
        Write-Host ""
    }

    $count = ($selected | Where-Object { $_ }).Count
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    if ($count -gt 0) {
        Write-Host "  Panier : $count application(s) selectionnee(s)" -ForegroundColor Green
    } else {
        Write-Host "  Panier : vide" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Numero = cocher/decocher   " -ForegroundColor DarkGray -NoNewline
    Write-Host "P" -ForegroundColor White -NoNewline
    Write-Host " = panier   Echap = retour menu" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Uninstall handlers ───────────────────────────────────────

function Invoke-UninstallOneDrive {
    Write-Step "Desinstallation de OneDrive..."
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    $already = winget list --exact --id Microsoft.OneDrive --accept-source-agreements 2>&1
    if ($already -match "Microsoft.OneDrive") {
        winget uninstall --exact --id Microsoft.OneDrive --silent --accept-source-agreements 2>&1 | Out-Null
    }
    $paths = @(
        "$env:SystemRoot\System32\OneDriveSetup.exe",
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe",
        "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDriveSetup.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { Start-Process $p -ArgumentList "/uninstall" -Wait -ErrorAction SilentlyContinue; break }
    }
    Remove-Item "$env:USERPROFILE\OneDrive"             -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive"  -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive"   -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKCU:\Software\Microsoft\OneDrive"     -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKLM:\Software\Microsoft\OneDrive"     -Recurse -Force -ErrorAction SilentlyContinue
    Write-Success "OneDrive desinstalle"
    return "ok"
}

function Invoke-UninstallOneNote {
    Write-Step "Desinstallation de OneNote..."
    $pkg = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*OneNote*" }
    if ($pkg) {
        $pkg | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Success "OneNote (Store) desinstalle"
    }
    $reg = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    foreach ($key in $reg) {
        Get-ChildItem $key -ErrorAction SilentlyContinue | ForEach-Object {
            $disp = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($disp -like "*OneNote*") {
                $uninst = (Get-ItemProperty $_.PSPath).UninstallString
                if ($uninst) { Start-Process "cmd.exe" -ArgumentList "/c $uninst /quiet" -Wait -ErrorAction SilentlyContinue }
            }
        }
    }
    Write-Success "OneNote desinstalle"
    return "ok"
}

# ── Installer un fichier EXE ou MSI silencieusement ──────────
#
# Switches silencieux :
#   .msi  -> msiexec /i ... /qn /norestart
#   .exe  -> /s /S /silent /quiet /norestart
#
# Codes de sortie OK : 0, 3010 (reboot needed), 1641 (reboot initiated)

function Invoke-SilentInstaller {
    param(
        [string]$FilePath,
        [string]$Label
    )

    $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()

    try {
        if ($ext -eq ".msi") {
            $proc = Start-Process "msiexec.exe" `
                -ArgumentList @("/i", "`"$FilePath`"", "/qn", "/norestart") `
                -Wait -PassThru -ErrorAction Stop
        } else {
            $proc = Start-Process -FilePath "`"$FilePath`"" `
                -ArgumentList @("/s", "/S", "/silent", "/quiet", "/norestart", "-s", "-noreboot") `
                -Wait -PassThru -ErrorAction Stop
        }

        if ($proc.ExitCode -in @(0, 3010, 1641)) {
            Write-Success "    OK  $Label  (exit $($proc.ExitCode))"
            return $true
        } else {
            Write-Fail "    FAIL  $Label  (exit $($proc.ExitCode))"
            return $false
        }
    } catch {
        Write-Fail "    ERREUR  $Label : $_"
        return $false
    }
}

# ── Install dispatcher ───────────────────────────────────────

function Invoke-InstallApp {
    param($app)

    if ($app.type -eq "uninstall") {
        switch ($app.uninstall) {
            "onedrive" { return Invoke-UninstallOneDrive }
            "onenote"  { return Invoke-UninstallOneNote  }
        }
        Write-Fail "$($app.name) - handler manquant"
        return "fail"
    }

    if ($app.type -eq "winget") {
        $already = winget list --exact --id $app.id --accept-source-agreements 2>&1
        if ($already -match [regex]::Escape($app.id)) {
            Write-Info "$($app.name) - deja installe, ignore"
            return "skipped"
        }
        winget install --exact --id $app.id --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Success "$($app.name) - installe"; return "ok" }
        else                     { Write-Fail    "$($app.name) - echec (code $LASTEXITCODE)"; return "fail" }
    }

    if ($app.type -eq "url") {
        Write-Step "Telechargement : $($app.name)..."
        $tmp = "$env:TEMP\$($app.name -replace '[^a-zA-Z0-9]','_').exe"
        try {
            Invoke-WebRequest -Uri $app.url -OutFile $tmp -UseBasicParsing
            Write-Step "Lancement : $($app.name)..."
            $proc = Start-Process -FilePath $tmp -PassThru
            $proc.WaitForExit()
            Write-Success "$($app.name) - installation terminee"
            return "ok"
        } catch {
            Write-Fail "$($app.name) - echec telechargement : $_"
            return "fail"
        }
    }

    if ($app.type -eq "mas") {
        Write-Step "Execution de MAS..."
        Write-Host ""
        try {
            & ([ScriptBlock]::Create((irm https://get.activated.win)))
            Write-Host ""
            Write-Success "MAS - termine"
            return "ok"
        } catch {
            Write-Fail "MAS - echec : $_"
            return "fail"
        }
    }

    if ($app.type -eq "store") {
        Write-Step "Reinstallation Microsoft Store..."
        Start-Process "wsreset.exe" -ArgumentList "-i" -Wait
        Write-Success "Microsoft Store - reinstalle"
        return "ok"
    }

    if ($app.type -eq "winhance") {
        Write-Step "Installation de WinHance..."
        try {
            & ([ScriptBlock]::Create((irm "https://raw.githubusercontent.com/memstechtips/Winhance/main/Install-Winhance.ps1")))
            Write-Host ""
            Write-Success "WinHance - installe"
            return "ok"
        } catch {
            Write-Fail "WinHance - echec : $_"
            return "fail"
        }
    }

    Write-Fail "$($app.name) - type inconnu"
    return "fail"
}

# ── Panier & installation ────────────────────────────────────

function Install-Packages {
    [bool[]]$selected = @()
    for ($i = 0; $i -lt $catalog.Count; $i++) { $selected += $false }

    while ($true) {
        Show-AppCatalog -selected $selected
        $choice = Read-NumberChoice -Min 1 -Max $catalog.Count -AllowShortcutP -AllowEscape
        if ($choice -eq 'ESC') { return }

        if ($choice -eq 'P') {
            $cart = @()
            for ($i = 0; $i -lt $catalog.Count; $i++) {
                if ($selected[$i] -and $catalog[$i].type -ne "separator") { $cart += $catalog[$i] }
            }

            Write-Header "Panier"
            if ($cart.Count -eq 0) { continue }

            Write-Host "  Actions a effectuer :" -ForegroundColor White
            Write-Host ""
            foreach ($app in $cart) {
                $tag = switch ($app.type) {
                    "url"       { " [URL]"         }
                    "mas"       { " [MAS]"         }
                    "store"     { " [Store]"       }
                    "uninstall" { " [Suppression]" }
                    "winhance"  { " [Script]"      }
                    default     { ""               }
                }
                $color = if ($app.type -eq "uninstall") { 'Red' } else { 'Green' }
                Write-Host "  $($app.name)$tag" -ForegroundColor $color
            }
            Write-Host ""
            Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Total : $($cart.Count) element(s)" -ForegroundColor White
            Write-Host ""
            Write-Host "  Confirmer ? O / N / Echap : " -ForegroundColor White -NoNewline

            $confirm = Read-KeyChoice @('O','o','N','n') -AllowEscape
            if ($confirm -eq 'ESC') { continue }
            Write-Host $confirm
            if ($confirm -match '^[Nn]$') { continue }

            Write-Header "Traitement en cours"

            try {
                $wv = winget --version 2>&1
                Write-Success "winget detecte : $wv"
            } catch {
                Write-Fail "winget non disponible. Tentative de reparation..."
                Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
            }

            Write-Host ""
            $success = 0; $failed = 0; $skipped = 0
            foreach ($app in $cart) {
                $r = Invoke-InstallApp -app $app
                switch ($r) {
                    "ok"      { $success++ }
                    "fail"    { $failed++  }
                    "skipped" { $skipped++ }
                }
            }

            Write-Host ""
            Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
            Write-Host ""
            Write-Success "Reussis  : $success"
            Write-Info    "Ignores  : $skipped"
            if ($failed -gt 0) { Write-Fail "Echoues  : $failed" }
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir au menu principal..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $selected.Count) {
            if ($catalog[$idx].type -ne "separator") {
                $selected[$idx] = -not $selected[$idx]
            }
        }
    }
}

# ── Drivers ──────────────────────────────────────────────────
#
# Structure attendue sur la cle USB :
#
#   <USB>:\SETUP\drvs\<device>\EXE.zip  -> archive contenant les dossiers 1\, 2\, 3\...
#   <USB>:\SETUP\drvs\<device>\INF.zip  -> archive contenant les drivers .inf
#
# Structure de travail sur le PC :
#
#   C:\SETUP\DRIVERS\<device>\EXE.zip   -> copie locale de EXE.zip
#   C:\SETUP\DRIVERS\<device>\INF.zip   -> copie locale de INF.zip
#   C:\SETUP\DRIVERS\<device>\EXE\      -> extraction locale des installateurs
#   C:\SETUP\DRIVERS\<device>\INF\      -> extraction locale des drivers INF
#
# Deroulement :
#
#   1. Recherche du dossier <USB>:\SETUP\drvs\<device> sur la cle USB
#   2. Copie de EXE.zip et INF.zip vers C:\SETUP\DRIVERS\<device>
#   3. Dezippage local de EXE.zip et INF.zip sur le disque
#   4. Lancement de chaque EXE/MSI dans l'ordre (1, 2, 3...) depuis C:
#   5. Message "Appuyez sur une touche" apres chaque lancement
#   6. Import des drivers INF via pnputil depuis C:\SETUP\DRIVERS\<device>\INF
#   7. Suppression des ZIP et dossiers extraits locaux
#
# Resultat :
#
#   - La cle USB reste propre et inchangee
#   - Les installations se lancent depuis le disque local
#   - Les performances et la fiabilite sont meilleures que depuis la cle USB

function Install-Drivers {
    Write-Header "Installation des drivers"
    Write-Host "  Quel appareil souhaitez-vous equiper ?" -ForegroundColor White
    Write-Host ""

    $valid = @()
    for ($i = 0; $i -lt $devices.Count; $i++) {
        $n = ($i + 1).ToString()
        Write-Host "  $n   $($devices[$i].name)" -ForegroundColor White
        $valid += $n
    }

    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Votre choix  1-$($devices.Count)  Echap : " -ForegroundColor White -NoNewline

    $choice = Read-KeyChoice $valid -AllowEscape
    if ($choice -eq 'ESC') { return }
    Write-Host $choice
    $device = $devices[[int]$choice - 1]

    Write-Header "Drivers : $($device.name)"
    Write-Info $device.label
    Write-Host ""
    Write-Host "  O  Oui, installer" -ForegroundColor Green
    Write-Host "  N  Non, annuler"   -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Votre choix  O / N / Echap : " -ForegroundColor White -NoNewline

    $confirm = Read-KeyChoice @('O','o','N','n') -AllowEscape
    if ($confirm -eq 'ESC' -or $confirm -match '^[Nn]$') { return }
    Write-Host $confirm
    Write-Host ""

    Write-Step "Recherche de la cle USB (SETUP\drvs\$($device.folder))..."
    Write-Host ""

    $devicePath = $null
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -ne 'C:\' -and $_.Root -ne '' }
    foreach ($drive in $drives) {
        $candidate = Join-Path $drive.Root "SETUP\drvs\$($device.folder)"
        if (Test-Path $candidate) {
            $devicePath = $candidate
            break
        }
    }

    if (-not $devicePath) {
        Write-Fail "Dossier introuvable : SETUP\drvs\$($device.folder) sur une cle USB."
        Write-Info "Structure attendue  : <USB>:\SETUP\drvs\$($device.folder)\EXE.zip et INF.zip"
        Write-Host ""
        Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
        Wait-Return
        return
    }

    Write-Success "Dossier source trouve : $devicePath"
    Write-Host ""

    $totalOk   = 0
    $totalFail = 0

    # ── Source USB (lecture seule) ─────────────────────────────
    $exeZipSrc = Join-Path $devicePath "EXE.zip"
    $infZipSrc = Join-Path $devicePath "INF.zip"

    # ── Cible locale sur C: ────────────────────────────────────
    $localRoot   = Join-Path "C:\SETUP\DRIVERS" $device.folder
    $exeZipLocal = Join-Path $localRoot "EXE.zip"
    $infZipLocal = Join-Path $localRoot "INF.zip"
    $exeRootPath = Join-Path $localRoot "EXE"
    $infPath     = Join-Path $localRoot "INF"

    Write-Step "Preparation du dossier local : $localRoot"
    Write-Host ""
    try {
        New-Item -Path $localRoot -ItemType Directory -Force | Out-Null
        Write-Success "  Dossier local pret."
    } catch {
        Write-Fail "  Impossible de creer le dossier local : $_"
        Write-Host ""
        Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
        Wait-Return
        return
    }

    Write-Host ""
    Write-Step "Copie des archives depuis la cle USB vers C:\SETUP\DRIVERS..."
    Write-Host ""

    if (Test-Path $exeZipSrc) {
        try {
            Copy-Item -LiteralPath $exeZipSrc -Destination $exeZipLocal -Force -ErrorAction Stop
            Write-Success "  EXE.zip copie vers le disque local."
        } catch {
            Write-Fail "  Echec copie EXE.zip : $_"
        }
    } else {
        Write-Fail "  EXE.zip introuvable sur la cle USB."
    }

    if (Test-Path $infZipSrc) {
        try {
            Copy-Item -LiteralPath $infZipSrc -Destination $infZipLocal -Force -ErrorAction Stop
            Write-Success "  INF.zip copie vers le disque local."
        } catch {
            Write-Fail "  Echec copie INF.zip : $_"
        }
    } else {
        Write-Fail "  INF.zip introuvable sur la cle USB."
    }

    Write-Host ""
    Write-Step "Nettoyage des anciens dossiers extraits locaux..."
    Write-Host ""

    foreach ($folder in @($exeRootPath, $infPath)) {
        if (Test-Path $folder) {
            try {
                Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction Stop
                Write-Success "  Ancien dossier supprime : $folder"
            } catch {
                Write-Fail "  Impossible de supprimer $folder : $_"
            }
        }
    }

    Write-Host ""
    Write-Step "Dezippage des archives locales..."
    Write-Host ""

    if (-not (Test-Path $exeZipLocal)) {
        Write-Fail "EXE.zip absent localement - etape EXE/MSI impossible."
    } else {
        try {
            New-Item -Path $exeRootPath -ItemType Directory -Force | Out-Null
            Expand-Archive -LiteralPath $exeZipLocal -DestinationPath $exeRootPath -Force -ErrorAction Stop
            Write-Success "  EXE.zip extrait dans $exeRootPath"
        } catch {
            Write-Fail "  Erreur extraction EXE.zip : $_"
        }
    }

    if (-not (Test-Path $infZipLocal)) {
        Write-Fail "INF.zip absent localement - etape INF impossible."
    } else {
        try {
            New-Item -Path $infPath -ItemType Directory -Force | Out-Null
            Expand-Archive -LiteralPath $infZipLocal -DestinationPath $infPath -Force -ErrorAction Stop
            Write-Success "  INF.zip extrait dans $infPath"
        } catch {
            Write-Fail "  Erreur extraction INF.zip : $_"
        }
    }

    Write-Host ""

    # ── ETAPE 1/2 : EXE / MSI ─────────────────────────────────
    if (Test-Path $exeRootPath) {
        $numFolders = Get-ChildItem -Path $exeRootPath -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^\d+$' } |
            Sort-Object { [int]$_.Name }

        if ($numFolders.Count -gt 0) {
            $totalFiles = 0
            foreach ($folder in $numFolders) {
                $totalFiles += (
                    Get-ChildItem -Path $folder.FullName -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Extension.ToLower() -in @('.exe', '.msi') }
                ).Count
            }

            Write-Step "ETAPE 1/2 - Drivers EXE/MSI  ($($numFolders.Count) dossier(s) / $totalFiles fichier(s))"
            Write-Host ""
            Write-Host "  Les installateurs vont se lancer un par un depuis C:\SETUP\DRIVERS." -ForegroundColor Yellow
            Write-Host "  Apres chaque lancement, installe ou ferme la fenetre, puis reviens ici et appuie sur une touche." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
            Write-Host ""

            foreach ($folder in $numFolders) {
                $installers = Get-ChildItem -Path $folder.FullName -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Extension.ToLower() -in @('.exe', '.msi') } |
                    Sort-Object Name

                if ($installers.Count -eq 0) {
                    Write-Info "  [$($folder.Name)] Aucun installateur (.exe/.msi) - dossier ignore."
                    Write-Host ""
                    continue
                }

                Write-Host "  Dossier [$($folder.Name)]  -  $($installers.Count) fichier(s)" -ForegroundColor Cyan
                Write-Host ""

                foreach ($installer in $installers) {
                    Write-Host ""
                    Write-Host "  $($installer.Name)" -ForegroundColor White
                    Write-Host "  Chemin : $($installer.FullName)" -ForegroundColor DarkGray
                    Write-Host ""

                    try {
                        if ($installer.Extension.ToLower() -eq '.msi') {
                            Start-Process "msiexec.exe" -ArgumentList @("/i", "`"$($installer.FullName)`"") | Out-Null
                        } else {
                            Start-Process -FilePath $installer.FullName | Out-Null
                        }
                        Write-Success "  Lancement effectue. Termine l'installation dans la fenetre ouverte."
                    } catch {
                        Write-Fail "  Erreur lancement : $_"
                    }

                    Write-Host ""
                    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
                    Write-Host ""
                    Write-Host "  Appuyez sur une touche pour lancer le suivant..." -ForegroundColor DarkGray
                    Wait-Return
                }

                Write-Host ""
            }
        } else {
            Write-Info "EXE.zip present mais aucun dossier numerique 1/2/3... n'a ete trouve apres extraction."
            Write-Host ""
        }
    } else {
        Write-Info "EXE.zip absent ou extraction impossible."
        Write-Host ""
    }

    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Tous les EXE/MSI ont ete lances." -ForegroundColor Green
    Write-Host "  Passage a l'etape 2 : import des drivers INF via pnputil." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Appuyez sur une touche pour continuer..." -ForegroundColor DarkGray
    Wait-Return

    # ── ETAPE 2/2 : INF via pnputil ───────────────────────────
    if (Test-Path $infPath) {
        $infFiles = Get-ChildItem -Path $infPath -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue
        if ($infFiles.Count -gt 0) {
            Write-Step "ETAPE 2/2 - Drivers INF via pnputil  ($($infFiles.Count) fichier(s))"
            Write-Host ""
            $result = pnputil.exe /add-driver "$infPath\*.inf" /subdirs /install 2>&1
            foreach ($line in $result) {
                if     ($line -match 'Install|Ajout')      { Write-Success $line; $totalOk++   }
                elseif ($line -match 'Failed|Echec|Error') { Write-Fail    $line; $totalFail++ }
                elseif ($line.Trim() -ne '')               { Write-Info    $line               }
            }
        } else {
            Write-Info "INF.zip present mais aucun .inf n'a ete trouve apres extraction."
        }
    } else {
        Write-Info "INF.zip absent ou extraction impossible."
    }

    # ── Nettoyage local uniquement ─────────────────────────────
    Write-Host ""
    Write-Step "Nettoyage : suppression des dossiers et archives locales..."
    Write-Host ""

    foreach ($item in @($exeRootPath, $infPath, $exeZipLocal, $infZipLocal)) {
        if (Test-Path $item) {
            try {
                Remove-Item -LiteralPath $item -Recurse -Force -ErrorAction Stop
                Write-Success "  Supprime : $item"
            } catch {
                Write-Fail "  Impossible de supprimer $item : $_"
            }
        }
    }

    try {
        if (Test-Path $localRoot) {
            $remaining = Get-ChildItem -LiteralPath $localRoot -Force -ErrorAction SilentlyContinue
            if (-not $remaining) {
                Remove-Item -LiteralPath $localRoot -Force -ErrorAction SilentlyContinue
                Write-Success "  Dossier racine local supprime : $localRoot"
            }
        }
    } catch {
        Write-Fail "  Nettoyage final incomplet : $_"
    }

    Write-Host ""
    Write-Info "La cle USB n'a pas ete modifiee : seuls les ZIP sources ont ete lus."
    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Success "Installation terminee : $($device.name)"
    Write-Success "Reussis  : $totalOk"
    if ($totalFail -gt 0) { Write-Fail "Echoues  : $totalFail" }
    Write-Info "Un redemarrage peut etre necessaire pour finaliser certains drivers."
    Write-Host ""
    Write-Host "  Appuyez sur une touche pour revenir au menu principal..." -ForegroundColor DarkGray
    Wait-Return
}


# ── Mise à jour depuis GitHub ─────────────────────────────────

function Update-Script {
    Write-Header "Mise a jour depuis GitHub"

    # ── CONFIGURE ICI ──────────────────────────────────────────
    $githubRawUrl = "https://raw.githubusercontent.com/Eliaas01/iso-setup/main/iso-setup.ps1"
    # ───────────────────────────────────────────────────────────

    Write-Info "URL source : $githubRawUrl"
    Write-Host ""
    Write-Step "Connexion a GitHub..."
    Write-Host ""

    try {
        $remoteContent = Invoke-WebRequest -Uri $githubRawUrl -UseBasicParsing -ErrorAction Stop

        if ($remoteContent.StatusCode -ne 200) {
            Write-Fail "Erreur HTTP : $($remoteContent.StatusCode)"
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        $remoteText = $remoteContent.Content

        $selfPath = $PSCommandPath
        if (-not $selfPath) { $selfPath = $MyInvocation.ScriptName }

        if (-not $selfPath -or -not (Test-Path $selfPath)) {
            Write-Fail "Impossible de determiner le chemin du script actuel."
            Write-Info "Lance le script avec : powershell.exe -File <chemin>"
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        Write-Success "Script local localise : $selfPath"
        Write-Host ""

        $localText   = Get-Content -LiteralPath $selfPath -Raw -Encoding UTF8
        $localLines  = ($localText  -split "`n").Count
        $remoteLines = ($remoteText -split "`n").Count

        Write-Info "Version locale   : $localLines lignes"
        Write-Info "Version distante : $remoteLines lignes"
        Write-Host ""

        if ($localText.Trim() -eq $remoteText.Trim()) {
            Write-Success "Le script est deja a jour !"
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        Write-Host "  Une mise a jour est disponible." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Remplacer le script actuel ? O / N / Echap : " -ForegroundColor White -NoNewline

        $confirm = Read-KeyChoice @('O','o','N','n') -AllowEscape
        if ($confirm -eq 'ESC' -or $confirm -match '^[Nn]$') {
            Write-Host $confirm
            Write-Host ""
            Write-Info "Mise a jour annulee."
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }
        Write-Host $confirm
        Write-Host ""

        $backupPath = $selfPath -replace '\.ps1$', "_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
        Copy-Item -LiteralPath $selfPath -Destination $backupPath -Force
        Write-Info "Sauvegarde creee : $backupPath"
        Write-Host ""

        [System.IO.File]::WriteAllText($selfPath, $remoteText, [System.Text.Encoding]::UTF8)

        Write-Success "Script mis a jour avec succes !"
        Write-Host ""
        Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Le script va se relancer automatiquement..." -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 2

        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$selfPath`"" -Verb RunAs
        exit

    } catch {
        Write-Fail "Erreur lors de la mise a jour : $_"
        Write-Host ""
        Write-Host "  Verifie ta connexion internet et que le depot GitHub est accessible." -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
        Wait-Return
    }
}




# =========================================================================
# WINHANCEMENT - Optimisations registre
# =========================================================================

function Invoke-WinHancement {
    Clear-Host
    Write-Host "`n=== WINHANCEMENT : Optimisations registre ===" -ForegroundColor Cyan

    function Set-Reg {
        param([string]$Path, [string]$Name, [string]$Type, $Value, [string]$Desc)
        try {
            if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
            Write-Host "[OK] $Desc" -ForegroundColor Green
        } catch {
            Write-Host "[ERR] $Desc : $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    function Remove-Reg {
        param([string]$Path, [string]$Name, [string]$Desc)
        try {
            if (Test-Path $Path) {
                Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
                Write-Host "[OK] Supprime : $Desc" -ForegroundColor Green
            }
        } catch {
            Write-Host "[ERR] $Desc : $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n=== TELEMETRIE & CONFIDENTIALITE ===" -ForegroundColor Cyan

    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" 0 "Telemetrie desactivee"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" 0 "Telemetrie (policies)"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "MaxTelemetryAllowed" "DWord" 0 "Telemetrie max = 0"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AITEnable" "DWord" 0 "AIT desactive"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableTailoredExperiencesWithDiagnosticData" "DWord" 1 "Experiences personnalisees desactivees"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" "DWord" 1 "Notifications feedback desactivees"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "AllowInputPersonalization" "DWord" 0 "Personnalisation saisie desactivee"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" 2 "Apps background desactivees"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessAppDiagnostics" "DWord" 2 "Acces diagnostic apps desactive"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" "DWord" 0 "CEIP desactive"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 1 "Error Reporting desactive"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 1 "Error Reporting (local)"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" "DWord" 0 "Cortana desactive"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" 1 "App suggestions desactivees"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" 1 "Metadonnees peripherique reseau desactivees"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" "DWord" 1 "Advertising ID desactive"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" "KFMBlockOptIn" "DWord" 1 "OneDrive KFM backup bloque"

    Write-Host "`n=== PERFORMANCES SYSTEME ===" -ForegroundColor Cyan

    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" "DWord" 2 "Priorite foreground apps"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" "DWord" 20 "Reactivite systeme multimedia"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Priority" "DWord" 2 "Priorite CPU jeux"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Scheduling Category" "String" "Medium" "Categorie scheduling jeux"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" "DWord" 8 "Priorite GPU jeux"
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "DWord" 2 "Hardware GPU Scheduling"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "DWord" 10 "Network Throttling Index"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "StartupDelayInMSec" "DWord" 0 "Startup delay supprime"
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" "DWord" 3 "Prefetcher active"
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" "DWord" 3 "Superfetch active"

    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" "MaintenanceDisabled" "DWord" 1 "Maintenance automatique desactivee"

    Write-Host "`n=== WINDOWS UPDATE ===" -ForegroundColor Cyan

    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" "DWord" 1 "Pas de redemarrage auto avec user connecte"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "ExcludeWUDriversInQualityUpdate" "DWord" 1 "Drivers exclus des quality updates"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AllowAutoWindowsUpdateDownloadOverMeteredNetwork" "DWord" 0 "Pas de MAJ sur reseau limite"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" "AUOptions" "DWord" 2 "Notification MAJ seulement (pas auto)"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "IsContinuousInnovationOptedIn" "DWord" 0 "Continuous innovation optout"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" "DWord" 2 "Store : telechargement auto desactive"

    Write-Host "`n=== SECURITE ===" -ForegroundColor Cyan

    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" "DWord" 5 "UAC niveau normal conserve"
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" "DWord" 1 "UAC secure desktop"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings" "PreventDeviceEncryption" "DWord" 1 "BitLocker auto bloque"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" "DWord" 0 "Compte Microsoft auth conserve"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" "BlockAADWorkplaceJoin" "DWord" 1 "Popup Azure AD bloque"

    Write-Host "`n=== INTERFACE & EXPLORER ===" -ForegroundColor Cyan

    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" "DWord" 0 "Extensions fichiers visibles"
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" "DWord" 1 "Long Paths active"

    $classicMenuPath = "HKLM:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (-not (Test-Path $classicMenuPath)) {
        New-Item -Path $classicMenuPath -Force | Out-Null
        Set-ItemProperty -Path $classicMenuPath -Name "(Default)" -Value "" -Type String -Force
        Write-Host "[OK] Menu contextuel Windows 10 active" -ForegroundColor Green
    }

    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" 1 "Recommandations Start Menu masquees"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableSearchBoxSuggestions" "DWord" 1 "Suggestions recherche Bing desactivees"
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" "AllowNewsAndInterests" "DWord" 0 "Widgets/News desactives"

    Remove-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" "(Default)" "Dossier Gallery masque du panneau nav"
    Remove-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" "(Default)" "Dossier Home masque du panneau nav"

    Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "link" "Binary" ([byte[]](0x00,0x00,0x00,0x00)) "Texte '- Raccourci' supprime"

    Write-Host "`n=== ENERGIE ===" -ForegroundColor Cyan

    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "HibernateEnabled" "DWord" 0 "Hibernation desactivee"
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" "DWord" 0 "Fast Startup desactive"
    powercfg /hibernate off 2>$null
    Write-Host "[OK] Hibernation desactivee via powercfg" -ForegroundColor Green

    Write-Host "`n=== TACHES PLANIFIEES TELEMETRIE ===" -ForegroundColor Cyan

    $tasksToDisable = @(
        "\\Microsoft\\Windows\\Application Experience\\Microsoft Compatibility Appraiser",
        "\\Microsoft\\Windows\\Application Experience\\ProgramDataUpdater",
        "\\Microsoft\\Windows\\Customer Experience Improvement Program\\Consolidator",
        "\\Microsoft\\Windows\\Customer Experience Improvement Program\\UsbCeip",
        "\\Microsoft\\Windows\\DiskDiagnostic\\Microsoft-Windows-DiskDiagnosticDataCollector",
        "\\Microsoft\\Windows\\Feedback\\Siuf\\DmClient",
        "\\Microsoft\\Windows\\Feedback\\Siuf\\DmClientOnScenarioDownload",
        "\\Microsoft\\Windows\\Windows Error Reporting\\QueueReporting",
        "\\Microsoft\\Windows\\Application Experience\\MareBackup",
        "\\Microsoft\\Windows\\Application Experience\\StartupAppTask",
        "\\Microsoft\\Windows\\Maps\\MapsToastTask",
        "\\Microsoft\\Windows\\Maps\\MapsUpdateTask",
        "\\Microsoft\\Windows\\Power Efficiency Diagnostics\\AnalyzeSystem",
        "\\Microsoft\\Windows\\Family Safety\\FamilySafetyMonitor"
    )

    foreach ($task in $tasksToDisable) {
        try {
            schtasks /Change /TN $task /Disable 2>$null | Out-Null
            Write-Host "[OK] Tache desactivee : $task" -ForegroundColor Green
        } catch {
            Write-Host "[SKIP] Tache introuvable : $task" -ForegroundColor Yellow
        }
    }

    Write-Host "`n=== SERVICES INUTILES ===" -ForegroundColor Cyan

    $servicesToDisable = @(
        @{ Name = "DiagTrack";          Start = 4; Desc = "Telemetrie DiagTrack" },
        @{ Name = "dmwappushservice";   Start = 4; Desc = "WAP Push (telemetrie)" },
        @{ Name = "WerSvc";             Start = 4; Desc = "Windows Error Reporting" },
        @{ Name = "WSearch";            Start = 3; Desc = "Windows Search (manuel)" },
        @{ Name = "Fax";                Start = 4; Desc = "Fax" },
        @{ Name = "WMPNetworkSvc";      Start = 4; Desc = "WMP Network Sharing" },
        @{ Name = "wisvc";              Start = 3; Desc = "Windows Insider" },
        @{ Name = "RetailDemo";         Start = 3; Desc = "Retail Demo" },
        @{ Name = "PhoneSvc";           Start = 3; Desc = "Phone Service" },
        @{ Name = "ScDeviceEnum";       Start = 3; Desc = "Smart Card Enum" },
        @{ Name = "SCPolicySvc";        Start = 3; Desc = "Smart Card Policy" },
        @{ Name = "SCardSvr";           Start = 3; Desc = "Smart Card" },
        @{ Name = "XblAuthManager";     Start = 3; Desc = "Xbox Auth" },
        @{ Name = "XblGameSave";        Start = 3; Desc = "Xbox Game Save" },
        @{ Name = "XboxNetApiSvc";      Start = 3; Desc = "Xbox Network" },
        @{ Name = "WpcMonSvc";          Start = 3; Desc = "Parental Controls" },
        @{ Name = "SEMgrSvc";           Start = 3; Desc = "NFC Payment" },
        @{ Name = "RasAuto";            Start = 3; Desc = "RAS AutoDial" },
        @{ Name = "MapsBroker";         Start = 3; Desc = "Maps Broker" },
        @{ Name = "SharedAccess";       Start = 3; Desc = "ICS (partage connexion)" }
    )

    foreach ($svc in $servicesToDisable) {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
        if (Test-Path $regPath) {
            Set-Reg $regPath "Start" "DWord" $svc.Start "Service $($svc.Desc)"
        } else {
            Write-Host "[SKIP] Service introuvable : $($svc.Name)" -ForegroundColor Yellow
        }
    }

    Write-Host "`n=== TERMINE ===" -ForegroundColor Green
    Write-Host "Toutes les optimisations registre ont ete appliquees." -ForegroundColor Green
    Write-Host ""
    Write-Host "  Appuyez sur une touche pour revenir au menu principal..." -ForegroundColor DarkGray
    Wait-Return
}


# ── Mise à jour depuis GitHub ─────────────────────────────────

function Update-Script {
    Write-Header "Mise a jour depuis GitHub"

    # ── CONFIGURE ICI ──────────────────────────────────────────
    $githubRawUrl = "https://raw.githubusercontent.com/Eliaas01/iso-setup/main/iso-setup.ps1"
    # ───────────────────────────────────────────────────────────

    Write-Info "URL source : $githubRawUrl"
    Write-Host ""
    Write-Step "Connexion a GitHub..."
    Write-Host ""

    try {
        $remoteContent = Invoke-WebRequest -Uri $githubRawUrl -UseBasicParsing -ErrorAction Stop

        if ($remoteContent.StatusCode -ne 200) {
            Write-Fail "Erreur HTTP : $($remoteContent.StatusCode)"
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        $remoteText = $remoteContent.Content

        $selfPath = $PSCommandPath
        if (-not $selfPath) { $selfPath = $MyInvocation.ScriptName }

        if (-not $selfPath -or -not (Test-Path $selfPath)) {
            Write-Fail "Impossible de determiner le chemin du script actuel."
            Write-Info "Lance le script avec : powershell.exe -File <chemin>"
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        Write-Success "Script local localise : $selfPath"
        Write-Host ""

        $localText   = Get-Content -LiteralPath $selfPath -Raw -Encoding UTF8
        $localLines  = ($localText  -split "`n").Count
        $remoteLines = ($remoteText -split "`n").Count

        Write-Info "Version locale   : $localLines lignes"
        Write-Info "Version distante : $remoteLines lignes"
        Write-Host ""

        if ($localText.Trim() -eq $remoteText.Trim()) {
            Write-Success "Le script est deja a jour !"
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }

        Write-Host "  Une mise a jour est disponible." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Remplacer le script actuel ? O / N / Echap : " -ForegroundColor White -NoNewline

        $confirm = Read-KeyChoice @('O','o','N','n') -AllowEscape
        if ($confirm -eq 'ESC' -or $confirm -match '^[Nn]$') {
            Write-Host $confirm
            Write-Host ""
            Write-Info "Mise a jour annulee."
            Write-Host ""
            Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
            Wait-Return
            return
        }
        Write-Host $confirm
        Write-Host ""

        $backupPath = $selfPath -replace '\\.ps1$', "_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
        Copy-Item -LiteralPath $selfPath -Destination $backupPath -Force
        Write-Info "Sauvegarde creee : $backupPath"
        Write-Host ""

        [System.IO.File]::WriteAllText($selfPath, $remoteText, [System.Text.Encoding]::UTF8)

        Write-Success "Script mis a jour avec succes !"
        Write-Host ""
        Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Le script va se relancer automatiquement..." -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 2

        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$selfPath`"" -Verb RunAs
        exit

    } catch {
        Write-Fail "Erreur lors de la mise a jour : $_"
        Write-Host ""
        Write-Host "  Verifie ta connexion internet et que le depot GitHub est accessible." -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Appuyez sur une touche pour revenir..." -ForegroundColor DarkGray
        Wait-Return
    }
}



# ── Plans d'alimentation ─────────────────────────────────────

$SUB_PROCESSOR  = "54533251-82be-4824-96c1-47b60b740d00"
$SUB_SLEEP      = "238c9fa8-0aad-41ed-83f4-97be242c8f20"
$SUB_VIDEO      = "7516b95f-f776-4464-8c53-06167f40cc99"
$SUB_DISK       = "0012ee47-9041-4b5d-9b77-535fba8b1144"
$SUB_USB        = "2a737441-1930-4402-8d77-b2bebba308a3"
$SUB_PCIE       = "501a4d13-42af-4429-9fd1-a8218c268e20"
$SUB_WIRELESS   = "19caa586-e017-445c-aa8f-a5b7a1516fab"
$SET_CPUMIN     = "893dee8e-2bef-41e0-89c6-b55d0929964c"
$SET_CPUMAX     = "bc5038f7-23e0-4960-96da-33abaf5935ec"
$SET_CPUBOOST   = "be337238-0d82-4146-a960-4f3749d470c7"
$SET_STANDBY    = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
$SET_MONITOR    = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
$SET_DISKIDLE   = "6738e2c4-e8a5-4a42-b16a-e040e769756e"
$SET_USBSUSP    = "48e6b7a6-50f5-4782-a5d4-53bb8f07e226"
$SET_PCIELINK   = "ee12f906-d277-404b-b6da-e5fa1a576df5"
$SET_WIFISAVE   = "12bbebe6-58d6-4636-95bb-3217ef867c1a"
$GUID_BALANCED  = "381b4222-f694-41f0-9685-ff5bb260df2e"
$GUID_HIGHPERF  = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
$GUID_POWERSAVE = "a1841308-3541-4fab-bc81-f71556f20b4a"

function New-PowerPlan {
    param([string]$BaseGuid, [string]$Name, [string]$Desc)
    $out  = powercfg /duplicatescheme $BaseGuid
    $guid = ($out | Select-String -Pattern '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}').Matches[0].Value
    powercfg /changename $guid $Name $Desc | Out-Null
    return $guid
}

function Set-PlanValue {
    param([string]$Guid,[string]$Sub,[string]$Set,$AC,$DC)
    if ($null -ne $AC) { powercfg /setacvalueindex $Guid $Sub $Set $AC | Out-Null }
    if ($null -ne $DC) { powercfg /setdcvalueindex $Guid $Sub $Set $DC | Out-Null }
}

function Remove-CustomPlans {
    param([string[]]$Names)
    $lines = powercfg /list
    foreach ($line in $lines) {
        foreach ($name in $Names) {
            if ($line -match [regex]::Escape($name)) {
                $g = ($line | Select-String -Pattern '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}').Matches[0].Value
                powercfg /delete $g 2>$null | Out-Null
            }
        }
    }
}

function Set-DesktopPlans {
    param([string]$Tag)
    Remove-CustomPlans @("$Tag - Turbo","$Tag - Daily","$Tag - Idle")

    $t = New-PowerPlan $GUID_HIGHPERF  "$Tag - Turbo" "Performances absolues - gaming, rendu, VM"
    Set-PlanValue $t $SUB_PROCESSOR $SET_CPUMIN   100  $null
    Set-PlanValue $t $SUB_PROCESSOR $SET_CPUMAX   100  $null
    Set-PlanValue $t $SUB_PROCESSOR $SET_CPUBOOST 2    $null
    Set-PlanValue $t $SUB_SLEEP     $SET_STANDBY  0    $null
    Set-PlanValue $t $SUB_VIDEO     $SET_MONITOR  0    $null
    Set-PlanValue $t $SUB_DISK      $SET_DISKIDLE 0    $null
    Set-PlanValue $t $SUB_USB       $SET_USBSUSP  0    $null
    Set-PlanValue $t $SUB_PCIE      $SET_PCIELINK 0    $null
    powercfg /hibernate off | Out-Null

    $d = New-PowerPlan $GUID_BALANCED  "$Tag - Daily" "Usage quotidien - web, dev, bureautique"
    Set-PlanValue $d $SUB_PROCESSOR $SET_CPUMIN   10   $null
    Set-PlanValue $d $SUB_PROCESSOR $SET_CPUMAX   100  $null
    Set-PlanValue $d $SUB_PROCESSOR $SET_CPUBOOST 1    $null
    Set-PlanValue $d $SUB_SLEEP     $SET_STANDBY  0    $null
    Set-PlanValue $d $SUB_VIDEO     $SET_MONITOR  1200 $null
    Set-PlanValue $d $SUB_DISK      $SET_DISKIDLE 1800 $null
    Set-PlanValue $d $SUB_USB       $SET_USBSUSP  1    $null
    Set-PlanValue $d $SUB_PCIE      $SET_PCIELINK 1    $null

    $i = New-PowerPlan $GUID_POWERSAVE "$Tag - Idle" "PC en fond - telechargements, serveur leger"
    Set-PlanValue $i $SUB_PROCESSOR $SET_CPUMIN   0    $null
    Set-PlanValue $i $SUB_PROCESSOR $SET_CPUMAX   60   $null
    Set-PlanValue $i $SUB_PROCESSOR $SET_CPUBOOST 0    $null
    Set-PlanValue $i $SUB_SLEEP     $SET_STANDBY  0    $null
    Set-PlanValue $i $SUB_VIDEO     $SET_MONITOR  300  $null
    Set-PlanValue $i $SUB_DISK      $SET_DISKIDLE 900  $null
    Set-PlanValue $i $SUB_USB       $SET_USBSUSP  1    $null
    Set-PlanValue $i $SUB_PCIE      $SET_PCIELINK 2    $null

    powercfg /setactive $d | Out-Null
    Write-Success "Plans alimentation crees pour $Tag  (actif par defaut : Daily)"
}

function Set-LaptopPlans {
    param([string]$Tag)
    Remove-CustomPlans @("$Tag - Perf","$Tag - Balanced","$Tag - Saver")

    $p = New-PowerPlan $GUID_HIGHPERF  "$Tag - Perf" "Performances maximales - secteur"
    Set-PlanValue $p $SUB_PROCESSOR $SET_CPUMIN   100  50
    Set-PlanValue $p $SUB_PROCESSOR $SET_CPUMAX   100  100
    Set-PlanValue $p $SUB_PROCESSOR $SET_CPUBOOST 2    2
    Set-PlanValue $p $SUB_SLEEP     $SET_STANDBY  0    0
    Set-PlanValue $p $SUB_VIDEO     $SET_MONITOR  0    0
    Set-PlanValue $p $SUB_DISK      $SET_DISKIDLE 0    0
    Set-PlanValue $p $SUB_USB       $SET_USBSUSP  0    0
    Set-PlanValue $p $SUB_PCIE      $SET_PCIELINK 0    0

    $b = New-PowerPlan $GUID_BALANCED  "$Tag - Balanced" "Usage quotidien - hybride AC/DC"
    Set-PlanValue $b $SUB_PROCESSOR $SET_CPUMIN   10   5
    Set-PlanValue $b $SUB_PROCESSOR $SET_CPUMAX   100  80
    Set-PlanValue $b $SUB_PROCESSOR $SET_CPUBOOST 1    1
    Set-PlanValue $b $SUB_SLEEP     $SET_STANDBY  1800 900
    Set-PlanValue $b $SUB_VIDEO     $SET_MONITOR  600  300
    Set-PlanValue $b $SUB_DISK      $SET_DISKIDLE 1200 600
    Set-PlanValue $b $SUB_USB       $SET_USBSUSP  1    1
    Set-PlanValue $b $SUB_PCIE      $SET_PCIELINK 1    1

    $s = New-PowerPlan $GUID_POWERSAVE "$Tag - Saver" "Autonomie maximale - batterie critique"
    Set-PlanValue $s $SUB_PROCESSOR $SET_CPUMIN   0    0
    Set-PlanValue $s $SUB_PROCESSOR $SET_CPUMAX   40   40
    Set-PlanValue $s $SUB_PROCESSOR $SET_CPUBOOST 0    0
    Set-PlanValue $s $SUB_SLEEP     $SET_STANDBY  600  600
    Set-PlanValue $s $SUB_VIDEO     $SET_MONITOR  180  180
    Set-PlanValue $s $SUB_DISK      $SET_DISKIDLE 300  300
    Set-PlanValue $s $SUB_USB       $SET_USBSUSP  1    1
    Set-PlanValue $s $SUB_PCIE      $SET_PCIELINK 2    2
    Set-PlanValue $s $SUB_WIRELESS  $SET_WIFISAVE 2    2

    powercfg /setactive $b | Out-Null
    Write-Success "Plans alimentation crees pour $Tag  (actif par defaut : Balanced)"
}

function Install-PowerPlans {
    Write-Header "Plans d'alimentation"
    Write-Host "  Quel appareil configurer ?" -ForegroundColor White
    Write-Host ""

    $valid = @()
    for ($i = 0; $i -lt $devices.Count; $i++) {
        $n = ($i + 1).ToString()
        Write-Host "  $n   $($devices[$i].name)" -ForegroundColor White
        $valid += $n
    }

    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Votre choix  1-$($devices.Count)  Echap : " -ForegroundColor White -NoNewline

    $choice = Read-KeyChoice $valid -AllowEscape
    if ($choice -eq 'ESC') { return }
    Write-Host $choice
    $device = $devices[[int]$choice - 1]

    Write-Header "Plans d'alimentation : $($device.name)"
    $laptopFolders = @("omnibook", "zephyrus")
    $isLaptop      = $laptopFolders -contains $device.folder

    Write-Host ""
    if ($isLaptop) { Write-Info "Laptop detecte  ->  Perf / Balanced / Saver" }
    else           { Write-Info "Desktop detecte ->  Turbo / Daily / Idle"    }
    Write-Host ""
    Write-Host "  Confirmer ? O / N / Echap : " -ForegroundColor White -NoNewline
    $confirm = Read-KeyChoice @('O','o','N','n') -AllowEscape
    if ($confirm -eq 'ESC' -or $confirm -match '^[Nn]$') { return }
    Write-Host $confirm
    Write-Host ""

    if ($isLaptop) { Set-LaptopPlans  -Tag $device.folder.ToUpper() }
    else           { Set-DesktopPlans -Tag $device.folder.ToUpper() }

    Write-Host ""
    Write-Host "  Plans actifs :" -ForegroundColor DarkGray
    powercfg /list | ForEach-Object { Write-Info "  $_" }
    Write-Host ""
    Write-Host "  Appuyez sur une touche pour revenir au menu principal..." -ForegroundColor DarkGray
    Wait-Return
}

# ── Menu principal ────────────────────────────────────────────

function Show-Menu {
    Write-Header "Menu principal"
    Write-Host "  1  Drivers & Plans d'alimentation  (depuis cle USB : SETUP\drvs\<appareil>)" -ForegroundColor White
    Write-Host "  2  Installer des applications     (winget / Office / MAS)"                   -ForegroundColor White
    Write-Host "  3  Rechercher une mise a jour     (GitHub)"                                   -ForegroundColor Cyan
    Write-Host "  4  Appliquer WinHancement         (optimisations registre)"                   -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Echap  Quitter" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Votre choix  1 / 2 / 3 / 4 / Echap : " -ForegroundColor White -NoNewline

    $choice = Read-KeyChoice @('1','2','3','4') -AllowEscape
    if ($choice -eq 'ESC') { return 'ESC' }
    Write-Host $choice
    return $choice
}

try {
    do {
        $choice = Show-Menu
        switch ($choice) {
            '1'   { Install-Drivers; Install-PowerPlans }
            '2'   { Install-Packages   }
            '3'   { Update-Script      }
            '4'   { Invoke-WinHancement }
            'ESC' { break }
        }
    } while ($choice -ne 'ESC')
} finally {
    Write-Host ""
    Write-Host "  [LOG] Session terminee. Log sauvegarde : $_logFile" -ForegroundColor DarkCyan
    Stop-Transcript | Out-Null
    exit
}
