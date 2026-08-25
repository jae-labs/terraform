# Agent Guidelines

This repository is organized into flat, independent Terraform roots. For any domain-specific documentation, state models, providers, or workflows, agents MUST read the documentation in [docs/](docs/).

## Commands

- Install git hooks: `lefthook install`
- Run pre-commit checks: `lefthook run pre-commit`

## Agent workflow

Hard rules for any agent making changes in this repo:

- **Read the docs first.** Always refer to [docs/](docs/) to understand the backend layout, provider-root conventions, and CI/CD triggers.
- **Plan only, never apply.** Run `terraform plan` for verification. Do not run `terraform apply` locally. Applies happen via CI on merge to `main`.
- **Use Doppler for secrets.** Wrap every Terraform invocation with `doppler run --` so secrets are injected.
- **No commits, no PRs.** Do not `git commit`, `git push`, or open pull requests unless the user explicitly asks for that step in the current turn. Stage nothing, push nothing.
- **Keep changes scoped.** Edit only the provider root(s) the task requires. Cross-root drive-by changes are not acceptable.
- **Keep docs updated & check for drift.** Documentation MUST be updated in the same PR or commit as the code change. Check existing docs, workflows, and lefthook configurations for drift. Make sure to run `lefthook run pre-commit` to validate.
- **Keep tools and docs fresh.** Always check provider/vendor docs, and always aim for the latest stable versions of tools.
- **Ask before acting on ambiguity.** If a request is unclear, the change is destructive, or a schema-managed locals key/path would change, stop and ask the user. Do not guess.
