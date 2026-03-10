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
  instruments <- DBI::dbConnect(RSQLite::SQLite(), # db_path)
                           dbname = "./inst/app/db/instruments.db") # pre-install/dev
  on.exit(DBI::dbDisconnect(instruments))

  #x <- c("None", pull(distinct(tbl(instruments, "kpi_desc"), kpi_name)))
  # setting default to 1st, not "None"
  x <- pull(distinct(tbl(instruments, "kpi_desc"), kpi_name))

  return(x[!is.na(x)])

}
