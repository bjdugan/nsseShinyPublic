// reusable components
#let callout(kind, body) = block(
  inset: 12pt,
  radius: 4pt,
  fill: if kind == "note" { rgb("#F0F4F8") }
        else if kind == "warning" { rgb("#FFF4E5") }
        else { rgb("#F8F9FA") },
  body
)