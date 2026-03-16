# Section 2.4: Concurrency and parallelism experiments.
# Builds all, runs A (shared counter), B (parallel reduction), C (async), saves JSON to out/.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$root = $PSScriptRoot
$out = Join-Path $root "out"
$common = Join-Path $root "common"
$env:Path = "C:\ghcup\bin;$env:USERPROFILE\.cargo\bin;$env:Path"
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }

# Run counts (methodology: A=20, B=10, C=10; reduced here for faster runs)
# Methodology: A=20 runs, B=10, C=10; use smaller values for quick test
$runsA = 5
$runsB = 4
$runsC = 4
$workersA = @(2, 4, 8)
$itersA = 200000
$nB = 20000000
$workersB = @(1, 2, 4, 8)
$tasksC = 1000
$delayC = 10

New-Item -ItemType Directory -Force -Path $out | Out-Null
$monitor = Join-Path $common "run_monitor.py"

# --- Build ---
Write-Host "Building C..."
& gcc -O2 -std=c17 -Wall -Wextra -o (Join-Path $out "counter_c.exe") (Join-Path $root "c\counter_c.c") 2>&1
& gcc -O2 -std=c17 -Wall -Wextra -o (Join-Path $out "sum_c.exe") (Join-Path $root "c\sum_c.c") 2>&1

Write-Host "Building Rust (rejected must fail)..."
& rustc (Join-Path $root "rust\rust_rejected.rs") -o (Join-Path $out "rust_rejected.exe") 2>&1 | Out-File (Join-Path $out "rust_rejected_build.txt") -Encoding utf8
& rustc -O (Join-Path $root "rust\counter_rust.rs") -o (Join-Path $out "counter_rust.exe") 2>&1
& rustc -O (Join-Path $root "rust\sum_rust.rs") -o (Join-Path $out "sum_rust.exe") 2>&1

Write-Host "Building Haskell..."
& ghc -O2 -threaded -rtsopts (Join-Path $root "haskell\counter_hs.hs") -o (Join-Path $out "counter_hs.exe") 2>&1
& ghc -O2 -threaded -rtsopts (Join-Path $root "haskell\sum_hs.hs") -o (Join-Path $out "sum_hs.exe") 2>&1

# --- Experiment A: shared counter ---
Write-Host "Experiment A: shared counter..."
$counterC = Join-Path $out "counter_c.exe"
$counterRust = Join-Path $out "counter_rust.exe"
$counterHs = Join-Path $out "counter_hs.exe"
$counterPy = Join-Path $root "python\counter_py.py"

foreach ($w in $workersA) {
    foreach ($r in 1..$runsA) {
        foreach ($variant in @("race","mutex","atomic")) {
            $tag = "c_${variant}_${w}_$itersA"
            & $py $monitor $counterC $variant $w $itersA 2>&1 | Out-File (Join-Path $out "exp_a_${tag}_run$r.json") -Encoding utf8
        }
        foreach ($variant in @("mutex","atomic")) {
            $tag = "rust_${variant}_${w}_$itersA"
            & $py $monitor $counterRust $variant $w $itersA 2>&1 | Out-File (Join-Path $out "exp_a_${tag}_run$r.json") -Encoding utf8
        }
        foreach ($variant in @("race","atomic","mvar")) {
            $tag = "hs_${variant}_${w}_$itersA"
            & $py $monitor $counterHs $variant $w $itersA "+RTS" "-N$w" 2>&1 | Out-File (Join-Path $out "exp_a_${tag}_run$r.json") -Encoding utf8
        }
        foreach ($variant in @("race","lock")) {
            $tag = "py_${variant}_${w}_$itersA"
            & $py $monitor $py $counterPy $variant $w $itersA 2>&1 | Out-File (Join-Path $out "exp_a_${tag}_run$r.json") -Encoding utf8
        }
    }
}

# --- Experiment B: parallel reduction ---
Write-Host "Experiment B: parallel reduction..."
$sumC = Join-Path $out "sum_c.exe"
$sumRust = Join-Path $out "sum_rust.exe"
$sumHs = Join-Path $out "sum_hs.exe"
$sumPy = Join-Path $root "python\sum_py.py"

foreach ($w in $workersB) {
    foreach ($run in 1..$runsB) {
        $modeC = if ($w -eq 1) { "seq" } else { "threads" }
        $tag = "c_${modeC}_${w}_$nB"
        & $py $monitor $sumC $modeC $w $nB 2>&1 | Out-File (Join-Path $out "exp_b_${tag}_run$run.json") -Encoding utf8
        $tag = "rust_${modeC}_${w}_$nB"
        & $py $monitor $sumRust $modeC $w $nB 2>&1 | Out-File (Join-Path $out "exp_b_${tag}_run$run.json") -Encoding utf8
        $modeHs = if ($w -eq 1) { "seq" } else { "par" }
        $tag = "hs_${modeHs}_${w}_$nB"
        $rts = if ($w -eq 1) { @("+RTS","-N1") } else { @("+RTS","-N$w") }
        & $py $monitor $sumHs $modeHs $w $nB @rts 2>&1 | Out-File (Join-Path $out "exp_b_${tag}_run$run.json") -Encoding utf8
        if ($w -eq 1) {
            $tag = "py_seq_1_$nB"
            & $py $monitor $py $sumPy seq 1 $nB 2>&1 | Out-File (Join-Path $out "exp_b_${tag}_run$run.json") -Encoding utf8
        } else {
            foreach ($modePy in @("threads","processes")) {
                $tag = "py_${modePy}_${w}_$nB"
                & $py $monitor $py $sumPy $modePy $w $nB 2>&1 | Out-File (Join-Path $out "exp_b_${tag}_run$run.json") -Encoding utf8
            }
        }
    }
}

# --- Experiment C: async ---
Write-Host "Experiment C: async..."
$asyncPy = Join-Path $root "python\async_py.py"
foreach ($mode in @("seq","threads","async")) {
    foreach ($run in 1..$runsC) {
        $tag = "py_${mode}_${tasksC}_${delayC}"
        & $py $monitor $py $asyncPy $mode $tasksC $delayC 2>&1 | Out-File (Join-Path $out "exp_c_${tag}_run$run.json") -Encoding utf8
    }
}

Write-Host "Building report..."
& $py (Join-Path $common "build_report.py") 2>&1
Write-Host "Done. Output in out/, report in report/report.txt"
