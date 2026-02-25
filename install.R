# to match rocker/verse:4.4 used in py-rocker-base
# look up the date that the Rocker image was created and put that
list.of.packages <- c(
  "remotes",
  "Hmisc",
  "jsonify",
  "sp",
  "MatrixModels",
  "SparseM",
  "dotCall64",
  "quantreg",
  "mcmc",
  "coda",
  "maps",
  "spam",
  "truncnorm",
  "statmod",
  "sp",
  "pROC",
  "pracma",
  "MCMCpack",
  "matrixStats",
  "FNN",
  "fields",
  "BayesLogit",
  "ape",
  "abind",
  'coda',
  'tidyverse',
  'MASS',
  'Matrix',
  'nnet',
  'rlang',
  'statmod',
  'truncnorm'
)
install.packages(
  list.of.packages,
  repos = "https://packagemanager.posit.co/cran/__linux__/noble/latest",
  dependencies = TRUE
)
remotes::install_github(
  'jonpeake/HMSC',
  dependencies = TRUE,
  repos = 'https://packagemanager.posit.co/cran/__linux__/noble/latest'
)
