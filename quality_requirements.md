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

### Detekce nedostatečných opravnění pro odesílání emailů [Bošániová]

- **Zdroj stimulu:** Neznámý přihlášený útočník
- **Stimulus:** Požadavek přistoupit k spamování ostatních uživatelů
- **Artefakt:** **Zobrazenie emailového okna** v kontejneru  **Zobrazení**
- **Očekávané měření:** Systém verifikuje uživatele a zamezí mu velký množství dotazů

**Navrhovaná řešení:**

- **Kontrolovat auth**
  Kontrolovat, zda je daný požadavek od authentifikovaného a autorizovaného uživatele.
- **Testovaní**
  Otestovat, využít externího auditu ve snaze odhalit exploits, které by mohly být využity k neautorizovanému čtení uživatelových lístků.
- **Udržovat log**
  Udržovat záznam, ve kterém bude zdroj požadavku a jeho obsah uložen.

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

## Testovatelnost

TODO

# Nezařazené

## Korektnost

### Odosielanie naformátovaného html namiesto raw dát [Bošániová] (TODO: odebrat?)

- **Zdroj stimulu:** Zobrazení
- **Stimulus:** Zobrazení vyžádá zobrazení stránek
- **Artefakt:** **Zobrazení**, **Smerovač stránek**
- **Očekávané měření:** Pokial sa s datami pracuje tak sa z nich nerobí html. Šablona sa používa nesrpávnym spôsobom.

**Navrhovaná řešení:**

- príklad MVC
