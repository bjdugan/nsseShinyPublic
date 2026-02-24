# create random responses
library(dplyr)
library(tidyr)
library(odbc)
library(DBI)
library(purrr)

instruments <- dbConnect(RSQLite::SQLite(),
                         dbname = "../instruments/instruments.db")

load("data/institutions.rda")

n_respondents <- 20000

# generate responses for NSSE, CWP and AAD (example)
responses <- list("items_US", "items_CWP", "items_AAD") |>
  map(\(x) tbl(instruments, x)) |>
  map(filter, yr == 25 & text_input == 0) |>
  map(left_join, tbl(instruments, "response_options"),
            by = "response_set") |>
  map(select, item, value) |>
  map(collect) |>
  bind_rows() |>
  (\(x) replicate(n_respondents, x, simplify = FALSE))() |>
  # randomly select a response
  map(slice_sample, by = item) |>
  # create a small number of non-respondents: 10%
  # map_at(sample(1:n_respondents, n_respondents * .1, replace = FALSE),
  #        mutate, value = NA_integer_) %>%
  # add a little bit of itemwise missing values
  map(mutate,
      x = sample(c(FALSE, TRUE), n(), replace = TRUE, prob = c(.1, .9)),
      value = if_else(x, value, NA_integer_)) |>
  # assign id from list position/index
  imap(mutate) |>
  map(select, id = last_col(), item, value) |>
  bind_rows()

usethis::use_data(responses, overwrite = TRUE)
