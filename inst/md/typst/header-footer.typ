#let set-header-footer() = {
  set page(
	// note nesting params$inputs$unitid 
    footer: context [
      align(left)[
        text(size: 8pt)[
          "Report ID:" + metadata("params").inputs.unitid
        ]
      ]
      align(center)[
        text(size: 8pt)[
          counter(page)
        ]
      ]
      align(right)[
        text(size: 8pt)[
          "Publilshed " + datetime.today().display()
        ]
      ]
    ]
  )
}
