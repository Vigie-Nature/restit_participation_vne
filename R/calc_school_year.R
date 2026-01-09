calc_school_year <- function (observation_date){
  observation_year <- ifelse(lubridate::month(observation_date) %in% 1:8,
                             lubridate::year(observation_date),
                             lubridate::year(observation_date) + 1)
  observation_year
}