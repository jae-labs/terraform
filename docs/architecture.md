# Repository Architecture

This repo separates infrastructure by provider/domain into independent Terraform root modules. The split keeps blast radius small, allows path-filtered CI/CD, and avoids cross-module state coupling.

## Topology

```mermaid
flowchart TD
    subgraph RootModules["root modules"]
        GH["github/"]
        CF["cloudflare/"]
        DP["doppler/"]
        OCI["oci/"]
    end

    subgraph State["remote state"]
        PG["PostgreSQL backend"]
    end

    GH -.->|"schema: github"| PG
    CF -.->|"schema: cloudflare"| PG
    DP -.->|"schema: doppler"| PG
    OCI -.->|"schema: oci"| PG
```

## Layout

| Path | Responsibility |
|---|---|
| `github/` | Flat GitHub org root module |
| `cloudflare/` | Flat Cloudflare root module |
| `doppler/` | Flat Doppler root module |
| `oci/` | Flat OCI root module |
| `docs/` | Module and operations documentation |
| `scripts/` | Operational utilities |

## State model

- Backend: PostgreSQL `pg` backend
- Isolation boundary: one backend schema per root module
- Cross-module dependencies: none by design
- Apply model: plan and apply only the changed root module

This keeps operations idempotent and reduces the chance that an unrelated provider change mutates the wrong state.

## CI/CD flow

```mermaid
flowchart LR
    PR["pull request"] --> CI["ci.yml"]
    CI --> FMT["terraform fmt -check"]
    CI --> LINT["tflint --recursive"]
    CI --> VALIDATE["terraform validate per root module"]
    MERGE["merge to main"] --> PATH["path filter by root module"]
    PATH --> GHAPPLY["github-apply.yml"]
    PATH --> CFAPPLY["cloudflare-apply.yml"]
    PATH --> DPAPPLY["doppler-apply.yml"]
    PATH --> OCIAPPLY["oci-apply.yml"]
```

Reusable apply logic lives in `.github/workflows/terraform-reusable.yml` for GitHub, Cloudflare, and Doppler. OCI has a dedicated workflow because it needs multiple provider environment variables and stack inputs.

## Bot coupling

The [conCierge bot](https://github.com/jae-labs/conCIerge/tree/main) is an external client of this repository. It reads live Terraform configuration from this repo, uses that data to populate Slack workflows and validate requests, then writes changes back by editing specific Terraform locals files and opening pull requests.

It is a client because it consumes this repo through stable file paths and HCL structures rather than sharing in-process code or Terraform state with it.

The contract is the set of files and data shapes the bot expects to exist unchanged:

| File | Reason |
|---|---|
| `github/locals.tf` | Repository, membership, and org settings |
| `cloudflare/locals.tf` | DNS CRUD input |

Constraints:

- do not rename those files without updating bot path constants
- do not change key names or nesting without updating the HCL editor implementation
- treat those locals files as bot-consumed API surfaces, not internal-only config

Break the contract and the likely failure mode is not Terraform itself. The likely failure is that Slack request handling, HCL parsing, or PR generation in the bot stops working correctly.

See the module docs for exact shapes and examples.
