workspace "Dynamic diagram -- Manager spraví request pre dáta z databázy histórie zmien" {
    !identifiers hierarchical

    model {
        manager = person "Manager" "Manažér, ktorý interaguje so systémom."
       
        enrollments = softwareSystem "Zápisy" {
           displayer = container "Zobrazenie" {
                ui = component "UI" "Určuje rozhranie, pomocou ktorého užívateľ interaguje so systémom"
           
                routing_engine = component "Smerovací engine" "Engine, ktorý presmerováva a poskytuje HTML stránky."
                manager_view = component "Zobrazenie pre managera"
           }
           data_handling = container "Data Handling"{
               loader = component "Loader" "Spracováva requesty na zobrazenie dát a v správnom formáte ich posiela databázovým API."
               validator_data_correctness = component "Validátor správnosti dát" "Na základe pravidiel overuje, či sú requesty a dáta platné."
               rules = component "Pravidlá" "Zoznam pravidiel, podľa ktorých sa overujú requesty do databáz + dáta, ktoré z databáz prichádzajú"
               data_preparation = component "Data preparation [zobrazenie]" "Prijíma požiadavky na zobrazenie a posiela ich na overenie. Získané dáta mení do vhodného formátu na zobrazenie."
               changes_api = component "Changes API" "API, ktoré interaguje s databázou histórie zmien."
           }
           history_db = container "History of changes [database]"
        }
        
        schedules = softwareSystem "Schedules [database]"{
            schedules_db = container "Databáza predmetov a lístkov"{
                
            }
        }
        
        manager -> enrollments.displayer.ui "1. Chce si zobraziť históriu zmien"
        enrollments.displayer.routing_engine -> enrollments.displayer.ui "2. Poskytne HTML stránku"
        enrollments.displayer.routing_engine -> enrollments.displayer.manager_view "3. Nasmeruje na zobrazenie"
        enrollments.displayer.manager_view -> enrollments.data_handling.data_preparation "4. Vyžiada dáta"

        enrollments.data_handling.data_preparation -> enrollments.data_handling.loader "5. Pošle požiadavok na načítanie dát"
        enrollments.data_handling.loader -> enrollments.data_handling.validator_data_correctness "6. Pošle požiadavok na overenie"
        enrollments.data_handling.rules -> enrollments.data_handling.validator_data_correctness "7. Získa pravidlá na overenie správnosti požiadavku"
        enrollments.data_handling.validator_data_correctness -> enrollments.data_handling.loader "8. Informuje o správnosti"
        enrollments.data_handling.loader -> enrollments.data_handling.changes_api "9. Pošle request na načítanie"
        enrollments.data_handling.changes_api -> enrollments.history_db "10. Request zmení na SQL a pošle ho"
        enrollments.history_db -> enrollments.data_handling.changes_api "11. Vráti získané dáta"
        enrollments.data_handling.changes_api -> enrollments.data_handling.loader "12. Vráti získané dáta"
        enrollments.data_handling.loader -> enrollments.data_handling.validator_data_correctness "13. Pošle získané dáta na overenie"
        
        enrollments.data_handling.rules -> enrollments.data_handling.validator_data_correctness "14. Získa pravidlá na overenie správnosti dát"
        enrollments.data_handling.validator_data_correctness -> enrollments.data_handling.data_preparation "15. Pošle na prípravu pred zobrazením"
        
        enrollments.data_handling.data_preparation -> enrollments.displayer.manager_view "16. Poskytne dáta"
        
    }

    views {
        component enrollments.data_handling "Nav"{
            include *
            autoLayout lr
        }

        component enrollments.displayer "NavigationComponentView" {
            include *
            autoLayout lr
        }
        
        container enrollments "ContainerView" {
            include *
            autoLayout
        }

        theme default
    }
}