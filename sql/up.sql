BEGIN TRANSACTION;

-- Tablice i enumeracije

CREATE TYPE vrsta_dokumenta AS ENUM (
    'PROJEKTNA DOKUMENTACIJA',
    'SEMINARSKI RAD',
    'ZAVRŠNI RAD',
    'DIPLOMSKI RAD',
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
    'IZVJEŠTAJ PROJEKTA',
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
    vrsta vrsta_dokumenta NOT NULL DEFAULT 'OSTALO'
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

CREATE TABLE verzija_dokumenta (
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    vrijedi TSRANGE NOT NULL DEFAULT tsrange(NOW()::TIMESTAMP, 'infinity'::TIMESTAMP),
    verzija INT NOT NULL DEFAULT 1,
    datoteka_id INT REFERENCES datoteka(id),
    finalna BOOLEAN NOT NULL DEFAULT FALSE,
    kreirao_id INT NOT NULL REFERENCES korisnik(id),
    napomena TEXT,
    PRIMARY KEY (dokument_id, vrijedi)
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

CREATE TYPE pravo AS ENUM (
    'vlasnik',
    'čitanje'
);

CREATE TABLE pristup_korisnik (
    korisnik_id INT REFERENCES korisnik(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    pravo pravo,
    PRIMARY KEY (korisnik_id, dokument_id)
);

CREATE TABLE pristup_grupa (
    grupa_id INT REFERENCES grupa(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    dokument_id INT REFERENCES dokument(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
    pravo pravo,
    PRIMARY KEY (grupa_id, dokument_id)
);

-- Funkcije

CREATE OR REPLACE FUNCTION registriraj_korisnika(ime TEXT, prezime TEXT, novo_korime TEXT, novi_email TEXT, lozinka TEXT, adresa TEXT, telefon TEXT)
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

        INSERT INTO korisnik(ime, prezime, korime, email, lozinka_hash, adresa, telefon) VALUES (
            ime,
            prezime,
            novo_korime,
            novi_email,
            encode(sha256(lozinka::bytea), 'hex'),
            adresa,
            telefon
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

    IF vlasnik_id = clan_id THEN
        RAISE EXCEPTION '%', 'Nije moguće ukloniti vlasnika grupe!';
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

CREATE OR REPLACE FUNCTION korisnici_koji_nisu_clanovi_grupe(vlasnik_id INT, grupa_id INT)
RETURNS TABLE (
    id INT,
    ime VARCHAR(50),
    prezime VARCHAR(50),
    email VARCHAR(50),
    korime VARCHAR(50)
)
AS $$
DECLARE
    je_vlasnik BOOLEAN;
BEGIN
    je_vlasnik := EXISTS(
        SELECT * FROM grupa g
        WHERE g.id = $2 AND g.vlasnik_id = $1
    );

    IF NOT je_vlasnik THEN
        RAISE EXCEPTION '%', 'Niste vlasnik grupe!';
    END IF;

    RETURN QUERY
    SELECT k.id, k.ime, k.prezime, k.email, k.korime
    FROM korisnik k
    WHERE k.id NOT IN (
        SELECT kug.korisnik_id
        FROM korisnik_u_grupi kug
        WHERE kug.grupa_id = $2
    );
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION stvori_grupu(naziv TEXT, vlasnik_id INT)
RETURNS INT
AS $$
DECLARE
    postoji_slicna BOOLEAN;
    novi_id INT;
BEGIN
    postoji_slicna := EXISTS(
        SELECT * FROM grupa g
        WHERE g.naziv = $1
    );

    IF postoji_slicna THEN
        RAISE EXCEPTION '%', 'Već postoji grupa s tim nazivom!';
    END IF;

    INSERT INTO grupa(naziv, vlasnik_id) VALUES ($1, $2)
    RETURNING id INTO novi_id;

    RETURN novi_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nova_datoteka(naziv TEXT, putanja TEXT)
RETURNS INT
AS $$
DECLARE
    novi_id INT;
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
    )
    RETURNING id INTO novi_id;

    RETURN novi_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dohvati_grupe_i_korisnici_za_korisnika(korisnik_id INT)
RETURNS TABLE (
    id INT,
    naziv VARCHAR(255),
    korisnici JSON
)
AS $$
BEGIN
RETURN QUERY
    SELECT
        g.id,
        g.naziv,
        COALESCE(
            (SELECT json_agg(json_build_object(
                'korisnik_id', k.id,
                'korisnik', CONCAT(k.ime, ' ', k.prezime)
            ))
            FROM korisnik_u_grupi kug
            JOIN korisnik k ON kug.korisnik_id = k.id
            WHERE kug.grupa_id = g.id
            AND kug.korisnik_id != $1),
            '[]'::json
        ) AS clanovi
    FROM grupa g
    WHERE g.id IN (
        SELECT kug2.grupa_id
        FROM korisnik_u_grupi kug2
        WHERE kug2.korisnik_id = $1
    );
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prva_verzija_dokumenta(
    korisnik_id INT,
    naziv TEXT,
    opis TEXT,
    vrsta vrsta_dokumenta,
    finalna BOOLEAN,
    napomena TEXT,
    dijeli_s_grupama JSON,
    dijeli_s_korisnicima JSON,
    putanja TEXT,
    naziv_datoteke TEXT
)
RETURNS INT
AS $$
DECLARE
    postoji_dokument BOOLEAN;
    novi_dokument_id INT;
    nova_datoteka_id INT;
    obj JSON;
BEGIN
    postoji_dokument := EXISTS(
        SELECT * FROM dokument d
        WHERE d.naziv = $2
    );

    IF postoji_dokument THEN
        RAISE EXCEPTION '%', 'Dokument s tim nazivom već postoji!';
    END IF;

    INSERT INTO dokument(naziv, opis, vrsta) VALUES($2, $3, $4)
    RETURNING id INTO novi_dokument_id;

    SELECT nova_datoteka($10, $9) INTO nova_datoteka_id;

    INSERT INTO verzija_dokumenta(dokument_id, datoteka_id, finalna, kreirao_id, napomena)
    VALUES (novi_dokument_id, nova_datoteka_id, $5, $1, $6);

    INSERT INTO pristup_korisnik(korisnik_id, dokument_id, pravo)
    VALUES ($1, novi_dokument_id, 'vlasnik');

    IF $7 IS NOT NULL AND json_typeof($7) = 'array' THEN
        FOR obj IN SELECT * FROM json_array_elements($7) LOOP
            INSERT INTO pristup_grupa(grupa_id, dokument_id, pravo)
            VALUES (
                (obj->>'selectedGroup')::INT,
                novi_dokument_id,
                (obj->>'selectedRole')::pravo
            );
        END LOOP;
    END IF;

    IF $8 IS NOT NULL AND json_typeof($8) = 'array' THEN
        FOR obj IN SELECT * FROM json_array_elements($8) LOOP
            INSERT INTO pristup_korisnik(korisnik_id, dokument_id, pravo)
            VALUES (
                (obj->>'selectedUser')::INT,
                novi_dokument_id,
                (obj->>'selectedRole')::pravo
            );
        END LOOP;
    END IF;

    RETURN novi_dokument_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dohvati_popis_mojih_dokumenata(korisnik_id INT)
RETURNS TABLE (
    id INT,
    naziv VARCHAR(255),
    vrsta TEXT,
    broj_verzija INT,
    prva_izmjena TIMESTAMP,
    prvi_izmijenio TEXT,
    ima_finalnu BOOL,
    zadnja_izmjena TIMESTAMP,
    zadnji_izmijenio TEXT
)
AS $$
SELECT
    d.id,
    d.naziv,
    d.vrsta::TEXT,
    COUNT(v.verzija) AS broj_verzija,
    MIN(LOWER(v.vrijedi)::TIMESTAMP) AS prva_izmjena,
    (SELECT CONCAT(k.ime, ' ', k.prezime)
        FROM korisnik k
        WHERE k.id = (
            SELECT v1.kreirao_id
            FROM verzija_dokumenta v1
            WHERE v1.dokument_id = d.id
            ORDER BY LOWER(v1.vrijedi) ASC
            LIMIT 1
        )
    ) AS prvi_izmijenio,
    EXISTS(
        SELECT * FROM verzija_dokumenta v2
        WHERE v2.dokument_id = d.id
        AND v2.finalna = TRUE
    ) AS ima_finalnu,
    MAX(LOWER(v.vrijedi)::TIMESTAMP) AS zadnja_izmjena,
    (SELECT CONCAT(k2.ime, ' ', k2.prezime)
        FROM korisnik k2
        WHERE k2.id = (
            SELECT v3.kreirao_id
            FROM verzija_dokumenta v3
            WHERE v3.dokument_id = d.id
            ORDER BY LOWER(v3.vrijedi) DESC
            LIMIT 1
        )
    ) AS zadnji_izmijenio
FROM dokument d 
LEFT JOIN verzija_dokumenta v 
ON d.id = v.dokument_id 
WHERE id IN (
    SELECT pk.dokument_id FROM pristup_korisnik pk
    WHERE pk.pravo = 'vlasnik'::pravo AND pk.korisnik_id = $1
    UNION
    SELECT pg.dokument_id FROM pristup_grupa pg
    WHERE pg.pravo = 'vlasnik'::pravo AND pg.grupa_id IN (
        SELECT kug.grupa_id FROM korisnik_u_grupi kug
        WHERE kug.korisnik_id = $1
    )
)
GROUP BY d.id
ORDER BY d.id;
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION dohvati_popis_dijeljenih_dokumenata(korisnik_id INT)
RETURNS TABLE (
    id INT,
    naziv VARCHAR(255),
    vrsta TEXT,
    broj_verzija INT,
    prva_izmjena TIMESTAMP,
    prvi_izmijenio TEXT,
    ima_finalnu BOOL,
    zadnja_izmjena TIMESTAMP,
    zadnji_izmijenio TEXT
)
AS $$
SELECT
    d.id,
    d.naziv,
    d.vrsta::TEXT,
    COUNT(v.verzija) AS broj_verzija,
    MIN(LOWER(v.vrijedi)::TIMESTAMP) AS prva_izmjena,
    (SELECT CONCAT(k.ime, ' ', k.prezime)
        FROM korisnik k
        WHERE k.id = (
            SELECT v1.kreirao_id
            FROM verzija_dokumenta v1
            WHERE v1.dokument_id = d.id
            ORDER BY LOWER(v1.vrijedi) ASC
            LIMIT 1
        )
    ) AS prvi_izmijenio,
    EXISTS(
        SELECT * FROM verzija_dokumenta v2
        WHERE v2.dokument_id = d.id
        AND v2.finalna = TRUE
    ) AS ima_finalnu,
    MAX(LOWER(v.vrijedi)::TIMESTAMP) AS zadnja_izmjena,
    (SELECT CONCAT(k2.ime, ' ', k2.prezime)
        FROM korisnik k2
        WHERE k2.id = (
            SELECT v3.kreirao_id
            FROM verzija_dokumenta v3
            WHERE v3.dokument_id = d.id
            ORDER BY LOWER(v3.vrijedi) DESC
            LIMIT 1
        )
    ) AS zadnji_izmijenio
FROM dokument d 
LEFT JOIN verzija_dokumenta v 
ON d.id = v.dokument_id 
WHERE id IN (
    SELECT pk.dokument_id FROM pristup_korisnik pk
    WHERE pk.pravo = 'čitanje'::pravo AND pk.korisnik_id = $1
    UNION
    SELECT pg.dokument_id FROM pristup_grupa pg
    WHERE pg.pravo = 'čitanje'::pravo AND pg.grupa_id IN (
        SELECT kug.grupa_id FROM korisnik_u_grupi kug
        WHERE kug.korisnik_id = $1
    )
) AND id NOT IN (
    SELECT pk.dokument_id FROM pristup_korisnik pk
    WHERE pk.pravo = 'vlasnik'::pravo AND pk.korisnik_id = $1
    UNION
    SELECT pg.dokument_id FROM pristup_grupa pg
    WHERE pg.pravo = 'vlasnik'::pravo AND pg.grupa_id IN (
        SELECT kug.grupa_id FROM korisnik_u_grupi kug
        WHERE kug.korisnik_id = $1
    )
)
GROUP BY d.id
ORDER BY d.id;
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION provjeri_pravo_korisnika_na_dokument(korisnik_id INT, dokument_id INT)
RETURNS pravo
AS $$
DECLARE
    ima_pravo BOOLEAN;
    je_vlasnik BOOLEAN;
BEGIN
    ima_pravo := EXISTS(
        SELECT * FROM pristup_korisnik pk
        WHERE pk.korisnik_id = $1 AND pk.dokument_id = $2
    );

    IF NOT ima_pravo THEN
        ima_pravo := EXISTS(
            SELECT * FROM pristup_grupa pg
            WHERE pg.dokument_id = $2
            AND pg.grupa_id IN (
                SELECT grupa_id FROM korisnik_u_grupi kug
                WHERE kug.korisnik_id = $1
            )
        );
    END IF;

    IF NOT ima_pravo THEN
        RAISE EXCEPTION '%', 'Nemate pristup ovom dokumentu!';
    END IF;

    je_vlasnik := EXISTS(
        SELECT pk.pravo FROM pristup_korisnik pk
        WHERE pk.korisnik_id = $1 AND pk.dokument_id = $2 AND pk.pravo = 'vlasnik'::pravo
        UNION
        SELECT pg.pravo FROM pristup_grupa pg
        WHERE pg.dokument_id = $2 AND pg.pravo = 'vlasnik'::pravo
        AND pg.grupa_id IN (
            SELECT grupa_id FROM korisnik_u_grupi kug
            WHERE kug.korisnik_id = $1
        )
    );

    IF je_vlasnik THEN
        RETURN 'vlasnik'::pravo;
    ELSE 
        RETURN 'čitanje'::pravo;
    END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dohvati_detalje_dokumenta(korisnik_id INT, dokument_id INT)
RETURNS TABLE (
    id INT,
    naziv VARCHAR(255),
    opis TEXT,
    vrsta vrsta_dokumenta,
    pravo pravo,
    ima_finalnu BOOL,
    verzije JSON,
    dijeljeno_s_korisnicima JSON,
    dijeljeno_s_grupama JSON
)
AS $$
DECLARE
    koje_pravo pravo;
BEGIN
    SELECT provjeri_pravo_korisnika_na_dokument($1, $2) INTO koje_pravo;

    RETURN QUERY
    SELECT
        d.id,
        d.naziv,
        d.opis,
        d.vrsta,
        koje_pravo,
        EXISTS(
            SELECT * FROM verzija_dokumenta vd
            WHERE vd.dokument_id = d.id
            AND vd.finalna = TRUE
        ) AS ima_finalnu,
        COALESCE(
            (SELECT json_agg(json_build_object(
                'vrijedi_od', LOWER(v.vrijedi)::TIMESTAMP,
                'vrijedi_do', UPPER(v.vrijedi)::TIMESTAMP,
                'verzija', v.verzija,
                'finalna', v.finalna,
                'kreirao', CONCAT(k.ime, ' ', k.prezime),
                'napomena', v.napomena,
                'datoteka_id', dat.id,
                'naziv_datoteke', dat.naziv
            ) ORDER BY v.verzija DESC)
            FROM verzija_dokumenta v
            LEFT JOIN datoteka dat
            ON v.datoteka_id = dat.id
            LEFT JOIN korisnik k
            ON k.id = v.kreirao_id
            WHERE v.dokument_id = d.id),
            '[]'::json
        ) AS verzije,
        COALESCE(
            (SELECT json_agg(json_build_object(
                'naziv', CONCAT(k.ime, ' ', k.prezime),
                'pravo', pk.pravo
            ))
            FROM pristup_korisnik pk
            LEFT JOIN korisnik k
            ON pk.korisnik_id = k.id
            WHERE pk.dokument_id = d.id
            ),
            '[]'::json
        ) AS dijeljeno_s_korisnicima,
        COALESCE(
            (SELECT json_agg(json_build_object(
                'naziv', g.naziv,
                'pravo', pg.pravo
            ))
            FROM pristup_grupa pg
            LEFT JOIN grupa g
            ON pg.grupa_id = g.id
            WHERE pg.dokument_id = d.id
            ),
            '[]'::json
        ) AS dijeljeno_s_grupama
    FROM dokument d
    WHERE d.id = $2;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION preuzmi_datoteku(korisnik_id INT, datoteka_id INT)
RETURNS TABLE(
    temp_naziv TEXT,
    naziv_datoteke TEXT
)
AS $$
DECLARE
    dokument_id INT;
    temp_naziv TEXT;
    naziv_datoteke TEXT;
BEGIN
    SELECT vd.dokument_id INTO dokument_id
    FROM verzija_dokumenta vd
    WHERE vd.datoteka_id = $2;

    PERFORM provjeri_pravo_korisnika_na_dokument($1, dokument_id);

    SELECT d.naziv INTO naziv_datoteke
    FROM datoteka d
    WHERE d.id = $2;

    SELECT '/tmp/' || gen_random_uuid() || '_' || naziv_datoteke INTO temp_naziv;

    PERFORM lo_export(d.datoteka, temp_naziv)
    FROM datoteka d
    WHERE d.id = $2;

    RETURN QUERY
    SELECT temp_naziv, naziv_datoteke;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nova_verzija_dokumenta(
    korisnik_id INT,
    dokument_id INT,
    finalna BOOLEAN,
    napomena TEXT,
    putanja TEXT,
    naziv_datoteke TEXT
)
RETURNS VOID
AS $$
DECLARE
    postoji_dokument BOOLEAN;
    koje_pravo pravo;
    postoji_finalna_verzija BOOLEAN;
    nova_datoteka_id INT;
BEGIN
    postoji_dokument := EXISTS(
        SELECT * FROM dokument
        WHERE id = $2
    );

    IF NOT postoji_dokument THEN
        RAISE EXCEPTION '%', 'Dokument s tim ID-om ne postoji!';
    END IF;

    SELECT provjeri_pravo_korisnika_na_dokument($1, $2) INTO koje_pravo;

    IF koje_pravo != 'vlasnik'::pravo THEN
        RAISE EXCEPTION '%', 'Korisnik nije vlasnik dokumenta!';
    END IF;

    postoji_finalna_verzija := EXISTS(
        SELECT * FROM verzija_dokumenta vd
        WHERE vd.dokument_id = $2
        AND vd.finalna = TRUE
    );

    IF postoji_finalna_verzija THEN
        RAISE EXCEPTION '%', 'Već postoji finalna verzija dokumenta!';
    END IF;

    SELECT nova_datoteka($6, $5) INTO nova_datoteka_id;

    INSERT INTO verzija_dokumenta(dokument_id, datoteka_id, finalna, kreirao_id, napomena)
    VALUES ($2, nova_datoteka_id, $3, $1, $4);
END;
$$
LANGUAGE plpgsql;

-- Napredno pretraživanje

CREATE OR REPLACE FUNCTION napredno_pretrazivanje(
    korisnik_id INT,
    naziv_dio TEXT DEFAULT NULL, -- Ako je NULL, ne primjenjuje se
    vrsta_upit vrsta_dokumenta DEFAULT NULL,
    min_broj_verzija INT DEFAULT NULL,
    max_broj_verzija INT DEFAULT NULL,
    kreiran_unutar_raspona TSRANGE DEFAULT NULL,
    zadnja_izmjena_unutar_raspona TSRANGE DEFAULT NULL,
    ima_finalnu_upit BOOLEAN DEFAULT NULL,
    prvi_izmijenio_upit INT DEFAULT NULL,
    dijeljeno_s_korisnicima INT[] DEFAULT NULL,
    dijeljeno_s_grupama INT[] DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    naziv VARCHAR(255),
    vrsta TEXT,
    broj_verzija INT,
    prva_izmjena TIMESTAMP,
    prvi_izmijenio TEXT,
    ima_finalnu BOOL,
    zadnja_izmjena TIMESTAMP,
    zadnji_izmijenio TEXT,
    pravo pravo
)
AS $$
BEGIN
    CREATE TEMP TABLE temp_dokumenti AS
    SELECT
        d.id,
        d.naziv,
        d.vrsta::TEXT,
        COUNT(v.verzija)::INT AS broj_verzija,
        MIN(LOWER(v.vrijedi)::TIMESTAMP) AS prva_izmjena,
        (SELECT CONCAT(k.ime, ' ', k.prezime)
            FROM korisnik k
            WHERE k.id = (
                SELECT v1.kreirao_id
                FROM verzija_dokumenta v1
                WHERE v1.dokument_id = d.id
                ORDER BY LOWER(v1.vrijedi) ASC
                LIMIT 1
            )
        ) AS prvi_izmijenio,
        EXISTS(
            SELECT * FROM verzija_dokumenta v2
            WHERE v2.dokument_id = d.id
            AND v2.finalna = TRUE
        ) AS ima_finalnu,
        MAX(LOWER(v.vrijedi)::TIMESTAMP) AS zadnja_izmjena,
        (SELECT CONCAT(k2.ime, ' ', k2.prezime)
            FROM korisnik k2
            WHERE k2.id = (
                SELECT v3.kreirao_id
                FROM verzija_dokumenta v3
                WHERE v3.dokument_id = d.id
                ORDER BY LOWER(v3.vrijedi) DESC
                LIMIT 1
            )
        ) AS zadnji_izmijenio,
        (SELECT * FROM provjeri_pravo_korisnika_na_dokument($1, d.id)) AS pravo
    FROM dokument d 
    LEFT JOIN verzija_dokumenta v 
    ON d.id = v.dokument_id 
    WHERE d.id IN (
        SELECT pk.dokument_id FROM pristup_korisnik pk
        WHERE pk.korisnik_id = $1
        UNION
        SELECT pg.dokument_id FROM pristup_grupa pg
        WHERE pg.grupa_id IN (
            SELECT kug.grupa_id FROM korisnik_u_grupi kug
            WHERE kug.korisnik_id = $1
        )
    )
    GROUP BY d.id
    ORDER BY d.id;

    CREATE TEMP TABLE temp_idovi(
        id INT
    );

    IF naziv_dio IS NOT NULL THEN -- Provjera ima li naziv dio
        DELETE FROM temp_idovi;

        INSERT INTO temp_idovi (id)
        SELECT td.id
        FROM temp_dokumenti td
        WHERE td.naziv LIKE '%' || naziv_dio || '%';

        DELETE FROM temp_dokumenti td
        WHERE td.id NOT IN (SELECT ti.id FROM temp_idovi ti);
    END IF;

    IF vrsta_upit IS NOT NULL THEN -- Provjera je li dokument određene vrste
        DELETE FROM temp_dokumenti td
        WHERE td.vrsta::TEXT != vrsta_upit::TEXT;
    END IF;

    IF min_broj_verzija IS NOT NULL THEN -- Provjera minimalnog broja verzija dokumenta
        DELETE FROM temp_dokumenti td
        WHERE td.broj_verzija < min_broj_verzija;
    END IF;

    IF max_broj_verzija IS NOT NULL THEN -- Provjera najvećeg broja verzija dokumenta
        DELETE FROM temp_dokumenti td
        WHERE td.broj_verzija > max_broj_verzija;
    END IF;

    IF kreiran_unutar_raspona IS NOT NULL THEN -- Provjera je li dokument kreiran unutar određenog raspona
        DELETE FROM temp_idovi;

        INSERT INTO temp_idovi (id)
        SELECT td.id
        FROM temp_dokumenti td
        WHERE kreiran_unutar_raspona @> td.prva_izmjena;

        DELETE FROM temp_dokumenti td
        WHERE td.id NOT IN (SELECT ti.id FROM temp_idovi ti);
    END IF;

    IF zadnja_izmjena_unutar_raspona IS NOT NULL THEN -- Provjera je li zadnja izmjena dokumenta unutar određenog raspona
        DELETE FROM temp_idovi;

        INSERT INTO temp_idovi (id)
        SELECT td.id
        FROM temp_dokumenti td
        WHERE zadnja_izmjena_unutar_raspona @> td.zadnja_izmjena;

        DELETE FROM temp_dokumenti td
        WHERE td.id NOT IN (SELECT ti.id FROM temp_idovi ti);
    END IF;

    IF ima_finalnu_upit IS NOT NULL THEN -- Provjera ima li dokument finalnu verziju
        DELETE FROM temp_dokumenti td
        WHERE td.ima_finalnu != ima_finalnu_upit;
    END IF;

    IF prvi_izmijenio_upit IS NOT NULL THEN -- Provjera je li taj korisnik prvi izmijenio upit
        DELETE FROM temp_idovi;

        INSERT INTO temp_idovi (id)
        SELECT vd.dokument_id AS id
        FROM verzija_dokumenta vd
        WHERE vd.verzija = 1
        AND vd.kreirao_id = prvi_izmijenio_upit;

        DELETE FROM temp_dokumenti td
        WHERE td.id NOT IN (SELECT ti.id FROM temp_idovi ti);
    END IF;

    IF dijeljeno_s_korisnicima IS NOT NULL THEN -- Provjera je li dokument dijeljen s popisanim korisnicima
        DELETE FROM temp_idovi;

        INSERT INTO temp_idovi (id)
        SELECT pk.dokument_id AS id
        FROM pristup_korisnik pk
        WHERE pk.korisnik_id = ANY(dijeljeno_s_korisnicima);

        DELETE FROM temp_dokumenti td
        WHERE td.id NOT IN (SELECT ti.id FROM temp_idovi ti);
    END IF;

    IF dijeljeno_s_grupama IS NOT NULL THEN -- Provjera je li dokument dijeljen s popisanim grupama
        DELETE FROM temp_idovi;

        INSERT INTO temp_idovi (id)
        SELECT pg.dokument_id AS id
        FROM pristup_grupa pg
        WHERE pg.grupa_id = ANY(dijeljeno_s_grupama);

        DELETE FROM temp_dokumenti td
        WHERE td.id NOT IN (SELECT ti.id FROM temp_idovi ti);
    END IF;

    RETURN QUERY
    SELECT * FROM temp_dokumenti td;

    DROP TABLE temp_idovi;
    DROP TABLE temp_dokumenti;
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

CREATE OR REPLACE FUNCTION dodaj_vlasnika_kao_clana_grupe()
RETURNS TRIGGER
AS $$
DECLARE
    vec_dodan BOOLEAN;
BEGIN
    IF NEW.vlasnik_id IS NULL THEN
        RETURN NULL;
    END IF;

    vec_dodan := EXISTS(
        SELECT * FROM korisnik_u_grupi
        WHERE grupa_id = NEW.id AND korisnik_id = NEW.vlasnik_id
    );

    IF NOT vec_dodan THEN
        INSERT INTO korisnik_u_grupi(grupa_id, korisnik_id)
        VALUES (NEW.id, NEW.vlasnik_id);
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER dodavanje_vlasnika_kao_clana_grupe
AFTER INSERT
ON grupa
FOR EACH ROW
EXECUTE PROCEDURE dodaj_vlasnika_kao_clana_grupe();

COMMIT;