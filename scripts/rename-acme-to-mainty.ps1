[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $false)]
  [string]$Path = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,

  # Rewrites @mainty/* import/package scope to @mainty/*
  [Parameter(Mandatory = $false)]
  [string]$FromScope = "@mainty/",

  [Parameter(Mandatory = $false)]
  [string]$ToScope = "@mainty/",

  # Optional: also rewrite plain-text Mainty/mainty occurrences (docs/templates)
  [Parameter(Mandatory = $false)]
  [switch]$AlsoReplacePlainText,

  # Optional: rewrite lowercase 'mainty' whole word to 'mainty' (docs/templates)
  [Parameter(Mandatory = $false)]
  [switch]$AlsoReplaceLowercaseWord,

  # Optional: include lockfiles (pnpm-lock.yaml, yarn.lock, etc.)
  [Parameter(Mandatory = $false)]
  [switch]$IncludeLockfiles
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
  throw "Path not found: $Path"
}

$excludeDirs = @(
  "node_modules",
  ".git",
  ".next",
  ".turbo",
  ".expo",
  "dist",
  "build",
  "coverage",
  ".cache",
  ".pnpm-store"
)

$excludeDirRegex = "(^|[\\/])(" + (($excludeDirs | ForEach-Object { [regex]::Escape($_) }) -join "|") + ")([\\/])"

$excludeFileNames = @(
  "pnpm-lock.yaml",
  "yarn.lock",
  "package-lock.json",
  "bun.lockb",
  "turbo.lock"
)

$binaryExtensions = @(
  ".png", ".jpg", ".jpeg", ".gif", ".webp",
  ".ico", ".pdf", ".zip", ".7z", ".gz", ".tgz", ".rar",
  ".mp4", ".mov", ".mp3", ".wav",
  ".ttf", ".otf", ".woff", ".woff2",
  ".exe", ".dll"
)

$rootPath = (Resolve-Path -LiteralPath $Path).Path

$files = Get-ChildItem -LiteralPath $rootPath -Recurse -File -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch $excludeDirRegex } |
  Where-Object {
    if (-not $IncludeLockfiles -and ($excludeFileNames -contains $_.Name)) { return $false }
    if ($binaryExtensions -contains $_.Extension.ToLowerInvariant()) { return $false }
    return $true
  }

$changedFiles = 0
$totalReplacements = 0

foreach ($f in $files) {
  $content = $null
  try {
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
  } catch {
    continue
  }

  if ($null -eq $content) {
    continue
  }

  $newContent = $content
  $fileReplacements = 0

  if ($FromScope -and $ToScope) {
    if ($newContent.Contains($FromScope)) {
      $count = ([regex]::Matches($newContent, [regex]::Escape($FromScope))).Count
      $newContent = $newContent.Replace($FromScope, $ToScope)
      $fileReplacements += $count
    }
  }

  if ($AlsoReplacePlainText) {
    # Capitalized brand string
    $acmeCap = "Mainty"
    $maintyCap = "Mainty"
    if ($newContent -match "\b$acmeCap\b") {
      $count = ([regex]::Matches($newContent, "\b$acmeCap\b")).Count
      $newContent = [regex]::Replace($newContent, "\b$acmeCap\b", $maintyCap)
      $fileReplacements += $count
    }
  }

  if ($AlsoReplaceLowercaseWord) {
    if ($newContent -match "\bacme\b") {
      $count = ([regex]::Matches($newContent, "\bacme\b")).Count
      $newContent = [regex]::Replace($newContent, "\bacme\b", "mainty")
      $fileReplacements += $count
    }
  }

  if ($fileReplacements -gt 0 -and $newContent -ne $content) {
    if ($PSCmdlet.ShouldProcess($f.FullName, "Replace '$FromScope' -> '$ToScope' (and optional doc strings)")) {
      Set-Content -LiteralPath $f.FullName -Value $newContent -Encoding utf8
    }
    $changedFiles++
    $totalReplacements += $fileReplacements
    Write-Output ("{0} replacements in {1}" -f $fileReplacements, $f.FullName)
  }
}

Write-Host ""
Write-Host ("Changed files: {0}" -f $changedFiles)
Write-Host ("Total replacements: {0}" -f $totalReplacements)



