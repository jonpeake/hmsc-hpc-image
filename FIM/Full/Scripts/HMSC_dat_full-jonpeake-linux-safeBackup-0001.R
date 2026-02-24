library(tidyverse)
load('samps_spat.RData')
hmsc_dat <- samps_spat %>%
  mutate(
    all_dat = pmap(list(bio,sample_info,geo), function(bio, samp, spat){
      dat <- cbind(bio, samp, spat) %>%
        select(Reference,
               starts_with("Bio_"),
               StartDepth,
               vis,
               Temperature,
               pH,
               Salinity,
               DissolvedO2,
               starts_with("Bottom_"),
               starts_with("Veg_"),
               starts_with("Bycatch_"),
               starts_with("Shore_"),
               Latitude,
               Longitude,
               Month,
               Year)
    }),
    predictors = map(all_dat,function(dat){
      
      hab <- select(dat,StartDepth,
                    vis,
                    Temperature,
                    pH,
                    Salinity,
                    DissolvedO2,
                    starts_with("Bottom_"),
                    starts_with("Veg_"),
                    starts_with("Bycatch_"),
                    starts_with("Shore_"))
    }),
    bio = map(all_dat, ~select(.,starts_with("Bio_"))),
    spat = map(all_dat, ~select(., Latitude, Longitude)),
    Month = map(all_dat, ~select(., Month)),
    Year = map(all_dat, ~select(., Year)),
    Reference = map(all_dat, ~select(., Reference))) %>%
  select(Reference,Bay,predictors,bio,spat,Month,Year) %>%
  unnest(cols = c(Reference,predictors, bio, spat, Month, Year)) %>%
  nest(predictors = c(StartDepth:DissolvedO2, 
                      starts_with("Bottom_"),
                      starts_with("Veg_"),
                      starts_with("Bycatch_"),
                      starts_with("Shore_")),
       bio = starts_with("Bio_"),
       spat = c(Latitude,Longitude),
       Month = Month,
       Year = Year,
       Bay = Bay,
       Reference = Reference)

save(hmsc_dat, file = "HMSCdat_full.RData")

