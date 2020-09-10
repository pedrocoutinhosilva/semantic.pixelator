library(shiny)
library(htmltools)
library(glue)
library(shiny.semantic)
library(imager)
library(stringi)
library(shiny.grid)

# Define UI for application that draws a histogram

baseSize <- 300

ui <- semanticPage(
  tags$style(HTML("
    html, body {height: calc(100% - 10px);}
    .ui.raised.segment {margin: 0 !important;}
    .ui.checkbox {max-width: 17px;}
    .ui.checkbox, .ui.checkbox .label {
      max-height: 0;
      max-width: 0;
      padding: 0;
      margin: 0 -4px -4px 0;
      border: 1px solid;
    }
  ")),
  gridPanel(
    columns = "350px 1fr",
    gap = "15px",


    div(class = "ui raised segment",
        action_button("reload", "Load new image"),
      imageOutput("image")
    ),

    div(class = "ui raised segment",
      lapply(c(1:(baseSize/10)), function(height) {
        tagList(
          lapply(c(1:(baseSize/10)), function(width) {
            tagList(
              checkbox_input(paste0('pixel_', height, '_', width), is_marked = FALSE)
            )
          }),
          br()
        )
      }),
      uiOutput("grid")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  images <- reactiveValues(
    image = NULL,
    thumbnail = NULL
  )

  observeEvent(input$reload, {
    images$image <-
      load.image(glue('https://picsum.photos/{baseSize}/{baseSize}?.jpg'))
    images$thumbnail <- resize(images$image, round(baseSize/10), round(baseSize/10))
  })

  observeEvent(images$image, {
    output$image <- renderImage({
      outfile <- tempfile(fileext='.png')

      jpeg(outfile, width = baseSize, height = baseSize)
      save.image(images$image, outfile)
      dev.off()

      list(src = outfile, alt = "This is alternate text")
    }, deleteFile = TRUE)
  })

  observeEvent(images$thumbnail, {
    output$grid <- renderUI({
      pixelated <- images$thumbnail

      gridPanel(
        rows = glue("repeat({baseSize}, 17px)"),
        columns = glue("repeat({baseSize}, 17px)"),

        lapply(c(1:height(pixelated)), function(height) {
          tagList(
            lapply(c(1:width(pixelated)), function(width) {
              color <- color.at(pixelated, x = width, y = height)

              tagList(
                tags$style(HTML(glue::glue("
                input#{paste0('pixel_', height, '_', width)}~label:before{{
                  background-color: rgb({color[1] * 256}, {color[2] * 256}, {color[3] * 256}) !important;
                }}
              ")))
              )
            })
          )
        })
      )
    })
  })


}

# Run the application
shinyApp(ui = ui, server = server)
