BEGIN TRANSACTION;

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