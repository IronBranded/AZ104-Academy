# Style Guide

The conventions this repository actually follows. Every rule here is descriptive
rather than aspirational — it was extracted from the 22 modules and 5 appendices
after they were written, so a new module that follows this guide will look like
the existing ones.

If you disagree with a rule, change it here first, then change the content. A
convention that lives only in one author's head is not a convention.

---

## 1. Sourcing

**Microsoft Learn is the only source of factual content.** Product documentation,
the AZ-104 study guide, and Microsoft Learn training modules. Nothing else.

Third-party material — courses, blogs, practice-question vendors, forum posts —
may be used **only** to sanity-check structure and emphasis: *is this topic
weighted the way I think it is?* It is never the source of a claim. While writing
the SC-500 guide this engine came from, four prep sites were found contradicting
each other and the official page on an exam's duration and question count. That is the failure mode this
rule exists to prevent.

**Every module ends with a Sources block** listing the specific pages it draws
from, as inline autolinks:

```markdown
## Sources

- Microsoft Learn - AZ-104 skills measured: <https://learn.microsoft.com/...>
- Azure Firewall rule processing logic: <https://learn.microsoft.com/azure/firewall/rule-processing>
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
- Short exact strings that matter — a cmdlet, a plan name, an alert name such as
  `AI.Azure_CredentialTheftAttempt`, a policy element — are quoted as code.

---

## 2. Structure

### Two files per objective

| File | Answers |
| --- | --- |
| `content/<domain>/<id>-<slug>.md` | Why this control exists and how it works |
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

**Foundation primer (Module 0A):** `## The problem`, `## In plain English`,
`## Words you need to know`, `## Mental model`, `## Where this shows up in AZ-104`,
`## Check yourself`, `## Teach it back`, `## Key takeaways`, `## Sources`. Primers
teach prerequisite knowledge only to the depth an AZ-104 lesson needs, stay
skippable, and never turn into AZ-900.

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

All eighteen keys are required on every content file; `Test-GuideContent.ps1`
fails the build otherwise. Empty is fine; missing is not.

| Key | Type | Notes |
| --- | --- | --- |
| `objective` | string | Verbatim from the study guide |
| `sub_objectives` | list | Verbatim. Empty list for appendices |
| `domain` | string | Must match `manifest.json` |
| `domain_weight` | string | `20-25%`, `25-30%`, or `n/a` — **validated** |
| `status` | `GA` \| `Preview` | **Validated.** Use `Preview` if any sub-objective is preview |
| `prerequisites` | list of module ids | Rendered as links in the field card |
| `ms_learn_source` | url | The study guide |
| `product_docs` | list of urls | The pages you actually read |
| `last_verified` | `YYYY-MM-DD` | **Validated**; warns after 60 days |
| `portal` | string | Where the work happens |
| `powershell_module` | string | Comma-separated; rendered as code chips |
| `az_cli_command` | string | One representative command, or empty |
| `kql_tables` | list | Tables the module teaches |
| `licensing` | string | State gaps plainly — see §7 |
| `azure_resources` | list | ARM types |
| `lab_cost_estimate` | string | Drives the cost chip — see §6 |
| `free_practice_available` | bool | Can this be practised at no cost |
| `forensic_relevance` | string | What this control means in an investigation |

`forensic_relevance` is not decoration. It is the one field that makes this guide
different from a certification cram, and it should say something an investigator
would care about — usually what evidence exists, or fails to.

---

## 4. Voice and explanation

**First principles before product names.** The `Why this exists` section should be
readable by someone who has never used Azure. Name the threat or failure mode, then
the control. If the first sentence contains a Microsoft product name, rewrite it.

**One analogy at most, and only if it pays its way.** An analogy that needs its own
explanation is worse than the plain mechanism. Most modules have none.

**Say the thing.** Prefer "the exam will use this" to "it is worth being aware
that". No "in this module we will explore". No filler transitions.

**Bold carries load.** Bold the claim a reader must not miss — typically one per
section. If a page has thirty bold phrases, none of them work.

**Tables over prose for comparisons.** Any "X versus Y" gets a table. The glossary
(A3) is organised entirely this way because the exam is.

**Second person for instructions, third for mechanism.** "You assign the role";
"the firewall evaluates DNAT rules first".

---

## 5. GUI and PowerShell parity

Every lab part that can be done both ways shows both:

```markdown
### Method A - Portal
### Method B - PowerShell
```

**Portal-only is acceptable in exactly two cases**, and you must say which:

1. **The cmdlet surface is unstable.** Recovery Services immutability, Defender
   plan extensions, Foundry model deployment. Say so and tell the reader to check
   `-Syntax`:

   > Immutability state and MUA wiring are portal-driven above because the cmdlet
   > surface for them moves between `Az.RecoveryServices` and `Az.DataProtection`
   > versions.

2. **No cmdlet exists.** Sample alerts, some Defender configuration.

**Never invent a cmdlet.** If you are not certain a parameter exists, either verify
it or route the step through the portal and say why. Every such flag is also logged
in appendix A1 §6.

**Resolve identifiers at runtime.** No hardcoded GUIDs for role definitions,
permission scopes, or authentication strengths — look them up by display name. The
only literal GUID in this repository is the Microsoft Graph application ID.

---

## 6. Cost

**Every lab states its cost in the header**, and the `lab_cost_estimate` front
matter drives the colour chip on the site. The parser reads the prose, so use these
words:

| Contains | Chip | Use for |
| --- | --- | --- |
| `$0` or `free` | green `$0` | M365-only, or no billable resource |
| `Low` | muted green | Pennies |
| `Medium` | ochre | Real but small |
| `HIGH` (incl. `Medium-HIGH`) | brick | Hourly meters |
| `HIGHEST` | deep brick | Security Copilot |

**Anything that bills hourly gets a clock.** State it in the header, tell the
reader to start a timer when provisioning completes, and build the free parts
first:

> **Start a timer when the firewall finishes deploying.** Deployment takes 10-20
> minutes and billing starts the moment it lands, not when you start testing.

**Build cheap things first.** Firewall policies, VNets, storage — then the metered
resource last, so its clock runs for the shortest possible time.

### Teardown: the six buckets

Every lab's `## Teardown` uses this structure, from `content/00-lab-safety/00-03`:

1. **Resources** — the resource group, and anything expensive deleted *first*
2. **Subscription scope** — Defender plans, policy assignments, role assignments
3. **Directory scope** — app registrations, CA policies, groups, consent grants
4. **Soft-deleted remains** — vaults, workspaces, sites, app registrations
5. **Access** — deactivate PIM, discard credentials
6. **Verify** — commands that prove it, plus a Cost Management check

**Name what the teardown script cannot see.** It knows nothing about Bastion hosts,
Azure Firewalls, `MC_*` node resource groups, orphaned disks, Sentinel connectors,
or Security Copilot capacity. If your lab creates one, bucket 1 or 6 says so
explicitly.

---

## 7. Preview status and licensing gaps

**Set `status: Preview`** if any sub-objective depends on a preview feature, and
open the module with a callout telling the reader to re-verify. 03-02 is the
worked example.

**State licensing gaps plainly and give a written deliverable instead.** Three
objectives cannot be fully built on the stated M365 E5 lab tenant. None of them is
skipped or glossed:

> **Licensing gate.** Conditional Access for agents requires **Microsoft Agent 365**
> licensing per user on top of Entra ID P1/P2. Microsoft 365 E5 provides neither.

The lab then splits into *build-if-licensed* and *design-if-not*, where the design
output is the same prose the exam asks for anyway.

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
See [01-02 lab](../../labs/01-identity-access-governance/01-02-lab.md).
Covered in [00-03](../00-lab-safety/00-03-teardown-checklist-template.md).
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
    "sub_skill": "Implement and configure managed identities for Azure resources",
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
