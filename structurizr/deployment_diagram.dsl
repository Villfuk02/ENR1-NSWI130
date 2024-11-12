workspace "Deployment Diagram" {
    !identifiers hierarchical
    
    model {
        enrollments = softwareSystem "Zápisy" {
            displayer = container "Zobrazení"
            email_service = container "Email service"
            data_handling = container "Data handling"
            user_enrollment = container "Zápisy uživatele"
            
            modification_history = container "Historie změn" "Database"
            database = container "Users Database"
            api = container "Zápisy API"
        }
        
        mail_server = softwareSystem "Mail server" {

        }

        schedules = softwareSystem "Rozvrhy" {
            courses_and_events = container "Předměty a lístky" "Database"
        }

        users = softwareSystem "Uživatelé" {
            user_database = container "Database"
        }
        
        enrollments.displayer -> enrollments.email_service "Forwards requests to [HTTPS]"
        enrollments.email_service -> mail_server "Send email [SMTP/IMAP]"
        
        enrollments.displayer -> enrollments.data_handling "Sending and receiving data [HTML]"
        enrollments.data_handling -> schedules "API Calls to Schedules Database [XML/HTTPS]"
        enrollments.data_handling -> enrollments.modification_history "Reads from and writes to [SQL]"
        
        enrollments.user_enrollment -> users "Reads from [SQL]"
        enrollments.user_enrollment -> enrollments.database "Reads from and writes to [SQL]"
        
        enrollments.api -> enrollments.database "Reads from and writes to [SQL]"

        deploymentEnvironment "Production" {
            apacheTomcat = deploymentNode "Apache Tomcat" "Deployment node: Apache Tomcat 8.x" {
                apiInstance = containerInstance enrollments.api
            }
            
            oracleDB = deploymentNode "Oracle" "Deployment node: Oracle 12c" {
                enrollmentsDBInstance = containerInstance enrollments.database
                historyDBInstance = containerInstance enrollments.modification_history
            }
            
            
            amazonEmailService = deploymentNode "Amazon simple email service" "Deployment node: Amazon SES" {
                emailServiceInstance = containerInstance enrollments.email_service
            }
            
            mailserver = deploymentNode "Mail server"{
                mailServerInstance = softwareSystemInstance mail_server
            }
            
            webBrowser = deploymentNode "Web server" "Deployment node: Chrome, Firefix, Edge"{
                displayInstance = containerInstance enrollments.displayer
            }
            
            javaSpringBoot = deploymentNode "Java SpringBoot Framework" "Deployment node: Java SpringBoot 3.x"{
                dataHandlingInstance = containerInstance enrollments.data_handling
                userEnrInstance = containerInstance enrollments.user_enrollment
            }
            
            schedules = deploymentNode "Schedules SW System"{
                schedulesInstance = softwareSystemInstance schedules
            }
            
            usersSS = deploymentNode "Users SW system"{
                usersSSInstance = softwareSystemInstance users
            }
            
            
        }
    }

    views {
        deployment enrollments "Production" {
            include *
            autolayout lr
        }

        theme default
    }
}
