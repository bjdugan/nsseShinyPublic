#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import dplyr
#' @import dbplyr
#' @import tidyr
#' @import htmltools
#' @import ggplot2
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

    # item groups; note None is omitted now...
    if (input$kpi_name_filter != "None") {
      data <- filter(tbl(instruments, "kpi_desc"),
                     kpi_name == input$kpi_name_filter) |>
        left_join(tbl(instruments, "kpis"), by = c("kpi", "kpi_group")) |>
        select(item) |>
        collect() |>
        left_join(
          left_join(data, responses, by = "id") |>
            select(inst, item, value),
          by = "item")
    }
  })
  # for table displays
  summarized_data <- reactive({
    filtered_data() |>
      #data |> # local testing
      count(inst, item, value) |>
      # filter missing, also filter valid/user NA levels
      filter(!is.na(value)) |>
      mutate(p = n / sum(n), .by = c(inst, item)) |>
      pivot_wider(names_from = inst, values_from = c(n, p)) |>
      # add context; might benefit from view;
      #  also must accept correct instrument, yr
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
      select(label, item, response_option, value,
             `Institution (n)` = n_TRUE, `Institution (%)` = p_TRUE,
             `Comparison (n)` = n_FALSE, `Comparison (%)` = p_FALSE ) |>
      rename_with(stringr::str_to_title, .cols = 1:4)
  })

  plotted_data <- reactive({
    filtered_data() |>
      #data |> #local testing
      count(inst, item, value) |>
      filter(!is.na(value)) |>
      mutate(p = n / sum(n), .by = c(inst, item)) |>
      left_join(
        tbl(instruments, "items_US") |>
          filter(yr == 25) |>
          select(item, label, response_set, question_order) |>
          collect(),
        by = "item") |>
      left_join(
        tbl(instruments, "response_options") |>
          select(response_set, value, response_option = label, coded_as_missing) |>
          collect(),
        by = c("response_set", "value")) |>
      left_join(
        tbl(instruments, "questions_US") |>
          filter(yr == 25) |>
          select(question_order, question) |>
          collect(),
        by = "question_order"
      ) |>
      filter(coded_as_missing == 0) |>
      filter(value %in% c(max(value), max(value) - 1)) |>
      mutate(
        label = factor(item,
                       labels = paste0(unique(label), " [", unique(item), "]") |>
                         stringr::str_wrap(40),
        )) |>
      summarize(
        p = sum(p) * 100,
        response_option = paste0(response_option, collapse = "/"),
        .by = c("inst", "question", "label")
      ) |>
      mutate(xbegin = min(p), xend = max(p), .by = label) |>
      ggplot(aes(x = p, y = forcats::fct_rev(label), color = inst)) +
      geom_segment(aes(x = xbegin, xend = xend),
                   color = "darkgrey",
                   linewidth = 1.5) +
      geom_point(size = 6) +
      theme_minimal() +
      theme(legend.position = "bottom",
            plot.title.position = "plot",
            legend.title = element_blank(),
            text = element_text(size = 22)
      ) +
      scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
      labs(
        title = "<Question>",
        subtitle = "<Response option list>",
        x = paste("Percentage", "<response option n-1/response option n>"),
        y = NULL
      )
  })


  # modules ####
  # create a list of applied filters/inputs to pass to qmd/pdf
  filter_inputs <- list(
    unitid_filter = reactive({ input$unitid_filter }),
    kpi_name_filter = reactive({ input$kpi_name_filter }),
    irclass_filter = reactive({ input$irclass_filter })
  )

  mod_download_pdf_server("download_pdf_1", summarized_data, filter_inputs)

  mod_download_plot_server("download_plot_1", plotted_data)

  # output ####
  #  output$plot <- renderPlot({ plotted_data() })

  # server=FALSE will allow DL of all data presented, not just first N rows
  # > split the summarization function and datatable function into modules
  output$table <- DT::renderDT(server = FALSE, {
    DT::datatable(
      summarized_data(),
      # options
      extensions = "Buttons", # for download etc.
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
      # colnames = c("Label", "Item", "Response Option", "Value", "Institution (n)",
      #              "Institution (%)", "Comparison (n)", "Comparison (%)"),
      rownames = FALSE,
      # as way to allow banding headers, e.g. label-item
      # https://stackoverflow.com/questions/59354456/r-and-dt-can-you-add-row-subheadings-and-groups-to-a-datatable
      # extensions = RowGroup
      class = 'cell-border stripe'
    ) |>
      DT::formatPercentage(c("Institution (%)", "Comparison (%)"), 1)
  })

  # text elements for UI ####
  # page title
  output$page_title <- renderText({
    paste("NSSE2X:", # could add year dynamically etc.
          filter(institutions,
                 unitid == input$unitid_filter)$name_report
    )
  })
  # main content panel title: selected topic
  output$panel_title <- renderText({
    filter(tbl(instruments, "kpi_desc"),
           kpi_name == input$kpi_name_filter) |>
      pull(kpi_name)
  })
  # description
  output$panel_kpi_desc <- renderText({
    filter(tbl(instruments, "kpi_desc"),
           kpi_name == input$kpi_name_filter) |>
      pull(description)
  })


}
