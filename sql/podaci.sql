BEGIN TRANSACTION;

INSERT INTO korisnik (ime, prezime, email, korime, lozinka_hash) VALUES (
    'Običan',
    'Korisnik',
    'obicankorisnik@nekimail',
    'obican',
    encode(sha256('obican'), 'hex')
);

INSERT INTO pravo VALUES (
    'vlasnik',
    '{"create", "read", "update", "delete"}'
);

INSERT INTO pravo VALUES (
    'citanje',
    '{"read"}'
);

INSERT INTO grupa (naziv) VALUES ('Korisnici');

INSERT INTO korisnik_u_grupi VALUES (1, 1);

COMMIT;