##########################################################################
#             Project: Dissertation                                      #
#         Name: 40d_check_merge_duplicate                                #
#     Description: Counting Duplicates of students by Year               #
#       Author : Matheus N. Loureiro                                     #
##########################################################################


qc_out <- map_dfr(
  years,
  function(y) {
    path <- fs::path(input, glue("panel_{y}.csv"))
    
    # só o essencial
    df <- vroom(
      path,
      delim       = ",",
      col_select  = c(cpf_masc, nu_ano,
                      starts_with("score_"), ends_with("_cs_t1")),
      progress    = FALSE,
      show_col_types = FALSE
    )
    
    ## 1. Unmatched flag (no info on Higher Education)
    pct_missing_cs <- mean(is.na(df$sg_ies_cs_t1)) * 100
    
    ## 2. Duplicates
    dups_id_ano <- df %>% count(cpf_masc, nu_ano) %>% filter(n > 1) %>% nrow()
    
    ## 3. More than 1 school in t+1
    mult_school  <- df %>% count(id_estudante, nu_ano) %>% filter(n > 1) %>% nrow()
    
    ## 4. Valores fora de range em notas ENEM
    notas <- df %>% select(starts_with("score_")) %>% unlist()
    pct_notas_invalid <- mean(is.na(notas) | notas < 0 | notas > 1000) * 100
    pct_score_missing <- mean(is.na(notas)) * 100
    
    tibble(
      year                = y,
      pct_missing_cs_next = round(pct_missing_cs, 2),
      dup_key_rows        = dups_id_ano,
      mult_school_rows    = mult_school,
      pct_invalid_scores  = round(pct_notas_invalid, 2),
      pct_score_missing   = round(pct_score_missing, 2)
    )
  }
)

# Salva relatório
report <- fs::path(log_dir, "merge_qc_summary.csv")
vroom_write(qc_out, report, delim = ",", progress = FALSE)
print(qc_out)

message("📝 QC summary gravado em: ", report)