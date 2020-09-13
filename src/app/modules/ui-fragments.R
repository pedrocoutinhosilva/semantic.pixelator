pageBackground <- function() {
  imageOutput("bodyBackground") %>% tagAppendAttributes(class = "body-background")
}

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

generateSourceImage <- function(src, name) {
  outfile <- tempfile(fileext='.png')
  jpeg(outfile, width = baseSize, height = baseSize)
  save.image(src, outfile)
  dev.off()

  list(src = outfile, alt = name)
}
