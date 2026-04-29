//import and call styling etc.
#import "styles.typ": *
#import "header-footer.typ": *
#import "components.typ": *

// this overrides anything in _quarto.yml
#set page(
	paper: "letter",
	margin: (top: .5in, bottom: .5in, left: .5in, right: .5in)
)

#show: document => {
  set-text-styles()
  set-header-footer()

  document
}
