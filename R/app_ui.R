#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import dplyr
#' @import htmltools
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    # sidebar
    page_sidebar(
      title = uiOutput("page_title"),
      window_title = "NSSE Report",
      sidebar = sidebar(
        width = 300,

        # item/kpi/topical filters
        # this will need to be limited to available instrument(s)
        # also recall UI is static, can't talk to database; hence util fxn
        card_header("Topical filters"),
        selectInput(
          "kpi_name_filter",
          "Topic:",
          choices = get_kpi_name_filter(),
          selected = "Collaborative Learning",
        ),
        # institutional filters
        card_header("Institutional filters"),
        selectInput(
          "unitid_filter",
          "Unitid:",
          choices = unique(institutions$unitid),
          selected = unique(institutions$unitid)[1]
        ),
        selectInput(
          "comp_filter",
          "Comparison group:",
          choices = 1:5,
          selected = 1
        ),
        # student-level filters
        card_header("Student filters"),
        selectInput(
          "irclass_filter",
          "Class level",
          choices = unique(respondents$IRclass),
          selected = "First-year"
        ),
        # other action buttons
        actionButton("reset_filters", "Reset filters",
                     class = "btn_secondary w-100"
        )
      ),

      # main panel content
      navset_card_tab(
        nav_panel(
          title = uiOutput("panel_title"),

          # text content: context, links, etc.
          p("**Generic statement, boilerplate text, etc. followed by dynamic content.**"),
          uiOutput("panel_kpi_desc"),
          p("**Links to other reports etc.**"),

          # dataviz and tables placeholder
          plotOutput("plot"),
          DT::DTOutput("table"),
          # other
          HTML("<small>links placeholder (feedback, support, etc.</small>")
        ),
        nav_panel("Read Me",
                  # htmltools, alternative to ~tedious formatting above.
                  h2("Please be aware!"),
                  p("All survey response and student data presented here are fabricated.
                  Institutions were selected arbitrarily as examples.
                  No inferences should be made from these data.
                  This application serves only as a prototype.
                  Please direct any feedback or hatemail to Brendan (bjdugan@iu.edu)")
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "nsseShiny"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}


