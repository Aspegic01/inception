# Developer Documentation

## Architecture

The Compose project is defined in `srcs/docker-compose.yml` and creates three services on the `inception` bridge network:

| Service | Role | Internal endpoint | Host exposure |
| --- | --- | --- | --- |
| `mariadb` | Database server | `mariadb:3306` | None |
| `wordpress` | WP-CLI bootstrap and PHP-FPM | `wordpress:9000` | None |
| `nginx` | HTTPS reverse proxy and static file server | `nginx:443`|

Nginx mounts the same `wordpress_data` volume as the WordPress container. MariaDB uses `mariadb_data`. Both volumes are bind mounts, so data survives container recreation.

## Bootstrap sequence

1. `make build` builds each image from Debian Bookworm.
2. The Makefile creates the host data directories.
3. MariaDB initializes its data directory if needed, creates `DATA_BASE`, creates `DB_USER`, and grants that user access to the database.
4. WordPress waits for MariaDB to answer `mariadb-admin ping`.
5. On an empty WordPress volume, WP-CLI downloads WordPress, writes `wp-config.php`, installs the site, and creates the regular author account.
6. WordPress starts PHP-FPM in the foreground on port `9000`.
7. Nginx serves `/var/www/wordpress`, forwards PHP requests to `wordpress:9000`, and listens for TLS connections on port `443` inside the container.

Initialization is guarded by the presence of `/var/lib/mysql/mysql` and `/var/www/wordpress/wp-config.php`. Existing data is therefore reused on normal restarts.

## Configuration

Runtime variables are loaded from `srcs/.env`:

| Variable | Purpose |
| --- | --- |
| `DOMAIN_NAME` | WordPress site URL and intended host name |
| `DATA_BASE` | MariaDB database name |
| `DB_USER` | WordPress database user |
| `WP_ADMIN_USER` / `WP_ADMIN_EMAIL` | Initial administrator account |
| `WP_REGULAR_USER` / `WP_REGULAR_EMAIL` | Initial author account |
| `DATA_PATH` | Makefile directory-creation path; Compose bind-mount devices must also be changed for a custom path |

Passwords are read from Docker secrets mounted at `/run/secrets/`. Do not place passwords in `.env`, Dockerfiles, or source control.

## Development commands

```sh
make build                 # Build images
make up                    # Start in detached mode
make status                # Equivalent to docker compose ps
make logs                  # Follow all collected logs after startup
docker compose -f srcs/docker-compose.yml config
docker compose -f srcs/docker-compose.yml exec wordpress wp user list --allow-root
```

To rebuild after changing an image or startup script:

```sh
make build
make up
```

To force a fresh WordPress installation, stop the stack and remove the persisted data. `make fclean` is destructive: it removes Docker resources and the contents of the configured MariaDB and WordPress data directories.

## Important implementation notes

- `depends_on` controls start order but does not mean MariaDB or PHP-FPM is ready. The WordPress startup script handles the database readiness check.
- The current Nginx configuration hard-codes `mlabrirh.42.fr` in `server_name` and in the generated certificate subject. Changing `DOMAIN_NAME` alone does not update Nginx.
- The certificate is self-signed and generated during the Nginx image build with a one-year validity.
- The Nginx configuration publishes HTTPS on host port `443`; use `https://<domain>:443/`.
- The database is bound to `0.0.0.0` inside the container but is not published to the host. It is reachable only through the Compose network.
- The image build downloads WP-CLI from GitHub. Rebuilds can therefore retrieve a different artifact unless the download is pinned.
- PHP-FPM, Nginx, and MariaDB run as foreground processes so Docker can supervise them.

## Troubleshooting

Check status and logs first:

```sh
make status
make logs
```

If WordPress keeps waiting for MariaDB, verify that `DB_USER`, `DATA_BASE`, and `secrets/db_password` match the existing database volume. Changing credentials does not modify an already initialized database.

If the site is unreachable, verify that port `443` is open, the domain resolves to the host, and the `nginx` container is running. A browser certificate warning is expected with the generated self-signed certificate.
