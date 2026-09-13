# clang-format analiza

Za proveru formatiranja izvornog koda korišćen je **clang-format 18.1.3**.

Cilj analize bio je da se proveri da li izabrani produkcioni fajlovi biblioteke `fmt`
odgovaraju pravilima definisanim u postojećoj projektnoj `.clang-format`
konfiguraciji.

Analiza nije menjala izvorne fajlove, već je samo prijavila mesta na kojima bi
`clang-format` primenio drugačije formatiranje.

## Obuhvat analize

Proverena su tri izabrana produkciona fajla:

- `include/fmt/base.h`
- `include/fmt/format.h`
- `src/os.cc`

Analiziran je samo ovaj odabrani skup fajlova, a ne ceo `fmt` projekat.

## Pokretanje analize

Analiza se pokreće iz korenskog direktorijuma projekta:

```bash
./clang_format/run_clang_format.sh
```

Rezultat se čuva u:

```text
clang_format/results/clang_format_report.txt
```

## Korišćena konfiguracija

Skripta koristi postojeću `.clang-format` konfiguraciju iz samog `fmt` projekta:

```text
fmt/.clang-format
```

Na taj način se kod ne proverava prema proizvoljno izabranom stilu, već prema
pravilima koja su već definisana u projektu.

Korišćene su opcije:

```text
--dry-run
--Werror
--style=file
```

Opcija `--dry-run` znači da `clang-format` ne menja fajlove, već samo proverava
kako bi oni bili formatirani.

Opcija `--style=file` nalaže alatu da koristi `.clang-format` fajl iz projekta.

Opcija `--Werror` dovodi do toga da se formatting odstupanja prijavljuju kao
greške i da komanda vraća neuspešan izlazni status. Te poruke ne predstavljaju
C++ sintaksne ili funkcionalne greške, već samo razlike u formatiranju.

## Struktura skripte

Skripta najpre određuje korenski direktorijum projekta i putanju do `fmt`
submodula.

Zatim definiše listu fajlova koji će biti analizirani:

```bash
TARGET_FILES=(
  "include/fmt/base.h"
  "include/fmt/format.h"
  "src/os.cc"
)
```

Pre same analize u rezultat se upisuju:

- verzija `clang-format` alata;
- putanja do `.clang-format` konfiguracije;
- lista proveravanih fajlova.

Nakon toga se analiza pokreće iz `fmt` direktorijuma.

Ako svi izabrani fajlovi odgovaraju formatiranju koje bi generisao
`clang-format`, u izveštaj se upisuje:

```text
Result: all selected files comply with the project formatting rules.
```

Ako postoje razlike, one se čuvaju u rezultatu i upisuje se:

```text
Result: formatting differences were detected.
```

U tom slučaju skripta vraća neuspešan izlazni status, jer je korišćena opcija
`--Werror`.

## Rezultat

Analiza je izvršena pomoću:

```text
Ubuntu clang-format version 18.1.3
```

Pronađene su formatting razlike u:

- `include/fmt/base.h`
- `include/fmt/format.h`

Za `src/os.cc` u rezultatu nisu prijavljene formatting razlike.

Ukupno je prijavljeno 103 mesta na kojima bi korišćeni `clang-format` primenio
drugačije formatiranje:

- 34 prijave u `include/fmt/base.h`
- 69 prijava u `include/fmt/format.h`

Tipični primeri odnose se na:

- prelom dugih deklaracija funkcija;
- poravnanje parametara;
- raspored višelinijskih izraza;
- pozicioniranje delova deklaracije u skladu sa pravilima iz `.clang-format`
  konfiguracije.

Ove prijave ne predstavljaju greške u ponašanju programa niti probleme koji
utiču na ispravnost izvršavanja.

## Tumačenje rezultata

Rezultat pokazuje da dva od tri analizirana fajla nisu identična izlazu koji bi
generisao `clang-format 18.1.3` koristeći projektnu `.clang-format`
konfiguraciju.

Ovo ne mora nužno da znači da je kod ručno formatiran pogrešno. Različite
verzije `clang-format` alata mogu u pojedinim slučajevima proizvesti različit
raspored koda čak i kada koriste isti konfiguracioni fajl.

Zbog toga je rezultat najpreciznije tumačiti kao razliku između trenutnog
formatiranja koda i formatiranja koje generiše korišćena verzija
`clang-format` alata.

## Zaključak

`clang-format` analiza je pokazala da u izabranim produkcionim fajlovima postoje
formatting razlike u odnosu na projektnu `.clang-format` konfiguraciju kada se
koristi `clang-format 18.1.3`.

Razlike su pronađene u `base.h` i `format.h`, dok za `src/os.cc` nisu
prijavljena odstupanja.

Analiza je izvršena u `--dry-run` režimu, tako da nijedan izvorni fajl nije
automatski izmenjen.

Rezultat predstavlja proveru stila i formatiranja izvornog koda i ne treba ga
tumačiti kao nalaz funkcionalnih ili sintaksnih grešaka u biblioteci.
