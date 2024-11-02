workspace "Zápisy Workspace" "Tento Workspace dokumentuje architekturu softwarového systému Zápisy" {

    model {
        # Softwarové systémy
        enrollments = softwareSystem "Zápisy"
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
        
        
        
    }

    views {
        theme default
        
        systemContext enrollments {
            include *
        }
    }


}