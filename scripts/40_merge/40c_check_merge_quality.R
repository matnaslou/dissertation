##########################################################################
#             Project: Dissertation                                      #
#         Name: 40c_check_merge_duplicate                                #
#     Description: Counting Duplicates of students by Year               #
#       Author : Matheus N. Loureiro                                     #
##########################################################################

# 1) Run Setup
source("scripts/00_setup/00_setup_environment.R") 

# 2) Parameters
input <- cleanroot
output <-  str_c(cleanroot, "/panels")
log_dir <- str_c("outputs")
years <- 2009:2023

# Function for reporting Duplicates
dup_report <- map_dfr(
  years,
  function(y) {
    path <- fs::path(input, glue("panel_{y}.csv"))
    
    df <- vroom(
      file        = path,
      delim       = ";",
      col_select  = c(cpf_masc, nu_ano),
      show_col_types = FALSE,
      progress    = FALSE
    )
    
    out <- df %>%
      count(cpf_masc, nu_ano, name = "n") %>%
      filter(n > 1) %>%
      summarise(
        year         = y,
        dup_rows     = n(),
        worst_dups   = max(n)
      )
    
    # Messaging
    if (out$dup_rows > 0) {
      message("Ano ", y, " tem ", out$dup_rows,
              " combinações duplicadas (máx ", out$worst_dups, ")")
    } else {
      message("✓ ", y, " sem duplicatas.")
    }
    
    out
  }
)

# Saving Report
report_path <- fs::path(log_dir, "40c_dup_report.csv")
vroom_write(dup_report, report_path, delim = ";", progress = FALSE)

message("\n Relatório salvo em: ", report_path)