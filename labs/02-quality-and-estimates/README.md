# Lab 2: Quantify the Dashboard Reads

## 1. Cerințe de calitate (Quality requirements)

### 1.1. Latența citirilor (Read latency)

- **Măsurare:** timpul dintre trimiterea unei cereri de către utilizator și primirea răspunsului complet de la Dashboard.
- **Țintă:** cel puțin 95% dintre citirile corecte trebuie să se finalizeze în mai puțin de 2 secunde.
- **Condiții:** în perioadele aglomerate, inclusiv la deschiderea pieței, pentru un trafic de până la 30.000 de utilizatori concurenți.
- **Depășirea limitei:** dacă răspunsul durează 2 secunde sau mai mult, cererea nu respectă ținta de latență. Un răspuns rapid de tip „preț indisponibil” nu este considerat automat un răspuns corect cu date valide.

### 1.2. Disponibilitate (Availability)

Dashboard-ul este considerat disponibil dacă utilizatorul autentificat poate deschide aplicația și poate efectua citirile de bază, inclusiv accesarea propriului Watchlist. Datele care lipsesc trebuie indicate explicit, fără a bloca nejustificat restul aplicației.

Ipoteze pentru calcul:

- Programul pieței americane: 09:30–16:00, ora New York, în zilele de tranzacționare.
- Pentru estimare: 22 de zile de tranzacționare într-o perioadă de 30 de zile.
- Programul pieței: `22 × 6,5 = 143` ore.
- Restul perioadei: `720 − 143 = 577` ore.

Aleg ținte diferite deoarece utilizatorii au nevoie de acces deosebit de fiabil la prețuri în timpul programului pieței.

| Fereastră | Țintă de disponibilitate | Calculul timpului de indisponibilitate în 30 de zile |
|---|---:|---|
| Orele pieței | 99,99% | `143 × 0,0001 = 0,0143` ore = **51,48 secunde** |
| Restul zilei | 99,9% | `577 × 0,001 = 0,577` ore = **34,62 minute** |

Disponibilitatea se măsoară separat pentru cele două ferestre, pe o perioadă de 30 de zile. Valorile sunt bugete teoretice de indisponibilitate, nu măsurători reale.

### 1.3. Consistență (Consistency)

**Prețul unui Stock**

- **Măsurare:** vechimea datelor, calculată din momentul furnizat de Market Data Provider.
- **Țintă:** prețul afișat trebuie să includă momentul furnizorului și să indice clar întârzierea.
- **Ipoteză:** o vechime de până la 20 de minute este acceptată, având în vedere întârzierea estimată de aproximativ 15 minute comunicată în brief.
- Dacă datele depășesc 20 de minute, prețul este afișat ca indisponibil, nu ca zero.

**Watchlist**

- **Măsurare:** rezultatul următoarei citiri efectuate de același utilizator după confirmarea unei modificări.
- **Țintă:** următoarea citire trebuie să reflecte modificarea confirmată.
- **Condiție:** această regulă se aplică numai Watchlist-ului utilizatorului respectiv. Un utilizator nu poate citi sau modifica Watchlist-ul altui utilizator.

### 1.4. Debitul (Throughput)

- **Măsurare:** numărul de cereri Dashboard procesate cu succes pe secundă (RPS).
- **Țintă:** sistemul trebuie să susțină traficul calculat pentru 30.000 de utilizatori concurenți, inclusiv ținta de trafic pentru deschiderea pieței.
- **Condiție:** testele trebuie să includă citirile Overview, Filter, Stock price, History, Watchlist și Search.
- **Criteriu suplimentar:** atingerea RPS-ului țintă nu este suficientă dacă latența sau consistența nu respectă cerințele.

---

## 2. Steady RPS estimates

Formula utilizată pentru fiecare citire:

```ini
RPS = concurrent Users × participating share × actions per User / seconds
```

Comportamentul utilizatorilor este preluat din brief-ul original.

| **Read** | **300 Users** | **3,000 Users** | **30,000 Users** |
|---|---:|---:|---:|
| Overview | 7 RPS | 70 RPS | 700 RPS |
| Filter | 7,5 RPS | 75 RPS | 750 RPS |
| Stock price | 60 RPS | 600 RPS | 6.000 RPS |
| History | 0,2 RPS | 2 RPS | 20 RPS |
| Watchlist | 3 RPS | 30 RPS | 300 RPS |
| Search | 1,5 RPS | 15 RPS | 150 RPS |
| **Steady total** | **79,2 RPS** | **792 RPS** | **7.920 RPS** |

### 2.1. Calcule detaliate

Frecvențele utilizate:

- O dată la 30 secunde: `1/30` acțiuni pe secundă.
- De 3 ori pe minut: `3/60` acțiuni pe secundă.
- O dată pe secundă: `1` acțiune pe secundă.
- O dată la 5 minute: `1/300` acțiuni pe secundă.
- O dată pe minut: `1/60` acțiuni pe secundă.

| Read | Calcul pentru 300 de utilizatori | Rezultat nerotunjit |
|---|---|---:|
| Overview | `300 users × 0,70 × (1 action / 30 s)` | 7 RPS |
| Filter | `300 users × 0,50 × (3 actions / 60 s)` | 7,5 RPS |
| Stock price | `300 users × 0,20 × (1 action / 1 s)` | 60 RPS |
| History | `300 users × 0,20 × (1 action / 300 s)` | 0,2 RPS |
| Watchlist | `300 users × 0,60 × (1 action / 60 s)` | 3 RPS |
| Search | `300 users × 0,10 × (3 actions / 60 s)` | 1,5 RPS |

**Total pentru 300 de utilizatori:**

`7 + 7,5 + 60 + 0,2 + 3 + 1,5 = 79,2 RPS`

**Total pentru 3.000 de utilizatori:**

`70 + 75 + 600 + 2 + 30 + 15 = 792 RPS`

**Total pentru 30.000 de utilizatori:**

`700 + 750 + 6.000 + 20 + 300 + 150 = 7.920 RPS`

---

## 3. Market-open RPS estimates

La deschiderea pieței:

- 30% dintre utilizatori reîncarcă Overview o dată în intervalul de 10 secunde.
- 60% dintre acest grup reîncarcă și Watchlist în același interval.
- Aceste acțiuni se adaugă traficului normal.
- După subtotal se adaugă o marjă de capacitate de 10%.
- Se rotunjește în sus numai ținta finală.

| **Market-open calculation** | **300 Users** | **3,000 Users** | **30,000 Users** |
|---|---:|---:|---:|
| Steady read traffic | 79,2 RPS | 792 RPS | 7.920 RPS |
| Additional Overview refresh flow | `300 × 0,30 / 10 = 9 RPS` | `3.000 × 0,30 / 10 = 90 RPS` | `30.000 × 0,30 / 10 = 900 RPS` |
| Additional Watchlist refresh flow | `300 × 0,30 × 0,60 / 10 = 5,4 RPS` | `3.000 × 0,30 × 0,60 / 10 = 54 RPS` | `30.000 × 0,30 × 0,60 / 10 = 540 RPS` |
| **Market-open subtotal** | **93,6 RPS** | **936 RPS** | **9.360 RPS** |
| 10% capacity margin | 9,36 RPS | 93,6 RPS | 936 RPS |
| Total înainte de rotunjire | 102,96 RPS | 1.029,6 RPS | 10.296 RPS |
| **Rounded-up market-open target** | **103 RPS** | **1.030 RPS** | **10.296 RPS** |

### 3.1. Exemplu de calcul pentru 300 de utilizatori

```text
Additional Overview = 300 users × 0,30 / 10 seconds
                    = 9 RPS

Additional Watchlist = 300 users × 0,30 × 0,60 / 10 seconds
                     = 5,4 RPS

Market-open subtotal = 79,2 + 9 + 5,4
                     = 93,6 RPS

10% capacity margin = 93,6 × 0,10
                    = 9,36 RPS

Final target = ceil(93,6 + 9,36)
             = 103 RPS
```

Pentru 3.000 de utilizatori:

`(792 + 90 + 54) × 1,10 = 1.029,6 RPS → 1.030 RPS`

Pentru 30.000 de utilizatori:

`(7.920 + 900 + 540) × 1,10 = 10.296 RPS`

Nu se adaugă din nou traficul normal pentru Overview și Watchlist. Fluxurile din tabel sunt numai cererile suplimentare de la deschiderea pieței.

---

## 4. Storage estimates

### 4.1. Cercetarea și definirea unui Stock

Conform [Investor.gov — Stocks: FAQs](https://www.nasdaq.com/), o acțiune reprezintă un titlu financiar care conferă deținătorului o participație la o companie. Sursa distinge între acțiuni ordinare (common stock) și acțiuni preferențiale (preferred stock).

**Deciziile pentru prima versiune a Dashboard-ului:**

- **Piață:** The Nasdaq Stock Market din SUA.
- **Instrumente incluse:** acțiuni ordinare ale companiilor listate.
- **Instrumente excluse:** ETF-uri, alte ETP-uri, fonduri și acțiuni preferențiale.
- **Instrumente inactive:** companiile delistate nu apar în rezultatele curente de căutare, dar identitatea lor este păstrată pentru interpretarea istoricului.
- **Monedă:** USD.

**Estimarea numărului de instrumente**

Raportul oficial Nasdaq pentru trimestrul al treilea din 2026 indică 4.726 de companii listate pe Nasdaq Stock Market la 30 septembrie 2026, dintre care 1.292 de ETP-uri.

Sursă: [Nasdaq — Third Quarter 2026](https://www.nasdaq.com/).

Calcul orientativ:

`4.726 − 1.292 = 3.434`

Prin urmare, folosim **3.434 de instrumente ca estimare de planificare**, cu data observației de 30 septembrie 2026.

**Limitare:** diferența nu reprezintă un număr oficial verificat de acțiuni ordinare unice. Numărul de companii și numărul de instrumente financiare nu sunt identice. Pentru producție, lista exactă trebuie obținută din catalogul furnizorului și filtrată după tipul instrumentului. Valoarea de 3.434 este folosită pentru estimarea capacității.

### 4.2. Datele sincronizate

| Set de date | Câmpuri reprezentative | Necesitate în Dashboard | Frecvență presupusă |
|---|---|---|---|
| Stock reference data | ID, simbol, denumire, bursă, tip instrument, monedă, stare activă | Identificare, căutare și filtrare | Zilnic și la schimbări în catalog |
| Latest prices | ID instrument, preț, monedă, ora furnizorului, ora sincronizării, stare disponibilitate | Overview și Stock price | La fiecare 60 secunde în timpul programului pieței |
| Price history | ID instrument, interval temporal, deschidere, maxim, minim, închidere, volum | Graficul History | Puncte de un minut, actualizate pe parcursul zilei |
| Other selected data | Data, deschiderea pieței, închiderea pieței, indicator zi de tranzacționare | Interpretarea intervalelor istorice și programul pieței | Zilnic și la actualizarea calendarului |

Fiecare acțiune a utilizatorului creează o cerere Dashboard, dar nu presupunem că fiecare cerere Dashboard creează și o cerere către Market Data Provider. Traficul furnizorului necesită un model separat.

### 4.3. Exemple de înregistrări

Exemplu de înregistrare Stock:

```json
{
  "id": 1001,
  "symbol": "AAPL",
  "name": "Apple Inc.",
  "exchange": "NASDAQ",
  "instrument_type": "common_stock",
  "currency": "USD",
  "active": true
}
```

Exemplu de preț curent:

```json
{
  "stock_id": 1001,
  "price": 250.50,
  "currency": "USD",
  "provider_time": "2026-10-28T15:00:00Z",
  "sync_time": "2026-10-28T15:00:05Z",
  "status": "available"
}
```

Exemplu de punct istoric:

```json
{
  "stock_id": 1001,
  "timestamp": "2026-10-28T15:00:00Z",
  "open": 250.10,
  "high": 250.80,
  "low": 249.90,
  "close": 250.50,
  "volume": 12500
}
```

Dimensiunile medii presupuse:

| Tipul înregistrării | Dimensiune estimată |
|---|---:|
| Stock reference data | 512 B |
| Latest price | 128 B |
| Un punct din istoricul prețului | 32 B |
| O înregistrare de calendar al pieței | 1 KiB = 1.024 B |

Acestea sunt estimări pentru date brute. Nu includ indexuri, replici, copii de rezervă sau overhead-ul bazei de date.

### 4.4. Calcularea volumului de stocare

Ipoteze:

- Număr de instrumente: 3.434.
- O zi de tranzacționare: 390 de minute.
- Istoric: o înregistrare pe minut pentru fiecare instrument.
- Retenție: 252 de zile de tranzacționare, aproximativ un an.
- Fiecare zi de tranzacționare conține 390 de puncte istorice.

Formule:

```text
raw storage = record count × average bytes per record

history record count
  = supported Stocks × history points per Stock per day × retained days
```

**Stock reference data**

`3.434 Stocks × 512 B = 1.758.208 B`

**Latest prices**

`3.434 Stocks × 128 B = 439.552 B`

**Price history — o zi**

`3.434 × 390 = 1.339.260 înregistrări`

`1.339.260 × 32 B = 42.856.320 B`

**Price history — un an**

`3.434 × 390 × 252 = 337.493.520 înregistrări`

`337.493.520 × 32 B = 10.799.792.640 B`

**Calendarul pieței — un an**

`252 zile × 1.024 B = 258.048 B`

### 4.5. Tabelul complet de stocare

| **Data set** | **Decizie și retenție** | **Calculul numărului de înregistrări** | **Bytes per record** | **Raw storage** |
|---|---|---|---:|---:|
| Stock reference data | Instrumentele selectate; păstrate pentru identificare și istoric | `3.434` | 512 B | 1.758.208 B |
| Latest prices | Ultimul preț pentru fiecare instrument; înregistrarea se actualizează | `3.434` | 128 B | 439.552 B |
| Price history | Bare de un minut; 252 zile de tranzacționare | `3.434 × 390 × 252 = 337.493.520` | 32 B | 10.799.792.640 B |
| Other selected data | Calendarul pieței; 252 zile | `252` | 1.024 B | 258.048 B |
| **Total** | | | | **10.802.248.448 B** |

### 4.6. Stocare inițială, zilnică și anuală

Încărcarea inițială conține întregul istoric de 252 de zile, datele de referință, ultimele prețuri și calendarul. Ulterior, istoricul crește zilnic, iar prețurile curente sunt suprascrise.

| Estimare | Calcul | Rezultat aproximativ |
|---|---|---:|
| Stocare inițială pentru un an de istoric | Suma tuturor celor patru seturi | **10,06 GiB** |
| Creștere zilnică | `42.856.320 + 1.024 B` | **42.857.344 B ≈ 40,87 MiB/zi** |
| Date istorice noi într-un an | `42.856.320 × 252 B` | **10,03 GiB** |
| Stocare totală cu retenție rulantă de un an | Date de referință + ultimele prețuri + un an de istoric + calendar | **10,06 GiB** |

Conversii: `1 GiB = 2³⁰ B` și `1 MiB = 2²⁰ B`.

Dacă istoricul nu este șters după un an, spațiul va continua să crească. Estimarea nu include overhead-ul bazei de date și replicile.

---

## 5. Find and analyze the potential bottlenecks

Un volum mare de RPS indică o zonă care trebuie investigată, dar nu demonstrează că există deja un blocaj.

| **Quality** | **Potential bottleneck** | **Evidence from this lab** | **Possible effect** | **What to measure next** |
|---|---|---|---|---|
| Latency | Citirile Stock price și Filter, inclusiv accesul la baza de date | La 30.000 de utilizatori, Stock price generează 6.000 RPS, iar Filter 750 RPS | Timpul de răspuns poate depăși 2 secunde în perioadele aglomerate | P95 și P99 ale latenței, timpul de interogare al bazei de date și durata cererilor |
| Consistency | Sincronizarea dintre Market Data Provider și datele salvate în Dashboard | Furnizorul poate avea o întârziere de aproximativ 15 minute | Dashboard-ul poate afișa un preț prea vechi sau fără indicator clar al întârzierii | Vechimea datelor, diferența dintre ora furnizorului și ora sincronizării, procentul prețurilor mai vechi de 20 de minute |
| Throughput | Procesarea cererilor simultane și accesul la baza de date | La deschiderea pieței, ținta este de 10.296 RPS pentru 30.000 de utilizatori | Cererile se pot acumula, iar sistemul poate răspunde mai lent sau poate respinge cereri | Cereri procesate pe secundă, numărul cererilor în așteptare, utilizarea CPU și a conexiunilor la baza de date |
| Availability | Dependența de Market Data Provider și punctele unice de defectare ale Dashboard-ului | Disponibilitatea trebuie măsurată separat în timpul pieței și în restul zilei | O întrerupere a furnizorului sau a unei componente esențiale poate face unele funcții indisponibile | Uptime pe fiecare fereastră, numărul și durata incidentelor, rata erorilor și disponibilitatea componentelor independente |

### 5.1. Explicarea blocajelor potențiale

**1. Latency — latență**

Calea de citire a prețului unei acțiuni este o zonă importantă de investigat. La 30.000 de utilizatori, această citire reprezintă 6.000 RPS în estimarea normală. Dacă interogările sunt lente sau conexiunile la baza de date sunt insuficiente, timpul de răspuns poate depăși limita de 2 secunde.

Ipoteza se confirmă dacă testele arată că P95 depășește 2 secunde și se observă o creștere a timpului de interogare sau a cozilor de cereri.

**2. Consistency — consistență**

Calea de sincronizare a prețurilor poate produce date învechite dacă furnizorul întârzie sau dacă procesul de sincronizare nu actualizează la timp baza de date. Modificările Watchlist trebuie, de asemenea, să fie vizibile la următoarea citire a aceluiași utilizator.

Ipoteza se verifică prin măsurarea vechimii prețurilor și prin teste în care se modifică Watchlist-ul, apoi se citește din nou pentru a confirma că modificarea este prezentă.

**3. Throughput — debit**

La deschiderea pieței, sistemul trebuie să susțină o țintă de 10.296 RPS pentru 30.000 de utilizatori concurenți. Dacă aplicația, baza de date sau conexiunile disponibile nu pot procesa acest volum, cererile se acumulează și latența crește.

Ipoteza se verifică prin teste de încărcare la ținta calculată, urmărind numărul de cereri procesate, erorile, resursele utilizate și latența.

**4. Availability — disponibilitate**

Dashboard-ul depinde de propriile componente și de Market Data Provider. Dacă furnizorul nu răspunde, prețurile pot deveni indisponibile. Totuși, problema nu trebuie să facă automat indisponibile toate funcțiile aplicației, precum accesul la Watchlist sau la datele istorice deja salvate.

Ipoteza se verifică prin simularea indisponibilității furnizorului și prin măsurarea funcțiilor care continuă să funcționeze, a ratei erorilor și a timpului total de indisponibilitate.

---

## Checklist

- [x] Am scris cerințe măsurabile pentru toate calitățile de bază.
- [x] Am ales și justificat ținte de uptime pentru ambele perioade ale zilei.
- [x] Am arătat calculele steady RPS și market-open RPS pentru toate cele trei scări.
- [x] Am cercetat și definit domeniul Stock-urilor acceptate.
- [x] Am estimat stocarea inițială, zilnică și pentru un an a datelor brute.
- [x] Am precizat ipotezele, unitățile, intervalele și rotunjirea finală.
- [x] Am analizat cel puțin un posibil blocaj pentru fiecare calitate de bază.

## Concluzie

Pentru 30.000 de utilizatori concurenți, Dashboard-ul trebuie proiectat pentru o țintă estimată de **10.296 RPS la deschiderea pieței**. Stocarea brută estimată pentru domeniul și retenția alese este de aproximativ **10,06 GiB** pentru încărcarea inițială cu un an de istoric. Aceste valori sunt estimări de planificare și trebuie validate prin teste de încărcare și prin date reale de la furnizor.
