#' Sets up a local semantic CDN.
options("shiny.custom.semantic.cdn" = "semantic")

#' Base sizes for the images and the generated grids.
baseSize <- 300
thumbnailSize <- round(baseSize/10)

#' List of semantic icons available for icon based grids.
icons <- list(
  "Stars" = "star",
  "Clouds" = "cloud",
  "Cats" = "cat",
  "Circles" = "circle",
  "Fishes" = "fish",
  "Apples" = "fruit-apple"
)

#' List of semantic loader types available for loader based grids.
loaders <- list(
  "Double line" = "double",
  "Single line" = "single"
)

#' List of types of grids that can be created. The value corresponds to an existing callback function
#'   that generates a piel unit of the grid.
pixelTypes <- c(
  "Icons" = "ratingCell",
  "Solid Pixels" = "pixelCell",
  "Animated loaders" = "loaderCell",
  "Checkboxes" = "checkboxCell"
)

#' List of available grid sizes. Only square grids are available for now. Bigger grids than 30x30 will work,
#'   but become very heavy given the amount of HTML elements added to the browser.
gridSizes <- c(
  "30x30" = 30,
  "25z25" = 25,
  "20x20" = 20,
  "15x15" = 15,
  "10x10" = 10,
  "5x5" = 5
)
