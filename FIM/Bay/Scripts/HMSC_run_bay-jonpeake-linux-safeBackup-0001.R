library(Hmsc)
library(tidyverse)
load('HMSCdat_bay.RData')

bay <- c('AP','CK','TB','CH','JX','IR','TQ')
Sys.setenv("MKL_NUM_THREADS" = 1)

nChains = 4
test.run = F
if (test.run){
  #with this option, the vignette runs fast but results are not reliable
  thin = 1
  samples = 5
  transient = 10
  verbose = 1
  npar = 2
} else {
  #with this option, the vignette evaluates slow but it reproduces the results of the
  #.pdf version
  thin = 100
  samples = 500
  transient = thin*samples
  verbose =1
  npar = 4
}

hmsc_mods <- hmsc_dat %>%
  filter(Bay %in% bay) %>%
  mutate(
    ref = map(Reference, ~.$Reference),
    geo_ind = map(spat, ~group_indices(group_by(., Latitude, Longitude))),
    hmsc_mod = pmap(list(geo_ind,ref, predictors,spat,Year, Month,bio),function(i,u,v,w,x,y,z){
      z <- z %>%
        select(where(~sum(.x != 0)/length(.x) > 0.005))
      
      date_YM <- as.matrix(x + y/12)
      spat <- as.matrix(cbind((w$Longitude), (w$Latitude)))
      rownames(spat) <- i
      rownames(date_YM) <- date_YM
      
      studyDesign <- data.frame(Loc = as.factor(i),Year = as.factor(as.matrix(x)),Time = as.factor(date_YM),Sample = as.factor(u))
      rownames(studyDesign) <- u
      rl1 <- HmscRandomLevel(units = studyDesign$Year)
      rl2 <- HmscRandomLevel(sData = unique(date_YM))
      rl2 <- setPriors(rl2,nfMin = 1, nfMax = 8)
      rl3 <- HmscRandomLevel(sData = unique(spat), sMethod = "NNGP", nNeighbours = 20)
      rl3 <- setPriors(rl3,nfMin = 1, nfMax = 8)
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
                ranLevels = list(Year = rl1,
                                 Time = rl2, 
                                 Loc  = rl3,
                                 Sample = rl4),
                distr = "lognormal poisson")
      
      m_datpar <- computeDataParameters(m)
      return(list(mod = m, datpar = m_datpar))}),
    hmsc_mod = walk2(hmsc_mod,Bay, function(dat,bay){
      gc()
      mod <- dat$mod
      datpar <- dat$datpar
      print(paste("Starting MCMC Sampling:",bay))
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
      save(mod, file = paste0('../Results/Bays/Bay Data/mod',bay,'.RData'))
      gc()
    })
  )
