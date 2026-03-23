#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}

# local testing
# devtools::load_all(); run_app()
# load("data/comp_groups.rda")
# load("data/institutions.rda")
# load("data/respondents.rda")
# load("data/responses.rda")
# instruments <- DBI::dbConnect(RSQLite::SQLite(), #db_path)
#                               dbname = "./inst/app/db/instruments.db")
#
# input <- list(
#   "unitid_filter" = unique(institutions$unitid)[1],
#   "comp_filter" = 1,
#   "irclass_filter" = "First-year",
#   "kpi_name_filter" = "Collaborative Learning"
# )
#
# data <- filter(institutions, unitid == input$unitid_filter) |>
#   left_join(comp_groups, by = "unitid") |>
#   filter(comp == input$comp_filter) |>
#   select(unitid, unitid_comp) |>
#   pivot_longer(everything(), values_to = "unitid") |>
#   distinct(unitid, .keep_all = TRUE) |>
#   mutate(inst = if_else(name == "unitid", T, F),
#          name = NULL) |>
#   # join students
#   left_join(respondents, by = "unitid") |>
#   filter(IRclass == input$irclass_filter)
#
# data <- filter(tbl(instruments, "kpi_desc"),
#                kpi_name == input$kpi_name_filter) |>
#   left_join(tbl(instruments, "kpis"), by = c("kpi", "kpi_group")) |>
#   select(item) |>
#   collect() |>
#   left_join(
#     left_join(data, responses, by = "id") |>
#       select(inst, item, value),
#     by = "item")

