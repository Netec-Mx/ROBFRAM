# Robot Framework — Guía del estudiante

Guía de laboratorios del curso **Robot Framework y Automatización de Pruebas** (NETEC / Claro Guatemala), preparación para la certificación **RFCP**.

Cada práctica está en Markdown (fuente única) y se compila a PDF con Typst — sin LaTeX, sin Chromium.

## Compilar a PDF

```bash
./_template/build.sh              # compila todos los capítulos
./_template/build.sh Capitulo01   # compila solo un capítulo
```

Requiere `typst` en el PATH (`~/.local/bin/typst`, instalado desde el binario precompilado de GitHub Releases — evitar `cargo install` si la máquina tiene poca RAM) y `pandoc` ≥ 3.x.

## Estructura

```
_template/
├── preamble.typ          # estilos de marca + helpers de diagramas nativos
├── strip-mermaid.lua     # filtro pandoc: oculta bloques mermaid en el PDF
└── build.sh
Capitulo01/
├── Practica1.md / .pdf
└── Practica2.md / .pdf
images/
└── netec-logo.png
```

## Diagramas didácticos

- Bloques ` ```mermaid ` → se renderizan en GitHub/VS Code, se ocultan en el PDF.
- Bloques ` ```{=typst} ` con `#flujo-vertical(...)`, `#comparacion(...)` → diagramas nativos en el PDF, sin dependencias externas.

## Sesiones — curso completo ✅

| Sesión | Tema | Estado |
|---|---|---|
| 1 | Fundamentos y ecosistema RF | ✅ |
| 2 | Sintaxis y diseño de suites | ✅ |
| 3 | Control de flujo y validaciones | ✅ |
| 4 | BDD y pruebas orientadas a negocio | ✅ |
| 5 | RF avanzado, data-driven y Python | ✅ |
| 6 | Automatización web con SeleniumLibrary | ✅ |
| 7 | Automatización de APIs con RequestsLibrary | ✅ |
| 8 | RF aplicado a RPA | ✅ |
| 9 | Ejecución avanzada, reporting y RFCP | ✅ |
