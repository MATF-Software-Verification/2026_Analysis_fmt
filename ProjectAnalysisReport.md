# Project Analysis Report — fmt

## 1. Uvod

Ovaj dokument sadrži detaljan izveštaj analize projekta **fmt** korišćenjem različitih alata i tehnika za verifikaciju softvera.

Cilj analize je ispitivanje kvaliteta i ponašanja projekta, pronalaženje potencijalnih grešaka i uskih grla, kao i dokumentovanje rezultata korišćenih alata.

## 2. Opis projekta

`fmt` je biblioteka otvorenog koda za formatiranje teksta u C++ jeziku.

Izvorni kod projekta:

https://github.com/fmtlib/fmt

U okviru seminarskog rada analizira se:

* grana: `master`
* commit: `7bce22571a49ba7921174effefbfbf24300667a6`

Projekat je dodat u seminarski repozitorijum kao Git submodule.

## 3. Okruženje

Analiza se izvršava u Linux okruženju preko WSL-a na Windows operativnom sistemu.

Detaljne verzije kompajlera, build sistema i korišćenih alata biće navedene nakon konfiguracije okruženja.

## 4. Analize

Za svaki korišćeni alat ili tehniku biće dokumentovani:

* cilj analize,
* deo projekta koji se analizira,
* način pokretanja alata,
* korišćene opcije,
* dobijeni rezultati,
* interpretacija rezultata,
* zaključak.

### 4.1. Unit testovi i pokrivenost koda

Za proveru funkcionalnog ponašanja biblioteke napisani su dodatni unit testovi korišćenjem **Google Test** framework-a. Pokrivenost izvornog koda testovima praćena je alatom **LCOV**.

Testovi su fokusirani na javni `fmt::format` API i nekoliko reprezentativnih graničnih slučajeva numeričkog formatiranja i obrade format stringova.

Napisano je ukupno pet testova:

1. **IntegerLimits** - proverava formatiranje vrednosti `INT_MIN` i `INT_MAX`.
2. **HexPadding** -  proverava heksadecimalno formatiranje sa zadatom širinom i vodećim nulama.
3. **FloatingPointSpecialValues** - proverava formatiranje vrednosti `inf`, `-inf` i `NaN`.
4. **PrecisionAndRounding** - proverava preciznost i zaokruživanje floating-point vrednosti.
5. **InvalidRuntimeFormatThrows** - proverava da neispravan runtime format string dovodi do kontrolisanog `fmt::format_error` izuzetka.

Svi napisani testovi uspešno su prošli nad analiziranim commitom projekta.

#### Pokrivenost koda

Testovi su kompajlirani sa GCC coverage instrumentacijom, nakon čega su podaci prikupljeni pomoću LCOV-a.

Iz coverage izveštaja uklonjeni su:

* sistemski C++ headeri,
* Google Test kod,
* sam kod napisanih testova.

Na taj način rezultat predstavlja pokrivenost analiziranog `fmt` koda testovima napisanim u okviru seminarskog rada.

Dobijeni rezultati su:

* **Line coverage:** 26.0% - 636 od 2448 linija
* **Function coverage:** 20.9% - 166 od 793 funkcije

Pokrivenost po glavnim fajlovima koji su izvršeni tokom testova:

| Fajl           | Line coverage | Function coverage |
| -------------- | ------------: | ----------------: |
| `base.h`       |         42.9% |             38.9% |
| `format.h`     |         25.0% |             16.0% |
| `format-inl.h` |          4.7% |              6.4% |

Najveća pokrivenost ostvarena je u `base.h`, dok je `format-inl.h` znatno manje pokriven. Ovo je očekivano jer napisani testovi koriste osnovni formatting API i ne aktiviraju veliki deo interne implementacije biblioteke.

Dobijeni procenat ne predstavlja pokrivenost kompletnog projekta njegovim postojećim test suite-om, već samo pokrivenost ostvarenu pomoću dodatnih testova napisanih za ovu analizu.

Visoka pokrivenost sama po sebi ne garantuje ispravnost programa, već pokazuje koji deo koda je izvršen tokom testiranja.

#### Zaključak

U testiranim slučajevima nisu pronađena odstupanja od očekivanog ponašanja.

Test suite može biti proširen tokom kasnijih analiza ukoliko fuzz testiranje, sanitizatori ili statička analiza otkriju dodatne slučajeve koje bi bilo korisno sačuvati kao regresione testove.

Analiza se reprodukuje pokretanjem:

`./unit_tests/run_tests.sh`


### 4.2. Fuzz testiranje

Za dodatno ispitivanje robusnosti biblioteke primenjeno je **coverage-guided fuzz testiranje** korišćenjem **libFuzzer** alata uz **AddressSanitizer** i **UndefinedBehaviorSanitizer**.

Cilj fuzz testa bio je da nasumično generisanim ulazima proveri ponašanje `fmt::format` funkcije pri obradi različitih runtime format stringova i tipova argumenata.

Napisan je poseban fuzz target:

`fuzzing/format_fuzzer.cpp`

Fuzzer iz jednog ulaznog bafera bira jedan od četiri podržana tipa i zatim formira poziv ka:

`fmt::format(fmt::runtime(format_str), value)`

Obuhvaćeni su sledeći tipovi:

* `int`
* `unsigned int`
* `double`
* `std::string`

Neispravni format stringovi su očekivani tokom fuzzinga, pa se `fmt::format_error` izuzeci hvataju i ignorišu kako bi se fokus zadržao na neočekivanim padovima, problemima sa memorijom i nedefinisanim ponašanjem.

#### Pokretanje

Analiza se reprodukuje pokretanjem:

`./fuzzing/run_fuzzing.sh`

Fuzzer se kompajlira pomoću Clang-a 18.1.3 sa opcijama:

* `-fsanitize=fuzzer,address,undefined`
* `-O1`
* `-g`

Kao početni corpus korišćen je mali skup ručno pripremljenih seed-ova za sva četiri tipa podataka.

#### Rezultat

Fuzz target je uspešno kompajliran i pokrenut nad seed corpusom. Tokom probnog izvršavanja nije došlo do prijavljenih `AddressSanitizer` niti `UndefinedBehaviorSanitizer` grešaka.

LibFuzzer je tokom izvršavanja automatski proširio corpus dodatnim interesantnim ulazima, što pokazuje da target uspešno dolazi do većeg broja putanja kroz kod od početnog ručno pripremljenog skupa ulaza.

#### Ograničenje okruženja

U korišćenom okruženju `LeakSanitizer` prijavljuje lažan problem pri završetku fuzzera zbog ograničenja rada pod `ptrace`. Zbog toga je u skripti za pokretanje postavljeno:

`ASAN_OPTIONS=detect_leaks=0`

Ova izmena ne isključuje `AddressSanitizer` ni `UndefinedBehaviorSanitizer`, već samo sprečava lažni neuspeh završetka procesa.

#### Zaključak

Na trenutnom uzorku izvršavanja nisu pronađeni padovi, memory safety problemi ni prijavljeno nedefinisano ponašanje u obuhvaćenim scenarijima.

Fuzz target ostaje koristan za duža izvršavanja i može se naknadno proširiti novim tipovima argumenata ili specijalizovanim dictionary fajlom ukoliko dalja analiza pokaže da je to potrebno.

### 4.3. Valgrind Memcheck

Za runtime analizu rada sa memorijom korišćen je **Valgrind Memcheck**.

Cilj analize bio je da se prilikom izvršavanja dodatnih unit testova pronađu eventualne greške u radu sa memorijom, kao što su:

* nevalidna čitanja ili upisi u memoriju;
* upotreba neinicijalizovanih vrednosti;
* nepravilno oslobađanje memorije;
* curenje memorije.

#### Obuhvat analize

Kroz Memcheck je pokrenut izvršni program:

`unit_tests/build/format_edge_tests`

Program sadrži pet dodatnih unit testova nad javnim `fmt::format` API-jem. Testovi obuhvataju granične vrednosti celih brojeva, heksadecimalno formatiranje, specijalne floating-point vrednosti, zaokruživanje i obradu neispravnog runtime format stringa.

#### Pokretanje

Analiza se iz korena repozitorijuma reprodukuje komandom:

```bash
./valgrind/run_memcheck.sh

Skripta prvo konfiguriše i kompajlira Debug build testova, a zatim pokreće Memcheck nad izvršnim programom.

Korišćene su sledeće opcije:

- `--tool=memcheck` — bira alat za proveru memorijskih grešaka;
- `--leak-check=full` — uključuje detaljnu proveru curenja memorije;
- `--show-leak-kinds=all` — prikazuje sve vrste eventualnih curenja;
- `--track-origins=yes` — omogućava pronalaženje porekla neinicijalizovanih vrednosti;
- `--error-exitcode=1` — skripta završava neuspešno ako Memcheck pronađe grešku.

Rezultat se čuva u:
```bash
`valgrind/results/memcheck.log`
```
Analiza je izvršena alatom Valgrind 3.22.0.

#### Rezultat

Memcheck je prijavio sledeći sažetak:

```text
in use at exit: 0 bytes in 0 blocks
total heap usage: 233 allocs, 233 frees
All heap blocks were freed -- no leaks are possible
ERROR SUMMARY: 0 errors from 0 contexts
```

To znači da je tokom analiziranog izvršavanja svaka zabeležena alokacija memorije odgovarajuće oslobođena i da Memcheck nije pronašao memorijske greške.

#### Zaključak

Na putanjama izvršenim kroz pet dodatnih unit testova nisu pronađeni problemi sa memorijom niti curenje memorije.

Ovaj rezultat ne dokazuje odsustvo memorijskih grešaka u celom projektu `fmt`, već potvrđuje da ih Memcheck nije pronašao u konkretnom obuhvatu testiranih scenarija i ulaza.

### 4.4. Analiza performansi pomoću perf

Za analizu performansi korišćen je Linux alat **perf**.

Cilj analize bio je da se za kontrolisani workload identifikuju zbirne performance metrike i funkcije u kojima se provodi najveći deo CPU vremena.

#### Workload

Napravljen je poseban workload:

`perf/format_workload.cpp`

Program izvršava 10 miliona iteracija. U svakoj iteraciji koristi `fmt::format` za:

* celobrojnu vrednost sa širinom i vodećim nulama;
* `double` vrednost sa zadatom preciznošću;
* string vrednost sa poravnanjem.

Rezultati formatiranja učestvuju u izračunavanju i ispisu kontrolne vrednosti `checksum`. Time se sprečava da optimizujući kompajler ukloni pozive formatiranja kao nepotreban kod.

Workload se kompajlira sa opcijama `-O2`, `-g` i `-DNDEBUG`.

#### Zbirne metrike

Zbirne performance metrike reprodukuju se komandom:

```bash
./perf/run_perf_stat.sh
```

Skripta pokreće `perf stat` i rezultat čuva u:

`perf/results/perf_stat.txt`

Dobijeni rezultat bio je:

```text
task-clock:         1692.42 msec
time elapsed:       1.623658679 seconds
cycles:             7789029895
instructions:       38889633886
instructions/cycle: 4.99
branches:           6726364122
branch-misses:      203770
context-switches:   0
cpu-migrations:     0
```

Odnos promašaja grananja je približno 0.003%. Tokom analiziranog pokretanja nije bilo context switch-eva ni migracija procesa između CPU jezgara.

#### Hot spot analiza

Za profil hot spotova korišćeni su `perf record` i `perf report`. Analiza se reprodukuje komandom:

```bash
./perf/run_perf_hotspots.sh
```

Skripta koristi `perf record --call-graph dwarf` za statističko uzorkovanje i beleženje pozivnih lanaca. Čitljiv izveštaj se čuva u:

`perf/results/perf_report.txt`

U profilu su najzastupljenije putanje povezane sa funkcijama:

* `fmt::vformat`;
* `fmt::detail::vformat_to`;
* `fmt::detail::parse_format_string`;
* obradom format specifikacija;
* upisom formatiranog stringa;
* Unicode obradom i poravnavanjem stringa.

Ovaj rezultat je očekivan za izabrani workload, jer se format stringovi sa specifikacijama `{:08d}`, `{:.6f}` i `"{:<16}"` obrađuju u svakoj iteraciji.

#### Okruženje i ograničenja

Analiza je izvršena u Ubuntu 24.04.3 WSL2 okruženju, sa kernelom `6.18.33.2-microsoft-standard-WSL2` i alatom perf 6.8.12.

Zbog razlike između WSL kernela i dostupne Ubuntu verzije alata, skripte direktno koriste instalirani perf binarni fajl. Rezultati zato važe za konkretan workload i korišćeno okruženje; nisu opšti benchmark cele biblioteke niti se mogu direktno porediti sa rezultatima na drugom računaru ili operativnom sistemu.

#### Zaključak

U analiziranom workload-u nisu pronađeni neočekivani hot spotovi niti potvrđeno usko grlo projekta. Najveći deo rada očekivano je vezan za parsiranje format stringa, obradu format specifikacija i generisanje formatiranog izlaza.

### 4.5. ASan i UBSan analiza

Za dodatnu runtime proveru korišćeni su **AddressSanitizer (ASan)** i **UndefinedBehaviorSanitizer (UBSan)**.

Cilj analize bio je da se pri izvršavanju testova otkriju memory-safety problemi i određeni oblici nedefinisanog ponašanja.

#### Obuhvat analize

Sanitizeri su pokrenuti nad:

* originalnim `fmt` test suite-om;
* pet dodatnih unit testova iz `unit_tests/tests/format_edge_tests.cpp`.

Originalni test suite obuhvata različite delove biblioteke, uključujući formatiranje, argumente, `chrono`, Unicode, `printf`, ranges i OS-specifičnu funkcionalnost.

#### Pokretanje

Analiza se iz korena repozitorijuma reprodukuje komandom:

```bash
./sanitizers/run_sanitizers.sh
```

Skripta pravi dva odvojena Clang build-a: jedan za originalne `fmt` testove, a drugi za dodatne unit testove.

Korišćene su opcije:

```text
-fsanitize=address,undefined
-fno-omit-frame-pointer
-O1
-g
```

`-fsanitize=address,undefined` uključuje ASan i UBSan, dok `-fno-omit-frame-pointer` i `-g` omogućavaju čitljivije stack trace-ove pri eventualnoj prijavi problema.

#### Ograničenje okruženja

Zbog poznatog LeakSanitizer/`ptrace` ograničenja u WSL okruženju, skripta koristi:

```text
ASAN_OPTIONS=detect_leaks=0
```

Time se isključuje samo LeakSanitizer. ASan i UBSan ostaju aktivni.

#### Posebno obrađeni test-only slučajevi

Dva originalna test slučaja su izuzeta samo iz sanitizer izvršavanja:

* `memory_buffer_test.move_ctor_dynamic_buffer_non_propagating`;
* `ostream_test.write_to_ostream_max_size`.

Ti testovi namerno koriste testne scenarije koje UBSan prijavljuje pre provere očekivanog ponašanja: prvi koristi mock allocator sa praznim pokazivačem, a drugi izvodi aritmetiku nad `nullptr` pri simulaciji maksimalne veličine stream izlaza.

Ostatak originalnog test suite-a je pokrenut, uključujući 18 CTest test programa, 137 testova u `format-test` i 18 testova u `ostream-test`.

#### Rezultat

Svi pokrenuti originalni i dodatni testovi su uspešno prošli.

U sačuvanim logovima:

* `sanitizers/results/fmt_tests.log`;
* `sanitizers/results/custom_tests.log`;

nije pronađena `AddressSanitizer`, `UndefinedBehaviorSanitizer`, `runtime error` niti `ERROR:` prijava.

#### Zaključak

U obuhvaćenim testnim putanjama ASan i UBSan nisu prijavili memory-safety problem niti nedefinisano ponašanje u analiziranoj implementaciji `fmt`.

Rezultat ne dokazuje odsustvo svih mogućih problema u celoj biblioteci, već pokazuje da ih sanitizeri nisu pronašli pri izvršavanju širokog originalnog test suite-a i dodatnih testova.

### 4.6. Analiza 6

Biće dopunjeno.

## 5. Zaključak

Završni zaključci biće dodati nakon sprovođenja svih analiza.
