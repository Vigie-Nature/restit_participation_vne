# plot participation
plot_participation_per_year <- function(df) {
  if ("classes" %in% colnames(df)) {
    y_var = "classes"
    y_lab = "Nombre de classes \n participantes"
  } else if ("profs" %in% colnames(df)) {
    y_var = "profs"
    y_lab = "Nombre d'enseignants et d'enseigantes \n ayant participés"
  } else if ("observations" %in% colnames(df)) {
    y_var = "observations"
    y_lab = "Nombre d'observations \n réalisées"
  } else if ("etablissements" %in% colnames(df)) {
    y_var = "etablissements"
    y_lab = "Nombre d'établissements \n ayant participés"
  } else if ("eleves" %in% colnames(df)) {
    y_var = "eleves"
    y_lab = "Nombre d'élèves \n ayant participés"
  }
  
  graph_participation <- ggplot(df, aes(x = annee_scolaire, y = !!sym(y_var), group = 1)) +
    geom_line(color = "#00CC33", linewidth= 1) +
    geom_point(color = "#00CC33", size = 2) +
    geom_text(aes(label = !!sym(y_var)), position = position_dodge(width = 1),
              vjust = +2, size = 3)+
    ylab(y_lab) +
    xlab("Années") +
    scale_x_discrete(labels = df$labelsYears) +
    theme_minimal() +
    theme(panel.grid.major = element_line(color = "#FFFFFF"), panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          text = element_text(colour = "#314C4C")) +
    expand_limits(y=0)
  return(graph_participation)
}
