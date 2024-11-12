workspace "Zápisy Workspace" "Tento Workspace dokumentuje architekturu softwarového systému Zápisy" {

    !identifiers hierarchical

    model {
        # Softwarové systémy
        enrollments = softwareSystem "Zápisy" {

            displayer = container "Zobrazení" {
                ui = component "UI" "Určuje rozhranie, pomocou ktoráho užívateľ interaguje so systémom"
                notification_reporter = component "Správca upozornení" "Upozorní užívateľa o nových dôležitých aktuálnostiach"
                routing_engine = component "Smerovací Engine" "Kontroluje presmerovania na jednotlivé časti systému"
                third_party_integrations = component "Integrácie so systémami tretích strán" "Spája systém s inými systémami a zaisťuje prúdenie dát"
                schedule_renderer = component "Vykresľovanie rozvrhu"
                event_displayer = component "Zobrazenie lístkov"
                event_details = component "Detail o lístku"
                email_window_displayer = component "Zobrazenie emailového okna"
                manager_displayer = component "Zobrazenie pre manažéra"
            }
            email_service = container "Email service" {
                email_generator = component "Tvorba emailov"
                email_sender = component "Odosielanie emailov"
            }
            data_handling = container "Data Handling"{
                data_preparation = component "Príprava dát"
                data_validation = component "Overenie správnosti dát"
                loader = component "Loader"
                schedule_api = component "Schedule API"
                modification_handler = component "Modification Handler"
                validator = component "Validátor"
                data_preparation_changes = component "Príprava dát [zmeny]"
                changes_api = component "Changes API"
                rules = component "Rules"
            }
            user_enrollment = container "Zápisy uživatele" {
                displaying_user_data_preparator = component "Príprava užívateľských dát ka zobrazení" "Shromáždí data o uživateli a jeho zapsaných lístkách a vytvoří html"
                user_data_loader = component "Načítání dat uživatelů" "Komunikuje s databází a získává data"
                event_enroller = component "Zapsat studenta na lístek" "Zapíše přihlášeného studenta na lístek"
            }
            modification_history = container "Historie změn" "Database"
            database = container "Database"
            api = container "API"
        }

        mail_server = softwareSystem "Mail server" {

        }

        schedules = softwareSystem "Rozvrhy"{
            courses_and_events = container "Předměty a lístky" "Database"
        }

        users = softwareSystem "Uživatelé" {
            user_database = container "Database"
        }

        #Vzťahy medzi containerom Database a API
        enrollments.database -> enrollments.api "Zpřístupňuje data o zápisech"

        #Vzťahy medzi databázou zápisov a containerom  Zápisy uživatele
        enrollments.database -> enrollments.user_enrollment.user_data_loader "Čtení dat"
        enrollments.user_enrollment.event_enroller -> enrollments.database "Zapsání nového zápisu"

        #Vzťahy medzi softwareovým systémom Uživatelé a containerom Zápisy uživatele 
        users.user_database -> enrollments.user_enrollment.user_data_loader "Zpřístupní ID uživatele"

        #Vzťahy medzi emailovými službami
        enrollments.email_service.email_sender -> mail_server "Komunikuje"
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
        study_dep = person "Studijní oddělení"
        
        # Vztahy mezi uživateli a Zápisy (Enrollments)
        manager -> enrollments "Používá"
        student -> enrollments "Používá"
        teacher -> enrollments "Používá"
        study_dep -> enrollments "Používá"
        
        # Vztahy mezi softwerovými systémy
        login_system -> enrollments "Posílá data o uživatelech"
        schedules -> enrollments "Posílá data o rozvrzích pomocí API"
        enrollments -> exams "Posílá data o zápisech pomocí API"
        
        #Vzťahy medzi užívateľami a zobrazením
        student -> enrollments.displayer.ui "Ovládanie cez"
        teacher -> enrollments.displayer.ui "Ovládanie cez"
        study_dep -> enrollments.displayer.ui "Ovládanie cez"
        manager -> enrollments.displayer.ui "Ovládanie cez"
        
        #Vztahy medzi komponentami displayer containeru
        enrollments.displayer.notification_reporter ->  enrollments.displayer.ui "Posielanie notifikácii"
        enrollments.displayer.routing_engine ->  enrollments.displayer.ui "Posielanie notifikácii"
        enrollments.displayer.routing_engine -> enrollments.displayer.schedule_renderer "Odkazuje na"
        enrollments.displayer.routing_engine -> enrollments.displayer.event_displayer "Odkazuje na"
        enrollments.displayer.routing_engine -> enrollments.displayer.manager_displayer "Odkazuje na"
        enrollments.displayer.event_displayer -> enrollments.displayer.event_details "Odkazuje na"
        enrollments.displayer.event_details -> enrollments.displayer.email_window_displayer "Odkazuje na"

        #Vzťahy medzi containerami Data Handling a Zobrazenie
        enrollments.data_handling.data_preparation -> enrollments.displayer.event_displayer "Odosielanie dát v HTML pre zobrazenie"
        enrollments.displayer.manager_displayer -> enrollments.data_handling.data_preparation "Odosielanie dát na zobrazenie pre manažéra"

        #Vzťahy vo vnútri containeru Data Handling
        enrollments.data_handling.modification_handler -> enrollments.data_handling.validator "Pošle zmeny validátoru"
        enrollments.data_handling.validator ->  enrollments.data_handling.data_preparation_changes "Pošle zmeny k príprave na odoslanie"
        enrollments.data_handling.validator -> enrollments.data_handling.rules "Získa pravidlá, podľa ktorých vyhodnotí platnosť zmien"
        enrollments.data_handling.data_preparation_changes -> enrollments.data_handling.schedule_api "Požiadavka na modifikáciu dát"
        enrollments.data_handling.data_preparation_changes -> enrollments.data_handling.changes_api "Požiadavka na pridanie záznamu"
        enrollments.data_handling.data_validation -> enrollments.data_handling.data_preparation "Pošle dáta k príprave na zobrazenie"
        enrollments.data_handling.data_validation -> enrollments.data_handling.rules "Získa pravidlá, podľa ktorých zistí, či sú načítané dáta správne"
        enrollments.data_handling.loader ->  enrollments.data_handling.data_validation "Pošle dáta na overenie správnosti"
        enrollments.data_handling.loader -> enrollments.data_handling.schedule_api "Požiadavka na nčítanie dát"
        enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Posílá požadavky na data"
        enrollments.data_handling.loader -> enrollments.data_handling.changes_api "Posílá požadavky na načítání dat"

        #Vzťahy medzi komponentami containeru Zápisy užívateľa
        enrollments.user_enrollment.user_data_loader -> enrollments.user_enrollment.displaying_user_data_preparator "Načítání dat"
        enrollments.user_enrollment.user_data_loader -> enrollments.user_enrollment.event_enroller "Získání dat o přihlášeném uživateli"

        #Vzťahy medzi containerom Zápisy užívatele a containerom Zobrazenie
        enrollments.user_enrollment.displaying_user_data_preparator -> enrollments.displayer.schedule_renderer "Odeslání dat HTML pro zobrazení"
        enrollments.displayer.event_displayer -> enrollments.user_enrollment.event_enroller "Vybraný lístek se zapíše"
        enrollments.user_enrollment.event_enroller -> enrollments.displayer.notification_reporter "Informace o výsledku zápisu"

        
        #Vzťahy medzi containerom Zápisy užívatele a containerom Data Handling
        enrollments.user_enrollment.event_enroller -> enrollments.data_handling.modification_handler "Zapísanie zmien (prihlásenie študenta na lístok)"
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
            autoLayout
        }

        component enrollments.modification_history "ModificationHistoryComponentView" {
            include *
            autoLayout
        }

        component enrollments.database "DatabaseComponentView" {
            include *
            autoLayout
        }

        component enrollments.api "APICOmponentView" {
            include * 
            autoLayout
        }

        dynamic enrollments.user_enrollment {
            title "Zápis předmětu studentem"
            student -> enrollments.displayer.ui "Chce se zapsat na lístek"
            enrollments.displayer.routing_engine -> enrollments.displayer.ui "Poskytne stránku"
            enrollments.displayer.routing_engine -> enrollments.displayer.event_displayer "Nasměruje na"
            enrollments.displayer.event_displayer -> enrollments.user_enrollment.event_enroller "Požádá o zápis vybraného lístku"
            enrollments.user_enrollment.event_enroller -> enrollments.user_enrollment.user_data_loader "Požádá o ID studenta"
            enrollments.user_enrollment.user_data_loader -> users "Požádá o ID studenta"
            users -> enrollments.user_enrollment.user_data_loader "Předá ID studenta"
            enrollments.user_enrollment.user_data_loader -> enrollments.user_enrollment.event_enroller "Předá ID studenta"
            enrollments.user_enrollment.event_enroller -> enrollments.database "Zapíše lístek studentovi do databáze"
            enrollments.user_enrollment.event_enroller -> enrollments.data_handling.modification_handler "Zapíše změnu o přihlášení na lístek"
            enrollments.user_enrollment.event_enroller -> enrollments.displayer.notification_reporter "Předá informaci o výsledku zapsání lístku"
            enrollments.displayer.notification_reporter -> enrollments.displayer.ui "Zobrazí výsledek zápisu lístku"
            autoLayout
        }

        dynamic enrollments.data_handling {
            title "Zobrazení historie pro manažera"
            manager -> enrollments.displayer.ui "Chce si zobraziť históriu zmien"
            enrollments.displayer.routing_engine -> enrollments.displayer.ui "Poskytne HTML stránku"
            enrollments.displayer.routing_engine -> enrollments.displayer.manager_displayer "Nasmeruje na zobrazenie"
            enrollments.displayer.manager_displayer -> enrollments.data_handling.data_preparation "Vyžiada dáta"
    
            enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "Pošle požiadavok na načítanie dát"
            enrollments.data_handling.loader -> enrollments.data_handling.data_validation "Pošle požiadavok na overenie"
            enrollments.data_handling.rules -> enrollments.data_handling.data_validation "Získa pravidlá na overenie správnosti požiadavku"
            enrollments.data_handling.data_validation -> enrollments.data_handling.loader "Informuje o správnosti"
            enrollments.data_handling.loader -> enrollments.data_handling.changes_api "Pošle request na načítanie"
            enrollments.data_handling.changes_api -> enrollments.modification_history "Request zmení na SQL a pošle ho"
            enrollments.modification_history -> enrollments.data_handling.changes_api "Vráti získané dáta"
            enrollments.data_handling.changes_api -> enrollments.data_handling.loader "Vráti získané dáta"
            enrollments.data_handling.loader -> enrollments.data_handling.data_validation "Pošle získané dáta na overenie"
            
            enrollments.data_handling.rules -> enrollments.data_handling.data_validation "Získa pravidlá na overenie správnosti dát"
            enrollments.data_handling.data_validation -> enrollments.data_handling.data_preparation "Pošle na prípravu pred zobrazením"
        
            enrollments.data_handling.data_preparation -> enrollments.displayer.manager_displayer "Poskytne dáta"
        }

    }
}