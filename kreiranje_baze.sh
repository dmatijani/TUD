#!/bin/bash

# Po potrebi prije izvršavanja skripte pokrenuti: 'chmod +x kreiranje_baze.sh'
# Skriptu izvršiti sa: './kreiranje_baze.sh'
# Po potrebi promijeniti podatke ovdje:
DB_NAME="tud"
DB_USER="postgres"
DB_PASSWORD="postgres"
# Ako se podaci promijene ovdje, potrebno je u datoteci './app/server/config/config.json' također ažurirati podatke!

# Ako skripta ne radi, ručno kreirati novu bazu 'tud' u postgres konzoli i zalijepiti sadržaj datoteke './sql/up.sql' (s konfiguriranjem config datoteke)

SQL_SCRIPT="./sql/up.sql" # Ovo NE mijenjati!

if [ ! -f "$SQL_SCRIPT" ]; then
    echo "Greška: Datoteka '$SQL_SCRIPT' ne postoji!"
    exit 1
fi

echo "Kreiram bazu '$DB_NAME' i izvršavam '$SQL_SCRIPT'..."

export PGPASSWORD="$DB_PASSWORD"

psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"

if [ $? -ne 0 ]; then
    echo "Greška pri kreiranju baze."
    exit 1
fi

psql -U "$DB_USER" -d "$DB_NAME" -f "$SQL_SCRIPT"

if [ $? -ne 0 ]; then
    echo "Greška pri izvršavanju SQL skripte."
    exit 1
fi

echo "Baza '$DB_NAME' je uspešno kreirana!"
