#import "@preview/touying:0.5.5": *
#import themes.university: *
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge


#let end-doc(bib-file: "bibliografia.yml", doc) = {
  bibliography(bib-file, title: "Referencias", style: "ieee")
  counter(heading).update(0)
  pagebreak(weak: true)
  doc
}