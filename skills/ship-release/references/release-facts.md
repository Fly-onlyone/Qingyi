# Release Facts

What a release run needs to know about the project. Read them from the project's instructions
first (`AGENTS.md`, `CLAUDE.md`, `RELEASING.md`, `CONTRIBUTING.md`); find the rest in the
repository as shown, and confirm what was found with the user before the first change.

## The facts and where to find them

| Fact | Where it usually is |
|---|---|
| Checks that must pass before work counts as done | the instructions; the CI workflow's steps (`.github/workflows/*.yml`); `package.json` scripts; a `Makefile` or `justfile` |
| Main branch | `git symbolic-ref --short refs/remotes/origin/HEAD` |
| Every file that holds the version | `git grep -n -F '<current version>'`: `Cargo.toml` (also `version = "<x>", path` requirements between crates), `package.json`, `pyproject.toml`, `*.csproj`, plugin manifests (`plugin.json`), installer scripts, badges in `README.md` |
| A test that checks the versions agree | `git grep -n -i version -- '*test*'` |
| How the lockfile follows the bump | `cargo check --workspace` without `--locked` rewrites `Cargo.lock`; `npm install --package-lock-only`; `uv lock` |
| Package command, output folder, file name | the instructions; `scripts/package*`; the release workflow's build step |
| Where the published package comes from | `gh release list`; `gh release view <tag> --json assets` |
| Tag format | `git tag --sort=-v:refname \| head`; the `on: push: tags:` filter of the release workflow |
| Workflows to wait for after a push | workflows with `on: push` |
| Workflows a tag starts, and what they publish | workflows with `on: push: tags:`; their upload steps |
| Rules for pushing a tag | the instructions; often "only when asked" |
| Guest test: script, VM, account, checkpoints, memory, passes, report folder, how long a pass takes, and which suites or passes may shrink and when | the instructions; `scripts/vm/` or similar; `Get-VM`, `Get-VMSnapshot -VMName *` |
| Docs to update for a release | `CHANGELOG.md`, `ROADMAP.md`, `README.md` status lines, the agent instructions, generated docs |
| Clean-up after a release | the instructions; `scripts/clean*` |
| Traps of this project or machine | the instructions; the memory notes |

A fact that cannot be found is a question for the user, asked with the decisions.

## A model "Releasing" section

Offer a section like this for the project's instructions file, filled with what step 1 found:

```markdown
## Releasing

- Checks: `cargo fmt --all`, `cargo clippy --workspace --all-targets -- -D warnings`,
  `cargo test --workspace`, `cargo deny check`.
- Version: `version` in the root `Cargo.toml`, the `version = "<old>", path` requirements in
  `crates/*/Cargo.toml`, and `plugin/.claude-plugin/plugin.json`; `tests/versions.rs` fails when
  one is missed. Then `cargo check --workspace` once without `--locked` to rewrite `Cargo.lock`.
- Package: `pwsh scripts\package.ps1` writes `dist\MyApp-<version>-windows-x64.zip` and its
  `.sha256`. Keep the previous published zip in `dist\old\`.
- Push: wait for `ci.yml` and `security.yml`. Tag: `v<version>`, which starts `release.yml`; it
  publishes the zip and its `.sha256`.
- Guest test: `pwsh scripts\vm\test-release.ps1 -VmName "Test VM" -Snapshot "Clean" -Zip <zip>
  -OldZip <previous zip> -Report report\vm-test-<date>-<version>`; about 45 minutes. May shrink:
  skip the `-Servers` suite when `crates/servers` is unchanged since the last release; the
  second pass (no graphics card) runs `-Only <cases that draw or move>`; the published-package
  pass runs `-Only <the install and update cases>`. Say in the report what was skipped.
- Docs: `CHANGELOG.md`, the status line in `README.md`, `AGENTS.md` for new parts.
- Clean-up: `pwsh scripts\clean.ps1`.
```
