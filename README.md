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

## Alignment

- Aligned to the **AZ-104 skills measured as of April 17, 2026**: all **82** official bullets, across
  5 domains and 15 functional groups.
- Every lesson is built from Microsoft Learn documentation and lists its sources.
- Lessons teach generally available behavior; anything in preview is labeled as preview.
- Microsoft updates the English exam first and localized versions about eight weeks later. The
  Academy's exam-info page explains which outline applies to you.

## Content

Each exam module covers one official functional group. Every module has a lesson, a hands-on lab, a
knowledge check, comparisons and flashcards: **212 questions** and **216 flashcards** in total.

### Module 0 · Lab safety

A prerequisite, not an exam objective. Do it before any lab.

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

- **Lesson.** Follows one sequence: Orient → Learn → Visualize → Distinguish → Practice → Check →
  Review. Diagrams appear where a relationship is easier to see than to read, such as scope
  inheritance, NSG evaluation order, load balancer anatomy and the Site Recovery lifecycle. Each
  lesson ends with an Exam Lens: what the exam is likely to test, and the traps.
- **Lab.** States its cost tier up front (free, low, medium or high) and ends with a mandatory
  teardown. Parts that a lab subscription can't reasonably support, such as identity-based access
  for Azure Files or customer-managed keys, are labeled as walkthroughs. The ARM and Bicep lab ships
  with working templates and worked solutions.
- **Knowledge check.** Questions mapped to the module's objectives, with every answer explained.
- **Comparisons.** Side-by-side "which option?" tables for the services and settings the exam asks
  you to tell apart.
- **Flashcards.** The distinctions worth memorizing.

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
| [Objective coverage](https://ironbranded.github.io/AZ104-Academy/#/coverage) | Every official bullet, with the lesson, lab and questions that cover it. |
| [Cost planner](https://ironbranded.github.io/AZ104-Academy/#/cost) | Every lab ordered by cost, so you know what you can afford to run. |
| [Verification watchlist](https://ironbranded.github.io/AZ104-Academy/#/preview) | Lessons that cover preview features or are due for a fresh check against the documentation. |

Your progress is stored only in your browser.
