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
  "abind"
)
install.packages(list.of.packages)
remotes::install_git('https://github.com/jonpeake/HMSC')
