# daily-seed-fetcher

Fetches the PokeRogue daily seed every day at 00:01 UTC, writes it to
`/output/daily-seed.txt`, and triggers the `fetch-seed.yaml` workflow in
[PokeRogue-Offline/pokerogue-offline](https://github.com/PokeRogue-Offline/pokerogue-offline)
via the GitHub API.

## Usage

1. Copy `.env.example` to `.env` and set `GH_PAT` to a GitHub PAT with
   permission to dispatch workflows on `pokerogue-offline`.
2. Edit `docker-compose.yml` and set the volume mount to wherever you want
   `daily-seed.txt` written (e.g. a web root).
3. Start it:

```bash
docker compose up -d
```

That's it — the container runs indefinitely, firing the fetch job every day
at 00:01 UTC. Schedule changes can be made by editing `crontab` and running
`docker compose restart` (no rebuild needed, since it's bind-mounted).

## Logs

```bash
docker compose logs -f
```

## Force a manual sync

To trigger a fetch + workflow dispatch immediately (without waiting for the
00:01 UTC schedule), run:

```bash
./force-sync.sh
```

This runs `getSeed.sh` inside the running container and streams its output
to your terminal. If your container has a different name, pass it as an
argument:

```bash
./force-sync.sh my-container-name
```

## Internals

- **Dockerfile**: Alpine + [supercronic](https://github.com/aptible/supercronic)
  (a cron implementation designed for containers — logs to stdout/stderr,
  no syslog).
- **getSeed.sh**: fetches the seed, writes it to `/output/daily-seed.txt`,
  and dispatches the GitHub Actions workflow.
- **crontab**: runs `getSeed.sh` daily at `00:01 UTC`.
