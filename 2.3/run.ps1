# Section 2.3 experiment runner for Windows
$ErrorActionPreference = "Continue"
# Run from script directory (project root)
Set-Location $PSScriptRoot
# Ensure compilers are in PATH (ghcup, cargo/rustup)
$env:Path = "C:\ghcup\bin;$env:USERPROFILE\.cargo\bin;$env:Path"
# Use venv Python if present (so mypy and same interpreter as dev)
$venvScripts = Join-Path $PSScriptRoot "venv\Scripts"
if (Test-Path (Join-Path $venvScripts "python.exe")) {
  $env:Path = "$venvScripts;$env:Path"
}
$LOGDIR = "logs"

function Run-ToLog {
  param([string]$Exe, [string[]]$Args, [string]$LogPath)
  try {
    & $Exe @Args 2>&1 | Out-File -FilePath $LogPath -Encoding utf8
  } catch {
    "Command not found: $Exe" | Out-File -FilePath $LogPath -Encoding utf8
  }
}
New-Item -ItemType Directory -Force -Path $LOGDIR | Out-Null

$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
# Use "python -m mypy" so mypy is found when installed in current env (venv/pip) but not in PATH

Write-Host "== Section 2.3 experiment runner =="
Write-Host ""

Write-Host "== Tool versions =="
$versions = @()
if (Get-Command gcc -ErrorAction SilentlyContinue) { $versions += "[gcc]`n$(gcc --version 2>&1 | Select-Object -First 1)" }
if (Get-Command rustc -ErrorAction SilentlyContinue) { $versions += "[rustc]`n$(rustc --version 2>&1)" }
if (Get-Command ghc -ErrorAction SilentlyContinue) { $versions += "[ghc]`n$(ghc --version 2>&1)" }
if (Get-Command $py -ErrorAction SilentlyContinue) { $versions += "[python]`n$(& $py --version 2>&1)" }
try { $mypyVer = & $py -m mypy --version 2>&1; if ($LASTEXITCODE -eq 0) { $versions += "[mypy]`n$mypyVer" } } catch {}
$versions -join "`n`n" | Tee-Object -FilePath "$LOGDIR/tool_versions.txt"
Write-Host ""

Write-Host "== C: compile-time checks =="
cmd /c "gcc -std=c17 -Wall -Wextra -Wpedantic -Werror c/type_mismatch.c -o c/type_mismatch 2> $LOGDIR/c_type_mismatch.log"
cmd /c "gcc -std=c17 -Wall -Wextra -Wpedantic -Werror -Wswitch-enum c/non_exhaustive_switch.c -o c/non_exhaustive_switch 2> $LOGDIR/c_non_exhaustive_switch.log"
Write-Host "C compile logs saved."

Write-Host "== C: runtime checks with sanitizers =="
cmd /c "gcc -std=c17 -O1 -g -Wall -Wextra -Wpedantic -fsanitize=address,undefined c/null_deref.c -o c/null_deref 2> $LOGDIR/c_null_deref_build.log"
cmd /c "gcc -std=c17 -O1 -g -Wall -Wextra -Wpedantic -fsanitize=address c/use_after_free.c -o c/use_after_free 2> $LOGDIR/c_use_after_free_build.log"
if (Test-Path c/null_deref.exe -PathType Leaf) { cmd /c "c\null_deref.exe 2> $LOGDIR\c_null_deref.log > $LOGDIR\c_null_deref.out" }
elseif (Test-Path c/null_deref -PathType Leaf) { cmd /c "c\null_deref 2> $LOGDIR\c_null_deref.log > $LOGDIR\c_null_deref.out" }
if (Test-Path c/use_after_free.exe -PathType Leaf) { cmd /c "c\use_after_free.exe 2> $LOGDIR\c_use_after_free.log > $LOGDIR\c_use_after_free.out" }
elseif (Test-Path c/use_after_free -PathType Leaf) { cmd /c "c\use_after_free 2> $LOGDIR\c_use_after_free.log > $LOGDIR\c_use_after_free.out" }
Write-Host "C runtime logs saved."

Write-Host "== C: null_deref without sanitizers (raw crash / Segmentation Fault) =="
cmd /c "gcc -std=c17 -O1 -g -Wall -Wextra -Wpedantic c/null_deref.c -o c/null_deref_nosan 2> $LOGDIR/c_null_deref_nosan_build.log"
$nosanExe = if (Test-Path c/null_deref_nosan.exe -PathType Leaf) { "c\null_deref_nosan.exe" } elseif (Test-Path c/null_deref_nosan -PathType Leaf) { "c\null_deref_nosan" } else { $null }
if ($nosanExe) {
  $nosanLog = Join-Path $LOGDIR "c_null_deref_nosan.log"
  $nosanOut = Join-Path $LOGDIR "c_null_deref_nosan.out"
  & cmd /c "$nosanExe 2> `"$nosanLog`" > `"$nosanOut`""
  $exitCode = $LASTEXITCODE
  # On crash, process often writes nothing to stderr; append exit code for report
  if ($exitCode -ne 0) {
    $msg = "Process exited with code $exitCode (e.g. -1073741819 = 0xC0000005 ACCESS_VIOLATION on Windows; 139 = SIGSEGV on Linux)."
    Add-Content -Path $nosanLog -Value $msg -Encoding utf8
  }
}
Write-Host "C null_deref (no sanitize) run saved."

Write-Host "== Rust compile-time checks =="
$rustDir = Join-Path $PSScriptRoot "rust"
$rustLogs = @(
  @("type_mismatch","type_mismatch.rs","rust_type_mismatch.log"),
  @("option_mismatch","option_mismatch.rs","rust_option_mismatch.log"),
  @("use_after_move","use_after_move.rs","rust_use_after_move.log"),
  @("two_mut_borrows","two_mut_borrows.rs","rust_two_mut_borrows.log"),
  @("non_exhaustive_match","non_exhaustive_match.rs","rust_non_exhaustive_match.log")
)
foreach ($t in $rustLogs) {
  cmd /c "cd /d `"$rustDir`" && rustc -o $($t[0]) $($t[1]) 2> `"$PSScriptRoot\$LOGDIR\$($t[2])`""
}
Write-Host "Rust logs saved."

Write-Host "== Haskell compile-time checks =="
$hsDir = Join-Path $PSScriptRoot "haskell"
cmd /c "cd /d `"$hsDir`" && ghc -Wall -Werror TypeMismatch.hs -o type_mismatch 2> `"$PSScriptRoot\$LOGDIR\hs_type_mismatch.log`""
cmd /c "cd /d `"$hsDir`" && ghc -Wall -Werror MaybeMismatch.hs -o maybe_mismatch 2> `"$PSScriptRoot\$LOGDIR\hs_maybe_mismatch.log`""
cmd /c "cd /d `"$hsDir`" && ghc -Wall -Werror -Wincomplete-patterns NonExhaustive.hs -o non_exhaustive 2> `"$PSScriptRoot\$LOGDIR\hs_non_exhaustive.log`""
Write-Host "Haskell logs saved."

Write-Host "== Python runtime =="
cmd /c "$py python\type_mismatch.py 2> $LOGDIR\py_type_mismatch.log > $LOGDIR\py_type_mismatch.out"
cmd /c "$py python\none_mismatch.py 2> $LOGDIR\py_none_mismatch.log > $LOGDIR\py_none_mismatch.out"
cmd /c "$py python\non_exhaustive.py 2> $LOGDIR\py_non_exhaustive.log > $LOGDIR\py_non_exhaustive.out"
# Redact project path from Python tracebacks (no confidential paths in logs)
foreach ($log in @("py_type_mismatch.log","py_none_mismatch.log","py_non_exhaustive.log")) {
  $fp = Join-Path $LOGDIR $log
  if (Test-Path $fp) {
    (Get-Content $fp -Raw -ErrorAction SilentlyContinue) -replace [regex]::Escape($PSScriptRoot), '<project>' | Set-Content $fp -Encoding utf8 -NoNewline
  }
}
Write-Host "Python runtime logs saved."

Write-Host "== Python static analysis (mypy) =="
& $py -m mypy --strict python/type_mismatch.py 2>&1 | Out-File "$LOGDIR/mypy_type_mismatch.out" -Encoding utf8
& $py -m mypy --strict python/none_mismatch.py 2>&1 | Out-File "$LOGDIR/mypy_none_mismatch.out" -Encoding utf8
& $py -m mypy --strict python/non_exhaustive.py 2>&1 | Out-File "$LOGDIR/mypy_non_exhaustive.out" -Encoding utf8
Write-Host "mypy logs saved."

Write-Host ""
Write-Host "== Summary =="
Write-Host "Generated logs in: $LOGDIR"
$logFiles = @(
  "c_type_mismatch.log", "c_non_exhaustive_switch.log", "c_null_deref.log", "c_null_deref_nosan_build.log", "c_null_deref_nosan.log", "c_use_after_free.log",
  "rust_type_mismatch.log", "rust_option_mismatch.log", "rust_use_after_move.log", "rust_two_mut_borrows.log", "rust_non_exhaustive_match.log",
  "hs_type_mismatch.log", "hs_maybe_mismatch.log", "hs_non_exhaustive.log",
  "py_type_mismatch.log", "py_none_mismatch.log", "py_non_exhaustive.log",
  "mypy_type_mismatch.out", "mypy_none_mismatch.out", "mypy_non_exhaustive.out"
)
foreach ($f in $logFiles) {
  $p = Join-Path $LOGDIR $f
  if (Test-Path $p) {
    Write-Host "----- $f -----"
    Get-Content $p -TotalCount 8
    Write-Host ""
  }
}
Write-Host "Done."
