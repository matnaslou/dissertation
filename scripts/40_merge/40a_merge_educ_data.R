##########################################################################
#             Project: Dissertation                                      #
#         Name: 10e_import_enem                                          #
#     Description: Import and Treat SAT (ENEM)                           #
#       Author : Matheus N. Loureiro                                     #
##########################################################################
# 1) Run Setup
source("scripts/00_setup/00_setup_environment.R")

# 2) Parameters
input <- cleanroot
output <-  str_c(cleanroot, "/panels")
years <- 2009:2023

# 3) Functions for Reading Data
read_cb <- function(y, what) {
  vroom(
    file = fs::path(input, str_glue("/cb_{y}_{what}.csv")),
    delim = ";",
    show_col_types = FALSE,
    progress = FALSE
  )
}

read_cs <- funtion(y, what) {
  vroom(
    file = fs::path(input, str_glue("/cs_{y}_{what}.csv")),
    delim = ";",
    show_col_types = FALSE,
    progress = FALSE
  )
}

read_enem <- function(y) {
  vroom(
    file = fs::path(input, str_glue("/enem_{y}.csv")),
    delim = ";",
    show_col_types = FALSE,
    progress = FALSE
  )
}

# Function for Processing Years
## Census Data and SAT (period t); Undergraduate Census (t+1)
process_year <- function(y) {
  
  message("▶ Ano ", y, " …")
  
  # Joining School Census Data 
  cb_y <- left_join(
    read_cb(y, "mat"),
    read_cb(y, "sch"),
    by = "co_entidade",
    suffix  = c("", "_sch"),
    na_matches = "never"
  )
  
  # Joining Undergraduate Census
  cs_y <- left_join(
    read_cs(y, "mat"),
    read_cs(y, "sch"),
    by = "co_ies",
    suffix  = c("", "_sch"),
    na_matches = "never"
  )
  
  # From years 2009 to 2022, joining with t+1 Undergraduate Census (Outcome is in t+1)
  if (y + 1 <= max(YEARS) + 1) {
    cs_next <- read_cs(y + 1, "mat") |>
      select(cpf_masc, everything())     # ID para juntar
    cbcs_y  <- cb_y |>
      left_join(cs_next,
                by      = "cpf_masc",
                suffix  = c("", "_cs"),
                na_matches = "never")
  } else {
    # 2023 only matters School Census and SAT Information
    cbcs_y <- cb_y
  }
  
  # Joining with SAT Data
  enem_y <- read_enem(y) |>
    select(id_estudante, everything())
  
  # Creating yearly panels
  panel_y <- cbcs_y |>
    left_join(enem_y, by = "cpf_masc")
  
  # Saving as .csv
  out_path <- fs::path(output, str_glue("panel_{y}.csv"))
  
  vroom_write(panel_y, out_path, delim = ";", progress = FALSE)
  
  invisible(out_path)
  
}

# Binding Years
panel_paths <- map(years, process_year)

master_path <- fs::path(output, "educ_panel.csv")

master_df <- map(panel_paths, ~ vroom(.x, delim = ";", progress = FALSE)) |>
  list_rbind()

vroom_write(master_df, master_path, delim = ";", progress = FALSE)