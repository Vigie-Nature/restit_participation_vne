##################################################################
#  Participation script
#
#
#
#
##################################################################
library(ggplot2)
library(dplyr)

# load scripts
source("../export_data_management/R/functions_import_database_VN.R")
source("R/stats_globales.R")
source("R/calc_school_year.R")
source("R/label_years.R")
source("R/plot_participation.R")
source("R/vne_style.R")

readRenviron(".Renviron")

# import data
participation_vne <- import_from_vne(read_sql_query("sql/Resume_complet_des_observations_moins_agrege.sql"))


### clean etab names ----
participation_vne$type_etablissement[participation_vne$type_etablissement == "Autre" | participation_vne$type_etablissement == "structure"] <- "Autre"
participation_vne$type_etablissement[participation_vne$type_etablissement == "Ecole Maternelle"] <- "Ecole maternelle" 
participation_vne$type_etablissement <- factor(participation_vne$type_etablissement)

### clean protocol names ----
participation_vne$protocole[participation_vne$protocole == "Escargots des Jardins (Inventaire)"] <- "Opération escargots"
participation_vne$protocole[participation_vne$protocole == "Lichen Go"] <- "Lichen GO"

### add observation month ----
participation_vne$moisObs <- lubridate::month(participation_vne$date_observation)


participation_vne$annee_scolaire = calc_school_year(participation_vne$date_observation)
participation_vne <- participation_vne %>%
  filter(annee_scolaire > 2012)
participation_vne$annee_scolaire <- as.character(participation_vne$annee_scolaire)


### graph_participation classes

nombre_classe_par_an <- stats_globales(participation_vne, selectAnnee = "table")

nombre_classe_par_an$labelsYears = label_years(nombre_classe_par_an$annee, retour = TRUE)
participation_chiro =         c(    16,     16,     16,     16,     16,     16,     16,     23,     38,     28,     15,     25,     20)
names(participation_chiro) <- c("2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026")

participation_appetisol =         c(     0,      0,      0,      0,      0,      0,      0,      0,      0,      0,      0,      0,     19)
names(participation_appetisol) <- c("2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026")

nombre_classe_par_an$classes = nombre_classe_par_an$classes + participation_chiro + participation_appetisol



plot_participation_per_year(nombre_classe_par_an)

### graph participation profs
nombre_classe_par_an <- stats_globales(participation_vne, selectAnnee = "table", compter = "profs")
nombre_classe_par_an$labelsYears = label_years(nombre_classe_par_an$annee, retour = TRUE)
plot_participation_per_year(nombre_classe_par_an)

### graph participation observations
nombre_classe_par_an <- stats_globales(participation_vne, selectAnnee = "table", compter = "observations")

nombre_classe_par_an$labelsYears = label_years(nombre_classe_par_an$annee, retour = TRUE)
plot_participation_per_year(nombre_classe_par_an)

### graph participation etab
nombre_classe_par_an <- stats_globales(participation_vne, selectAnnee = "table", compter = "etablissements")
nombre_classe_par_an$labelsYears = label_years(nombre_classe_par_an$annee, retour = TRUE)
plot_participation_per_year(nombre_classe_par_an)

### graph participation eleves
nombre_eleves_par_an <- stats_globales(participation_vne, selectAnnee = "table", compter = "eleves")
nombre_eleves_par_an$labelsYears = label_years(nombre_eleves_par_an$annee, retour = TRUE)
nombre_eleves_par_an$eleves = nombre_classe_par_an$eleves + participation_chiro*25 + participation_appetisol*25
plot_participation_per_year(nombre_classe_par_an)

# graph par protocoles ----
## calculate metric ----
participation_vne_count_years_protocoles <-stats_globales(participation_vne, selectAnnee = "table", selectProtocole = "table")
chiro <- data.frame( annee_scolaire = names(participation_chiro), protocole = "Vigie-Chiro", classes = participation_chiro)
appetisol <- data.frame( annee_scolaire = names(participation_appetisol), protocole = "Appétisol", classes = participation_appetisol)

participation_vne_count_years_protocoles <- rbind(participation_vne_count_years_protocoles, chiro, appetisol)


### prepare labels ----
participation_vne_count_years_protocoles$annee_scolaire_labels <- label_years(participation_vne_count_years_protocoles$annee_scolaire, retour = TRUE)

# reduce label number
xlabels <- sort(unique(participation_vne_count_years_protocoles$annee_scolaire_labels))
xlabels[seq(2, length(xlabels), 2)] <- ""


## make graph ----
participation_protocole_temps_classes <- ggplot(participation_vne_count_years_protocoles, aes(x = annee_scolaire_labels, y = classes, fill = protocole)) +
  geom_col() +
  theme_light() +
  labs(x = "Année scolaire", y = "Nombre de classes ayant envoyé des données") +
  theme(legend.position = "none", strip.text.x = element_text(size = 14), axis.title = element_text(size = 14)) +
  scale_fill_manual(values = unlist(VNE_palettes$protocole_names))+
  scale_x_discrete(labels = xlabels) +
  facet_wrap(~protocole)

participation_protocole_temps_classes

### Fidelisation ----

# combien les profs font-ils de session d'observation
participation_vne$user_id <- participation_vne$observateur
participation_vne$annee_participation <- participation_vne$annee_scolaire
participation_vne$type_etablissement <- participation_vne$type_etablissement


# fidelisation par etablissements


# get table of users per period
new_users <- participation_vne %>%
  dplyr::select(user_id, annee_participation, type_etablissement) %>%
  distinct() %>%
  arrange(annee_participation) %>%
  data.table::setDF()

# all first users are new
new_users$new = 1

cum_particip <- new_users %>%
  group_by(user_id) %>%
  mutate(year_parti = cumsum(new))%>%
  arrange(desc(year_parti))

# get count per categories
new_users_summary <- cum_particip %>%
  group_by(annee_participation, year_parti, type_etablissement) %>%
  summarise(nombre_users = n()) %>%
  filter(type_etablissement %in% c("Ecole maternelle", "Ecole élémentaire", "Collège", "Lycée"))

# revert order for plot


pluriannual_users_summary <- new_users_summary |>
  filter(year_parti > 1) %>%
  mutate(nb_annee_partic = ordered(year_parti,sort(unique(new_users_summary$year_parti))))


ggplot(pluriannual_users_summary, aes(x = annee_participation, y = nombre_users)) +
  geom_col(aes(fill = nb_annee_partic)) +
  facet_wrap(~type_etablissement) +
  theme_minimal() +
  theme(legend.position="bottom") +
  guides(fill=guide_legend(nrow=2,byrow=TRUE))

new_users_summary$nb_annee_partic_cat <- ifelse(new_users_summary$year_parti == 1, "Nouveau user", "User pluriannuel")

ggplot(new_users_summary, aes(x = annee_participation, y = nombre_users)) +
  geom_col(aes(fill = nb_annee_partic_cat)) +
  facet_wrap(~type_etablissement) +
  theme_minimal() +
  theme(legend.position="bottom") +
  guides(fill=guide_legend(nrow=2,byrow=TRUE))

