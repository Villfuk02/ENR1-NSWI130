# Požadavky na Kvalitu

## Výkon (Performance)

### Efektivní zápis pod vysokým zatížením

**Scénář:**

- **Aktér:** Student pokoušející se zapsat do kurzu.
- **Událost:** Student odešle žádost o zápis prostřednictvím komponenty **Zapsat studenta na lístek**, zatímco tisíce dalších uživatelů podávají podobné žádosti současně.
- **Zasažená komponenta:** **Zapsat studenta na lístek** v kontejneru **Zápisy uživatele**.
- **Očekávané měření:** 99 % transakcí zápisů by mělo být úspěšně dokončeno do 2 sekund, i při 5 000 požadavcích za minutu. **Každý** požadavek musí doručit uživateli zpětnou vazbu zda byla transakce úspěšná, a to do 2 sekund.

**Navrhované řešení:**

- **Optimalizace databázových transakcí:**  
  Použití optimalizovaných neblokujících dotazů ke snížení zátěže na databáze.

- **Kešování:**  
  Kešování často přistupovaných dat ke snížení zátěže databází.

- **Horizontální škálování:**  
  Nasadit více instancí kontejneru **Zápisy uživatele** pro efektivní rozložení zátěže.  
  Použití load balanceru pro rovnoměrné rozdělení požadavků mezi instance.

## Spolehlivost (Reliability)

### Obnova po selhání Smerovacího engine

**Scénář:**

- **Aktér:** Student pokoušející se přejít na stránku zápisů.
- **Událost:** Komponenta **Smerovací engine** selže během zpracování požadavku kvůli neočekávané chybě nebo přetížení.
- **Zasažená komponenta:** **Smerovací engine** v kontejneru **Směrovač stránek**.
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

### Zotavení se z výpadku databáze

**Scénář:**

- **Aktér:** **Zápisy uživatele** nebo **Data Handling** se pokouší číst nebo zapisovat do **Databáze**
- **Událost:** Komponenta **Databáze** není částečně nebo zcela dostupná kvůli chybě připojení, nefungujícímu HW, neodpovídajícímu containeru, ...
- **Zasažená komponenta:** **Databáze**
- **Očekávané měření:** Systém musí bufferovat dotazy po dobu nedostupnosti přístupu k **Databázi**

**Navrhované řešení:**

- **DB proxy:**  
  Nová komponenta **DB proxy**, která přijímá asynchronní dotazy na zápis a čtení z **Databáze**.
  V případě její nedostupnosti, zaloguje fault, bufferuje dotazy a opakovaně je posílá, dokud nebudou vyřízeny

- **Warm spare:**  
  Pořídit si záložní container **Databáze** jako passive redundancy. **DB proxy** jednou za čas propíše provedené změny do záložní **Databáze**
  **DB proxy** posílá ping na hlavní **Databázi**. V případě výpadku začnw směrovat dotazy na záložní **Databázi**
  Po obnovení provozu obě **Databáze** uvede do konzistentního stavu

## Bezpečnost

### Detekce nedostatečných opravnění pro zobrazení lístků

- **Aktér:** Neznámý útočník
- **Událost:** Požadavek přistoupit k soukromým lístkům jiného uživatele
- **Zasažená komponenta:** **Zobrazenie lístkov** v kontejneru **Zobrazení**
- **Očekávané měření:** Systém požadavek odmítne a zaloguje.

**Navrhovaná řešení:**

- **Kontrolovat auth**
  Kontrolovat, zda je daný požadavek od authentifikovaného a autorizovaného uživatele.
- **Testovaní**
  Otestovat, využít externího auditu ve snaze odhalit exploits, které by mohly být využity k neautorizovanému čtení uživatelových lístků.
- **Udržovat log**
  Udržovat záznam, ve kterém bude zdroj požadavku a jeho obsah uložen.

## Interopabilita

### Interopabilita email service a mail routeru

- **Aktér:** Zobrazení
- **Událost:** Zobrazení vyžádá odeslání mailů.
- **Zasažené kontejnery:** **Email service**
- **Očekávané měření:** 100% je zpracováno **Mail routerem** a vzniklé maily nejsou poškozené.

**Navrhovaná řešení:**

- **Testovaní**
  Otestovat, že **Email service** splňuje API **Mail router**, že **Mail router** nepřebírá malformed požadavky, že odeslané maily nejsou poškozené (správné kódování, speciální znaky).
- **Standardní formát**
  Použít standartní formát pro mail zprávy, s kterými **Mail router** bude schopný pracovat.
