# subset of real institutions for which mock data will be generated
library(readxl)
library(dplyr)

institutions <- read_xlsx("C:/nsse/2025/nsse kiosk (2013-25).xlsx") |>
  filter(admin_year == 2025 & state_abb %in% c("PA", "TX", "NY") &
           module1abb %in% c("CWP", "AAD")
  ) |>
  select(unitid, admin_year, name_report, name_nick, state_abb, module1abb,
         module2abb)

usethis::use_data(institutions, overwrite = TRUE)
