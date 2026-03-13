# Agent Instructions — Opsy Slack Bot

## Module and commands

- Go module root: `bot/slack/`
- Build: `go build ./cmd/opsy/`
- Test: `go test ./...` — MUST run after every change

## Package map

| Package | Role |
|---|---|
| `internal/config` | Env var loading and validation |
| `internal/conversation` | Thread-keyed state machine; one state per Slack thread |
| `internal/github` | GitHub API wrapper: branch creation, file commits, PR creation |
| `internal/hcl` | HCL editors for terraform locals files |
| `internal/slack` | Socket Mode event loop, interaction routing, Block Kit modal definitions |

## Key constraints

**HCL editing** (`internal/hcl/`): editors parse with `hcl/v2` for reading but use string operations for writing, to preserve file formatting. Do not switch to AST rewriting without careful testing.

**HCL field names**: changing a field name requires updating both the corresponding editor in `internal/hcl/` and the Block Kit modal in `internal/slack/blocks.go`. Missing either will silently produce malformed terraform.

**Terraform path constants**: `internal/slack/handler.go` contains constants mapping workflow actions to terraform file paths under `iac/terraform/`. Update these if the terraform directory structure changes.

**Block Kit modals**: `internal/slack/blocks.go` is large; each modal builder function is self-contained. Edit only the relevant function.

**Test data**: `internal/hcl/testdata/` mirrors the terraform file structure (`locals_repos.tf`, `locals_members.tf`, `locals_org.tf`, `locals_dns.tf`). Add or update fixtures there when adding new HCL editor tests.

**Conversation state**: `internal/conversation/` keys state by Slack thread timestamp. Ensure new workflow steps register and clear state correctly to avoid stale state across sessions.
