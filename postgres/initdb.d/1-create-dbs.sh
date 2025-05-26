#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- enable gathering of query statistics --

    CREATE EXTENSION pg_stat_statements;

    -- create databases -- 

    CREATE DATABASE wallet;
    CREATE DATABASE feedback;
EOSQL

