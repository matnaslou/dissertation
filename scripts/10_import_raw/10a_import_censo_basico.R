#########################################################
#             Project: Dissertation                     #
#         Name: 10a_import_censo_basico                 #
#     Description: Import and Treat Educational Census  #
#       Author : Matheus N. Loureiro                    #
#########################################################
# 1) Run Setup
source("scripts/00_setup/00_setup_environment.R")

# 2) Parameters
input <- "caminho_censo_basico_sedap"
output <- cleanroot
anos <- 2008:2024

# 3) Selected Columns
# Columns by Year
cbyy <- list(
  `2008` = c("id_escola", "cod_municipio", "uf", "dependencia_adm"),
  `2009` = c("id_escola", "cod_municipio", "uf",
             "dependencia_adm", "localizacao"),
  `2010` = c("id_escola", "cod_municipio", "uf",
             "dependencia_adm", "localizacao",
             "qtd_docentes", "qtd_matriculas_total"),
  # … continue até 2024
  `2024` = c("id_escola", "cod_municipio", "uf",
             "dependencia_adm", "localizacao",
             "rede", "qtd_docentes", "qtd_matriculas_total")
)

# Matching Columns with different names
rbyy <- list(
  `2008` = c(
    doc_tot        = "qtd_docentes",
    matric_tot     = "qtd_matriculas_total"
  ),     # old = new
  `2009` = c(doc_tot = "qtd_docentes"),
  # empty lists or NULL for anos que já vêm certos
  `2010` = NULL
)