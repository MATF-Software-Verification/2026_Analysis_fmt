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

On pokreće pet dodatnih unit testova nad javnim `fmt::format` API-jem.

## Preduslovi

Potrebni su:

- CMake;
- C++ kompajler;
- Valgrind.

Analiza je izvršena sa verzijom:

- Valgrind 3.22.0

## Pokretanje

Iz korena seminarskog repozitorijuma pokrenuti:

```bash
./valgrind/run_memcheck.sh