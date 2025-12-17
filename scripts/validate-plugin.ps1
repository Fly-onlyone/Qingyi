# Qingyi Plugin Structure Validator
# Run this script to validate the plugin structure after installation

Write-Host "`n=== Qingyi Plugin Structure Validation ===" -ForegroundColor Cyan

$errors = 0
$warnings = 0

# Test 1: Marketplace Configuration
Write-Host "`n[1/10] Checking marketplace configuration..." -ForegroundColor Yellow
if (Test-Path ".claude-plugin/marketplace.json") {
    try {
        $marketplace = Get-Content ".claude-plugin/marketplace.json" | ConvertFrom-Json
        Write-Host "  OK marketplace.json exists and is valid JSON" -ForegroundColor Green

        $pluginCount = $marketplace.plugins.Count
        Write-Host "  OK Found $pluginCount plugin(s) configured" -ForegroundColor Green

        foreach ($plugin in $marketplace.plugins) {
            Write-Host "    - $($plugin.name) v$($plugin.version)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  ERROR marketplace.json is invalid: $_" -ForegroundColor Red
        $errors++
    }
} else {
    Write-Host "  ERROR marketplace.json not found" -ForegroundColor Red
    $errors++
}

# Test 2: Main Plugin Structure
Write-Host "`n[2/10] Checking qingyi plugin structure..." -ForegroundColor Yellow
if (Test-Path "plugins/qingyi") {
    Write-Host "  OK plugins/qingyi directory exists" -ForegroundColor Green

    $requiredDirs = @("agents", "skills")
    foreach ($dir in $requiredDirs) {
        $path = "plugins/qingyi/$dir"
        if (Test-Path $path) {
            Write-Host "  OK $path exists" -ForegroundColor Green
        } else {
            Write-Host "  ERROR $path missing" -ForegroundColor Red
            $errors++
        }
    }
} else {
    Write-Host "  ERROR plugins/qingyi directory not found" -ForegroundColor Red
    $errors++
}

# Test 3: Agent Files
Write-Host "`n[3/10] Checking agent files..." -ForegroundColor Yellow
$agentFiles = Get-ChildItem "plugins/qingyi/agents/*.md" -ErrorAction SilentlyContinue
if ($agentFiles) {
    $agentCount = $agentFiles.Count
    Write-Host "  OK Found $agentCount agent file(s)" -ForegroundColor Green

    if (Test-Path "plugins/qingyi/agents/qingyi-orchestrator.md") {
        Write-Host "  OK Master orchestrator present" -ForegroundColor Green
    } else {
        Write-Host "  ERROR Master orchestrator missing" -ForegroundColor Red
        $errors++
    }

    $sampleAgents = $agentFiles | Select-Object -First 3
    foreach ($agent in $sampleAgents) {
        $content = Get-Content $agent.FullName -TotalCount 15 -Raw
        if ($content -match 'name:' -and $content -match 'description:' -and $content -match 'tools:') {
            Write-Host "  OK $($agent.Name) has valid frontmatter" -ForegroundColor Green
        } else {
            Write-Host "  WARN $($agent.Name) frontmatter may be invalid" -ForegroundColor Yellow
            $warnings++
        }
    }
} else {
    Write-Host "  ERROR No agent files found" -ForegroundColor Red
    $errors++
}

# Test 4: Skill Files
Write-Host "`n[4/10] Checking skill files..." -ForegroundColor Yellow
$skillFiles = Get-ChildItem "plugins/qingyi/skills/*/SKILL.md" -ErrorAction SilentlyContinue
if ($skillFiles) {
    $skillCount = $skillFiles.Count
    Write-Host "  OK Found $skillCount skill file(s)" -ForegroundColor Green

    $criticalSkills = @(
        "forge-registry-api",
        "neoforge-registry-api",
        "forge-event-system",
        "pattern-recognition"
    )

    foreach ($skill in $criticalSkills) {
        $path = "plugins/qingyi/skills/$skill/SKILL.md"
        if (Test-Path $path) {
            Write-Host "  OK $skill present" -ForegroundColor Green
        } else {
            Write-Host "  WARN $skill missing" -ForegroundColor Yellow
            $warnings++
        }
    }
} else {
    Write-Host "  ERROR No skill files found" -ForegroundColor Red
    $errors++
}

# Test 5: Supporting Files
Write-Host "`n[5/10] Checking supporting files (progressive loading)..." -ForegroundColor Yellow
$supportingCount = 0
$skillDirs = Get-ChildItem "plugins/qingyi/skills" -Directory -ErrorAction SilentlyContinue
foreach ($dir in $skillDirs) {
    $mdFiles = Get-ChildItem "$($dir.FullName)/*.md" -Exclude "SKILL.md" -ErrorAction SilentlyContinue
    $supportingCount += $mdFiles.Count
}

if ($supportingCount -gt 0) {
    Write-Host "  OK Found $supportingCount supporting file(s)" -ForegroundColor Green
} else {
    Write-Host "  INFO No supporting files found (optional)" -ForegroundColor Cyan
}

# Test 6: Additional Plugins
Write-Host "`n[6/10] Checking additional plugins..." -ForegroundColor Yellow

if (Test-Path "plugins/qingyi-code-review") {
    Write-Host "  OK qingyi-code-review plugin present" -ForegroundColor Green
    $reviewSkills = Get-ChildItem "plugins/qingyi-code-review/skills/*/SKILL.md" -ErrorAction SilentlyContinue
    if ($reviewSkills) {
        Write-Host "    OK Found $($reviewSkills.Count) code review skill(s)" -ForegroundColor Green
    }
} else {
    Write-Host "  INFO qingyi-code-review plugin not installed (optional)" -ForegroundColor Cyan
}

if (Test-Path "plugins/qingyi-modernizer") {
    Write-Host "  OK qingyi-modernizer plugin present" -ForegroundColor Green
    $modernSkills = Get-ChildItem "plugins/qingyi-modernizer/skills/*/SKILL.md" -ErrorAction SilentlyContinue
    if ($modernSkills) {
        Write-Host "    OK Found $($modernSkills.Count) modernizer skill(s)" -ForegroundColor Green
    }
} else {
    Write-Host "  INFO qingyi-modernizer plugin not installed (optional)" -ForegroundColor Cyan
}

# Test 7: Documentation Files
Write-Host "`n[7/10] Checking documentation..." -ForegroundColor Yellow
$docFiles = @("CLAUDE.md", "README.md", "CHANGELOG.md", "docs/ARCHITECTURE.md", "docs/AGENTS.md", "docs/SKILLS.md")
foreach ($doc in $docFiles) {
    if (Test-Path $doc) {
        Write-Host "  OK $doc exists" -ForegroundColor Green
    } else {
        Write-Host "  WARN $doc missing" -ForegroundColor Yellow
        $warnings++
    }
}

# Test 8: Markdown Link Validation
Write-Host "`n[8/10] Checking for broken markdown links..." -ForegroundColor Yellow
$mdFiles = Get-ChildItem "plugins/qingyi" -Filter "*.md" -Recurse -ErrorAction SilentlyContinue
$brokenLinks = 0

foreach ($md in ($mdFiles | Select-Object -First 10)) {
    $content = Get-Content $md.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $pattern = '\]\(\./[^\)]+\.md\)'
        $links = [regex]::Matches($content, $pattern)

        foreach ($link in $links) {
            $linkPath = $link.Value -replace '\]\(', '' -replace '\)', ''
            $fullPath = Join-Path (Split-Path $md.FullName) $linkPath
            $fullPath = [System.IO.Path]::GetFullPath($fullPath)

            if (-not (Test-Path $fullPath)) {
                Write-Host "  WARN Broken link in $($md.Name): $linkPath" -ForegroundColor Yellow
                $brokenLinks++
            }
        }
    }
}

if ($brokenLinks -eq 0) {
    Write-Host "  OK No broken links found (sampled 10 files)" -ForegroundColor Green
} else {
    Write-Host "  WARN Found $brokenLinks broken link(s)" -ForegroundColor Yellow
    $warnings += $brokenLinks
}

# Test 9: YAML Syntax Validation
Write-Host "`n[9/10] Validating YAML frontmatter syntax..." -ForegroundColor Yellow
$yamlErrors = 0

foreach ($agent in ($agentFiles | Select-Object -First 5)) {
    $content = Get-Content $agent.FullName -Raw

    $requiredFields = @("name", "description", "tools", "model")
    $missingFields = @()

    foreach ($field in $requiredFields) {
        $fieldPattern = "$field\s*:"
        if ($content -notmatch $fieldPattern) {
            $missingFields += $field
        }
    }

    if ($missingFields.Count -eq 0) {
        Write-Host "  OK $($agent.Name) YAML valid" -ForegroundColor Green
    } else {
        Write-Host "  ERROR $($agent.Name) missing fields: $($missingFields -join ', ')" -ForegroundColor Red
        $yamlErrors++
    }
}

if ($yamlErrors -gt 0) {
    $errors += $yamlErrors
}

# Test 10: File Naming Conventions
Write-Host "`n[10/10] Checking naming conventions..." -ForegroundColor Yellow
$namingIssues = 0

foreach ($agent in $agentFiles) {
    if ($agent.BaseName -cmatch '[A-Z]') {
        Write-Host "  WARN $($agent.Name) should use kebab-case" -ForegroundColor Yellow
        $namingIssues++
    }
}

$skillDirs = Get-ChildItem "plugins/qingyi/skills" -Directory -ErrorAction SilentlyContinue
foreach ($dir in $skillDirs) {
    if ($dir.Name -cmatch '[A-Z]') {
        Write-Host "  WARN $($dir.Name) should use kebab-case" -ForegroundColor Yellow
        $namingIssues++
    }
}

if ($namingIssues -eq 0) {
    Write-Host "  OK All files follow kebab-case convention" -ForegroundColor Green
} else {
    $warnings += $namingIssues
}

# Final Report
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Errors:   $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $warnings" -ForegroundColor $(if ($warnings -eq 0) { "Green" } else { "Yellow" })

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "`nSUCCESS: Plugin structure is valid! Ready for use." -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Claude Code to load the plugin"
    Write-Host "  2. Test agent invocation: 'Use the qingyi-orchestrator agent to analyze this project'"
    Write-Host "  3. Run full quality checks: See scripts/quality-check.md"
} elseif ($errors -eq 0) {
    Write-Host "`nWARNING: Plugin structure is mostly valid with minor warnings." -ForegroundColor Yellow
    Write-Host "  Review warnings above and fix if needed."
} else {
    Write-Host "`nFAILED: Plugin structure has errors. Fix them before using." -ForegroundColor Red
    Write-Host "  Review errors above and consult CLAUDE.md for guidance."
}

Write-Host ""
exit $errors
