#!/usr/bin/env bash

if [ -f .env ]; then
  echo ".env file already exists, so it will be overwritten."
  read -p "Press [ENTER] to continue: " input
  if [ ! -z $input ]; then
    echo "Another key pressed. Aborting."
    exit 1
  fi
fi

function read_variable() {
  local var_name=$1
  local default_value=$2
  echo -n "Input value for $var_name [$default_value]: " 
  read $var_name
}

function read_secret_variable() {
  local var_name=$1
  local default_value=$2
  echo -n "Input value for $var_name [$default_value]: " 
  read -s $var_name
  echo
}

read_variable POSTGRES_USER 'postgres'
POSTGRES_USER=${POSTGRES_USER:-'postgres'}

read_secret_variable POSTGRES_PASSWORD 'postgres'
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-'postgres'}

read_variable PGADMIN_DEFAULT_EMAIL 'admin@example.com'
PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL:-'admin@example.com'}

read_secret_variable PGADMIN_DEFAULT_PASSWORD 'admin123!@#'
PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD:-'admin123!@#'}

echo "POSTGRES_USER=$POSTGRES_USER" > .env
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env
echo "PGADMIN_DEFAULT_EMAIL=$PGADMIN_DEFAULT_EMAIL" >> .env
echo "PGADMIN_DEFAULT_PASSWORD=$PGADMIN_DEFAULT_PASSWORD" >> .env
echo ".env file created/updated."
