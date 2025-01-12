BEGIN TRANSACTION;

-- Okidači (i funkcije)

DROP TRIGGER dodavanje_vlasnika_kao_clana_grupe ON grupa;

DROP FUNCTION dodaj_vlasnika_kao_clana_grupe();

DROP TRIGGER update_nova_verzija ON verzija_dokumenta;

DROP FUNCTION update_nove_verzije();

DROP TRIGGER insert_nova_verzija ON verzija_dokumenta;

DROP FUNCTION insert_nove_verzije();

DROP TRIGGER dodavanje_korisnika_u_grupu_korisnika ON korisnik;

DROP FUNCTION dodaj_novog_korisnika_u_grupu_korisnika();

-- Funkcije

DROP FUNCTION nova_verzija_dokumenta(INT, INT, BOOLEAN, TEXT, TEXT, TEXT);

DROP FUNCTION preuzmi_datoteku(INT, INT);

DROP FUNCTION dohvati_detalje_dokumenta(INT, INT);

DROP FUNCTION provjeri_pravo_korisnika_na_dokument(INT, INT);

DROP FUNCTION dohvati_popis_dijeljenih_dokumenata(INT);

DROP FUNCTION dohvati_popis_mojih_dokumenata(INT);

DROP FUNCTION prva_verzija_dokumenta(INT, TEXT, TEXT, vrsta_dokumenta, BOOLEAN, TEXT, JSON, JSON, TEXT, TEXT);

DROP FUNCTION dohvati_grupe_i_korisnici_za_korisnika(INT);

DROP FUNCTION nova_datoteka(TEXT, TEXT);

DROP FUNCTION stvori_grupu(TEXT, INT);

DROP FUNCTION korisnici_koji_nisu_clanovi_grupe(INT, INT);

DROP FUNCTION ukloni_clana_iz_grupe(INT, INT, INT);

DROP FUNCTION dodaj_clana_u_grupu(INT, INT, INT);

DROP FUNCTION podaci_o_grupi(INT, INT);

DROP FUNCTION podaci_o_korisniku(INT);

DROP FUNCTION registriraj_korisnika(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);

-- Tablice i enumeracije

DROP TABLE pristup_grupa;

DROP TABLE pristup_korisnik;

DROP TYPE pravo;

DROP TABLE korisnik_u_grupi;

DROP TABLE grupa;

DROP TABLE verzija_dokumenta;

DROP TABLE korisnik;

DROP TABLE dokument;

DROP TABLE datoteka;

DROP TYPE vrsta_dokumenta;

COMMIT;