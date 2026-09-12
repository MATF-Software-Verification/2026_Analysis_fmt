# 2026_Analysis_fmt

## Analiza projekta fmt
### Autor

Dunja Mijačić

## Analizirani projekat

U okviru seminarskog rada analizira se projekat fmt, biblioteka otvorenog koda za formatiranje teksta u C++ jeziku.

- Projekat: fmt
- Izvorni kod: https://github.com/fmtlib/fmt
- Analizirana grana: master
- Analizirani commit: 7bce22571a49ba7921174effefbfbf24300667a6

Originalni projekat je dodat u ovaj repozitorijum kao Git submodule u direktorijumu fmt.

## Cilj analize

Cilj seminarskog rada je analiza projekta korišćenjem različitih tehnika i alata za verifikaciju softvera, sa fokusom na pronalaženje potencijalnih grešaka, problema sa memorijom, neispravnog ponašanja.

U okviru rada biće korišćeno najmanje šest alata ili tehnika za analizu softvera.

## Korišćeni alati i tehnike

Trenutno su završene sledeće analize:

### Unit testovi i LCOV

Napisano je pet dodatnih Google Test testova nad javnim `fmt::format` API-jem. Pokrivenost koda prati se alatom LCOV.

Dobijena pokrivenost `fmt` koda dodatnim testovima iznosi:

- line coverage: 26.0%;
- function coverage: 20.9%.

Detaljno uputstvo nalazi se u `unit_tests/RunningTests.md`.

### LLVM libFuzzer uz ASan i UBSan

Za coverage-guided fuzz testiranje javnog `fmt::format` API-ja koristi se LLVM libFuzzer uz AddressSanitizer i UndefinedBehaviorSanitizer.

Fuzz target obrađuje runtime format stringove za tipove `int`, `unsigned int`, `double` i `std::string`. Početni, ručno pripremljeni corpus nalazi se u `fuzzing/corpus/`.

Detaljno uputstvo i tumačenje rezultata nalaze se u `fuzzing/RunningFuzzing.md`.

### Valgrind Memcheck

Za runtime analizu memorije koristi se Valgrind Memcheck nad izvršnim programom dodatnih unit testova.

Memcheck proverava nevalidne pristupe memoriji, upotrebu neinicijalizovanih vrednosti i curenje memorije. U izvršenoj analizi nad pet testova nije prijavljena nijedna memorijska greška niti curenje memorije.

Detaljno uputstvo i tumačenje rezultata nalaze se u `valgrind/RunningValgrind.md`.

### perf

Za analizu performansi koristi se Linux alat perf.

Napravljen je kontrolisani workload koji više puta poziva `fmt::format` nad celobrojnim, floating-point i string vrednostima. Korišćeni su `perf stat` za zbirne metrike i `perf record`/`perf report` za pronalaženje hot spotova.

Detaljno uputstvo i tumačenje rezultata nalaze se u:

`perf/RunningPerf.md`

## Reprodukcija rezultata

Unit testovi i coverage analiza pokreću se iz korena repozitorijuma komandom:

```bash
./unit_tests/run_tests.sh
```

Fuzzing analiza se reprodukuje komandom:

```bash
./fuzzing/run_fuzzing.sh 500
```

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

## Izveštaj

Detaljan opis postupka analize i dobijenih rezultata nalaziće se u fajlu:

ProjectAnalysisReport.md

## Zaključci
