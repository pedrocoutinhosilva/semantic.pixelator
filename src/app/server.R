function(session, input, output) {
  images <- reactiveValues(
    image = load.image(glue('https://picsum.photos/{baseSize}/{baseSize}?.jpg')),
    thumbnail = NULL,
    filteredThumbnail = NULL
  )

  observeEvent(input$downloadImage, {
    session$sendCustomMessage("downloadImage", list(id = "gridCells", name = "pixelated-image"))
  })

  observeEvent(input$downloadPalette, {
    session$sendCustomMessage("downloadImage", list(id = "generatedPalette", name = "color-palette"))
  })

  observeEvent(input$gridType, {
    output$pixelType <- renderUI({
      darkify(selectInput,"rateType", "Pixel type", modifyList(list("Randomize" = "random"), icons)) %>%
      tagAppendAttributes(class = ifelse(input$gridType != "ratingCell", "hidden", ""))
    })
  })

  observeEvent(input$gridType, {
    output$loaderType <- renderUI({
      darkify(selectInput, "loaderWidthType", "Loader type", loaders) %>%
      tagAppendAttributes(class = ifelse(input$gridType != "loaderCell", "hidden", ""))
    })
  }, ignoreInit = TRUE)

  observeEvent(input$rateType, {
    output$pixelRandomize <- renderUI({
      darkify(action_button, "randomize", "Randomize icons") %>%
        tagAppendAttributes(class = ifelse(
          is.null(input$gridType) || is.null(input$rateType), "hidden", "")
        ) %>%
        tagAppendAttributes(class = ifelse(
          input$gridType != "ratingCell" || input$rateType != "random", "hidden", "")
        )
    })
  }, ignoreInit = TRUE)

  observeEvent(c(input$gridType, input$randomize, input$loaderWidthType), {
    output$gridCells <- renderUI({
      tagList(
        div(
          class = "loading",
          div(class = glue::glue("large ui text active inline loader slow"), "Generating...")
        ),
        generateGrid(baseSize, get(input$gridType), icon = input$rateType, loader = input$loaderWidthType)
      )
    })
  }, ignoreInit = TRUE)

  observeEvent(input$reload, {
    images$image <- load.image(glue('https://picsum.photos/{baseSize}/{baseSize}?.jpg'))
  })

  observeEvent(images$image, {
    images$thumbnail <- resize(images$image, thumbnailSize, thumbnailSize)

    output$bodyBackground <- renderImage({
      generateSourceImage(images$image, "Main picture")
    }, deleteFile = TRUE)

    output$image <- renderImage({
      generateSourceImage(images$image, "Background picture")
    }, deleteFile = TRUE)
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

  observeEvent(input$generatePalette, {
    newPalette <- paletteValues(images$filteredThumbnail, 5)

    output$paletteColors <- renderUI({
      tags$style(paste(":root {", newPalette, "}"))
    })
    session$sendCustomMessage("updatePaletteText", list(values = newPalette))
  })

  observeEvent(images$filteredThumbnail, {
    assign("Rcolor", 0, envir = .GlobalEnv)
    assign("Gcolor", 0, envir = .GlobalEnv)
    assign("Bcolor", 0, envir = .GlobalEnv)

    cellNumber <- width(images$filteredThumbnail) * height(images$filteredThumbnail)

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
          glue::glue("--color-image-average: rgb({get('Rcolor', envir = .GlobalEnv)/cellNumber * 256}, {get('Gcolor', envir = .GlobalEnv)/cellNumber * 256}, {get('Bcolor', envir = .GlobalEnv)/cellNumber * 256});"),
        "}", collapse = "")
      )
    })
  })
}
