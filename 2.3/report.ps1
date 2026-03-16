# Report generator for Section 2.3 experiments
# Collects OS, CPU, RAM, compiler versions, flags, and all logs with comments.
Set-Location $PSScriptRoot
$LOGDIR = "logs"
$REPORT = "logs\report.txt"

$sb = [System.Text.StringBuilder]::new()

function Out-Report {
  param([string]$Text)
  [void]$sb.AppendLine($Text)
}

# --- System info ---
Out-Report "=============================================="
Out-Report "  SECTION 2.3 EXPERIMENT REPORT"
Out-Report "  Error detection in C, Rust, Haskell, Python"
Out-Report "=============================================="
Out-Report ""

Out-Report "--- SYSTEM ---"
try {
  $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
  if ($os) {
    Out-Report "OS: Windows, $($os.OSArchitecture)"
  } else {
    Out-Report "OS: $([System.Environment]::OSVersion.VersionString)"
  }
} catch {
  Out-Report "OS: $([System.Environment]::OSVersion.VersionString)"
}
Out-Report ""

Out-Report "--- CPU ---"
try {
  $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($cpu) {
    Out-Report "CPU: $($cpu.Name.Trim())"
    Out-Report "Cores: $($cpu.NumberOfCores), logical: $($cpu.NumberOfLogicalProcessors)"
  }
} catch {}
Out-Report ""

Out-Report "--- MEMORY (RAM) ---"
try {
  $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
  if ($cs) {
    $totalGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
    Out-Report "Total RAM: $totalGB GB"
  }
  $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
  if ($os) {
    $freeGB = [math]::Round($os.FreePhysicalMemory * 1KB / 1GB, 2)
    Out-Report "Free: $freeGB GB"
  }
} catch {}
Out-Report ""

Out-Report "--- COMPILERS AND VERSIONS ---"
$env:Path = "C:\ghcup\bin;$env:USERPROFILE\.cargo\bin;$env:Path"
$venvScripts = Join-Path $PSScriptRoot "venv\Scripts"
if (Test-Path (Join-Path $venvScripts "python.exe")) { $env:Path = "$venvScripts;$env:Path" }
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
foreach ($cmd in @("gcc","rustc","ghc","python")) {
  try {
    $v = & $cmd --version 2>&1 | Select-Object -First 2
    Out-Report "$cmd : $($v -join ' ')"
  } catch {
    Out-Report "$cmd : not found"
  }
}
try {
  $mypyVer = & $py -m mypy --version 2>&1
  Out-Report "mypy : $mypyVer"
} catch { Out-Report "mypy : not found" }
Out-Report ""

Out-Report "--- BUILD / OPTIMIZATION FLAGS ---"
Out-Report "C (strict): -std=c17 -Wall -Wextra -Wpedantic -Werror"
Out-Report "C (enum switch): additionally -Wswitch-enum"
Out-Report "C (sanitizers): -O1 -g -fsanitize=address,undefined for null_deref; -fsanitize=address for use_after_free"
Out-Report "C (no sanitize): -O1 -g only for null_deref_nosan to observe raw Segmentation Fault / crash"
Out-Report "Rust: rustc default flags"
Out-Report "Haskell: -Wall -Werror, -Wincomplete-patterns for exhaustive match"
Out-Report "Python: default interpreter; mypy: --strict"
Out-Report ""

Out-Report "=============================================="
Out-Report "  EXPERIMENT LOGS (with comments)"
Out-Report "=============================================="

$logDescriptions = @{
  "c_type_mismatch.log" = "C: type mismatch - char* passed instead of int. Expect compile error."
  "c_non_exhaustive_switch.log" = "C: incomplete switch on enum - no case BLUE. Expect -Wswitch-enum error."
  "c_null_deref_build.log" = "C: build null_deref with UBSan+ASan (may fail link on Windows)."
  "c_null_deref.log" = "C: run null_deref with sanitizers - NULL dereference. Expect ASan/UBSan message if linked."
  "c_null_deref_nosan_build.log" = "C: build null_deref without -fsanitize (plain gcc). Succeeds; binary will crash at runtime."
  "c_null_deref_nosan.log" = "C: run null_deref without sanitizers. Expect Segmentation Fault (or access violation on Windows)."
  "c_use_after_free_build.log" = "C: build use_after_free with ASan."
  "c_use_after_free.log" = "C: use after free. Expect heap-use-after-free."
  "rust_type_mismatch.log" = "Rust: type mismatch - &str instead of i32. Expect compile error."
  "rust_option_mismatch.log" = "Rust: Option<i32> assigned to i32. Expect compile error."
  "rust_use_after_move.log" = "Rust: use after move - borrow of moved value. Expect compile error."
  "rust_two_mut_borrows.log" = "Rust: two mutable borrows at once. Expect compile error."
  "rust_non_exhaustive_match.log" = "Rust: incomplete match on enum - no Color::Blue. Expect compile error."
  "hs_type_mismatch.log" = "Haskell: type mismatch - [Char] instead of Int. Expect compile error."
  "hs_maybe_mismatch.log" = "Haskell: Maybe passed to function expecting Int. Expect compile error."
  "hs_non_exhaustive.log" = "Haskell: incomplete pattern - no Blue. Expect -Wincomplete-patterns."
  "py_type_mismatch.log" = "Python: str passed to function expecting int. Expect runtime TypeError."
  "py_none_mismatch.log" = "Python: None passed to inc. Expect runtime TypeError."
  "py_non_exhaustive.log" = "Python: to_code returns None for BLUE - None+1. Expect runtime TypeError."
  "mypy_type_mismatch.out" = "mypy: static check type_mismatch.py. Expect argument type error."
  "mypy_none_mismatch.out" = "mypy: static check none_mismatch.py. Expect None type error."
  "mypy_non_exhaustive.out" = "mypy: static check non_exhaustive.py. Expect missing return or None."
}

$logOrder = @(
  "c_type_mismatch.log", "c_non_exhaustive_switch.log",
  "c_null_deref_build.log", "c_null_deref.log",
  "c_null_deref_nosan_build.log", "c_null_deref_nosan.log",
  "c_use_after_free_build.log", "c_use_after_free.log",
  "rust_type_mismatch.log", "rust_option_mismatch.log", "rust_use_after_move.log",
  "rust_two_mut_borrows.log", "rust_non_exhaustive_match.log",
  "hs_type_mismatch.log", "hs_maybe_mismatch.log", "hs_non_exhaustive.log",
  "py_type_mismatch.log", "py_none_mismatch.log", "py_non_exhaustive.log",
  "mypy_type_mismatch.out", "mypy_none_mismatch.out", "mypy_non_exhaustive.out"
)

foreach ($f in $logOrder) {
  $path = Join-Path $LOGDIR $f
  Out-Report ""
  Out-Report "---------- $f ----------"
  $desc = $logDescriptions[$f]
  if ($desc) { Out-Report "[Comment] $desc" }
  if (Test-Path $path) {
    $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
    if ($content) {
      # Redact paths: project root and user paths (no confidential info in report)
      $content = $content -replace [regex]::Escape($PSScriptRoot), '<project>'
      $content = $content -replace 'C:\\Users\\[^\\]+', '<project>'
      $content = $content -replace '/home/[^/]+', '<project>'
      Out-Report $content.TrimEnd()
    } else { [void]$sb.AppendLine("(empty)") }
  } else {
    [void]$sb.AppendLine("(file missing)")
  }
  Out-Report ""
}

$reportPath = Join-Path $PSScriptRoot $REPORT
$reportDir = Split-Path $reportPath -Parent
if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
# UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), $utf8NoBom)
Write-Host "Report saved: $reportPath"
