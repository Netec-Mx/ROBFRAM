# Robot Framework y Automatización de Pruebas

Curso práctico de automatización de pruebas y RPA con Robot Framework 7x. Cubre desde fundamentos hasta técnicas avanzadas: automatización web, API, RPA, BDD, extensión con Python y preparación para la certificación RFCP.

## Estructura

- `CapituloXX/README.md`: guía de laboratorio por capítulo.

## Lista de laboratorios

### Capítulo 1

- [Instalación del entorno y ejecución del primer test case](Capitulo01/README.md#instalación-del-entorno-y-ejecución-del-primer-test-case)
  - Descripción: Configurar Python, Robot Framework y VS Code; escribir y ejecutar un test case básico verificando la salida generada.
  - Duración estimada: 72 min
- [Análisis del reporte HTML generado](Capitulo01/README.md#análisis-del-reporte-html-generado)
  - Descripción: Interpretar el output.xml, log.html y report.html de una ejecución; identificar métricas clave de resultados.
  - Duración estimada: 72 min

### Capítulo 2

- [Suite estructurada con keywords reutilizables y archivo Resource](Capitulo02/README.md#suite-estructurada-con-keywords-reutilizables-y-archivo-resource)
  - Descripción: Diseñar una suite de prueba con separación en capa de keywords, importar un archivo Resource y validar datos con variables.
  - Duración estimada: 72 min
- [Parametrización con Setup/Teardown y filtrado por tags](Capitulo02/README.md#parametrización-con-setupteardown-y-filtrado-por-tags)
  - Descripción: Implementar Suite Setup/Teardown, Test Setup/Teardown y ejecutar subconjuntos de tests usando tags de inclusión y exclusión.
  - Duración estimada: 72 min

### Capítulo 3

- [Tests con lógica condicional y bucles de datos](Capitulo03/README.md#tests-con-lógica-condicional-y-bucles-de-datos)
  - Descripción: Crear tests que usen IF/ELSE para validar condiciones variables y FOR para recorrer conjuntos de datos de prueba.
  - Duración estimada: 72 min
- [Suite robusta con manejo de fallas y recuperación](Capitulo03/README.md#suite-robusta-con-manejo-de-fallas-y-recuperación)
  - Descripción: Diseñar tests que continúen ejecutándose ante fallos parciales usando Continue On Failure y capturen errores esperados.
  - Duración estimada: 72 min

### Capítulo 4

- [Escritura de escenarios BDD para un flujo comercial de telecomunicaciones](Capitulo04/README.md#escritura-de-escenarios-bdd-para-un-flujo-comercial-de-telecomunicaciones)
  - Descripción: Traducir un proceso de negocio real (ej: activación de servicio) a escenarios Gherkin funcionales en Robot Framework.
  - Duración estimada: 72 min
- [Refactorización de test tradicional a modelo BDD con separación de capas](Capitulo04/README.md#refactorización-de-test-tradicional-a-modelo-bdd-con-separación-de-capas)
  - Descripción: Migrar un script de prueba existente hacia arquitectura BDD con Given/When/Then y separar la capa de negocio de la técnica.
  - Duración estimada: 72 min

### Capítulo 5

- [Suite data-driven con CSV y segmentación por tags](Capitulo05/README.md#suite-data-driven-con-csv-y-segmentación-por-tags)
  - Descripción: Implementar pruebas parametrizadas desde un archivo CSV externo y generar reportes segmentados por tag de ambiente y prioridad.
  - Duración estimada: 72 min
- [Creación de librería Python personalizada e integración en suite](Capitulo05/README.md#creación-de-librería-python-personalizada-e-integración-en-suite)
  - Descripción: Desarrollar un keyword personalizado en Python con documentación, empaquetarlo como librería e importarlo en una suite de prueba.
  - Duración estimada: 72 min

### Capítulo 6

- [Automatización de flujo de login y navegación E2E](Capitulo06/README.md#automatización-de-flujo-de-login-y-navegación-e2e)
  - Descripción: Implementar un flujo completo de autenticación y navegación usando localizadores CSS/XPath con waits explícitos y screenshots en fallo.
  - Duración estimada: 72 min
- [Suite web con Page Object y captura de evidencias completas](Capitulo06/README.md#suite-web-con-page-object-y-captura-de-evidencias-completas)
  - Descripción: Estructurar una suite bajo patrón Page Object con keywords por página, screenshots automáticos y manejo de frames y alertas.
  - Duración estimada: 72 min

### Capítulo 7

- [Suite de pruebas API con autenticación Bearer y validación JSON](Capitulo07/README.md#suite-de-pruebas-api-con-autenticación-bearer-y-validación-json)
  - Descripción: Consumir endpoints REST autenticados con token, validar estructura y valores de respuesta JSON e implementar aserciones de contrato.
  - Duración estimada: 72 min
- [Suite API data-driven: smoke y regresión desde CSV](Capitulo07/README.md#suite-api-data-driven-smoke-y-regresión-desde-csv)
  - Descripción: Construir una suite parametrizada desde CSV que cubra escenarios positivos y negativos de una API con segmentación por tags de suite.
  - Duración estimada: 72 min

### Capítulo 8

- [Proceso RPA con lectura de Excel, transformación y generación de reporte PDF](Capitulo08/README.md#proceso-rpa-con-lectura-de-excel-transformación-y-generación-de-reporte-pdf)
  - Descripción: Construir un flujo de automatización que lea datos de Excel, los transforme y genere un reporte PDF con logging de cada etapa.
  - Duración estimada: 72 min
- [Proceso RPA end-to-end: web + API + archivos con checklist de calidad](Capitulo08/README.md#proceso-rpa-end-to-end-web-api-archivos-con-checklist-de-calidad)
  - Descripción: Implementar un proceso RPA completo que integre automatización web, llamada a API y escritura de archivo, con manejo de errores y checklist de validación.
  - Duración estimada: 72 min

### Capítulo 9

- [Ejecución avanzada por CLI con filtros de tags y regeneración de reportes](Capitulo09/README.md#ejecución-avanzada-por-cli-con-filtros-de-tags-y-regeneración-de-reportes)
  - Descripción: Lograr la ejecución selectiva de suites por tags, el rerun automático de fallidos y la combinación de reportes con Rebot.
  - Duración estimada: 54 min
- [Simulacro RFCP y proyecto final integrador](Capitulo09/README.md#simulacro-rfcp-y-proyecto-final-integrador)
  - Descripción: Resolver preguntas tipo certificación RFCP y presentar un plan de adopción regional de automatización con RF basado en los aprendizajes del curso.
  - Duración estimada: 54 min

## Flujo de colaboración

- Trabajar en `changes_course`.
- Crear Pull Request hacia `main`.
- Merge por `Squash and merge`.
