#install.packages(c("MASS", "tidyverse"))
library(MASS)
library(tidyverse)

## Find mean function by BIC
mean_fit <- function(samples_file, response_file){
  samples <- read_csv(samples_file)
  response <- read_csv(response_file)

  # Merge data for stepAIC function, remove id column
  data <- merge(samples, response, by = "id") %>% select(-1)
  
  #Avoid mistaking response variable name as function call in maximalModel
  colnames(data)[colnames(data)=="limnsw(cm)"] <- "limnsw"

  nobs = dim(data)[1]

  maximalModel <- lm(limnsw ~ ., data)
  fit <- stepAIC(maximalModel, scope = . ~ . ^ 3, direction = "both", k = log(nobs))

}

## Example
samplesFile <- "~/Alaska/lhs_samples_gcm.csv"
responseFile <- "~/Alaska/dgmsl_rcp_85_year_2100.csv"
dgmsl_85_2100 <- mean_fit(samplesFile, responseFile)
dgmsl_85_2100
