#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "feedback" <<-EOSQL
    CREATE EXTENSION cube;
    CREATE EXTENSION earthdistance;

    -- business table --

    CREATE TABLE business (
      business_id  SERIAL PRIMARY KEY,
      name         TEXT NOT NULL,
      description  TEXT NOT NULL,
      lat          DECIMAL(11,8) NOT NULL,
      lon          DECIMAL(11,8) NOT NULL,
      active       BOOLEAN NOT NULL DEFAULT FALSE,
      registered   TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
 
    -- customer table --

    CREATE TABLE customer (
      customer_id  SERIAL PRIMARY KEY,
      name         TEXT NOT NULL,
      banned_from  INTEGER[] DEFAULT '{}',
      registered   TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    -- feedback table --

    CREATE TABLE feedback (
      feedback_id  SERIAL PRIMARY KEY,
      business_id  INTEGER NOT NULL REFERENCES business (business_id),
      customer_id  INTEGER NOT NULL REFERENCES customer (customer_id),
      message      TEXT NOT NULL,
      last_edited  TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
 
EOSQL
