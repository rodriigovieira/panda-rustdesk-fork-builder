param(
  [string]$PatchUrl = "https://raw.githubusercontent.com/rodriigovieira/panda-rustdesk-fork-builder/main/patches/rustdesk/pandapdv-temporary-password-ipc.patch",
  [string]$PatchPath = "C:\panda-build\pandapdv-temporary-password-ipc.patch"
)

$ErrorActionPreference = "Stop"
$ExpectedSha256 = "a362d3521eaa04440e751e669f7427e9bb7b534c1d446617bc944cbe653301b2"
$ExpectedLineCount = 366

if (-not (Test-Path ".git")) {
  throw "Run this from the RustDesk checkout root, where .git exists."
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PatchPath) | Out-Null

Write-Host "Downloading PandaPDV RustDesk patch..."
Invoke-WebRequest -Uri $PatchUrl -OutFile $PatchPath

$Hash = (Get-FileHash -Algorithm SHA256 $PatchPath).Hash.ToLowerInvariant()
if ($Hash -ne $ExpectedSha256) {
  throw "Patch SHA-256 mismatch. Expected $ExpectedSha256, got $Hash."
}

$LineCount = (Get-Content -LiteralPath $PatchPath).Count
if ($LineCount -ne $ExpectedLineCount) {
  throw "Patch line count mismatch. Expected $ExpectedLineCount, got $LineCount."
}

Write-Host "Checking patch..."
git apply --check $PatchPath

Write-Host "Applying patch..."
git apply $PatchPath

Write-Host "Refreshing Cargo.lock for the added hmac dependency..."
cargo generate-lockfile

Write-Host "Patch applied successfully."
