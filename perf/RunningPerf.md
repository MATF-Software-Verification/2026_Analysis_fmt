# Running Performance Analysis

Za analizu performansi koristi se Linux alat **perf**.

`perf` meri hardverske i softverske performance brojače tokom izvršavanja programa. U ovoj analizi korišćeni su:

- `perf stat` za zbirne metrike izvršavanja;
- `perf record` i `perf report` za statistički profil hot spotova.

## Okruženje

Analiza je izvršena u sledećem okruženju:

- Ubuntu 24.04.3 LTS u WSL2;
- kernel: `6.18.33.2-microsoft-standard-WSL2`;
- perf: 6.8.12.

Zbog WSL kernel verzije standardna komanda `perf` nije automatski pronašla alat. Zato skripte direktno koriste:

`/usr/lib/linux-tools/6.8.0-139-generic/perf`

Putanja se može promeniti postavljanjem promenljive `PERF_BIN` pri pokretanju skripte.

## Workload

Workload se nalazi u:

`perf/format_workload.cpp`

Program izvršava 10 miliona iteracija. U svakoj iteraciji poziva `fmt::format` za:

- celobrojnu vrednost sa širinom i vodećim nulama;
- `double` vrednost sa zadatom preciznošću;
- string vrednost sa poravnanjem i celobrojnim argumentom.

Rezultati formatiranja učestvuju u izračunavanju kontrolne vrednosti `checksum`, koja se na kraju ispisuje. Time se sprečava da kompajler ukloni formatting operacije kao nepotreban kod.

Workload se kompajlira sa opcijama:

- `-O2` — optimizovani build;
- `-g` — simboličke informacije za interpretaciju profila;
- `-DNDEBUG` — isključivanje `assert` provera.

## Zbirne metrike

Iz korena repozitorijuma pokrenuti:

```bash
./perf/run_perf_stat.sh

Skripta kompajlira workload, pokreće `perf stat` i čuva rezultat u:

`perf/results/perf_stat.txt`

Dobijeni rezultat za workload sa 10 miliona iteracija:

```text
task-clock:         1692.42 msec
time elapsed:       1.623658679 seconds
cycles:             7789029895
instructions:       38889633886
instructions/cycle: 4.99
branches:           6726364122
branch-misses:      203770
context-switches:   0
cpu-migrations:     0
```

Odnos promašaja grananja je približno 0.003%, što je nizak procenat za posmatrani workload.

## Hot spot analiza

Iz korena repozitorijuma pokrenuti:

```bash
./perf/run_perf_hotspots.sh
```

Skripta kompajlira workload, pokreće `perf record` sa opcijom `--call-graph dwarf`, a zatim pravi tekstualni izveštaj pomoću `perf report`.

Čitljiv rezultat se čuva u:

`perf/results/perf_report.txt`

Sirovi binarni profil se privremeno čuva u:

`perf/results/perf.data`

U dobijenom call graph profilu najzastupljenije putanje prolaze kroz:

- `fmt::vformat`;
- `fmt::detail::vformat_to`;
- `fmt::detail::parse_format_string`;
- obradu format specifikacija;
- upis formatiranog stringa;
- Unicode obradu i poravnavanje stringa.

Profil pokazuje da se u ovom konkretnom scenariju značajan deo CPU vremena troši na parsiranje format stringa i obradu njegovih specifikacija. To je očekivano, jer workload namerno često koristi specifikacije kao `{:08d}`, `{:.6f}` i `"{:<16}"`.

## Zaključak i ograničenja

U analiziranom workload-u nisu identifikovani neočekivani hot spotovi niti problem koji bi predstavljao potvrđeno usko grlo projekta.

Rezultati važe samo za izabrani workload, korišćeni računar i WSL2 okruženje. Oni nisu opšti benchmark cele biblioteke `fmt` i ne mogu se direktno porediti sa rezultatima sa drugog računara ili drugog operativnog sistema.

`perf record` koristi statističko uzorkovanje, pa procenat funkcije u hotspot izveštaju predstavlja procenu zasnovanu na prikupljenim uzorcima, a ne precizno vreme svake funkcije.