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

Ova sekcija će biti dopunjavana tokom izrade seminarskog rada.

### LLVM libFuzzer uz ASan i UBSan

Za coverage-guided fuzz testiranje javnog `fmt::format` API-ja koristi se
LLVM libFuzzer uz AddressSanitizer i UndefinedBehaviorSanitizer. Fuzz target
obrađuje runtime format stringove za tipove `int`, `unsigned int`, `double` i
`std::string`.

Početni, ručno pripremljeni corpus nalazi se u `fuzzing/corpus/`, a kompletna
uputstva i objašnjenje rezultata u `fuzzing/RunningFuzzing.md`.

## Reprodukcija rezultata

Fuzzing analiza se iz korena repozitorijuma reprodukuje komandom:

```bash
./fuzzing/run_fuzzing.sh 500
```

Skripta kompajlira target sa libFuzzer, ASan i UBSan instrumentacijom, a zatim
ga pokreće nad seed corpusom. Eventualni reprodukcioni artefakti smeštaju se u
`fuzzing/artifacts/`.

Detaljna uputstva za ostale analize biće navedena u odgovarajućim direktorijumima i u ovom README fajlu nakon njihovog završetka.

## Izveštaj

Detaljan opis postupka analize i dobijenih rezultata nalaziće se u fajlu:

ProjectAnalysisReport.md

## Zaključci
