# Running Fuzzing

Za fuzz testiranje koristi se **libFuzzer** uz **AddressSanitizer** i **UndefinedBehaviorSanitizer**.

Fuzzer se nalazi u:

`fuzzing/format_fuzzer.cpp`

## Ideja fuzz testa

Ulazni bafer se deli na:

* selector tipa vrednosti,
* binarnu reprezentaciju vrednosti,
* runtime format string.

Trenutna verzija fuzzera pokriva četiri reprezentativna slučaja:

* `int`
* `unsigned int`
* `double`
* `std::string`

Za svaki slučaj poziva se `fmt::format(fmt::runtime(...), value)`, dok se očekivani `fmt::format_error` izuzeci hvataju i ignorišu.

## Seed corpus

Početni corpus se nalazi u:

`fuzzing/corpus/`

U njemu su ručno pripremljeni osnovni seed-ovi za sva četiri podržana tipa.

Tokom izvršavanja libFuzzer automatski proširuje corpus novim interesantnim ulazima.

## Preduslovi

Potrebno je imati instalirane:

* `clang++`
* sanitizer podršku u Clang toolchain-u

Analiza je testirana sa:

* Clang 18.1.3

## Pokretanje

Iz korena seminarskog repozitorijuma pokrenuti:

```bash
./fuzzing/run_fuzzing.sh
```

Opcionalno je moguće zadati broj izvršavanja:

```bash
./fuzzing/run_fuzzing.sh 10000
```

Skripta automatski:

* kompajlira fuzzer sa `-fsanitize=fuzzer,address,undefined`,
* koristi postojeći seed corpus,
* smešta eventualne reprodukcione artifact fajlove u `fuzzing/artifacts/`.

## Napomena o LeakSanitizer-u

U ovom okruženju `LeakSanitizer` prijavljuje lažan problem pri završetku fuzzera zbog ograničenja rada pod `ptrace`. Zbog toga skripta koristi:

`ASAN_OPTIONS=detect_leaks=0`

Time su i dalje aktivni `AddressSanitizer` i `UndefinedBehaviorSanitizer`, dok se izbegava lažno negativan status izvršavanja.

## Trenutni rezultat

Kompajliranje fuzzera uspeva, a pokretanje nad corpusom prolazi bez prijavljenih `ASan` i `UBSan` grešaka.
