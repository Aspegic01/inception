# User Guide

## Open the site

After the stack is running, open:

```text
https://<DOMAIN_NAME>:443/
```

Replace `<DOMAIN_NAME>` with the value in `srcs/.env`. The first visit normally shows a certificate warning because the project uses a self-signed certificate. Continue only if you trust the local installation.

If the domain is not provided by DNS, add it to the client machine's hosts file, pointing to the Docker host. For a local installation, that may be:

```text
127.0.0.1 <DOMAIN_NAME>
```

## Accounts

The initial accounts are configured in `srcs/.env`:

- Administrator: `WP_ADMIN_USER` and `WP_ADMIN_EMAIL`
- Regular author: `WP_REGULAR_USER` and `WP_REGULAR_EMAIL`

Their passwords are stored in `secrets/wp_admin_password` and `secrets/wp_regular_password`. Use the administrator account at:

```text
https://<DOMAIN_NAME>:443/wp-admin/
```

The administrator username must not contain `admin` or `Admin`, as required by the bootstrap configuration.

## Basic operations

From the WordPress dashboard, an administrator can create posts and pages, manage users, change the site settings, and maintain themes and plugins.

For service operations:

```sh
make status   # Check whether the containers are running
make logs     # Inspect recent service output
make stop     # Stop the site while preserving data
make start    # Start a stopped site
make down     # Remove containers while preserving bind-mounted data
```

Do not run `make clean`, `make fclean`, or `make re` unless you understand the data-loss impact. `make fclean` removes the persisted WordPress and MariaDB data from the host.

## Data and passwords

WordPress files are stored in `/home/mlabrirh/data/wordpress`, and MariaDB files are stored in `/home/mlabrirh/data/mariadb` with the current Compose configuration. Back up both directories before destructive maintenance.

Keep all files in `secrets/` private. To change a WordPress password after installation, use the WordPress dashboard or the normal WordPress password reset flow. Updating a secret file alone does not change an existing WordPress account.

## Common problems

| Problem | Check |
| --- | --- |
| Site does not load | Confirm the domain points to the Docker host and that host port `443` is reachable. |
| Certificate warning | Expected for the default self-signed certificate. |
| Login fails after editing a secret | Existing WordPress accounts keep their old passwords; reset the password in WordPress. |
| Site appears empty after cleanup | `make fclean` removes persisted data; the next startup performs a new installation. |
| WordPress is still starting | Wait for MariaDB initialization, then inspect `make logs`. |
