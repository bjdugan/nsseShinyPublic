# create respondents
library(dplyr)
library(tidyr)
library(purrr)

load("data/institutions.rda")
load("data/responses.rda")


n_respondents <- 20000

# generate respondents
set.seed(123)
respondents <- tibble(
  id = 1:n_respondents,
  unitid = sample(institutions$unitid, n_respondents, replace = TRUE),
  IRsex = sample(c("Male", "Female"), size = n_respondents, prob = c(.4, .6),
                   replace = TRUE) |>
    factor(),
  IRclass = sample(c("First-year", "Senior"), size = n_respondents, prob = c(.6, .4),
                   replace = TRUE) |>
  factor(),
  IRenrollment = sample(c("Part-time", "Full-time"), size = n_respondents,
                        prob = c(.9, .1), replace = TRUE),
)
# each institution should have roughly same number: n_respondents / n_institutions
#count(respondents, unitid)

usethis::use_data(respondents, overwrite = TRUE)
