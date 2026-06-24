# VNE style


# liste permettant un accès facile aux couleurs VNE
VNE_colors <- list(
  orangeVNE = "#fb883b",
  rougeVNE = "#ff6666",
  vertVNE = "#66cc33",
  violetVNE = "#ba6dba",
  bleubiolitVNE = "#23d2dd",
  jauneVNE = "#c2c62a",
  bleulichenVNE = "#5487ed",
  marronVNE = "#895f13",
  texteVNE = "#314C4C",
  vertclairVNE = "#ddeddd",
  grisUrbain = "#707176ff",
  `Opération escargots` = "#fb883b",
  `Escargots des Jardins (Inventaire)` = "#fb883b",
  `Oiseaux des Jardins` = "#ff6666",
  `Sauvages de ma rue` = "#66cc33",
  `Biolit` = "#23d2dd",
  `SPIPOLL` = "#c2c62a",
  `Lichen GO` = "#5487ed",
  `Observatoire des Vers de Terre` = "#895f13",
  texteVNE = "#314C4C",
  vertclairVNE = "#ddeddd",
  `ALAMER` = "#1d8f8fff",
  `Vigie-Chiro` = "#ba6dba",
  `Appétisol` = "#732735ff"
)

#' Function to extract VNE colors as hex codes
#'
#' @param ... Character names of VNE_colors 
#'
VNE_cols <- function(...) {
  cols <- c(...)
  
  if (is.null(cols))
    return (VNE_colors)
  
  VNE_colors[cols]
}

# palettes VNE
VNE_palettes <- list(
  `protocole_names` = VNE_cols("Opération escargots",
                               "Escargots des Jardins (Inventaire)",
                               "Oiseaux des Jardins",
                               "Sauvages de ma rue",
                               "Biolit",
                               "SPIPOLL",
                               "Lichen GO",
                               "Observatoire des Vers de Terre",
                               "ALAMER",
                              "Vigie-Chiro",
                            "Appétisol"),
  
  `protocoles`  = VNE_cols("orangeVNE",
                           "rougeVNE",
                           "vertVNE",
                           "violetVNE",
                           "bleubiolitVNE",
                           "jauneVNE",
                           "bleulichenVNE",
                           "marronVNE"),
  `environnement` = VNE_cols("vertclairVNE",
                             "texteVNE",
                             "vertVNE"),
  `medianeQuartile` = VNE_cols("texteVNE",
                               "vertVNE",
                               "bleubiolitVNE"),
  
  
  `gris` = VNE_cols("vertclairVNE", "texteVNE")
)
