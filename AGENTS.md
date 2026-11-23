# Working in this repository

`cirope/tlm-action` is the GitHub Action that installs the `tlm` CLI
(`../tlm-cli`) from its release and uploads a build's source maps to Tlm
(`../tlm`).

- Inputs reach the scripts as environment variables only, never pasted
  into `run:`, so none can inject commands. No third-party actions.
- Every download is checked against the release's `checksums.txt`, and
  by default its build provenance (`gh attestation verify`).
- `shellcheck install.sh upload.sh` is clean; the `test` workflow runs the
  action on Linux (x64, ARM64) and macOS with a dry run.
- Never commit or run git-modifying commands unless asked; end each change
  with a commit subject of 50 characters or less.
- Never name or point at other codebases in code, comments or docs.
- Releases: Franco tags `vX.Y.Z` and moves `v1` to it. Say whether a
  change is worth releasing, with the commands.
- Work is tracked like `../tlm-cli/AGENTS.md` says, on the board
  "Telemetría".
