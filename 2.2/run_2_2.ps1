# Section 2.2: build, run via run_monitor.py, save JSON (2-3 runs per variant).
# Requires: graph.txt (same as 1.5). Copy from ../1.5 or generate there.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$root = $PSScriptRoot
$s15 = Join-Path $root "..\1.5"
$out = Join-Path $root "out"
$common = Join-Path $root "common"
$env:Path = "C:\ghcup\bin;$env:USERPROFILE\.cargo\bin;$env:Path"
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
$runs = 3

New-Item -ItemType Directory -Force -Path $out | Out-Null

# graph.txt (same as 1.5)
$graphPath = Join-Path $root "graph.txt"
if (-not (Test-Path $graphPath)) {
    $s15Graph = Join-Path $s15 "graph.txt"
    if (Test-Path $s15Graph) {
        Copy-Item $s15Graph $graphPath
        Write-Host "Copied graph.txt from 1.5"
    } else {
        Push-Location $s15
        & $py "generate_graph.py" $graphPath 2>&1 | Out-Null
        Pop-Location
        if (Test-Path $graphPath) { Write-Host "Generated graph.txt via 1.5" } else { Write-Host "WARNING: Create graph.txt (e.g. run 1.5 generate_graph.py)" }
    }
}

# Build C
Write-Host "Building C..."
& gcc -O2 (Join-Path $root "c\dijkstra_22.c") -o (Join-Path $out "dijkstra_c_22.exe") 2>&1
& gcc -O2 (Join-Path $root "c\relax_loop_22.c") -o (Join-Path $out "relax_loop_c_22.exe") 2>&1

# Build Rust
Write-Host "Building Rust..."
& rustc (Join-Path $root "rust\dijkstra_22.rs") -C opt-level=3 -o (Join-Path $out "dijkstra_rust_22.exe") 2>&1
& rustc (Join-Path $root "rust\relax_loop_22.rs") -C opt-level=3 -o (Join-Path $out "relax_loop_rust_22.exe") 2>&1

# Build Haskell
Write-Host "Building Haskell..."
& ghc -O2 -rtsopts (Join-Path $root "haskell\Dijkstra22.hs") -o (Join-Path $out "dijkstra_hs_22.exe") 2>&1
& ghc -O2 -rtsopts (Join-Path $root "haskell\RelaxLoop22.hs") -o (Join-Path $out "relax_loop_hs_22.exe") 2>&1

# Run Dijkstra (each language, $runs times)
$monitor = Join-Path $common "run_monitor.py"
$dijkstraCmds = @(
    @{ name = "dijkstra_c_22"; cmd = @((Join-Path $out "dijkstra_c_22.exe"), $graphPath) },
    @{ name = "dijkstra_rust_22"; cmd = @((Join-Path $out "dijkstra_rust_22.exe"), $graphPath) },
    @{ name = "dijkstra_hs_22"; cmd = @((Join-Path $out "dijkstra_hs_22.exe"), $graphPath, "+RTS", "-s") },
    @{ name = "dijkstra_python_22"; cmd = @($py, (Join-Path $root "python\dijkstra_22.py"), $graphPath) }
)
foreach ($d in $dijkstraCmds) {
    for ($r = 1; $r -le $runs; $r++) {
        $outJson = Join-Path $out ($d.name + "_run$r.json")
        Write-Host "Run $r : $($d.name)"
        & $py $monitor @($d.cmd) 2>&1 | Out-File -FilePath $outJson -Encoding utf8
    }
}

# Run relax_loop (each language, $runs times)
$relaxCmds = @(
    @{ name = "relax_loop_c_22"; cmd = @((Join-Path $out "relax_loop_c_22.exe")) },
    @{ name = "relax_loop_rust_22"; cmd = @((Join-Path $out "relax_loop_rust_22.exe")) },
    @{ name = "relax_loop_hs_22"; cmd = @((Join-Path $out "relax_loop_hs_22.exe"), "+RTS", "-s") },
    @{ name = "relax_loop_python_22"; cmd = @($py, (Join-Path $root "python\relax_loop_22.py")) }
)
foreach ($d in $relaxCmds) {
    for ($r = 1; $r -le $runs; $r++) {
        $outJson = Join-Path $out ($d.name + "_run$r.json")
        Write-Host "Run $r : $($d.name)"
        & $py $monitor @($d.cmd) 2>&1 | Out-File -FilePath $outJson -Encoding utf8
    }
}

# Build report from JSON logs
Write-Host "Building report..."
& $py (Join-Path $common "build_report.py") 2>&1
Write-Host "Done. JSON logs in out/, report in report/report.txt"
