#!/bin/bash

DB_USER="user_1"
DB_PASSWORD="user_1"
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="alpha"

# Create tables
SQL_SCRIPT="create_tables.sql"
PSQL_COMMAND="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -W -f $SQL_SCRIPT"
$PSQL_COMMAND

# Load data into staging with pgfutter
LOAD_SCRIPT="load_stage.sql"
LOAD_COMMAND="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -W -f $LOAD_SCRIPT"
$LOAD_COMMAND


# Load data from staging into tables

