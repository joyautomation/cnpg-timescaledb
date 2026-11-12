# cnpg-timescaledb

PostgreSQL container image with the TimescaleDB extension preinstalled, built on
[CloudNativePG](https://cloudnative-pg.io/)'s official Postgres operand image so
it drops directly into a CNPG `Cluster` resource.

## Image

Published to two registries, same digest:

```
ghcr.io/joyautomation/cnpg-timescaledb:<pg_major>-ts<timescale_version>                    # public, no pull secret
registry.digitalocean.com/jar-containers/cnpg-timescaledb:<pg_major>-ts<timescale_version>  # private (jar-containers)
```

Tag examples (immutable variants are produced for every build):

- `17-ts2.31` — rolling tag, latest weekly rebuild
- `17-ts2.31-20261112` — date-stamped
- `17-ts2.31-20261112-<git_sha>` — fully pinned (pin by digest in production)

Older `17-ts2.25*` tags stay in the DO registry; existing clusters pinned to them are unaffected.

## Usage in a CNPG `Cluster`

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: timescale
spec:
  imageName: ghcr.io/joyautomation/cnpg-timescaledb:17-ts2.31
  postgresql:
    parameters:
      shared_preload_libraries: "timescaledb"
  bootstrap:
    initdb:
      postInitTemplateSQL:
        - "CREATE EXTENSION IF NOT EXISTS timescaledb;"
```

Activate the extension in each application database:

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb;
```

## Build

GitHub Actions (`.github/workflows/build.yml`) rebuilds weekly on top of the
upstream CNPG image to pick up Postgres minor patches and TimescaleDB point
releases. To force a build with different versions, run the workflow manually:

```
gh workflow run build.yml -f pg_major=17 -f timescale_version=2.31
```

### Required repository secret

- `DIGITALOCEAN_ACCESS_TOKEN` — DO API token with read/write access to the
  `jar-containers` container registry. GHCR uses the workflow's own `GITHUB_TOKEN`.

GitHub disables scheduled workflows after 60 days without repository activity (this
one stopped on 2026-07-06). Check with `gh workflow list --all`; re-enable with
`gh workflow enable build.yml`.

## Why DIY

CNPG's official extension catalog ships pgvector, PostGIS, pgAudit, and
pg_crash — TimescaleDB is not included. Timescale's own `timescaledb-ha` image
embeds Patroni and is incompatible with CNPG. Community images exist but
maintenance is at a single contributor's discretion. This repo gives us a
~15-line Dockerfile, a weekly automated rebuild, and one less third-party
dependency to track.
