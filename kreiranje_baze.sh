#!/bin/bash

# Po potrebi prije izvršavanja skripte pokrenuti: 'chmod +x kreiranje_baze.sh'
# Skriptu izvršiti sa: './kreiranje_baze.sh'
# Po potrebi promijeniti naziv baze ovdje:
DB_NAME="tud" # Ako se podaci promijene ovdje, potrebno je u datoteci './app/server/config/config.json' također ažurirati podatke!

# Ako skripta ne radi, ručno kreirati novu bazu 'tud' u postgres konzoli i zalijepiti sadržaj datoteke './sql/up.sql' (s konfiguriranjem ranije spomenute config datoteke)

SQL_SCRIPT="./sql/up.sql" # Ovo NE mijenjati!
TEMP_SQL_SCRIPT="/tmp/up_tud.sql"

echo "Kreiram bazu '$DB_NAME' i izvršavam '$SQL_SCRIPT'..."

if [ ! -r "$SQL_SCRIPT" ]; then
    echo "Greška: Datoteka '$SQL_SCRIPT' nije čitljiva ili ne postoji."
    exit 1
fi

cp "$SQL_SCRIPT" "$TEMP_SQL_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Greška: Ne mogu kopirati '$SQL_SCRIPT' u '/tmp'."
    exit 1
fi

sudo -u postgres psql <<EOF
CREATE DATABASE $DB_NAME;
\c $DB_NAME
\i '$TEMP_SQL_SCRIPT'
EOF

if [ $? -eq 0 ]; then
    echo "Baza '$DB_NAME' uspešno kreirana i skripta izvršena!"
else
    echo "Greška pri kreiranju baze ili izvršavanju skripte."
    exit 1
fi
