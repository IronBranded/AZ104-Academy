---
objective: "(Appendix - not an AZ-104 exam objective)"
sub_objectives: []
domain: "Appendix"
domain_weight: "n/a"
status: GA
prerequisites: []
ms_learn_source: "https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104"
product_docs:
  - "https://learn.microsoft.com/en-us/entra/fundamentals/concept-learn-about-groups"
  - "https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b"
  - "https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-policy"
  - "https://learn.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles"
  - "https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged"
last_verified: "2026-09-30"
portal: ""
powershell_module: ""
az_cli_command: ""
kql_tables: []
licensing: ""
azure_resources: []
lab_cost_estimate: ""
free_practice_available: true
---

# Choosing Between Similar Options

> **Why this appendix exists.** The skills outline is organised by *service*, so this
> guide is too: one module per functional group. The exam is organised by *choice*. A
> question describes a requirement and offers options that could all plausibly satisfy
> something near it, and the mark goes to the one that satisfies exactly it.
>
> **This appendix is a cross-reference, not a source.** Every claim below is taught, with
> its Microsoft Learn citation, in the module named beside it. If this appendix and a
> module disagree, the module is right and this file has drifted: fix it here.
>
> It grows with the guide. Each new module adds the comparisons it owns.

## How to read each section

Each section is a question the exam asks in disguise. You get the comparison, then **the
trap**: the wrong answer that is attractive because it is *nearly* right. Cover the
right-hand column and explain each row out loud; that is the fastest review pass in the
repository.

---

## 1. Which group: type and membership

**Modules 01-01.**

| Option | Can contain | Membership | Choose it when |
| --- | --- | --- | --- |
| **Security group, assigned** | Users, devices, service principals, other groups | Added by hand | Resource access; any group that will hold Microsoft Entra roles |
| **Security group, dynamic** | Users *or* devices, never both | Rule on attributes; can't be edited by hand | Access or licensing that should follow department, country or device attributes |
| **Microsoft 365 group** | Users only, including guests | Assigned or dynamic user | Collaboration |

> **The trap.** *"Automatically include every device running Windows"* is never a
> Microsoft 365 group, dynamic or not: Microsoft 365 groups hold users only. And
> *"a group assigned a Microsoft Entra role, membership by department"* has no dynamic
> answer: role-assignable groups require assigned membership.

---

## 2. Guests: who can invite, and from where

**Modules 01-01.**

| Setting | Controls | Scope |
| --- | --- | --- |
| **External collaboration settings** | Who in your tenant can invite; which domains can be invited; what guests can see | Invitations from your tenant to anyone |
| **Cross-tenant access settings** | Inbound and outbound B2B with other Microsoft Entra organisations, per user, group and app; whether to trust their MFA and device claims | Other Microsoft Entra tenants |
| **Guest Inviter role** | Lets one user invite when invitations are limited to admin roles | One user |

> **The trap.** When the two settings sets disagree, it's tempting to look for which one
> "wins". Neither wins: **the most restrictive setting applies**. A domain on the external
> collaboration deny list can't be invited even if cross-tenant access allows that
> organisation.

---

## 3. Password reset: users, administrators, hybrid

**Modules 01-01.**

| Who | Policy that applies | What decides success |
| --- | --- | --- |
| **Cloud user in SSPR scope** | Your SSPR policy: one or two methods from the Authentication methods policy | Registered enough enabled methods; a licence that includes reset |
| **Any administrator role holder** | Fixed two-gate policy: two methods, no security questions | Can't be changed by your policy |
| **User synchronised from on-premises** | Your SSPR policy, plus writeback | Password writeback configured; P1/P2 or Microsoft 365 Business Premium |

> **The trap.** Testing SSPR with your own administrator account and concluding the user
> policy works, or doesn't. Administrators never follow the user policy. Test with a
> non-administrator.

---

## 4. Which role manages, and which grants access

**Modules 01-02.**

| Role | Manage resources | Assign Azure roles | Manage other access, such as Azure Policy |
| --- | --- | --- | --- |
| **Owner** | Yes | Yes | Yes |
| **Contributor** | Yes | No | No |
| **User Access Administrator** | Read only | Yes | Yes |
| **Role Based Access Control Administrator** | Read only | Yes | No |
| **Reader** | Read only | No | No |

> **The trap.** *"Manage everything but don't grant access"* tempts people towards Owner
> with a caveat. The answer is Contributor. And *"grant access, least privilege"* has two
> right-looking answers: Role Based Access Control Administrator when only role
> assignments are needed, User Access Administrator when the requirement includes other
> access management. None of the five reads data: that takes a data role.

---

## 5. Two authorization systems: Azure roles and Microsoft Entra roles

**Modules 01-01, 01-02.**

| | Azure roles (Azure RBAC) | Microsoft Entra roles |
| --- | --- | --- |
| Govern | Subscriptions and resources | Users, groups, licences, directory settings |
| Scopes | Management group, subscription, resource group, resource | Tenant, administrative unit, single object |
| Assigned in | Access control (IAM) | Microsoft Entra admin center |
| Example least-privilege answer | Virtual Machine Contributor on one resource group | User Administrator, Guest Inviter |

> **The trap.** Global Administrator is the most powerful Entra role and grants **no**
> access to Azure resources by default. The only bridge is **elevate access**, which gives
> that one user User Access Administrator at root scope until they turn it off.

---

## 6. Where group nesting counts

**Modules 01-01, 01-02.**

| Feature | Does a member of a nested group get it? |
| --- | --- |
| **Azure role assignment** to a group | **Yes.** Assignments are transitive through nested groups |
| **SSPR** scoped to one selected group | **Yes.** Nested groups are supported |
| **Group-based licensing** | **No.** Only first-level members get the licence |
| **Microsoft 365 group** | Not applicable: it can't contain groups at all |

> **The trap.** Learning "nesting works" from RBAC and applying it to licensing, or the
> reverse. The question usually shows a user two levels down and asks whether they got
> the thing. The answer depends entirely on which feature granted it.

---

## 7. RBAC, Policy or a lock?

**Modules 01-02, 01-03.**

| Control | Question it answers | Applies to | Stops an Owner? |
| --- | --- | --- | --- |
| **Azure RBAC** | *Who* may perform an action | The principal | It's what makes someone an Owner |
| **Azure Policy** | *What* may exist, and how it must be configured | The resource and request, whoever sends it | Yes, with `deny` |
| **Resource lock** | Whether it can be changed or deleted **at all** | Everyone and every role | **Yes** |

> **The trap.** "Prevent anyone, including administrators, from deleting the production
> resource group" isn't an RBAC answer: removing Owner doesn't stop other Owners. It's a
> **Delete lock**. And "prevent storage accounts without HTTPS-only" isn't a lock or a role:
> it's a **policy**.

---

## 8. Which policy effect

**Modules 01-03.**

| Effect | New or updated resources | Existing resources |
| --- | --- | --- |
| `audit` | Allowed, flagged non-compliant | Flagged non-compliant |
| `deny` | **Rejected** | Flagged non-compliant; **never changed** |
| `append` / `modify` | Changed at request time | `modify`: fixed by a **remediation task**; `append`: only when next updated |
| `auditIfNotExists` | Flagged if a related resource is missing | Flagged |
| `deployIfNotExists` | Related resource **deployed** | Fixed by a **remediation task** |

> **The trap.** Choosing `deny` to *fix* existing resources. `deny` only protects the future.
> Fixing the past takes `modify` or `deployIfNotExists` plus a remediation task, which runs
> as the assignment's managed identity.

---

## 9. Leaving something out of a policy

**Modules 01-03.**

| Option | Evaluated? | Shows in compliance? | Use when |
| --- | --- | --- | --- |
| **Exclusion** (`notScopes`) | No | No | The scope genuinely isn't meant to be governed by this assignment |
| **Exemption: Waiver** | No | Yes, as **Exempted** | Non-compliance is accepted for now; can expire |
| **Exemption: Mitigated** | No | Yes, as **Exempted** | The intent is met another way |
| **Enforcement mode `DoNotEnforce`** | Yes | Yes | Test the whole assignment without enforcing it |

> **The trap.** Using an exclusion when the requirement says the exception must be *tracked*
> or *reviewed*. Excluded resources disappear from the report; exempted ones stay visible.

---

## 10. What inherits down the hierarchy

**Modules 01-02, 01-03.**

| Setting | Inherited by child scopes? | Can be set on a management group? |
| --- | --- | --- |
| Role assignment | Yes | Yes |
| Policy assignment | Yes | Yes |
| Resource lock | Yes; the most restrictive wins | **No** |
| Tag | **No** | **No** |

> **The trap.** Assuming tags behave like the other three. They never inherit; an inherit-tag
> policy with the `modify` effect copies them.

---

## 11. Which shared access signature

**Modules 02-01.**

| SAS type | Signed with | Scope | Stored access policy? | Survives key rotation? |
| --- | --- | --- | --- | --- |
| **User delegation SAS** | User delegation key (Microsoft Entra) | Blob, Queue, Table or Azure Files resource; at most 7 days | No | **Yes** |
| **Service SAS** | Account key | One resource in one service | **Yes**: the only type that can use one | No |
| **Account SAS** | Account key | One or more services, including service-level operations | No | No |

> **The trap.** Reaching for a stored access policy with a user delegation or account SAS.
> Only a service SAS can reference one. And "work across Blob and Queue, including service
> properties" rules out both other types: that's an account SAS.

---

## 12. Taking access back

**Modules 02-01.**

| To revoke | Do this | Collateral damage |
| --- | --- | --- |
| A service SAS tied to a stored access policy | Delete or rename the policy, or set its expiry in the past | None beyond that policy's tokens |
| An ad hoc service or account SAS | **Regenerate the key** that signed it | Everything else using that key |
| A user delegation SAS | Revoke the account's user delegation keys, or remove the signer's roles | Every user delegation SAS on the account |
| All key-based access at once | Disallow Shared Key | Every key and key-signed SAS; Entra access keeps working |
| An Entra user's data access | Remove the data role assignment | None |

> **The trap.** Re-creating a deleted stored access policy with the **same name**: the old
> tokens come back to life. And a key *expiration policy* revokes nothing: it's a reminder.

---

## 13. Which storage firewall rule

**Modules 02-01.**

| Client | Rule |
| --- | --- |
| On-premises or internet client with a known **public** IPv4 | IP network rule |
| Azure VM or service in a **subnet** | Virtual network rule + `Microsoft.Storage` service endpoint on the subnet |
| Client in the **same Azure region** as the account | Virtual network rule: IP rules don't govern same-region traffic |
| A listed Azure service outside your networks, such as reading logs | Trusted service exception |
| A specific Azure resource instance that can't be isolated by network | Resource instance rule |

> **The trap.** Entering a private range such as `10.1.1.0/24` as an IP rule. It's rejected.
> Private addresses reach the account through a virtual network rule, or a private endpoint
> (module 04-02).

---

## 14. Which redundancy

**Modules 02-02.**

| Requirement | Choose |
| --- | --- |
| Lowest cost; losing one datacenter is acceptable | **LRS** |
| Survive the loss of an availability zone | **ZRS** |
| Survive a regional disaster (after failover) | **GRS** |
| Read the secondary copy at any time, no failover | **RA-GRS** |
| Zone **and** regional protection | **GZRS** (**RA-GZRS** to read the secondary) |
| Premium account | **LRS or ZRS only** |

> **The trap.** Picking GRS for "read during an outage". GRS's secondary isn't readable until
> failover; only the **RA-** variants are.

---

## 15. Three ways to copy blob data

**Modules 02-02.**

| Mechanism | Copies | Destination | Runs |
| --- | --- | --- | --- |
| **Geo-redundancy** (GRS, GZRS) | The whole account | The paired region, which you don't choose | Continuously, asynchronous |
| **Object replication** | Block blobs in chosen containers | An account you choose, any region | Continuously, asynchronous; destination read-only |
| **AzCopy** | Whatever you point it at | Anywhere | When you run it; server-to-server between accounts |

> **The trap.** Using GRS to put data in a *specific* region. The secondary is always the
> paired region. For a region you choose, use object replication or AzCopy.

---

## 16. Who holds the encryption key

**Modules 02-02.**

| Option | Key held by | Scope | Choose when |
| --- | --- | --- | --- |
| Microsoft-managed keys | Microsoft | Whole account (default) | No specific key requirement |
| **Customer-managed keys** | Your Key Vault or Managed HSM | Account, or per encryption scope | You must control and rotate the key |
| **Customer-provided keys** | The client, per request | Individual Blob operations | The client must supply its own key |
| **Infrastructure encryption** | Microsoft (a second key) | Whole account or scope, at creation | Compliance demands double encryption |

> **The trap.** Confusing **access keys** (they authorize requests, 02-01) with **encryption
> keys** (they protect data at rest). Rotating an access key changes nothing about encryption.

---

## 17. Which recovery feature

**Modules 02-03.**

| What was lost | Feature that recovers it |
| --- | --- |
| A deleted blob | Blob soft delete, or versioning (promote a version) |
| An overwritten blob | Versioning, or blob soft delete |
| A deleted container | **Container soft delete** only |
| A file or folder in an Azure file share | **Share snapshot** |
| A deleted Azure file share | **Share soft delete** |
| The storage account | None of the above: prevent it with a **lock** |

> **The trap.** Assuming a feature covers the level above or below it. Blob soft delete never
> restores a container, share soft delete never restores a file, and nothing inside an account
> survives deleting the account.

---

## 18. Which access tier

**Modules 02-03.**

| Tier | Minimum stay | Read latency | Choose when |
| --- | --- | --- | --- |
| Hot | — | Milliseconds | Active data |
| Cool | 30 days | Milliseconds | Infrequent access, must be immediate |
| Cold | 90 days | Milliseconds | Rare access, must still be immediate |
| Archive | 180 days | **Hours** (rehydrate first) | Rare access, hours of delay acceptable; LRS, GRS or RA-GRS only |

> **The trap.** Picking archive for data that is rarely read but must be available *immediately* when
> it is. Archive is offline; rarely-but-instantly is **cold** (or cool).

---

## 19. Incremental or complete

**Modules 03-01.**

| | Incremental (default) | Complete |
| --- | --- | --- |
| Resources in the template | Created or updated | Created or updated |
| Resources in the group, not in the template | **Left alone** | **Deleted** |
| Resources whose condition is false | Left alone | Deleted |
| Resource group has a Delete lock | — | Nothing is deleted |
| Microsoft's recommendation | Use it | Avoid it; use deployment stacks to delete |

> **The trap.** Reading "the template contains only what we want" as a reason to pick complete mode.
> Anything else in the resource group, VMs included, would be deleted. Always what-if first.

---

## 20. Where a template comes from

**Modules 03-01.**

| Need | Use | Output |
| --- | --- | --- |
| Describe resources as they exist **now** | Export template (resource group or resource) | ARM JSON; **Bicep in the portal only** |
| The **exact** template a past deployment used | Deployment history > Template | ARM JSON |
| Bicep from an existing ARM template | `bicep decompile` | Best-effort Bicep |
| ARM JSON from a Bicep file | `bicep build` | Equivalent ARM JSON |

> **The trap.** Treating an export as a finished template. It may omit passwords, use older API
> versions and hard-code names, and it fails above 200 resources.

---

## 21. VM availability options

**Modules 03-02.**

| Option | Protects against | SLA | Decided |
| --- | --- | --- | --- |
| **Availability set** | Rack failures and planned maintenance in one datacenter (up to 3 fault, 20 update domains) | 99.95% | **At VM creation**; existing VMs can't join |
| **Availability zones** | Loss of a datacenter or zone | **99.99%** across zones | At VM creation |
| **Scale set (Flexible)** | Spreads instances across fault domains or zones, and scales | Matches the spread used | Orchestration mode **at creation** |

> **The trap.** Combining them as if they stack: availability sets **don't support zones**. And "add
> the existing VM to the set" is never a configuration change: it's delete and re-create.

---

## 22. Which VM disk encryption

**Modules 03-02.**

| | Server-side encryption | Encryption at host | Azure Disk Encryption |
| --- | --- | --- | --- |
| On by default | **Yes** | No: register the feature, set per VM | No |
| Temporary disk and caches | No | **Yes** | Yes |
| Uses VM CPU | No | No | Yes |
| Change on an existing VM | — | **Deallocate first** | In the guest |
| Future | Always on | **Recommended for new VMs** | **Retires September 15, 2028** |

> **The trap.** Answering "encrypt the temp disk" with server-side encryption. SSE never covered the
> temp disk or caches; encryption at host does.

---

## 23. Container Instances or Container Apps

**Modules 03-03.**

| Need | Container Instances | Container Apps |
| --- | --- | --- |
| Run once, then stop | **Yes** (restart policy Never or OnFailure) | Jobs exist; ACI is simpler |
| Scale on HTTP, TCP or events | **No** rule-based scaling | **Yes**, including to zero |
| Release with traffic splitting | No | **Yes**: multiple revision mode |
| Change CPU or memory | **Delete and re-create** the group | Deploy a new revision |
| Pull from ACR with managed identity | **User-assigned only** | System- or user-assigned |

> **The trap.** Reaching for Container Instances when the requirement says "scale automatically" or
> "scale to zero". Those are Container Apps features.

---

## 24. Which App Service tier unlocks it

**Modules 03-04.**

| Feature | Lowest tier |
| --- | --- |
| Dedicated instances, manual scale out (up to 3) | **Basic** |
| Custom domain with **SNI** TLS binding, free managed certificate | **Basic** |
| Automatic and custom **backups** | **Basic** (production slot only in Basic) |
| **VNet integration** (outbound) | **Basic** |
| **Deployment slots** (5) and **rule-based autoscale** (up to 10) | **Standard** |
| **IP-based** TLS binding | **Standard** |
| **Automatic scaling** (HTTP, no rules), up to 30 | **Premium v2** |
| Network isolation, up to 100 instances | **Isolated v2** |

> **The trap.** Choosing Standard for "custom domain with HTTPS at the lowest cost". Basic already
> supports SNI bindings and the free managed certificate.

---

## 25. App Service networking: in or out

**Modules 03-04.**

| Requirement | Feature | Direction |
| --- | --- | --- |
| Only certain IPs or subnets may reach the app | **Access restrictions** (implicit deny once a rule exists) | Inbound, public endpoint |
| The app must be reachable privately from a VNet | **Private endpoint** (then disable public access) | Inbound |
| The app must call resources inside a VNet | **VNet integration** | **Outbound** |
| The app must call an on-premises endpoint without a VPN | Hybrid connection | Outbound |

> **The trap.** Answering "make the app private" with VNet integration. Integration only lets the app
> call **out** into the network. Private inbound access is a private endpoint, and private-endpoint
> traffic isn't subject to access restrictions.

---

## 26. Which route wins

**Modules 04-01.**

| Step | Rule |
| --- | --- |
| 1 | **Longest prefix match**: a `/24` beats a `/16` for an address in both |
| 2 | Same prefix: **user-defined** > **BGP** > **system** |
| 3 | System routes for the virtual network, peerings and service endpoints are preferred over more specific BGP routes; **service endpoint routes can't be overridden** |

> **The trap.** Assuming user-defined routes always win. They win only on a tie of prefix length.
> A more specific system or BGP route still beats a broader user-defined one.

---

## 27. Which Network Watcher tool

**Modules 04-01.**

| Question | Tool |
| --- | --- |
| Is it allowed, and which rule decided? | **IP flow verify** (or NSG diagnostics) |
| Where does traffic to this IP go? | **Next hop** |
| Which routes apply to this NIC? | **Effective routes** |
| Which NSG rules apply to this NIC and subnet together? | **Effective security rules** |
| Can it connect right now? | **Connection troubleshoot** |
| Is it connected over time? | **Connection monitor** (module 05-01) |
| Log every flow for new deployments | **Virtual network flow logs** (NSG flow logs retire Sept 30, 2027) |

> **The trap.** Using IP flow verify for a routing problem, or next hop for an NSG problem. One
> answers "is it allowed", the other "where does it go".

---

## 28. Service endpoint or private endpoint

**Modules 02-01, 04-02.**

| Need | Service endpoint | Private endpoint |
| --- | --- | --- |
| Restrict a PaaS resource to a subnet, free | **Yes** | Works, but bills hourly |
| Reach it privately from on-premises or over peering | No (on-premises) | **Yes** |
| Disable the resource's public endpoint | No | **Yes** |
| Scope to **one** resource instance (exfiltration protection) | No: whole service | **Yes** |
| DNS changes | None | **Private DNS zone** required |

> **The trap.** Choosing a service endpoint for "private access from on-premises". Service endpoints
> don't extend beyond the VNet; private endpoints do.

---

## 29. Which Bastion SKU

**Modules 04-02.**

| Requirement | Minimum SKU |
| --- | --- |
| Free, one test VM at a time, no peering | **Developer** |
| Dedicated host, peered VNets, concurrent sessions | **Basic** |
| Native client, shareable links, IP connect, file transfer, scaling | **Standard** |
| Session recording, private-only deployment | **Premium** |

> **The trap.** Assuming you can step down later. Bastion upgrades in place, but a downgrade means
> deleting and re-creating it.

---

## 30. Which DNS record

**Modules 04-03.**

| Need | Record |
| --- | --- |
| A name to a fixed IPv4 address | **A** |
| A subdomain to another name | **CNAME** (one record only; never at the apex) |
| The apex to an Azure resource, following IP changes | **Alias** A/AAAA |
| Prove domain ownership, SPF | **TXT** |
| Mail for the domain | **MX** |
| Delegate the domain to Azure DNS | **NS** at the registrar |

> **The trap.** A CNAME at the apex (`contoso.com`). It's not allowed; an alias record is the answer
> when the target is an Azure resource.

---

## 31. Public or internal load balancer, and which rule

**Modules 04-03.**

| Requirement | Answer |
| --- | --- |
| Balance internet traffic across VMs | **Public** load balancer + load-balancing rule + probe |
| Balance traffic for a private tier | **Internal** load balancer |
| Reach one specific VM through the load balancer's IP | **Inbound NAT rule** |
| Give backend VMs outbound internet through the load balancer | **Outbound rule** (public load balancer) |
| Balance every port for an NVA | **HA ports** (internal Standard only) |
| Keep a user on the same backend | Session persistence: **client IP** |

> **The trap.** Expecting Standard to be open like retired Basic was. Standard is **closed until an NSG
> allows the traffic**, even when every probe is healthy.

---

## 32. Which alert rule type

**Modules 05-01.**

| Watch for | Rule type |
| --- | --- |
| A number crossing a threshold (CPU, latency, transactions) | **Metric** |
| A pattern or count in logs; anything needing KQL logic | **Log search** |
| A specific operation (delete, stop, role assignment) | **Activity log** |
| An Azure service incident or a resource becoming unavailable | **Activity log**: Service Health or Resource Health |

> **The trap.** Using an alert processing rule to *detect* something. Processing rules only change what
> happens to alerts that have already fired: suppress, or add action groups.

---

## 33. Which Network Watcher tool

**Modules 04-01, 04-02, 05-01.**

| Question | Tool | Agent extension? |
| --- | --- | --- |
| Is A **still** reaching B, and how fast, over time? | **Connection monitor** | Yes |
| Can A reach B **right now**, and where does it fail? | **Connection troubleshoot** | Yes |
| Is this flow allowed, and by which rule? | **IP flow verify** | No |
| Where does this packet go? | **Next hop** | No |
| What's actually on the wire? | **Packet capture** | Yes |
| What traffic flowed, historically? | **VNet flow logs** + traffic analytics | No |

> **The trap.** Choosing connection troubleshoot for "continuous" or "trend" requirements. It's one-time;
> Connection monitor is continuous.

---

## 34. Recovery Services vault or Backup vault

**Modules 05-02.**

| Datasource | Vault |
| --- | --- |
| Azure VMs, SQL or SAP HANA in VMs, Azure Files, on-premises (MARS, MABS, DPM) | **Recovery Services vault** |
| Azure Disks, Azure Blobs, Azure Database for PostgreSQL | **Backup vault** |
| Site Recovery replication | **Recovery Services vault** |

> **The trap.** "Back up managed disks" sounds like VM backup, but standalone disk backup lives in a **Backup
> vault**; whole-VM backup lives in a **Recovery Services vault**.

---

## 35. Backup or Site Recovery

**Modules 05-02.**

| Requirement | Service |
| --- | --- |
| Restore data or a VM as it was at a point in time (hours to years ago) | **Azure Backup** |
| Recover from deletion, corruption or ransomware | **Azure Backup** (with soft delete) |
| Keep a workload running when a region fails, with minutes of data loss | **Azure Site Recovery** |
| Rehearse regional disaster recovery without impact | **Site Recovery test failover** |
| Restore in the paired region on demand | **Azure Backup** with **GRS + Cross Region Restore** |

> **The trap.** Treating GRS backup as disaster recovery for running workloads. Restoring from backup takes much
> longer and loses hours of data; Site Recovery fails over replicated VMs with recovery points minutes apart.

## Sources

- Microsoft Learn: [Learn about group types, membership types, and access management](https://learn.microsoft.com/en-us/entra/fundamentals/concept-learn-about-groups)
- Microsoft Learn: [Manage rules for dynamic membership groups](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership)
- Microsoft Learn: [What is Microsoft Entra B2B collaboration?](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b)
- Microsoft Learn: [Configure external collaboration settings](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure)
- Microsoft Learn: [Administrator reset policy differences](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-policy)
- Microsoft Learn: [Licensing requirements for self-service password reset](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-licensing)
- Microsoft Learn: [What is Azure role-based access control?](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)
- Microsoft Learn: [Azure built-in roles for Privileged](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged)
- Microsoft Learn: [Azure roles, Microsoft Entra roles, and classic subscription administrator roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles)
- Microsoft Learn: [Assign or unassign licenses to a group in the Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-group-licenses)
- Microsoft Learn: [Tutorial: Enable self-service password reset](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr)
- Microsoft Learn: [Azure Policy definitions effect basics](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-basics)
- Microsoft Learn: [Understand scope in Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/scope)
- Microsoft Learn: [Lock your Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources)
- Microsoft Learn: [Use tags to organize your Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)
- Microsoft Learn: [Grant limited access with shared access signatures](https://learn.microsoft.com/en-us/azure/storage/common/storage-sas-overview)
- Microsoft Learn: [Create a service SAS: lifetime and revocation](https://learn.microsoft.com/en-us/rest/api/storageservices/create-service-sas)
- Microsoft Learn: [Azure Storage firewall rules and network access control](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security)
- Microsoft Learn: [Guidelines and limitations for the Azure Storage firewall](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security-limitations)
- Microsoft Learn: [Azure Storage redundancy](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)
- Microsoft Learn: [Object replication for block blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/object-replication-overview)
- Microsoft Learn: [Azure Storage encryption for data at rest](https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption)
- Microsoft Learn: [Data protection overview](https://learn.microsoft.com/en-us/azure/storage/blobs/data-protection-overview)
- Microsoft Learn: [Access tiers for blob data](https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview)
- Microsoft Learn: [Use share snapshots with Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/storage-snapshots-files)
- Microsoft Learn: [Azure Resource Manager deployment modes](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-modes)
- Microsoft Learn: [Use Azure portal to export a Bicep file](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/export-bicep-portal)
- Microsoft Learn: [Decompile a JSON ARM template to Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/decompile)
- Microsoft Learn: [Orchestration modes for Virtual Machine Scale Sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes)
- Microsoft Learn: [Availability sets overview](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)
- Microsoft Learn: [Overview of managed disk encryption options](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
- Microsoft Learn: [Update containers in Azure Container Instances](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-update)
- Microsoft Learn: [Set scaling rules in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/scale-app)
- Microsoft Learn: [What are Azure App Service plans?](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
- Microsoft Learn: [Azure App Service access restrictions](https://learn.microsoft.com/en-us/azure/app-service/overview-access-restrictions)
- Microsoft Learn: [Integrate your app with an Azure virtual network](https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration)
- Microsoft Learn: [Azure virtual network traffic routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- Microsoft Learn: [What is Azure Network Watcher?](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview)
- Microsoft Learn: [Compare private endpoints and service endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/vnet-integration-for-azure-services#compare-private-endpoints-and-service-endpoints)
- Microsoft Learn: [Choose the right Azure Bastion SKU](https://learn.microsoft.com/en-us/azure/bastion/bastion-sku-comparison)
- Microsoft Learn: [Azure DNS alias records overview](https://learn.microsoft.com/en-us/azure/dns/dns-alias)
- Microsoft Learn: [Azure Load Balancer components](https://learn.microsoft.com/en-us/azure/load-balancer/components)
- Microsoft Learn: [Choose the right type of alert rule](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-types)
- Microsoft Learn: [What is Azure Network Watcher?](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview)
- Microsoft Learn: [Azure Backup FAQ: supported vaults](https://learn.microsoft.com/en-us/azure/backup/backup-azure-backup-faq)
- Microsoft Learn: [Azure to Azure disaster recovery architecture](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-architecture)
