################################################
#             Project: Dissertation            #
#         Name: 00_setup_environment           #
#     Description: Setup Code for all Scripts  #
#       Author : Matheus N. Loureiro           #
################################################

# 1) Loading packages
pacman::p_load(
  # Workflow
  targets, fs, config, glue, purrr,
  # Data reading
  haven, readxl, readr,
  # Data wrangling
  tidyverse, dplyr, data.table, lubridate, reshape2, tidyr, stringi,
  stringr, broom, vroom, janitor,
  # Graphics
  ggplot2, lattice,
  # Reproducible
  knitr, rmarkdown, kableExtra,
  # Computation
  foreach, 
  # Models
  did, synthdid, contdid
)

# 2) Setting the directories
CFG   <- config::get(file = "config.yaml")          # adjust Raw path
DIRS  <- CFG$dirs  

# Function to create directories
ensure_dir <- function(path) {                      # idempotent & chatty
  abs <- (path)
  if (fs::dir_exists(abs)) {
    message("✓ exists: ", abs)
  } else {
    fs::dir_create(abs, recurse = TRUE)
    message("➕ created: ", abs)
  }
  invisible(abs)                                    # return abs path
}

# Main Directories
rawroot   <- ensure_dir(DIRS$rawdata)
cleanroot <- ensure_dir(DIRS$clean)
outroot   <- ensure_dir(DIRS$outcomes)

