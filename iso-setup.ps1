$host.UI.RawUI.WindowTitle = "MonSetup - Installation personnalisee"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"

Clear-Host

$ignoredVK = @(8,9,13,16,17,18,19,20,33,34,35,36,37,38,39,40,45,46,91,92,93,112,113,114,115,116,117,118,119,120,121,122,123,144,145)
$lineChar   = [char]0x2550

$ESC            = [char]27
$DESTR_DEFAULT  = "${ESC}[97m"
$DESTR_SELECTED = "${ESC}[31m"
$RESET          = "${ESC}[0m"

$devices = @(
    @{ name = "ASUS ROG Zephyrus G16 2024 - RTX 4090"; folder = "Zephyrus_G16_2024"; label = "Laptop ASUS ROG Zephyrus G16 2024 (RTX 4090 / Intel Core Ultra 9)" },
    @{ name = "Desktop Elias";   folder = "Desktop_Elias";   label = "PC fixe Elias"      },
    @{ name = "Desktop Lilou";   folder = "Desktop_Lilou";   label = "PC fixe Lilou"      },
    @{ name = "Laptop Lilou HP"; folder = "Laptop_Lilou_HP"; label = "Laptop HP de Lilou" }
)

$catalog = @(
    # ── Outils ───────────────────────────────────────────────
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
    # ── Gaming ───────────────────────────────────────────────
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
    # ── Web & Cloud ──────────────────────────────────────────
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
    # ── Social ───────────────────────────────────────────────
    @{ name = "Slack";               type = "winget"; id = "SlackTechnologies.Slack";     cat = "Social" },
    @{ name = "Discord";             type = "winget"; id = "Discord.Discord";             cat = "Social" },
    @{ name = "WhatsApp";            type = "winget"; id = "WhatsApp.WhatsApp";           cat = "Social" },
    @{ name = "Thunderbird";         type = "winget"; id = "Mozilla.Thunderbird";         cat = "Social" },
    # ── Developpement ────────────────────────────────────────
    @{ name = "VS Code";             type = "winget"; id = "Microsoft.VisualStudioCode";  cat = "Developpement" },
    @{ name = "Zed";                 type = "winget"; id = "ZedIndustries.Zed";           cat = "Developpement" },
    @{ name = "Git";                 type = "winget"; id = "Git.Git";                     cat = "Developpement" },
    @{ name = "Termius";             type = "winget"; id = "Termius.Termius";             cat = "Developpement" },
    @{ name = "Framer";              type = "winget"; id = "Framer.Framer";               cat = "Developpement" },
    @{ name = "Claude";              type = "winget"; id = "Anthropic.Claude";            cat = "Developpement" },
    @{ name = "Claude Code";         type = "winget"; id = "Anthropic.ClaudeCode";        cat = "Developpement" },
    @{ name = "Perplexity";          type = "winget"; id = "Perplexity.Comet";            cat = "Developpement" },
    @{ name = "Windhawk";            type = "winget"; id = "RamenSoftware.Windhawk";      cat = "Developpement" },
    # ── Media ────────────────────────────────────────────────
    @{ name = "VLC";                 type = "winget"; id = "VideoLAN.VLC";                cat = "Media" },
    @{ name = "Plex";                type = "winget"; id = "Plex.Plex";                   cat = "Media" },
    @{ name = "Stremio";             type = "winget"; id = "Stremio.Stremio";             cat = "Media" },
    @{ name = "qBittorrent";         type = "winget"; id = "qBittorrent.qBittorrent";     cat = "Media" },
    @{ name = "TypeWhisper";         type = "url";    url = "https://github.com/TypeWhisper/typewhisper-win/releases/download/v0.7.0/TypeWhisper-win-x64-Setup.exe"; cat = "Media" },
    # ── Autres ───────────────────────────────────────────────
    @{ name = "Office 2024 Home";    type = "url";    url = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=Home2024Retail&platform=x64&language=fr-fr&version=O16GA"; cat = "Autres" },
    @{ name = "Microsoft Store";     type = "store";                                       cat = "Autres" },
    @{ name = "MAS Activation";      type = "mas";                                         cat = "Autres" },
    @{ name = "WinToys";             type = "winget"; id = "9P8LTPGCBZXD";                cat = "Autres" },
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
    Remove-Item "$env:USERPROFILE\OneDrive"            -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive"  -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKCU:\Software\Microsoft\OneDrive"    -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKLM:\Software\Microsoft\OneDrive"    -Recurse -Force -ErrorAction SilentlyContinue
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
    Write-Step "Recherche de la cle USB..."
    Write-Host ""

    $driversRoot = $null
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -ne 'C:\' -and $_.Root -ne '' }
    foreach ($drive in $drives) {
        $candidate = Join-Path $drive.Root 'Drivers'
        if (Test-Path $candidate) { $driversRoot = $candidate; break }
    }

    if (-not $driversRoot) {
        Write-Fail 'Dossier Drivers introuvable sur une cle USB.'
        Write-Info 'Assurez-vous que la cle USB contient un dossier Drivers a la racine.'
        Wait-Return; return
    }

    $driversPath = Join-Path $driversRoot $device.folder
    if (-not (Test-Path $driversPath)) {
        Write-Fail "Dossier introuvable : $driversPath"
        Write-Info "Verifiez que '$($device.folder)' existe dans Drivers\ sur la cle USB."
        Wait-Return; return
    }

    Write-Success "Dossier trouve : $driversPath"
    Write-Host ""
    $infFiles = Get-ChildItem -Path $driversPath -Filter '*.inf' -Recurse -ErrorAction SilentlyContinue
    Write-Info "Fichiers .inf detectes : $($infFiles.Count)"
    Write-Host ""

    if ($infFiles.Count -eq 0) { Write-Fail 'Aucun fichier .inf trouve.'; Wait-Return; return }

    Write-Step 'Installation via pnputil...'
    Write-Host ""
    $result = pnputil.exe /add-driver "$driversPath\*.inf" /subdirs /install 2>&1
    foreach ($line in $result) {
        if ($line -match 'Install|Ajout')          { Write-Success $line }
        elseif ($line -match 'Failed|Echec|Error') { Write-Fail $line    }
        elseif ($line.Trim() -ne '')               { Write-Info $line    }
    }

    Write-Host ""
    Write-Success "Installation terminee pour : $($device.name)"
    Write-Host ""
    Write-Host "  Appuyez sur une touche pour revenir au menu principal..." -ForegroundColor DarkGray
    Wait-Return
}

# ── Menu principal ────────────────────────────────────────────

function Show-Menu {
    Write-Header 'Menu principal'
    Write-Host '  1  Installer les drivers          (depuis cle USB)'        -ForegroundColor White
    Write-Host '  2  Installer des applications     (winget / Office / MAS)' -ForegroundColor White
    Write-Host '  Echap  Quitter' -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  $(Get-FullLine)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host '  Votre choix  1 / 2 / Echap : ' -ForegroundColor White -NoNewline

    $choice = Read-KeyChoice @('1','2') -AllowEscape
    if ($choice -eq 'ESC') { return 'ESC' }
    Write-Host $choice
    return $choice
}

do {
    $choice = Show-Menu
    switch ($choice) {
        '1'   { Install-Drivers  }
        '2'   { Install-Packages }
        'ESC' { exit }
    }
} while ($true)