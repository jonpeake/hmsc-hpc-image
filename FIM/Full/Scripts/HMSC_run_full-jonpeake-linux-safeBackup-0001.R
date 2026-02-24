library(Hmsc)
library(tidyverse)
load('HMSCdat_full.RData')

Sys.setenv("MKL_NUM_THREADS" = 1)



hmsc_mods <- hmsc_dat %>%
  mutate(
  ref = map(Reference, ~.$Reference),
  bay = map(Bay, ~.$Bay),
  geo_ind = map(spat, ~group_indices(group_by(., Latitude, Longitude))),
  hmsc_mod = pmap(list(geo_ind,bay,ref, predictors,spat,Year, Month,bio),function(i,j,u,v,w,x,y,z){

    date_YM <- as.matrix(x + y/12)
    spat <- as.matrix(cbind((w$Longitude), (w$Latitude)))
    rownames(spat) <- i
    rownames(date_YM) <- date_YM
  
    studyDesign <- data.frame(Loc = as.factor(i),Time = as.factor(date_YM),Bay = as.factor(j),Sample = as.factor(u))
    rownames(studyDesign) <- u
    rl1 <- HmscRandomLevel(units = studyDesign$Bay)
    rl2 <- HmscRandomLevel(sData = unique(date_YM))
    rl2 <- setPriors(rl2,nfMin = 8, nfMax = 8)
    rl3 <- HmscRandomLevel(sData = unique(spat), sMethod = "NNGP", nNeighbours = 20)
    rl3 <- setPriors(rl3,nfMin = 5, nfMax = 5)
    rl4 <- HmscRandomLevel(units = studyDesign$Sample)
    
    qq <- 0.1
    nc <- ncol(v)
    ns <- ncol(z)
    
    XSelect <- list()
    for (k in 1:nc){
      covGroup <- k
      spGroup <- 1:ns
      q <- rep(qq,max(spGroup))
      XSelect[[k]] <- list(covGroup = covGroup,
                           spGroup = spGroup,
                           q = q)
    }
    
    
    m <- Hmsc(Y = z, 
              XData = v, 
              XFormula = ~., 
              XSelect = XSelect,
              studyDesign = studyDesign,
              ranLevels = list(Bay = rl1, 
                               Time = rl2, 
                               Loc  = rl3,
                               Sample = rl4),
              distr = "lognormal poisson")
    
    m_datpar <- computeDataParameters(m)
    return(list(mod = m, datpar = m_datpar))}))

mod <- hmsc_mods$hmsc_mod[[1]]$mod
datpar <- hmsc_mods$hmsc_mod[[1]]$datpar
rm(list = setdiff(ls(),list('mod','datpar')))

nChains = 2
test.run = F
if (test.run){
  #with this option, the vignette runs fast but results are not reliable
  thin = 1
  samples = 40
  transient = 20
  verbose = 1
  npar = 2
} else {
  #with this option, the vignette evaluates slow but it reproduces the results of the
  #.pdf version
  thin = 100
  samples = 500
  transient = 50000
  verbose =1
  npar = 2
}

mod <- sampleMcmc(mod, 
                  thin = thin, 
                  samples = samples, 
                  transient = transient,
                  nChains = nChains,
                  nParallel = npar, 
                  verbose = verbose, 
                  dataParList = datpar,
                  updater = list(GammaEta=FALSE,
                                 Gamma2=FALSE),
                  useSocket = F)
warnings()
save(mod, file = "HMSC_full.RData")
