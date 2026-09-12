# Running Cppcheck Analysis

Za statičku analizu korišćen je **Cppcheck 2.13.0**.

Cppcheck analizira izvorni kod bez njegovog izvršavanja i prijavljuje potencijalne greške, sumnjive obrasce, portability probleme i preporuke za stil ili performanse.

## Obuhvat analize

Analiziran je produkcioni kod biblioteke:

- `fmt/include/`;
- `fmt/src/`.

Testni direktorijumi nisu obuhvaćeni, jer je cilj analize implementacija biblioteke `fmt`.

## Pokretanje

Iz korena repozitorijuma pokrenuti:

```bash
./cppcheck/run_cppcheck.sh
```

Rezultat se čuva u:

`cppcheck/results/cppcheck_report.txt`

## Korišćene opcije

Analiza koristi sledeće važne opcije:

```text
--enable=warning,style,performance,portability
--inconclusive
--force
--std=c++20
--inline-suppr
--suppress=missingIncludeSystem
```

- `--inconclusive` uključuje i nesigurne nalaze, koji se ne tumače kao automatski bagovi;
- `--force` pokušava analizu svih pronađenih konfiguracija;
- `--std=c++20` postavlja standard jezika;
- `--suppress=missingIncludeSystem` uklanja nebitne poruke o sistemskim headerima.

## Rezultat

Cppcheck je prijavio:

- 4 `syntaxError` poruke;
- 20 warnings;
- 131 style preporuku;
- 34 performance preporuke;
- 2 portability upozorenja.

Četiri `syntaxError` poruke nalaze se u makro/template deklaracijama koje Cppcheck 2.13 ne parsira potpuno u ovoj konfiguraciji. One nisu potvrđene greške u `fmt` kodu, jer je isti kod uspešno kompajliran Clang-om i izvršen kroz testove.

Većina nalaza pripada kategorijama kao što su:

- `noExplicitConstructor`;
- `functionConst`;
- `functionStatic`;
- `shadowFunction`;
- `passedByValue`.

To su preporuke za stil, čitljivost ili potencijalni refaktoring, a ne potvrđeni problemi u ponašanju programa.

Nekoliko upozorenja koja na prvi pogled deluju ozbiljnije provereno je ručno:

- `bitwiseOnBoolean` se javlja u Dragonbox implementaciji i odnosi se na namerne bitovske/paritetne provere;
- `shiftNegativeLHS` dolazi iz `static_assert` provere ponašanja aritmetičkog desnog shift-a;
- `accessMoved` prijavljuje objekat koji se nakon `std::move` ponovo inicijalizuje pozivom `resize`;
- `AssignmentAddressToInteger` nastaje usled makro-ekspanzije oko poziva `fopen`.

Nijedan od tih nalaza nije potvrđen kao bag u analiziranom `fmt` kodu.

## Zaključak i ograničenja

Cppcheck nije pronašao potvrđen problem u analiziranoj implementaciji biblioteke.

Alat je koristan za otkrivanje kandidata za ručnu proveru, ali rezultat nije dokaz odsustva grešaka. Kod projekta `fmt` intenzivno koristi template-e i makroe, što ograničava preciznost Cppcheck analize i proizvodi deo očekivanih false-positive ili style nalaza.