# ASan i UBSan analiza

Za dinamičku analizu memorijskih grešaka i nedefinisanog ponašanja korišćeni su **AddressSanitizer (ASan)** i **UndefinedBehaviorSanitizer (UBSan)**.

Analiza je sprovedena nad:

- originalnim `fmt` testovima;
- dodatnim testovima napravljenim u okviru projekta.

Sanitizer analiza je izvršena pomoću Clang kompajlera.

## Pokretanje analize

Analiza se pokreće iz korenskog direktorijuma projekta:

```bash
./sanitizers/run_sanitizers.sh
```

Skripta koristi sledeće sanitizer opcije:

```bash
SANITIZER_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer -O1 -g"
SANITIZER_LINK_FLAGS="-fsanitize=address,undefined"
```

Opcija `-fsanitize=address,undefined` uključuje AddressSanitizer i UndefinedBehaviorSanitizer.

ASan služi za otkrivanje problema sa memorijom, kao što su pristupi memoriji van dozvoljenih granica i korišćenje memorije nakon njenog oslobađanja.

UBSan otkriva određene oblike nedefinisanog ponašanja u C++, kao što su nedozvoljene operacije nad pokazivačima i druge operacije koje prema C++ standardu imaju undefined behavior.

Opcija `-fno-omit-frame-pointer` zadržava informacije koje sanitizerima olakšavaju prikazivanje čitljivog stack trace-a.

Opcije `-O1 -g` koriste blagu optimizaciju i uključuju debug simbole, kako bi dijagnostika sanitizera sadržala korisne informacije o funkcijama, fajlovima i linijama izvornog koda.

## Runtime podešavanja

Sanitizer testovi se izvršavaju sa sledećim podešavanjima:

```bash
ASAN_OPTIONS=detect_leaks=0
UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1
```

LeakSanitizer je isključen pomoću `detect_leaks=0` zbog ograničenja WSL okruženja vezanog za `ptrace`.

Ovo isključuje samo detekciju curenja memorije. Ostale provere AddressSanitizera ostaju aktivne.

Za UBSan se koriste opcije `halt_on_error=1` i `print_stacktrace=1`, tako da se izvršavanje zaustavlja nakon UBSan prijave i prikazuje se stack trace koji olakšava određivanje mesta na kojem je problem nastao.

## Analiza originalnih fmt testova

Originalni `fmt` testovi posebno se kompajliraju sa uključenim ASan i UBSan instrumentacijama.

Za njih se koristi poseban build direktorijum:

```text
sanitizers/build/fmt
```

Tokom početnog sanitizer pokretanja identifikovana su dva originalna testa koja pod UBSan-om proizvode prijave:

- `memory_buffer_test.move_ctor_dynamic_buffer_non_propagating`
- `ostream_test.write_to_ostream_max_size`

Ovi testovi nisu automatski zanemareni. Oba su dodatno pokrenuta pojedinačno i njihove UBSan prijave su analizirane.

### `memory_buffer_test.move_ctor_dynamic_buffer_non_propagating`

Pojedinačnim pokretanjem testa dobijena je UBSan prijava:

```text
runtime error: reference binding to null pointer of type 'std::allocator<char>'
```

Prijava nastaje u `fmt/test/mock-allocator.h`, u testnom tipu `allocator_ref`.

Test koristi `basic_memory_buffer` sa non-propagating allocatorom. Prvi buffer ima eksplicitno zadat allocator, dok se odredišni buffer pravi bez eksplicitno zadatog allocatora:

```cpp
basic_memory_buffer<char, 4, std_allocator_noprop> buffer2;
buffer2 = std::move(buffer);
```

Pošto je allocator non-propagating, allocator iz izvornog buffera se ne prenosi na odredišni buffer. Tokom move operacije dolazi do potrebe za alokacijom, a testni `allocator_ref` u tom trenutku nema validan allocator pokazivač.

UBSan zbog toga prijavljuje vezivanje reference za null pokazivač.

Stack trace povezuje prijavu sa testom preko poziva:

```text
allocator_ref::allocate
basic_memory_buffer::grow
buffer::try_reserve
basic_memory_buffer::resize
basic_memory_buffer::move_alloc
basic_memory_buffer::move
basic_memory_buffer::operator=
```

Na osnovu toga zaključeno je da prijava potiče iz specifične konstrukcije testnog allocatora i ovog testnog scenarija, a ne predstavlja potvrđen problem u uobičajenom korišćenju `fmt` biblioteke.

### `ostream_test.write_to_ostream_max_size`

Pojedinačnim pokretanjem drugog testa dobijena je UBSan prijava:

```text
runtime error: applying non-zero offset 9223372036854775807 to null pointer
```

Prijava nastaje direktno u `fmt/test/ostream-test.cc` na operaciji:

```cpp
data += n;
```

pri čemu je pokazivač prethodno postavljen na:

```cpp
const char* data = nullptr;
```

Ovaj test proverava ponašanje funkcije za upisivanje veoma velikog buffera.

Umesto stvarne alokacije buffera maksimalne veličine, test konstruiše specijalni testni buffer i koristi `nullptr` kao fiktivnu početnu adresu podataka. Zatim vrši pointer aritmetiku nad tim pokazivačem kako bi simulirao pomeranje kroz veoma veliki buffer.

UBSan takvu operaciju prijavljuje kao undefined behavior, jer se nenulti offset dodaje na null pokazivač.

Prijava zato nastaje direktno u specifičnoj konstrukciji testnog koda.

## Izvršavanje ostatka originalnih testova

Da se zbog dva prethodno analizirana slučaja ne bi izgubio ostatak testnog obuhvata, `format-test` i `ostream-test` se prvo izuzimaju iz opšteg `ctest` poziva:

```bash
ctest --test-dir "$FMT_BUILD_DIR"   --output-on-failure   -E '^(format-test|ostream-test)$'
```

Nakon toga se oba test programa pokreću direktno, ali se iz svakog izuzima samo jedan prethodno analizirani test slučaj.

Za `format-test`:

```bash
"$FMT_BUILD_DIR/bin/format-test"   --gtest_filter=-memory_buffer_test.move_ctor_dynamic_buffer_non_propagating
```

Za `ostream-test`:

```bash
"$FMT_BUILD_DIR/bin/ostream-test"   --gtest_filter=-ostream_test.write_to_ostream_max_size
```

Na taj način nisu izuzeti čitavi testni programi, već samo dva konkretna testna slučaja kod kojih su UBSan prijave prethodno ručno analizirane.

U finalnom sanitizer prolazu:

- `ctest` deo je završio sa 18 od 18 uspešnih testova;
- `format-test` je izvršio 137 testova iz 8 test suite-ova i svi su prošli;
- `ostream-test` je izvršio 18 testova i svi su prošli.

U tim izvršavanjima nije bilo ASan ni UBSan prijava.

Rezultat originalnih testova čuva se u:

```text
sanitizers/results/fmt_tests.log
```

## Dodatni testovi

Dodatni testovi se grade odvojeno u direktorijumu:

```text
sanitizers/build/custom
```

i takođe se kompajliraju sa ASan i UBSan instrumentacijom.

Nakon build-a pokreće se:

```text
format_edge_tests
```

sa istim runtime sanitizer podešavanjima.

Svih pet dodatnih testova je uspešno prošlo i tokom njihovog izvršavanja nisu primećene ASan ni UBSan prijave.

Rezultat se čuva u:

```text
sanitizers/results/custom_tests.log
```

## Rezultat

Tokom početne analize identifikovana su dva originalna test slučaja koja proizvode UBSan prijave zbog specifičnih konstrukcija u samom testnom kodu.

Oba slučaja su pojedinačno pokrenuta i analizirana pre njihovog izuzimanja iz finalnog sanitizer prolaza.

Nakon izuzimanja samo ta dva konkretna testa:

- ostatak originalnog `fmt` test suite-a uspešno je prošao;
- svih pet dodatnih testova uspešno je prošlo;
- u izvršenim testovima nije bilo ASan ni UBSan prijava.

LeakSanitizer nije bio uključen zbog ograničenja WSL okruženja, pa ovom analizom nije obuhvaćena detekcija curenja memorije.

## Zaključak

ASan i UBSan nisu otkrili potvrđen problem u `fmt` implementaciji na testnim putanjama obuhvaćenim finalnim sanitizer izvršavanjem.

Dve UBSan prijave koje su se pojavile tokom početnog pokretanja detaljnije su analizirane i utvrđeno je da potiču iz specifičnih konstrukcija originalnog testnog koda.

Rezultati ne predstavljaju dokaz da biblioteka ne sadrži druge probleme. Sanitizeri dinamički proveravaju samo kod koji je stvarno izvršen tokom testiranja.
