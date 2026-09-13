# Running Valgrind Memcheck

Za runtime analizu memorije koristi se **Valgrind Memcheck**.

Memcheck izvršava program pod nadzorom i proverava, između ostalog:

- nevalidna čitanja i upise u memoriju;
- upotrebu neinicijalizovanih vrednosti;
- nepravilno oslobađanje memorije;
- curenje memorije pri završetku programa.

## Obuhvat analize

Analizira se izvršni program:

`unit_tests/build/format_edge_tests`

On pokreće 5 test slučajeva nad javnim `fmt::format` API-jem.

## Preduslovi

Potrebni su:

- CMake;
- C++ kompajler;
- Valgrind.

Analiza je izvršena sa verzijom:

- Valgrind 3.22.0

## Pokretanje

Iz korena seminarskog repozitorijuma pokrenuti:

`./valgrind/run_memcheck.sh`

Skripta prvo pravi Debug build test programa, a zatim pokreće Valgrind sa Memcheck alatom.

Uključene su detaljna provera curenja memorije, prikaz svih tipova curenja i praćenje porekla neinicijalizovanih vrednosti. Rezultat analize čuva se u fajlu:

`valgrind/results/memcheck.log`

## Rezultat

Memcheck nije prijavio memorijske greške.

Dobijeni rezultat:

- 0 bytes in 0 blocks pri završetku programa;
- 233 allocs i 233 frees;
- nema detektovanih curenja memorije;
- ERROR SUMMARY: 0 errors from 0 contexts.

Na osnovu ovog pokretanja nisu pronađeni problemi sa upravljanjem memorijom u kodu koji je izvršen kroz napisane testove.