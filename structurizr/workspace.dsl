workspace "Zápisy Workspace" "Tento Workspace dokumentuje architekturu softwarového systému Zápisy" {

    !identifiers hierarchical

    model {
        # Softwarové systémy
        enrollments = softwareSystem "Zápisy" {
            navigation = container "Navigace" {
                ui = component "UI" "Určuje rozhranie, pomocou ktoráho užívateľ interaguje so systémom"
                notification_reporter = component "Správca upozornení" "Upozorní užívateľa o nových dôležitých aktuálnostiach"
                routing_engine = component "Smerovací Engine" "Kontroluje presmerovania na jednotlivé časti systému"
                third_party_integrations = component "Integrácie so systémami tretích strán" "Spája systém s inými systémami a zaisťuje prúdenie dát"
            }
        }
        exams = softwareSystem "Zkoušky"
        schedules = softwareSystem "Rozvrhy"
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
        
        #Vzťahy medzi užívateľami a navigáciou
        student -> enrollments.navigation.ui "Ovládanie cez"
        teacher -> enrollments.navigation.ui "Ovládanie cez"
        study_dep -> enrollments.navigation.ui "Ovládanie cez"
        
        enrollments.navigation.notification_reporter ->  enrollments.navigation.ui "Posielanie notifikácii"
        enrollments.navigation.routing_engine ->  enrollments.navigation.ui "Posielanie notifikácii"
        
    }

    views {
        theme default
        
        systemContext enrollments {
            include *
        }

        container enrollments "ContainerView" {
            include *
            autoLayout
        }

        component enrollments.navigation "NavigationComponentView" {
            include *
            autoLayout
        }


    }
}