##### INIT #############
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) 
library(tidyverse)

##### LOAD & CHECK DATA #############
data_orig <- read.csv('compas-scores-two-years.csv') %>% as_tibble

# data_orig %>% glimpse
# data_orig$c_charge_desc %>% unique
colnames(data_orig)

data_orig %>% 
  filter(decile_score != decile_score.1) %>%
  glimpse

data_orig %>% 
  filter(priors_count != priors_count.1) %>%
  glimpse

data_orig %>% 
  filter(juv_fel_count + juv_misd_count + juv_other_count > priors_count) %>%
  glimpse

##### PREP DATA #############
data <- data_orig %>% 
  mutate(priors_count = priors_count.1) %>%
  select(sex, age, race, 
         juv_fel_count, juv_misd_count, juv_other_count, priors_count,
         c_charge_degree, 
         decile_score, is_recid,
         ) %>% 
  drop_na

data %>% glimpse

write_csv(data, 'compas_clustering_prep.csv')

##### PREP AS CLASSIFICATION #############
thres <- 5.5

data_classpb <- data %>% 
  mutate(pred_recid = ifelse(decile_score < thres, 0, 1)) %>% 
  mutate(TP = ifelse(pred_recid == 1 & is_recid == 1, 1, 0)) %>%
  mutate(TN = ifelse(pred_recid == 0 & is_recid == 0, 1, 0)) %>%
  mutate(FP = ifelse(pred_recid == 1 & is_recid == 0, 1, 0)) %>%
  mutate(FN = ifelse(pred_recid == 0 & is_recid == 1, 1, 0)) %>%
  glimpse

data_classpb %>% glimpse

write_csv(data_classpb, 'compas_clustering_classpb.csv')
