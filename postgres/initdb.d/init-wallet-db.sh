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

    INSERT INTO account (name)
    VALUES ('User A'), ('User B'), ('User C');

    -- wallet table --

    CREATE TABLE wallet (
      wallet_id SERIAL PRIMARY KEY,
      account_id INTEGER NOT NULL REFERENCES account (account_id),
      balance NUMERIC(10, 2),
      created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
      updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
    );
 
    CREATE UNIQUE INDEX wallet_account_idx ON wallet (account_id);

    WITH initial_data AS (
      SELECT
        account_id,
        '1000.0'::numeric as balance
      FROM account
    )
    INSERT INTO wallet (account_id, balance) 
    SELECT * FROM initial_data;

    -- topup_log table --

    CREATE TABLE topup_log (
      topup_log_id SERIAL PRIMARY KEY,
      wallet_id INTEGER NOT NULL REFERENCES wallet (wallet_id),
      amount NUMERIC(10, 2),
      created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
    );

    CREATE INDEX topup_log_wallet_idx ON topup_log (wallet_id);

    WITH initial_data AS (
      SELECT
        wallet_id,
        balance as amount
      FROM wallet
    )
    INSERT INTO topup_log (wallet_id, amount)
    SELECT * FROM initial_data;

    -- transfer_log table --

    CREATE TABLE transfer_log (
      transfer_log_id SERIAL PRIMARY KEY,
      from_wallet_id INTEGER NOT NULL REFERENCES wallet (wallet_id),
      to_wallet_id INTEGER NOT NULL REFERENCES wallet (wallet_id),
      amount NUMERIC(10, 2),
      created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
    );

    CREATE INDEX transfer_log_from_wallet_idx ON transfer_log (from_wallet_id);
    CREATE INDEX transfer_log_to_wallet_idx ON transfer_log (to_wallet_id);
EOSQL
