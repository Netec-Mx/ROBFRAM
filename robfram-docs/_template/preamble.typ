// Preámbulo inyectado en cada PDF de guía vía `pandoc --include-in-header`.
// Define estilos de marca y helpers de diagramas didácticos nativos en Typst
// (sin dependencias externas: nada de Chromium/mermaid-cli).

#let color-marca = rgb("#E30613")
#let color-gris = rgb("#4D4D4D")
#let color-caja = rgb("#F2F2F2")

#set text(font: "Liberation Sans", size: 10.5pt, lang: "es")
#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, x: 2cm),
  footer: context [
    #set text(size: 8pt, fill: color-gris)
    #line(length: 100%, stroke: 0.4pt + gray)
    #v(2pt)
    #align(center)[Robot Framework y Automatización de Pruebas — Netec · Página #counter(page).display()]
  ],
)

// --- Logo de portada, centrado, usado al inicio de cada práctica ---
#let logo-portada(ruta) = align(center)[#image(ruta, width: 3.2cm) #v(0.4cm)]

#show heading.where(level: 1): it => {
  set text(size: 16pt, fill: color-marca, weight: "bold")
  v(0.6em)
  it.body
  v(0.2em)
  line(length: 100%, stroke: 1.2pt + color-marca)
  v(0.4em)
}
#show heading.where(level: 2): it => {
  set text(size: 13pt, fill: color-gris, weight: "bold")
  v(0.5em)
  it.body
  v(0.2em)
}

// --- Diagrama de flujo horizontal: lista de pasos -> cajas unidas por flechas ---
// Uso: #flujo(("Paso 1", "Paso 2", "Paso 3"))
#let flujo(pasos) = block(width: 100%, above: 1em, below: 1em)[
  #align(center)[
    #stack(
      dir: ltr,
      spacing: 0pt,
      ..pasos.enumerate().map(((i, paso)) => {
        let caja = box(
          fill: color-caja,
          stroke: 1pt + color-gris,
          radius: 3pt,
          inset: 8pt,
          align(center, text(size: 9pt, paso)),
        )
        if i == 0 { caja } else { stack(dir: ltr, spacing: 4pt, text(size: 12pt, fill: color-marca)[→], caja) }
      })
    )
  ]
]

// --- Diagrama de flujo vertical: para procesos con más pasos ---
#let flujo-vertical(pasos) = block(width: 100%, above: 1em, below: 1em)[
  #align(center)[
    #stack(
      dir: ttb,
      spacing: 4pt,
      ..pasos.enumerate().map(((i, paso)) => {
        let caja = box(
          fill: color-caja,
          stroke: 1pt + color-gris,
          radius: 3pt,
          inset: 8pt,
          align(center, text(size: 9.5pt, paso)),
        )
        if i == 0 { caja } else { stack(dir: ttb, spacing: 2pt, text(size: 12pt, fill: color-marca)[↓], caja) }
      })
    )
  ]
]

// --- Opciones/alternativas (sin flecha de secuencia): para decisiones,
// no procesos. Uso: #opciones(("Opción A", "Opción B", "Opción C"))
#let opciones(items) = block(width: 100%, above: 1em, below: 1em)[
  #align(center)[
    #stack(
      dir: ltr,
      spacing: 10pt,
      ..items.map(item => box(
        fill: color-caja,
        stroke: 1pt + color-gris,
        radius: 3pt,
        inset: 8pt,
        align(center, text(size: 9pt, item)),
      ))
    )
  ]
]

// --- Comparación de dos columnas (ej. Pruebas vs RPA) ---
// Uso: #comparacion(titulo-a: "Pruebas", items-a: (...), titulo-b: "RPA", items-b: (...))
#let comparacion(titulo-a: "", items-a: (), titulo-b: "", items-b: ()) = block(width: 100%, above: 1em, below: 1em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    block(fill: rgb("#E7F3FE"), stroke: 1pt + rgb("#1A73E8"), radius: 4pt, inset: 10pt, width: 100%)[
      *#titulo-a*
      #for item in items-a [ \u{2022} #item \ ]
    ],
    block(fill: rgb("#FFF4E5"), stroke: 1pt + rgb("#E69500"), radius: 4pt, inset: 10pt, width: 100%)[
      *#titulo-b*
      #for item in items-b [ \u{2022} #item \ ]
    ],
  )
]

// --- Cajas de nota / tip, estilo Admonition ---
#let nota(titulo: "Nota", cuerpo) = block(
  fill: rgb("#FFF4E5"), stroke: (left: 3pt + rgb("#E69500")), inset: 10pt, radius: 2pt, width: 100%,
)[*⚠ #titulo:* #cuerpo]

#let tip(cuerpo) = block(
  fill: rgb("#E7F3FE"), stroke: (left: 3pt + rgb("#1A73E8")), inset: 10pt, radius: 2pt, width: 100%,
)[*💡 Tip:* #cuerpo]
