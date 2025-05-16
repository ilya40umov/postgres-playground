#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE wallet;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "wallet" <<-EOSQL

    -- account table --

    CREATE TABLE account (
      account_id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
    );

    CREATE UNIQUE INDEX account_name_idx ON account (name);

    -- wallet table --

    CREATE TABLE wallet (
      wallet_id SERIAL PRIMARY KEY,
      account_id INTEGER NOT NULL REFERENCES account (account_id),
      balance NUMERIC(10, 2),
      created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
      updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
    );
 
    CREATE UNIQUE INDEX wallet_account_idx ON wallet (account_id);
EOSQL
