get_kpi_name_filter <- function() {
  #' get_kpi_name_filter
  #'
  #' @description For populating selectInput list with ~static~ content
  #'
  #' @return kpi_name
  #'
  #' @noRd

  # db connection (added manually; contents of inst should move to root after isntallation)
  db_path <- system.file("app", "db", "instruments.db", package = "nsseShiny")
  instruments <- DBI::dbConnect(RSQLite::SQLite(),  db_path)
                           #dbname = "./inst/app/db/instruments.db") # pre-install/dev
  on.exit(DBI::dbDisconnect(instruments))

  # for flat select input list, return vector
  x <- pull(distinct(tbl(instruments, "kpi_desc"), kpi_name))

  # # for nested list, return list: list(l1 = c(l2, l2), l1 = c(l2, l2))
  # left_join(
  #   tbl(instruments, "kpi_desc"),
  #   tbl(instruments, "instrument_names"),
  #   by = "instrument") |>
  #   left_join(tbl(instruments, "instrument_tracking"), by = "instrument") |>
  #   distinct(kpi_name, .keep_all = TRUE) |>
  #   collect() |>
  #   # factor(instrument) so that order is core, con, mod
  #   mutate(
  #     type = factor(type, levels = c("core", "mod", "con")),
  #     # have to adjust since we kept name but changed abb...fix? Where?
  #     instrument_name = if_else(instrument == "ADV",
  #                               "Academic Adivsing (old)",
  #                               instrument_name)) |>
  #   arrange(type, instrument) |>
  #   mutate(instrument_name = forcats::as_factor(instrument_name)) |>
  #   pull(instrument_name)
  #   split(~instrument) |>
  #   lapply(pull, kpi_name)
  return(x[!is.na(x)])

}


