#########################################################################
#             Project: Dissertation                                     #
#         Name: 10b_import_censo_basico_esc                             #
#     Description: Import and Treat Educational Census (School Level)   #
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
  "NU_ANO", "CO_ENTIDADE", "NO_ENTIDADE", "TP_SITUACAO_FUNCIONAMENTO", "TP_FALTANTE",
  "CO_REGIAO", "CO_MESORREGIAO", "CO_MICRORREGIAO", "CO_UF","CO_MUNICIPIO",
  "CO_DISTRITO", "TP_DEPENDENCIA","TP_LOCALIZACAO",
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
  path_out <- fs::path(output, glue::glue("cb_{yr}_sch.csv"))
  
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
  
  # Writing the clean .csv
  vroom::vroom_write(df, output, delim = ";", progress = FALSE)
  
  message("Completed ", yr, "!",
          round(difftime(Sys.time(), start, "secs"), 1), " s")
  invisible(path_out)
}

purrr::walk(years, import_clean_cb)
