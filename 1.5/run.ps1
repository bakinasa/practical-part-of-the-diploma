# Section 1.5: run Dijkstra implementations, collect metrics, create report
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$env:Path = "C:\ghcup\bin;$env:USERPROFILE\.cargo\bin;$env:Path"
$LOGDIR = "logs"
$REPORT = "logs\report.txt"
$GRAPH = "graph.txt"
New-Item -ItemType Directory -Force -Path $LOGDIR | Out-Null

# Ensure graph exists (100k vertices, 500k edges); regenerate if old size
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
$needGen = -not (Test-Path $GRAPH)
if (Test-Path $GRAPH) {
    $first = Get-Content $GRAPH -TotalCount 1
    if ($first -notmatch "100000\s+500000") { $needGen = $true }
}
if ($needGen) {
    Write-Host "Generating graph (100k vertices, 500k edges)..."
    & $py generate_graph.py
    if (-not (Test-Path $GRAPH)) { Write-Error "Failed to generate graph"; exit 1 }
}
$graphPath = (Resolve-Path $GRAPH).Path

Write-Host "== Section 1.5 Dijkstra metrics =="
Write-Host ""

# Build C
Write-Host "Building C..."
$cExe = "c\dijkstra.exe"
$cBuilt = $false
cmd /c "gcc -O2 -std=c11 -o c/dijkstra.exe c/dijkstra.c 2> $LOGDIR/c_build.log"
if (Test-Path $cExe) { $cBuilt = $true; Write-Host "  C OK" } else { Write-Host "  C build failed" }

# Build Rust
Write-Host "Building Rust..."
$rustExe = "rust\dijkstra.exe"
$rustBuilt = $false
Push-Location rust
cmd /c "rustc -O -o dijkstra.exe dijkstra.rs 2> ..\$LOGDIR\rust_build.log"
Pop-Location
if (Test-Path $rustExe) { $rustBuilt = $true; Write-Host "  Rust OK" } else { Write-Host "  Rust build failed" }

# Build Haskell
Write-Host "Building Haskell..."
$hsExe = "haskell\dijkstra.exe"
$hsBuilt = $false
Push-Location haskell
cmd /c "ghc -O2 -o dijkstra.exe Dijkstra.hs 2> ..\$LOGDIR\hs_build.log"
Pop-Location
if (Test-Path $hsExe) { $hsBuilt = $true; Write-Host "  Haskell OK" } else { Write-Host "  Haskell build failed" }

# Python: no build
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
Write-Host "  Python (interpreted)"
Write-Host ""

function Get-PeakMemoryMB {
    param(
        [string]$ExePath,
        [string]$ArgString,
        [int]$SampleMs = 30  # интервал опроса, по умолчанию как раньше
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $ExePath
    $psi.Arguments = $ArgString
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $peak = 0
    while (-not $p.HasExited) {
        try {
            $p.Refresh()
            $ws = [math]::Round($p.WorkingSet64 / 1MB, 2)
            if ($ws -gt $peak) { $peak = $ws }
        } catch {}
        Start-Sleep -Milliseconds $SampleMs
    }
    # Процесс уже завершился; делаем ещё один замер WorkingSet,
    # чтобы очень короткие программы не давали искусственный ноль.
    try {
        $p.Refresh()
        $ws = [math]::Round($p.WorkingSet64 / 1MB, 2)
        if ($ws -gt $peak) { $peak = $ws }
    } catch {}
    $p.WaitForExit()
    return $peak
}

function Run-AndParseTime {
    param([string]$ExePath, [string[]]$ArgList)
    $out = & $ExePath @ArgList 2>&1
    $line = $out | Select-String "avg_time_ms:\s*([\d.]+)"
    if ($line -match "avg_time_ms:\s*([\d.]+)") { return [double]$matches[1] }
    return $null
}

$results = @{}
$memResults = @{}

# Run C
if ($cBuilt) {
    $cExePath = Join-Path $PSScriptRoot "c\dijkstra.exe"
    $t = Run-AndParseTime $cExePath @($graphPath)
    if ($null -ne $t) { $results["C"] = $t; Write-Host "C avg_time_ms: $t" }
    # Для C уменьшаем интервал опроса, чтобы поймать пик даже при очень быстром выполнении.
    $mem = Get-PeakMemoryMB $cExePath $graphPath 5
    $memResults["C"] = $mem
    Write-Host "C peak_memory_mb: $mem"
} else { $results["C"] = $null; $memResults["C"] = $null }

# Run Rust
if ($rustBuilt) {
    $rustExePath = Join-Path $PSScriptRoot "rust\dijkstra.exe"
    $t = Run-AndParseTime $rustExePath @($graphPath)
    if ($null -ne $t) { $results["Rust"] = $t; Write-Host "Rust avg_time_ms: $t" }
    $mem = Get-PeakMemoryMB $rustExePath $graphPath
    $memResults["Rust"] = $mem
    Write-Host "Rust peak_memory_mb: $mem"
} else { $results["Rust"] = $null; $memResults["Rust"] = $null }

# Run Haskell
if ($hsBuilt) {
    $hsExePath = Join-Path $PSScriptRoot "haskell\dijkstra.exe"
    $t = Run-AndParseTime $hsExePath @($graphPath)
    if ($null -ne $t) { $results["Haskell"] = $t; Write-Host "Haskell avg_time_ms: $t" }
    $mem = Get-PeakMemoryMB $hsExePath $graphPath
    $memResults["Haskell"] = $mem
    Write-Host "Haskell peak_memory_mb: $mem"
} else { $results["Haskell"] = $null; $memResults["Haskell"] = $null }

# Run Python (measure time from output; memory via same sampling)
$pyScript = Join-Path $PSScriptRoot "python\dijkstra.py"
$t = Run-AndParseTime $py @($pyScript, $graphPath)
if ($null -ne $t) { $results["Python"] = $t; Write-Host "Python avg_time_ms: $t" }
$mem = Get-PeakMemoryMB $py "$pyScript $graphPath"
$memResults["Python"] = $mem
Write-Host "Python peak_memory_mb: $mem"
Write-Host ""

# Build report
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("==============================================")
[void]$sb.AppendLine("  SECTION 1.5 DIJKSTRA METRICS REPORT")
[void]$sb.AppendLine("  Graph: 100,000 vertices, 500,000 edges. 50 runs per implementation.")
[void]$sb.AppendLine("==============================================")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Language | Time (ms) | Memory (MB) |")
[void]$sb.AppendLine("|----------|-----------|-------------|")
foreach ($lang in @("C", "Rust", "Haskell", "Python")) {
    $timeStr = if ($results[$lang] -ne $null) { [string][math]::Round($results[$lang], 2) } else { "N/A" }
    $memStr = if ($memResults[$lang] -ne $null) { [string]$memResults[$lang] } else { "N/A" }
    [void]$sb.AppendLine("| $lang | $timeStr | $memStr |")
}

$reportPath = Join-Path $PSScriptRoot $REPORT
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), $utf8)
Write-Host "Report saved: $reportPath"
