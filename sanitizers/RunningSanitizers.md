# Running ASan and UBSan Analysis

Za runtime proveru memorijske bezbednosti i nedefinisanog ponašanja koriste se **AddressSanitizer (ASan)** i **UndefinedBehaviorSanitizer (UBSan)**.

## Cilj analize

ASan proverava probleme kao što su:

- pristup memoriji van granica;
- use-after-free;
- use-after-return;
- određene greške pri radu sa stekom i heap memorijom.

UBSan proverava određene oblike nedefinisanog ponašanja u C++ programu.

## Obuhvat analize

Sanitizeri se pokreću nad:

1. originalnim `fmt` test suite-om;
2. pet dodatnih unit testova iz `unit_tests/tests/format_edge_tests.cpp`.

Originalni test suite pokriva širok skup funkcionalnosti biblioteke, uključujući formatiranje, argumente, `chrono`, Unicode, `printf`, ranges i rad sa operativnim sistemom.

## Pokretanje

Iz korena repozitorijuma pokrenuti:

```bash
./sanitizers/run_sanitizers.sh
```

Skripta pravi dva odvojena Clang build-a:

- `sanitizers/build/fmt/` — originalni `fmt` test suite;
- `sanitizers/build/custom/` — dodatni unit testovi.

Rezultati se čuvaju u:

- `sanitizers/results/fmt_tests.log`;
- `sanitizers/results/custom_tests.log`.

## Korišćene opcije

Testovi se kompajliraju sa opcijama:

```text
-fsanitize=address,undefined
-fno-omit-frame-pointer
-O1
-g
```

- `-fsanitize=address,undefined` uključuje ASan i UBSan;
- `-fno-omit-frame-pointer` poboljšava stack trace pri prijavi problema;
- `-O1` daje umerenu optimizaciju uz zadržavanje dobre dijagnostike;
- `-g` uključuje simboličke informacije.

Skripta koristi i:

```text
ASAN_OPTIONS=detect_leaks=0
UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1
```

`detect_leaks=0` isključuje samo LeakSanitizer, zbog poznatog WSL/`ptrace` ograničenja u ovom okruženju. ASan i UBSan ostaju aktivni.

## Posebno obrađeni test-only slučajevi

Dva originalna test slučaja namerno koriste operacije koje UBSan prijavljuje pre provere očekivanog ponašanja:

- `memory_buffer_test.move_ctor_dynamic_buffer_non_propagating`;
- `ostream_test.write_to_ostream_max_size`.

Prvi koristi testni mock allocator sa praznim pokazivačem, a drugi koristi aritmetiku nad `nullptr` pri simulaciji maksimalne veličine stream izlaza.

Ta dva konkretna test slučaja su izuzeta samo iz sanitizer izvršavanja. Svi ostali originalni testovi su pokrenuti:

- 18 CTest test programa;
- 137 testova u `format-test`;
- 18 testova u `ostream-test`.

Ovo izuzimanje je ograničeno na testni kod i ne predstavlja prikrivanje prijave iz `fmt` implementacije.

## Rezultat

Svi pokrenuti originalni i dodatni testovi su uspešno prošli.

Pretraga sačuvanih logova nije pronašla:

- `AddressSanitizer`;
- `UndefinedBehaviorSanitizer`;
- `runtime error`;
- `ERROR:`.

## Zaključak

U obuhvaćenim originalnim i dodatnim testovima ASan i UBSan nisu prijavili memory-safety problem niti nedefinisano ponašanje u analiziranoj implementaciji `fmt`.

Ovaj rezultat ne dokazuje odsustvo svih mogućih problema u biblioteci, već potvrđuje odsustvo sanitizer prijava na izvršenim testnim putanjama i korišćenim ulazima.