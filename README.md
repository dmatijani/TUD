# TUD

Sustav za **temporalno upravljanje dokumentima**. Razvijen kao projekt u sklopu kolegija 'Teorija baza podataka' na prvoj godini diplomskog studija 'Informacijsko i programsko inženjerstvo' na Fakultetu organizacije i informatike.

Ovaj projekt je otvoreni softver licenciran pod GNU General Public License v3.0.

## Licenca

Ovaj projekt je licenciran pod GNU GPLv3. Detalje možete pronaći u datoteci `LICENSE.md`.

## Upotreba

Slobodni ste koristiti, mijenjati i distribuirati ovaj projekt pod uvjetima GNU GPLv3 licence.

## Pokretanje aplikacije

**Nešto detaljnije upute nalaze se u datoteci 'UPUTE_ZA_POKRETANJE.md'.**

Potrebno je izvršiti skriptu 'kreiranje_baze.sh' na sljedeći način:
1. Pozicionirani u ovaj direktorij, izvršiti naredbu 'chmod +x kreiranje_baze.sh'.
2. Skriptu izvršiti sa './kreiranje_baze.sh'. Po potrebi izvršiti sa 'sudo ./kreiranje_baze.sh'.

Ako nešto ne radi, u konzolu će se ispisati komentar, a i unutar same skripte se nalaze komentari s dodatnim objašnjenjima.

#### Priprema poslužiteljske aplikacije

Prije samog pokretanja aplikacije, još je potrebno instalirati _node modules_ kako bi mogla raditi:
1. Otići u './app/server' i izvršiti naredbu 'npm run pripremi' (npm se najčešće instalira s Node).
2. Po potrebi izmijeniti './app/server/config/config.json' ako su podaci za prijavu na postgres različiti od uobičajenih i ako ste mijenjali naziv baze u skripti za kreiranje iste.

#### Pokretanje servera

Server se sada može pokrenuti sa 'npm start'. Dalje je potrebno otići na bilo koji web preglednik i kao adresu staviti 'localhost:12345', odnosno koji već port se ispiše u konzoli.

## Ostalo

Slika na pozadini aplikacije preuzeta je sa sljedeće poveznice: https://pixabay.com/photos/cortina-dampezzo-mountain-italy-9307295/
