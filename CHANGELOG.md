# Changelog

Notable changes to AZ104 Academy, newest first. Content corrections that change a
factual claim are listed with the lesson id. Routine `last_verified` bumps are not.

## [Unreleased] - Beginner-first, certification-first pass (2026-10-06)

The Academy now teaches the infrastructure before it expects you to administer it. Full record:
[docs/CURRICULUM-AUDIT-2026-10-06.md](docs/CURRICULUM-AUDIT-2026-10-06.md).

### Objective validation

- Re-retrieved the study guide through the Microsoft Learn MCP server. *Skills measured as of April
  17, 2026* is still current, and a mechanical diff of all 82 bullets, five weights and fifteen
  functional groups found no drift. Every existing lesson, lab and question is classified CURRENT.

### Added

- **Module 0A, Understanding Azure:** 13 short, skippable primers, from cloud computing and regions
  to Resource Manager, the admin tools, and how resources fit together. Each one ends with where it
  shows up in AZ-104. The dashboard recommends it first and lets experienced learners skip it.
- **Lesson anatomy** on all 15 exam lessons: *The administrative problem*, *In plain English*,
  *Words you need to know*, *Mental model* (with a diagram and an everyday-to-Azure translation),
  *Where it fits* (the ten relationship questions), *Worked example*, *Validate the result* and
  *Teach it back*. Lessons now run Orient, Understand, Learn, Validate, Distinguish, Practice, Check,
  Review.
- **Resource map** (`#/map`): 21 resources, each answering what contains it, what it depends on,
  what depends on it, who manages it, and how it's networked, monitored, protected, recovered,
  billed and removed. Data: `data/resources.json`.
- **Comparisons** (`#/compare`, and inside lessons): 12 structured comparisons with purpose, scope,
  layer, when to use, key difference, limitation, dependency, how to validate, and the AZ-104
  takeaway. Data: `data/comparisons.json`.
- **Glossary** (`#/glossary`): 207 terms, built from the lessons' own *Words you need to know*
  tables, so a term is defined once.
- **Scenario clues** on all 212 questions: the phrase that decides the answer.
- **Progress:** *Validated* (the lab's validation checklist is ticked) and *Retained* (questions
  answered correctly again at least 7 days after first being right), shown in lesson headers and
  domain cards.
- **Labs:** *Why this matters*, *The desired state*, a validation checklist of observed results,
  *What just happened?*, and a teardown checklist on every lab.
- **Official training:** course AZ-104T00-A and all six Microsoft Learn learning paths with their
  modules, retrieved through the Microsoft Learn MCP server and shown on the lessons they serve.
- Module 0B (00-00): choosing the subscription and the region.
- `tools/smoke-test.js`: a headless check that every route renders without errors.

### Fixed

- Labs could be marked *practised* with a single click; 15 of 16 had no checklist.
- The lab card told learners to activate roles through PIM, contradicting lesson 00-00.
- The sidebar rendered only the last non-exam domain.
- Lab checklist items inside wrapped sections were never recorded as validation checks.
- The validator crashed on non-numeric module ids.

### Validator

- Requires the new lesson, primer and lab sections, a validation and a teardown checklist in every
  lab, a scenario clue on every question, and resolvable ids in the comparison and resource data.

## Phase 16: module 05-02 (all 82 outline bullets covered)

### Final verification (2026-10-02)

- **Outline drift:** the live study guide still shows *Skills measured as of April 17, 2026* (page updated
  2026-03-19). A mechanical diff of its 82 bullets against `data/objectives/` matched exactly, verbatim and in order.
- **Integrity:** 18 modules, 212 questions, 216 flashcards. No duplicate IDs; every bullet has at least one question;
  every quiz `sub_skill` is an objective of its module; every card points at a real module. Answer positions:
  A 57, B 54, C 53, D 48.
- **Coverage page:** 82 covered, 0 partial, 0 missing.
- **Validator:** PASS, no errors or warnings. **Template check:** clean. **axe:** 33 routes x 2 themes, 0 violations.

### Known gaps

- `content/official-training.json` is deliberately empty: official AZ-104 Microsoft Learn training paths haven't been
  mapped and verified, so the site hides that panel.
- The coverage page counts objectives whose module has a lab. It doesn't yet distinguish walkthrough-only lab parts
  (Azure Files identity, customer-managed keys, region moves, dedicated Bastion, custom domains), which each lab labels.
- Master prompt sections 12 to 35 haven't been received; their requirements aren't assessed here.

### Added

- Module 05-02, Backup and recovery: Recovery Services and Backup vaults, redundancy and Cross Region Restore, soft
  delete, Standard and Enhanced VM policies, restore options, Site Recovery replication and failover (with a lifecycle
  diagram), and backup alerts and reports.
- Lab (**high cost**, the Academy's most expensive): vault redundancy set before protection; an Enhanced policy created
  but not assigned; on-demand backup; file recovery walkthrough; restore disks with the generated template; built-in
  backup alerts routed by an alert processing rule; backup reports through vault diagnostic settings; Site Recovery
  replication and a test failover into an isolated VNet. A real failover is optional.
- **Order-critical teardown:** soft delete is disabled **before** backup data is deleted. Otherwise the vault can't be
  deleted for 14 days. That step fires a Sev 0 security alert, which the lab uses as its alert example.
- `data/exam.js` `metered` lists 05-02. 14-question check, two A6 comparisons, 15 flashcards.

### Content notes

- Dated changes taught: classic Azure Backup alerts were deprecated on March 31, 2026.
- The validator's "planned" warning is now gone: all 82 bullets have written modules.

## Phase 15: module 05-01 (Domain 5 begins)

### Added

- Module 05-01, Monitoring resources: what's collected automatically versus configured, metrics explorer
  (aggregation, splitting, retention), diagnostic settings and workspace retention and table plans, KQL, alert
  rule types, action groups and alert processing rules (with an alert pipeline diagram), VM, storage and network
  Insights, and Network Watcher with Connection monitor.
- Lab (**medium cost**): activity log and blob resource logs to a workspace; VM insights; metrics with splitting; a
  CPU alert that fires and resolves, then is **suppressed** by an alert processing rule while still being recorded;
  KQL across four tables; a connection monitor broken by an outbound NSG deny and recovered. The teardown explicitly
  removes the **connection monitor** (it lives in NetworkWatcherRG), the **subscription** diagnostic setting and the
  VM insights DCR, none of which a resource group deletion removes.
- `data/exam.js` `metered` lists 05-01. 18-question check, two A6 comparisons, 14 flashcards.

### Content notes

- Dated changes taught: the Log Analytics agent was retired in August 2024; the VM insights Map and Dependency agent
  retire on June 30, 2028; Connection monitor (classic) is deprecated.

### Fixed (inherited from the SC500 engine)

- **Code comments failed WCAG AA contrast in the dark theme.** The syntax token `--syn-comment` (`#8a8886`) measured
  4.38:1 on the code background. It surfaced only when KQL `//` comments produced comment tokens. Now `#979593`
  (5.19:1). A full axe run across all 32 routes in both themes passes.

## Phase 14: module 04-03 (Domain 4 complete)

### Added

- Module 04-03, Name resolution and load balancing: public zones and delegation, record sets, alias records,
  private zones with registration and resolution links, Standard Load Balancer components (with an anatomy
  diagram), public versus internal, and troubleshooting with Data Path Availability and Health Probe Status.
- Lab (**medium cost**), with **no Bastion**: commands run through `az vm run-command`. VMs auto-register in a
  private zone; Python serves a page per VM; a Standard load balancer stays closed until an NSG allows client
  traffic; an alias A record at the apex of a test zone; then a probe blocked by an NSG (found with effective
  rules) and a backend that stops listening.
- `data/exam.js` `metered` lists 04-03. 12-question check, two A6 comparisons, 13 flashcards.

### Content notes

- Because new virtual networks have private subnets by default, lab VMs can't install packages. The lab uses
  Ubuntu's built-in Python, started as a transient systemd unit, rather than nginx.

## Phase 13: module 04-02

### Added

- Module 04-02, Secure access to virtual networks: NSG rules, default rules and evaluation order (with a
  diagram), application security groups, effective security rules and IP flow verify, Azure Bastion SKUs,
  service endpoints, and private endpoints with private DNS.
- Lab (**medium cost**): free Bastion Developer used **before** any NSG exists, so no rule can lock the learner
  out; DNS resolution stays public with a service endpoint and turns private with a private endpoint; then subnet
  and NIC NSGs with an ASG, tested with IP flow verify (denied by the NIC's default rule until both allow) and
  effective security rules. Dedicated Bastion SKUs are a walkthrough.
- `data/exam.js` `metered` lists 04-02. 15-question check, two A6 comparisons, 15 flashcards.

### Content notes

- No source address is documented for Bastion Developer's shared infrastructure, so the lab orders its parts to
  avoid needing an NSG rule for it, rather than guessing one.
- The NSG diagram's first version passed every automated check but rendered illegibly: Mermaid laid its two
  subgraphs side by side and shrank the text. It was rebuilt as two vertical chains and checked visually.

## Phase 12: module 04-01 (Domain 4 begins)

### Added

- Module 04-01, Virtual networks: subnets and the five reserved addresses, peering (states, overlap,
  non-transitivity, sync, gateway transit), Standard public IPs, user-defined routes and route
  selection, and Network Watcher's troubleshooting tools. Includes a non-transitivity diagram.
- Lab (**medium cost**, one small VM): Initiated → Connected peering, a refused overlapping peering,
  effective routes showing no path to a spoke's spoke, next hop before and after UDRs (None, then a
  more specific virtual appliance route), a peering sync after a resize, and a Standard public IP.
- `data/exam.js` `metered` lists 04-01.
- 14-question check, A6 comparisons 26-27, 16 flashcards (deck: 159).

### Content notes

- Dated changes taught: default outbound access (new VNets have private subnets by default, API versions
  after March 31, 2026), Basic public IP retirement (September 30, 2025), and NSG flow logs (no new
  creation after June 30, 2025; retirement September 30, 2027).

### Verification notes

- This module was written in a session whose history was later trimmed, and was verified separately
  before commit. Its dated and numeric claims were re-checked against Microsoft Learn: private-by-default
  subnets for new VNets on API versions after March 31, 2026 (existing VNets unchanged), NSG flow log
  dates (no new ones after June 30, 2025; retirement September 30, 2027), non-movable peered VNets, and
  Use remote gateways on one peering only. The Basic public IP retirement note now flags the separate
  VPN gateway timeline. (verified after a session gap)

## Phase 11: module 03-04 (Domain 3 complete)

### Added

- Module 03-04, Azure App Service: plans and tiers (what each tier unlocks), scale up versus scale out,
  autoscale and automatic scaling, custom domains and their DNS records, certificates and TLS bindings,
  automatic and custom backups, access restrictions, private endpoints and VNet integration, and
  deployment slots with sticky settings. Includes a plans-apps-slots diagram.
- Lab (**medium cost**): a B1 plan for TLS settings, backups, access restrictions (the implicit deny) and
  VNet integration; scaled to S1 only for slots (swap with preview, sticky versus travelling settings)
  and rule-based autoscale. Custom domains and managed certificates are a walkthrough unless the learner
  owns a domain.
- `data/exam.js` `metered` lists 03-04.
- 16-question check, A6 comparisons 24-25, 16 flashcards (deck: 143).

### Content notes

- Dated changes taught: custom backups stop supporting linked databases on March 31, 2028.
- "Autoscale needs Standard" is stated from Microsoft's scale-up guidance and tier limits. Automatic
  scaling (Premium v2 and higher) is taught as a separate feature with its own maximum burst.

## Phase 10: module 03-03

### Added

- Module 03-03, Containers: Container Registry tiers and data-plane roles, Container Instances container
  groups (sizing, restart policies, volumes, what can't be updated), Container Apps (ingress, revisions,
  traffic splitting, scale rules and scale to zero), and an ACI-versus-Container-Apps comparison.
- Lab (low cost): a Basic registry with an imported image; ACI pulling through a **user-assigned**
  identity; a CPU change that is refused in place; a run-once task ending in Succeeded; a container app
  scaling to zero, then pulling through its **system-assigned** identity; revisions with an 80/20
  traffic split.
- `data/exam.js` `metered` lists 03-03 (registry per day, container groups per second).
- 12-question check, A6 comparison 23, 13 flashcards (deck: 127).

### Content notes

- The ACI image-pull identity rule (user-assigned only) comes from Microsoft's ACI troubleshooting
  guidance; the Container Apps system-assigned path from the Container Apps managed identity guide.

## Phase 9: module 03-02

### Added

- Module 03-02, Virtual machines: what a VM is made of, sizes and resizing, the five disk types and
  expansion rules, encryption at host (with the Azure Disk Encryption retirement), moving VMs,
  availability sets versus zones (with a decision diagram), and scale sets with autoscale.
- Lab (**medium cost**, the first with an hourly meter): a zonal B-series VM with encryption at host and
  no public IP; online disk expansion, a refused shrink, and a type change after deallocation; resizing;
  turning encryption at host off and on; moving the VM with its disks and NIC; an availability set the
  VM can't join; a Flexible scale set with **zero instances** and autoscale rules. Every VM is tagged for
  the Module 0 compute brake.
- `data/exam.js` `metered` now lists 03-02, so the cost planner flags it.
- 16-question check (answers spread 4/4/4/4), A6 comparisons 21-22, 17 flashcards (deck: 114).

### Content notes

- Two dated retirements are taught: Azure Disk Encryption (September 15, 2028) and Standard HDD as an OS
  disk (September 8, 2028).
- One draft question had autoscale limits that contradicted its own scenario; it was corrected before
  release.

## Phase 8: module 03-01 (Domain 3 begins)

### Added

- Module 03-01, ARM templates and Bicep: reading both languages side by side, modifying them,
  deployment scopes, modes and what-if, export, deployment history and decompile. Includes a
  template-lifecycle diagram.
- Lab templates in `labs/03-compute/templates/` (Bicep, `.bicepparam`, ARM JSON, a parameters file)
  with worked solutions. The lab deploys one small storage account, previews complete-mode deletion
  with and without a lock, exports the resource group, and has learners find four concrete
  differences between decompiled and hand-written Bicep.
- **Template CI:** `.github/workflows/bicep.yml` and `tools/check-templates.sh` build and lint every
  Bicep file, build every `.bicepparam`, and decompile every ARM template, with the Bicep CLI pinned
  to v0.47.16. A negative test confirmed that a broken Bicep file fails the check, along with the
  parameters file that uses it.
- 15-question check (template-reading items included), A6 comparisons 19-20, 15 flashcards (deck: 97).

### Content notes

- The implicit-dependency rule was **verified with the compiler**, not only from documentation:
  building a file whose container uses `parent:` produced the `dependsOn` chain in the JSON.
- The four decompile differences in the lab were observed from the actual decompiler output.

## Phase 7: module 02-03 (Domain 2 complete)

### Added

- Module 02-03, Azure Files and Blob Storage: file share billing models and tiers, containers and
  anonymous access levels, access tiers, archive rehydration (with a diagram), lifecycle management,
  blob and container soft delete, versioning, share snapshots and share soft delete.
- Lab (low cost): a protection matrix. Undelete doesn't restore the current version under
  versioning, then a version is promoted; a container is restored under its original name; a blob is
  archived and rehydrated; a lifecycle rule is checked for the re-archiving trap; a file comes back
  from a snapshot while the share comes back from soft delete.
- 14-question check, A6 comparisons 17-18, 17 flashcards (deck: 82).

### Content notes

- Lifecycle `prefixMatch` values start with the container name. A first draft of the lesson's example
  used a bare prefix and was corrected before release.
- The 10 GiB-per-hour limit is stated as Microsoft states it: a per-account limit on high-priority
  rehydration.

## Phase 6: module 02-02

### Added

- Module 02-02, Storage accounts: account types and naming, redundancy (with a redundancy map)
  and conversion paths, object replication, encryption (Microsoft-managed, customer-managed,
  customer-provided keys, encryption scopes, infrastructure encryption), AzCopy and Storage Explorer.
- Lab (low cost, two storage accounts): the RA-GRS secondary endpoint appearing, infrastructure
  encryption fixed at creation, encryption scopes, object replication defaults (existing blobs
  skipped, destination read-only with 409), AzCopy server-to-server copy and one-way sync.
  Customer-managed keys are a **walkthrough**: purge protection would leave an undeletable key vault.
- 15-question check, A6 comparisons 14-16, 16 flashcards (deck: 65).

### Content notes

- Object replication policies use the source account's **full resource ID**. New accounts disallow
  cross-tenant replication by default, and then a name alone is rejected.
- Encryption scope creation is done in the portal: the PowerShell switch for Microsoft-managed keys
  couldn't be confirmed against current documentation.

## Phase 5: module 02-01 (Domain 2 begins)

### Added

- Module 02-01, Configuring access to storage: the storage firewall (four rule types, IP rule
  restrictions, same-region behaviour), SAS types, stored access policies, access keys
  (rotation, expiration reminders, disallowing Shared Key), and Azure Files identity-based
  access. Includes a decision diagram for choosing an access method.
- Lab (low cost, one storage account): a revocation matrix across three SAS types, disallowing
  Shared Key, and a firewall that refuses a valid token. The Azure Files identity part is a
  **walkthrough**, since it needs a directory service.
- 15-question check, A6 comparisons 11-13 (which SAS, taking access back, which firewall rule),
  14 flashcards (deck: 49).

### Content notes

- The user delegation SAS is documented for **Blob, Queue, Table and Azure Files**. Older
  material says Blob only.
- A user delegation SAS never grants more than its signer can do. Contributor can request the
  delegation key through its wildcard, but without a data role the token reads nothing.
- The Azure CLI key-renewal syntax was left out: its `--key` values couldn't be confirmed
  against current documentation. The lesson uses `New-AzStorageAccountKey`.

## Phase 4: module 01-03 (Domain 1 complete)

### Added

- Module 01-03, Subscriptions and governance, covering all seven bullets: Azure Policy
  (effects, remediation, exclusions vs exemptions, evaluation timing), resource locks, tags,
  resource groups and moves, subscriptions and change directory, management groups, and
  costs with budgets and Advisor. Includes a hierarchy-inheritance diagram.
- Free lab: an inherit-tag policy remediates an existing resource; an Allowed locations deny
  at the target **blocks a move** (RequestDisallowedByPolicy); locks stop an Owner; exclusion
  versus exemption in the compliance report; management group creation and subscription move.
- 16-question knowledge check with answers spread evenly across positions.
- A6 comparisons 7-10: RBAC vs Policy vs locks; policy effects; exclusion vs exemption vs
  DoNotEnforce; what inherits down the hierarchy.
- 15 flashcards (deck: 35). Accessibility routes for 01-03.

### Fixed

- **Orphaned role assignments at resource-group scope were never found.** Five orphan checks
  (the 00-02 sweep, the 00-01 and 01-02 labs, and `Remove-LabResourceGroup.ps1`) called
  `Get-AzRoleAssignment -Scope /subscriptions/...`, which returns assignments at that scope
  and above only. They now list the whole subscription. The script came from the SC500
  engine, so SC500-Academy has the same limitation.

### Content notes

- Advisor's "underutilized VM" thresholds are deliberately not stated: two current Microsoft
  Learn pages give different criteria. The lesson teaches the configurable parts (lookback,
  CPU filter) instead.
- Resource-group regional-outage behaviour is not stated for the same reason. The lesson
  gives Microsoft's recommendation (keep resources and resource group in the same region).

## Phase 3: module 01-02

### Added

- Module 01-02, Azure role-based access control: lesson with a scope-hierarchy diagram,
  free lab (nested-group inheritance, Contributor vs access administrators, reading
  assignments with Check access, the CLI and PowerShell), 10-question knowledge check.
- A6 comparisons 4-6: which role manages and which grants access; Azure roles vs
  Microsoft Entra roles; where group nesting counts (RBAC and SSPR yes, group licensing no).
- 10 flashcards for 01-02 (deck: 20).
- Accessibility check route for 01-02.

### Content notes

- Role assignment limit stated as **5,000 per subscription** and 500 per management
  group, from current Microsoft Learn. Older material quotes 2,000 or 4,000.
- Classic subscription administrators are described as fully retired (May 2026).
- Custom roles appear only as labelled context: the current outline measures built-in
  roles, so no question or lab step depends on them.

## Phase 2: AZ-104 foundation and first module

Bootstrapped from SC500-Academy@9fa07ce (engine only). Outline targeted: skills measured
as of April 17, 2026, confirmed current on 2026-09-29.

### Added

- `data/exam.js`: all exam identity as data. The engine reads it; nothing AZ-104-specific
  is hardcoded in `assets/`.
- `data/objectives/az104-2026-04-17.json`: the 82 objectives verbatim, with stable
  semantic ids (`id.users.sspr`) and a planned owner module for each.
- `docs/SKILLS-MEASURED-SNAPSHOT.md`: the AZ-104 skills-measured section.
- Five-domain colour system. Networking magenta (`--d-04`) is new; its dark-theme values
  are computed (`#BF0077` is 2.88:1 on the dark background, below the 3:1 floor).
  Monitor & Maintain moved to `--d-05`.
- Module 01-01, Microsoft Entra users and groups: lesson, free lab, 10-question
  knowledge check, three A6 comparisons, 10 flashcards.
- Appendix A1, Exam information: outline version, localized-exam timing, scoring,
  renewal. Linked from a new dashboard badge, "Aligned to AZ-104 skills measured as of
  April 17, 2026".
- `scripts/00-lab-safety/Stop-LabCompute.ps1`: budget brake that deallocates tagged lab
  VMs and scale sets, and reports everything else without changing it.
- Validator checks: objectives data must match the snapshot; lesson `objective_ids`
  must match their bullets; no domain hex outside `tokens.css`; no literal storage keys.

### Changed

- All 19 `SC500*` globals renamed `Academy*`. Storage keys and cache names use the
  `az104` prefix.
- Module 0 adapted for AZ-104: PIM lesson removed (Entra ID P2, not in the outline);
  teardown checklist rewritten around AZ-104 traps (locks, Recovery Services vault soft
  delete, deallocated disks, tenant-wide Entra settings).
- Outline-drift workflow: reads the study-guide URL from `data/exam.js`, ignores line
  wrapping when comparing, and no longer polls the SC-500 practice-assessment sentence.
- Validator: a bullet owned by a module not yet written is a warning ("planned"); a
  bullet with no owner is still an error. `forensic_relevance` is optional.
- Accessibility check: AZ-104 routes, and the theme key read from `data/exam.js`.

### Fixed (inherited from the SC500 engine)

- Service worker deleted every cache not its own; Cache Storage is per origin, so it
  evicted other Academies' offline copies. It now deletes only `az104-` caches.
  **SC500-Academy still has this bug and needs the same one-line fix.**
- Lesson section labels were hard-tinted with specific domain colours (always Identity
  blue for "First principles"), and the strong colour failed 4.5:1 as text in dark mode.
  They now use the lesson's own domain ink.
- Heading anchors overwrote ids set by other components, leaving the Exam Lens
  `aria-labelledby` pointing at nothing.
- Tables built in JavaScript (coverage, objective status, exam prep) were scrollable but
  not keyboard-focusable (axe: scrollable-region-focusable).
- The teardown sweep filtered Entra role assignments by sign-in name instead of object id.

### Removed

- All SC-500 lessons, labs, quizzes, flashcards and appendices, and the SC-500
  official-training mapping (`content/official-training.json` is empty until the AZ-104
  learning paths are verified).
