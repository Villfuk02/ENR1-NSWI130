

# Enrollments 1

## Core features and responsibilities

### Feature: Zápis předmětu
Jako student si chci zapsat předmět, abych mohl začít docházet na tento předmět (protože je třeba povinný).

#### Feature breakdown

1. Na dashboard student klikne na tlačítko a přejde na zápis předmětu 
2.  Student si vybere z nabídky předmětů - dostat všechny předměty pro výpis - seřadit/filtrovat lístky 
3. Zobrazí se mu všechny rozvrhové lístky pro vybraný předmět - dostat rozvrhové lístky předmětu - seřadit lístky 
4. Student si vybere lístek 
5. Pokud je lístek volný, tak se zapíše 
6. Pokud ne, nezapíše se 
7. Zobrazí se, jestli se zápis povedl 
8. Student bude přesměrován zpátky na nabídku předmětů

#### Responsibilities
##### Přístup k datům responsibilities 
- předměty, lístky daného předmětu 
##### Zápis předmětu responsibilities 
- +1 k zapsaným studentům na lístku - připsat studentovi lístek/předmět jako zapsaný 
- připsat studenta k lístku 
##### Filtrování předmětů responsibilities
- seřadit 
- filtrovat podle názvu/fakulty

### Feature: Zobrazovanie zmien pre manažéra
Ako manažér chcem mať prehľad o všetkých zmenách v lístkoch.

#### Feature breakdown:
1. Na dashboarde manažér klikne tlačidlo "Zobraziť audit log"
2. Po kliknutí sa zobrazí chronologický zoznam zmien.
	- zmeny treba načítať z databázy a zobraziť ich chronologicky (podľa času, kedy sa udiali)
 	- Každá zmena má dátum, čas, meno pracovníka, ktorý ju vykonal a náhľad obsahu zmeny
3. Manažér si môže vybrať ľubovoľnú zmeu a kliknúť na ňu
4. Zobrazí sa detail zmeny
   	- Zobrazí sa celý obsah zmeny

#### Responsibilities
##### Dashboard responsibilities
- tlačítko, ktoré presmeruje manažéra na zobrazenie zmien

##### Zoznam zmien responsibilities
- Získanie zoznamu zmien z databázy
- Zoradenie a zobrazenie zmien v chronologickom poradí
- Zobrazenie náhľadu zmeny (kvôli kompaktnosti UI)
- Zaistenie správneho priradenia zodpovednej osoby k zmene
  
##### Detail zmeny responsibilities
- Zobrazenie celej zmeny s dátumom, časom, zodpovednou osobou a jej plným obsahom

### Feature: Zobrazenie zapísaných študentov pre učiteľa

Ako učiteľ si chcem vedieť zobraziť zoznam zapísaných študentov, aby som si mohol viesť dochádzku.

### Feature breakdown

1. Učiteľ na dashboarde klikne na "Zobraziť zapísané lístky"
2. Systém zobrazí zoznam zapísaných lístkov
3. Učiteľ si môže jednotlivé lístky rozkliknúť
4. Po rozkliknutí sa mu zobrazí zoznam zapísaných študentov pre daný lístok


### Responsibilities
#### Dashboard responsibilities
- Zobraziť tlačítko "Zobraziť zapísané lístky"
- Zobraziť zoznam lístkov na učiteľovom dashboarde
- Zobraziť podrobnosti o študentoch po rozkliknutí lístka

#### Načítavacie responsibilities
- Umožniť učiteľovi prístup k informáciám o študentoch
- Načítať lístky z databázy
- Načítať študentov pre vybraný lístok

### Feature: Zobrazenie zapísaných predmetov pre študenta

Ako študent chcem mať možnosť zobraziť zapísané predmety, aby som mal prehľad o svojom zápise.

### Feature breakdown

1. Študent na dashboarde klikne na tlačidlo "Zápis", a následne tlačidlo "Zapísané"
2. Systém zobrazí zoznam zapísaných predmetov
3. Študent si môže jednotlivé predmetov rozkliknúť
4. Po rozkliknutí sa mu zobrazia podrobnejšie informácie o predmete

### Responsibilities
#### Dashboard responsibilities
- Zobraziť na dashboarde tlačidlá "Zápis" a následné "Zapísané"
- Zobraziť na dashboarde zoznam zapísaných predmetov
- Zobraziť na dashboarde podrobnejšie informácie o predmete po rozkliknutí

#### Načítavacie responsibilities
- Umožniť študentovi zobrazenie zapísaných predmetov
- Umožniť študentovi vidieť informácie o predmete
- Načítať z databázy predmety zvolené študentom
- Načítať z databázy informácie o predmete

### Feature: Komunikace učitele se studenty

Jakožto učitel chci mít možnost komunikovat se studenty na svých lístcích, abych je mohl informovat např. o případných změnách.

### Feature breakdown

1. Na Dashboardu se nachází tlačítko s nápisem: "Komunikace"
2. Po kliknutí na tlačítko se učiteli zobrazí jeho jednotlivé rozvrhové lístky
3. Pod každým rozvrhovým lístkem je seznam studentů, jež se do něj zapsali a u každého uveden jeho email
4. Učitel může každého studenta kontaktovat samostatně
5. U každého rozvrhového lístku se nachází tlačítko "Kontaktovat všechny zapsané", které umožní učiteli napsat hromadný email všem zapsaným na daný rozvrhový lístek
6. Pod všemi rozvrhovými lístky se nachází tlačítko "Kontaktovat všechny", které umožní učiteli napsat hromadný email všem zapsaným do jakéhokoliv rozvrhového lístku
7. Po kliknutí na tlačítka "Kontaktovat všechny", "Kontaktovat všechny zapsané" nebo jen rozkliknutí emailu jednoho z žáků se učiteli zobrazí možnost vyplnit předmět emailu a jeho obsah a tlačítko odeslat email

### Responsibilities
#### Dashboard responsibilities
- Zobrazit na dashboardu tlačítko "Komunikace"
- Zobrazit na dashboardu seznam zapsaných předmětů
- U každého rozvrhového lístku zobrazit seznam studentů do něj zapsaných a jejich email
- Zobrazit u každého rozvrhového lístku tlačítko "Kontaktovat všechny zapsané"
- Zobrazit tlačítko "Kontaktovat všechny"
- Zobrazit kolonky pro předmět a obsah emailu a tlačítko "Odeslat"

#### Načítávací responsibilities
- Umožnit učiteli vidět seznam všech jeho rozvrhových lístků
- Umožnit učiteli vidět email všech studentů k němu zapsaných
- Načíst z databáze emaily studentů
 
#### Odesílací responsibilities
- Po vyplnění obsahu emailu a stisknutí tlačítka "Odeslat" se email rozešle všem adresovaným
