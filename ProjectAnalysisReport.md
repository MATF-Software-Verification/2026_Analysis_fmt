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


### 4.2. Analiza 2

Biće dopunjeno.

### 4.3. Analiza 3

Biće dopunjeno.

### 4.4. Analiza 4

Biće dopunjeno.

### 4.5. Analiza 5

Biće dopunjeno.

### 4.6. Analiza 6

Biće dopunjeno.

## 5. Zaključak

Završni zaključci biće dodati nakon sprovođenja svih analiza.
