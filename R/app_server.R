#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import dplyr
#' @import dbplyr
#' @import tidyr
#' @import DT
#' @import htmltools
#' @noRd
app_server <- function(input, output, session) {

  # db connection (added manually; contents of inst should move to root after isntallation)
  db_path <- system.file("app", "db", "instruments.db", package = "nsseShiny")
  instruments <- DBI::dbConnect(RSQLite::SQLite(), #db_path)
                           dbname = "./inst/app/db/instruments.db") # pre-install/dev

  # ensure connection closes when session ends
  onStop(function() {
    DBI::dbDisconnect(instruments)
  })

  # dynamic UI elements; loaded once (static) and supplied in selectInput directly
  # observe({
  #   kpi_name_filter_content <- c("None", pull(distinct(tbl(instruments, "kpi_desc"), kpi_name)))
  #   updateSelectInput(session, "kpi_name_filter", choices = kpi_name_filter_content)
  # })

  # reactive filtered data
  filtered_data <- reactive({

    # keep inst and selected comparison
    data <- filter(institutions, unitid == input$unitid_filter) |>
      left_join(comp_groups, by = "unitid") |>
      filter(comp == input$comp_filter) |>
      select(unitid, unitid_comp) |>
      pivot_longer(everything(), values_to = "unitid") |>
      distinct(unitid, .keep_all = TRUE) |>
      mutate(inst = if_else(name == "unitid", T, F),
             name = NULL) |>
      # join students
      left_join(respondents, by = "unitid")

    # apply other inst-level filters...

    # apply other student-level filters; defaults to FY, but need to trigger filter either way
    if (input$irclass_filter == "First-year") {
      data <- filter(data, IRclass == input$irclass_filter)
    } else {
      data <- filter(data, IRclass == input$irclass_filter)
    }

    if (input$irenrollment_filter != "All") {
      data <- filter(data, IRenrollment == input$irenrollment_filter)
    }

    if (input$irsex_filter != "All") {
      data <- filter(data, IRsex == input$irsex_filter)
    }

    # item groups
    if (input$kpi_name_filter != "None") {
      data <- filter(tbl(instruments, "kpi_desc"), kpi_name == input$kpi_name_filter) |>
        left_join(tbl(instruments, "kpis"), by = c("kpi", "kpi_group")) |>
        select(item) |>
        collect() |>
        left_join(
          left_join(data, responses, by = "id") |>
            select(inst, item, value),
          by = "item")
    }
  })

  # summarization, probably in separate functions

  # output
  # server=FALSE will allow DL of all data presented, not just first N rows
  output$table <- renderDT(server = FALSE, {
    # simple summarization for now
    DT::datatable(
      filtered_data() |>
      #data |> # local testing
        count(inst, item, value) |>
        # filter missing, also filter valid/user NA levels
        filter(!is.na(value)) |>
        mutate(p = n / sum(n) * 100, .by = c(inst, item)) |>
        pivot_wider(names_from = inst, values_from = c(n, p)) |>
        # add context; might benefit from view; also must accept correct instrument, yr
        left_join(
          tbl(instruments, "items_US") |>
            filter(yr == 25) |>
            select(item, label, response_set) |>
            collect(),
          by = "item") |>
        left_join(
          tbl(instruments, "response_options") |>
            select(response_set, value, response_option = label) |>
            collect(),
          by = c("response_set", "value")) |>
          select(label, item, response_option, value, n_TRUE, p_TRUE, n_FALSE,
                 p_FALSE),
      # options
      extensions = "Buttons", # for donwload etc.
      # can feed this with Question etc?
      caption = tags$caption("Table caption", style = "caption-side:top;"),
      options = list(
        # order matters for DOM options
        dom = 'frtipB',
        pageLength = 25,
        scrollX = TRUE,
        searchHighlight = TRUE,
        order = list(list(0, 'asc')),
        buttons = list(
          list(
            extend = "csv",
            text = "Download CSV",
            filename = paste0("NSSE_data_", Sys.Date()),
            exportOptions = list(modifier = list(page = "all"))
          )
        )
      ),
      filter = "none",
      # dynamically rename using input$... perhaps to filter comp_names table (TBD)
      colnames = c("Label", "Item", "Response Option", "Value", "Institution (n)",
                   "Institution (%)", "Comparison (n)", "Comparison (n)"),
      rownames = FALSE,
      # as way to allow banding headers, e.g. label-item
      # https://stackoverflow.com/questions/59354456/r-and-dt-can-you-add-row-subheadings-and-groups-to-a-datatable
      # extensions = RowGroup
      class = 'cell-border stripe'
    )
  })
}
