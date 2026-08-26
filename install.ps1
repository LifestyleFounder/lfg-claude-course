#Requires -Version 5.1
<#
  LFG Claude Code Course - Installer (Windows)
  by Dan Harrison / Lifestyle Founders Group

  Run it with:
    irm https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main/install.ps1 | iex

  NOTE TO MAINTAINERS: this file must stay pure ASCII and be saved as UTF-8 with BOM.
  Windows PowerShell 5.1 decodes BOM-less UTF-8 as Windows-1252, which turns any
  multi-byte character into garbage. Em-dashes and arrows in particular decode into
  curly quotes, which PowerShell treats as real string delimiters -- that produces
  "The string is missing the terminator" errors that point at the wrong line.
#>

$ErrorActionPreference = 'Stop'

# PowerShell 5.1 on older Windows defaults to TLS 1.0, which GitHub refuses.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = 'https://raw.githubusercontent.com/LifestyleFounder/lfg-claude-course/main'
$ClaudeDir = Join-Path $HOME '.claude'
$LfgDir    = Join-Path $HOME '.lfg'
$Failed    = 0

function Write-Sep {
    Write-Host '==========================================================='
}

# Download a file from the repo into a destination path.
function Get-RepoFile {
    param([string]$Source, [string]$Dest)
    try {
        $parent = Split-Path -Parent $Dest
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Invoke-WebRequest -Uri "$Repo/$Source" -OutFile $Dest -UseBasicParsing
    } catch {
        $script:Failed++
        Write-Host "    could not download $Source" -ForegroundColor Red
    }
}

# Download only if the local file does not already exist (preserves user edits).
function Get-RepoFileIfMissing {
    param([string]$Source, [string]$Dest)
    if (-not (Test-Path $Dest)) {
        Get-RepoFile -Source $Source -Dest $Dest
    }
}

Write-Host ''
Write-Sep
Write-Host ''
Write-Host '   L      FFFFF   GGGG'
Write-Host '   L      F      G'
Write-Host '   L      FFF    G  GG'
Write-Host '   L      F      G   G'
Write-Host '   LLLLL  F       GGGG'
Write-Host ''
Write-Host '  CLAUDE CODE FOR COACHES'
Write-Host '  Installing...'
Write-Host ''
Write-Sep
Write-Host ''

# Create directories
Write-Host '  Creating directories...'
$dirs = @(
    (Join-Path $ClaudeDir 'commands\lfg'),
    (Join-Path $ClaudeDir 'skills\time-spent'),
    (Join-Path $ClaudeDir 'skills\call-capture\scripts'),
    (Join-Path $ClaudeDir 'skills\call-capture\config'),
    (Join-Path $ClaudeDir 'skills\call-capture\references'),
    (Join-Path $ClaudeDir 'skills\mine-calls\scripts'),
    (Join-Path $ClaudeDir 'skills\mine-calls\references'),
    (Join-Path $ClaudeDir 'skills\call-digest\scripts'),
    (Join-Path $LfgDir 'course'),
    (Join-Path $LfgDir 'gifts'),
    (Join-Path $LfgDir 'setup')
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

# Download slash commands
Write-Host '  Downloading slash commands...'
$commands = @('start','lesson-1','lesson-2','lesson-3','lesson-4','skill-builder','update','setup-call-pipeline')
foreach ($cmd in $commands) {
    Get-RepoFile "commands/lfg/${cmd}.md" (Join-Path $ClaudeDir "commands\lfg\${cmd}.md")
}

# Download time-spent skill (multi-file)
# categories.json only seeded on first install -- preserves user customizations on update
Write-Host '  Downloading time-spent skill...'
foreach ($f in @('SKILL.md','INSTALL.md','audit.py')) {
    Get-RepoFile "skills/time-spent/${f}" (Join-Path $ClaudeDir "skills\time-spent\${f}")
}
Get-RepoFileIfMissing 'skills/time-spent/categories.json' (Join-Path $ClaudeDir 'skills\time-spent\categories.json')

# Download advanced module -- call pipeline (call-capture + mine-calls + call-digest)
# Note: extraction + hook mining run in-context (no separate Anthropic API key)
Write-Host '  Downloading call-pipeline skills...'
$captureFiles = @(
    'SKILL.md',
    'scripts/__init__.py',
    'scripts/parse_vtt.py',
    'scripts/classify_keywords.py',
    'references/extraction-prompt.md'
)
foreach ($f in $captureFiles) {
    Get-RepoFile "skills/call-capture/${f}" (Join-Path $ClaudeDir "skills\call-capture\$($f -replace '/','\')")
}
Get-RepoFileIfMissing 'skills/call-capture/config/call-types.json' (Join-Path $ClaudeDir 'skills\call-capture\config\call-types.json')

# Clean up obsolete API-dependent scripts from prior installs (no-op on fresh installs)
Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $ClaudeDir 'skills\call-capture\scripts\extract.py')
Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $ClaudeDir 'skills\mine-calls\scripts\mine_call.py')

foreach ($f in @('SKILL.md','scripts/__init__.py','references/hook-prompt.md')) {
    Get-RepoFile "skills/mine-calls/${f}" (Join-Path $ClaudeDir "skills\mine-calls\$($f -replace '/','\')")
}

foreach ($f in @('SKILL.md','scripts/__init__.py','scripts/format_digest.py')) {
    Get-RepoFile "skills/call-digest/${f}" (Join-Path $ClaudeDir "skills\call-digest\$($f -replace '/','\')")
}

# Setup files for the call pipeline (Supabase schema + example config)
Write-Host '  Downloading call-pipeline setup files...'
Get-RepoFile 'setup/call-pipeline/supabase-schema.sql' (Join-Path $LfgDir 'setup\supabase-schema.sql')
Get-RepoFile 'setup/call-pipeline/example-config.json' (Join-Path $LfgDir 'setup\call-pipeline-example-config.json')

# Changelog (used by /lfg:update to show what's new)
Get-RepoFile 'CHANGELOG.md' (Join-Path $LfgDir 'CHANGELOG.md')

# Download course support files
Write-Host '  Downloading course support files...'
foreach ($f in @('fun-facts','course-guide')) {
    Get-RepoFile "course/${f}.md" (Join-Path $LfgDir "course\${f}.md")
}

# Download gift files
Write-Host '  Downloading gifts...'
$gifts = @('30-ai-prompts-for-coaches','5-agent-workflows-for-coaches','coaching-business-templates')
foreach ($f in $gifts) {
    Get-RepoFile "gifts/${f}.md" (Join-Path $LfgDir "gifts\${f}.md")
}

# Verify
$CommandCount = @(Get-ChildItem -Path (Join-Path $ClaudeDir 'commands\lfg') -Filter '*.md' -ErrorAction SilentlyContinue).Count
$TimeSpent    = @(Get-ChildItem -Path (Join-Path $ClaudeDir 'skills\time-spent\SKILL.md') -ErrorAction SilentlyContinue).Count
$CallPipeline = 0
foreach ($s in @('call-capture','mine-calls','call-digest')) {
    if (Test-Path (Join-Path $ClaudeDir "skills\${s}\SKILL.md")) { $CallPipeline++ }
}

Write-Host ''

if ($CommandCount -ge 8 -and $TimeSpent -ge 1 -and $CallPipeline -ge 3) {
    Write-Sep
    Write-Host ''
    Write-Host '  [OK] LFG Claude Code Course - INSTALLED' -ForegroundColor Green
    Write-Host ''
    Write-Host '  8 commands installed'
    Write-Host '  4 skills installed (time-spent + call-capture + mine-calls + call-digest)'
    Write-Host '  3 gift files ready'
    Write-Host '  2 course support files ready'
    Write-Host ''
    Write-Sep
    Write-Host ''
    Write-Host '  Next step:'
    Write-Host ''
    Write-Host '  1. Open Claude Code'
    Write-Host '  2. Type /lfg:start and hit enter' -ForegroundColor Yellow
    Write-Host ''
    Write-Host "  That's it. I'll walk you through everything from there."
    Write-Host ''
    Write-Host '  Available commands:'
    Write-Host '  * /lfg:start through /lfg:lesson-4 - the free 4-lesson course'
    Write-Host '  * /lfg:skill-builder - build a custom skill from a conversation'
    Write-Host '  * /lfg:update - pull future course updates'
    Write-Host '  * /time-spent - audit your time (needs ActivityWatch)'
    Write-Host ''
    Write-Host '  Advanced module (premium):'
    Write-Host '  * /lfg:setup-call-pipeline - configure the call pipeline'
    Write-Host '  * /process-calls - capture Zoom calls -> Supabase + Notion'
    Write-Host '  * /mine-calls - extract content ideas in your voice'
    Write-Host '  * /call-digest - daily digest emailed to you'
    Write-Host '    (Run /lfg:setup-call-pipeline first to wire up Zoom + Supabase + Notion.)'
    Write-Host ''
    Write-Host '  - Dan'
    Write-Host ''
} else {
    Write-Host '  [X] Something went wrong.' -ForegroundColor Red
    Write-Host "  Got: $CommandCount commands, $TimeSpent time-spent skill files, $CallPipeline call-pipeline skills."
    if ($Failed -gt 0) {
        Write-Host "  $Failed file(s) failed to download."
    }
    Write-Host '  Try running the command again, or check your internet connection.'
    Write-Host ''
}
