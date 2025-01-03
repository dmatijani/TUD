CREATE USER tudadmin WITH ENCRYPTED PASSWORD 'tud';
CREATE DATABASE tud_test WITH OWNER = 'tudadmin';
GRANT ALL PRIVILEGES ON DATABASE tud_test TO tudadmin;

\c tud_test

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO tudadmin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO tudadmin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO tudadmin;

-- OVDJE pozvati up.sql

\c postgres;