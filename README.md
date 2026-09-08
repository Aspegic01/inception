*This project has been created as part of the 42 curriculum by Mouad labrirhil.*

# Inception

## Description

This project focuses on system administration and infrastructure architecture. It deploys a multi-service WordPress environment using Docker and Docker Compose.

The infrastructure is built from custom Dockerfiles instead of ready-to-use application images. Nginx, WordPress with PHP-FPM, and MariaDB run in separate containers and communicate through a private Docker bridge network.

## Project Description

### Architecture & Design Choices

The project contains three services:

- **Nginx:** Terminates HTTPS connections on port `443` in the container and publishes them on host port `443`.
- **WordPress:** Downloads and installs WordPress with WP-CLI, then runs PHP-FPM on port `9000`.
- **MariaDB:** Creates the WordPress database and user, then stores the application data.

Each service has its own custom Dockerfile and startup configuration. Docker Compose manages the service dependencies, private network, secrets, and persistent bind mounts.

Key design choices include:

- **TLS configuration:** Nginx accepts TLSv1.2 and TLSv1.3 traffic and uses a self-signed certificate generated with OpenSSL.
- **Process isolation:** Each container runs its main service in the foreground so Docker can supervise it as PID 1.
- **Data persistence:** WordPress files and MariaDB data are stored in `/home/mlabrirh/data/` on the host.
- **Secrets:** Database and WordPress passwords are mounted from the `secrets/` directory at runtime instead of being stored in environment variables.

### Technical Comparisons

#### Virtual Machines vs Docker

- **Virtual machines:** Emulate complete computer systems and run a separate guest operating system, which requires more memory and startup time.
- **Docker:** Uses the host Linux kernel while isolating processes, filesystems, and networks with namespaces and cgroups.

#### Secrets vs Environment Variables

- **Docker secrets:** Mount sensitive values as files, such as `/run/secrets/db_password`, so applications can read them without placing passwords in the normal environment.
- **Environment variables:** Are convenient for non-sensitive configuration, but can be exposed through process inspection, logs, or diagnostic output.

#### Docker Network vs Host Network

- **Docker bridge network:** Provides private container-to-container communication and Docker DNS resolution. MariaDB is not exposed directly to the host.
- **Host network:** Removes the container network boundary and makes services bind directly to the host network interfaces.

#### Docker Volumes vs Bind Mounts

- **Docker volumes:** Are managed by Docker and stored in Docker's volume area.
- **Bind mounts:** Map explicit host directories into containers. This project uses bind mounts so the data is easy to inspect and back up on the host.

## Instructions

Install Docker Engine, the Docker Compose plugin, and `make` before starting the project.

Copy the example environment file and adjust it if necessary:

```sh
cp srcs/.env.example srcs/.env
```

The default domain is `mlabrirh.42.fr`. Add it to `/etc/hosts` when local DNS is not available:

```text
127.0.0.1 mlabrirh.42.fr
```

Make sure these secret files exist and contain the required passwords:

- `secrets/db_password`
- `secrets/wp_admin_password`
- `secrets/wp_regular_password`

### Makefile Execution Rules

- **`make`** or **`make all`** creates the host data directories, builds the images, and starts the containers in detached mode.
- **`make status`** or **`make ps`** displays the container status.
- **`make logs`** displays service logs.
- **`make stop`** stops the containers without removing them.
- **`make start`** starts stopped containers.
- **`make down`** stops and removes the containers while preserving host data.
- **`make clean`** removes containers, networks, and Compose volume metadata.
- **`make fclean`** removes containers, images, Docker resources, and the persisted WordPress and MariaDB data.
- **`make re`** runs `fclean` and then performs a complete rebuild and startup.

After `make`, open:

```text
https://mlabrirh.42.fr:443/
```

The browser will warn about the self-signed certificate on the first visit.

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress Documentation](https://wordpress.org/documentation/)

For more detailed project information, see [DEV_DOC.md](DEV_DOC.md) and [USER_DOC.md](USER_DOC.md).
