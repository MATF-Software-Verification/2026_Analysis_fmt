# Project Analysis Report — fmt

## 1. Uvod

Ovaj dokument sadrži izveštaj analize projekta **fmt** korišćenjem različitih alata i tehnika za verifikaciju softvera.

Cilj analize je ispitivanje ponašanja i kvaliteta projekta, pronalaženje potencijalnih problema i dokumentovanje rezultata korišćenih alata.

## 2. Opis projekta

`fmt` je biblioteka otvorenog koda za formatiranje teksta u C++ jeziku.

Izvorni kod projekta:

https://github.com/fmtlib/fmt

U okviru seminarskog rada analizira se:

- grana: `master`;
- commit: `7bce22571a49ba7921174effefbfbf24300667a6`.

Projekat je dodat u seminarski repozitorijum kao Git submodule i analiza se odnosi na navedeni commit.

## 3. Okruženje

Analiza je izvršena u Linux okruženju preko WSL2 na Windows operativnom sistemu.

Korišćene su sledeće verzije alata:

- Ubuntu 24.04.3 LTS;
- GCC 13.3.0;
- Clang 18.1.3;
- CMake 3.28.3;
- LCOV 2.0-1;
- Valgrind 3.22.0;
- perf 6.8.12;
- Cppcheck 2.13.0.

Pojedini alati imaju dodatne napomene vezane za WSL okruženje, koje su navedene u odgovarajućim delovima izveštaja.

## 4. Analize

### 4.1. Unit testovi i pokrivenost koda

Za proveru funkcionalnog ponašanja biblioteke napisani su dodatni testovi korišćenjem **Google Test** framework-a. Pokrivenost izvornog koda praćena je alatom **LCOV**.

Testovi su fokusirani na javni `fmt::format` API i nekoliko izabranih graničnih slučajeva numeričkog formatiranja i obrade format stringova.

Napisano je pet test slučajeva:

1. **IntegerLimits** — proverava formatiranje vrednosti `INT_MIN` i `INT_MAX`;
2. **HexPadding** — proverava heksadecimalno formatiranje sa zadatom širinom i vodećim nulama;
3. **FloatingPointSpecialValues** — proverava formatiranje vrednosti `inf`, `-inf` i `NaN`;
4. **PrecisionAndRounding** — proverava preciznost i zaokruživanje floating-point vrednosti;
5. **InvalidRuntimeFormatThrows** — proverava da neispravan runtime format string dovodi do `fmt::format_error` izuzetka.

Svi napisani test slučajevi uspešno su prošli nad analiziranim commitom projekta.

#### Pokretanje

Analiza se reprodukuje iz korena repozitorijuma:

```bash
./unit_tests/run_tests.sh
```

Skripta pravi coverage build, kompajlira projekat i testove, pokreće testove i pomoću LCOV-a prikuplja podatke o pokrivenosti.

Iz rezultata se uklanjaju sistemske biblioteke, Google Test i sami test fajlovi.

#### Pokrivenost koda

Dobijeni rezultati su:

- **Line coverage:** 26.0% - 636 od 2448 linija;
- **Function coverage:** 20.9% - 166 od 793 funkcije.

Pokrivenost po glavnim fajlovima koji su izvršeni tokom testova:

| Fajl | Line coverage | Function coverage |
| --- | ---: | ---: |
| `base.h` | 42.9% | 38.9% |
| `format.h` | 25.0% | 16.0% |
| `format-inl.h` | 4.7% | 6.4% |

Najveća pokrivenost ostvarena je u `base.h`, dok je `format-inl.h` znatno manje pokriven.

Relativno niska ukupna pokrivenost je očekivana, jer je `fmt` znatno veći projekat, dok su dodatni testovi usmereni na nekoliko izabranih slučajeva formatiranja.

Dobijeni procenat ne predstavlja pokrivenost kompletnog projekta njegovim postojećim test suite-om, već samo pokrivenost ostvarenu pomoću dodatnih testova napisanih u okviru ove analize.

#### Zaključak

U testiranim slučajevima nisu pronađena odstupanja od očekivanog ponašanja.

Pokrivenost pokazuje koji deo koda je izvršen tokom dodatnih testova, ali sama po sebi ne predstavlja dokaz ispravnosti programa.

---

### 4.2. Provera stila pomoću clang-format-a

Za proveru usklađenosti izvornog koda sa pravilima formatiranja korišćen je alat **clang-format**, verzija 18.1.3.

Analiza je sprovedena nad tri reprezentativna fajla iz glavnog izvornog koda biblioteke:

- `include/fmt/base.h`;
- `include/fmt/format.h`;
- `src/os.cc`.

Pravila formatiranja preuzeta su iz konfiguracionog fajla:

`fmt/.clang-format`

#### Pokretanje

Iz korena repozitorijuma pokreće se:

```bash
./clang_format/run_clang_format.sh
```

Skripta pokreće `clang-format` u režimu provere:

```text
--dry-run
--Werror
--style=file
```

Opcija `--dry-run` obezbeđuje da se nijedan izvorni fajl ne menja.

Opcija `--style=file` nalaže alatu da koristi postojeću `.clang-format` konfiguraciju projekta.

Opcija `--Werror` dovodi do toga da se formatting odstupanja prijavljuju kao greške i da komanda vraća neuspešan izlazni status. Ove prijave ne predstavljaju C++ sintaksne ili funkcionalne greške, već razlike u formatiranju.

Izlaz analize čuva se u:

`clang_format/results/clang_format_report.txt`

#### Rezultat

Analiza je izvršena nad izabranim fajlovima.

Za `include/fmt/base.h` i `include/fmt/format.h` clang-format je prijavio razlike u odnosu na formatiranje koje bi generisao `clang-format 18.1.3` koristeći postojeću projektnu konfiguraciju.

Za `src/os.cc` nisu prijavljena odstupanja.

Ukupno su prijavljena 103 mesta:

- 34 u `include/fmt/base.h`;
- 69 u `include/fmt/format.h`.

Prijavljene razlike uglavnom se odnose na prelom dugih deklaracija, poravnanje parametara i raspored višelinijskih izraza.

Pošto je analiza pokrenuta sa `--dry-run`, izvorni kod nije izmenjen.

#### Zaključak

clang-format proverava stil i formatiranje izvornog koda, a ne funkcionalnu, memorijsku ili sintaksnu ispravnost programa.

Pronađene razlike zato ne predstavljaju potvrđene greške u implementaciji biblioteke, već odstupanja između trenutnog formatiranja koda i rezultata koji bi proizvela korišćena verzija clang-format alata prema postojećoj `.clang-format` konfiguraciji.

Provera je ograničena na tri odabrana reprezentativna fajla i ne predstavlja proveru kompletnog izvornog stabla projekta.

---

### 4.3. Valgrind Memcheck

Za runtime analizu rada sa memorijom korišćen je **Valgrind Memcheck**.

Cilj analize bio je da se prilikom izvršavanja dodatnih testova pronađu eventualni problemi kao što su:

- nevalidna čitanja ili upisi u memoriju;
- upotreba neinicijalizovanih vrednosti;
- nepravilno oslobađanje memorije;
- curenje memorije.

#### Obuhvat analize

Kroz Memcheck je pokrenut izvršni program:

`unit_tests/build/format_edge_tests`

On izvršava pet dodatnih test slučajeva nad javnim `fmt::format` API-jem.

#### Pokretanje

Iz korena repozitorijuma:

```bash
./valgrind/run_memcheck.sh
```

Skripta prvo konfiguriše i kompajlira Debug build testova, a zatim pokreće Memcheck.

Korišćene su opcije:

- `--tool=memcheck`;
- `--leak-check=full`;
- `--show-leak-kinds=all`;
- `--track-origins=yes`;
- `--error-exitcode=1`.

Rezultat se čuva u:

`valgrind/results/memcheck.log`

Analiza je izvršena alatom Valgrind 3.22.0.

#### Rezultat

Memcheck je prijavio:

```text
in use at exit: 0 bytes in 0 blocks
total heap usage: 233 allocs, 233 frees, 118,235 bytes allocated

All heap blocks were freed -- no leaks are possible

ERROR SUMMARY: 0 errors from 0 contexts
```

Na kraju izvršavanja nije ostala zauzeta heap memorija, a Memcheck nije prijavio greške.

#### Zaključak

Na putanjama izvršenim kroz dodatne testove nisu pronađeni problemi sa upravljanjem memorijom niti curenje memorije.

Rezultat ne dokazuje odsustvo memorijskih grešaka u celom projektu, već se odnosi na konkretno izvršene testne putanje.

---

### 4.4. Analiza performansi pomoću perf

Za analizu performansi korišćen je Linux alat **perf**.

Cilj analize bio je da se na kontrolisanom workload-u pregledaju zbirne performance metrike i identifikuju funkcije koje imaju najveći udeo prikupljenih uzoraka.

#### Workload

Napravljen je poseban workload:

`perf/format_workload.cpp`

Program izvršava 10 miliona iteracija. U svakoj iteraciji koristi `fmt::format` za:

- celobrojnu vrednost sa širinom i vodećim nulama;
- `double` vrednost sa zadatom preciznošću;
- tekst sa poravnanjem i dodatnim celobrojnim argumentom.

Dužine dobijenih stringova učestvuju u izračunavanju vrednosti `checksum`, koja se na kraju ispisuje.

Workload se kompajlira sa opcijama:

- `-O2`;
- `-g`;
- `-DNDEBUG`.

#### Zbirne metrike

Analiza se pokreće:

```bash
./perf/run_perf_stat.sh
```

Rezultat se čuva u:

`perf/results/perf_stat.txt`

Dobijeni rezultat bio je:

```text
task-clock:          1692.42 msec
time elapsed:        1.623658679 seconds
cycles:              7789029895
instructions:        38889633886
instructions/cycle:  4.99
branches:            6726364122
branch-misses:       203770
context-switches:    0
cpu-migrations:      0
```

Odnos promašaja grananja u ovom pokretanju iznosi približno 0.003%.

#### Hot spot analiza

Detaljni profil generiše se pomoću:

```bash
./perf/run_perf_hotspots.sh
```

Skripta koristi:

```text
perf record --call-graph dwarf
```

i generiše:

`perf/results/perf_report.txt`

Za jednostavniji pregled pojedinačnih funkcija iz istog `perf.data` fajla generisan je i flat profil:

```bash
/usr/lib/linux-tools/6.8.0-139-generic/perf report \
  --stdio \
  --no-children \
  --sort symbol \
  -i perf/results/perf.data \
  > perf/results/perf_flat_report.txt
```

Najveći `Overhead` u flat profilu imaju:

- `parse_format_specs` — 10.78%;
- `format_handler::on_format_specs` — 10.32%;
- `copy_noinline` — 9.46%;
- `parse_format_string` — 9.35%.

Rezultat pokazuje da se među funkcijama sa najvećim pojedinačnim udelom uzoraka nalaze funkcije povezane sa parsiranjem i obradom format specifikacija, kao i kopiranjem i upisom dobijenog sadržaja.

To odgovara izabranom workload-u, koji koristi specifikacije:

- `{:08d}`;
- `{:.6f}`;
- `{:<16}`.

U profilu se pojavljuju i funkcije povezane sa kreiranjem, kopiranjem i oslobađanjem rezultujućih `std::string` objekata.

Detaljni call graph korišćen je kao dopuna flat profilu kako bi se pregledalo iz kojih delova workload-a dolaze izdvojene funkcije.

#### Okruženje i ograničenja

Analiza je izvršena u Ubuntu 24.04.3 WSL2 okruženju sa kernelom:

`6.18.33.2-microsoft-standard-WSL2`

Korišćen je:

`perf version 6.8.12`

Zbog razlike između WSL kernel verzije i dostupnog `linux-tools` paketa, skripte direktno koriste:

`/usr/lib/linux-tools/6.8.0-139-generic/perf`

Rezultati se odnose samo na izabrani workload i korišćeno okruženje. Ne predstavljaju opšti benchmark cele biblioteke.

`perf record` koristi statističko uzorkovanje, pa procenti predstavljaju udeo prikupljenih uzoraka, a ne precizno vreme izvršavanja svake pojedinačne funkcije.

---

### 4.5. ASan i UBSan analiza

Za dodatnu runtime proveru korišćeni su **AddressSanitizer (ASan)** i **UndefinedBehaviorSanitizer (UBSan)**.

Cilj analize bio je da se tokom izvršavanja testova otkriju memorijske greške i određeni oblici nedefinisanog ponašanja.

#### Obuhvat analize

Sanitizeri su pokrenuti nad:

1. originalnim `fmt` testovima;
2. pet dodatnih test slučajeva iz `unit_tests/tests/format_edge_tests.cpp`.

Originalni testovi obuhvataju različite delove biblioteke, uključujući formatiranje, argumente, `chrono`, Unicode, `printf`, ranges i OS-specifičnu funkcionalnost.

#### Pokretanje

Iz korena repozitorijuma:

```bash
./sanitizers/run_sanitizers.sh
```

Skripta pravi dva odvojena Clang build-a:

- `sanitizers/build/fmt/` za originalne `fmt` testove;
- `sanitizers/build/custom/` za dodatne testove.

Korišćene su opcije:

```text
-fsanitize=address,undefined
-fno-omit-frame-pointer
-O1
-g
```

`-fsanitize=address,undefined` uključuje ASan i UBSan, dok `-fno-omit-frame-pointer` i `-g` omogućavaju korisnije stack trace-ove pri eventualnoj prijavi problema.

#### Ograničenje okruženja

Zbog LeakSanitizer ograničenja u korišćenom WSL okruženju koristi se:

```text
ASAN_OPTIONS=detect_leaks=0
```

Time se isključuje samo LeakSanitizer, dok ASan i UBSan ostaju aktivni.

UBSan je konfigurisan pomoću:

```text
UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1
```

#### Posebno analizirani test slučajevi

Tokom početnog sanitizer pokretanja identifikovana su dva originalna testa koja pod UBSan-om proizvode prijave:

- `memory_buffer_test.move_ctor_dynamic_buffer_non_propagating`;
- `ostream_test.write_to_ostream_max_size`.

Oba testa su zatim pokrenuta pojedinačno i njihove prijave su ručno analizirane pre izuzimanja iz finalnog sanitizer prolaza.

Kod testa `memory_buffer_test.move_ctor_dynamic_buffer_non_propagating` UBSan je prijavio:

```text
reference binding to null pointer
```

Prijava nastaje u testnom `fmt/test/mock-allocator.h`, pri radu sa non-propagating allocatorom i move assignment-om. Odredišni `basic_memory_buffer` je napravljen bez eksplicitno zadatog allocatora, pa testni `allocator_ref` u tom specifičnom scenariju dolazi do null allocator pokazivača.

Kod testa `ostream_test.write_to_ostream_max_size` UBSan je prijavio:

```text
applying non-zero offset ... to null pointer
```

Prijava nastaje direktno u `fmt/test/ostream-test.cc` na operaciji `data += n`. Test simulira buffer maksimalne veličine bez stvarne alokacije memorije, koristeći `nullptr` kao fiktivnu početnu adresu i zatim vršeći pointer aritmetiku nad tim pokazivačem.

Na osnovu analize zaključeno je da obe prijave potiču iz specifičnih konstrukcija originalnog testnog koda, a ne predstavljaju potvrđene probleme u uobičajenom korišćenju `fmt` biblioteke.

Zbog toga su samo ta dva konkretna test slučaja izuzeta iz finalnog sanitizer prolaza. Čitavi `format-test` i `ostream-test` test programi nisu odbačeni.

#### Izvršavanje ostatka originalnih testova

`format-test` i `ostream-test` se prvo izuzimaju iz opšteg `ctest` poziva, a zatim se pokreću direktno uz Google Test filter kojim se izuzima samo prethodno analizirani pojedinačni slučaj.

U finalnom sanitizer prolazu:

- `ctest` deo je završio sa 18 od 18 uspešnih testova;
- `format-test` je izvršio 137 testova iz 8 test suite-ova i svi su prošli;
- `ostream-test` je izvršio 18 testova i svi su prošli;
- dodatni `format_edge_tests` izvršio je 5 testova i svi su prošli.

Rezultati su sačuvani u:

- `sanitizers/results/fmt_tests.log`;
- `sanitizers/results/custom_tests.log`.

U finalnim izvršavanjima nisu primećene ASan ni UBSan prijave.

#### Zaključak

ASan i UBSan nisu otkrili potvrđen problem u `fmt` implementaciji na testnim putanjama obuhvaćenim finalnim sanitizer izvršavanjem.

Dve UBSan prijave primećene tokom početnog pokretanja dodatno su analizirane i povezane sa specifičnim konstrukcijama originalnog testnog koda, nakon čega su samo ta dva konkretna slučaja izuzeta iz finalnog prolaza.

LeakSanitizer nije bio uključen zbog ograničenja WSL okruženja, pa ovom analizom nije obuhvaćena detekcija curenja memorije.

Rezultat se odnosi samo na konkretne pokrenute testove i ulaze i ne predstavlja dokaz odsustva svih mogućih problema u biblioteci.


---

### 4.6. Statička analiza pomoću Cppcheck-a

Za statičku analizu produkcionog koda korišćen je **Cppcheck 2.13.0**.

Cppcheck analizira izvorni kod bez njegovog izvršavanja i prijavljuje potencijalne greške, sumnjive obrasce, probleme sa portabilnošću i preporuke vezane za stil ili performanse.

#### Obuhvat analize

Analizirani su:

- `fmt/include/`;
- `fmt/src/`.

Testni direktorijumi nisu uključeni, jer je cilj bio pregled implementacije biblioteke.

#### Pokretanje

Iz korena repozitorijuma:

```bash
./cppcheck/run_cppcheck.sh
```

Rezultat se čuva u:

```text
cppcheck/results/cppcheck_report.txt
```

Analiza koristi:

```text
--enable=warning,style,performance,portability
--force
--std=c++20
--language=c++
--inline-suppr
--suppress=missingIncludeSystem
```

Opcija `--inconclusive` nije korišćena u finalnoj analizi, kako bi se smanjio broj nalaza niže pouzdanosti i rezultat učinio preglednijim.

#### Rezultat

Cppcheck je prijavio ukupno **136 nalaza**:

- 4 `error` nalaza, svi sa identifikatorom `syntaxError`;
- 19 `warning` nalaza;
- 103 `style` nalaza;
- 8 `performance` nalaza;
- 2 `portability` nalaza.

Najveći deo rezultata čine `style` nalazi. Rezultati zato nisu analizirani red po red, već su ponavljajući nalazi grupisani po tipu, dok je nekoliko reprezentativnih i potencijalno ozbiljnijih nalaza dodatno pregledano u izvornom kodu.

Među češćim ponavljajućim nalazima nalaze se:

- `noExplicitConstructor`;
- `shadowFunction`;
- `knownConditionTrueFalse`;
- `uninitMemberVar`;
- `passedByValue`;
- `duplInheritedMember`.

Ovi nalazi se uglavnom odnose na način konstrukcije objekata, zaklanjanje imena, uslove koje Cppcheck procenjuje kao konstantne, inicijalizaciju članova, prosleđivanje parametara i odnose između članova baznih i izvedenih klasa.

Posebno su izdvojeni nalazi:

- `shiftNegativeLHS`;
- `AssignmentAddressToInteger`;
- `mismatchingContainerExpression`;
- `uninitMemberVar`.

Nalaz `shiftNegativeLHS` prijavljen je na izrazu:

```cpp
static_assert((-1 >> 1) == -1, "right shift is not arithmetic");
```

Pregledom izvornog koda utvrđeno je da se ova operacija namerno koristi kao compile-time provera pretpostavke o aritmetičkom desnom shift-u. U korišćenoj konfiguraciji provera prolazi, pa nalaz nije potvrđen kao funkcionalna greška.

Kod nalaza `AssignmentAddressToInteger` pregledani su poziv makroa `FMT_RETRY_VAL` i deklaracija promenljive `file_`. Utvrđeno je da je `file_` tipa `FILE*`, dok funkcija `fopen` takođe vraća `FILE*`, pa ne postoji stvarna dodela pokazivača celobrojnom tipu. Nalaz je najverovatnije posledica načina na koji Cppcheck interpretira makro-ekspanziju.

Za `mismatchingContainerExpression` Cppcheck je prijavio poređenje:

```cpp
sv.end() == s.end()
```

Pregledom funkcije `for_each_codepoint` utvrđeno je da `sv` predstavlja pogled nad delom iste memorije na koju pokazuje originalni `s`. Poređenje se namerno koristi da bi se utvrdilo da li je dostignut kraj originalnog stringa, pa nalaz nije potvrđen kao greška.

Kod nalaza `uninitMemberVar` utvrđeno je da konstruktor klase `writer` koji prima bafer zaista ne inicijalizuje član `file_`. Međutim, u tom slučaju `buf_` pokazuje na prosleđeni bafer i metoda `print` koristi upravo `buf_`, dok se `file_` ne čita. Nalaz zato nije potvrđen kao funkcionalna greška u posmatranom toku izvršavanja.

Četiri `syntaxError` poruke nisu tretirane kao potvrđene sintaksne greške, jer se isti kod uspešno kompajlira u korišćenoj konfiguraciji i prolazi kroz testove.

Kod biblioteke `fmt` intenzivno koristi template-e, makroe i compile-time konstrukcije, što predstavlja zahtevniji ulaz za statičke analizatore i zahteva dodatno tumačenje pojedinih nalaza u kontekstu izvornog koda.

#### Zaključak

Cppcheck analiza je izdvojila više potencijalno interesantnih mesta u kodu, pri čemu najveći deo rezultata pripada kategoriji `style`.

Ručnom proverom nekoliko reprezentativnih nalaza nije potvrđena funkcionalna greška u biblioteci `fmt`. Pojedini nalazi predstavljaju namerne konstrukcije, dok su drugi posledica načina na koji statički analizator interpretira makroe, string view objekte ili određene obrasce inicijalizacije.

Cppcheck je zato korišćen kao alat za izdvajanje mesta koja zahtevaju dodatnu ručnu proveru, a ne kao konačan dokaz prisustva ili odsustva grešaka.

## 5. Zaključak

U seminarskom radu analizirana je verzija projekta `fmt` na commit-u:

`7bce22571a49ba7921174effefbfbf24300667a6`

Korišćeno je šest alata i tehnika:

1. dodatni unit testovi uz LCOV pokrivenost;
2. clang-format;
3. Valgrind Memcheck;
4. perf;
5. AddressSanitizer i UndefinedBehaviorSanitizer;
6. Cppcheck.

Dodatni test slučajevi uspešno su prošli i ostvarili 26.0% line coverage i 20.9% function coverage nad analiziranim `fmt` kodom.

clang-format je nad tri odabrana reprezentativna fajla prijavio odstupanja od očekivanog formata u `base.h` i `format.h`, dok za `os.cc` nije prijavljeno odstupanje. Ovi nalazi odnose se na formatiranje izvornog koda i ne predstavljaju funkcionalne greške.

Valgrind Memcheck nije pronašao memorijske greške ni curenje memorije na putanjama izvršenim kroz dodatne testove.

Perf analiza pokazala je da se među funkcijama sa najvećim pojedinačnim udelom uzoraka nalaze funkcije povezane sa parsiranjem format specifikacija, obradom format stringova i kopiranjem formatiranog sadržaja. Detaljni call graph korišćen je kao dopuna za povezivanje tih funkcija sa operacijama iz workload-a.

Posebna ASan i UBSan analiza nad originalnim `fmt` testovima i dodatnim testovima nije otkrila potvrđen problem u `fmt` implementaciji na putanjama obuhvaćenim finalnim sanitizer prolazom. Tokom početnog pokretanja UBSan je prijavio dva specifična slučaja u originalnom testnom kodu; oba su pojedinačno reprodukovana i analizirana, nakon čega su samo ta dva test slučaja izuzeta iz finalnog prolaza.

Cppcheck je prijavio veći broj `style` nalaza, kao i manji broj `warning`, `performance`, `portability` i `syntaxError` nalaza. Nekoliko reprezentativnih i potencijalno ozbiljnijih nalaza dodatno je ručno pregledano u izvornom kodu. Analizirani su primeri `shiftNegativeLHS`, `AssignmentAddressToInteger`, `mismatchingContainerExpression` i `uninitMemberVar`, pri čemu nijedan od tih nalaza nije potvrđen kao funkcionalna greška u biblioteci.

U okviru sprovedene analize nije pronađen potvrđen bag u verziji projekta koja je obuhvaćena radom.

To ne dokazuje da u celoj biblioteci ne postoje problemi. Svaki rezultat važi samo za konkretne testne putanje, ulaze, konfiguraciju alata i korišćeno okruženje.

Kombinovanje funkcionalnog testiranja, provere formatiranja koda, runtime memorijske analize, sanitizera, performance profilisanja i statičke analize omogućilo je da se projekat posmatra iz više različitih aspekata.

**ASan + UBSan** i **Cppcheck** predstavljaju dve korišćene tehnike koje nisu obrađene na vežbama.