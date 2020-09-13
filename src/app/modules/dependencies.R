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

appDependencies <- function() {
  tagList(
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$script(src = "dom-to-image.min.js"),
    tags$script(src = "filesaver.js"),
    tags$script(src = "downloader.js"),
    tags$script(src = "palette.js"),
    cssCellRules()
  )
}
