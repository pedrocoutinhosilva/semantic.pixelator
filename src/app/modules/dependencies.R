cssCellRules <- function() {
  tags$style(
    paste(lapply(c(1:thumbnailSize), function(height) {
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
  )
}

eggs <- function() {
  tags$script(
    paste(
      "let eggList = [",
        paste(lapply(list.files("www/assets/eggs"), function(egg) {
          glue::glue("{{code: '{strsplit(egg, '.', fixed = TRUE)[[1]][1]}', target: '{egg}'}}")
        }), collapse = ","),
      "]", collapse = "")
  )
}

appDependencies <- function() {
  tagList(
    tags$link(rel = "stylesheet", href = "css/sass.min.css"),
    tags$script(src = "scripts/dom-to-image.min.js"),
    tags$script(src = "scripts/filesaver.js"),
    tags$script(src = "scripts/downloader.js"),
    tags$script(src = "scripts/egg.js"),
    tags$script(src = "scripts/palette.js"),
    tags$script(src = "scripts/console.js"),
    eggs(),
    cssCellRules()
  )
}
