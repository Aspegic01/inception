# Inception - 42 Project

An automated, secure multi-container web infrastructure built from scratch using custom Dockerfiles, Docker Compose, and Debian.

## Architecture

* **Nginx**: Dedicated container acting as TLS terminating reverse proxy (port 443 only, TLSv1.2 & TLSv1.3).
* **WordPress + PHP-FPM**: Dedicated container executing PHP-FPM listening on port 9000. Includes WP-CLI for automated initialization.
* **MariaDB**: Dedicated container running MariaDB listening on port 3306 on the private bridge network.

```
      Host Browser (https://mlabrirh.42.fr:443)
                      │
                      ▼
               ┌───────────────┐
               │  nginx:443    │ (TLS termination)
               └───────┬───────┘
                       │ FastCGI (port 9000)
                       ▼
               ┌───────────────┐
               │ wordpress:9000│
               └───────┬───────┘
                       │ MariaDB TCP (port 3306)
                       ▼
               ┌───────────────┐
               │ mariadb:3306  │
               └───────────────┘
```

## Setup Instructions

1. Add domain routing to `/etc/hosts`:
   ```bash
   127.0.0.1 mlabrirh.42.fr
   ```

2. Create host storage directories:
   ```bash
   mkdir -p /home/mlabrirh/data/mariadb /home/mlabrirh/data/wordpress
   ```

3. Launch the infrastructure:
   ```bash
   make
   ```

## Makefile Commands

* `make` / `make all` - Builds images and launches containers in detached mode.
* `make down` - Stops and removes containers and network.
* `make clean` - Stops containers and removes Docker volumes.
* `make fclean` - Complete teardown: removes containers, networks, images, and clears host data directories.
* `make re` - Rebuilds the entire infrastructure from scratch (`fclean` + `all`).
* `make logs` - Shows unified container output logs.
* `make ps` - Displays the status and health of all containers.

## Credentials & Users

* **WordPress URL**: `https://mlabrirh.42.fr`
* **Admin Login URL**: `https://mlabrirh.42.fr/wp-admin`
* **Admin Username**: `wp_master` (Non-admin naming compliant with 42 evaluation rules)
* **Regular Username**: `mlabrirh_user`
* **Secrets**: Managed securely via files in the `secrets/` directory (`db_password`, `wp_admin_password`, `wp_regular_password`).
