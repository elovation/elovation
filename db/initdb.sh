#!/bin/bash
set -e

#echo "Passwords"
#echo $POSTGRESS_PASSWORD
#echo $ELOVATION_DB_USER_PASSWORD
#echo $ELOVATION_DB_ADMIN_PASSWORD

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER elovation_admin WITH PASSWORD '$ELOVATION_DB_USER_PASSWORD';
    CREATE USER elovation_user WITH PASSWORD '$ELOVATION_DB_ADMIN_PASSWORD';
    CREATE DATABASE elovation_db;
    REVOKE CONNECT ON DATABASE elovation_db FROM PUBLIC;
    GRANT ALL PRIVILEGES ON DATABASE elovation_db TO elovation_admin;
    GRANT CONNECT ON DATABASE elovation_db TO elovation_user;
    \connect elovation_db;
    GRANT USAGE ON SCHEMA public TO elovation_user;
EOSQL

#export PGPASSWORD='$ELOVATION_DB_ADMIN_PASSWORD'

psql -v ON_ERROR_STOP=1 --username "elovation_admin" -d "elovation_db" <<-EOSQL
    ALTER DEFAULT PRIVILEGES FOR ROLE elovation_admin IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO elovation_user;
    ALTER DEFAULT PRIVILEGES FOR ROLE elovation_admin IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO elovation_user;
EOSQL