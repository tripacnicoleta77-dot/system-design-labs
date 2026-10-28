# Laboratorul 2: Cuantificarea citirilor Dashboard-ului

## Scopul laboratorului

Scopul acestui laborator este de a estima volumul de citiri al aplicației Personal Investment Dashboard, de a calcula cerințele de performanță și disponibilitate și de a identifica principalele riscuri tehnice ale sistemului.

Dashboard-ul permite utilizatorilor să urmărească prețurile acțiunilor, istoricul prețurilor, listele de urmărire (Watchlist) și să caute instrumente financiare.

Estimările sunt folosite pentru a înțelege de ce resurse ar avea nevoie sistemul și ce componente trebuie optimizate.

## Punctul de pornire

În Laboratorul 1 au fost identificate următoarele tipuri principale de citiri:

- **Overview** – afișează o imagine generală a investițiilor și a prețurilor.
- **Filter** – permite filtrarea instrumentelor financiare.
- **Stock price** – afișează cel mai recent preț al unei acțiuni.
- **History** – afișează istoricul prețurilor.
- **Watchlist** – afișează lista personală de instrumente urmărite.
- **Search** – permite căutarea instrumentelor financiare.

Prețurile trebuie să includă informații despre momentul actualizării sau despre întârzierea datelor. Dacă un preț nu este disponibil, sistemul trebuie să afișeze această stare, nu să folosească valoarea zero.

---

## 1. Cerințe de calitate

### 1.1. Performanță

Cerința principală de performanță este ca majoritatea citirilor să fie finalizate în maximum 2 secunde, inclusiv în perioadele aglomerate.

Criterii de acceptare:

- Percentila 95 (P95) a timpului de răspuns pentru citirile importante trebuie să fie de maximum 2 secunde.
- Timpul de răspuns trebuie măsurat în condiții de încărcare reprezentative pentru utilizarea reală.

### 1.2. Disponibilitate

Pentru acest laborator, se folosesc următoarele ținte:

- În timpul programului de tranzacționare: disponibilitate de 99,99%.
- În afara programului de tranzacționare: disponibilitate de 99,9%.

Se presupune o perioadă de 30 de zile, cu 22 de zile de tranzacționare și 6,5 ore de tranzacționare pe zi.

Calculul pentru programul de tranzacționare:

22 × 6,5 = 143 ore

143 × 60 × 60 = 514.800 secunde

Pentru o disponibilitate de 99,99%, timpul permis de indisponibilitate este:

514.800 × (1 − 0,9999) = 51,48 secunde

Prin urmare, bugetul de indisponibilitate în timpul tranzacționării este de aproximativ **51,5 secunde în 30 de zile**.

Calculul pentru perioada din afara programului de tranzacționare:

30 × 24 = 720 ore în total.

720 − 143 = 577 ore în afara programului de tranzacționare.

577 × 60 × 60 = 2.077.200 secunde.

Pentru o disponibilitate de 99,9%, timpul permis de indisponibilitate este:

2.077.200 × (1 − 0,999) = 2.077,2 secunde.

Acest lucru înseamnă aproximativ **34 minute și 37 de secunde** de indisponibilitate.

### 1.3. Consistența datelor

Sistemul trebuie să respecte următoarele reguli:

- Prețurile trebuie să aibă un moment de actualizare sau o indicație clară privind întârzierea datelor.
- Datele mai vechi de 15 minute trebuie marcate ca întârziate.
- Un preț lipsă trebuie afișat ca indisponibil, nu ca zero.
- Fiecare utilizator poate accesa numai propria listă Watchlist.
- După modificarea Watchlist, utilizatorul trebuie să vadă rezultatul actualizat la următoarea citire.

Disponibilitatea tehnică și corectitudinea datelor sunt două aspecte diferite. Sistemul poate fi disponibil, dar poate afișa date întârziate. În acest caz, starea datelor trebuie comunicată clar utilizatorului.

---

## 2. Calcularea cererilor în condiții normale (Steady State)

Pentru calcularea volumului de cereri, se presupun trei niveluri de utilizare:

- 100 de utilizatori activi;
- 1.000 de utilizatori activi;
- 10.000 de utilizatori activi.

Se consideră că fiecare utilizator activ generează cereri conform frecvențelor de mai jos.

### 2.1. Frecvența citirilor

| Tipul citirii | Procentul utilizatorilor | Frecvența |
|---|---:|---|
| Overview | 70% | O dată la 30 de secunde |
| Filter | 50% | De 3 ori pe minut |
| Stock price | 20% | O dată pe secundă |
| History | 20% | O dată la 5 minute |
| Watchlist | 60% | O dată pe minut |
| Search | 10% | De 3 ori pe minut |

### 2.2. Formula de calcul

RPS reprezintă numărul de cereri procesate pe secundă.

Formula generală este:

**RPS = numărul utilizatorilor activi × procentul utilizatorilor care efectuează citirea × frecvența cererilor pe secundă**

Frecvențele utilizate:

- O dată la 30 de secunde = 1/30 cereri pe secundă.
- De 3 ori pe minut = 3/60 = 0,05 cereri pe secundă.
- O dată pe secundă = 1 cerere pe secundă.
- O dată la 5 minute = 1/300 cereri pe secundă.
- O dată pe minut = 1/60 cereri pe secundă.

### 2.3. Calculul RPS pentru fiecare tip de citire

| Tipul citirii | 100 utilizatori | 1.000 utilizatori | 10.000 utilizatori |
|---|---:|---:|---:|
| Overview | 2,33 | 23,33 | 233,33 |
| Filter | 2,5 | 25 | 250 |
| Stock price | 20 | 200 | 2.000 |
| History | 0,067 | 0,667 | 6,667 |
| Watchlist | 1 | 10 | 100 |
| Search | 0,5 | 5 | 50 |
| **Total** | **26,4** | **264** | **2.640** |

### 2.4. Calcul detaliat pentru 100 de utilizatori

**Overview:**

100 × 70% × 1/30 = 2,33 RPS

**Filter:**

100 × 50% × 3/60 = 2,5 RPS

**Stock price:**

100 × 20% × 1 = 20 RPS

**History:**

100 × 20% × 1/300 = 0,067 RPS

**Watchlist:**

100 × 60% × 1/60 = 1 RPS

**Search:**

100 × 10% × 3/60 = 0,5 RPS

Totalul este:

2,3333 + 2,5 + 20 + 0,0667 + 1 + 0,5 = **26,4 RPS**

Pentru celelalte două niveluri de utilizare, valorile se multiplică proporțional cu numărul de utilizatori.

---

## 3. Calcularea cererilor în timpul deschiderii pieței (Market Open)

În timpul deschiderii pieței, utilizatorii pot reîncărca mai des dashboard-ul și lista Watchlist pentru a urmări schimbările de preț.

Se presupune că:

- 30% dintre utilizatorii activi reîncarcă Overview o dată la 10 secunde.
- Dintre acești utilizatori, 60% reîncarcă și Watchlist o dată la 10 secunde.
- Se adaugă o marjă de 10% pentru a acoperi variațiile de trafic.

### 3.1. Cereri suplimentare pentru Overview

Formula:

**RPS = numărul utilizatorilor × 30% × 1/10**

| Utilizatori activi | Cereri suplimentare Overview |
|---|---:|
| 100 | 3 RPS |
| 1.000 | 30 RPS |
| 10.000 | 300 RPS |

### 3.2. Cereri suplimentare pentru Watchlist

60% dintre utilizatorii care reîncarcă Overview efectuează și reîncărcarea Watchlist.

Formula:

**RPS = numărul utilizatorilor × 30% × 60% × 1/10**

| Utilizatori activi | Cereri suplimentare Watchlist |
|---|---:|
| 100 | 1,8 RPS |
| 1.000 | 18 RPS |
| 10.000 | 180 RPS |

### 3.3. Volumul total în timpul deschiderii pieței

Se adună cererile normale și cele suplimentare.

| Utilizatori activi | Steady State | Supliment Overview | Supliment Watchlist | Total înainte de marjă |
|---|---:|---:|---:|---:|
| 100 | 26,4 | 3 | 1,8 | 31,2 |
| 1.000 | 264 | 30 | 18 | 312 |
| 10.000 | 2.640 | 300 | 180 | 3.120 |

Se adaugă marja de 10%:

- 100 utilizatori: 31,2 × 1,1 = 34,32 RPS.
- 1.000 utilizatori: 312 × 1,1 = 343,2 RPS.
- 10.000 utilizatori: 3.120 × 1,1 = 3.432 RPS.

Prin urmare, valorile de planificare sunt:

| Utilizatori activi | RPS estimat cu marjă de 10% |
|---|---:|
| 100 | 34,32 |
| 1.000 | 343,2 |
| 10.000 | 3.432 |

Aceste valori reprezintă estimări bazate pe comportamentul presupus al utilizatorilor. Într-un sistem real, ele trebuie validate prin teste de încărcare și măsurători.

---

## 4. Estimarea volumului de date

### 4.1. Numărul de instrumente financiare

Pentru estimarea volumului de date, se folosește ca reper numărul de listări Nasdaq.

Conform raportului trimestrial Nasdaq pentru trimestrul al doilea din 2026, la 30 iunie 2026 erau 4.659 de listări pe Nasdaq Stock Market. Acest total include și 1.243 de produse tranzacționate la bursă (ETP).

Prin urmare, numărul de 4.659 nu reprezintă exact numărul acțiunilor obișnuite. În acest laborator, este utilizat ca reper aproximativ pentru estimarea capacității, nu ca număr exact al acțiunilor.

### 4.2. Dimensiunile estimate ale înregistrărilor

| Tipul datelor | Dimensiunea estimată |
|---|---:|
| Date de referință pentru un instrument financiar (Stock) | 512 B |
| Cel mai recent preț | 128 B |
| Un punct din istoricul prețului | 32 B |
| Calendarul pieței pentru o zi | 1 KiB |

Aceste valori sunt ipoteze de planificare, nu dimensiuni măsurate dintr-o bază de date reală. În practică, dimensiunea depinde de schema bazei de date, tipurile de date, indexuri și metadatele suplimentare.

### 4.3. Exemple de înregistrări

Exemplu de înregistrare Stock:

```json
{
  "symbol": "AAPL",
  "name": "Apple Inc.",
  "exchange": "NASDAQ",
  "currency": "USD"
}
