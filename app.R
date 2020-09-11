library(shiny)
library(htmltools)
library(glue)
library(shiny.semantic)
library(imager)
library(stringi)
library(shiny.grid)

baseSize <- 300

darkify <- function(callback, ...) {
  callback(...) %>% tagAppendAttributes(class = "inverted", type = "inverted")
}

icons <- list(
  "Stars" = "star",
  "Clouds" = "cloud",
  "Cats" = "cat",
  "Circles" = "circle",
  "Fishes" = "fish",
  "Apples" = "fruit-apple"
)

cssVariableRules <- paste(lapply(c(1:(baseSize/10)), function(height) {
  paste(lapply(c(1:(baseSize/10)), function(width) {
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

ui <- semanticPage(
  tags$link(rel = "stylesheet", href = "styles.css"),
  tags$script(src = "dom-to-image.min.js"),
  tags$style(cssVariableRules),

  imageOutput("bodyBackground") %>% tagAppendAttributes(class = "body-background"),

  gridPanel(
    columns = "350px 1fr",
    rows = "75px 1fr",
    areas = c(
      "header main",
      "side main"
    ),
    gap = "15px",

    header = div(
      class = "ui raised segment inverted",
      div(class = "background-gradient"),
      h2(class = "title", "Semantic Pixelator")
    ),

    side = div(class = "ui raised segment inverted",
      darkify(action_button, "reload", "Load new image"),
      imageOutput("image"),

      darkify(
        selectInput,
        "gridType",
        "Pixel grid type",
        c(
          "pixel grid" = "pixelCell",
          "loader grid" = "loaderCell",
          "rating grid" = "ratingCell",
          "checkbox grid" = "checkboxCell"
        )
      ),
      darkify(
        selectInput,
        "rateType",
        "Pixel grid type",
        modifyList(icons, list("Randomize" = "random"))
      ),
      darkify(action_button, "randomize", "Randomize icons again")
    ),

    main = gridPanel(class = "ui raised segment pixel-grid inverted",
      columns = "1fr 300px",
      rows = "1fr",
      gap = "15px",

      div(
        class = "grid-wrapper",
        uiOutput("gridCells"),
        uiOutput("grid")
      ),
      div(
        class = "grid-side ui raised segment inverted",
        uiOutput("averageRed"),
        uiOutput("averageGreen"),
        uiOutput("averageBlue"),

        div(darkify(toggle, "grayScale", "Gray scale", is_marked = FALSE)),
        div(darkify(toggle, "toggleRed", "Enable red")),
        div(darkify(toggle, "toggleGreen", "Enable green")),
        div(darkify(toggle, "toggleBlue", "Enable blue"))
      )
    )
  )
)

pixelCell <- function(height, width, ...) {
  div(id = paste0('pixel_', height, '_', width), class = "ui placeholder")
}

loaderCell <- function(height, width, ...) {
  div(id = paste0('pixel_', height, '_', width), class = "ui mini active inline loader slow double")
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
    rows = glue("repeat({baseSize/10}, 20px)"),
    columns = glue("repeat({baseSize/10}, 20px)"),
    class = "cell-container",
    div(class = "ui placeholder overlay"),

    lapply(c(1:(baseSize/10)), function(height) {
      tagList(
        lapply(c(1:(baseSize/10)), function(width) {
          tagList(
            cellCallback(height, width, ...)
          )
        })
      )
    })
  )
}

# Define server logic required to draw a histogram
server <- function(input, output) {
  images <- reactiveValues(
    image = NULL,
    thumbnail = NULL,
    filteredThumbnail = NULL
  )

  images$image <- load.image(glue('https://picsum.photos/{baseSize}/{baseSize}?.jpg'))

  observeEvent(c(input$gridType, input$rateType, input$randomize), {
    output$gridCells <- renderUI({
      generateGrid(baseSize, get(input$gridType), input$rateType)
    })
  })

  observeEvent(input$reload, {
    images$image <-
      load.image(glue('https://picsum.photos/{baseSize}/{baseSize}?.jpg'))
  })

  observeEvent(images$image, {
    images$thumbnail <- resize(images$image, round(baseSize/10), round(baseSize/10))

    output$bodyBackground <- renderImage({
      outfile <- tempfile(fileext='.png')
      jpeg(outfile, width = baseSize, height = baseSize)
      save.image(images$image, outfile)

      list(src = outfile, alt = "Main picture")
    }, deleteFile = TRUE)
    dev.off()

    output$image <- renderImage({
      outfile <- tempfile(fileext='.png')
      jpeg(outfile, width = baseSize, height = baseSize)
      save.image(images$image, outfile)

      list(src = outfile, alt = "Background picture")
    }, deleteFile = TRUE)
    dev.off()
  })

  observeEvent(c(images$thumbnail, input$toggleRed, input$toggleGreen, input$toggleBlue, input$grayScale), {
    images$filteredThumbnail <- images$thumbnail

    if(!is.null(images$filteredThumbnail)) {

      if(input$grayScale) {
        images$filteredThumbnail <- grayscale(images$thumbnail)
      } else {
        if(!input$toggleRed) {
          R(images$filteredThumbnail) <- 0
        }
        if(!input$toggleGreen) {
          G(images$filteredThumbnail) <- 0
        }
        if(!input$toggleBlue) {
          B(images$filteredThumbnail) <- 0
        }
      }
    }
  })

  observeEvent(images$filteredThumbnail, {
    assign("Rcolor", 0, envir = .GlobalEnv)
    assign("Gcolor", 0, envir = .GlobalEnv)
    assign("Bcolor", 0, envir = .GlobalEnv)

    output$grid <- renderUI({
      tags$style(
        paste(
          ":root {",
          paste(lapply(c(1:height(images$filteredThumbnail)), function(height) {
            paste(lapply(c(1:width(images$filteredThumbnail)), function(width) {
              color <- color.at(images$filteredThumbnail, x = width, y = height)

              if(length(color) == 1) {
                redValue <- color[1]
                greenValue <- color[1]
                blueValue <- color[1]
              } else {
                redValue <- color[1]
                greenValue <- color[2]
                blueValue <- color[3]
              }

              assign("Rcolor", (get("Rcolor", envir = .GlobalEnv) + redValue), envir = .GlobalEnv)
              assign("Gcolor", (get("Gcolor", envir = .GlobalEnv) + greenValue), envir = .GlobalEnv)
              assign("Bcolor", (get("Bcolor", envir = .GlobalEnv) + blueValue), envir = .GlobalEnv)

              glue::glue("--color-{height}-{width}: rgb({redValue * 256}, {greenValue * 256}, {blueValue * 256});")
            }), collapse = "")
          }), collapse = ""),
          glue::glue("--color-image-average: rgb({get('Rcolor', envir = .GlobalEnv)/cellNumber * 256}, {get('Gcolor', envir = .GlobalEnv)/cellNumber * 256}, {get('Bcolor', envir = .GlobalEnv)/cellNumber * 256})"),
        "}", collapse = "")
      )
    })

    cellNumber <- width(images$filteredThumbnail) * height(images$filteredThumbnail)

    output$averageRed <- renderUI({span(get("Rcolor", envir = .GlobalEnv)/cellNumber)})
    output$averageGreen <- renderUI({span(get("Gcolor", envir = .GlobalEnv)/cellNumber)})
    output$averageBlue <- renderUI({span(get("Bcolor", envir = .GlobalEnv)/cellNumber)})
  })
}

# Run the application
shinyApp(ui = ui, server = server)
