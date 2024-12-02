workspace "Zápisy Workspace" "Tento Workspace dokumentuje architekturu softwarového systému Zápisy" {

    !identifiers hierarchical

    model {
        # Softwarové systémy
        enrollments = softwareSystem "Zápisy" {

            browser = container "Prohlížeč" {
                dom_reader = component "DOM Reader"
            }

            router = container "Směrovač stránek" "Sestavuje požadovanou stránku"{
                routing_engine = component "Smerovací Engine" "Sestavuje požadovanou stránku"
                ui_templator = component "UI Templator" "Poskytuje template pro stránku v prohlížeči"
            }

            displayer = container "Zobrazení" "Vytváří jednotlivá zobrazení s daty"{
                schedule_displayer = component "Zobrazovanie rozvrhu"
                event_displayer = component "Zobrazenie lístkov"
                event_details = component "Detail o lístku"
                email_window_displayer = component "Zobrazenie emailového okna"
                manager_displayer = component "Zobrazenie pre manažéra"
            }

            email_service = container "Email service" "Vytváření a zasílání emailů"{
                email_generator = component "Tvorba emailov"
                email_sender = component "Odosielanie emailov"
            }

            data_handling = container "Data Handling" "Zaznamenává změny, komunikuje s Rozvrhy a vytváří jejich zobrazení" {
                data_preparation = component "Príprava dát"
                data_verificator = component "Data verificator" "Overenie správnosti dát"
                loader = component "Loader" "načíta dáta predmetov pomocou Schedule API"
                schedule_api = component "Schedule API" "Zapisování a načítání lístků ze Schedules"
                modification_handler = component "Modification Handler"
                validator = component "Validátor" "Vyhodnotí správnosť zmien"
                data_preparation_changes = component "Príprava dát [zmeny]" "Upraví dáta do formátu, ktorý sa dá poslať do Schedule API"
                changes_api = component "Changes API" "Zapisování a načítání historie změn"
                rules = component "Rules" "pravidlá, ktoré určujú, či sú zmeny platné"
            
                listky_api = component "Lístky API" "API na komunikáciu s databázou so zapismi študentov"
            }

            user_enrollment = container "Zápisy uživatele" "Zajišťuje zápis uživatele na daný lístek"{
                user_data_loader = component "Načítání dat uživatelů" "Komunikuje s databází a získává data"
                event_enroller = component "Zapsat studenta na lístek" "Zapíše přihlášeného studenta na lístek"
            }
            
            modification_history = container "Databáze historie změn"
            database = container "Databáze" "Databáze zapsaných lístků uživatelů"
            api = container "API"
        }

        mail_router = softwareSystem "Mail router" {

        }

        schedules = softwareSystem "Rozvrhy"{
            courses_and_events = container "Předměty a lístky" "Database"
        }


        #Vzťahy medzi containerom Database a API
        enrollments.database -> enrollments.api "Zpřístupňuje data o zápisech"

        #Vzťahy medzi databázou zápisov a containerom  Zápisy uživatele
        enrollments.database -> enrollments.user_enrollment.user_data_loader "Čtení dat"
        enrollments.user_enrollment.event_enroller -> enrollments.database "Zapsání nového zápisu"
        

        #Vzťahy medzi emailovými službami
        enrollments.email_service.email_sender -> mail_router "Komunikuje"
        enrollments.email_service.email_generator -> enrollments.email_service.email_sender "Předá email"
        enrollments.displayer.email_window_displayer -> enrollments.email_service.email_generator "Sprístupňuje"


        #Vzťahy medzi containerom Data handling a softwareovým systémom Rozvrhy
        enrollments.data_handling.schedule_api -> schedules.courses_and_events "Komunikácia s Databázou"
        
        #Vzťahy medzi containerom Data Handling a containerom Historie změn
        enrollments.data_handling.changes_api -> enrollments.modification_history "Pridanie záznamu do databázy zmien"

        #Ostatné softwareové systémy
        exams = softwareSystem "Zkoušky"
        login_system = softwareSystem "Přihlašovací systém"
        
        # Uživatelé
        manager = person "Manažer"
        student = person "Student"
        teacher = person "Učitel"
        
        # Vztahy mezi uživateli a Zápisy (Enrollments)
        manager -> enrollments "Používá"
        student -> enrollments "Používá"
        teacher -> enrollments "Používá"
        
        # Vztahy mezi softwerovými systémy
        login_system -> enrollments "Posílá data o uživatelech"
        schedules -> enrollments "Posílá data o rozvrzích pomocí API"
        enrollments -> exams "Posílá data o zápisech pomocí API"
        enrollments.user_enrollment.user_data_loader -> login_system "Posílání požadavků na uživatelská data"
        login_system -> enrollments.user_enrollment.user_data_loader "Posílání dat uživatele"
        
        #Vzťahy medzi užívateľami a zobrazením
        student -> enrollments.browser "Ovládanie cez"
        teacher -> enrollments.browser "Ovládanie cez"
        manager -> enrollments.browser "Ovládanie cez"

        
        #Vztahy medzi komponentami displayer containeru
        enrollments.displayer.event_displayer -> enrollments.displayer.event_details "Odkazuje na"
        enrollments.displayer.event_details -> enrollments.displayer.email_window_displayer "Odkazuje na"

        #Vzťahy medzi komponentami containeru router
        enrollments.router.ui_templator -> enrollments.router.routing_engine "Poskytnutí template"

        #Vzťahy medzi containerom router a ostatnými systémami
        enrollments.displayer.event_displayer -> enrollments.router.routing_engine "Předání zobrazení lístků"
        enrollments.displayer.schedule_displayer -> enrollments.router.routing_engine "Předání zobrazení rozvrhu"
        enrollments.displayer.manager_displayer -> enrollments.router.routing_engine "Předání zobrazení pro manažera"
        enrollments.router.routing_engine -> enrollments.displayer.event_displayer "Požadavek na zobrazení lístků"
        enrollments.router.routing_engine -> enrollments.displayer.schedule_displayer "Požadavek na zobrazení rozvrhu"
        enrollments.router.routing_engine -> enrollments.displayer.manager_displayer "Požadavek na zobrazení pro manažera"
        enrollments.router.routing_engine -> enrollments.user_enrollment.event_enroller "Žádá o zapsání lístku"
        enrollments.router.routing_engine -> enrollments.browser.dom_reader "Předání stránky"
        
        #Vzťahy medzi containerom browser a ostatnými containermi
        enrollments.browser.dom_reader -> enrollments.router.routing_engine "Požadavek na změnu stránky"

        #Vzťahy medzi containerami Data Handling a Zobrazenie
        enrollments.data_handling.data_preparation -> enrollments.displayer.event_displayer "Odosielanie dát v HTML pre zobrazenie"
        enrollments.data_handling.data_preparation -> enrollments.displayer.manager_displayer "Odosielanie dát na zobrazenie pre manažéra"
        enrollments.data_handling.data_preparation -> enrollments.displayer.event_details "Odesílání dat o lístku v HTML"

        #Vzťahy vo vnútri containeru Data Handling
        enrollments.data_handling.modification_handler -> enrollments.data_handling.validator "Pošle zmeny validátoru"
        enrollments.data_handling.validator ->  enrollments.data_handling.data_preparation_changes "Pošle zmeny k príprave na odoslanie"
        enrollments.data_handling.validator -> enrollments.data_handling.rules "Získa pravidlá, podľa ktorých vyhodnotí platnosť zmien"
        enrollments.data_handling.data_preparation_changes -> enrollments.data_handling.schedule_api "Požiadavka na modifikáciu dát"
        enrollments.data_handling.data_preparation_changes -> enrollments.data_handling.changes_api "Požiadavka na pridanie záznamu"
        enrollments.data_handling.data_verificator -> enrollments.data_handling.data_preparation "Pošle dáta k príprave na zobrazenie"
        enrollments.data_handling.data_verificator -> enrollments.data_handling.rules "Získa pravidlá, podľa ktorých zistí, či sú načítané dáta správne"
        enrollments.data_handling.loader ->  enrollments.data_handling.data_verificator "Pošle dáta na overenie správnosti"
        enrollments.data_handling.loader -> enrollments.data_handling.schedule_api "Požiadavka na nčítanie dát"
        enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Posílá požadavky na data"
        enrollments.data_handling.loader -> enrollments.data_handling.changes_api "Posílá požadavky na načítání dat"
        enrollments.data_handling.loader -> enrollments.data_handling.listky_api "Posíla požadavky na data"
        enrollments.data_handling.listky_api -> enrollments.database "Posílá požadavky na data"


        #Vzťahy medzi komponentami containeru Zápisy užívateľa
        enrollments.user_enrollment.user_data_loader -> enrollments.user_enrollment.event_enroller "Získání dat o přihlášeném uživateli"
        enrollments.user_enrollment.event_enroller -> enrollments.user_enrollment.user_data_loader "Doptá se na data o uživateli"


        #Vzťahy medzi containerom Zápisy užívatele a containerom Zobrazenie
        enrollments.user_enrollment.user_data_loader -> enrollments.displayer.schedule_displayer "Předání dat o zapsaných lístcích"
        
        #Vzťahy medzi containerom Zápisy užívatele a containerom Data Handling
        enrollments.user_enrollment.event_enroller -> enrollments.data_handling.modification_handler "Zapísanie zmien (prihlásenie študenta na lístok)"


        enrollments.user_enrollment.event_enroller -> enrollments.router.routing_engine "Pošle informaci o výsledku zápisu"
        

    }

    views {
        theme default
        
        systemContext enrollments {
            include *
            autoLayout
        }

        container enrollments "ContainerView" {
            include *
        }

        component enrollments.displayer "NavigationComponentView" {
            include *
        }

        component enrollments.data_handling "DataHandlingComponentView" {
            include *
        }

        component enrollments.email_service "EmailServiceComponentView" {
            include *
            autoLayout
        }

        component enrollments.user_enrollment "UserEnrollmentComponentView" {
            include *
        }

        component enrollments.modification_history "ModificationHistoryComponentView" {
            include *
            autoLayout
        }

        component enrollments.database "DatabaseComponentView" {
            include *
            autoLayout
        }

        component enrollments.api "APIComponentView" {
            include * 
            autoLayout
        }

        component enrollments.router "routerComponentView" {
            include *
        }

        component enrollments.browser "BrowserComponentView" {
            include *
            autoLayout
        }

        dynamic enrollments.user_enrollment {
            title "Zápis předmětu studentem"
            student -> enrollments.browser "Chce se zapsat na lístek"
            # prohlížeč -> směrovač
            enrollments.browser -> enrollments.router.routing_engine "Požádá o zápis předmětu"
            # směrovač -> zapsat studenta na lístek 
            enrollments.router.routing_engine -> enrollments.user_enrollment.event_enroller "Požádá o zápis předmětu"
            
            enrollments.user_enrollment.event_enroller -> enrollments.user_enrollment.user_data_loader "Požádá o ID studenta"
            # načítání dat uživatelů -> přihlašovací systém
            enrollments.user_enrollment.user_data_loader -> login_system "Požádá o ID studenta"
            # přihlašovací systém -> načítání dat uživatelů     
            login_system -> enrollments.user_enrollment.user_data_loader "Pošle ID studenta"
            # načítání dat uživatelů -> zapsat studenta na lístek
            enrollments.user_enrollment.user_data_loader -> enrollments.user_enrollment.event_enroller "Předá ID studenta"
            # zapsat studenta na lístek -> databáze
            enrollments.user_enrollment.event_enroller -> enrollments.database "Zapsání nového zápisu studenta na lístek"
            # zapsat studenta na lístek -> data handling
            enrollments.user_enrollment.event_enroller -> enrollments.data_handling.modification_handler "Pošle informace o zápisu lístku pro zápisu do historie změn"
            enrollments.data_handling.modification_handler -> enrollments.data_handling.validator 
            enrollments.data_handling.validator -> enrollments.data_handling.rules
            enrollments.data_handling.validator -> enrollments.data_handling.data_preparation_changes
            enrollments.data_handling.data_preparation_changes -> enrollments.data_handling.changes_api
            enrollments.data_handling.changes_api -> enrollments.modification_history "Zapíše informaci o zápisu lístku do databáze změn"

            # zapsat studenta na lístek -> směrovač
            enrollments.user_enrollment.event_enroller -> enrollments.router.routing_engine "Pošle informaci o výsledku zápisu"
            # směrovač zobrazí studentovi
            enrollments.router.routing_engine -> enrollments.browser "Předá informaci o výsledku zápisu"


            autoLayout
        }

        dynamic enrollments.data_handling {
            title "Zobrazení historie pro manažera"
            manager -> enrollments.browser "Chce si zobraziť históriu zmien"

            enrollments.browser -> enrollments.router.routing_engine
            enrollments.router.routing_engine -> enrollments.displayer.manager_displayer "Požádá o zobrazení pro manažera"

            enrollments.displayer.manager_displayer -> enrollments.data_handling.data_preparation "Vyžiada dáta"
            enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Pošle požiadavok na načítanie dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle požiadavok na overenie"
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti požiadavku"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Informuje o správnosti"
            enrollments.data_handling.loader -> enrollments.data_handling.changes_api "Pošle request na načítanie"
            enrollments.data_handling.changes_api -> enrollments.modification_history "Request zmení na SQL a pošle ho"
            enrollments.modification_history -> enrollments.data_handling.changes_api "Vráti získané dáta"
            enrollments.data_handling.changes_api -> enrollments.data_handling.loader "Vráti získané dáta"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle získané dáta na overenie"
            
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti dát"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Pošle informáciu o správnosti dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_preparation "Pošle na prípravu pred zobrazením"
        
            enrollments.data_handling.data_preparation -> enrollments.displayer.manager_displayer "Poskytne dáta"
            enrollments.displayer.manager_displayer -> enrollments.router.routing_engine "Předá zobrazení"
            enrollments.router.ui_templator -> enrollments.router.routing_engine "Předá template pro vytvoření stránky"
            enrollments.router.routing_engine -> enrollments.browser "Předá stránku"

            autoLayout
        }

        dynamic enrollments.displayer {
            title "Zobrazenie zapísaných študentov pre učiteľa"
            teacher -> enrollments.browser "Chce si zobraziť detail o lístku so zapísanými študentmi"
            enrollments.browser -> enrollments.router.routing_engine "Požiada o presmerovanie na zobrazenie"
            enrollments.router.routing_engine -> enrollments.displayer.event_displayer "Predá požiadavok na zobrazenie lístkov"
            enrollments.displayer.event_displayer -> enrollments.displayer.event_details "Požiada o zobrazenie detailu lístku"
            enrollments.displayer.event_details -> enrollments.data_handling.data_preparation "Vyžiada dáta o detaile lístku"
            
            enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Pošle požiadavok na načítanie dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle požiadavok na overenie"
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti požiadavku"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Informuje o správnosti"
            enrollments.data_handling.loader -> enrollments.data_handling.listky_api "Pošle request na načítanie"
            enrollments.data_handling.listky_api -> enrollments.database "Request zmení na SQL a pošle ho"
            enrollments.database -> enrollments.data_handling.listky_api "Vráti získané dáta"
            enrollments.data_handling.listky_api -> enrollments.data_handling.loader "Vráti získané dáta"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle získané dáta na overenie"
            
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti dát"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Pošle informáciu o správnosti dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_preparation "Pošle na prípravu pred zobrazením"
        
            enrollments.data_handling.data_preparation -> enrollments.displayer.event_details "Odošle dáta o lístku"
            enrollments.displayer.event_details -> enrollments.displayer.event_displayer "Vráti na"
            enrollments.displayer.event_displayer -> enrollments.router.routing_engine "Vráti zobrazenie lístkov"
            enrollments.router.ui_templator -> enrollments.router.routing_engine "Predá template na vytvorenie stránky"
            enrollments.router.routing_engine -> enrollments.browser "Predá stránku"
            
            autoLayout
        }

        dynamic enrollments.displayer {
            title "Zobrazenie zapísaných predmetov pre študenta"
            student -> enrollments.browser "Chce si zobraziť zapísané predmety"
            enrollments.browser -> enrollments.router.routing_engine "Požiada o presmerovanie na zobrazenie predmetov"
            enrollments.router.routing_engine -> enrollments.displayer.event_displayer "Požiada o zobrazenie lístkov"
            enrollments.displayer.event_displayer -> enrollments.displayer.event_details "Vyžiada detaily lístkov"
            enrollments.displayer.event_details -> enrollments.data_handling.data_preparation "Vyžiada dáta o lístkoch"
            
            enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Pošle požiadavku na načítanie dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle požiadavku na overenie"
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti požiadavku"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Informuje o správnosti"
            enrollments.data_handling.loader -> enrollments.data_handling.listky_api "Pošle request na načítanie"
            enrollments.data_handling.listky_api -> enrollments.database "Request zmení na SQL a pošle ho"
            enrollments.database -> enrollments.data_handling.listky_api "Vráti získané dáta"
            enrollments.data_handling.listky_api -> enrollments.data_handling.loader "Vráti získané dáta"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle získané dáta na overenie"
            
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti dát"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Pošle informáciu o správnosti dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_preparation "Pošle na prípravu pred zobrazením"

            enrollments.data_handling.data_preparation -> enrollments.displayer.event_details "Odošle dáta o lístkoch"
            enrollments.displayer.event_details -> enrollments.displayer.event_displayer "Vráti na"
            enrollments.displayer.event_displayer -> enrollments.router.routing_engine "Vráti zobrazenie predmetov"
            enrollments.router.ui_templator -> enrollments.router.routing_engine "Predá template na vytvorenie stránky"
            enrollments.router.routing_engine -> enrollments.browser "Predá stránku"
            
            autoLayout
        }

        dynamic enrollments.email_service {
            title "Komunikace učitele se studenty"
            teacher -> enrollments.browser "Chce odeslat email studentům"
            # prohlížeč -> směrovač
            enrollments.browser -> enrollments.router.routing_engine "Požádá o presměrování na zobrazení"
            # směrovač -> zobrazení lístku
            enrollments.router.routing_engine -> enrollments.displayer.event_displayer "Požádá o zobrazení svých lístků"
            # zobrazení lístku -> zobrazení detailu o lístku
            enrollments.displayer.event_displayer -> enrollments.displayer.event_details "Požádá o zobrazení detailu o lístku"
    
            enrollments.displayer.event_details -> enrollments.data_handling.data_preparation "Vyžiada dáta o lístkoch"
            
            enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Pošle požiadavku na načítanie dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle požiadavku na overenie"
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti požiadavku"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Informuje o správnosti"
            enrollments.data_handling.loader -> enrollments.data_handling.listky_api "Pošle request na načítanie"
            enrollments.data_handling.listky_api -> enrollments.database "Request zmení na SQL a pošle ho"
            enrollments.database -> enrollments.data_handling.listky_api "Vráti získané dáta"
            enrollments.data_handling.listky_api -> enrollments.data_handling.loader "Vráti získané dáta"
            enrollments.data_handling.loader -> enrollments.data_handling.data_verificator "Pošle získané dáta na overenie"
            
            enrollments.data_handling.rules -> enrollments.data_handling.data_verificator "Získa pravidlá na overenie správnosti dát"
            enrollments.data_handling.data_verificator -> enrollments.data_handling.loader "Pošle informáciu o správnosti dát
            enrollments.data_handling.loader -> enrollments.data_handling.data_preparation "Pošle na prípravu pred zobrazením"

            enrollments.data_handling.data_preparation -> enrollments.displayer.event_details "Odošle dáta o lístkoch"
    
            # zobrazení detailu o lístku -> zobrazení okna pro tvorbu emailu
            enrollments.displayer.event_details -> enrollments.displayer.email_window_displayer "Požádá o zobrazení okna pro vyplnění emailu"
            # okno pro tvorbu emailu -> email generator
            enrollments.displayer.email_window_displayer -> enrollments.email_service.email_generator "Požádá o vygenerování emailu"
            # email generator -> email sender
            enrollments.email_service.email_generator -> enrollments.email_service.email_sender "Požádá o odeslání emailu"
            # email sender -> mail router
            enrollments.email_service.email_sender -> mail_router "Odešle email"                                                                                                                       
                                                                                                                           
            autoLayout
        }

    }
}
