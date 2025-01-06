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

CREATE TABLE korisnik (
    id SERIAL PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    korime VARCHAR(50) NOT NULL UNIQUE,
    lozinka_hash CHAR(64) NOT NULL,
    vrijeme_registracije TIMESTAMP NOT NULL DEFAULT NOW()::TIMESTAMP,
    adresa TEXT,
    telefon TEXT
);

CREATE TABLE grupa (
    id SERIAL PRIMARY KEY,
    naziv VARCHAR(255) NOT NULL,
    vlasnik_id INT REFERENCES korisnik(id) DEFAULT NULL
);

CREATE TABLE korisnik_u_grupi (
    korisnik_id INT REFERENCES korisnik(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    grupa_id INT REFERENCES grupa(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    vrijeme_pridruzivanja TIMESTAMP NOT NULL DEFAULT NOW()::TIMESTAMP,
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

INSERT INTO pravo VALUES (
    'vlasnik',
    '{"create", "read", "update", "delete"}'
);

INSERT INTO pravo VALUES (
    'citanje',
    '{"read"}'
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

CREATE OR REPLACE FUNCTION registriraj_korisnika(ime TEXT, prezime TEXT, novo_korime TEXT, novi_email TEXT, lozinka TEXT)
RETURNS VOID
AS $$
    DECLARE
        korime_postoji BOOLEAN;
        declare email_postoji BOOLEAN;
    BEGIN
        korime_postoji := EXISTS(
            SELECT id FROM korisnik
            WHERE korime = novo_korime
        );

        IF korime_postoji THEN
            RAISE EXCEPTION '%','Korisnik s tim korisničkim imenom već postoji!';
        END IF;

        email_postoji := EXISTS(
            SELECT id FROM korisnik
            WHERE email = novi_email
        );

        IF email_postoji THEN
            RAISE EXCEPTION '%', 'Korisnik s tom email adresom već postoji!';
        END IF;

        IF NOT (novi_email ~ '^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') THEN
            RAISE EXCEPTION '%', 'Email nije ispravan!';
        END IF;

        INSERT INTO korisnik(ime, prezime, korime, email, lozinka_hash) VALUES (
            ime,
            prezime,
            novo_korime,
            novi_email,
            encode(sha256(lozinka::bytea), 'hex')
        );
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION podaci_o_korisniku(id INT)
RETURNS TABLE(
    id INT,
    ime TEXT,
    prezime TEXT,
    email TEXT,
    korime TEXT,
    vrijeme_registracije TIMESTAMP,
    adresa TEXT,
    telefon TEXT,
    grupe JSON
)
AS $$
SELECT
    k.id,
    k.ime,
    k.prezime,
    k.email,
    k.korime,
    k.vrijeme_registracije,
    k.adresa,
    k.telefon,
    COALESCE(
        (SELECT json_agg(json_build_object(
            'grupa_id', g.id,
            'naziv', g.naziv,
            'vrijeme_uclanjivanja', kug.vrijeme_pridruzivanja,
            'je_vlasnik', COALESCE((g.vlasnik_id = k.id), false)::BOOLEAN
        ))
         FROM korisnik_u_grupi kug
         JOIN grupa g ON kug.grupa_id = g.id
         WHERE kug.korisnik_id = k.id),
        '[]'::json
    ) AS grupe
FROM
    korisnik k
WHERE
    k.id = $1;
$$
LANGUAGE sql;

CREATE OR REPLACE FUNCTION podaci_o_grupi(grupa_id INT, korisnik_id INT)
RETURNS TABLE(
    id INT,
    naziv VARCHAR(255),
    vlasnik_id INT,
    vlasnik TEXT,
    email_vlasnika VARCHAR(50),
    clanovi JSON
)
AS $$
DECLARE
    clan_grupe BOOLEAN;
BEGIN
    clan_grupe := EXISTS(
        SELECT * FROM korisnik_u_grupi kug
        WHERE kug.grupa_id = $1
        AND kug.korisnik_id = $2
    );

    IF NOT clan_grupe THEN
        RAISE EXCEPTION '%', 'Korisnik nije član grupe!';
    END IF;

    RETURN QUERY
    SELECT
        g.id,
        g.naziv,
        v.id as vlasnik_id,
        CONCAT(v.ime, ' ', v.prezime)::TEXT AS vlasnik,
        v.email AS email_vlasnika,
        COALESCE(
            (SELECT json_agg(json_build_object(
                'korisnik_id', k.id,
                'korisnik', CONCAT(k.ime, ' ', k.prezime),
                'vrijeme_uclanjivanja', kug.vrijeme_pridruzivanja,
                'je_vlasnik', COALESCE((g.vlasnik_id = k.id), false)::BOOLEAN
            ))
            FROM korisnik_u_grupi kug
            JOIN korisnik k ON kug.korisnik_id = k.id
            WHERE kug.grupa_id = g.id),
            '[]'::json
        ) AS clanovi
    FROM
        grupa g
    LEFT JOIN korisnik v
        ON g.vlasnik_id = v.id
    WHERE
        g.id = $1;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dodaj_clana_u_grupu(vlasnik_id INT, grupa_id INT, novi_clan_id INT)
RETURNS VOID
AS $$
DECLARE
    je_vlasnik BOOLEAN;
    vec_clan BOOLEAN;
BEGIN
    je_vlasnik := EXISTS(
        SELECT * FROM grupa g
        WHERE g.id = $2 AND g.vlasnik_id = $1
    );

    IF NOT je_vlasnik THEN
        RAISE EXCEPTION '%', 'Niste vlasnik grupe!';
    END IF;
    
    vec_clan := EXISTS(
        SELECT * FROM korisnik_u_grupi kug
        WHERE kug.grupa_id = $2 AND kug.korisnik_id = $3
    );

    IF vec_clan THEN
        RAISE EXCEPTION '%', 'Korisnik je već član grupe!';
    END IF;

    INSERT INTO korisnik_u_grupi(korisnik_id, grupa_id) VALUES ($3, $2);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ukloni_clana_iz_grupe(vlasnik_id INT, grupa_id INT, clan_id INT)
RETURNS VOID
AS $$
DECLARE
    je_vlasnik BOOLEAN;
    je_clan BOOLEAN;
BEGIN
    je_vlasnik := EXISTS(
        SELECT * FROM grupa g
        WHERE g.id = $2 AND g.vlasnik_id = $1
    );

    IF NOT je_vlasnik THEN
        RAISE EXCEPTION '%', 'Niste vlasnik grupe!';
    END IF;
    
    je_clan := EXISTS(
        SELECT * FROM korisnik_u_grupi kug
        WHERE kug.grupa_id = $2 AND kug.korisnik_id = $3
    );

    IF NOT je_clan THEN
        RAISE EXCEPTION '%', 'Korisnik nije član grupe!';
    END IF;

    DELETE FROM korisnik_u_grupi kug WHERE kug.grupa_id = $2 AND kug.korisnik_id = $3;
END;
$$
LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION dodaj_novog_korisnika_u_grupu_korisnika()
RETURNS TRIGGER
AS $$
    DECLARE
        postoji BOOLEAN;
        grupa_id INT;
    BEGIN
        postoji := EXISTS(
            SELECT * FROM grupa
            WHERE naziv = 'Korisnici'
        );

        IF NOT postoji THEN
            INSERT INTO grupa(naziv) VALUES ('Korisnici');
        END IF;

        SELECT id INTO grupa_id FROM grupa WHERE naziv = 'Korisnici';
        INSERT INTO korisnik_u_grupi VALUES (NEW.id, grupa_id);

        RETURN NEW;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER dodavanje_korisnika_u_grupu_korisnika
AFTER INSERT
ON korisnik
FOR EACH ROW
EXECUTE PROCEDURE dodaj_novog_korisnika_u_grupu_korisnika();

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