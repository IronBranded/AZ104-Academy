# Style Guide

The conventions this repository actually follows. Every rule here is descriptive
rather than aspirational — it was extracted from the 31 modules (13 foundation
primers, 3 lab-safety lessons and 15 exam lessons), 16 labs and 2 appendices after
they were written, so a new module that follows this guide will look like the
existing ones.

If you disagree with a rule, change it here first, then change the content. A
convention that lives only in one author's head is not a convention.

---

## 1. Sourcing

**Microsoft Learn is the only source of factual content.** Product documentation,
the AZ-104 study guide, and Microsoft Learn training modules. Nothing else.

Third-party material — courses, blogs, practice-question vendors, forum posts —
may be used **only** to sanity-check structure and emphasis: *is this topic
weighted the way I think it is?* It is never the source of a claim. Prep sites
routinely contradict each other, and the official page, on an exam's length and
question count; appendix A1 says what Microsoft publishes instead of repeating them.
That is the failure mode this rule exists to prevent.

**Every module ends with a Sources block** listing the specific pages it draws
from, as inline autolinks:

```markdown
## Sources

- Microsoft Learn - AZ-104 skills measured: <https://learn.microsoft.com/...>
- Azure Storage redundancy: <https://learn.microsoft.com/azure/storage/common/storage-redundancy>
```

Only list pages you actually read. A Sources block padded with plausible URLs is
worse than a short one, because it launders unverified claims.

**Locale-less URLs are acceptable** (`learn.microsoft.com/azure/...`). If you only
ever saw a page in another locale, use the locale-less form rather than
constructing an `en-us` URL you have not opened.

### Verbatim quoting limits

- **Sub-objectives are quoted verbatim** from the skills-measured outline, in
  `sub_objectives` and in the `## Sub-objectives covered` list. They are the
  literal thing the exam is built from, and paraphrasing them loses the mapping.
- **Everything else is written in our own words.** Do not reproduce paragraphs of
  Microsoft documentation. Explain the mechanism, then cite the page.
- Short exact strings that matter — a cmdlet, a role name such as
  `Storage Blob Data Reader`, a SKU such as `Standard_RAGRS`, a log table such as
  `AzureActivity` — are quoted as code.

---

## 2. Structure

### Two files per objective

| File | Answers |
| --- | --- |
| `content/<domain>/<id>-<slug>.md` | Why the resource or setting exists, where it fits, and how it works |
| `labs/<domain>/<id>-lab.md` | How to configure it, prove it, and remove it |

Theory never contains numbered configuration steps. Labs never contain the
conceptual explanation. A reader doing a review pass reads content; a reader at a
terminal reads the lab.

### Required sections, in order

Every exam lesson follows one teaching sequence. The validator enforces the
headings; the lesson engine (`assets/js/lesson.js`) groups them into stages.

> PROBLEM -> PLAIN ENGLISH -> MENTAL MODEL -> TERMINOLOGY -> RELATIONSHIPS ->
> HOW IT WORKS -> CONFIGURE -> VALIDATE -> DISTINGUISH -> TROUBLESHOOT ->
> EXAM LENS -> KNOWLEDGE CHECK -> TEACH IT BACK -> REVIEW

**Content file (exam module):**

| Heading | Stage | What it must do |
| --- | --- | --- |
| `## Sub-objectives covered` | Orient | Verbatim bullets from the snapshot |
| `## The administrative problem` | Understand | The operational requirement, **before** the service is named |
| `## In plain English` | Understand | The idea with no jargon; compatible with the precise version later |
| `## Words you need to know` | Understand | A two-column table, `Term` and `In plain English`, at least three terms. The glossary view is built from these tables |
| `## Mental model` | Understand | A diagram or analogy, an everyday-idea to Azure-name table, and one sentence saying it's a teaching model |
| `## Where it fits` | Understand | The ten-question table: contains, depends on, depended on by, who manages, networking, monitoring, protection, recovery, cost, safe removal |
| `## How it works under the hood` | Learn | Mechanism, not menu paths |
| `## Configuration surface` | Learn | Commands and the setting / default / exam-angle table |
| `## Worked example` | Learn | A realistic requirement, the decision, the configuration and how it's proven |
| `## Validate the result` | Validate | Observable checks that prove the desired state; never "the command succeeded" |
| `## Common failure modes` | Distinguish | Quoted symptom, then cause and fix |
| `## How this is tested` | Distinguish | Rendered as the **Exam Lens** |
| `## Hands-on` | Practice | One line linking the lab |
| `## Check yourself` | Check | Reasoning questions, not recall |
| `## Teach it back` | Check | Prompts the learner answers out loud, without notes |
| `## Key takeaways` | Review | 3 to 5 points |
| `## Sources` | Review | Microsoft Learn pages the lesson was checked against |

**Foundation lesson (Modules 0A and 0B):** `## The problem`, `## In plain English`,
`## Words you need to know`, `## Mental model`, `## Where this shows up in AZ-104`,
`## Check yourself`, `## Teach it back`, `## Key takeaways`, `## Sources`. Primers
teach prerequisite knowledge only to the depth an AZ-104 lesson needs, stay
skippable, and never turn into AZ-900. Module 0B lessons may add sections between
`## Mental model` and `## Where this shows up in AZ-104` for the lab conventions they
set, such as naming tables or the teardown template.

**Lab file:**

1. `# Lab <id> - Title`, then objective, cost, licensing and warning callouts
2. `## Why this matters` — the administrative problem the lab solves
3. `## The desired state` — what will be true at the end, each item checked later
4. `## Prerequisites`
5. Numbered `## Part N` sections, with portal and command-line methods where both exist
6. `## Validation` — commands and portal checks, then a `### Validation checklist`
   of `- [ ]` items. Each item names an **observed result**. The lab counts as
   **validated** when these are ticked
7. `## What just happened?` — reconnect the steps to the lesson's mental model
8. `## Teardown` — the six buckets, ending in a `- [ ]` verification checklist.
   The lab counts as **practised** only when validation and teardown are both ticked

Optional, licence-gated parts are never checklist items: a learner without the
licence must still be able to finish the lab honestly.

---

## 3. Front matter schema

All seventeen keys below are required on every content file; `Test-GuideContent.ps1`
fails the build otherwise. Empty is fine; missing is not. Exam lessons also carry
`objective_ids`.

| Key | Type | Notes |
| --- | --- | --- |
| `objective` | string | Verbatim from the study guide |
| `sub_objectives` | list | Verbatim. Empty list for foundation lessons |
| `domain` | string | Must match `manifest.json` |
| `domain_weight` | string | `20-25%`, `15-20%`, `10-15%`, or `n/a` for Modules 0A and 0B — **validated** |
| `status` | `GA` \| `Preview` | **Validated.** Use `Preview` if any sub-objective depends on a preview feature |
| `prerequisites` | list of module ids | Rendered as links in the lesson header |
| `ms_learn_source` | url | The study guide, or the main page a primer was checked against |
| `product_docs` | list of urls | The pages you actually read |
| `last_verified` | `YYYY-MM-DD` | **Validated**; warns after 60 days |
| `portal` | string | Where the work happens |
| `powershell_module` | string | Comma-separated; rendered as code chips |
| `az_cli_command` | string | One representative command, or empty |
| `kql_tables` | list | Log tables the module queries, such as `AzureActivity` in 05-01 |
| `licensing` | string | State gaps plainly — see §7 |
| `azure_resources` | list | ARM types |
| `lab_cost_estimate` | string | Drives the cost chip — see §6 |
| `free_practice_available` | bool | Can this be practised at no cost |
| `objective_ids` | list | Exam lessons only: the stable ids from `data/objectives/` for exactly this lesson's bullets — **validated** |

---

## 4. Voice and explanation

**The problem before the product.** `## The administrative problem` must be
readable by someone who has never used Azure. Name the operational requirement,
then the service that meets it. If the first sentence contains a Microsoft product
name, rewrite it.

**One analogy per lesson, in its place.** The `## Mental model` section carries the
lesson's analogy and its everyday-idea to Azure-name table. Don't add others
elsewhere: an analogy that needs its own explanation is worse than the plain
mechanism.

**Say the thing.** Prefer "the exam will use this" to "it is worth being aware
that". No "in this module we will explore". No filler transitions.

**Bold carries load.** Bold the claim a reader must not miss — typically one per
section. If a page has thirty bold phrases, none of them work.

**Tables over prose for comparisons.** Any "X versus Y" gets a table, or an entry in
`data/comparisons.json`. Appendix A2 is organised entirely this way because the exam is.

**Second person for instructions, third for mechanism.** "You assign the role";
"the storage firewall evaluates the request before authorization does".

---

## 5. GUI and PowerShell parity

Every lab part that can be done both ways shows both:

```markdown
### Method A - Portal
### Method B - PowerShell
```

**Portal-only is acceptable in exactly two cases**, and you must say which:

1. **The command line can't do it reliably.** Microsoft documents that budgets
   created with PowerShell don't send notifications, so lab 00-01 creates its budget
   in the portal and says why in the step itself:

   > Create the budget in the **portal**. Microsoft documents that budgets created
   > with PowerShell don't send notifications.

2. **The cmdlet surface is unstable.** Say so, and tell the reader to check
   `Get-Help <cmdlet> -Parameter *` against their installed module version.

**Never invent a cmdlet.** If you are not certain a parameter exists, either verify
it or route the step through the portal and say why in the step itself.

**Resolve identifiers at runtime.** No hardcoded GUIDs for role definitions,
subscriptions or tenants — look them up by display name. There is no literal GUID
in this repository.

---

## 6. Cost

**Every lab states its cost in the header**, and the `lab_cost_estimate` front
matter drives the colour chip on the site. The parser reads the prose, so use these
words:

| Contains | Chip | Use for |
| --- | --- | --- |
| `$0` or `free` | green `$0` | Directory objects only, or no billable resource |
| `Low` | muted green | Pennies |
| `Medium` | ochre | Real but small |
| `High` (incl. `Medium-High`) | brick | Several hours of metered compute, such as lab 05-02 |
| `Highest` | deep brick | Reserved. No AZ-104 lab uses it |

**Anything that bills hourly gets a callout.** State it in the header, name the
meter, and list it in `metered` in `data/exam.js` so the cost planner flags it:

> **This lab has an hourly meter.** Complete **Module 0B** first, so your budget alert
> exists. Every VM here is tagged `az104-module = 03-02`, so its cost shows under that
> tag in cost analysis.

**Build cheap things first.** Virtual networks, NSGs, storage — then the VM or the
App Service plan last, so its meter runs for the shortest possible time. Deallocate
VMs between parts.

### Teardown: the six buckets

Every lab's `## Teardown` uses this structure, from `content/00-lab-safety/00-02`:

1. **Resources** — verify the context and the resource group's contents first, then
   locks this lab created, then the resource group, and anything that must go first
   (Site Recovery replication, backup protection)
2. **Subscription scope** — policy assignments, role assignments, subscription
   diagnostic settings
3. **Directory scope** — users, groups and guests, and any tenant-wide setting
   restored to the value you recorded
4. **Soft-deleted remains** — backup items held by soft delete, and deleted users
   (restorable for 30 days)
5. **Access** — the roles you gave your working account for this lab
6. **Verify** — a `- [ ]` checklist of commands that prove it, plus a Cost
   Management check

**Name what the teardown script cannot see.** `Remove-LabResourceGroup.ps1` sees the
lab resource group and resources tagged with the lab's module id. It knows nothing
about what Azure creates elsewhere on your behalf: connection monitors in
`NetworkWatcherRG`, Site Recovery's `*-asr` resource groups, restore points in
`AzureBackupRG*`, or backup items held by soft delete. If your lab creates one,
bucket 1 or 6 says so explicitly.

---

## 7. Preview status and licensing gaps

**Set `status: Preview`** if any sub-objective depends on a preview feature, and
open the module with a callout telling the reader to re-verify. No AZ-104 lesson is
currently in preview. The verification watchlist (`#/preview`) lists every file by
the age of its `last_verified`, so the oldest are re-checked first.

**State licensing gaps plainly.** Almost all of AZ-104 needs only an Azure
subscription and Microsoft Entra ID Free. Where a part needs more, the lab header
says which parts and which licence, as 01-01 does:

> **Licensing required:** Microsoft Entra ID Free for Parts 1, 2, 3 and 5. Part 4
> needs any licence to assign. Part 2b needs Entra ID P1.

Licence-gated parts are marked in their headings, such as **(P1)**, and are never
items in the validation checklist, so a learner without the licence can still
finish the lab honestly.

---

## 8. Dated changes and exam notes

When a product changed in a way that makes older material wrong — a rename, a
retired module, a setting that moved — say so in a blockquote opening with
**`Dated change.`** (with the date) or **`Exam note.`** The site colours both as exam
callouts. Microsoft Entra ID is the current name; mention Azure AD only to say it was
renamed.

---

## 9. Links

**Internal links are relative `.md` paths.** `assets/js/app.js` rewrites them into
hash routes using `manifest.json`, so they work both on GitHub and on the site:

```markdown
See [01-02 lab](../../labs/01-identities-governance/01-02-lab.md).
Covered in [00-02](../00-lab-safety/00-02-teardown-checklist-template.md).
```

A relative link the site cannot resolve renders with a dotted underline and a
tooltip naming the bad path — so serving the site is itself a link check.

**External links are autolinks** in Sources blocks (`<https://...>`) and inline
markdown links elsewhere. The site opens them in a new tab automatically.

---

## 10. Quizzes

One file per module at `quizzes/<module-id>.json`, kept separate from prose so
editing a question never touches content.

```json
{
  "module": "01-01",
  "schema": 1,
  "questions": [{
    "id": "01-01-q1",
    "sub_skill": "Create users and groups",
    "prompt": "...",
    "options": ["...", "..."],
    "answer": 1,
    "explanation": "Why this is right, and what the distractors are testing.",
    "why_not": [null, "Why option B is weaker", "..."],
    "clue": "\"phrase from the scenario\": what it points to."
  }]
}
```

- `sub_skill` **must quote a verbatim sub-objective** from that module's front
  matter. It is the join between a wrong answer and what to re-read.
- `answer` is a zero-based index, or an array for multiple response.
- Options are presented in file order, never shuffled, so explanations can refer
  to them.
- `explanation` says why the correct answer is correct **and** what the distractors
  are testing. An explanation that only restates the answer is not finished.
- `why_not` explains each wrong option in place (null for correct ones). A
  distractor must be wrong for a real conceptual reason, never because it is
  absurd.
- `clue` names the **scenario clue**: the phrase in the prompt that decides the
  answer, and what it points to. The validator requires it.
- Original scenarios only. Never exam dumps, recalled questions or leaked material.
- Reasoning, not recall.
