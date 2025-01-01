BEGIN TRANSACTION;

-- Tablice i enumeracije

CREATE TYPE vrsta_dokumenta AS ENUM (
    'PROJEKTNA_DOKUMENTACIJA',
    'SEMINARSKI_RAD',
    'ZAVRŠNI_RAD',
    'DIPLOMSKI_RAD',
    'UGOVOR',
    'FAKTURA',
    'PONUDA',
    'IZVJEŠTAJ',
    'POLITIKA',
    'ZAPISNIK',
    'UPUTSTVO',
    'OBAVIJEST',
    'ODLUKA',
    'DOZVOLA',
    'TUŽBA',
    'SPECIFIKACIJA',
    'DIZAJN',
    'BIOGRAFIJA',
    'IDENTIFIKACIJA',
    'PLAN',
    'PROCJENA',
    'IZVJEŠTAJ_PROJEKTA',
    'ARHIVA',
    'OSTALO'
);

CREATE TABLE datoteka (
    id SERIAL PRIMARY KEY,
    datoteka OID NOT NULL,
    naziv VARCHAR(255) NOT NULL,
    velicina BIGINT NOT NULL,
    hash CHAR(64) NOT NULL
);

CREATE TABLE dokument (
    id SERIAL PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL,
    opis TEXT,
    dodatno JSON NOT NULL DEFAULT '{}'::JSON,
    vrsta vrsta_dokumenta NOT NULL DEFAULT 'OSTALO'
);

CREATE TABLE verzija_dokumenta (
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    vrijedi TSRANGE NOT NULL DEFAULT tsrange(NOW()::TIMESTAMP, 'infinity'::TIMESTAMP),
    verzija INT NOT NULL DEFAULT 1,
    datoteka_id INT REFERENCES datoteka(id),
    finalna BOOLEAN NOT NULL DEFAULT FALSE,
    napomena TEXT,
    PRIMARY KEY (dokument_id, vrijedi)
);

CREATE TABLE grupa (
    id SERIAL PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL
);

CREATE TABLE korisnik (
    id SERIAL PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    korime VARCHAR(50) NOT NULL UNIQUE,
    lozinka_hash CHAR(64) NOT NULL,
    adresa TEXT,
    telefon TEXT
);

CREATE TABLE korisnik_u_grupi (
    korisnik_id INT REFERENCES korisnik(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    grupa_id INT REFERENCES grupa(id),
    PRIMARY KEY (korisnik_id, grupa_id)
);

CREATE TYPE radnja AS ENUM (
    'create',
    'read',
    'update',
    'delete'
);

CREATE TABLE pravo (
    naziv TEXT PRIMARY KEY,
    radnje radnja[] NOT NULL
);

CREATE TABLE pristup_korisnik (
    korisnik_id INT REFERENCES korisnik(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    pravo TEXT REFERENCES pravo(naziv),
    PRIMARY KEY (korisnik_id, dokument_id)
);

CREATE TABLE pristup_grupa (
    grupa_id INT REFERENCES grupa(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    pravo TEXT REFERENCES pravo(naziv),
    PRIMARY KEY (grupa_id, dokument_id)
);

-- Funkcije

CREATE OR REPLACE FUNCTION nova_datoteka(naziv TEXT, putanja TEXT)
RETURNS VOID
AS $$
    DECLARE
        oid OID;
        data BYTEA;
    BEGIN
        oid := lo_import(putanja);
        SELECT lo_get(oid) INTO data;
        INSERT INTO datoteka (datoteka, naziv, velicina, hash)
        VALUES (
            oid,
            naziv,
            octet_length(data),
            encode(sha256(data), 'hex')
        );
    END;
$$
LANGUAGE plpgsql;

-- Okidači (i funkcije)

CREATE OR REPLACE FUNCTION insert_nove_verzije()
RETURNS TRIGGER
AS $$
    DECLARE
        postoji BOOLEAN;
        prethodna_verzija INT;
    BEGIN
        postoji := EXISTS(
            SELECT * FROM verzija_dokumenta
            WHERE dokument_id = NEW.dokument_id
        );
        IF NOT postoji THEN
            RETURN NEW;
        ELSE
            SELECT verzija INTO prethodna_verzija
            FROM verzija_dokumenta
            WHERE dokument_id = NEW.dokument_id
            AND UPPER(vrijedi) = 'infinity'::TIMESTAMP;

            UPDATE verzija_dokumenta
            SET vrijedi = tsrange(
                LOWER(vrijedi)::TIMESTAMP,
                NOW()::TIMESTAMP
            )
            WHERE dokument_id = NEW.dokument_id
            AND UPPER(vrijedi) = 'infinity'::TIMESTAMP;

            NEW.verzija = prethodna_verzija + 1;
        END IF;

        RETURN NEW;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_nova_verzija
BEFORE INSERT
ON verzija_dokumenta
FOR EACH ROW
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE insert_nove_verzije();

CREATE OR REPLACE FUNCTION update_nove_verzije()
RETURNS TRIGGER
AS $$
    DECLARE
        prethodna_verzija INT;
    BEGIN
        IF UPPER(OLD.vrijedi) = 'infinity'::TIMESTAMP THEN
            SELECT verzija INTO prethodna_verzija
            FROM verzija_dokumenta
            WHERE dokument_id = NEW.dokument_id
            AND UPPER(vrijedi) = 'infinity'::TIMESTAMP;

            UPDATE verzija_dokumenta
            SET vrijedi = tsrange(
                LOWER(vrijedi)::TIMESTAMP,
                NOW()::TIMESTAMP
            )
            WHERE dokument_id = NEW.dokument_id
            AND UPPER(vrijedi) = 'infinity'::TIMESTAMP;

            INSERT INTO verzija_dokumenta (dokument_id, verzija, datoteka_id, finalna, napomena)
            VALUES (
                NEW.dokument_id,
                prethodna_verzija + 1,
                NEW.datoteka_id,
                NEW.finalna,
                NEW.napomena
            );
        END IF;

        RETURN null;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_nova_verzija
BEFORE UPDATE
ON verzija_dokumenta
FOR EACH ROW
WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE update_nove_verzije();

COMMIT;