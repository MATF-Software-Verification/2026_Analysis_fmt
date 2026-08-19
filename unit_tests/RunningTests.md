# Running Tests

Za unit testove koristi se **Google Test**, a za praćenje pokrivenosti koda **LCOV**.

Testovi se nalaze u:

`unit_tests/tests/format_edge_tests.cpp`

## Preduslovi

Potrebno je imati instalirane:

* C++ kompajler
* CMake
* LCOV

Analiza je testirana sa:

* GCC 13.3.0
* CMake 3.28.3
* LCOV 2.0-1

## Pokretanje

Iz korena seminarskog repozitorijuma pokrenuti:

```bash
./unit_tests/run_tests.sh
```

Skripta automatski:

* pravi coverage build,
* kompajlira `fmt`, Google Test i napisane testove,
* pokreće testove,
* prikuplja coverage podatke,
* filtrira sistemske biblioteke i test framework,
* generiše LCOV HTML izveštaj.

## Rezultat

Trenutno je napisano 5 unit testova i svi uspešno prolaze.

Dobijena pokrivenost `fmt` koda:

* Line coverage: **26.0%**
* Function coverage: **20.9%**

HTML izveštaj se lokalno generiše u:

`unit_tests/coverage_report/index.html`

