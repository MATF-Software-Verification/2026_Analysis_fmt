# Cppcheck

Cppcheck je korišćen za statičku analizu izvornog koda biblioteke `fmt`.
Analizirani su direktorijumi `fmt/include` i `fmt/src`.

## Pokretanje

Iz korenskog direktorijuma projekta:

```bash
./cppcheck/run_cppcheck.sh
```

Rezultat analize se čuva u:

```text
cppcheck/results/cppcheck_report.txt
```

Analiza koristi C++20 standard i uključuje kategorije:

- `warning`
- `style`
- `performance`
- `portability`

Sistemski include fajlovi koji nisu dostupni Cppcheck-u nisu prijavljivani kao greške.

## Rezultat

Finalna analiza prijavila je ukupno **136 nalaza**:

- 4 `error`
- 19 `warning`
- 103 `style`
- 8 `performance`
- 2 `portability`

Najveći broj nalaza odnosio se na preporuke kao što su
`noExplicitConstructor`, `shadowFunction`,
`knownConditionTrueFalse` i `passedByValue`.

Nalazi nisu automatski tretirani kao potvrđene greške, već su
reprezentativni slučajevi dodatno pregledani u izvornom kodu.

## Ručna provera reprezentativnih nalaza

### `shiftNegativeLHS`

Cppcheck je prijavio desni shift negativne vrednosti u izrazu:

```cpp
static_assert((-1 >> 1) == -1, "right shift is not arithmetic");
```

Pregledom koda utvrđeno je da je ova operacija namerno korišćena kao
compile-time provera ponašanja platforme. Nalaz zato nije potvrđen kao
funkcionalna greška.

### `AssignmentAddressToInteger`

Nalaz je prijavljen kod poziva `FMT_RETRY_VAL` prilikom otvaranja fajla.

Pregledom makroa i deklaracije člana `file_` utvrđeno je da je `file_`
tipa `FILE*`, a `fopen` takođe vraća `FILE*`. Nema stvarne dodele
pokazivača celobrojnom tipu, pa je nalaz najverovatnije posledica
interpretacije makroa od strane Cppcheck-a.

### `mismatchingContainerExpression`

Cppcheck je prijavio poređenje:

```cpp
sv.end() == s.end()
```

Pregledom funkcije `for_each_codepoint` utvrđeno je da `sv` predstavlja
pogled nad delom iste memorije na koju pokazuje originalni `s`.
Poređenje se namerno koristi za proveru da li je dostignut kraj stringa.

### `uninitMemberVar`

Cppcheck je prijavio da `writer::file_` nije inicijalizovan u konstruktoru
koji prima bafer.

Član zaista nije eksplicitno inicijalizovan, ali se u tom slučaju
`buf_` postavlja na prosleđeni bafer, pa metoda `print` koristi `buf_`,
dok se `file_` ne čita.

Nalaz zato nije potvrđen kao funkcionalna greška u analiziranom toku
izvršavanja.

## Zaključak

Cppcheck je izdvojio više potencijalno interesantnih mesta u kodu,
pretežno iz kategorija `style` i `performance`.

Ručnom proverom nekoliko reprezentativnih upozorenja nije potvrđena
funkcionalna greška u biblioteci `fmt`. Rezultati pokazuju da nalaze
statičke analize treba dodatno tumačiti u kontekstu izvornog koda.
