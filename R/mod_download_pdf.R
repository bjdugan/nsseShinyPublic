#' download_pdf UI Function
#'
#' @description A shiny module to download a PDF report.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_download_pdf_ui <- function(id) {
  ns <- NS(id)
  tagList(
    downloadButton(ns("download_pdf"), "Download PDF Report")
  )
}

#' download_pdf Server Functions
#'
#'@param summarized_data Reactive expr for containing filtered data
#'
#' @noRd
# include reactive data, plot, etc.
mod_download_pdf_server <- function(id, summarized_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$download_pdf <- downloadHandler(
      filename = function() {
        paste0("report_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".pdf")
      },
      content = function(file) {
        # set paths and temp dir
        temp_dir <- tempdir()

        # for local dev vs. production
        if (interactive()) {
          template_path <- "./inst/md/report_template.qmd"
          child_path <- "./inst/md/footer.qmd"
        } else {
          template_path <- system.file("md", "report_template.qmd",
                                       package = "nsseShiny")
          child_path <- system.file("md", "footer.qmd",
                                    package = "nsseShiny")
        }

        # copy templates to temp directory to ensure child document is accessible
        temp_template <- file.path(temp_dir, "report_template.qmd")
        temp_child <- file.path(temp_dir, "footer.qmd")
        file.copy(template_path, temp_template, overwrite = TRUE)
        file.copy(child_path, temp_child, overwrite = TRUE)

        # render
        quarto::quarto_render(
          input = temp_template,
          output_file = basename(file),
          # params for rmarkdown::render()
          execute_params = list(
            summarized_data = summarized_data()
            ),
          #envir = new.env(parent = globalenv()) # only for rmd
        )
      },
      # guessed otherwise
      contentType = "pdf"
    )
  })
}

## To be copied in the UI
# mod_download_pdf_ui("download_pdf_1")

## To be copied in the server
# mod_download_pdf_server("download_pdf_1")
