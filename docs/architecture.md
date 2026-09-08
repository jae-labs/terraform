# Repository Architecture

This repo is split by provider/domain into independent Terraform roots. Each top-level provider folder owns its own state schema and is applied independently.

## Topology

```mermaid
flowchart TD
    subgraph ProviderRoots["provider roots"]
        GH["github/"]
        CF["cloudflare/"]
        DP["doppler/"]
        OCI["oci/"]
        SENTRY["sentry/"]
        TAILSCALE["tailscale/"]
        HC["honeycomb/"]
    end

    subgraph State["remote state"]
        PG["PostgreSQL backend"]
    end

    GH -.->|"schema: github"| PG
    CF -.->|"schema: cloudflare"| PG
    DP -.->|"schema: doppler"| PG
    OCI -.->|"schema: oci"| PG
    SENTRY -.->|"schema: sentry"| PG
    TAILSCALE -.->|"schema: tailscale"| PG
    HC -.->|"schema: honeycomb"| PG
```

## Core model

- one Terraform root per top-level provider folder
- one PostgreSQL backend schema per root
- path-filtered CI/CD applies only the changed root
- no reusable internal Terraform modules; roots stay flat

## References

- [providers.md](providers.md) — generic provider-root model, `locals.tf`
- [ci-cd.md](ci-cd.md) — workflows, triggers, secrets
