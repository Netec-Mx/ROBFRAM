# Robot Framework — Manual Teórico

Manual teórico del curso **Robot Framework y Automatización de Pruebas** (NETEC / Claro Guatemala), preparación para la certificación **RFCP**.

> Contenido propio, redactado por el equipo formativo — el PDF de 241 páginas que entregó el cliente (generado por IA) es solo una referencia de alcance/temario, no la fuente de este manual.

## Entregable: un único PDF monolítico

A diferencia de `robfram-guide` (1 PDF por práctica) y `robfram-ppts` (1 PPTX por capítulo), el manual teórico se entrega como **un solo documento** — así lo exige el cliente. Las fuentes sí están separadas por capítulo para mantenibilidad y versionado por sesión; el build siempre las compila todas juntas.

```bash
./_template/build.sh    # genera Manual-Teorico-Robot-Framework.pdf (todas las fuentes, en orden)
```

## Estructura

```
00_Portada.md       # info del curso, objetivos, cómo usar el manual
Capitulo01.md ... Capitulo09.md   # una fuente por capítulo, lecciones X.1...X.5
_template/
├── preamble.typ     # mismo estilo de marca que robfram-guide
├── strip-mermaid.lua
└── build.sh
images/
└── netec-logo.png
Manual-Teorico-Robot-Framework.pdf   # artefacto final, regenerado en cada sesión
```

## Consistencia entre entregables

Cada capítulo de este manual debe ser consistente con:
- el código real en `robfram-code/sesion-NN/`
- la guía práctica en `robfram-guide/CapituloNN/`
- las slides en `robfram-ppts/CapituloNN/`

Se revisa con sub-agente `docs-writer` contra los otros 3 entregables antes de cerrar cada sesión.

## Sesiones — curso completo ✅

| Capítulo | Tema | Estado |
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

**Manual-Teorico-Robot-Framework.pdf**: 9 capítulos, 123 páginas, un solo documento.

## Profundidad por lección

Cada lección sigue una estructura fija, diseñada para servir como guía de estudio real (no solo referencia rápida):

```
Objetivos de la lección
¿Por qué importa?
Conceptos clave (3-5 sub-temas desarrollados, no solo mencionados)
Ejemplo comentado (código real, no solo descripción)
Tabla de referencia rápida
Errores comunes
Puntos clave
Autoevaluación (3-5 preguntas con respuestas)
```

Esta estructura es resultado de una auditoría de profundidad solicitada explícitamente tras una primera versión (45 páginas) que el cliente consideró insuficiente como guía de estudio.
