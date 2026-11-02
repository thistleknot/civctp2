[CmdletBinding()]
param(
    [switch]$NoRun,
    [switch]$ForceRun,
    [switch]$PreferRelease,
    [string]$SourceRoot = 'H:\Games\civctp2-gaia-integration\ctp2_code\ctp',

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$GameArgs
)

function Get-PeMachine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return 'missing'
    }

    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $reader = New-Object System.IO.BinaryReader($stream)
        $stream.Seek(0x3c, [System.IO.SeekOrigin]::Begin) | Out-Null
        $peOffset = $reader.ReadInt32()
        $stream.Seek($peOffset + 4, [System.IO.SeekOrigin]::Begin) | Out-Null
        $machine = $reader.ReadUInt16()
    } finally {
        $stream.Dispose()
    }

    switch ($machine) {
        0x014c { return 'x86' }
        0x8664 { return 'x64' }
        0x01c0 { return 'ARM' }
        0xaa64 { return 'ARM64' }
        default { return ('0x{0:x}' -f $machine) }
    }
}

function Resolve-LaunchSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $false)]
        [switch]$PreferRelease
    )

    $candidateOrder = if ($PreferRelease) {
        @('ctp2.exe', 'ctp2-log.exe', 'ctp2-dbg.exe')
    } else {
        @('ctp2-dbg.exe', 'ctp2-log.exe', 'ctp2.exe')
    }

    foreach ($candidate in $candidateOrder) {
        $candidatePath = Join-Path $SourceRoot $candidate
        if (Test-Path $candidatePath) {
            return [pscustomobject]@{
                SourcePath   = $candidatePath
                RelativePath = $candidate
            }
        }
    }

    return $null
}

function Test-DependencyPresence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$SourceRoot
    )

    $searchPaths = @(
        (Join-Path $Root $Name),
        (Join-Path $SourceRoot $Name),
        (Join-Path $env:WINDIR ("System32\" + $Name)),
        (Join-Path $env:WINDIR ("SysWOW64\" + $Name))
    )

    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            return $true
        }
    }

    return $false
}

function Get-PeImportNames {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $reader = New-Object System.IO.BinaryReader($stream)
        $stream.Seek(0x3c, [System.IO.SeekOrigin]::Begin) | Out-Null
        $peOffset = $reader.ReadInt32()
        $stream.Seek($peOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
        if ($reader.ReadUInt32() -ne 0x00004550) {
            throw "Invalid PE signature: $Path"
        }

        $stream.Seek($peOffset + 6, [System.IO.SeekOrigin]::Begin) | Out-Null
        $sectionCount = $reader.ReadUInt16()
        $stream.Seek($peOffset + 20, [System.IO.SeekOrigin]::Begin) | Out-Null
        $optionalHeaderSize = $reader.ReadUInt16()
        $optionalHeaderOffset = $peOffset + 24
        $stream.Seek($optionalHeaderOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
        $optionalMagic = $reader.ReadUInt16()
        $directoryOffset = switch ($optionalMagic) {
            0x010b { 96 }
            0x020b { 112 }
            default { throw "Unsupported PE optional-header format 0x$('{0:x}' -f $optionalMagic): $Path" }
        }

        $stream.Seek($optionalHeaderOffset + $directoryOffset + 8, [System.IO.SeekOrigin]::Begin) | Out-Null
        $importRva = $reader.ReadUInt32()
        if ($importRva -eq 0) {
            return @()
        }

        $sections = New-Object System.Collections.Generic.List[object]
        $sectionTableOffset = $optionalHeaderOffset + $optionalHeaderSize
        for ($index = 0; $index -lt $sectionCount; $index++) {
            $sectionOffset = $sectionTableOffset + ($index * 40)
            $stream.Seek($sectionOffset + 8, [System.IO.SeekOrigin]::Begin) | Out-Null
            $virtualSize = $reader.ReadUInt32()
            $virtualAddress = $reader.ReadUInt32()
            $rawSize = $reader.ReadUInt32()
            $rawPointer = $reader.ReadUInt32()
            $sections.Add([pscustomobject]@{
                    VirtualSize    = $virtualSize
                    VirtualAddress = $virtualAddress
                    RawSize        = $rawSize
                    RawPointer     = $rawPointer
                })
        }

        $resolveRva = {
            param([uint32]$Rva)
            foreach ($section in $sections) {
                $sectionSpan = [Math]::Max([double]$section.VirtualSize, [double]$section.RawSize)
                if ($Rva -ge $section.VirtualAddress -and $Rva -lt ($section.VirtualAddress + $sectionSpan)) {
                    return [long]$section.RawPointer + ($Rva - $section.VirtualAddress)
                }
            }
            throw "PE RVA 0x$('{0:x}' -f $Rva) is outside all sections: $Path"
        }

        $descriptorOffset = & $resolveRva $importRva
        $imports = New-Object System.Collections.Generic.List[string]
        while ($true) {
            $stream.Seek($descriptorOffset + 12, [System.IO.SeekOrigin]::Begin) | Out-Null
            $nameRva = $reader.ReadUInt32()
            if ($nameRva -eq 0) {
                break
            }

            $nameOffset = & $resolveRva $nameRva
            $stream.Seek($nameOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
            $nameBytes = New-Object System.Collections.Generic.List[byte]
            while (($byte = $reader.ReadByte()) -ne 0) {
                $nameBytes.Add($byte)
            }
            $imports.Add([System.Text.Encoding]::ASCII.GetString($nameBytes.ToArray()))
            $descriptorOffset += 20
        }

        return $imports.ToArray()
    } finally {
        $stream.Dispose()
    }
}

function Get-MissingLaunchDependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $true)]
        [string]$LaunchSourcePath
    )

    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($name in (Get-PeImportNames -Path $LaunchSourcePath)) {
        if ($name -match '^(api-ms-win-|ext-ms-win-)') {
            continue
        }
        if (-not (Test-DependencyPresence -Root $Root -Name $name -SourceRoot $SourceRoot)) {
            $missing.Add($name)
        }
    }

    return $missing
}

function Get-MissingRequiredPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Paths
    )

    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($path in $Paths) {
        if (-not (Test-Path $path)) {
            $missing.Add($path)
        }
    }

    return $missing
}

function Write-PreflightReport {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExePath,

        [Parameter(Mandatory = $true)]
        [string]$LogsDirectory,

        [Parameter(Mandatory = $true)]
        [object[]]$ScanRows
    )

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $reportPath = Join-Path $LogsDirectory ("preflight-$stamp.txt")
    $exeMachine = ($ScanRows | Where-Object { $_.Role -eq 'planned-exe' } | Select-Object -First 1).Machine
    $coreMismatches = $ScanRows | Where-Object {
        $_.Role -eq 'core-runtime' -and $_.Machine -ne 'missing' -and $_.Machine -ne $exeMachine
    }

    $lines = @(
        "Preflight result: BLOCKED",
        "Reason          : runtime architecture mismatch",
        "",
        "Planned executable:",
        ("- {0} [{1}]" -f $ExePath, $exeMachine),
        "",
        "Scanned files:"
    )

    foreach ($row in $ScanRows) {
        $lines += ("- {0} | {1} | {2}" -f $row.Role, $row.Machine, $row.Path)
    }

    $lines += @(
        "",
        "Blocking mismatches:"
    )

    foreach ($row in $coreMismatches) {
        $lines += ("- {0} is {1} but {2} is {3}" -f $row.Path, $row.Machine, $ExePath, $exeMachine)
    }

    $lines += @(
        "",
        "Likely consequence:",
        "- Windows loader error 0xc000007b before the game's own crash handler starts",
        "",
        "Next requirement:",
        "- either provide x86 SDL2/SDL2_image/SDL2_mixer beside the x86 debug exe",
        "- or provide a matching x64 ctp2-dbg.exe for the installed x64 runtime"
    )

    Set-Content -Path $reportPath -Value $lines
    return $reportPath
}

function Get-OverlaySources {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $true)]
        [string]$LaunchSourcePath,

        [Parameter(Mandatory = $true)]
        [string]$LaunchRelativePath
    )

    $sources = New-Object System.Collections.Generic.List[object]

    $sources.Add([pscustomobject]@{
            Source       = $LaunchSourcePath
            RelativePath = $LaunchRelativePath
        })

    $debugPdb = Join-Path $SourceRoot 'ctp2\Debug-SDL\ctp2-dbg.pdb'
    if ($LaunchRelativePath -eq 'ctp2-dbg.exe' -and (Test-Path $debugPdb)) {
        $sources.Add([pscustomobject]@{
                Source       = $debugPdb
                RelativePath = 'ctp2-dbg.pdb'
            })
    }

    # The in-game crash symbolizer reads the map beside the selected executable.
    # Keep release, log, and debug binaries paired with their own map so raw stack
    # addresses never resolve against symbols from a different build.
    $mapName = [System.IO.Path]::ChangeExtension($LaunchRelativePath, '.map')
    $symbolMap = Join-Path $SourceRoot $mapName
    if (Test-Path $symbolMap) {
        $sources.Add([pscustomobject]@{
                Source       = $symbolMap
                RelativePath = $mapName
            })
    }

    Get-ChildItem $SourceRoot -File -Filter '*.dll' -ErrorAction SilentlyContinue | ForEach-Object {
        $sources.Add([pscustomobject]@{
                Source       = $_.FullName
                RelativePath = $_.Name
            })
    }

    $dllRoot = Join-Path $SourceRoot 'dll'
    if (Test-Path $dllRoot) {
        Get-ChildItem $dllRoot -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $relativePath = $_.FullName.Substring($SourceRoot.Length + 1)
            $sources.Add([pscustomobject]@{
                    Source       = $_.FullName
                    RelativePath = $relativePath
                })
        }
    }

    return $sources
}

function Stage-X86RuntimeOverlay {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $true)]
        [string]$InstallRoot,

        [Parameter(Mandatory = $true)]
        [string]$LaunchSourcePath,

        [Parameter(Mandatory = $true)]
        [string]$LaunchRelativePath
    )

    $backupRoot = Join-Path $InstallRoot ("runtime-backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $manifest = New-Object System.Collections.Generic.List[object]
    $sources = Get-OverlaySources -SourceRoot $SourceRoot -LaunchSourcePath $LaunchSourcePath -LaunchRelativePath $LaunchRelativePath

    foreach ($item in $sources) {
        $destinationPath = Join-Path $InstallRoot $item.RelativePath
        $backupPath = Join-Path $backupRoot $item.RelativePath
        $destinationDir = Split-Path -Parent $destinationPath

        if (-not (Test-Path $destinationDir)) {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }

        $hadDestination = Test-Path $destinationPath
        if ($hadDestination) {
            $backupDir = Split-Path -Parent $backupPath
            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
            }
            Copy-Item $destinationPath $backupPath -Force
        }

        Copy-Item $item.Source $destinationPath -Force

        $manifest.Add([pscustomobject]@{
                Destination    = $destinationPath
                Backup         = $backupPath
                HadDestination = $hadDestination
            })
    }

    return [pscustomobject]@{
        BackupRoot = $backupRoot
        Manifest   = $manifest
    }
}

function Restore-X86RuntimeOverlay {
    param(
        [Parameter(Mandatory = $true)]
        [object]$OverlayState
    )

    foreach ($item in $OverlayState.Manifest | Sort-Object Destination -Descending) {
        if ($item.HadDestination) {
            Copy-Item $item.Backup $item.Destination -Force
        } elseif (Test-Path $item.Destination) {
            Remove-Item $item.Destination -Force
        }
    }

    if (Test-Path $OverlayState.BackupRoot) {
        Remove-Item $OverlayState.BackupRoot -Recurse -Force
    }
}

function Save-CrashTelemetry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExeName,

        [Parameter(Mandatory = $true)]
        [datetime]$StartedAt,

        [Parameter(Mandatory = $true)]
        [string]$LogsDirectory
    )

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

    $events = Get-WinEvent -FilterHashtable @{
            LogName   = 'Application'
            StartTime = $StartedAt.AddSeconds(-5)
        } -ErrorAction SilentlyContinue |
        Where-Object {
            ($_.ProviderName -eq 'Application Error' -or $_.ProviderName -eq 'Windows Error Reporting') -and
            $_.Message -match [regex]::Escape($ExeName)
        } |
        Select-Object -First 10 TimeCreated, Id, ProviderName, LevelDisplayName, Message

    if ($events) {
        $eventPath = Join-Path $LogsDirectory ("eventlog-$stamp.txt")
        $lines = foreach ($event in $events) {
            "TimeCreated: $($event.TimeCreated)"
            "Provider   : $($event.ProviderName)"
            "Event ID   : $($event.Id)"
            "Level      : $($event.LevelDisplayName)"
            "Message:"
            $event.Message
            ""
            ('-' * 80)
            ""
        }
        Set-Content -Path $eventPath -Value $lines
        Write-Host "Event log    : $eventPath"
    }

    $werReport = Get-ChildItem 'C:\ProgramData\Microsoft\Windows\WER\ReportArchive' -Directory -Filter ("AppCrash_{0}_*" -f $ExeName) -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $StartedAt.AddSeconds(-5) } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($werReport) {
        $reportPath = Join-Path $werReport.FullName 'Report.wer'
        if (Test-Path $reportPath) {
            $werCopyPath = Join-Path $LogsDirectory ("wer-$stamp.txt")
            Copy-Item $reportPath $werCopyPath -Force
            Write-Host "WER report   : $werCopyPath"
        }
    }
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsDir = Join-Path $root 'logs'
$profilePath = Join-Path $root 'userprofile.txt'
$launchSource = Resolve-LaunchSource -SourceRoot $SourceRoot -PreferRelease:$PreferRelease
$launchMode = if ($PreferRelease) { 'release-preferred' } else { 'debug-preferred' }

if (-not $launchSource) {
    throw "No launchable x86 source executable was found under $SourceRoot"
}

$missingLaunchDependencies = Get-MissingLaunchDependencies -Root $root -SourceRoot $SourceRoot -LaunchSourcePath $launchSource.SourcePath
if ($missingLaunchDependencies.Count -gt 0 -and $launchSource.RelativePath -ieq 'ctp2-dbg.exe') {
    $releaseSourcePath = Join-Path $SourceRoot 'ctp2.exe'
    if (Test-Path $releaseSourcePath) {
        Write-Warning ("Debug launch blocked by missing dependency: {0}. Falling back to ctp2.exe." -f ($missingLaunchDependencies -join ', '))
        $launchSource = [pscustomobject]@{
            SourcePath   = $releaseSourcePath
            RelativePath = 'ctp2.exe'
        }
        $launchMode = 'release-fallback'
        $missingLaunchDependencies = @()
    }
}

$exePath = Join-Path $root $launchSource.RelativePath
$exeName = Split-Path $exePath -Leaf
$sourceExeMachine = Get-PeMachine $launchSource.SourcePath

if (-not (Test-Path $exePath)) {
    Write-Warning "Installed runtime does not currently contain $exeName. The overlay will stage it from $SourceRoot."
}

if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

Set-Location $root

$startTime = Get-Date
$launchArgs = @('noassertdialogs') + @(
    $GameArgs | Where-Object {
        $_ -ne $null -and -not [string]::IsNullOrWhiteSpace([string]$_)
    }
)
$mapRuntimePaths = @(
    (Join-Path $root 'dll\map\Crater.dll'),
    (Join-Path $root 'dll\map\fault.dll'),
    (Join-Path $root 'dll\map\geometric.dll'),
    (Join-Path $root 'dll\map\plasma2.dll')
)
$requiredBaseUiPaths = @(
    (Join-Path $root '..\..\ctp2_data\default\graphics\pictures\uptg20e.tga'),
    (Join-Path $root '..\..\ctp2_data\default\graphics\pictures\uptg20e2.tga')
)
$forbiddenScenarioUiPaths = @(
    (Join-Path $root '..\..\Scenarios\mom\scen0000\default\graphics\pictures\uptg20e.tga'),
    (Join-Path $root '..\..\Scenarios\mom\scen0000\default\graphics\pictures\uptg20e2.tga')
)
$scanRows = @(
    [pscustomobject]@{ Role = 'planned-exe'; Path = $launchSource.SourcePath; Machine = $sourceExeMachine },
    [pscustomobject]@{ Role = 'release-exe'; Path = (Join-Path $root 'ctp2.exe'); Machine = (Get-PeMachine (Join-Path $root 'ctp2.exe')) },
    [pscustomobject]@{ Role = 'core-runtime'; Path = (Join-Path $root 'SDL2.dll'); Machine = (Get-PeMachine (Join-Path $root 'SDL2.dll')) },
    [pscustomobject]@{ Role = 'core-runtime'; Path = (Join-Path $root 'SDL2_image.dll'); Machine = (Get-PeMachine (Join-Path $root 'SDL2_image.dll')) },
    [pscustomobject]@{ Role = 'core-runtime'; Path = (Join-Path $root 'SDL2_mixer.dll'); Machine = (Get-PeMachine (Join-Path $root 'SDL2_mixer.dll')) },
    [pscustomobject]@{ Role = 'map-runtime'; Path = (Join-Path $root 'dll\map\Crater.dll'); Machine = (Get-PeMachine (Join-Path $root 'dll\map\Crater.dll')) },
    [pscustomobject]@{ Role = 'map-runtime'; Path = (Join-Path $root 'dll\map\fault.dll'); Machine = (Get-PeMachine (Join-Path $root 'dll\map\fault.dll')) },
    [pscustomobject]@{ Role = 'map-runtime'; Path = (Join-Path $root 'dll\map\geometric.dll'); Machine = (Get-PeMachine (Join-Path $root 'dll\map\geometric.dll')) },
    [pscustomobject]@{ Role = 'map-runtime'; Path = (Join-Path $root 'dll\map\plasma2.dll'); Machine = (Get-PeMachine (Join-Path $root 'dll\map\plasma2.dll')) },
    [pscustomobject]@{ Role = 'debug-sidecar'; Path = (Join-Path $root 'anet2d.dll'); Machine = (Get-PeMachine (Join-Path $root 'anet2d.dll')) },
    [pscustomobject]@{ Role = 'debug-sidecar'; Path = (Join-Path $root 'tiffd.dll'); Machine = (Get-PeMachine (Join-Path $root 'tiffd.dll')) },
    [pscustomobject]@{ Role = 'debug-sidecar'; Path = (Join-Path $root 'zlibwapid.dll'); Machine = (Get-PeMachine (Join-Path $root 'zlibwapid.dll')) }
)
$exeMachine = ($scanRows | Where-Object { $_.Role -eq 'planned-exe' } | Select-Object -First 1).Machine
$blockingMismatch = $scanRows | Where-Object {
    ($_.Role -eq 'core-runtime' -or $_.Role -eq 'map-runtime') -and $_.Machine -ne 'missing' -and $_.Machine -ne $exeMachine
}
$missingRequiredUi = Get-MissingRequiredPaths -Paths $requiredBaseUiPaths
$forbiddenScenarioUi = @($forbiddenScenarioUiPaths | Where-Object { Test-Path $_ })

$enableLogsLine = $null
if (Test-Path $profilePath) {
    $enableLogsLine = Select-String -Path $profilePath -Pattern '^EnableLogs=' | Select-Object -First 1
}

$enableLogsValue = $null
if ($enableLogsLine) {
    $enableLogsValue = $enableLogsLine.Line.Trim()
}

if ($enableLogsValue -and $enableLogsValue -notmatch '^(?i:EnableLogs=(Yes|True|1))$') {
    Write-Warning "EnableLogs is not enabled in $profilePath. crash.txt may not be written."
}

Write-Host "Executable : $exePath"
Write-Host "Source exe  : $($launchSource.SourcePath)"
Write-Host "Launch mode : $launchMode"
Write-Host "Working dir: $root"
Write-Host "Arguments  : $($launchArgs -join ' ')"
Write-Host "Executable arch: $exeMachine"
if ($missingLaunchDependencies.Count -gt 0) {
    Write-Warning ("Missing launch dependencies: {0}" -f ($missingLaunchDependencies -join ', '))
}
if ($missingRequiredUi.Count -gt 0) {
    Write-Warning ("Missing required base UI sheets: {0}" -f ($missingRequiredUi -join ', '))
}
if ($forbiddenScenarioUi.Count -gt 0) {
    Write-Warning ("Scenario override should not exist for shared UI sheets: {0}" -f ($forbiddenScenarioUi -join ', '))
}

$overlayState = $null
if ($blockingMismatch -and -not $ForceRun) {
    $reportPath = Write-PreflightReport -ExePath $exePath -LogsDirectory $logsDir -ScanRows $scanRows
    Write-Host "Preflight   : $reportPath"
    if ($NoRun) {
        Write-Warning "NoRun set: not staging the x86 overlay."
        return
    }

    if (-not (Test-Path $SourceRoot)) {
        Write-Warning "Blocked launch: x86 source runtime not found at $SourceRoot."
        Write-Warning "Use -ForceRun only if you want to reproduce the loader dialog anyway."
        return
    }

    Write-Host "Staging x86 runtime overlay from: $SourceRoot"
    $overlayState = Stage-X86RuntimeOverlay -SourceRoot $SourceRoot -InstallRoot $root -LaunchSourcePath $launchSource.SourcePath -LaunchRelativePath $launchSource.RelativePath
    Write-Host "Overlay mode: active (will restore original installed files after exit)"
}

if (($missingRequiredUi.Count -gt 0 -or $forbiddenScenarioUi.Count -gt 0) -and -not $ForceRun) {
    Write-Warning "Blocked launch: required progress-window UI sheet checklist failed."
    Write-Warning "Repair with: python patch_ctp2_images.py --base-only"
    return
}

# Stage the selected executable and its matching symbols even when the initial
# architecture preflight passes; otherwise the install may run a stale binary.
if (-not $overlayState -and -not $NoRun -and (Test-Path $SourceRoot)) {
    Write-Host "Staging x86 runtime overlay from: $SourceRoot"
    $overlayState = Stage-X86RuntimeOverlay -SourceRoot $SourceRoot -InstallRoot $root -LaunchSourcePath $launchSource.SourcePath -LaunchRelativePath $launchSource.RelativePath
    Write-Host "Overlay mode: active (will restore original installed files after exit)"
}

try {
    if (-not $NoRun) {
        $process = Start-Process -FilePath $exePath -ArgumentList $launchArgs -WorkingDirectory $root -PassThru
        $process.WaitForExit()
        $exitCode = $process.ExitCode
        Write-Host "Process exit code: $exitCode"
        if ($exitCode -ne 0) {
            Write-Warning "Non-zero exit code indicates the game terminated abnormally or restarted itself after the crash handler ran."
        }
        Start-Sleep -Seconds 2
    } else {
        Write-Host ("NoRun set; skipped launching {0}." -f [System.IO.Path]::GetFileName($exePath))
    }

    $recentLog = Get-ChildItem $logsDir -File -Filter 'civ3log*.txt' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $startTime.AddSeconds(-2) } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    $crashCandidates = @()
    $logsCrashPath = Join-Path $logsDir 'crash.txt'
    $rootCrashPath = Join-Path $root 'crash.txt'

    if (Test-Path $logsCrashPath) {
        $crashCandidates += Get-Item $logsCrashPath
    }

    if (Test-Path $rootCrashPath) {
        $crashCandidates += Get-Item $rootCrashPath
    }

    $recentCrash = $crashCandidates |
        Where-Object { $_.LastWriteTime -ge $startTime.AddSeconds(-2) } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($recentCrash) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $rawCrashCopy = Join-Path $logsDir ("crash-$stamp.txt")

        Copy-Item $recentCrash.FullName $rawCrashCopy -Force
        Copy-Item $recentCrash.FullName $rootCrashPath -Force

        Write-Host "Stack dump   : $rawCrashCopy"
        Write-Host "Crash alias  : $rootCrashPath"
    } else {
        Write-Host "No new crash.txt was found for this run."
    }

    if (-not $NoRun) {
        Save-CrashTelemetry -ExeName $exeName -StartedAt $startTime -LogsDirectory $logsDir
    }

    if ($recentLog) {
        Write-Host "Latest log   : $($recentLog.FullName)"
        Write-Host "----- civ3log tail -----"
        Get-Content $recentLog.FullName -Tail 80
        Write-Host "------------------------"
    } else {
        Write-Host "No recent civ3log*.txt file was found."
    }
} finally {
    if ($overlayState) {
        Restore-X86RuntimeOverlay -OverlayState $overlayState
        Write-Host "Overlay mode: restored original installed runtime files"
    }
}
