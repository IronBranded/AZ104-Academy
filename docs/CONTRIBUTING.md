# Contributing

How to add or change content without breaking the guide. Read
[STYLE-GUIDE.md](./STYLE-GUIDE.md) for the conventions themselves; this file is
the workflow.

---

## Before you write anything

**Re-fetch the skills-measured outline and diff it.** Microsoft revises these
lists; AZ-104's last revision took effect on April 17, 2026. The snapshot in
`docs/SKILLS-MEASURED-SNAPSHOT.md` is the drift baseline:

```powershell
$url = 'https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104?accept=text/markdown'
(Invoke-WebRequest -Uri $url -UseBasicParsing).Content |
    Set-Content -Path '.\docs\SKILLS-MEASURED-SNAPSHOT.new.md' -Encoding utf8

Compare-Object (Get-Content .\docs\SKILLS-MEASURED-SNAPSHOT.md) `
               (Get-Content .\docs\SKILLS-MEASURED-SNAPSHOT.new.md)
```

If the diff is empty, delete the `.new` file. If it is not, the outline moved:
update the affected module's `sub_objectives` and `objective_ids`,
`data/objectives/`, `manifest.json` and the snapshot together, in one commit, and
classify every affected lesson as CURRENT, NEEDS UPDATE, FOUNDATION, BEYOND THE
EXAM or OBSOLETE in a dated `docs/CURRICULUM-AUDIT-*.md`.

**Then re-verify the product documentation for the module you are touching.** Not
the study guide — the actual product pages. Several things this guide teaches
changed recently: NSG flow logs gave way to virtual network flow logs, the Log
Analytics agent was retired, Connection monitor (classic) was deprecated, and the
VM insights Map and its Dependency agent have a retirement date. Assume something
has moved.

---

## Authoring a module

1. **Copy an existing module of similar shape.** 02-01 for an access-control
   module, 03-04 for a many-bullet one, 04-03 for one that pairs two services, and
   any 0A primer for a foundation lesson.
2. **Write the front matter first**, all seventeen required keys, plus
   `objective_ids` from `data/objectives/`. It drives the site's field
   card, so an empty `licensing` or a wrong `lab_cost_estimate` is visible to the
   reader.
3. **Write `The administrative problem` before opening any portal.** If you cannot
   explain the requirement without naming a product, you do not understand the
   service yet. Then follow the lesson anatomy in STYLE-GUIDE §2, in order.
4. **Write the lab second**, and actually run it. Every cmdlet in this repository
   was either executed or explicitly flagged as version-sensitive.
5. **Add the module's comparisons** to `content/appendix/a6-choosing-between-options.md`,
   each opening with a `**Modules NN-NN.**` line so lessons can find them.
6. **Add the quiz** at `quizzes/<id>.json`. Scenario questions, one deciding
   constraint each, tagged with a verbatim `sub_skill`. Every question in the
   repository carries `why_not`: one note per wrong option, `null` for correct ones,
   restating what the explanation or the module already says. `difficulty`,
   `concept` and `misconception` are optional. Write every question from the
   documentation. Never use exam dumps or recalled exam questions.
7. **Add a diagram only where it beats a paragraph** - decision order, two paths
   that are easy to confuse, a pipeline. Use a ` ```mermaid ` flowchart:
   - put `accTitle:` and `accDescr:` on its first lines;
   - use `:::d0A`, `:::d00` and `:::d01` to `:::d05` for domain colour, and keep a
     text label on every node;
   - draw nothing the lesson text does not already say;
   - prefer top-down; left-to-right diagrams become unreadable on a phone.
8. **If an objective heading changes**, update `content/official-training.json` in
   the same commit. It joins Microsoft's learning paths and labs to objectives by
   heading text.
9. **Update `content/manifest.json`** if the module is new, and add its resources
   and comparisons to `data/resources.json` and `data/comparisons.json`.
10. **Tear down your own lab** before committing. Then run the verification sweep
   in `content/00-lab-safety/00-02-teardown-checklist-template.md`.

---

## Validate before every commit

```powershell
.\tools\Test-GuideContent.ps1
```

Checks front-matter schema, `domain_weight` and `status` values, `last_verified`
format and age, internal relative links, and that `manifest.json` points at files
that exist. Since the 2026-10-06 pass it also requires the full lesson anatomy
(docs/STYLE-GUIDE.md, section 2), the primer anatomy for Module 0A, a validation
checklist and a teardown checklist in every lab, a `clue` on every question, and
ids in `data/comparisons.json` and `data/resources.json` that resolve.

Weekly, or before a release:

```powershell
.\tools\Test-GuideContent.ps1 -CheckExternalLinks
```

This HEADs roughly 120 Microsoft Learn URLs. A 404 usually means a page moved
rather than a claim being wrong — find the new page and update the Sources block.
A redirect chain is fine.

### Accessibility, when you touch the site

```text
npm install --no-save playwright@1.56.0 axe-core@4.13.0
npx playwright install chromium
python -m http.server 8080 &
node tools/a11y-check.js
```

This is the same check CI runs on every push. It loads every page type in both
themes and fails on any WCAG 2.0/2.1 A or AA violation.

**If you changed any file under `assets/`, bump `CACHE_VERSION` in `sw.js`.** The
live site serves its code cache-first for offline use, so an unbumped version
means returning visitors run stale code alongside new content.

### Smoke-test every route

```text
npm install --no-save jsdom@24
python -m http.server 8080 &
node tools/smoke-test.js
```

Loads every lesson, lab, appendix and study view headlessly and fails if a page
throws, shows an error box, or renders without a heading. It found the lab
checklist bug the 2026-10-06 pass fixed; run it whenever you touch `assets/js`.

### Serve the site and click through

```powershell
python -m http.server 8080
```

The site fetches Markdown at runtime, so `file://` will not work. Clicking through
is a second link check the PowerShell validator cannot do: **an internal link the
site cannot resolve renders with a dotted underline and a tooltip naming the bad
path.**

---

## What the validator checks

All eight gaps previously logged here are now closed. `tools/Test-GuideContent.ps1`
requires **PowerShell 7** and is cross-platform. Each check below was
negative-tested - broken on purpose, confirmed to fire, then restored.

| Check | Catches |
| --- | --- |
| Front-matter schema | Any of the 17 keys missing; bad `domain_weight` or `status`; malformed or stale `last_verified` |
| Required sections | An exam lesson missing any section of the lesson anatomy, or a 0A primer missing any primer section (STYLE-GUIDE §2); a *Words you need to know* table with fewer than three terms; a *Where it fits* table without the ten questions |
| Lab schema | A lab missing any required section, or with no numbered parts; a `## Validation` or `## Teardown` with no `- [ ]` checklist |
| Outline diff | A bullet in `SKILLS-MEASURED-SNAPSHOT.md` that no module covers, or a `sub_objective` not in the captured outline |
| Front matter vs body | `sub_objectives` disagreeing with the `## Sub-objectives covered` list |
| Duplicate ownership | The same sub-objective claimed by two **exam** modules. A foundation lesson may list one it also prepares for |
| Cost parity | A module's `lab_cost_estimate` level disagreeing with its lab's `**Estimated cost:**` header |
| Quizzes | Malformed JSON, an `answer` index out of range, a `sub_skill` that is not a verbatim sub-objective, duplicate options or ids, fewer than three options, a missing explanation or scenario `clue` |
| Comparisons and resource map | An id in `data/comparisons.json` or `data/resources.json` that resolves to no module, objective or resource; a comparison option missing any of its nine fields |
| Manifest | Module *and appendix* paths that do not resolve; a module with no lab or no quiz |
| Orphans | Markdown on disk that no manifest entry references |
| Links | Unresolved relative links; with `-CheckExternalLinks`, every `learn.microsoft.com` URL |

Modules 0A and 0B are exempt from the exam-module rules, since `domain_weight: n/a`
marks them as foundations rather than exam domains: they need no `sub_objectives`,
no lab on every file, and no knowledge check.

```powershell
.\tools\Test-GuideContent.ps1                       # per commit
.\tools\Test-GuideContent.ps1 -CheckExternalLinks   # weekly
.\tools\Test-GuideContent.ps1 -FailOn Warning       # strict: warnings fail too (CI uses the default)
```

Exit code is 0 on pass, 1 on failure, so it drops straight into a pre-commit hook
or a workflow step.

### Previously logged gaps, for the record

| Gap | Why it matters |
| --- | --- |
| **Required sections are not checked.** Only front matter and links are. | A module missing `## Sources` or `## How this is tested` passes. |
| **Lab files are not schema-checked at all** — only for `## Teardown`. | A lab with no `## Validation` or no `## Prerequisites` passes. |
| **`sub_objectives` are not diffed against the snapshot.** | The whole point of keeping a verbatim baseline is undone by not comparing it. |
| **Quiz files are unvalidated.** | A `sub_skill` that does not match any `sub_objective`, an `answer` index out of range, or malformed JSON fails silently in the browser. |
| **`manifest.json` appendix paths are not checked.** | The loop only walks `domains`. The nav now depends on `appendix`. |
| **Windows path separators are assumed** (`content\manifest.json`, `-replace '/','\'`). | Fails on PowerShell 7 on Linux or macOS. |
| **No check that every module has a quiz**, or that `lab` paths in the manifest resolve for modules that declare one. | Silent coverage gaps. |
| **No orphan check**: files on disk that no manifest entry references. | A renamed file leaves an unreachable page. |

---

## When to bump `last_verified`

Bump it when you **re-checked the product documentation**, not when you edited
prose. The field answers "when was this last known to be true", and the site shows
a day count past 60 to match the validator's warning. Fixing a typo does not make
a claim fresher.

If a warning fires and you re-check and nothing changed, bump it anyway — that is
a verification, and it is the one you want recorded.

---

## Commit conventions

```
content(04-02): secure access to virtual networks, lesson and lab
docs(appendix): exam information page
feat(site): progress tracking, collapsible depth, search and quiz engine
fix(02-02): correct the redundancy conversion path from ZRS to GRS
```

Scope is the module id, `appendix`, `site`, `docs`, or `tools`. One module per
commit — content and lab together, since they are written as a pair.

---

## Repository layout

The README is written for learners. This is the map for maintainers.

| Path | What it holds |
| --- | --- |
| `content/` | Lesson files: Module 0A (13 foundation primers), Module 0B (3 lab-safety lessons) and one module per AZ-104 functional group (15). Theory only - the problem, where it fits, how it works, how it is tested |
| `labs/` | One lab per exam lesson: numbered steps, portal and PowerShell, validation, and a mandatory teardown |
| `content/appendix/` | Exam information (A1) and the comparisons appendix (A6) |
| `content/manifest.json` | The only file that defines the site's structure. Patched by hand |
| `content/official-training.json` | Course AZ-104T00-A and its six learning paths, mapped to lessons |
| `quizzes/` | One knowledge check per exam lesson, each question tagged with the official sub-objective it tests |
| `flashcards/` | The distinctions deck |
| `assets/` | The site: dependency-free HTML, CSS and JavaScript, no build step |
| `tools/`, `.github/workflows/` | The validator, the accessibility check, and the CI that runs them |
| `data/` | Exam identity (`exam.js`), the objectives with stable ids (`objectives/`), the resource map (`resources.json`) and the comparisons (`comparisons.json`). The engine reads them and hardcodes none of it |
| `docs/` | This guide, the style guide, the skills-outline snapshot, and the dated curriculum audits |

**The split between `content/` and `labs/` is deliberate.** Theory files contain no
numbered configuration steps; labs contain no conceptual explanation. A review pass
reads `content/`; someone at a terminal reads `labs/`.

## Automated checks

| Check | When | What fails it |
| --- | --- | --- |
| **Validate** (`tools/Test-GuideContent.ps1`) | Every push and pull request; weekly with external links | Front-matter schema, required sections, lab structure including teardown, objective mapping against the snapshot, quiz integrity, manifest and orphans, broken internal links. The weekly run also checks every Microsoft Learn URL |
| **Outline drift** | Weekly | The live skills outline differing from `docs/SKILLS-MEASURED-SNAPSHOT.md`, ignoring line wrapping, or a linked learning path, its module list, or a Microsoft lab changing. Either opens an issue |
| **Accessibility** (`tools/a11y-check.js`) | Every push and pull request | Any WCAG 2.0/2.1 A or AA violation, or a script error, on any page type in either theme |

## Things that are deliberate

Do not "fix" these without discussing them first:

- **One module per functional group: 15 exam modules.** Every one of the 82 outline
  bullets has exactly one owner, recorded in `data/objectives/`. A bullet whose
  module isn't written yet is a validator warning ("planned"), never silently missing.
- **Walkthrough labs** where hands-on practice would be expensive. Each says why and
  is recorded as a walkthrough, never merged with hands-on practice.
- **Portal-only steps** where the cmdlet surface is unstable. See STYLE-GUIDE §5.
- **`rg-az104-core` is never torn down.** It holds the budget, action group and
  brake runbook. Lab 00-01 has a deliberately different teardown section for this reason.
- **No readiness percentage, no pass prediction.** The dashboard reports
  observable counts per official sub-objective. Do not add a blended score.
- **Two kinds of objective id.** Stable semantic ids (`id.users.sspr`) live in
  `data/objectives/` and in lesson front matter, and survive a reorder of the official
  outline. The numbers the site displays (`1.1.5`) are positions, derived at load time.
- **Adjacent material is labelled.** A lesson may carry a short "Context - not a
  measured skill" note when a scenario needs it. Never build a lab or question on one.
- **The guide names its own uncertainty.** Where Microsoft does not publish a fact
  — AZ-104's question count, length and price — appendix A1 says so instead of
  repeating a third-party number. Keep that habit.

## Lab templates

Bicep files, `.bicepparam` files and ARM JSON templates live under `labs/<domain>/templates/`, with
worked answers under `templates/solutions/`. CI (`.github/workflows/bicep.yml`) runs
`tools/check-templates.sh`: every Bicep file must build and pass the linter, every parameters file
must build, and every ARM template must decompile. Run it locally before committing:

```bash
bash tools/check-templates.sh    # needs the Bicep CLI on PATH
```

The workflow pins the Bicep CLI version. Bump it deliberately: new versions can add linter rules.
