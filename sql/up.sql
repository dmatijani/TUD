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
    id INT PRIMARY KEY,
    datoteka OID NOT NULL,
    hash CHAR(64) NOT NULL
);

CREATE TABLE dokument (
    id INT PRIMARY KEY,
    datoteka_id INT REFERENCES datoteka(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    naziv VARCHAR(255) NOT NULL,
    opis TEXT,
    vrijedi TSRANGE NOT NULL DEFAULT tsrange(NOW()::TIMESTAMP, 'infinity'::TIMESTAMP),
    finalna BOOLEAN NOT NULL DEFAULT FALSE,
    dodatno JSON NOT NULL DEFAULT '{}'::JSON,
    vrsta vrsta_dokumenta NOT NULL DEFAULT 'OSTALO'
);

CREATE TABLE grupa (
    id INT PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL
);

CREATE TABLE korisnik (
    id INT PRIMARY KEY,
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
    id INT PRIMARY KEY,
    naziv VARCHAR(100) NOT NULL,
    radnje radnja[] NOT NULL
);

CREATE TABLE pristup_korisnik (
    korisnik_id INT REFERENCES korisnik(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    pravo_id INT REFERENCES pravo(id),
    PRIMARY KEY (korisnik_id, dokument_id)
);

CREATE TABLE pristup_grupa (
    grupa_id INT REFERENCES grupa(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    pravo_id INT REFERENCES pravo(id),
    PRIMARY KEY (grupa_id, dokument_id)
);

COMMIT;