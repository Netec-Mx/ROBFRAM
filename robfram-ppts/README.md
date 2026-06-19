# Robot Framework — Presentaciones

Slides del curso **Robot Framework y Automatización de Pruebas** (NETEC / Claro Guatemala), generadas a partir de la plantilla visual del cliente (`Plantilla PPT - [ROBFRAM].pptx`, no versionada por tamaño — ver `assets/`), con contenido simplificado y didáctico, alineado a `robfram-guide`.

## Cómo se generan

1. `_template/extraer_capitulo.py` — toma un subconjunto de slides de la plantilla de referencia (500 slides), preservando 100% el master/diseño, y purga las partes huérfanas (imágenes de los slides descartados) para mantener el archivo liviano.
2. `_template/reescribir_texto.py` — reemplaza el texto de slides puntuales con contenido más simple, preservando fuente/color/tamaño original.
3. Cada capítulo tiene su propio `generar.py` que orquesta ambos pasos.

```bash
cd Capitulo01
python generar.py
libreoffice --headless --convert-to pdf Capitulo01.pptx   # genera el PDF
```

## Requisito local (no versionado)

Coloca la plantilla original del cliente en `assets/_plantilla_referencia.pptx` (gitignored por tamaño — ~105 MB). Sin ese archivo, `extraer_capitulo.py` no puede ejecutarse, pero los `.pptx` ya generados en cada `CapituloXX/` son autocontenidos y no la necesitan.

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
