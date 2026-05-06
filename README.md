# cnpg-timescaledb

PostgreSQL container image with the TimescaleDB extension preinstalled, built on
[CloudNativePG](https://cloudnative-pg.io/)'s official Postgres operand image so
it drops directly into a CNPG `Cluster` resource.

## Image

```
registry.digitalocean.com/jar-containers/cnpg-timescaledb:<pg_major>-ts<timescale_version>
```

Tag examples (immutable variants are produced for every build):

- `17-ts2.25` — rolling tag, latest weekly rebuild
- `17-ts2.25-20260506` — date-stamped immutable
- `17-ts2.25-20260506-<git_sha>` — fully pinned

## Usage in a CNPG `Cluster`

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: timescale
spec:
  imageName: registry.digitalocean.com/jar-containers/cnpg-timescaledb:17-ts2.25
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
gh workflow run build.yml -f pg_major=17 -f timescale_version=2.25
```

### Required repository secret

- `DIGITALOCEAN_ACCESS_TOKEN` — DO API token with read/write access to the
  `jar-containers` container registry.

## Why DIY

CNPG's official extension catalog ships pgvector, PostGIS, pgAudit, and
pg_crash — TimescaleDB is not included. Timescale's own `timescaledb-ha` image
embeds Patroni and is incompatible with CNPG. Community images exist but
maintenance is at a single contributor's discretion. This repo gives us a
~15-line Dockerfile, a weekly automated rebuild, and one less third-party
dependency to track.
