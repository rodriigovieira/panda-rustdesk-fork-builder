param(
  [string]$PatchUrl = "https://raw.githubusercontent.com/rodriigovieira/panda-rustdesk-fork-builder/main/patches/rustdesk/pandapdv-temporary-password-ipc.patch",
  [string]$PatchPath = "C:\panda-build\pandapdv-temporary-password-ipc.patch"
)

$ErrorActionPreference = "Stop"
$ExpectedSha256 = "ba280bd69eb23c92d6cd8a87d25ea8a6fafcfd5f9525d6775ea8dfc911b7bf47"
$ExpectedLineCount = 378

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
git apply --check --recount $PatchPath

Write-Host "Applying patch..."
git apply --recount $PatchPath

Write-Host "Patch applied successfully."
