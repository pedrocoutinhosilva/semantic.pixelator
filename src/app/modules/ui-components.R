darkify <- function(callback, ...) {
  callback(...) %>% tagAppendAttributes(class = "inverted", type = "inverted")
}

paletteCell <- function(index) {
  div(
    id = glue("paletteColor{index}"),
    class = "palette-cell",
    `data-index` = index,
    style = glue("background-color: var(--palette-{index})"),
    div(class = "value")
  )
}

averageCard <- function(value, title, color) {
  card(
    class = "inverted",
    div(class = "content",
      div(class = "value", value),
      div(class = "title", title)
    )
  )
}

cssVariableRules <- paste(lapply(c(1:thumbnailSize), function(height) {
  paste(lapply(c(1:thumbnailSize), function(width) {
    glue::glue("
      #{paste0('pixel_', height, '_', width)}.ui.loader:after,
      #{paste0('pixel_', height, '_', width)}.ui.rating .active.icon {{
        color: var(--color-{height}-{width}) !important;
      }}
      #{paste0('pixel_', height, '_', width)}.ui.placeholder,
      input#{paste0('pixel_', height, '_', width)}~label:before{{
        background-color: var(--color-{height}-{width}) !important;
      }}
    ")
  }), collapse = "")
}), collapse = "")

pixelCell <- function(height, width, ...) {
  div(id = paste0('pixel_', height, '_', width), class = "ui placeholder")
}

loaderCell <- function(height, width, loader = double, ...) {
  div(id = paste0('pixel_', height, '_', width), class = glue::glue("ui mini active inline loader slow {loader}"))
}

ratingCell <- function(height, width, icon = "star", ...) {
  icon <- ifelse(icon == "random", sample(icons, 1), icon)
  rating_input(paste0('pixel_', height, '_', width), value = 1, max = 1, color = "black", icon = icon)
}

checkboxCell <- function(height, width, ...) {
  checkbox_input(paste0('pixel_', height, '_', width), is_marked = FALSE)
}

generateGrid <- function(baseSize, cellCallback, ...) {
  gridPanel(
    rows = glue("repeat({thumbnailSize}, 20px)"),
    columns = glue("repeat({thumbnailSize}, 20px)"),
    class = "cell-container",
    div(class = "ui placeholder overlay"),

    lapply(c(1:thumbnailSize), function(height) {
      tagList(
        lapply(c(1:thumbnailSize), function(width) {
          tagList(
            cellCallback(height, width, ...)
          )
        })
      )
    })
  )
}

paletteValues <- function(image, numberColors) {
  paste0(lapply(c(1:numberColors), function(index) {
      color <- color.at(image, sample(width(image), 1), sample(height(image), 1))

      if(length(color) == 1) {
        redValue <- color[1]
        greenValue <- color[1]
        blueValue <- color[1]
      } else {
        redValue <- color[1]
        greenValue <- color[2]
        blueValue <- color[3]
      }

      glue("--palette-{index}: rgb({redValue * 256}, {greenValue * 256}, {blueValue * 256});")
  }), collapse = "")
}
