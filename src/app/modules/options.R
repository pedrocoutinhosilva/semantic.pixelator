options("shiny.custom.semantic.cdn" = "semantic")

baseSize <- 300
thumbnailSize <- round(baseSize/10)

icons <- list(
  "Stars" = "star",
  "Clouds" = "cloud",
  "Cats" = "cat",
  "Circles" = "circle",
  "Fishes" = "fish",
  "Apples" = "fruit-apple"
)

loaders <- list(
  "Double line" = "double",
  "Single line" = "single"
)

pixelTypes <- c(
  "Icons" = "ratingCell",
  "Solid Pixels" = "pixelCell",
  "Animated loaders" = "loaderCell",
  "Checkboxes" = "checkboxCell"
)

gridSizes <- c(
  "30x30" = 30,
  "20x20" = 20,
  "10x10" = 10,
  "5x5" = 5
)
