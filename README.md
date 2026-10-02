# AZ104 Academy

A certification-first, interactive study site for **Microsoft Exam AZ-104: Microsoft
Azure Administrator**. Every lesson is built from Microsoft Learn documentation and
mapped to the official **skills measured as of April 17, 2026**.

Static, dependency-free, and deployed with GitHub Pages. Your progress stays in your
own browser.

## Status

Every official outline bullet is covered. Nothing is published as covered until it is written, sourced and
validated.

| Area | Status |
| --- | --- |
| Module 0: lab safety (overview, cost guardrails, teardown checklist) | Written, with the budget and compute-brake lab |
| 01-01 Microsoft Entra users and groups | Written: lesson, free lab, 10-question check, comparisons, flashcards |
| 01-02 Azure role-based access control | Written: lesson with scope diagram, free lab, 10-question check, comparisons, flashcards |
| 01-03 Subscriptions and governance | Written: lesson with inheritance diagram, free lab, 16-question check, comparisons, flashcards |
| 02-01 Configuring access to storage | Written: lesson with access-method decision diagram, low-cost lab (Azure Files identity is a walkthrough), 15-question check, comparisons, flashcards |
| 02-02 Storage accounts | Written: lesson with redundancy map, low-cost lab (customer-managed keys are a walkthrough), 15-question check, comparisons, flashcards |
| 02-03 Azure Files and Blob Storage | Written: lesson with tier and rehydration diagram, low-cost lab, 14-question check, comparisons, flashcards |
| 03-01 ARM templates and Bicep | Written: lesson with template-lifecycle diagram, low-cost lab with CI-tested templates and solutions, 15-question check, comparisons, flashcards |
| 03-02 Virtual machines | Written: lesson with availability decision diagram, medium-cost lab (hourly meter, brake-tagged, scale set with zero instances), 16-question check, comparisons, flashcards |
| 03-03 Containers | Written: lesson with container services diagram, low-cost lab (both managed-identity pull paths), 12-question check, comparison, flashcards |
| 03-04 Azure App Service | Written: lesson with plans-apps-slots diagram, medium-cost lab (B1, then S1 for slots and autoscale), 16-question check, comparisons, flashcards |
| 04-01 Virtual networks | Written: lesson with peering non-transitivity diagram, medium-cost lab (one VM, four VNets), 14-question check, comparisons, flashcards |
| 04-02 Secure access to virtual networks | Written: lesson with NSG evaluation diagram, medium-cost lab (free Bastion Developer, DNS public-to-private), 15-question check, comparisons, flashcards |
| 04-03 Name resolution and load balancing | Written: lesson with load balancer anatomy diagram, medium-cost lab (no Bastion: run-command), 12-question check, comparisons, flashcards |
| 05-01 Monitoring resources | Written: lesson with alert pipeline diagram, medium-cost lab (alert + processing rule, KQL, Connection monitor), 18-question check, comparisons, flashcards |
| 05-02 Backup and recovery | Written: lesson with Site Recovery lifecycle diagram, high-cost lab (backup, restore, alerts, test failover) with an order-critical teardown, 14-question check, comparisons, flashcards |

**All five domains are complete.** Coverage today: **82 of 82** official outline bullets. The site's Objective coverage page
shows exactly which, and the validator reports the rest as planned.

## How to study with it

Each lesson follows the same sequence: **Orient → Learn → Visualize → Distinguish →
Practice → Check → Review**. The dashboard tells you what to study next, and tracks
three things separately for each official objective:

- **Studied:** you marked the lesson studied.
- **Practised:** you completed its lab *and* confirmed teardown.
- **Knowledge checked:** every question on that objective answered, and the latest
  attempt on each was correct.

There is deliberately no readiness percentage. Start with **Module 0** before creating
anything billable.

## Run it locally

The site fetches its content, so it must be served rather than opened from disk:

```powershell
cd C:\Users\<you>\AZ104-Academy
python -m http.server 8080
# then open http://localhost:8080/
```

## Lab safety and cost

Labs create real Azure resources and real Microsoft Entra objects. Before any lab:

- Use a **lab tenant and subscription**, never production. Some Entra settings, such as
  self-service password reset, apply to every user in the tenant.
- Complete **Module 0**: a budget with alerts, an action group, and a runbook that
  deallocates tagged lab VMs when the budget is hit.
- Every lab ends with a **six-part teardown**. The dashboard keeps a reminder until you
  confirm it. Deleting the resource group is not enough; the checklist explains why.

A budget is a notification, not a spending cap. Teardown discipline is the real control.

## Repository layout

| Path | Purpose |
| --- | --- |
| `data/exam.js` | Exam identity: code, names, outline version, domain labels and icons, storage prefix |
| `data/objectives/` | The 82 official objectives, verbatim, with stable semantic ids and owner modules |
| `docs/SKILLS-MEASURED-SNAPSHOT.md` | The official outline as captured, the drift baseline |
| `content/` | Lessons and appendices, plus `manifest.json`, which defines the site's structure |
| `labs/` | One lab per lesson: steps, validation, teardown |
| `quizzes/`, `flashcards/` | Knowledge checks tagged to objectives; the distinctions deck |
| `scripts/` | The compute brake runbook and the teardown script |
| `assets/` | The engine: plain HTML, CSS and JavaScript. It hardcodes no exam details |
| `tools/`, `.github/workflows/` | Validator, accessibility check, outline-drift check |

## Checks

```powershell
pwsh ./tools/Test-GuideContent.ps1
```

The validator checks front matter, lesson and lab structure, quiz integrity, links, the
objectives data against the snapshot, and two engine rules: no domain colour outside
`assets/css/tokens.css`, and no storage key that isn't built from the exam's prefix.
CI runs it on every push, runs an axe-core accessibility check in both themes, compiles and lints
every lab Bicep file and decompiles every lab ARM template (`tools/check-templates.sh`), and compares
the live study guide against the snapshot weekly.

## Sourcing rules

Microsoft Learn is the only source of factual content. Where a fact can't be verified —
a default value, a licence requirement Microsoft no longer states, an exam's length —
the lesson leaves it out and says so rather than guessing.

## Relationship to SC500 Academy

The engine comes from [SC500 Academy](https://github.com/IronBranded/SC500-Academy).
The content does not: all SC-500 material was removed. The two sites share a GitHub
Pages origin, so their browser storage and offline caches are namespaced separately
(`az104:` keys, `az104-` caches).

## Licence

Code: MIT (`LICENSE`). Prose, diagrams and lab instructions: CC BY 4.0
(`LICENSE-CONTENT`). Not affiliated with or endorsed by Microsoft.
