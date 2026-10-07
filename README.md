<h1 align="center">AZ-104 Academy</h1>

<p align="center">
  A free, beginner-first and certification-first study site for<br>
  <b>Microsoft Exam AZ-104: Microsoft Azure Administrator</b><br>
  (Microsoft Certified: Azure Administrator Associate)
</p>

<h3 align="center">
  <a href="https://ironbranded.github.io/AZ104-Academy/" target="_blank" rel="noopener noreferrer">
    🟢 TRY THE ACADEMY 🟢
  </a>
</h3>

---

## What it is

The Academy has one purpose: help you pass AZ-104 by understanding Azure administration, not by memorizing
product names or portal blades. Each topic moves you up the same ladder:

1. *"I don't know what this Azure resource is."*
2. *"I understand why it exists."*
3. *"I understand how it relates to the other resources."*
4. *"I can configure and manage it."*
5. *"I can validate it and troubleshoot it."*
6. *"I can choose the right Azure solution in an AZ-104 scenario."*

AZ-104 measures whether you can implement, manage and monitor an organization's Azure environment:
identities and governance, storage, compute, virtual networking, and monitoring, backup and recovery. The
official **skills measured** list decides what the Academy teaches. **Beginner-first instruction** decides
how it's taught: every lesson starts with the administrative problem and plain English, and only then
configures, validates and asks the exam question.

## Who it's for

- **New to Azure?** Start with Module 0A. Thirteen short primers cover the ideas the exam lessons assume
  (tenants, subscriptions, networking, storage, monitoring, Resource Manager) at the depth AZ-104 needs.
  You don't need to take AZ-900 first.
- **Already work with Azure?** Skip Module 0A from the dashboard and go straight to Module 0B and the
  exam domains.
- **Everyone** needs an Azure subscription for the labs, and the labs create real, billable resources.
  Module 0B shows you how to keep that cheap and tidy.

## A study route

1. **Module 0A · Understanding Azure** (optional): the primers.
2. **Module 0B · Safe lab foundations** (do this before any lab): your lab subscription and naming,
   a budget alert, and the teardown habit.
3. **Domains 1 to 5, lesson by lesson.** For each lesson: read it, work through the Microsoft Learn
   modules it lists, do the lab (validate the result, then tear it down), take the knowledge check, and
   explain it back in your own words.
4. **Domain review** at the end of each domain: the distinctions, a mixed question set, and what needs
   another look.
5. **Exam prep** in the last weeks: *Needs review*, the retention review, the mock exam, and Microsoft's
   free practice assessment.

## Using it with Microsoft Learn

Microsoft's official course is **[AZ-104T00-A: Microsoft Azure Administrator](https://learn.microsoft.com/en-us/training/courses/az-104t00)**,
a set of self-paced learning paths:

- [AZ-104: Prerequisites for Azure administrators](https://learn.microsoft.com/en-us/training/paths/az-104-administrator-prerequisites/)
- [AZ-104: Manage identities and governance in Azure](https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/)
- [AZ-104: Implement and manage storage in Azure](https://learn.microsoft.com/en-us/training/paths/az-104-manage-storage/)
- [AZ-104: Deploy and manage Azure compute resources](https://learn.microsoft.com/en-us/training/paths/az-104-manage-compute-resources/)
- [AZ-104: Configure and manage virtual networks for Azure administrators](https://learn.microsoft.com/en-us/training/paths/az-104-manage-virtual-networks/)
- [AZ-104: Monitor and back up Azure resources](https://learn.microsoft.com/en-us/training/paths/az-104-monitor-backup-resources/)

The **[AZ-104 study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104)**
lists the skills measured. Microsoft Learn teaches each product in depth; the Academy keeps you pointed at the
exam: which objective you're on, how the resources depend on each other, what's easy to confuse, and whether
you can configure and prove it. Every lesson lists the Microsoft Learn modules that cover it and the
documentation pages it was checked against.

## Alignment

- Built on the **AZ-104 skills measured as of April 17, 2026**: all **82** official bullets across **5**
  domains and **15** functional groups, each owned by exactly one lesson. Re-checked against the live study
  guide on 2026-10-07: still the current version ([curriculum audit](docs/CURRICULUM-AUDIT-2026-10-06.md)).
- Facts, commands and portal steps come from Microsoft Learn and the Azure documentation; each lesson lists
  its sources and the date it was last verified.
- Lessons teach generally available behavior, and say so when something is in preview.

## Curriculum

### Module 0A · Understanding Azure

Short primers for anyone new to Azure. Not exam objectives; skip any you already know.

| Primer | Topic |
| --- | --- |
| 0A-01 | [Cloud computing and datacenters](https://ironbranded.github.io/AZ104-Academy/#/module/0A-01) |
| 0A-02 | [Azure regions and availability](https://ironbranded.github.io/AZ104-Academy/#/module/0A-02) |
| 0A-03 | [Tenants, subscriptions and resource groups](https://ironbranded.github.io/AZ104-Academy/#/module/0A-03) |
| 0A-04 | [Azure resources and resource providers](https://ironbranded.github.io/AZ104-Academy/#/module/0A-04) |
| 0A-05 | [Identity, authentication and authorization](https://ironbranded.github.io/AZ104-Academy/#/module/0A-05) |
| 0A-06 | [Virtual machines and virtualization](https://ironbranded.github.io/AZ104-Academy/#/module/0A-06) |
| 0A-07 | [Networking: IP addresses, subnets, routing and DNS](https://ironbranded.github.io/AZ104-Academy/#/module/0A-07) |
| 0A-08 | [Storage and persistent data](https://ironbranded.github.io/AZ104-Academy/#/module/0A-08) |
| 0A-09 | [Monitoring: metrics and logs](https://ironbranded.github.io/AZ104-Academy/#/module/0A-09) |
| 0A-10 | [Backup, recovery and resilience](https://ironbranded.github.io/AZ104-Academy/#/module/0A-10) |
| 0A-11 | [Azure Resource Manager](https://ironbranded.github.io/AZ104-Academy/#/module/0A-11) |
| 0A-12 | [Portal, Cloud Shell, PowerShell, Azure CLI, ARM and Bicep](https://ironbranded.github.io/AZ104-Academy/#/module/0A-12) |
| 0A-13 | [How Azure resources fit together](https://ironbranded.github.io/AZ104-Academy/#/module/0A-13) |

### Module 0B · Safe lab foundations

Not exam content, but do it before any lab: choosing the subscription and region, naming and tagging,
least-privilege access, a budget alert, cost categories, and a teardown you verify before and after deleting.

| Lesson | Topic | Lab |
| --- | --- | --- |
| 00-00 | [Your lab subscription and conventions](https://ironbranded.github.io/AZ104-Academy/#/module/00-00) | — |
| 00-01 | [Budgets and cost alerts](https://ironbranded.github.io/AZ104-Academy/#/module/00-01) | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/00-01) |
| 00-02 | [Teardown and verification](https://ironbranded.github.io/AZ104-Academy/#/module/00-02) | — |

### Domain 1 · Manage Azure identities and governance (20–25%)

| Lesson | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [01-01](https://ironbranded.github.io/AZ104-Academy/#/module/01-01) | Manage Microsoft Entra users and groups | Create users and groups, manage their properties and licenses, manage external users, configure self-service password reset | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/01-01) |
| [01-02](https://ironbranded.github.io/AZ104-Academy/#/module/01-02) | Manage access to Azure resources | Manage built-in Azure roles, assign roles at different scopes, interpret access assignments | 3 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/01-02) |
| [01-03](https://ironbranded.github.io/AZ104-Academy/#/module/01-03) | Manage Azure subscriptions and governance | Use Azure Policy, resource locks, tags, resource groups, subscriptions and management groups; manage costs with alerts, budgets and Azure Advisor | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/01-03) |

### Domain 2 · Implement and manage storage (15–20%)

| Lesson | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [02-01](https://ironbranded.github.io/AZ104-Academy/#/module/02-01) | Configure access to storage | Configure storage firewalls and virtual networks, SAS tokens, stored access policies, access keys, and identity-based access for Azure Files | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/02-01) |
| [02-02](https://ironbranded.github.io/AZ104-Academy/#/module/02-02) | Configure and manage storage accounts | Create and configure storage accounts, redundancy, object replication and encryption; manage data with Storage Explorer and AzCopy | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/02-02) |
| [02-03](https://ironbranded.github.io/AZ104-Academy/#/module/02-03) | Configure Azure Files and Azure Blob Storage | Configure file shares, containers, access tiers, soft delete, Azure Files snapshots, blob lifecycle management and versioning | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/02-03) |

### Domain 3 · Deploy and manage Azure compute resources (20–25%)

| Lesson | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [03-01](https://ironbranded.github.io/AZ104-Academy/#/module/03-01) | Automate deployment by using ARM templates or Bicep files | Interpret, modify and deploy ARM templates and Bicep files; export a deployment and convert ARM to Bicep | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-01) |
| [03-02](https://ironbranded.github.io/AZ104-Academy/#/module/03-02) | Create and configure virtual machines | Create VMs, configure encryption at host, move VMs, manage sizes and disks, use availability zones and sets, deploy scale sets | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-02) |
| [03-03](https://ironbranded.github.io/AZ104-Academy/#/module/03-03) | Provision and manage containers in the Azure portal | Manage Azure Container Registry, provision Container Instances and Container Apps, manage their sizing and scaling | 4 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-03) |
| [03-04](https://ironbranded.github.io/AZ104-Academy/#/module/03-04) | Create and configure Azure App Service | Provision and scale App Service plans, create apps, configure TLS and certificates, custom DNS names, backup, networking and deployment slots | 8 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-04) |

### Domain 4 · Implement and manage virtual networking (15–20%)

| Lesson | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [04-01](https://ironbranded.github.io/AZ104-Academy/#/module/04-01) | Configure and manage virtual networks in Azure | Configure virtual networks, subnets, peering, public IP addresses and user-defined routes; troubleshoot connectivity | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/04-01) |
| [04-02](https://ironbranded.github.io/AZ104-Academy/#/module/04-02) | Configure secure access to virtual networks | Configure NSGs and application security groups, evaluate effective security rules, implement Azure Bastion, service endpoints and private endpoints | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/04-02) |
| [04-03](https://ironbranded.github.io/AZ104-Academy/#/module/04-03) | Configure name resolution and load balancing | Configure Azure DNS and internal or public load balancers; troubleshoot load balancing | 3 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/04-03) |

### Domain 5 · Monitor and maintain Azure resources (10–15%)

| Lesson | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [05-01](https://ironbranded.github.io/AZ104-Academy/#/module/05-01) | Monitor resources in Azure | Interpret metrics, configure and query logs, set up alert rules, action groups and alert processing rules, use Insights, Network Watcher and Connection monitor | 6 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/05-01) |
| [05-02](https://ironbranded.github.io/AZ104-Academy/#/module/05-02) | Implement backup and recovery | Create Recovery Services and Backup vaults, configure backup policies, back up and restore, configure Site Recovery and fail over, use backup reports and alerts | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/05-02) |

### Appendices

| Appendix | What it's for |
| --- | --- |
| [A1 · Exam information](https://ironbranded.github.io/AZ104-Academy/#/appendix/a1) | What Microsoft publishes about the exam, and which version of the skills measured applies to you |
| [A2 · Choosing between similar options](https://ironbranded.github.io/AZ104-Academy/#/appendix/a2) | The "which one?" decisions the exam is built on: each with its deciding question and the nearly-right trap |

## Inside every exam lesson

Each lesson follows one sequence, so you always know where you are:

| Stage | What you get |
| --- | --- |
| **Understand** | The administrative problem, the idea in plain English, the words you need, a mental model, and *where it fits*: what contains the resource, what it depends on, what depends on it, who manages it, and how it's networked, monitored, protected, recovered, billed and removed |
| **Learn** | How it works, and how to configure and manage it, with portal, PowerShell and Azure CLI where each applies |
| **Validate** | How to prove the configuration did what you intended |
| **Distinguish** | Side-by-side comparisons with the services it's confused with, common failure points, and the **AZ-104 Exam Lens** |
| **Practice** | The hands-on lab |
| **Check** | A knowledge check: original scenario questions, each explaining the correct answer, why the others are weaker, the scenario clue and the official objective; then *Teach it back* |
| **Review** | Key takeaways and what to study next |

All questions are written from the documentation. The Academy never uses exam dumps or recalled exam questions.

## About the labs

- **One lab subscription, used for nothing else.** Lesson 00-00 explains the subscription, region, naming
  and tagging conventions every lab follows. Each lab builds in its own resource group, `rg-az104-lab-<id>`.
- **Cost up front.** Every lab states its cost tier (free, low, medium or high) and names any hourly meter at
  the top. The [cost planner](https://ironbranded.github.io/AZ104-Academy/#/cost) lists every lab by cost.
- **An alarm, not a limit.** Lab 00-01 sets a budget alert on your subscription. A budget never stops
  spending, so the real control is the teardown at the end of every lab.
- **Validation before completion.** Each lab ends with a checklist of results you must observe, not steps
  you clicked, and then a teardown checklist: verify what you're about to delete, delete it, then prove it's gone.
- **Walkthroughs where hands-on isn't reasonable.** A few parts that a single lab subscription can't
  sensibly support are labeled as walkthroughs. The ARM and Bicep lab ships working templates and worked
  solutions.

## Study tools

| Tool | What it's for |
| --- | --- |
| [Dashboard](https://ironbranded.github.io/AZ104-Academy/#/) | What to study next, and for each domain how many objectives you've studied, practiced, validated and knowledge-checked |
| [Readiness](https://ironbranded.github.io/AZ104-Academy/#/readiness) | The sub-objectives you missed in knowledge checks, lessons not yet studied (heaviest domains first), and unfinished labs |
| [Domain reviews](https://ironbranded.github.io/AZ104-Academy/#/domain/01) | An end-of-domain summary, the key distinctions, a mixed question set, and what needs another look |
| [Exam prep](https://ironbranded.github.io/AZ104-Academy/#/prep) | Questions by domain or objective, the ones you got wrong or haven't tried, and lessons marked *Review later* |
| [Mock exam](https://ironbranded.github.io/AZ104-Academy/#/exam) | A timed set sampled across every lesson and weighted by the official domain percentages |
| [Flashcards](https://ironbranded.github.io/AZ104-Academy/#/cards) | Spaced repetition over the distinctions the exam tests |
| [Retention review](https://ironbranded.github.io/AZ104-Academy/#/review) | Which knowledge checks are due for a re-test, lesson by lesson |
| [Resource map](https://ironbranded.github.io/AZ104-Academy/#/map) | How the resources you administer contain and depend on each other |
| [Compare options](https://ironbranded.github.io/AZ104-Academy/#/compare) | Every structured comparison in one place, filterable by domain |
| [Glossary](https://ironbranded.github.io/AZ104-Academy/#/glossary) | Every term the lessons define, in plain English, with the lesson that teaches it |
| [Objective coverage](https://ironbranded.github.io/AZ104-Academy/#/coverage) | Every official bullet, with the lesson, lab and questions that cover it |
| [Cost planner](https://ironbranded.github.io/AZ104-Academy/#/cost) | Every lab ordered by cost, with its hourly meters |
| [Content freshness](https://ironbranded.github.io/AZ104-Academy/#/freshness) | When each lesson was last checked against Microsoft Learn |

## Progress

Five states, tracked separately. None of them is a pass prediction, and there's no readiness score.

| State | Means |
| --- | --- |
| **Studied** | You marked the lesson studied. |
| **Practised** | You finished the lab, including its teardown checklist. |
| **Validated** | You ticked every check in the lab's validation checklist, each one a result you observed. |
| **Knowledge checked** | You answered the lesson's questions correctly on their latest attempt. |
| **Retained** | You answered them correctly again at least seven days later. |

Progress is stored only in your browser. Export it from the dashboard to move it between devices.

## Before exam day

- Check which version of the skills measured applies to you. Microsoft updates the English exam first and
  localized versions about eight weeks later; appendix A1 explains how to tell.
- A score of **700 or greater** passes. It's a scaled score, so it isn't the same as 70% of the questions.
- Try Microsoft's [exam sandbox](https://aka.ms/examdemo) to see the exam interface, and take the free
  [AZ-104 practice assessment](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-104/practice/assessment?assessment-type=practice&assessmentId=21).
- Associate certifications expire annually. You renew with a free online assessment on Microsoft Learn.

## Running it locally

It's a static GitHub Pages site with no build step: every page is Markdown and JSON fetched at runtime by a
hash router. Serve the folder rather than opening `index.html` from disk:

```powershell
python -m http.server 8080
# then open http://localhost:8080/
```

## Feedback and contributing

Found something wrong or out of date? Open an issue with the lesson id and the Microsoft Learn page that
disagrees. To change content, read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) and
[docs/STYLE-GUIDE.md](docs/STYLE-GUIDE.md). A lab that leaves something unsafe or billable behind is a
security report: see [SECURITY.md](SECURITY.md).

## License

Code is under the [MIT License](LICENSE). Lessons, diagrams and lab instructions are under
[Creative Commons Attribution 4.0](LICENSE-CONTENT).

AZ-104 Academy is an independent study resource. It isn't affiliated with or endorsed by Microsoft.
