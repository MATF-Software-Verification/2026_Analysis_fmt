# Running Performance Analysis

Za analizu performansi koristi se Linux alat **perf**.

`perf` meri hardverske i softverske performance brojače tokom izvršavanja programa. U ovoj analizi korišćeni su:

* `perf stat` za zbirne metrike izvršavanja;
* `perf record` i `perf report` za statistički profil hot spotova.

## Okruženje

Analiza je izvršena u sledećem okruženju:

* Ubuntu 24.04.3 LTS u WSL2;
* kernel: `6.18.33.2-microsoft-standard-WSL2`;
* perf: 6.8.12.

Zbog WSL kernel verzije standardna komanda `perf` nije automatski pronašla alat. Zato skripte direktno koriste:

`/usr/lib/linux-tools/6.8.0-139-generic/perf`

Putanja se može promeniti postavljanjem promenljive `PERF_BIN` pri pokretanju skripte.

## Workload

Workload se nalazi u:

`perf/format_workload.cpp`

Program izvršava 10 miliona iteracija. U svakoj iteraciji poziva `fmt::format` za:

* celobrojnu vrednost sa širinom i vodećim nulama;
* `double` vrednost sa zadatom preciznošću;
* string vrednost sa poravnanjem i celobrojnim argumentom.

Rezultati formatiranja učestvuju u izračunavanju kontrolne vrednosti `checksum`, koja se na kraju ispisuje. Time se sprečava da kompajler ukloni formatting operacije kao nepotreban kod.

Workload se kompajlira sa opcijama:

* `-O2` — optimizovani build;
* `-g` — simboličke informacije za interpretaciju profila;
* `-DNDEBUG` — isključivanje `assert` provera.

## Zbirne metrike

Iz korena repozitorijuma pokrenuti:

```bash
./perf/run_perf_stat.sh
```

Skripta kompajlira workload, pokreće `perf stat` i čuva rezultat u:

`perf/results/perf_stat.txt`

Dobijeni rezultat za workload sa 10 miliona iteracija:

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

Odnos promašaja grananja je približno 0.003%, što je nizak procenat za posmatrani workload.

## Hot spot analiza

Za pregled funkcija sa najvećim pojedinačnim udelom uzoraka iz istog `perf.data` fajla generisan je i flat profil:

```bash
/usr/lib/linux-tools/6.8.0-139-generic/perf report \
  --stdio \
  --no-children \
  --sort symbol \
  -i perf/results/perf.data \
  > perf/results/perf_flat_report.txt
```

Najveći `Overhead` u dobijenom profilu imaju:

* `parse_format_specs` - 10.78%;
* `format_handler::on_format_specs` - 10.32%;
* `copy_noinline` - 9.46%;
* `parse_format_string` - 9.35%.

Rezultat pokazuje da su među najzastupljenijim pojedinačnim operacijama parsiranje i obrada format specifikacija, kao i kopiranje i upis dobijenog sadržaja.

To odgovara izabranom workload-u, koji u svakoj iteraciji koristi formatiranje sa širinom, preciznošću i poravnanjem (`{:08d}`, `{:.6f}` i `{:<16}`).

U profilu se pojavljuju i funkcije povezane sa kopiranjem podataka i radom sa rezultujućim stringovima, kao što su `memmove`, kao i funkcije za oslobađanje memorije. Ovo je očekivano jer se u svakoj iteraciji formiraju tri nova `std::string` rezultata.

Detaljni `perf report` sa call graph-om korišćen je kao dopuna flat profilu, kako bi se proverilo iz kojih delova workload-a dolaze izdvojene funkcije.
