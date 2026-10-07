<#
.SYNOPSIS
    Creates the skeleton of a new AZ-104 Academy lesson (and optionally its lab)
    with the front matter and section headings the validator requires.

.DESCRIPTION
    Use this when Microsoft adds an objective to the AZ-104 skills measured, or
    when a new foundation lesson is needed. It writes stubs only: every heading
    is present and every body says TODO, so Test-GuideContent.ps1 recognises the
    shape and you fill in content you have verified against Microsoft Learn.

    It never overwrites a file, and it does not edit content/manifest.json:
    it prints the manifest entry to paste, because placing a lesson in the
    study order is a decision, not a side effect.

    Lesson kinds:
      Exam        an exam lesson (domains 01-05): full lesson anatomy,
                  sub_objectives quoted verbatim from the skills measured
      Foundation  a Module 0A or 0B lesson: the shorter foundation anatomy

.PARAMETER Id
    Lesson id, for example '02-04' or '0A-14'. The first two characters pick
    the domain folder from content/manifest.json.

.PARAMETER Title
    Lesson title, in title case.

.PARAMETER Slug
    File-name slug. Defaults to the title, lowercased and hyphenated.

.PARAMETER Kind
    Exam or Foundation. Defaults to Foundation for ids starting 0A or 00,
    Exam otherwise.

.PARAMETER WithLab
    Also create labs/<folder>/<id>-lab.md with the required lab sections.

.EXAMPLE
    ./tools/New-Module.ps1 -Id '0A-14' -Title 'Containers in Plain English'

.EXAMPLE
    ./tools/New-Module.ps1 -Id '02-04' -Title 'Storage Data Movement' -WithLab
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9A-Z]{2}-\d{2}$')]
    [string] $Id,

    [Parameter(Mandatory)]
    [string] $Title,

    [string] $Slug,

    [ValidateSet('Exam', 'Foundation')]
    [string] $Kind,

    [switch] $WithLab
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$manifest = Get-Content -LiteralPath (Join-Path $root 'content/manifest.json') -Raw | ConvertFrom-Json
$domainId = $Id.Substring(0, 2)
$domain = $manifest.domains | Where-Object { $_.id -eq $domainId }
if (-not $domain) { throw "No domain '$domainId' in content/manifest.json." }
if ($domain.modules | Where-Object { $_.id -eq $Id }) { throw "Lesson $Id is already in content/manifest.json." }

if (-not $Kind) { $Kind = if ($domain.weight -eq 'n/a') { 'Foundation' } else { 'Exam' } }
if (-not $Slug) { $Slug = ($Title.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-') }

$lessonRel = "content/$($domain.folder)/$Id-$Slug.md"
$labRel    = "labs/$($domain.folder)/$Id-lab.md"
$today     = (Get-Date).ToString('yyyy-MM-dd')

# Keep these lists in step with tools/Test-GuideContent.ps1.
$examSections = @(
    'Sub-objectives covered', 'The administrative problem', 'In plain English',
    'Words you need to know', 'Mental model', 'Where it fits', 'How it works under the hood',
    'Configuration surface', 'Worked example', 'Validate the result', 'Common failure modes',
    'How this is tested', 'Hands-on', 'Check yourself', 'Teach it back', 'Key takeaways', 'Sources'
)
$foundationSections = @(
    'The problem', 'In plain English', 'Words you need to know', 'Mental model',
    'Where this shows up in AZ-104', 'Check yourself', 'Teach it back', 'Key takeaways', 'Sources'
)
$labSections = @('Why this matters', 'The desired state', 'Prerequisites', 'Part 1 - TODO',
    'Validation', 'What just happened?', 'Teardown')

$isExam = $Kind -eq 'Exam'
$objective = if ($isExam) { 'TODO: the functional group heading, verbatim from the study guide' }
             else { '(Project prerequisite - not an AZ-104 exam objective)' }

$fm = @"
---
objective: "$objective"
sub_objectives: $(if ($isExam) { "`n  - `"TODO: each skills-measured bullet, verbatim`"" } else { '[]' })
domain: "$($domain.name)"
domain_weight: "$($domain.weight)"
status: GA
prerequisites: []
ms_learn_source: "https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104"
product_docs: []
last_verified: "$today"
portal: "TODO"
powershell_module: "TODO"
az_cli_command: "TODO"
kql_tables: []
licensing: "TODO"
azure_resources: []
lab_cost_estimate: "TODO: `$0, Low, Medium or High, then what bills"
free_practice_available: true
---

# $Title

"@

$body = New-Object System.Text.StringBuilder
[void]$body.Append($fm)
[void]$body.AppendLine()
if ($isExam) {
    [void]$body.AppendLine("> **Objective:** TODO")
    [void]$body.AppendLine("> **Domain:** $($domain.name) ($($domain.weight))")
}
else {
    [void]$body.AppendLine('> **Foundation lesson.** Not an exam objective by itself: TODO, one sentence on what it prepares you for.')
}
foreach ($sec in $(if ($isExam) { $examSections } else { $foundationSections })) {
    [void]$body.AppendLine()
    [void]$body.AppendLine("## $sec")
    [void]$body.AppendLine()
    switch ($sec) {
        'Sub-objectives covered' { [void]$body.AppendLine('- TODO: each skills-measured bullet, verbatim'); [void]$body.AppendLine() }
        'Words you need to know' { [void]$body.AppendLine("| Term | In plain English |`n| --- | --- |`n| **TODO** | TODO |`n| **TODO** | TODO |`n| **TODO** | TODO |") }
        'Where it fits' {
            [void]$body.AppendLine('| Question | Answer |')
            [void]$body.AppendLine('| --- | --- |')
            foreach ($q in 'What contains it?', 'What does it depend on?', 'What depends on it?', 'Who can manage it?',
                           'How is it networked?', 'How is it monitored?', 'How is it protected?', 'How is it recovered?',
                           'What does it cost?', 'How is it removed safely?') {
                [void]$body.AppendLine("| $q | TODO |")
            }
        }
        'Hands-on' { [void]$body.AppendLine($(if ($WithLab) { "See [$Id lab](../../$labRel)." } else { 'TODO' })) }
        default { [void]$body.AppendLine('TODO') }
    }
}

$lab = New-Object System.Text.StringBuilder
[void]$lab.AppendLine("# Lab $Id - $Title")
[void]$lab.AppendLine()
[void]$lab.AppendLine("**Objective:** $objective")
[void]$lab.AppendLine('**Estimated cost:** TODO: must match the lesson''s lab_cost_estimate level')
[void]$lab.AppendLine('**Licensing required:** None beyond an Azure subscription.')
foreach ($sec in $labSections) {
    [void]$lab.AppendLine()
    [void]$lab.AppendLine("## $sec")
    [void]$lab.AppendLine()
    switch ($sec) {
        'Validation' { [void]$lab.AppendLine("TODO: observable checks.`n`n### Validation checklist`n`n- [ ] TODO") }
        'Teardown'   { [void]$lab.AppendLine("**Mandatory.** Run before closing the session.`n`n### 1. Resources`n- [ ] Confirm the context and the resource group's contents`n- [ ] Delete the lab resource group ``rg-az104-lab-$Id```n`n### 6. Verify`n- [ ] ``Get-AzResource -TagName 'az104-module' -TagValue '$Id'`` returns nothing") }
        default      { [void]$lab.AppendLine('TODO') }
    }
}

$targets = @(@{ Rel = $lessonRel; Text = $body.ToString() })
if ($WithLab) { $targets += @{ Rel = $labRel; Text = $lab.ToString() } }

foreach ($t in $targets) {
    $path = Join-Path $root $t.Rel
    if (Test-Path -LiteralPath $path) { throw "$($t.Rel) already exists. Nothing was written." }
}
foreach ($t in $targets) {
    $path = Join-Path $root $t.Rel
    if ($PSCmdlet.ShouldProcess($t.Rel, 'Create')) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path) | Out-Null
        Set-Content -LiteralPath $path -Value $t.Text -Encoding utf8NoBOM -NoNewline
        Write-Host "Created $($t.Rel)" -ForegroundColor Green
    }
}

$entry = [ordered]@{
    id        = $Id
    title     = $Title
    objective = $objective
    content   = $lessonRel
    lab       = $(if ($WithLab) { $labRel } else { $null })
}
Write-Host "`nAdd this to the '$domainId' modules in content/manifest.json, in study order:" -ForegroundColor Cyan
$entry | ConvertTo-Json
if ($isExam) {
    Write-Host "`nThen: map the bullets in data/objectives/, write quizzes/$Id.json, and run ./tools/Test-GuideContent.ps1." -ForegroundColor Cyan
}
else {
    Write-Host "`nThen run ./tools/Test-GuideContent.ps1." -ForegroundColor Cyan
}
