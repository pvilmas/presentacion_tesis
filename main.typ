#import "globals.typ": *
#import "@preview/numbly:0.1.0": numbly
#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Charla Tesis II],
    subtitle: [Paralelización de procesos de modelamiento de tráfico urbano por medio de la contenerización del software Simulation of Urban MObility (SUMO) para supercomputadores],
    author: [Pablo Villar Mascaró],
    date: datetime.today(),
    institution: [Universidad de Chile],
  ),
)

#set heading(numbering: none, outlined: true)

#title-slide()

#include "content.typ"

#pagebreak()
#show: end-doc