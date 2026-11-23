# Tlm source maps action

Uploads your build's source maps to [Tlm](https://tlm.hullop.com) from
GitHub Actions, so stack traces show your own code. It installs the
[`tlm` CLI](https://github.com/cirope/tlm-cli) from its GitHub release,
checks the download against the release's checksums and its signed build
provenance, then runs `tlm upload`. Nothing is piped into a shell.

```yaml
- uses: cirope/tlm-action@v1
  with:
    dir: dist
  env:
    TLM_UPLOAD_TOKEN: ${{ secrets.TLM_UPLOAD_TOKEN }}
    TLM_DSN: ${{ vars.TLM_DSN }}
```

Upload **before you deploy**, in the job that builds what you deploy. The
release must be the one your app reports; it defaults to the commit
(`github.sha`).

Create the upload token, stored straight as a repository secret:

```sh
tlm upload-tokens create "GitHub Actions" --gh-secret TLM_UPLOAD_TOKEN
```

## Inputs

| Input | Default | |
|---|---|---|
| `dir` | | Required. The directory with the build, e.g. `dist` or `public/assets` |
| `release` | `github.sha` | The release your app reports, exactly |
| `url-prefix` | `/` | The URL path the directory is served at, e.g. `/assets` |
| `sources` | `false` | Also map scripts that have no source map line for line, for JavaScript served as written (importmap). Needs tlm 0.3.0 or later |
| `delete` | `false` | Delete the `.map` files after a successful upload, so they aren't deployed |
| `dry-run` | `false` | Only list what would be uploaded |
| `upload-token` | `TLM_UPLOAD_TOKEN` | An upload token (`tlmu_…`) |
| `dsn` | `TLM_DSN` | The project's DSN, which says where Tlm is |
| `version` | `latest` | The tlm version to install, e.g. `0.3.0` |
| `verify-attestation` | `true` | Also check the download's build provenance with `gh attestation verify` |

Checking the build provenance reads attestations with the job's token. If
your workflow sets `permissions:`, add `attestations: read` (or set
`verify-attestation: false`):

```yaml
permissions:
  contents: read
  attestations: read
```

Output: `tlm-version`, the version that ran. It runs on Linux and macOS
runners, x64 and ARM64.

## Rails with importmap

```yaml
- run: bin/rails assets:precompile
- uses: cirope/tlm-action@v1
  with:
    dir: public/assets
    url-prefix: /assets
    sources: true
  env:
    TLM_UPLOAD_TOKEN: ${{ secrets.TLM_UPLOAD_TOKEN }}
    TLM_DSN: ${{ vars.TLM_DSN }}
```

## Vite

```yaml
- run: npm run build
  env:
    GIT_SHA: ${{ github.sha }}
- uses: cirope/tlm-action@v1
  with:
    dir: dist
    delete: true
  env:
    TLM_UPLOAD_TOKEN: ${{ secrets.TLM_UPLOAD_TOKEN }}
    TLM_DSN: ${{ vars.TLM_DSN }}
```

with `define: { __TLM_RELEASE__: JSON.stringify(process.env.GIT_SHA) }`
and `build: { sourcemap: "hidden" }` in `vite.config.ts`.

## Versions

`@v1` follows every 1.x release of this action; pin a full version
(`@v1.0.0`) or a commit to never move. The CLI it installs is the
latest unless `version` says which.
