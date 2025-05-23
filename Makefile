ifeq ($(OS),Windows_NT)
	SHELL := bash.exe
else
	SHELL := bash
endif

venv_dir := .venv
ifeq ($(OS),Windows_NT)
	activate_venv := source $(venv_dir)/Scripts/activate
	python_cmd := python3.12.exe
else
	activate_venv := source $(venv_dir)/bin/activate
	python_cmd := python3.12
endif

export_env_vars := set -a && source .env && set +a &&

v := 1

.PHONY: help

# Usage: make help
help:
	@cat Makefile | grep "^# Usage:"

.env:
	@test -f .env || ./bin/create-env-file.sh

pgadmin4/servers.json: .env
	@$(export_env_vars) envsubst < pgadmin4/servers.template.json > pgadmin4/servers.json

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

.PHONY: tail-log

# Usage: make tail-log
tail-log:
	docker compose logs postgres -f

.PHONY: psql ssh

# Usage: make psql
psql: .env
	@$(export_env_vars) docker compose exec -u $$POSTGRES_USER postgres psql

# Usage: make ssh
ssh: .env
	@$(export_env_vars) docker compose exec -u $$POSTGRES_USER postgres bash

.PHONY: venv black

# Usage: make venv
venv:
	@test -z "$$VIRTUAL_ENV" || ( echo "venv already active"; exit 1 )
	$(python_cmd) -m venv $(venv_dir)
	$(activate_venv) && pip install --require-virtualenv -r requirements.txt

# Usage: black
black:
	$(activate_venv) && black .

.PHONY: topup-wallet generate-feedback

# Usage: topup-wallet [v=1]
topup-wallet:
	$(activate_venv) && python wallet/topup_v$(v).py

# Usage: generate-feedback
generate-feedback:
	$(activate_venv) && python feedback/generate.py
