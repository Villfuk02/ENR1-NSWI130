# Run-time požadavky

## Výkon

### Efektivní zápis pod vysokým zatížením [Gutvald]

**Scénář:**

- **Zdroj stimulu:** Student pokoušející se zapsat do kurzu.
- **Stimulus:** Student odešle žádost o zápis prostřednictvím komponenty **Zapsat studenta na lístek**, zatímco tisíce dalších uživatelů podávají podobné žádosti současně.
- **Artefakt:** **Zapsat studenta na lístek** v kontejneru **Zápisy uživatele**.
- **Očekávané měření:** 99 % transakcí zápisů by mělo být úspěšně dokončeno do 2 sekund, i při 5 000 požadavcích za minutu. **Každý** požadavek musí doručit uživateli zpětnou vazbu zda byla transakce úspěšná, a to do 2 sekund.

**Navrhované řešení:**

- **Optimalizace databázových transakcí:**  
  Použití optimalizovaných neblokujících dotazů ke snížení zátěže na databáze.

- **Kešování:**  
  Kešování často přistupovaných dat ke snížení zátěže databází.

- **Horizontální škálování:**  
  Nasadit více instancí kontejneru **Zápisy uživatele** pro efektivní rozložení zátěže.  
  Použití load balanceru pro rovnoměrné rozdělení požadavků mezi instance.

**Změny architektury:**
Stávající architektura je více-méně dostatečná, protože do ní navrhované změny nezasahují.
V případě kešování by bylo mozné oddělit logiku kešování do separátního komponentu.
Podobně, při použití load balanceru by tento load balancer stál jako separátní kontejner.

## Zpetna oprava databaze pri neopravnenem zapise [Jezowicz]

- **Zdroj stimulu:** Utocnik
- **Stimulus:** Zapsani studenta na termin zkousky v databazi utocnikem
- **Artefakt:** Limit poctu studentu zapsanych na termin je prekroceno
- **Očekávané měření:** Odchyceni neopravneneho zapisu a jeho odstraneni z databaze

**Navrhovaná řešení:**

- **Attack Recovery**
  Zavedeni containeru, ktery udrzuje seznam validnich pozadavku pro zapis do databaze. Kdyz databaze potvrdi zapis, dojde k overeni, zda byl pozadavek systemem skutecne zadan. Pokud nebyl, eventualne dojde k oprave databaze.

**Změny architektury:**
  Pridani containeru 'Enlistment Validator', ktery je schopen odchytit neopravneny zapis do databaze.

## Dostupnost

### Obnova po selhání Smerovacího engine [Gutvald]

**Scénář:**

- **Zdroj stimulu:** Student pokoušející se přejít na stránku zápisů.
- **Stimulus:** Komponenta **Smerovací engine** selže během zpracování požadavku kvůli neočekávané chybě nebo přetížení.
- **Artefakt:** **Smerovací engine** v kontejneru **Směrovač stránek**.
- **Očekávané měření:** Systém musí detekovat a obnovit funkčnost do 10 sekund.

**Navrhované řešení:**

- **Automatická detekce selhání:**  
  Integrace health-check mechanismů prostřednictvím pravidelných pingů pro sledování stavu komponenty **Smerovací engine**.  
  Tento proces bude zajišťovat nová komponenta **Health checker** v kontejneru **Spolehlivost směrovače**.

- **Mechanismus přepnutí při selhání (Failover):**  
  Nasadit redundantní instance **Směrovače stránek** a zajistit, aby přijímaly požadavky při selhání ostatních instancí.  
  Toto bude řešeno komponentou **Failover**.  
  Samozřejmě by bylo ideální použít moderní řešení jako Kubernetes, ale bylo požadováno přijít s něčím unikátním.

- **Testování a ověření odolnosti:**  
  Pravidelně testovat mechanismy přepnutí a proces obnovy za účelem ověření spolehlivosti v různých scénářích selhání.

**Změny architektury:**
Navržené změny v architekruře jsou v modelu zakresleny oranžově.

### Zotavení se z výpadku databáze [Benda]

**Scénář:**

- **Zdroj stimulu:** **Zápisy uživatele** nebo **Data Handling** se pokouší číst nebo zapisovat do **Databáze**
- **Stimulus:** Komponenta **Databáze** není částečně nebo zcela dostupná kvůli chybě připojení, nefungujícímu HW, neodpovídajícímu containeru, ...
- **Artefakt:** **Databáze**
- **Očekávané měření:** Systém musí bufferovat dotazy po dobu nedostupnosti přístupu k **Databázi**

**Navrhované řešení:**

- **DB proxy:**  
  Nová komponenta **DB proxy**, která přijímá asynchronní dotazy na zápis a čtení z **Databáze**.
  V případě její nedostupnosti, zaloguje fault, bufferuje dotazy a opakovaně je posílá, dokud nebudou vyřízeny

- **Warm spare:**  
  Pořídit si záložní container **Databáze** jako passive redundancy. **DB proxy** jednou za čas propíše provedené změny do záložní **Databáze**
  **DB proxy** posílá ping na hlavní **Databázi**. V případě výpadku začnw směrovat dotazy na záložní **Databázi**
  Po obnovení provozu obě **Databáze** uvede do konzistentního stavu

## Škálovatelnost

### Horizontální škálovatelnost směrovače stránek [Povolná]

**Scénář:**

- **Zdroj stimulu:** Uživatel systému přistupující na různé stránky v systému.
- **Stimulus:** Systém obdrží zvýšený počet požadavků na různé stránky.
- **Artefakt:** **Směrovač stránek**.
- **Očekávané měření:** Systém musí být schopen zvládnout nárůst požadavků o 100% během 5 minut bez snížení výkonu.

**Navrhované řešení:**

- **Dynamické škálování:**  
  Nasazení škálovacích mechanismů, které automaticky přidají nové instance směrovače při detekci vysoké zátěže.

- **Load Balancing:**  
  Použití vyvážení zátěže pro efektivní rozdělení požadavků mezi všechny instance.

- **Optimalizace zdrojů:**  
  Zavedení metrik pro sledování využití zdrojů a odstranění nečinných instancí po poklesu zátěže.

**Změny architektury:** Související problém je řešen již komponentou "Spolehlivost směrovače", kde jsou již spravovány instance směrovače. Mohla by případně být přidána komponenta Load balancer.

## Bezpečnost

### Detekce nedostatečných opravnění pro zobrazení lístků [Koucký]

- **Zdroj stimulu:** Neznámý útočník
- **Stimulus:** Požadavek přistoupit k soukromým lístkům jiného uživatele
- **Artefakt:** **Zobrazenie lístkov** v kontejneru **Zobrazení**
- **Očekávané měření:** Systém požadavek odmítne a zaloguje.

**Navrhovaná řešení:**

- **Kontrolovat auth**
  Kontrolovat, zda je daný požadavek od authentifikovaného a autorizovaného uživatele.
- **Testovaní**
  Otestovat, využít externího auditu ve snaze odhalit exploits, které by mohly být využity k neautorizovanému čtení uživatelových lístků.
- **Udržovat log**
  Udržovat záznam, ve kterém bude zdroj požadavku a jeho obsah uložen.

**Změny architektury:**
  Žádné, aktuální architektura nepopisuje žádné chování, které by bylo s tímto požadavkem v rozporu. Na požadavek bude nutno dbát při bližší specifikikaci.

## Studenti maji omezeny pocet pozadavku na zapis za jednotku casu [Jezowicz]

- **Zdroj stimulu:** Student
- **Stimulus:** Student pokousejici se o zapis
- **Artefakt:** Limit poctu zapsanych studentu je prekrocen
- **Očekávané měření:** System bude registrovat zadany pocet requestu pro kazdeho uzivatele. To zaruci vyhodnoceni vsech pozadavku v danem casovem limitu

**Navrhovaná řešení:**

- **Attack Recovery**
  Nasazeni separatniho serveru, ktery bude pozadavky filtrovat a prepisovat do vysledne fronty pozadavky dale procesovanych systemem.

**Změny architektury:**
  Pridani Enlistment serveru obsahujicim Queue Manager.

### Detekce nedostatečných opravnění pro odesílání emailů [Bošániová]

- **Zdroj stimulu:** Neznámý přihlášený útočník
- **Stimulus:** Požadavek přistoupit k spamování ostatních uživatelů
- **Artefakt:** **Zobrazenie emailového okna** v kontejneru  **Zobrazení**
- **Očekávané měření:** Systém verifikuje uživatele a zamezí mu velký množství dotazů

**Navrhovaná řešení:**

- **Kontrolovat auth**
  Kontrolovat, zda je daný požadavek od authentifikovaného a autorizovaného uživatele.
- **Testovaní**
  Otestovat, využít externího auditu ve snaze odhalit exploits, které by mohly být zneužity ke spamu nebo phishingu (telo správy je volitelné a odesílatel je důvěryhodný).
- **Udržovat log**
  Udržovat záznam, ve kterém bude zdroj požadavku a jeho obsah uložen.

**Změny architektury:**
  **Mail router** nemá popis o jeho bezpečnostích funkcích. Komponenta potřebuje logickú nadstavbu nad klasickým odesíláním emailu, která sníží riziko nebezpečí. (Velkost příloh, validace linků...)

### Detekce a řešení DDOS [Benda]

- **Zdroj stimulu:** Neznámý útočník / botnet
- **Stimulus:** High volume traffic z několika IP adres
- **Artefakt:** **Směrovací Engine** v kontejneru **Směrovač stránek**
- **Očekávané měření:** Útok bude evidován a provoz systému jím nebude ovlivněn

**Navrhovaná řešení:**

- **Detekce a blokování IP adres**
  Nová komponenta **DDOS detektor** analyzuje IP adresy a přidává je na blacklist
- **Geoblokace**
  Při detekci útoku zablokuji IP adresy pro danou geografickou oblast
- **Logova**
  Pro pozdější analýzu
- **Volavka**
  Nastartovat nový kontejner **Směrovače stránek** s mock API na ostatní komponenty.
  Dotazy označené jako DDOS přesměrovat na něj.

# Design-time požadavky

## Interopabilita

### Interopabilita email service a mail routeru [Koucký]

- **Zdroj stimulu:** Zobrazení
- **Stimulus:** Zobrazení vyžádá odeslání mailů.
- **Artefakt:** **Email service**
- **Očekávané měření:** 100% je zpracováno **Mail routerem** a vzniklé maily nejsou poškozené.

**Navrhovaná řešení:**

- **Testovaní**
  Otestovat, že **Email service** splňuje API **Mail router**, že **Mail router** nepřebírá malformed požadavky, že odeslané maily nejsou poškozené (správné kódování, speciální znaky).
- **Standardní formát**
  Použít standartní formát pro mail zprávy, s kterými **Mail router** bude schopný pracovat.

**Změny architektury:**
  Žádné, aktuální architektura nespecifikuje API, které by bylo s požadavkem v rozporu. Na požadavek bude potřeba dát pozor při podrobnějším rozepsání architektury.

## Testovatelnost

### Testovatelnost správnosti zápisu [Povolná]

- **Zdroj stimulu:** System tester
- **Stimulus:** Ověření správnosti zápisu předmětu v definovaných situacích.
- **Artefakt:** **Zápisy uživatele** a **Data Handling**
- **Očekávané měření:** Tester v testovacím prostředí provádí analýzu funkčnosti systému pro zápis předmětů pomocí připravených syntetických dat o uživatelích a jejich předmětech. Tester ověří 100 % předem připravených scénářů zahrnující požadavky na zápis podle předem definovaných pravidel, jako jsou kapacitní limity, časové kolize a oprávnění uživatele, a to pro všechny typy uživatelů, v průběhu 1 člověkoměsíce.

**Navrhovaná řešení:**

- **Testovací prostředí**
  Systém musí být možné provozovat i v testovacím režimu, který bude umožňovat použití specializovaných nástrojů. Musí být také dostupný logging.
- **Dokumentace architektury a řešení**
  Zajistit kompletní a čitelnou dokumentaci všech relevantních zdrojů.
- **Omezení komplexity systému**
  Kód musí být čitelný a modulární, s vysokou soudržností a nízkou provázaností.

**Změny architektury:**
  Architektuře chybí dokumentace, která by zlepšila její srozumitelnost a čitelnost. Architektura však obsahuje validátor, verifikátor a databázi historie změn, které umožňují efektivně sledovat a testovat chování systému. Systém limituje svou provázanost používáním APIs a není natolik komplexní, aby zabraňoval testerovi otestovat systém do 1 měsíce. Problémem by mohlo být těsné propojení mezi komponentami Zápis uživatele a Data handling, jejichž zodpovědnosti by bylo lepší jednoznačněji oddělit. Pomoci by mohlo i centrální logování.

## Korektnost

### Rozdelení rendrování UI a získávání dat [Bošániová]

- **Zdroj stimulu:** Zobrazení
- **Stimulus:** Zobrazení vyžádá zobrazení stránek
- **Artefakt:** **Data Handling**, **Zobrazení**, **Smerovač stránek**
- **Očekávané měření:** Druhá aplikace (server nebo klient aplikace) dostane šablonu a data oddelene a sama je vyrendruje (spojí).

**Navrhovaná řešení:**

- **Server-side rendering**
  Druhá instance, která lze paralelizovat, a která odlehčí zátěž vykreslování.

- **Single page application**
  Vytvořit Client-Side aplikaci a napojit na ní API. Client-Side aplikace spojuje šablonu s daty z API. Při změne stránky se pouze načtou nová data (statická data z cache).
  Server přijíma API dotazy a příkazy.

**Změna architektury:**
  Momentální řešení posílá napříč aplikací už vytvorený html kód. To může spůsobit spomalení systému velikostí posílaných dat. V první řade je potřeba změnu designu tak, aby aplikace posílala jenom raw data a až v posledním kroku je spracovala do html, spolu se šablonou. Vyhneme sa "zafixovanému" kódu,který by sme v případe úprav museli parsovat.
  
  Co se týče komplexnějších navrhovaných řešení:

- Single page application - ideální řešení (žádá si kompletní změnu designu)
- Server-side rendering - lepší návrh, ale ne dokonalý
