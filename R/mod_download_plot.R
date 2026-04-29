#' download_plot UI Function
#'
#' @description A shiny Module to download the displayed plot.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_download_plot_ui <- function(id) {
  ns <- NS(id)
  card(
    card_header("Plot card header"),
    card_body(
      plotOutput(ns("plot")) # plot itself
    ),
    card_footer(
      downloadButton(ns("download_plot"), "Download plot")
    )
  )
}

#' download_plot Server Functions
#'
#' @noRd
mod_download_plot_server <- function(id, plotted_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # create or accept plot as argument
    # curently in app_server, probably better as reactive function
    output$plot <- renderPlot({ plotted_data() })

    # download handler
    output$download_plot <- downloadHandler(
      filename = paset0("plot", Sys.Date(), ".png"),

      content = function(file){
        ggsave(
          file,
          plot = plotted_data(),
          width = 8,
          height = 6,
          dpi = 300,
          bg = "white"
        )
      }
    )
  })
}

## To be copied in the UI
# mod_download_plot_ui("download_plot_1")

## To be copied in the server
# mod_download_plot_server("download_plot_1")
