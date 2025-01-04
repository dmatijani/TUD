BEGIN TRANSACTION;

-- Okidači (i funkcije)

DROP TRIGGER update_nova_verzija ON verzija_dokumenta;

DROP FUNCTION update_nove_verzije();

DROP TRIGGER insert_nova_verzija ON verzija_dokumenta;

DROP FUNCTION insert_nove_verzije();

DROP TRIGGER dodavanje_korisnika_u_grupu_korisnika ON korisnik;

DROP FUNCTION dodaj_novog_korisnika_u_grupu_korisnika();

-- Funkcije

DROP FUNCTION nova_datoteka(TEXT, TEXT);

-- Tablice i enumeracije

DROP TABLE pristup_grupa;

DROP TABLE pristup_korisnik;

DROP TABLE pravo;

DROP TYPE radnja;

DROP TABLE korisnik_u_grupi;

DROP TABLE korisnik;

DROP TABLE grupa;

DROP TABLE verzija_dokumenta;

DROP TABLE dokument;

DROP TABLE datoteka;

DROP TYPE vrsta_dokumenta;

COMMIT;