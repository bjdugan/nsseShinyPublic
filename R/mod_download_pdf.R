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
#'@param filter_inputs Filter selections etc.
#'
#' @noRd
# include reactive data, plot, etc.
mod_download_pdf_server <- function(id, summarized_data, filter_inputs){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # helper fun to copy qmd and typst templates
    copy_dir_to_temp <- function(source_dir, temp_dir) {
      if (!dir.exists(source_dir)) return(invisible(NULL))

      files <- list.files(source_dir, full.names = TRUE, recursive = TRUE)
      if (length(files) == 0) return(invisible(NULL))

      # Get relative paths
      rel_paths <- sub(paste0(source_dir, "/"), "", files)
      dest_paths <- file.path(temp_dir, rel_paths)

      # Create all necessary subdirectories
      lapply(unique(dirname(dest_paths)),
             \(d) if (!dir.exists(d)) dir.create(d, recursive = TRUE))

      # Copy all files at once
      file.copy(files, dest_paths, overwrite = TRUE)
    }

    output$download_pdf <- downloadHandler(
      filename = function() {
        paste0("report_", format(Sys.Date(), "%Y-%m-%d"), ".pdf")
      },
      content = function(file) {
        # set paths and temp dir
        temp_dir <- tempdir()

        # for local dev vs. production; this will copy all files in subdirs
        if (interactive()) {
          md_dir <- "./inst/md"
          typst_dir <- "./inst/typst"
        } else {
          md_dir <- system.file("md", package = "nsseShiny")
          typst_dir <- system.file("typst", package = "nsseShiny")
        }

        # copy templates to temp directory
        copy_dir_to_temp(md_dir, temp_dir)
        copy_dir_to_temp(typst_dir, temp_dir)

        # render
        quarto::quarto_render(
          input = file.path(temp_dir, "report_template.qmd"),
          output_file = basename(file),
          # params for rmarkdown::render()
          execute_params = list(
            summarized_data = summarized_data(),
            inputs = list(
              unitid = filter_inputs$unitid_filter(),
              kpi_name = filter_inputs$kpi_name_filter(),
              irclass = filter_inputs$irclass_filter()
            ),
            endnotes = TRUE # generic endnotes page
            ),
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
