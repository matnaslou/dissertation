##########################################################################
#             Project: Dissertation                                      #
#         Name: 10e_import_enem                                          #
#     Description: Import and Treat SAT (ENEM)                           #
#       Author : Matheus N. Loureiro                                     #
##########################################################################
# 1) Run Setup
source("scripts/00_setup/00_setup_environment.R")

# 2) Parameters
input <- "caminho_enem_sedap"
output <- cleanroot
years <- 2009:2023

# 3) Selected Columns
# Build the year-keyed list in one line
# Columns by Year
cbyy <- list(
  `2009` = c("NU_ANO","CPF_MASC","ST_CONCLUSAO","CO_ESCOLA","IN_PRESENCA_CN",
             "IN_PRESENCA_CH","IN_PRESENCA_LC","IN_PRESENCA_MT","NOTA_CN","NOTA_CH","NOTA_LC",
             "NOTA_MT","NU_NOTA_REDACAO"),
  `2010` = c("NU_ANO","CPF_MASC","ST_CONCLUSAO","CO_ESCOLA","IN_PRESENCA_CN",
             "IN_PRESENCA_CH","IN_PRESENCA_LC","IN_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"),
  `2011` = c("NU_ANO","CPF_MASC","ST_CONCLUSAO","PK_CO_ENTIDADE","IN_PRESENCA_CN",
             "IN_PRESENCA_CH","IN_PRESENCA_LC","IN_PRESENCA_MT","NU_NT_CN","NU_NT_CH","NU_NT_LC",
             "NU_NT_MT","NU_NOTA_REDACAO"),
  `2012` = c("NU_ANO","CPF_MASC","ST_CONCLUSAO","PK_CO_ENTIDADE","IN_PRESENCA_CN",
             "IN_PRESENCA_CH","IN_PRESENCA_LC","IN_PRESENCA_MT","NU_NT_CN","NU_NT_CH","NU_NT_LC",
             "NU_NT_MT","NU_NOTA_REDACAO"),
  `2013` = c("NU_ANO","CPF_MASC","ST_CONCLUSAO","CO_ESCOLA","IN_PRESENCA_CN",
             "IN_PRESENCA_CH","IN_PRESENCA_LC","IN_PRESENCA_MT","NOTA_CN","NOTA_CH","NOTA_LC",
             "NOTA_MT","NU_NOTA_REDACAO"), 
  `2014` = c("NU_ANO","CPF_MASC","ST_CONCLUSAO","CO_ESCOLA","IN_PRESENCA_CN",
             "IN_PRESENCA_CH","IN_PRESENCA_LC","IN_PRESENCA_MT","NOTA_CN","NOTA_CH","NOTA_LC",
             "NOTA_MT","NU_NOTA_REDACAO"), 
  `2015` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2016` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2017` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2018` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2019` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2020` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2021` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2022` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO"), 
  `2023` = c("NU_ANO","CPF_MASC","TP_ST_CONCLUSAO","CO_ESCOLA","TP_PRESENCA_CN",
             "TP_PRESENCA_CH","TP_PRESENCA_LC","TP_PRESENCA_MT","NU_NOTA_CN","NU_NOTA_CH","NU_NOTA_LC",
             "NU_NOTA_MT","NU_NOTA_REDACAO")
)

# Matching Columns with different names
rbyy <- list(
  `2009` = c(
    CO_ESCOLA     = "co_entidade",
    NOTA_MT        = "score_mt",
    NOTA_CN        = "score_cn",
    NOTA_CH        = "score_ch",
    NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),     # old = new
  `2010` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2011` = c(
    PK_CO_ENTIDADE     = "co_entidade",
    NU_NT_MT        = "score_mt",
    NU_NT_CN        = "score_cn",
    NU_NT_CH        = "score_ch",
    NU_NT_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2012` = c(
    PK_CO_ENTIDADE     = "co_entidade",
    NU_NT_MT        = "score_mt",
    NU_NT_CN        = "score_cn",
    NU_NT_CH        = "score_ch",
    NU_NT_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2013` = c(
    CO_ESCOLA     = "co_entidade",
    NOTA_MT        = "score_mt",
    NOTA_CN        = "score_cn",
    NOTA_CH        = "score_ch",
    NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),     # old = new
  `2014` = c(
    CO_ESCOLA     = "co_entidade",
    NOTA_MT        = "score_mt",
    NOTA_CN        = "score_cn",
    NOTA_CH        = "score_ch",
    NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),     # old = new
  `2015` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2016` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),  
  `2017` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2018` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2019` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2020` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2021` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2022` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
  `2023` = c(
    CO_ESCOLA     = "co_entidade",
    NU_NOTA_MT        = "score_mt",
    NU_NOTA_CN        = "score_cn",
    NU_NOTA_CH        = "score_ch",
    NU_NOTA_LC        = "score_lc",
    NU_NOTA_REDACAO       = "score_red"
  ),
)


# Test Year
yr <- 2009

# Importing Function
import_clean_enem <- function(yr) {
  yr_chr   <- as.character(yr)
  desired  <- cbyy[[yr_chr]]
  rename_v <- rbyy[[yr_chr]]
  
  start <- Sys.time()
  path_in  <- fs::path(input,  glue::glue("enem_{yr}.csv"))
  path_out <- fs::path(output, glue::glue("enem_{yr}.csv"))
  
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

purrr::walk(years, import_clean_enem)
