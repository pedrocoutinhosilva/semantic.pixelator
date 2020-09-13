linkIcon <- function(icon, color, link) {
  tags$a(icon(class = glue::glue("large {icon}"), style = glue::glue("color: {color}")), target = "_blank", href = link)
}

helpModal <- function() {
  tagList(
    div(
      id = "help-open-button",
      class = "ui teal tertiary button",
      tags$i(class="info circle icon"), "About Pixelator..."
    ),
    modal(
      div(
        div(class = "title", "About Semantic Pixelator"),
        div(class = "message",
          p("Generate and save diferent compositions based on semantic/fomantic ui elements!"),
          p("Use the sidebar to load diferent images and pick the settings for your composition."),
          p("On the right side you can view the resulting composition, as well as generate diferent color palettes and download the results.")
        ),
        div(
          class = "inverted ui segment project-details",
          div(class = "author", p(class = "type", "About the author"),
            div(
              class = "avatar",
              tags$img(src = "assets/avatar.jpeg"),
              p("Pedro Silva")
            ),
            linkIcon("twitter", "#1da1f2", "https://twitter.com/sparktuga"),
            linkIcon("linkedin in", "#0077b5", "https://www.linkedin.com/in/pedrocoutinhosilva/"),
            linkIcon("github alternate", "#767676", "https://github.com/pedrocoutinhosilva")
          ),
          div(class = "repo", p(class = "type", "Pixelator Project"),
            p(style = "line-height: 20px; margin-bottom: 10px;", "Entry for the Appsilon semantic competition 2020"),
            linkIcon("github", "#767676", "https://github.com/pedrocoutinhosilva/semantic.pixelator")
          )
        )
      ),
      footer = div(class = "inverted positive teal ui button", "Return"),
      id = "help-modal",
      class = "inverted",
      target = "help-open-button"
    )
  )
}

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
