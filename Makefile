ifeq ($(OS),Windows_NT)
	SHELL := bash.exe
else
	SHELL := bash
endif

EXPORT_ENV_VARS := set -a && source .env && set +a &&

.PHONY: help

# Usage: make help
help:
	@cat Makefile | grep "^# Usage:"

.env:
	@test -f .env || ./bin/create-env-file.sh

pgadmin4/servers.json: .env
	@$(EXPORT_ENV_VARS) envsubst < pgadmin4/servers.template.json > pgadmin4/servers.json

.PHONY: .config-files

.config-files: .env pgadmin4/servers.json

.PHONY: clean

# Usage: make clean
clean:
	rm -f .env
	rm -f pdadmin4/servers.json

.PHONY: ps up down

# Usage: make ps
ps: .config-files
	docker compose ps 

# Usage: make up
up: .config-files
	docker compose up -d

# Usage: make down
down: .config-files
	docker compose down -v

.PHONY: tail-postgres tail-pgadmin

# Usage: make tail-postgres
tail-postgres:
	docker compose logs postgres -f

# Usage: make tail-pgadmin
tail-pgadmin:
	docker compose logs pgadmin -f

.PHONY: psql

# Usage: make psql
psql: .env
	@$(EXPORT_ENV_VARS) docker compose exec -u $$POSTGRES_USER postgres psql
