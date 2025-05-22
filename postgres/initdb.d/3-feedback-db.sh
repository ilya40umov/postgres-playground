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
 
    CREATE INDEX business_name_idx ON business USING HASH (name) WHERE active;
    CREATE INDEX business_description_idx ON business USING HASH (description) WHERE active;
    CREATE INDEX business_location_idx ON business USING GIST (ll_to_earth(lat, lon)) WHERE active;

    -- customer table --

    CREATE TABLE customer (
      customer_id  SERIAL PRIMARY KEY,
      name         TEXT NOT NULL,
      banned_from  INTEGER[] DEFAULT '{}',
      registered   TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE INDEX customer_name_idx ON customer USING BTREE (name);
    CREATE INDEX customer_banned_from_idx ON customer USING GIN (banned_from);

    -- feedback table --

    CREATE TABLE feedback (
      feedback_id  SERIAL PRIMARY KEY,
      business_id  INTEGER NOT NULL REFERENCES business (business_id),
      customer_id  INTEGER NOT NULL REFERENCES customer (customer_id),
      message      TEXT NOT NULL,
      last_edited  TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
 
    CREATE INDEX feedback_business_idx ON feedback USING BTREE (business_id);
    CREATE INDEX feedback_customer_idx ON feedback USING BTREE (customer_id);
    CREATE INDEX feedback_last_edited_idx ON feedback USING BRIN (last_edited);
EOSQL
