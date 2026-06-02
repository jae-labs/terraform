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
    end

    subgraph State["remote state"]
        PG["PostgreSQL backend"]
    end

    GH -.->|"schema: github"| PG
    CF -.->|"schema: cloudflare"| PG
    DP -.->|"schema: doppler"| PG
    OCI -.->|"schema: oci"| PG
```

## Core model

- one Terraform root per top-level provider folder
- one PostgreSQL backend schema per root
- path-filtered CI/CD applies only the changed root
- no reusable internal Terraform modules; roots stay flat

## Concierge contract

The bot contract is not provider-specific docs. It is:

- `concierge-schema.yaml`
- the schema-managed locals it references

If schema-managed locals paths, key names, field paths, or nesting change, update `concierge-schema.yaml` in the same PR.

## References

- [providers.md](providers.md) — generic provider-root model, `locals.tf`, concierge contract
- [ci-cd.md](ci-cd.md) — workflows, triggers, secrets
