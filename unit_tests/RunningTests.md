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

Iz korena repozitorijuma pokrenuti:

```bash
./unit_tests/run_tests.sh
```

Skripta pravi novi coverage build, kompajlira projekat i testove, pokreće testove i zatim pomoću LCOV-a prikuplja podatke o pokrivenosti.

Iz rezultata se uklanjaju sistemske biblioteke, Google Test i sami test fajlovi, nakon čega se generiše HTML izveštaj.

## Rezultat

Napisano je 5 test slučajeva i svi uspešno prolaze.

Dobijena pokrivenost `fmt` koda:

* Line coverage: **26.0%**
* Function coverage: **20.9%**

Relativno niska ukupna pokrivenost je očekivana, jer je `fmt` znatno veći projekat, dok su napisani testovi usmereni na nekoliko izabranih slučajeva formatiranja.

HTML izveštaj se lokalno generiše u:

`unit_tests/coverage_report/index.html`

