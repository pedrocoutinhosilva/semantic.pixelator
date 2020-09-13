library(shiny)
library(sass)
library(htmltools)
library(glue)
library(shiny.semantic)
library(imager)
library(stringi)
library(shiny.grid) #devtools::install_github("pedrocoutinhosilva/shiny.grid")

source("modules/dependencies.R")
source("modules/options.R")
source("modules/ui-fragments.R")

sass(
  sass::sass_file("styles/main.scss"),
  cache_options = sass_cache_options(FALSE),
  options = sass_options(output_style = "compressed"),
  output = "www/css/sass.min.css"
)
