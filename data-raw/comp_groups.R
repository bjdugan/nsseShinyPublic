# assign a few at random, some based on state, and based on module
library(dplyr)
library(tidyr)
library(tibble)

load("data/institutions.rda")

comp_groups <- mutate(institutions,
                      g1 = replicate(nrow(institutions), institutions$unitid,
                                     simplify = FALSE) |>
                        lapply(sample, 6) |>
                        lapply(as_tibble),
                      g3 = replicate(nrow(institutions), institutions$unitid,
                                     simplify = FALSE) |>
                        lapply(as_tibble)) |>
  left_join(
    select(institutions, unitid, state_abb) |>
      nest(g2 = unitid, .by = state_abb),
    by = "state_abb"
  ) |>
  left_join(
    select(institutions, unitid, module1abb) |>
      nest(g4 = unitid, .by = module1abb),
    by = "module1abb") |>
  mutate(across(c(g1, g2, g3, g4), map, rename, unitid_comp = 1)) |>
  pivot_longer(g1:g4) |>
  unnest(value) |>
  filter(unitid != unitid_comp) |>
  select(unitid, comp = name, unitid_comp) |>
  mutate(comp = as.integer(substr(comp, 2, 2))) |>
  arrange(unitid, comp, unitid_comp)

usethis::use_data(comp_groups, overwrite = TRUE)
