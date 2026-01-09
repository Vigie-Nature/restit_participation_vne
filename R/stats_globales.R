# stats_globales
# all = toutes les valeurs incluses dans le calcul
# table = renvoie un tableau selon la variable
# valeur = filtrer
# compter classes, profs, etablissements
stats_globales <- function(df, compter = "classes", selectAcademie = "all", selectAnnee = "all", selectProtocole = "all", selectTypeEtablissement = "all"){
  if (!compter %in% c("classes", "profs", "etablissements", "observations", "eleves", "protocoles")) stop("L'argument compter doit prendre l'une des valeurs suivantes : 'classes', 'profs', 'etablissements', 'observations', 'protocoles', 'eleves'")
  variable_a_compter <- switch (compter,
                                classes = "groupepk",
                                profs = "userpk",
                                etablissements = "structurepk",
                                observations = "num_observation",
                                eleves = "groupepk",
                                protocoles = "protocole"
  )
  
  # affect Ecole maternelle et élémentaire to Ecole élémentaire
  
  df$type_etablissement[df$type_etablissement == "Ecole maternelle et élémentaire"] <- "Ecole élémentaire"
  df$type_etablissement[!df$type_etablissement %in% c("Ecole maternelle", "Ecole élémentaire", "Collège", "Lycée", "Autre", "Université" )] <- "Autre" 
  
  # choose the variable that will make the table
  if (any(selectAcademie == "table", 
          selectAnnee == "table", 
          selectProtocole == "table",
          selectTypeEtablissement == "table")){
    group = c()
    if (selectAcademie == "table") group = c(group, "academie")
    if (selectAnnee == "table") group = c(group, "annee_scolaire")
    if (selectProtocole == "table") group = c(group, "protocole")
    if (selectTypeEtablissement == "table") group = c(group, "type_etablissement")
  }
  
  # choose the variables that are fixed
  if (!selectAcademie %in% c("all", "table")) df = dplyr::filter(df, academie %in% selectAcademie)
  if (!selectAnnee %in% c("all", "table")){
    selectAnnee <- as.numeric(selectAnnee)
    df = dplyr::filter(df, annee_scolaire %in% selectAnnee)
  } 
  if (!selectProtocole %in% c("all", "table")) df = dplyr::filter(df, protocole %in% selectProtocole)
  if (!selectTypeEtablissement %in% c("all", "table")) df = dplyr::filter(df, type_etablissement %in% selectTypeEtablissement)
  
  # if no table function without group_by
  if (!"table" %in% c(selectAnnee, selectProtocole, selectAcademie, selectTypeEtablissement)){
    if(compter != "eleves"){
      result <- df |>
        dplyr::select_at(dplyr::all_of(variable_a_compter)) |>
        dplyr::distinct()|>
        tidyr::drop_na() |>
        dplyr::summarise(nombre = dplyr::n())
      names(result) = compter
      result
    } else {
      result <- df |>
        dplyr::select(dplyr::all_of(c(variable_a_compter, "effectifs"))) |>
        dplyr::distinct() |>
        tidyr::drop_na() |>
        dplyr::summarise(nombre = sum(effectifs))
      names(result) = compter
      result
    }
  } else if (compter == "eleves") {
    result <- df |>
      dplyr::select(dplyr::all_of(c(variable_a_compter, group, "effectifs"))) |>
      dplyr::distinct() |>
      tidyr::drop_na() |>
      dplyr::group_by_at(c(group)) |>
      dplyr::summarise(nombre = sum(effectifs))
    result <- as.data.frame(result)
    names(result)[names(result) == 'nombre'] <- compter
    result
  } else {
    result <- df |>
      dplyr::group_by_at(dplyr::all_of(group)) |>
      dplyr::select(dplyr::all_of(variable_a_compter)) |>
      dplyr::distinct()|>
      tidyr::drop_na() |>
      dplyr::summarise(nombre = dplyr::n())
    result <- as.data.frame(result)
    names(result)[names(result) == 'nombre'] <- compter
    result
  }
}
