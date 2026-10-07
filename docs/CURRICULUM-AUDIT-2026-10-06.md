# Curriculum audit: 2026-10-06

The beginner-first, certification-first pass. This file records what was checked against
Microsoft Learn, what changed, what was classified how, and what still needs verifying, so the
syllabus decisions stay reviewable.

## 1. Objective drift

**Source.** The official study guide, retrieved through the Microsoft Learn MCP server:
<https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104>

**Effective version.** *Skills measured as of April 17, 2026*. It is the only outline the page
currently shows, so it is the controlling scope for the whole Academy.

**Method.** A mechanical diff of every domain, weight, functional group and bullet against
`data/objectives/az104-2026-04-17.json`, verbatim and in order.

| Domain | Weight | Functional groups | Bullets | Diff |
| --- | --- | --- | --- | --- |
| Manage Azure identities and governance | 20–25% | 3 | 15 | none |
| Implement and manage storage | 15–20% | 3 | 17 | none |
| Deploy and manage Azure compute resources | 20–25% | 4 | 24 | none |
| Implement and manage virtual networking | 15–20% | 3 | 13 | none |
| Monitor and maintain Azure resources | 10–15% | 2 | 13 | none |

No additions, removals, wording changes, regrouping or weight changes. The study guide's own change
log describes the April 17, 2026 changes as minor; they were already in the stored outline.

## 2. Classification of existing material

| Class | Material |
| --- | --- |
| **CURRENT** | All 15 exam lessons and labs, 212 knowledge-check questions, 216 flashcards, 35 A6 comparisons. Every one of the 82 bullets has a lesson, a lab and at least one question. |
| **FOUNDATION** | Module 0A (13 new primers) and Module 0B (the 3 lab-safety lessons). Not measured directly; needed to understand what is. |
| **SUPPLEMENTAL** | Application Gateway, as one side of the load-balancer comparison only. It's in the study guide's documentation list and the official networking learning path, not in a skills-measured bullet. Labeled in the comparison. The existing *Beyond the exam* panels. |
| **NEEDS UPDATE** | None for objective alignment. Engine inaccuracies are listed in section 4. |
| **BEYOND THE EXAM / OBSOLETE** | None found. |

## 3. Scope decisions

- **NSG vs Azure Firewall: excluded.** Azure Firewall isn't in the skills measured or in the study
  guide's documentation list. The exclusion is recorded in `data/comparisons.json`.
- **Load Balancer vs Application Gateway: included, as supplemental.** Distinguishing Layer 4 from
  Layer 7 load balancing supports *Configure an internal or public load balancer*.
- **System-assigned vs user-assigned managed identities: included.** Supported by
  *Create and manage an Azure Container Registry* (pulling images with an identity) and
  *Configure storage account encryption* (customer-managed keys reach Key Vault with an identity).
- **Module 0A stays at the depth AZ-104 needs.** It isn't an AZ-900 course: each primer ends by
  pointing to the AZ-104 lessons that use it, and the dashboard lets experienced learners skip it.

## 4. Defects found and corrected

| Defect | Effect | Fix |
| --- | --- | --- |
| 15 of 16 labs had no checklist | "Practised" meant pressing *Mark as read*, which contradicts "don't treat clicking as learning" | Every lab now has a validation checklist of observed results and a teardown checklist; the validator requires both |
| Lab card said "activate roles through PIM" | Contradicted lesson 00-00, which explains why PIM isn't used | Text now says to hold only the roles the lab needs |
| Sidebar kept only the last non-exam domain | Adding Module 0A would have hidden Module 0B | Every non-exam group is rendered, before the exam domains |
| Lab checklist section detection walked siblings | Validation and Teardown are wrapped in `<section>` by `sections.js`, so no item was ever recorded as a validation check (found by the smoke test) | Detection uses document order |
| Validator assumed numeric module ids | It crashed on `0A-*` files | Module id pattern accepts `0A` |
| `content/official-training.json` was empty | No link to Microsoft's own training | Filled from Microsoft Learn: course AZ-104T00-A and all six learning paths. Corrected in the revalidation below to 28 modules |

## 5. Verification performed

- `tools/Test-GuideContent.ps1`: PASS, 0 errors, 0 warnings, with the new checks (lesson anatomy,
  primer anatomy, lab checklists, scenario clues, comparison and resource-map integrity).
- `tools/smoke-test.js` (new, jsdom): 68 of 68 routes render with no script errors.
- All 41 Mermaid diagrams parse with the vendored Mermaid build (`mermaid.parse`), including the
  domain class definitions the engine appends.
- Functional checks: lesson stages render in order; the knowledge check shows correct answer, why,
  why not the others, scenario clue and objective; ticking a lab's validation checklist sets
  **Validated**; a question answered correctly again 7 or more days later counts toward
  **Retained**.

## 6. Knowledge boundary: needs verification

- **Microsoft's own AZ-104 lab exercises** aren't mapped. The GitHub API rate limit blocked the
  check, so they're left out rather than listed unverified.
- **Accessibility (axe)** wasn't run in this pass: no browser was available. The `a11y` workflow runs
  it on push; its route list now includes a primer, the resource map, the glossary and the
  comparison view.
- **Bicep and ARM template compilation** (`tools/check-templates.sh`) needs the Bicep CLI, which
  wasn't available here. The `bicep` workflow runs it on push. No template changed in this pass.

## 7. Revalidation of the published repository (2026-10-06, evening)

Run against commit `7d4c812` as published on GitHub, which is byte-identical to the build
that was delivered.

| Check | Result |
| --- | --- |
| Study guide, re-retrieved through the Microsoft Learn MCP server | Still *Skills measured as of April 17, 2026*. 5 domains, 15 functional groups and 82 bullets match the objectives data, the skills snapshot and the manifest weights, verbatim and in order |
| GitHub Actions on `7d4c812` | Validate and Accessibility passed. Bicep runs only on changes under `labs/`; no template changed since its last pass. Pages deployed |
| Live site | Serves the current build (service worker cache `v3`); the deleted design record returns 404 |
| `tools/Test-GuideContent.ps1` | PASS, 0 errors, 0 warnings |
| `tools/smoke-test.js` | 68 of 68 routes render with no script errors |
| Mermaid | 41 of 41 diagrams parse |
| Leftovers from another exam | None, by name or by topic |

**Corrected: two learning paths in `content/official-training.json`.** Microsoft's rendered
path pages and its path definitions in the public `MicrosoftDocs/learn` repository agree, and
both disagreed with the Academy:

| Path | Was | Now (Microsoft) |
| --- | --- | --- |
| AZ-104: Prerequisites for Azure administrators | 5 modules, including the portal tour, Bash and PowerShell introductions | 2: Introduction to Azure Cloud Shell; Deploy Azure infrastructure by using JSON ARM templates |
| AZ-104: Monitor and back up Azure resources | 4: two backup modules, Introduction to Azure Monitor, Improve incident response with alerts | 3: the two backup modules and Monitor your Azure virtual machines with Azure Monitor |

The course page doesn't list modules, so whether Microsoft changed these paths or the first
capture was wrong can't be determined. The other four paths matched module for module. All
28 modules now carry Microsoft's `uid`.

**Corrected: the outline-drift workflow could not have compared modules.** It compares each
stored module's `uid` with Microsoft's path definitions, and the file stored no `uid`, so every
module would have been reported as added. Run locally against Microsoft's definitions, the
workflow's own logic reported 14 changes for the published file and none for the corrected one,
and still caught a module deliberately removed from the corrected file.

**Not checked here: external links.** This environment can't reach learn.microsoft.com, so the
65 Microsoft Learn URLs added on 2026-10-06 haven't been HEAD-checked. The ones that come from
learning paths were confirmed by the path pages above. The weekly Validate run checks every URL;
it can also be started from the Actions tab with *check external links* ticked.

