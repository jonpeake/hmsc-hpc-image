# Load packages
library(tidyverse)
library(SpatialEpi)
library(RhpcBLASctl)

# Run Number: 4

blas_set_num_threads(1)
# Read and process the data
hmsc_dat <- read_csv('Data/samples.csv') %>%
  mutate(coast = case_when(Bay %in% c('AP','CK','TB','CH') ~ 'Gulf',
                           .default = 'Atlantic')) %>%
  group_by(coast,Bay) %>%
  # Nest the biotic, sample, and geo data for each bay
  nest(sample_info = -c(coast,Bay,starts_with("Bio_"),Longitude,Latitude),
       bio = starts_with("Bio_"),
       geo = c(Longitude, Latitude)) %>%
  ungroup() %>%
  # Convert geo lat long to cartesian coordinates
  mutate(geo      = map(geo,~latlong2grid(.))) %>%
  mutate(
    # Prepare the data for HMSC
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
               Year) %>%
        mutate(temp_poly = Temperature^2, 
               sal_poly = Salinity^2) %>%
        drop_na(StartDepth:last_col())
      return(dat)
    }),
    # Isolate predictors
    predictors = map(all_dat,function(dat){
      
      hab <- select(dat,StartDepth,
                    vis,
                    Temperature,
                    temp_poly,
                    pH,
                    Salinity,
                    sal_poly,
                    DissolvedO2,
                    starts_with("Bottom_"),
                    starts_with("Veg_"),
                    starts_with("Bycatch_"),
                    starts_with("Shore_")) %>%
              select(where(~sum(.x != 0)/length(.x) > 0.005))
      
      return(hab)
    }),
    # Isolate biotic data
    bio = map(all_dat, ~select(.,starts_with("Bio_"))),
    # Isolate spatial data
    spat = map(all_dat, ~select(., Latitude, Longitude)),
    # Isolate temporal data
    Month = map(all_dat, ~select(., Month)),
    Year = map(all_dat, ~select(., Year)),
    # Isolate reference data
    Reference = map(all_dat, ~select(., Reference))) %>%
  select(Reference,coast,Bay,predictors,bio,spat,Month,Year) %>%
  unnest(cols = c(Reference,predictors,bio,spat,Month, Year, Bay)) %>%
  replace(is.na(.), 0)

spat_dat <- hmsc_dat %>%
  select(Latitude,Longitude)

spat_ord <- order(prcomp(spat_dat)$x[,1])

hmsc_dat <- hmsc_dat[spat_ord,] %>%
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

save(hmsc_dat, file = "Analyses/Processing/Coast/Data/HMSCdat_coast.RData")

