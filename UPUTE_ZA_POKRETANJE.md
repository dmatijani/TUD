# Upute za pokretanje

### Prije samog pokretanja

Prije pokretanja, potrebno je instalirati Postgres i NodeJS.

Postgres: https://www.postgresql.org/

NodeJS: https://nodejs.org/en

Konkretne verzije koje su se koristile kod ovog projekta su Node v22.13.0 i Postgres 14.15.
Postgres je takav kakav je instaliran kroz skriptu [instalacije.sh](http://dragon.foi.hr/foi24/instalacije.sh'), pripremljene za izvođenje laboratorijskih vježbi na kolegiju 'Teorija baza podataka'.

Upute za instalaciju možete naći na internetu ili službenim stranicama.

### Kreiranje baze

Nakon što je postgres instaliran, potrebno je izvršiti skriptu 'kreiranje_baze.sh' na sljedeći način:
1. Pozicionirani u ovaj direktorij, izvršiti naredbu 'chmod +x kreiranje_baze.sh'.
2. Skriptu izvršiti sa './kreiranje_baze.sh'. Po potrebi izvršiti sa 'sudo ./kreiranje_baze.sh'.

Ako nešto ne radi, u konzolu će se ispisati komentar, a i unutar same skripte se nalaze komentari s dodatnim objašnjenjima.

### Priprema poslužiteljske aplikacije

Prije samog pokretanja aplikacije, još je potrebno instalirati _node modules_ kako bi mogla raditi:
1. Otići u './app/server' i izvršiti naredbu 'npm run pripremi' (npm se najčešće instalira s Node).
2. Po potrebi izmijeniti './app/server/config/config.json' ako su podaci za prijavu na postgres različiti od uobičajenih i ako ste mijenjali naziv baze u skripti za kreiranje iste.

### Pokretanje servera

Server se sada može pokrenuti sa 'npm start'. Dalje je potrebno otići na bilo koji web preglednik i kao adresu staviti 'localhost:12345', odnosno koji već port se ispiše u konzoli.