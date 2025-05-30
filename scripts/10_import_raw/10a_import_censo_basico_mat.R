#########################################################################
#             Project: Dissertation                                     #
#         Name: 10a_import_censo_basico_mat                             #
#     Description: Import and Treat Educational Census (Student Level)  #
#       Author : Matheus N. Loureiro                                    #
#########################################################################
# 1) Run Setup
source("scripts/00_setup/00_setup_environment.R")

# 2) Parameters
input <- "caminho_censo_basico_sedap"
output <- cleanroot
years <- 2007:2024

# 3) Selected Columns
# One canonical list of columns (upper-case as in the raw files)
cols <- c(
  "NU_ANO", "ID_MATRICULA", "CPF_MASC", "CO_PESSOA_FISICA", "DT_NASCIMENTO", "NU_IDADE",
  "TP_SEXO", "TP_COR_RACA", "TP_NACIONALIDADE", "CO_UF_NASC",
  "CO_MUNICIPIO_NASC", "CO_UF_END", "CO_MUNICIPIO_END",
  "TP_ZONA_RESIDENCIAL", "IN_TRANSPORTE_PUBLICO",
  "TP_RESPONSAVEL_TRANSPORTE", "TP_ETAPA_ENSINO",
  "IN_REGULAR", "ID_TURMA", "CO_ENTIDADE"
)

# Build the year-keyed list in one line
cbyy <- setNames(rep(list(cols), length(years)), years)

# Matching Columns with different names (No need for this data)
rbyy <- list()

# Test Year
yr <- 2008

# Importing Function
import_clean_cb <- function(yr) {
  yr_chr   <- as.character(yr)
  desired  <- cbyy[[yr_chr]]
  rename_v <- rbyy[[yr_chr]]
  
  start <- Sys.time()
  path_in  <- fs::path(input,  glue::glue("censo_{yr}.csv"))
  path_out <- fs::path(output, glue::glue("cb_{yr}_mat.csv"))
  
  message("Reading ", yr)
  
  # Reading Data
  df <- vroom(file = path_in,
              delim = ";",
              na = c("", "NA", "NULL"),
              progress = FALSE,
              col_select = desired
              ,n_max = 1 # Testing with one line of data first, comment if test completed
              )
  
  # Renaming columns for year to year consistency
  if (!is.null(rename_v)) {
    rename_pairs <- setNames(names(rename_v), rename_v)  # new = old
    df <- dplyr::rename(df, !!!rename_pairs)
  }
  
  # Lowercase columns names
  df <- setNames(df, tolower(names(df)))
  
  # Adjusting Strings
  clean_names_pt <- function(x) {
    x |>
      stringi::stri_trans_general("Latin-ASCII") |>  # drop ´, ˜, ç, ê…
      str_replace_all("'", " ") |>                  # '  →  space
      janitor::make_clean_names(case = "snake")     # final snake_case
  }
  
  names(df) <- clean_names_pt(names(df))
    
    
  # Checking Year column, and creating it if doesn't exists
  if (!"year" %in% names(df)) df <- mutate(df, ano = yr, .before = 1L)
  
  # Filter only 9th Grade and High School
  STEP_HS <- c(11,41, 25:29)   # High School Level Students only
  df <- dplyr::filter(df, tp_etapa_ensino %in% STEP_HS)
  
  # Writing the clean .csv
  vroom::vroom_write(df, output, delim = ";", progress = FALSE)
  
  message("Completed ", yr, "!",
          round(difftime(Sys.time(), start, "secs"), 1), " s")
  invisible(path_out)
}

purrr::walk(years, import_clean_cb)
