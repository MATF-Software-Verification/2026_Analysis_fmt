# 2026_Analysis_fmt

## Analiza projekta fmt
### Autor

Dunja Mijačić 1025/2025

## Analizirani projekat

U okviru seminarskog rada analizira se projekat fmt, biblioteka otvorenog koda za formatiranje teksta u C++ jeziku.

- Projekat: fmt
- Izvorni kod: https://github.com/fmtlib/fmt
- Analizirana grana: master
- Analizirani commit: 7bce22571a49ba7921174effefbfbf24300667a6

Originalni projekat je dodat u ovaj repozitorijum kao Git submodule u direktorijumu fmt.

## Cilj analize

Cilj seminarskog rada je analiza projekta korišćenjem različitih tehnika i alata za verifikaciju softvera, sa fokusom na pronalaženje potencijalnih grešaka, problema sa memorijom, neispravnog ponašanja.

U okviru rada korišćeno je šest alata i tehnika za analizu softvera.

## Korišćeni alati i tehnike

U okviru rada sprovedene su sledeće analize:

### Unit testovi i LCOV

Napisano je pet dodatnih Google Test testova nad javnim `fmt::format` API-jem. Pokrivenost koda prati se alatom LCOV.

Dobijena pokrivenost `fmt` koda dodatnim testovima iznosi:

- line coverage: 26.0%;
- function coverage: 20.9%.

Detaljno uputstvo nalazi se u `unit_tests/RunningTests.md`.

### Provera stila pomoću clang-format-a

Za proveru usklađenosti odabranih delova izvornog koda sa pravilima formatiranja koristi se clang-format 18.1.3.

Proveravaju se sledeći reprezentativni fajlovi:

- `fmt/include/fmt/base.h`;
- `fmt/include/fmt/format.h`;
- `fmt/src/os.cc`.

Provera se izvršava bez izmene izvornog koda:

```bash
./clang_format/run_clang_format.sh
```

Skripta koristi konfiguraciju `fmt/.clang-format` i čuva rezultat u `clang_format/results/clang_format_report.txt`.

Detaljno uputstvo nalazi se u `clang_format/RunningClangFormat.md`.

### Valgrind Memcheck

Za runtime analizu memorije koristi se Valgrind Memcheck nad izvršnim programom dodatnih unit testova.

Memcheck proverava nevalidne pristupe memoriji, upotrebu neinicijalizovanih vrednosti i curenje memorije. U izvršenoj analizi nad pet testova nije prijavljena nijedna memorijska greška niti curenje memorije.

Detaljno uputstvo i tumačenje rezultata nalaze se u `valgrind/RunningValgrind.md`.

### perf

Za analizu performansi koristi se Linux alat perf.

Napravljen je kontrolisani workload koji više puta poziva `fmt::format` nad celobrojnim, floating-point i string vrednostima. Korišćeni su `perf stat` za zbirne metrike i `perf record`/`perf report` za pronalaženje hot spotova.

Detaljno uputstvo i tumačenje rezultata nalaze se u:

`perf/RunningPerf.md`

### AddressSanitizer i UndefinedBehaviorSanitizer

Za dodatnu runtime analizu koriste se ASan i UBSan nad originalnim `fmt` test suite-om i pet dodatnih unit testova.

Sanitizeri proveravaju memory-safety probleme i određene oblike nedefinisanog ponašanja. Tokom početnog pokretanja UBSan je prijavio dva specifična slučaja u originalnom `fmt` testnom kodu. Oba slučaja su pojedinačno reprodukovana i analizirana, nakon čega su samo ta dva test slučaja izuzeta iz finalnog sanitizer prolaza. U finalnom obuhvatu nisu prijavljeni novi ASan ni UBSan problemi.

Detaljno uputstvo i tumačenje rezultata nalaze se u:

`sanitizers/RunningSanitizers.md`

### Cppcheck

Za statičku analizu produkcionog C++ koda koristi se Cppcheck.

Analizirani su direktorijumi `fmt/include/` i `fmt/src/`. Cppcheck je prijavio više nalaza iz kategorija `warning`, `style`, `performance`, `portability` i `error`. Nekoliko reprezentativnih i potencijalno ozbiljnijih nalaza dodatno je ručno pregledano u izvornom kodu, pri čemu nijedan od njih nije potvrđen kao funkcionalna greška u biblioteci.

Detaljno uputstvo i tumačenje rezultata nalaze se u:

`cppcheck/RunningCppcheck.md`

## Reprodukcija rezultata

Unit testovi i coverage analiza pokreću se iz korena repozitorijuma komandom:

```bash
./unit_tests/run_tests.sh
```

Provera stila izvornog koda pokreće se komandom:

```bash
./clang_format/run_clang_format.sh
```

Rezultat se čuva u `clang_format/results/clang_format_report.txt`.

Valgrind Memcheck analiza se reprodukuje komandom:

```bash
./valgrind/run_memcheck.sh
```

Memcheck rezultat se nakon pokretanja čuva u:

`valgrind/results/memcheck.log`

Zbirne performance metrike dobijaju se komandom:

```bash
./perf/run_perf_stat.sh
```

Hot spot analiza se pokreće komandom:

```bash
./perf/run_perf_hotspots.sh
```

Tekstualni rezultati čuvaju se u `perf/results/`.

Sanitizer analiza se reprodukuje komandom:

```bash
./sanitizers/run_sanitizers.sh
```

Rezultati se čuvaju u `sanitizers/results/`.

Cppcheck analiza se reprodukuje komandom:

```bash
./cppcheck/run_cppcheck.sh
```

Rezultat se čuva u `cppcheck/results/cppcheck_report.txt`.

## Izveštaj

Detaljan opis postupka analize i dobijenih rezultata nalazi se u fajlu:

ProjectAnalysisReport.md

## Zaključci

Analizom nije pronađen potvrđen bag u obuhvaćenoj verziji projekta `fmt`.

Dodatni unit testovi uspešno su prošli, a LCOV analiza pokazala je 26.0% line coverage i 20.9% function coverage nad analiziranim `fmt` kodom.

clang-format je u dva od tri odabrana reprezentativna fajla prijavio razlike u odnosu na format koji generiše korišćena konfiguracija, bez izmene izvornog koda. Za `fmt/src/os.cc` nisu prijavljene razlike.

Valgrind Memcheck nije prijavio memorijske greške ni curenje memorije na putanjama izvršenim kroz dodatne testove.

Perf analiza pokazala je hot spotove povezane sa parsiranjem format specifikacija, obradom format stringova i kopiranjem formatiranog sadržaja.

Tokom početnog ASan/UBSan pokretanja prijavljena su dva UBSan nalaza u originalnom testnom kodu. Oba su pojedinačno reprodukovana i analizirana, a finalni sanitizer prolaz nije prijavio dodatne probleme na obuhvaćenim putanjama.

Cppcheck je prijavio veći broj statičkih nalaza. Nekoliko reprezentativnih nalaza dodatno je ručno provereno u izvornom kodu i nijedan od njih nije potvrđen kao funkcionalna greška u biblioteci.

Rezultati važe za korišćene ulaze, testove, konfiguraciju alata i WSL okruženje i ne predstavljaju dokaz odsustva svih mogućih problema u biblioteci.