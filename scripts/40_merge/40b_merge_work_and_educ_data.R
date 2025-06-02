##########################################################################
#             Project: Dissertation                                      #
#         Name: 40b_merge_work_and_educ_data                             #
#     Description: Merge education data (Census, SAT)                    #
#       Author : Matheus N. Loureiro                                     #
##########################################################################
# 1) Run Setup
source("scripts/00_setup/00_setup_environment.R")

# 2) Parameters
input <- cleanroot
input_rais <- # A DEFINIR
output <-  str_c(cleanroot, "/panels")
years <- 2009:2023

# 3) Functions for Reading Data
read_panel <- function(y) {
  vroom(
    file = fs::path(input, str_glue("/educ_panel_{y}.csv")),
    delim = ";",
    show_col_types = FALSE,
    progress = FALSE
  )
}

read_panel <- function(y) {
  vroom(
    file = fs::path(input_rais, str_glue("/rais_{y}.csv")),
    delim = ";",
    show_col_types = FALSE,
    progress = FALSE
  )
}

process_year_panel <- function(y) {
  
  message("▶ Ano ", y, " …")
  
  # Joining School Census Data 
  cb_y <- left_join(
    read_panel(y),
    read_cb(y+1),
    by = "cpf_masc",
    suffix  = c("", "_t1"),
    na_matches = "never"
  )
  
  # Saving as .csv
  out_path <- fs::path(output, str_glue("panel_{y}.csv"))
  
  vroom_write(panel_y, out_path, delim = ";", progress = FALSE)
  
  invisible(out_path)
  
}

# Executing Function
purrr::walk(years, process_year_panel)