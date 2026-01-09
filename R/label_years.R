# add a value for the "annee scolaire"
# style
label_years <- function (x, retour = FALSE){
  yearMoinsUn <- as.numeric(x) - 1
  if (retour) paste0(yearMoinsUn, "\n", x) else paste(yearMoinsUn, " - ", x)
}