#install.packages(c("MASS", "tidyverse"))
library(MASS)
library(tidyverse)

## Find mean function by BIC, test up to 3rd order interactions
## Works for any RCP x Year combination in dgmsl_csv
mean_fit <- function(rcp, year) {
  rcpConvert <- as.character(rcp) %>% str_remove("[.]")
  samplesFile <- "lhs_samples_gcm.csv"
  responseFile <- paste0("dgmsl_rcp_", rcpConvert, "_year_", as.character(year), ".csv")
  
  samples <- read_csv(samplesFile, col_types = cols())
  response <- read_csv(responseFile, col_types = cols())

  # Merge data for stepAIC function, remove id column
  data <- merge(samples, response, by = "id") %>% dplyr::select(-1)
  
  #Avoid mistaking response variable name as function call in maximalModel
  colnames(data)[colnames(data)=="limnsw(cm)"] <- "limnsw"

  nobs = dim(data)[1]

  maximalModel <- lm(limnsw ~ ., data)
  fit <- stepAIC(maximalModel, scope = . ~ . ^ 3, direction = "both", k = log(nobs), trace = FALSE)

  header <- paste0("RCP ", rcp, " YEAR ", year)
  return(list(params = header, model = fit))
}

## Example: Loop over range of years and RCPs
setwd("~/../Downloads")
for (rcp in c(2.6, 4.5, 8.5)) {
  for (year in 2019:2022) {
    fun <- mean_fit(rcp, year)
    print(fun)
  }
}