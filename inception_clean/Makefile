NAME = inception
COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_PATH ?= /home/mlabrirh/data
MARIADB_DIR = $(DATA_PATH)/mariadb
WORDPRESS_DIR = $(DATA_PATH)/wordpress

all: build up

build:
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR) 2>/dev/null || true
	@docker compose -f $(COMPOSE_FILE) build

up:
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR) 2>/dev/null || true
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@docker compose -f $(COMPOSE_FILE) stop

start:
	@docker compose -f $(COMPOSE_FILE) start

status ps:
	@docker compose -f $(COMPOSE_FILE) ps

logs:
	@docker compose -f $(COMPOSE_FILE) logs

clean: down
	@docker compose -f $(COMPOSE_FILE) down -v

fclean: clean
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@docker system prune -af
	@sudo rm -rf $(MARIADB_DIR)/* $(WORDPRESS_DIR)/* 2>/dev/null || rm -rf $(MARIADB_DIR)/* $(WORDPRESS_DIR)/* 2>/dev/null || true

re: fclean all

.PHONY: all build up down stop start status ps logs clean fclean re
