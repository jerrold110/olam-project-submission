#!/bin/bash

DB_USER="user_1"
DB_PASSWORD="user_1"
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="alpha"

SQL_SCRIPT="create_tables.sql"

PSQL_COMMAND="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -W -f $SQL_SCRIPT"

$PSQL_COMMAND

if [ $? -eq 0 ]; then
    echo "Script executed successfully"
else
    echo "Error executing script"
fi
