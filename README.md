<h1 align="center">AZ-104 Academy</h1>

<p align="center">
  A certification-first, interactive study site for
  <b>Microsoft Exam AZ-104: Microsoft Azure Administrator</b>.
</p>

<h3 align="center">
  <a href="https://ironbranded.github.io/AZ104-Academy/" target="_blank" rel="noopener noreferrer">
    🟢 TRY THE ACADEMY🟢
  </a>
</h3>

---

## Objective

The Academy has one job: help you pass AZ-104. Everything in it exists to help you:

1. **Understand** each AZ-104 objective.
2. **Remember** the concepts behind it.
3. **Distinguish** similar services, settings and controls.
4. **Choose** the right configuration in an exam-style scenario.
5. **Perform** the configuration in a hands-on lab.
6. **Read, modify and deploy** ARM templates and Bicep files.
7. **Find** your weak areas.
8. **Review** efficiently before the exam.

AZ-104 is an administrator exam: it measures whether you can implement, manage and monitor an Azure
environment. The official skills measured list defines the scope. Architecture design, security
engineering, and services outside the outline, such as VPN Gateway, ExpressRoute, Azure Firewall, AKS
and Terraform, are not taught.

It's **beginner-first in how it explains Azure** and **certification-first in what it teaches**. Every
lesson starts with the administrative problem, explains it in plain English, shows how the resource
relates to the others, and only then configures it, validates it and asks the exam question. You don't
need to know Azure already; you do need to work through it.

## Alignment

- Aligned to the **AZ-104 skills measured as of April 17, 2026**: all **82** official bullets, across
  5 domains and 15 functional groups. Re-checked against the live study guide on 2026-10-06: no drift
  ([audit](docs/CURRICULUM-AUDIT-2026-10-06.md)).
- Every lesson is built from Microsoft Learn documentation and lists its sources.
- Lessons teach generally available behavior; anything in preview is labeled as preview.
- Microsoft updates the English exam first and localized versions about eight weeks later. The
  Academy's exam-info page explains which outline applies to you.

## Content

Each exam module covers one official functional group. Every module has a lesson, a hands-on lab, a
knowledge check, comparisons and flashcards: **212 questions**, each with a scenario clue, and **216
flashcards** in total.

### Module 0A · Understanding Azure

Short primers for anyone new to Azure: the prerequisite ideas the exam lessons assume, at the depth
AZ-104 needs and no deeper. Not exam objectives. Skip them if you already know this; the dashboard
lets you.

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

A prerequisite, not an exam objective. Do it before any lab: subscription and region choice, naming
and tagging, budget alerts, least-privilege access, and a teardown you verify.

| Module | Lesson | Lab |
| --- | --- | --- |
| 00-00 | [Lab topology and conventions](https://ironbranded.github.io/AZ104-Academy/#/module/00-00) | — |
| 00-01 | [Cost guardrails and budget alerts](https://ironbranded.github.io/AZ104-Academy/#/module/00-01) | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/00-01) |
| 00-02 | [Reusable teardown checklist](https://ironbranded.github.io/AZ104-Academy/#/module/00-02) | — |

### Domain 1 · Manage Azure identities and governance (20–25%)

| Module | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [01-01](https://ironbranded.github.io/AZ104-Academy/#/module/01-01) | Manage Microsoft Entra users and groups | Create users and groups, manage their properties and licenses, manage external users, configure self-service password reset | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/01-01) |
| [01-02](https://ironbranded.github.io/AZ104-Academy/#/module/01-02) | Manage access to Azure resources | Manage built-in Azure roles, assign roles at different scopes, interpret access assignments | 3 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/01-02) |
| [01-03](https://ironbranded.github.io/AZ104-Academy/#/module/01-03) | Manage Azure subscriptions and governance | Use Azure Policy, resource locks, tags, resource groups, subscriptions and management groups; manage costs with alerts, budgets and Azure Advisor | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/01-03) |

### Domain 2 · Implement and manage storage (15–20%)

| Module | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [02-01](https://ironbranded.github.io/AZ104-Academy/#/module/02-01) | Configure access to storage | Configure storage firewalls and virtual networks, SAS tokens, stored access policies, access keys, and identity-based access for Azure Files | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/02-01) |
| [02-02](https://ironbranded.github.io/AZ104-Academy/#/module/02-02) | Configure and manage storage accounts | Create and configure storage accounts, redundancy, object replication and encryption; manage data with Storage Explorer and AzCopy | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/02-02) |
| [02-03](https://ironbranded.github.io/AZ104-Academy/#/module/02-03) | Configure Azure Files and Azure Blob Storage | Configure file shares, containers, access tiers, soft delete, Azure Files snapshots, blob lifecycle management and versioning | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/02-03) |

### Domain 3 · Deploy and manage Azure compute resources (20–25%)

| Module | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [03-01](https://ironbranded.github.io/AZ104-Academy/#/module/03-01) | Automate deployment by using ARM templates or Bicep files | Interpret, modify and deploy ARM templates and Bicep files; export a deployment and convert ARM to Bicep | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-01) |
| [03-02](https://ironbranded.github.io/AZ104-Academy/#/module/03-02) | Create and configure virtual machines | Create VMs, configure encryption at host, move VMs, manage sizes and disks, use availability zones and sets, deploy scale sets | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-02) |
| [03-03](https://ironbranded.github.io/AZ104-Academy/#/module/03-03) | Provision and manage containers in the Azure portal | Manage Azure Container Registry, provision Container Instances and Container Apps, manage their sizing and scaling | 4 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-03) |
| [03-04](https://ironbranded.github.io/AZ104-Academy/#/module/03-04) | Create and configure Azure App Service | Provision and scale App Service plans, create apps, configure TLS and certificates, custom DNS names, backup, networking and deployment slots | 8 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/03-04) |

### Domain 4 · Implement and manage virtual networking (15–20%)

| Module | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [04-01](https://ironbranded.github.io/AZ104-Academy/#/module/04-01) | Configure and manage virtual networks in Azure | Configure virtual networks, subnets, peering, public IP addresses and user-defined routes; troubleshoot connectivity | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/04-01) |
| [04-02](https://ironbranded.github.io/AZ104-Academy/#/module/04-02) | Configure secure access to virtual networks | Configure NSGs and application security groups, evaluate effective security rules, implement Azure Bastion, service endpoints and private endpoints | 5 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/04-02) |
| [04-03](https://ironbranded.github.io/AZ104-Academy/#/module/04-03) | Configure name resolution and load balancing | Configure Azure DNS and internal or public load balancers; troubleshoot load balancing | 3 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/04-03) |

### Domain 5 · Monitor and maintain Azure resources (10–15%)

| Module | Official functional group | You'll be able to | Bullets | Lab |
| --- | --- | --- | --- | --- |
| [05-01](https://ironbranded.github.io/AZ104-Academy/#/module/05-01) | Monitor resources in Azure | Interpret metrics, configure and query logs, set up alert rules, action groups and alert processing rules, use Insights, Network Watcher and Connection monitor | 6 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/05-01) |
| [05-02](https://ironbranded.github.io/AZ104-Academy/#/module/05-02) | Implement backup and recovery | Create Recovery Services and Backup vaults, configure backup policies, back up and restore, configure Site Recovery and fail over, use backup reports and alerts | 7 | [Lab](https://ironbranded.github.io/AZ104-Academy/#/lab/05-02) |

## Inside every module

- **Lesson.** One teaching sequence: **Orient → Understand → Learn → Validate → Distinguish →
  Practice → Check → Review**. *Understand* comes first: the administrative problem, the idea in plain
  English, the words you need, a mental model with a diagram, and *where it fits*, the ten questions
  every resource answers (what contains it, what it depends on, what depends on it, who manages it,
  and how it's networked, monitored, protected, recovered, billed and removed). Then how it works,
  how to configure it, a worked example, how to **validate** the result, the comparisons and failure
  modes, and the **Exam Lens**. Each lesson ends with *Teach it back*: explain it without notes.
- **Lab.** Starts with why it matters and the desired state, and states its cost tier (free, low,
  medium or high). It ends with a **validation checklist** of results you must observe and a mandatory,
  verified **teardown**. Parts that a lab subscription can't reasonably support are labeled as
  walkthroughs. The ARM and Bicep lab ships with working templates and worked solutions.
- **Knowledge check.** Original scenario questions mapped to the module's objectives. Every answer
  shows the correct answer, why, why not the others, the **scenario clue**, and the official objective.
- **Comparisons.** Structured side-by-side comparisons (purpose, scope, layer, when to use, key
  difference, limitation, dependency, how to validate, AZ-104 takeaway), plus the "which option?"
  tables in appendix A6.
- **Flashcards.** The distinctions worth memorizing.
- **Official training.** The Microsoft Learn modules from course AZ-104T00-A that cover the lesson.

## Study tools

| Tool | What it's for |
| --- | --- |
| [Dashboard](https://ironbranded.github.io/AZ104-Academy/#/) | What to study next, and for each domain how many objectives you have studied, practiced and knowledge-checked. No readiness score and no pass prediction. |
| [Readiness](https://ironbranded.github.io/AZ104-Academy/#/readiness) | Your next steps, computed from your quiz history. |
| [Domain reviews](https://ironbranded.github.io/AZ104-Academy/#/domain/01) | An end-of-domain summary, the key distinctions, a mixed question set, and what needs another look. |
| [Exam prep](https://ironbranded.github.io/AZ104-Academy/#/prep) | Questions by domain or objective, the ones you got wrong, the ones you haven't tried, and lessons marked *Review later*. |
| [Mock exam](https://ironbranded.github.io/AZ104-Academy/#/exam) | A timed, weighted exam sampled across every module. |
| [Flashcards](https://ironbranded.github.io/AZ104-Academy/#/cards) | Spaced repetition over the distinctions the exam tests. |
| [Retention review](https://ironbranded.github.io/AZ104-Academy/#/review) | What has faded and what to re-test, module by module. |
| [Resource map](https://ironbranded.github.io/AZ104-Academy/#/map) | How the resources you administer contain and depend on each other, with the ten questions answered for each one. |
| [Compare options](https://ironbranded.github.io/AZ104-Academy/#/compare) | Every structured comparison in one place, filterable by domain. |
| [Glossary](https://ironbranded.github.io/AZ104-Academy/#/glossary) | Every term the lessons define, in plain English, with the lesson that teaches it. |
| [Objective coverage](https://ironbranded.github.io/AZ104-Academy/#/coverage) | Every official bullet, with the lesson, lab and questions that cover it. |
| [Cost planner](https://ironbranded.github.io/AZ104-Academy/#/cost) | Every lab ordered by cost, so you know what you can afford to run. |
| [Verification watchlist](https://ironbranded.github.io/AZ104-Academy/#/preview) | Lessons that cover preview features or are due for a fresh check against the documentation. |

## Progress

Five states, tracked separately, and none of them is a pass prediction:

| State | Means |
| --- | --- |
| **Studied** | You marked the lesson studied. |
| **Practised** | You finished the lab, including its verified teardown. |
| **Validated** | You ticked every check in the lab's validation checklist, each one a result you observed. |
| **Knowledge checked** | You answered the lesson's questions correctly on their latest attempt. |
| **Retained** | You answered them correctly again at least seven days later. |

Your progress is stored only in your browser. Export it from the dashboard to move it between devices.

## Running it

It's a static GitHub Pages site with no build step: every page is Markdown and JSON fetched at
runtime by a hash router. To preview locally, serve the folder (`python -m http.server 8080`) rather
than opening `index.html` from disk.
