#Requires -Version 7.0
<#
.SYNOPSIS
    Validates the Academy: structure, front matter, sections, links, quizzes,
    the objectives data, and the engine's exam-neutrality rules.

.DESCRIPTION
    Replaces the original scaffold validator and closes the eight gaps logged in
    docs/CONTRIBUTING.md:

      1.  required sections in content files are now checked
      2.  lab files are schema-checked, not only for '## Teardown'
      3.  sub_objectives are diffed against docs/SKILLS-MEASURED-SNAPSHOT.md
      4.  quiz files are validated - JSON, verbatim sub_skill, answer ranges
      5.  manifest appendix paths are checked
      6.  paths are cross-platform (was Windows-only)
      7.  every module is checked for a lab and a quiz
      8.  orphan check - files on disk that no manifest entry references

    Also added: front matter vs body sub-objective list drift, and cost-level
    parity between a module's front matter and its lab header - both of which
    caught real defects when this was written.

.PARAMETER Root
    Repository root. Defaults to the parent of the folder holding this script.

.PARAMETER CheckExternalLinks
    Also HEAD every learn.microsoft.com URL. Slow; run weekly, not per commit.

.PARAMETER StaleDays
    Warn when last_verified is older than this. Default 60.

.PARAMETER FailOn
    Error (default) or Warning. Controls the exit code, not the output.

.EXAMPLE
    .\tools\Test-GuideContent.ps1
.EXAMPLE
    .\tools\Test-GuideContent.ps1 -CheckExternalLinks -FailOn Warning
#>
[CmdletBinding()]
param(
    [string] $Root,
    [switch] $CheckExternalLinks,
    [int]    $StaleDays = 60,
    [ValidateSet('Error', 'Warning')]
    [string] $FailOn = 'Error'
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- setup ----

if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
$Root = (Resolve-Path -LiteralPath $Root).Path

$script:Issues = [System.Collections.Generic.List[pscustomobject]]::new()

function Add-Issue {
    param(
        [ValidateSet('Error', 'Warning', 'Info')] [string] $Severity,
        [string] $File,
        [string] $Message
    )
    $script:Issues.Add([pscustomobject]@{
        Severity = $Severity
        File     = $File
        Message  = $Message
    })
}

# Always compare and display paths with forward slashes, whatever the OS.
function ConvertTo-RelPath {
    param([string] $Path)
    $full = [System.IO.Path]::GetFullPath($Path)
    $rel  = $full.Substring($Root.Length).TrimStart([char]'\', [char]'/')
    return $rel -replace '\\', '/'
}

function Join-RepoPath {
    param([string] $Relative)
    return [System.IO.Path]::GetFullPath(
        (Join-Path $Root ($Relative -replace '/', [System.IO.Path]::DirectorySeparatorChar)))
}

# ------------------------------------------------------- front matter ------

<#
    Deliberately small YAML reader. It implements exactly the subset the guide's
    schema uses, and mirrors assets/js/frontmatter.js. If one grows, grow both.
#>
function Read-FrontMatter {
    param([string] $Text)

    $m = [regex]::Match($Text, '(?s)^\uFEFF?---\r?\n(.*?)\r?\n---\r?\n')
    if (-not $m.Success) { return $null }

    $data = [ordered]@{}
    $key  = $null

    foreach ($line in ($m.Groups[1].Value -split "`r?`n")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^\s*#') { continue }

        if ($line -match '^\s+-\s+(.*)$' -and $key) {
            if ($data[$key] -isnot [System.Collections.IList]) { $data[$key] = @() }
            $data[$key] += ($Matches[1].Trim() -replace '^"|"$', '')
            continue
        }

        if ($line -match '^([A-Za-z0-9_-]+)\s*:\s*(.*)$') {
            $key = $Matches[1]
            $raw = $Matches[2].Trim()
            if ($raw -eq '') {
                $data[$key] = @()
            }
            elseif ($raw.StartsWith('[')) {
                $inner = $raw.Trim('[', ']').Trim()
                $data[$key] = if ($inner) {
                    @($inner -split ',' | ForEach-Object { $_.Trim().Trim('"', "'") })
                } else { @() }
            }
            else {
                $data[$key] = $raw -replace '^"|"$', ''
            }
        }
    }

    return [pscustomobject]@{
        Data = $data
        Body = $Text.Substring($m.Length)
    }
}

function Get-Body {
    param([string] $Text)
    $fm = Read-FrontMatter $Text
    if ($fm) { return $fm.Body }
    return $Text
}

# Normalise whitespace so a wrapped bullet compares equal to a single line.
function ConvertTo-Norm {
    param([string] $Value)
    return ([regex]::Replace(($Value ?? ''), '\s+', ' ')).Trim().Trim('"')
}

# ------------------------------------------------------------ schema -------

$RequiredKeys = @(
    'objective', 'sub_objectives', 'domain', 'domain_weight', 'status',
    'prerequisites', 'ms_learn_source', 'product_docs', 'last_verified',
    'portal', 'powershell_module', 'az_cli_command', 'kql_tables', 'licensing',
    'azure_resources', 'lab_cost_estimate', 'free_practice_available'
)
# The AZ-104 weight bands, plus n/a for the foundation modules (0A and 0B).
$ValidWeights = @('10-15%', '15-20%', '20-25%', 'n/a')
$ValidStatus  = @('GA', 'Preview')

# The exam-lesson anatomy (docs/STYLE-GUIDE.md): problem and plain English
# before terminology, relationships before configuration, validation before
# troubleshooting, and teach-back before review.
$ContentSections = @(
    '## Sub-objectives covered', '## The administrative problem',
    '## In plain English', '## Words you need to know', '## Mental model',
    '## Where it fits', '## How it works under the hood',
    '## Configuration surface', '## Worked example', '## Validate the result',
    '## Common failure modes', '## How this is tested', '## Hands-on',
    '## Check yourself', '## Teach it back', '## Key takeaways', '## Sources'
)
# Foundation lessons (Modules 0A and 0B): concise, skippable, beginner-first.
$FoundationSections = @(
    '## The problem', '## In plain English', '## Words you need to know',
    '## Mental model', '## Where this shows up in AZ-104', '## Check yourself',
    '## Teach it back', '## Key takeaways', '## Sources'
)
$LabSections = @(
    '## Why this matters', '## The desired state', '## Prerequisites',
    '## Validation', '## What just happened?', '## Teardown'
)
# Module ids: two characters (digits, or 0A for the foundations), dash, two digits.
$ModIdPattern = '^([0-9A-Z]{2}-\d{2})'

# Mirrors AcademyFrontMatter.costLevel in assets/js/frontmatter.js: read the
# LEADING token, because estimates routinely say "back to Free in teardown"
# later in the sentence and that must not downgrade a paid lab to $0.
function Get-CostLevel {
    param([string] $Estimate)
    $s = ($Estimate ?? '').ToLowerInvariant()
    if (-not $s) { return 'low' }
    $head = ($s -split '\s[-\u2013\u2014]\s|\.\s')[0]
    if ($head.Length -gt 40) { $head = $head.Substring(0, 40) }
    foreach ($pair in @(@('highest', 'max'), @('high', 'high'), @('medium', 'mid'), @('low', 'low'))) {
        if ($head.Contains($pair[0])) { return $pair[1] }
    }
    if ($head.Contains('$0') -or $head.Contains('free')) { return 'none' }
    foreach ($pair in @(@('highest', 'max'), @('high', 'high'), @('medium', 'mid'), @('low', 'low'))) {
        if ($s.Contains($pair[0])) { return $pair[1] }
    }
    if ($s.Contains('$0')) { return 'none' }
    return 'low'
}

# ---------------------------------------------------------- 1. manifest ----

$manifestPath = Join-RepoPath 'content/manifest.json'
$manifest = $null
$referenced = [System.Collections.Generic.HashSet[string]]::new()

if (-not (Test-Path -LiteralPath $manifestPath)) {
    Add-Issue Error 'content/manifest.json' 'Manifest not found - structure checks skipped.'
}
else {
    try { $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json }
    catch { Add-Issue Error 'content/manifest.json' "Invalid JSON: $($_.Exception.Message)" }
}

$modules = @()

if ($manifest) {
    foreach ($domain in $manifest.domains) {
        foreach ($mod in $domain.modules) {
            $modules += [pscustomobject]@{
                Id      = $mod.id
                Title   = $mod.title
                Weight  = $domain.weight
                Domain  = $domain
                Content = $mod.content
                Lab     = $mod.lab
            }

            foreach ($p in @($mod.content, $mod.lab)) {
                if (-not $p) { continue }
                [void]$referenced.Add(($p -replace '\\', '/'))
                if (-not (Test-Path -LiteralPath (Join-RepoPath $p))) {
                    Add-Issue Error 'content/manifest.json' "$($mod.id): file not found -> $p"
                }
            }
            if (-not $mod.lab -and $domain.weight -ne 'n/a') {
                Add-Issue Warning 'content/manifest.json' "$($mod.id): no lab declared."
            }
        }
    }

    # Gap 5: the original loop never walked the appendix array, which the site
    # navigation now depends on.
    foreach ($apx in $manifest.appendix) {
        if (-not $apx.content) {
            Add-Issue Error 'content/manifest.json' "Appendix entry '$($apx.title)' has no content path."
            continue
        }
        [void]$referenced.Add(($apx.content -replace '\\', '/'))
        if (-not (Test-Path -LiteralPath (Join-RepoPath $apx.content))) {
            Add-Issue Error 'content/manifest.json' "Appendix file not found -> $($apx.content)"
        }
    }
}

# --------------------------------------------------- collect the files -----

$contentDir = Join-RepoPath 'content'
$labsDir    = Join-RepoPath 'labs'

$contentFiles = @()
$labFiles     = @()
if (Test-Path -LiteralPath $contentDir) {
    $contentFiles = Get-ChildItem -LiteralPath $contentDir -Recurse -Filter *.md -File | Sort-Object FullName
}
if (Test-Path -LiteralPath $labsDir) {
    $labFiles = Get-ChildItem -LiteralPath $labsDir -Recurse -Filter *.md -File | Sort-Object FullName
}

# Gap 8: files on disk that no manifest entry references are unreachable pages.
if ($manifest) {
    foreach ($f in @($contentFiles + $labFiles)) {
        $rel = ConvertTo-RelPath $f.FullName
        if (-not $referenced.Contains($rel)) {
            Add-Issue Warning $rel 'Orphan: on disk but not referenced by content/manifest.json.'
        }
    }
}

# -------------------------------------------- 2/3. front matter, sections --

$allSubObjectives = [System.Collections.Generic.List[string]]::new()
$subOwner         = @{}
$moduleCost       = @{}

foreach ($f in $contentFiles) {
    $rel  = ConvertTo-RelPath $f.FullName
    $text = Get-Content -LiteralPath $f.FullName -Raw
    $fm   = Read-FrontMatter $text

    if (-not $fm) { Add-Issue Error $rel 'No YAML front matter.'; continue }

    $d = $fm.Data
    foreach ($k in $RequiredKeys) {
        if (-not $d.Contains($k)) { Add-Issue Error $rel "Missing front-matter key: $k" }
    }

    if ($d.domain_weight -notin $ValidWeights) {
        Add-Issue Error $rel "domain_weight invalid: '$($d.domain_weight)'"
    }
    if ($d.status -notin $ValidStatus) {
        Add-Issue Error $rel "status invalid: '$($d.status)' (expected GA or Preview)"
    }

    if ("$($d.last_verified)" -notmatch '^\d{4}-\d{2}-\d{2}$') {
        Add-Issue Error $rel "last_verified malformed: '$($d.last_verified)'"
    }
    else {
        $age = (New-TimeSpan -Start ([datetime]$d.last_verified) -End (Get-Date)).Days
        if ($age -gt $StaleDays) {
            Add-Issue Warning $rel "last_verified is $age days old - re-check the product docs."
        }
    }

    $isAppendix = $rel -like 'content/appendix/*'

    if ($isAppendix) {
        if ($fm.Body -notmatch '(?m)^## Sources\s*$') {
            Add-Issue Warning $rel 'Appendix has no Sources block.'
        }
        continue
    }

    $subs = @($d.sub_objectives)
    $isExamModule = $d.domain_weight -ne 'n/a'

    # Gap 1: required sections were never checked.
    # The exam-lesson skeleton applies to exam modules only. Modules 0A
    # (Understanding Azure) and 0B (Safe Lab Foundations) are foundation lessons:
    # concise, skippable and held to the shorter foundation anatomy below.
    if ($isExamModule) {
        foreach ($sec in $ContentSections) {
            if ($fm.Body -notmatch ('(?m)^' + [regex]::Escape($sec) + '\s*$')) {
                Add-Issue Error $rel "Missing required section: $sec"
            }
        }
        # The words table feeds the glossary view: two columns, at least 3 terms.
        $words = [regex]::Match($fm.Body, '(?s)## Words you need to know\s*(.*?)(\r?\n## |\z)')
        $rows = @($words.Groups[1].Value -split "`r?`n" | Where-Object { $_ -match '^\|' -and $_ -notmatch '^\|\s*-' })
        if ($rows.Count -lt 4) { Add-Issue Error $rel 'Words you need to know: expected a table with at least 3 terms.' }
        # Where it fits answers the ten relationship questions in a table.
        $fits = [regex]::Match($fm.Body, '(?s)## Where it fits\s*(.*?)(\r?\n## |\z)')
        $fitRows = @($fits.Groups[1].Value -split "`r?`n" | Where-Object { $_ -match '^\|' -and $_ -notmatch '^\|\s*-' })
        if ($fitRows.Count -lt 11) { Add-Issue Error $rel "Where it fits: expected the ten-question table (found $([Math]::Max(0, $fitRows.Count - 1)) rows)." }
    }
    elseif ($rel -like 'content/0A-*' -or $rel -like 'content/00-*') {
        foreach ($sec in $FoundationSections) {
            if ($fm.Body -notmatch ('(?m)^' + [regex]::Escape($sec) + '\s*$')) {
                Add-Issue Error $rel "Missing required foundation section: $sec"
            }
        }
    }
    if ($isExamModule -and $subs.Count -eq 0) {
        Add-Issue Error $rel 'sub_objectives is empty on an exam module.'
    }

    $modId = if ($f.BaseName -match $ModIdPattern) { $Matches[1] } else { $null }
    if ($modId) { $moduleCost[$modId] = Get-CostLevel $d.lab_cost_estimate }

    foreach ($s in $subs) {
        $n = ConvertTo-Norm $s
        # A foundation lesson may list an exam bullet it also prepares for.
        # Only a bullet claimed by two EXAM modules is ambiguous ownership.
        if (-not $isExamModule) { $allSubObjectives.Add($n); continue }
        if ($subOwner.ContainsKey($n)) {
            Add-Issue Error $rel "Sub-objective also claimed by $($subOwner[$n]): $($n.Substring(0, [Math]::Min(70, $n.Length)))..."
        }
        else { $subOwner[$n] = $modId }
        $allSubObjectives.Add($n)
    }

    # Front matter and the visible list must agree - this caught a real drift.
    $vis = [regex]::Match($fm.Body, '(?s)## Sub-objectives covered\s*\r?\n\r?\n(.*?)\r?\n\r?\n')
    if ($vis.Success -and $subs.Count -gt 0) {
        $listed = @($vis.Groups[1].Value -split "`r?`n" |
            Where-Object { $_.StartsWith('- ') } |
            ForEach-Object { ConvertTo-Norm $_.Substring(2) })
        $fmNorm = @($subs | ForEach-Object { ConvertTo-Norm $_ })
        $diff = Compare-Object -ReferenceObject $fmNorm -DifferenceObject $listed
        if ($diff) {
            Add-Issue Error $rel 'sub_objectives front matter does not match the "## Sub-objectives covered" list.'
        }
    }
}

# Gap 2: labs were only checked for '## Teardown'.
foreach ($f in $labFiles) {
    $rel  = ConvertTo-RelPath $f.FullName
    $body = Get-Content -LiteralPath $f.FullName -Raw

    foreach ($sec in $LabSections) {
        if ($body -notmatch ('(?m)^' + [regex]::Escape($sec) + '\s*$')) {
            Add-Issue Error $rel "Missing required section: $sec"
        }
    }
    if ($body -notmatch '(?m)^## Part 1') {
        Add-Issue Warning $rel 'No "## Part 1" - labs are expected to be structured in numbered parts.'
    }

    # Completion means observed results, not clicked steps: the Validation and
    # Teardown sections must each carry a checklist the learner ticks.
    foreach ($sec in @('Validation', 'Teardown')) {
        $m = [regex]::Match($body, '(?s)(?m)^## ' + $sec + '\s*$(.*?)(?=^## |\z)')
        if ($m.Success -and $m.Groups[1].Value -notmatch '(?m)^\s*- \[ \] ') {
            Add-Issue Error $rel "## $sec has no checklist (- [ ] items): the lab can't record validation or teardown."
        }
    }

    # Cost parity: the module's chip and the lab header must agree.
    $modId = if ($f.BaseName -match $ModIdPattern) { $Matches[1] } else { $null }
    if ($modId -and $moduleCost.ContainsKey($modId)) {
        $hdr = [regex]::Match($body, '\*\*Estimated cost:\*\*(.*)')
        if (-not $hdr.Success) {
            Add-Issue Warning $rel 'Lab header has no "**Estimated cost:**" line.'
        }
        else {
            $labLevel = Get-CostLevel ($hdr.Groups[1].Value -replace '\*\*', '')
            if ($labLevel -ne $moduleCost[$modId]) {
                Add-Issue Error $rel "Cost level disagrees with the module: lab='$labLevel', module='$($moduleCost[$modId])'."
            }
        }
    }
}

# ------------------------------------------------ 3b. objectives data ------
# data/objectives/<exam>-<date>.json holds the same bullets as the snapshot,
# with stable semantic ids and a planned owner module. The two must agree
# exactly: same bullets, same order. Ids must be unique and never reused.

$script:ObjectiveRecords = @()
$objFiles = @(Get-ChildItem -LiteralPath (Join-RepoPath 'data/objectives') -Filter *.json -File -ErrorAction SilentlyContinue)
if ($objFiles.Count -ne 1) {
    Add-Issue Error 'data/objectives' "Expected exactly one objectives file, found $($objFiles.Count)."
}
else {
    $objRel = ConvertTo-RelPath $objFiles[0].FullName
    try {
        $objDoc = Get-Content -LiteralPath $objFiles[0].FullName -Raw | ConvertFrom-Json
        $script:ObjectiveRecords = @($objDoc.objectives)
        $ids = @($script:ObjectiveRecords | ForEach-Object { $_.id })
        $dupes = $ids | Group-Object | Where-Object Count -gt 1
        foreach ($d in $dupes) { Add-Issue Error $objRel "Duplicate objective id: $($d.Name)" }
        foreach ($o in $script:ObjectiveRecords) {
            if ($o.id -notmatch '^[a-z]+\.[a-z]+\.[a-z0-9-]+$') { Add-Issue Error $objRel "Id is not semantic (domain.group.slug): $($o.id)" }
            if ($o.module -notmatch '^\d{2}-\d{2}$') { Add-Issue Error $objRel "$($o.id): planned module missing or malformed." }
        }
        if ($manifest -and $objDoc.outline_version -and $manifest.outline_version -and $objDoc.outline_version -ne $manifest.outline_version) {
            Add-Issue Error $objRel "outline_version $($objDoc.outline_version) differs from the manifest's $($manifest.outline_version)."
        }
    }
    catch { Add-Issue Error $objRel "Invalid JSON: $($_.Exception.Message)" }
}

# Lessons that declare objective_ids must declare them for exactly their bullets.
$idByText = @{}
foreach ($o in $script:ObjectiveRecords) { $idByText[(ConvertTo-Norm $o.objective)] = $o.id }
foreach ($f in $contentFiles) {
    $fm = Read-FrontMatter (Get-Content -LiteralPath $f.FullName -Raw)
    if (-not $fm -or -not $fm.Data.Contains('objective_ids')) { continue }
    $want = @(@($fm.Data.sub_objectives) | ForEach-Object { $idByText[(ConvertTo-Norm $_)] })
    $have = @($fm.Data.objective_ids)
    if (($want -join '|') -ne ($have -join '|')) {
        Add-Issue Error (ConvertTo-RelPath $f.FullName) "objective_ids do not match sub_objectives. Expected: $($want -join ', ')"
    }
}

# ------------------------------------------- 3c. engine exam-neutrality ----
# Domain colours live in assets/css/tokens.css and nowhere else. The favicon is
# the one exception: a data: URI can't read CSS custom properties.
$tokensPath = Join-RepoPath 'assets/css/tokens.css'
if (Test-Path -LiteralPath $tokensPath) {
    $domainHex = [regex]::Matches((Get-Content -LiteralPath $tokensPath -Raw), '--d-0\d:\s*(#[0-9a-fA-F]{6})') |
        ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() } | Sort-Object -Unique
    $engineFiles = @(Get-ChildItem -LiteralPath (Join-RepoPath 'assets') -Recurse -Include *.css, *.js -File |
        Where-Object { $_.FullName -notmatch '[\\/]vendor[\\/]' -and $_.Name -ne 'tokens.css' })
    $engineFiles += @(Get-Item -LiteralPath (Join-RepoPath 'index.html') -ErrorAction SilentlyContinue)
    foreach ($ef in $engineFiles) {
        # Blank out /* block comments */ but keep their newlines, so a colour
        # quoted in a comment isn't flagged and line numbers stay accurate.
        $raw = Get-Content -LiteralPath $ef.FullName -Raw
        $raw = [regex]::Replace($raw, '(?s)/\*.*?\*/', { param($m) $m.Value -replace '[^\n]', '' })
        $n = 0
        foreach ($line in ($raw -split '\n')) {
            $n++
            if ($line -match 'rel="icon"' -or $line -match '^\s*//') { continue }
            foreach ($hex in $domainHex) {
                if ($line.ToLowerInvariant().Contains($hex)) {
                    Add-Issue Error (ConvertTo-RelPath $ef.FullName) "line ${n}: domain colour $hex hardcoded; use var(--d-NN)."
                }
            }
        }
    }
}
# Storage keys are built from AcademyExam.slug. A literal key would be shared by
# every Academy on the same GitHub Pages origin.
foreach ($jf in @(Get-ChildItem -LiteralPath (Join-RepoPath 'assets/js') -Filter *.js -File -ErrorAction SilentlyContinue)) {
    $m = [regex]::Matches((Get-Content -LiteralPath $jf.FullName -Raw), "['""][a-z0-9]+:[a-z]+:v\d+['""]")
    foreach ($x in $m) { Add-Issue Error (ConvertTo-RelPath $jf.FullName) "Literal storage key $($x.Value); build it from AcademyExam.slug." }
}

# ------------------------------------- 3d. comparisons and resource map ----
# data/comparisons.json and data/resources.json are rendered in lessons and at
# #/compare and #/map. A module id, objective or resource id that resolves to
# nothing is a silent hole in the page, so it is an error here.

$moduleIds = [System.Collections.Generic.HashSet[string]]::new()
foreach ($m in $modules) { [void]$moduleIds.Add($m.Id) }
$bulletNorms = [System.Collections.Generic.HashSet[string]]::new()
foreach ($s in $allSubObjectives) { [void]$bulletNorms.Add($s) }

$cmpPath = Join-RepoPath 'data/comparisons.json'
if (Test-Path -LiteralPath $cmpPath) {
    try {
        $cmp = Get-Content -LiteralPath $cmpPath -Raw | ConvertFrom-Json
        $fields = @('name', 'purpose', 'scope', 'layer', 'when', 'difference', 'limitation', 'dependency', 'validate')
        $seen = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($c in $cmp.comparisons) {
            if (-not $seen.Add($c.id)) { Add-Issue Error 'data/comparisons.json' "$($c.id): duplicate id." }
            if (-not $c.takeaway) { Add-Issue Error 'data/comparisons.json' "$($c.id): no AZ-104 takeaway." }
            foreach ($mid in @($c.modules)) {
                if (-not $moduleIds.Contains($mid)) { Add-Issue Error 'data/comparisons.json' "$($c.id): unknown module '$mid'." }
            }
            foreach ($o in @($c.objectives)) {
                if (-not $bulletNorms.Contains((ConvertTo-Norm $o))) { Add-Issue Error 'data/comparisons.json' "$($c.id): objective is not a verbatim bullet: $o" }
            }
            if (@($c.options).Count -lt 2) { Add-Issue Error 'data/comparisons.json' "$($c.id): fewer than two options." }
            foreach ($opt in @($c.options)) {
                foreach ($fld in $fields) {
                    if (-not $opt.$fld) { Add-Issue Error 'data/comparisons.json' "$($c.id) / $($opt.name): missing '$fld'." }
                }
            }
        }
    }
    catch { Add-Issue Error 'data/comparisons.json' "Invalid JSON: $($_.Exception.Message)" }
}
else { Add-Issue Error 'data/comparisons.json' 'Missing.' }

$resPath = Join-RepoPath 'data/resources.json'
if (Test-Path -LiteralPath $resPath) {
    try {
        $res = Get-Content -LiteralPath $resPath -Raw | ConvertFrom-Json
        $rids = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($r in $res.resources) { if (-not $rids.Add($r.id)) { Add-Issue Error 'data/resources.json' "$($r.id): duplicate id." } }
        $questions = @('contains', 'dependsOn', 'dependents', 'manage', 'network', 'monitor', 'protect', 'recover', 'cost', 'remove')
        foreach ($r in $res.resources) {
            foreach ($q in $questions) { if (-not $r.q.$q) { Add-Issue Error 'data/resources.json' "$($r.id): missing answer '$q'." } }
            foreach ($lid in @($r.lessons)) { if (-not $moduleIds.Contains($lid)) { Add-Issue Error 'data/resources.json' "$($r.id): unknown lesson '$lid'." } }
            foreach ($k in @('contains', 'dependsOn', 'dependents')) {
                foreach ($x in @($r.rel.$k)) { if ($x -and -not $rids.Contains($x)) { Add-Issue Error 'data/resources.json' "$($r.id).rel.$k -> unknown resource '$x'." } }
            }
        }
        foreach ($g in $res.groups) { foreach ($x in @($g.ids)) { if (-not $rids.Contains($x)) { Add-Issue Error 'data/resources.json' "group '$($g.name)' -> unknown resource '$x'." } } }
    }
    catch { Add-Issue Error 'data/resources.json' "Invalid JSON: $($_.Exception.Message)" }
}
else { Add-Issue Error 'data/resources.json' 'Missing.' }

# ---------------------------------------------- 4. skills-measured diff ----

$snapshotPath = Join-RepoPath 'docs/SKILLS-MEASURED-SNAPSHOT.md'
if (-not (Test-Path -LiteralPath $snapshotPath)) {
    Add-Issue Warning 'docs/SKILLS-MEASURED-SNAPSHOT.md' 'Snapshot missing - cannot diff sub-objectives against the exam outline.'
}
else {
    $snap = Get-Content -LiteralPath $snapshotPath -Raw
    $skills = [regex]::Match($snap, '(?s)## Skills measured(.*?)(?:\r?\n## |$)')
    if (-not $skills.Success) {
        Add-Issue Warning 'docs/SKILLS-MEASURED-SNAPSHOT.md' 'No "## Skills measured" section found - is this the markdown capture?'
    }
    else {
        # Bullets wrap across lines in the captured markdown; rejoin them first.
        $block = $skills.Groups[1].Value -replace '\r?\n(?!\s*[-#])', ' '
        # Only bullets under an objective ("#### ...") inside a weighted domain
        # ("### Name (20-25%)") are skills. The audience profile and "Skills at
        # a glance" are also bulleted, and counting them produced ten false
        # "not covered" errors. Mirrors parseSnapshot in assets/js/curriculum.js.
        $inDomain = $false; $inObjective = $false
        $live = [System.Collections.Generic.List[string]]::new()
        foreach ($line in ($block -split "`r?`n")) {
            if ($line -match '^###\s+.+\(\d+\s*[-\u2013]\s*\d+%\)\s*$') { $inDomain = $true; $inObjective = $false; continue }
            if ($line -match '^###\s') { $inDomain = $false; $inObjective = $false; continue }
            if ($line -match '^####\s') { $inObjective = $inDomain; continue }
            if ($inObjective -and $line -match '^\s*-\s+\S') {
                $n = ConvertTo-Norm ($line -replace '^\s*-\s+', '')
                if ($n.Length -gt 12) { $live.Add($n) }
            }
        }

        $liveSet = [System.Collections.Generic.HashSet[string]]::new(
            [string[]]$live, [System.StringComparer]::OrdinalIgnoreCase)
        $mineSet = [System.Collections.Generic.HashSet[string]]::new(
            [string[]]$allSubObjectives, [System.StringComparer]::OrdinalIgnoreCase)

        # A bullet owned (in the objectives data) by a module that isn't in the
        # manifest yet is PLANNED: reported as a warning, so the build can grow
        # module by module. A bullet with no owner at all is an error.
        $plannedOwner = @{}
        foreach ($o in $script:ObjectiveRecords) { $plannedOwner[(ConvertTo-Norm $o.objective)] = $o.module }
        $builtModules = @($modules | ForEach-Object { $_.Id })
        $plannedCount = 0
        foreach ($s in $liveSet) {
            if (-not $mineSet.Contains($s)) {
                $owner = $plannedOwner[$s]
                if ($owner -and $owner -notin $builtModules) { $plannedCount++ }
                elseif ($owner) {
                    Add-Issue Error 'docs/SKILLS-MEASURED-SNAPSHOT.md' "Outline bullet owned by $owner, but $owner does not list it: $s"
                }
                else {
                    Add-Issue Error 'docs/SKILLS-MEASURED-SNAPSHOT.md' "Outline bullet not covered by any module and has no planned owner: $s"
                }
            }
        }
        if ($plannedCount) {
            Add-Issue Warning 'data/objectives' "$plannedCount outline bullet(s) are planned: owned by modules not written yet."
        }
        foreach ($s in $mineSet) {
            if (-not $liveSet.Contains($s)) {
                Add-Issue Error 'content' "sub_objective is not in the captured outline (owner $($subOwner[$s])): $s"
            }
        }
        Add-Issue Info 'docs/SKILLS-MEASURED-SNAPSHOT.md' "Outline bullets: $($liveSet.Count); guide sub-objectives: $($mineSet.Count)."
    }
}

# --------------------------------------------------------- 6. quizzes ------

$quizDir = Join-RepoPath 'quizzes'
$quizzed = [System.Collections.Generic.HashSet[string]]::new()

if (Test-Path -LiteralPath $quizDir) {
    foreach ($qf in (Get-ChildItem -LiteralPath $quizDir -Filter *.json -File | Sort-Object Name)) {
        $rel = ConvertTo-RelPath $qf.FullName
        try { $q = Get-Content -LiteralPath $qf.FullName -Raw | ConvertFrom-Json }
        catch { Add-Issue Error $rel "Invalid JSON: $($_.Exception.Message)"; continue }

        if (-not $q.module) { Add-Issue Error $rel 'No "module" property.'; continue }
        [void]$quizzed.Add($q.module)

        $owned = @($subOwner.GetEnumerator() |
            Where-Object { $_.Value -eq $q.module } |
            ForEach-Object { $_.Key })

        if ($owned.Count -eq 0) {
            Add-Issue Error $rel "No content module matches module id '$($q.module)'."
            continue
        }

        $seenIds = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($item in $q.questions) {
            $qid = if ($item.id) { $item.id } else { '(no id)' }

            if (-not $seenIds.Add($qid)) { Add-Issue Error $rel "$qid : duplicate question id." }
            if (-not $item.prompt)       { Add-Issue Error $rel "$qid : no prompt." }
            if (-not $item.explanation)  { Add-Issue Warning $rel "$qid : no explanation." }
            if (-not $item.clue)         { Add-Issue Error $rel "$qid : no scenario clue." }

            $opts = @($item.options)
            if ($opts.Count -lt 3) { Add-Issue Error $rel "$qid : only $($opts.Count) options." }
            if (($opts | Select-Object -Unique).Count -ne $opts.Count) {
                Add-Issue Error $rel "$qid : duplicate option text."
            }

            foreach ($i in @($item.answer)) {
                # JSON integers deserialise as Int64 in PowerShell 7, so a type
                # test against [int] rejects every valid index. Coerce instead.
                $idx = $i -as [int]
                if ($null -eq $idx -or $idx -lt 0 -or $idx -ge $opts.Count) {
                    Add-Issue Error $rel "$qid : answer index '$i' out of range (0..$($opts.Count - 1))."
                }
            }

            # The join between a wrong answer and what to re-read.
            if ((ConvertTo-Norm $item.sub_skill) -notin $owned) {
                Add-Issue Error $rel "$qid : sub_skill is not a verbatim sub_objective of $($q.module)."
            }
        }
    }
}
else {
    Add-Issue Warning 'quizzes' 'No quizzes directory.'
}

foreach ($m in $modules) {
    if ($m.Weight -ne 'n/a' -and -not $quizzed.Contains($m.Id)) {
        Add-Issue Warning 'quizzes' "$($m.Id): no knowledge check."
    }
}

# ----------------------------------------------------------- 7. links ------

$onDisk = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@(@($contentFiles + $labFiles) | ForEach-Object { ConvertTo-RelPath $_.FullName }),
    [System.StringComparer]::OrdinalIgnoreCase)

$externals = [System.Collections.Generic.HashSet[string]]::new()

foreach ($f in @($contentFiles + $labFiles)) {
    $rel  = ConvertTo-RelPath $f.FullName
    $dir  = Split-Path -Parent $rel
    $text = Get-Content -LiteralPath $f.FullName -Raw

    foreach ($m in [regex]::Matches($text, '\[[^\]]*\]\(([^)\s]+)\)')) {
        $href = $m.Groups[1].Value
        if ($href -match '^(https?:|#|mailto:)') {
            if ($href -match '^https://learn\.microsoft\.com/') { [void]$externals.Add($href) }
            continue
        }
        $target = ($href -split '#')[0]
        if (-not $target) { continue }

        $combined = if ($dir) { "$dir/$target" } else { $target }
        $norm = ([System.IO.Path]::GetFullPath(
            (Join-Path $Root ($combined -replace '/', [System.IO.Path]::DirectorySeparatorChar))))
        $normRel = ConvertTo-RelPath $norm

        if ($normRel -like '*.md' -and -not $onDisk.Contains($normRel)) {
            if (-not (Test-Path -LiteralPath $norm)) {
                Add-Issue Error $rel "Unresolved internal link -> $href"
            }
        }
        elseif ($normRel -notlike '*.md' -and -not (Test-Path -LiteralPath $norm)) {
            Add-Issue Warning $rel "Link target not found -> $href"
        }
    }

    foreach ($m in [regex]::Matches($text, '<(https://learn\.microsoft\.com/[^>\s]+)>')) {
        [void]$externals.Add($m.Groups[1].Value)
    }
}

Add-Issue Info 'links' "Distinct learn.microsoft.com URLs cited: $($externals.Count)."

if ($CheckExternalLinks) {
    Write-Host "Checking $($externals.Count) external links..." -ForegroundColor DarkGray
    $n = 0
    foreach ($url in ($externals | Sort-Object)) {
        $n++
        Write-Progress -Activity 'External links' -Status $url -PercentComplete (100 * $n / $externals.Count)
        try {
            $r = Invoke-WebRequest -Uri $url -Method Head -MaximumRedirection 5 `
                                   -SkipHttpErrorCheck -TimeoutSec 20
            if ($r.StatusCode -ge 400) {
                Add-Issue Error 'links' "HTTP $($r.StatusCode) -> $url"
            }
        }
        catch {
            Add-Issue Warning 'links' "Unreachable ($($_.Exception.Message)) -> $url"
        }
    }
    Write-Progress -Activity 'External links' -Completed
}

# ----------------------------------------------------------- report --------

$errors   = @($script:Issues | Where-Object Severity -eq 'Error')
$warnings = @($script:Issues | Where-Object Severity -eq 'Warning')
$infos    = @($script:Issues | Where-Object Severity -eq 'Info')

Write-Host ''
Write-Host ('=' * 66)
$examCode = ([regex]::Match((Get-Content -LiteralPath (Join-RepoPath 'data/exam.js') -Raw -ErrorAction SilentlyContinue), "code:\s*'([^']+)'")).Groups[1].Value
Write-Host "  $examCode Academy validation" -ForegroundColor Cyan
Write-Host "  root: $Root"
Write-Host ('=' * 66)
Write-Host ("  content {0,-4} labs {1,-4} quizzes {2,-4} modules {3}" -f `
    $contentFiles.Count, $labFiles.Count, $quizzed.Count, $modules.Count)
Write-Host ("  sub-objectives {0}" -f $allSubObjectives.Count)
foreach ($i in $infos) { Write-Host "  $($i.Message)" -ForegroundColor DarkGray }
Write-Host ('=' * 66)

foreach ($group in @(
    @{ Name = 'ERROR';   Items = $errors;   Colour = 'Red' },
    @{ Name = 'WARNING'; Items = $warnings; Colour = 'Yellow' }
)) {
    Write-Host ''
    Write-Host "$($group.Name): $($group.Items.Count)" -ForegroundColor $group.Colour
    foreach ($g in ($group.Items | Group-Object File | Sort-Object Name)) {
        Write-Host "   $($g.Name)" -ForegroundColor Gray
        foreach ($i in $g.Group) { Write-Host "      $($i.Message)" }
    }
}

Write-Host ''
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host '  PASS - no issues.' -ForegroundColor Green
}
elseif ($errors.Count -eq 0) {
    Write-Host "  PASS with $($warnings.Count) warning(s)." -ForegroundColor Yellow
}
else {
    Write-Host "  FAIL - $($errors.Count) error(s), $($warnings.Count) warning(s)." -ForegroundColor Red
}
Write-Host ''

$exit = 0
if ($errors.Count -gt 0) { $exit = 1 }
elseif ($FailOn -eq 'Warning' -and $warnings.Count -gt 0) { $exit = 1 }
exit $exit
