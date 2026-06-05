# Práctica 17: Ejecución avanzada por CLI con filtros de tags y regeneración de reportes

## Metadatos

| Campo         | Valor                          |
|---------------|-------------------------------|
| **Duración**  | 54 minutos                    |
| **Complejidad** | Media                       |
| **Nivel Bloom** | Aplicar (Apply)             |
| **Módulo**    | 9 — CLI Avanzado y Reporting  |
| **Práctica**  | 17                            |

---

## Descripción General

En este laboratorio aplicarás las opciones avanzadas del CLI de Robot Framework para controlar con precisión qué pruebas se ejecutan, cómo se parametrizan y cómo se consolidan los resultados. Usarás las suites creadas en prácticas anteriores como material de trabajo real, ejecutarás filtros por tags con paretags booleanas, analizarás los artefactos `report.html`, `log.html` y `output.xml`, y dominarás la herramienta `rebot` para combinar y regenerar reportes. Al finalizar habrás implementado una estrategia completa de re-ejecución de fallos aplicable directamente en pipelines de CI/CD.

---

## Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Ejecutar suites con filtros CLI (`--include`, `--exclude`, `--suite`, `--test`, `--variable`) sin modificar ningún archivo `.robot`
- [ ] Analizar e interpretar los artefactos `report.html`, `log.html` y `output.xml` para identificar métricas de calidad y patrones de fallo
- [ ] Usar `rebot` para combinar múltiples `output.xml`, regenerar reportes filtrados y crear vistas consolidadas
- [ ] Aplicar la estrategia `--rerunfailed` + `rebot --merge` para flujos de corrección eficientes
- [ ] Configurar `Metadata` y tags enriquecidos en archivos `.robot` para contextualizar los reportes

---

## Prerrequisitos

### Conocimiento previo
- Haber completado las Prácticas 11, 13 y 15 (suites con tags `smoke`, `regression` y `wip` disponibles)
- Familiaridad básica con la línea de comandos (bash / PowerShell / cmd)
- Python básico: leer un script que usa `xml.etree.ElementTree`

### Acceso y herramientas
- Entorno virtual Python activo con Robot Framework 7.x instalado
- Comandos `robot` y `rebot` accesibles en el PATH del entorno virtual
- VS Code con Robot Framework Language Server (para editar archivos `.robot`)
- Al menos 200 MB de espacio libre para artefactos de reporte

---

## Entorno de Laboratorio

### Hardware mínimo recomendado

| Componente        | Mínimo                              |
|-------------------|-------------------------------------|
| Procesador        | Intel Core i5 8ª gen / AMD Ryzen 5  |
| RAM               | 8 GB                                |
| Almacenamiento    | 5 GB libres                         |
| Pantalla          | 1280 × 768 (para reportes HTML)     |
| Conexión          | No requerida (ejecución local)      |

### Software requerido

| Herramienta                  | Versión mínima |
|------------------------------|----------------|
| Python                       | 3.10+          |
| Robot Framework              | 7.x            |
| pip                          | 23.x           |
| VS Code                      | 1.85+          |
| RF Language Server (VS Code) | 1.12+          |

### Preparación del entorno

> **⚠️ OBLIGATORIO:** Activa tu entorno virtual antes de comenzar. Todos los comandos del laboratorio deben ejecutarse dentro del `venv`.

**Windows (cmd / PowerShell):**
```bat
cd C:\proyectos\rf-telecom
.\venv\Scripts\activate
```

**macOS / Linux (bash / zsh):**
```bash
cd ~/proyectos/rf-telecom
source venv/bin/activate
```

**Verificar que `robot` y `rebot` están disponibles:**
```bash
robot --version
rebot --version
```

Salida esperada (ambos comandos):
```
Robot Framework 7.x.x (Python 3.x.x on ...)
```

### Estructura de directorios de partida

El laboratorio asume la siguiente estructura heredada de prácticas anteriores. Si algún directorio no existe, el **Paso 1** lo creará.

```
rf-telecom/
├── venv/
├── tests/
│   ├── suite_smoke/
│   │   └── smoke_tests.robot
│   ├── suite_api/
│   │   └── api_tests.robot
│   └── suite_web/
│       └── web_tests.robot
├── resources/
│   └── common.resource
├── results/          ← se creará en este lab
└── scripts/          ← se creará en este lab
```

---

## Instrucciones Paso a Paso

---

### Paso 1 — Preparar el material de trabajo: suites con tags enriquecidos

**Objetivo:** Crear o actualizar las suites de prueba con `Metadata`, tags `smoke`, `regression`, `wip` y `priority` para que los filtros CLI del laboratorio funcionen correctamente.

#### Instrucciones

1. Crea el directorio de resultados y el directorio de scripts auxiliares:

   **Windows:**
   ```bat
   mkdir results
   mkdir scripts
   ```

   **macOS / Linux:**
   ```bash
   mkdir -p results scripts
   ```

2. Abre VS Code en la raíz del proyecto:
   ```bash
   code .
   ```

3. Crea o reemplaza el archivo `tests/suite_smoke/smoke_tests.robot` con el siguiente contenido. Este archivo simula pruebas de una empresa ficticia de telecomunicaciones:

   ```robotframework
   *** Settings ***
   Documentation     Suite de pruebas de humo — Sistema de Activación de Servicios
   ...               Telecom Ficticia S.A. | Sprint 42 | Entorno: ${ENV}
   Metadata          Version       2.1.0
   Metadata          Sprint        42
   Metadata          Environment   ${ENV}
   Metadata          Owner         Equipo QA

   *** Variables ***
   ${ENV}            dev
   ${BASE_URL}       https://dev.telecom.ejemplo.com
   ${TIMEOUT}        5s

   *** Test Cases ***
   TC-SMOKE-001 Verificar disponibilidad del portal de activación
       [Documentation]    Verifica que el portal responde con código 200
       [Tags]    smoke    priority:high    activacion
       Log    Conectando a ${BASE_URL} en entorno ${ENV}
       Log    Portal de activación disponible    console=True
       Should Be Equal As Strings    ${ENV}    ${ENV}

   TC-SMOKE-002 Verificar login de operador
       [Documentation]    Prueba de humo para autenticación de operadores
       [Tags]    smoke    priority:high    autenticacion
       Log    Ejecutando login de operador en ${ENV}
       ${resultado}=    Set Variable    OK
       Should Be Equal    ${resultado}    OK

   TC-SMOKE-003 Verificar consulta de líneas activas
       [Documentation]    Consulta básica de líneas activas en el sistema
       [Tags]    smoke    regression    consultas
       Log    Consultando líneas activas...
       ${total_lineas}=    Set Variable    ${150}
       Should Be True    ${total_lineas} > 0

   TC-SMOKE-004 Verificar módulo WIP de portabilidad avanzada
       [Documentation]    Módulo en desarrollo — NO ejecutar en CI
       [Tags]    smoke    wip    portabilidad
       Log    Este test está en desarrollo
       Fail    Módulo de portabilidad avanzada aún no implementado

   TC-SMOKE-005 Verificar facturación básica
       [Documentation]    Prueba de humo del módulo de facturación
       [Tags]    smoke    regression    facturacion    priority:medium
       Log    Verificando facturación básica en ${ENV}
       Should Be Equal As Strings    ${ENV}    ${ENV}
   ```

4. Crea o reemplaza `tests/suite_api/api_tests.robot`:

   ```robotframework
   *** Settings ***
   Documentation     Suite de pruebas de API REST — Gestión de Clientes
   ...               Telecom Ficticia S.A. | Sprint 42 | Entorno: ${ENV}
   Metadata          Version       2.1.0
   Metadata          Sprint        42
   Metadata          Environment   ${ENV}
   Metadata          Module        API-Clientes

   *** Variables ***
   ${ENV}            dev
   ${BASE_URL}       https://dev.telecom.ejemplo.com/api
   ${API_TOKEN}      token_dev_12345

   *** Test Cases ***
   TC-API-001 Consultar cliente por ID
       [Documentation]    GET /clientes/{id} debe retornar datos del cliente
       [Tags]    regression    api    clientes    priority:high
       Log    GET ${BASE_URL}/clientes/1001 con token ${API_TOKEN}
       ${status}=    Set Variable    200
       Should Be Equal As Integers    ${status}    200

   TC-API-002 Crear nuevo contrato de servicio
       [Documentation]    POST /contratos debe crear contrato y retornar 201
       [Tags]    regression    api    contratos    priority:high
       Log    POST ${BASE_URL}/contratos
       ${status}=    Set Variable    201
       Should Be Equal As Integers    ${status}    201

   TC-API-003 Actualizar plan tarifario
       [Documentation]    PUT /planes/{id} debe actualizar el plan
       [Tags]    regression    api    planes    priority:medium
       Log    PUT ${BASE_URL}/planes/500
       ${status}=    Set Variable    200
       Should Be Equal As Integers    ${status}    200

   TC-API-004 Eliminar contrato vencido
       [Documentation]    DELETE /contratos/{id} — funcionalidad en revisión
       [Tags]    regression    api    contratos    wip
       Log    DELETE ${BASE_URL}/contratos/999
       Fail    Endpoint DELETE /contratos no disponible en entorno dev

   TC-API-005 Validar autenticación Bearer inválida
       [Documentation]    Token inválido debe retornar 401
       [Tags]    regression    api    autenticacion    security
       Log    Probando token inválido...
       ${status}=    Set Variable    401
       Should Be Equal As Integers    ${status}    401
   ```

5. Crea o reemplaza `tests/suite_web/web_tests.robot`:

   ```robotframework
   *** Settings ***
   Documentation     Suite de pruebas Web — Portal de Autogestión
   ...               Telecom Ficticia S.A. | Sprint 42 | Entorno: ${ENV}
   Metadata          Version       2.1.0
   Metadata          Sprint        42
   Metadata          Environment   ${ENV}
   Metadata          Module        Web-Autogestion

   *** Variables ***
   ${ENV}            dev
   ${BASE_URL}       https://dev.telecom.ejemplo.com
   ${BROWSER}        chrome

   *** Test Cases ***
   TC-WEB-001 Navegar al portal de autogestión
       [Documentation]    Verificar que la página principal carga correctamente
       [Tags]    smoke    web    navegacion    priority:high
       Log    Abriendo ${BASE_URL} en ${BROWSER}
       Log    Página principal cargada    console=True

   TC-WEB-002 Login de cliente en portal web
       [Documentation]    Flujo de autenticación del cliente en el portal
       [Tags]    regression    web    autenticacion    priority:high
       Log    Ejecutando login web en ${ENV}
       ${resultado}=    Set Variable    login_exitoso
       Should Contain    ${resultado}    exitoso

   TC-WEB-003 Consultar historial de facturación web
       [Documentation]    Verificar visualización del historial de facturas
       [Tags]    regression    web    facturacion    priority:medium
       Log    Consultando historial de facturación...
       ${facturas}=    Set Variable    ${12}
       Should Be True    ${facturas} > 0

   TC-WEB-004 Descargar factura en PDF
       [Documentation]    Funcionalidad de descarga en desarrollo
       [Tags]    web    wip    facturacion
       Log    Descargando factura PDF...
       Fail    Descarga de PDF no implementada en esta versión

   TC-WEB-005 Verificar responsive en mobile
       [Documentation]    Vista móvil del portal — prueba de regresión
       [Tags]    regression    web    responsive    priority:low
       Log    Verificando vista responsive
       Should Be Equal As Strings    responsive    responsive
   ```

#### Salida esperada

Los tres archivos `.robot` deben estar creados y sin errores de sintaxis. VS Code debe mostrarlos sin subrayados rojos en el panel de problemas.

#### Verificación

```bash
# Verificar que robot puede parsear las suites sin ejecutarlas (dry-run)
robot --dryrun --outputdir results/dryrun tests/
```

Salida esperada:
```
==============================================================================
Tests                                                                         
==============================================================================
...
15 tests, 15 passed, 0 failed
==============================================================================
```

> **Nota:** En modo `--dryrun`, los `Fail` no se ejecutan realmente; solo se valida la sintaxis.

---

### Paso 2 — Ejecución básica completa y análisis de artefactos

**Objetivo:** Ejecutar la suite completa para generar los artefactos base (`output.xml`, `report.html`, `log.html`) y familiarizarse con su estructura.

#### Instrucciones

1. Ejecuta la suite completa apuntando a `tests/` con salida en `results/full/`:

   ```bash
   robot \
     --outputdir results/full \
     --output output.xml \
     --report report.html \
     --log log.html \
     --name "Telecom-Ficticia-Suite-Completa" \
     --doc "Ejecución completa Sprint 42 - Entorno dev" \
     tests/
   ```

   **Windows (cmd — sin backslash de continuación):**
   ```bat
   robot --outputdir results\full --output output.xml --report report.html --log log.html --name "Telecom-Ficticia-Suite-Completa" --doc "Ejecucion completa Sprint 42 - Entorno dev" tests\
   ```

2. Observa la salida en consola. Deberías ver algo similar a:

   ```
   ==============================================================================
   Telecom-Ficticia-Suite-Completa
   ==============================================================================
   Telecom-Ficticia-Suite-Completa.Suite Smoke                                   
   ==============================================================================
   TC-SMOKE-001 Verificar disponibilidad del portal de activación        | PASS |
   TC-SMOKE-002 Verificar login de operador                              | PASS |
   TC-SMOKE-003 Verificar consulta de líneas activas                     | PASS |
   TC-SMOKE-004 Verificar módulo WIP de portabilidad avanzada            | FAIL |
   TC-SMOKE-005 Verificar facturación básica                             | PASS |
   ...
   ==============================================================================
   Telecom-Ficticia-Suite-Completa                                       | FAIL |
   15 tests, 12 passed, 3 failed
   ==============================================================================
   ```

3. Abre `results/full/report.html` en tu navegador:
   - Identifica la **tasa de éxito** (debería ser 80% — 12 de 15)
   - Localiza la sección **Statistics by Tag** y observa cuántos tests hay por tag
   - Identifica los **3 tests fallidos** y sus tags asociados

4. Abre `results/full/log.html` en tu navegador:
   - Navega hasta `TC-SMOKE-004` y expande el árbol de keywords
   - Identifica el mensaje exacto del fallo: `Módulo de portabilidad avanzada aún no implementado`
   - Observa la jerarquía: Suite → Test Case → Keyword → Log message

5. Verifica los archivos generados:

   ```bash
   # macOS/Linux
   ls -lh results/full/

   # Windows
   dir results\full\
   ```

#### Salida esperada

```
output.xml    ~15-25 KB
report.html   ~80-120 KB
log.html      ~150-250 KB
```

#### Verificación

```bash
# El archivo output.xml debe existir y contener la etiqueta <robot>
# macOS/Linux
head -3 results/full/output.xml

# Windows PowerShell
Get-Content results\full\output.xml -TotalCount 3
```

Salida esperada (primeras líneas del XML):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<robot generator="Robot Framework 7.x.x" ...>
```

---

### Paso 3 — Filtrado por tags: `--include`, `--exclude` y paretags

**Objetivo:** Ejecutar subconjuntos específicos de pruebas usando filtros de tags simples y combinaciones booleanas (paretags).

#### Instrucciones

1. **Ejecución solo de pruebas `smoke`** (pipeline de integración rápida):

   ```bash
   robot \
     --include smoke \
     --outputdir results/smoke \
     --output output_smoke.xml \
     --name "Smoke-Sprint42" \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 6 — de las 3 suites)

2. **Excluir pruebas `wip`** (nunca deben llegar a CI):

   ```bash
   robot \
     --exclude wip \
     --outputdir results/no_wip \
     --output output_no_wip.xml \
     --name "Suite-Sin-WIP" \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 12 de 15)

3. **Combinar filtros: `smoke` pero sin `wip`** (el caso de uso más común en CI):

   ```bash
   robot \
     --include smoke \
     --exclude wip \
     --outputdir results/smoke_no_wip \
     --output output_smoke_no_wip.xml \
     --name "Smoke-CI-Sprint42" \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 5 — excluye TC-SMOKE-004)

4. **Paretag AND — pruebas de `regression` Y `api`:**

   ```bash
   robot \
     --include regressionANDapi \
     --outputdir results/regression_api \
     --output output_regression_api.xml \
     --name "Regression-API" \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 4 — TC-API-001 a TC-API-004)

5. **Paretag AND NOT — `regression` pero sin `wip`:**

   ```bash
   robot \
     --include regressionANDNOTwip \
     --outputdir results/regression_clean \
     --output output_regression_clean.xml \
     --name "Regression-Clean" \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 7)

6. **Paretag OR — `smoke` O `security`:**

   ```bash
   robot \
     --include smokeORsecurity \
     --outputdir results/smoke_or_security \
     --output output_smoke_security.xml \
     --name "Smoke-OR-Security" \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 7 — 6 smoke + 1 security, sin duplicados)

#### Salida esperada

Cada ejecución debe generar su propio directorio en `results/` con `output.xml`, `report.html` y `log.html`. Los conteos de tests deben coincidir con los valores esperados indicados en cada paso.

#### Verificación

```bash
# Verificar que todos los output.xml fueron generados
# macOS/Linux
ls results/*/output*.xml

# Windows PowerShell
Get-ChildItem results -Recurse -Filter "output*.xml"
```

> **💡 Tip pedagógico:** Los operadores `AND`, `OR` y `NOT` de las paretags van en **mayúsculas y sin espacios** dentro del valor del argumento. `--include regressionANDapi` es correcto; `--include "regression AND api"` **no** funcionará como se espera.

---

### Paso 4 — Selección por suite y test individual: `--suite` y `--test`

**Objetivo:** Delimitar la ejecución a una suite específica o a un caso de prueba individual usando `--suite` y `--test`.

#### Instrucciones

1. **Ejecutar solo la suite de API por nombre exacto:**

   ```bash
   robot \
     --suite "Suite Api" \
     --outputdir results/only_api \
     --output output_only_api.xml \
     tests/
   ```

   > **Nota:** Robot Framework normaliza los nombres de suites convirtiendo guiones bajos en espacios y usando title case. El directorio `suite_api` se convierte en `Suite Api`.

2. **Ejecutar suites que contengan "web" en su nombre (comodín `*`):**

   ```bash
   robot \
     --suite "*web*" \
     --outputdir results/only_web \
     --output output_only_web.xml \
     tests/
   ```

3. **Ejecutar un test individual por nombre:**

   ```bash
   robot \
     --test "TC-API-001 Consultar cliente por ID" \
     --outputdir results/single_test \
     --output output_single.xml \
     tests/
   ```

   Salida esperada en consola:
   ```
   1 test, 1 passed, 0 failed
   ```

4. **Combinar `--suite` con `--include`** (suite web, solo tests de regresión):

   ```bash
   robot \
     --suite "*web*" \
     --include regression \
     --outputdir results/web_regression \
     --output output_web_regression.xml \
     tests/
   ```

   Anota cuántos tests se ejecutaron: _____ (esperado: 3)

#### Salida esperada

Cada comando debe ejecutar exactamente el subconjunto indicado. El comando del paso 3 debe mostrar `1 test, 1 passed, 0 failed`.

#### Verificación

```bash
# Verificar conteo de tests en output_only_api.xml con grep/findstr
# macOS/Linux
grep -o 'status="PASS"' results/only_api/output_only_api.xml | wc -l
grep -o 'status="FAIL"' results/only_api/output_only_api.xml | wc -l

# Windows PowerShell
(Select-String -Path results\only_api\output_only_api.xml -Pattern 'status="PASS"').Count
(Select-String -Path results\only_api\output_only_api.xml -Pattern 'status="FAIL"').Count
```

---

### Paso 5 — Inyección de variables con `--variable` y `--variablefile`

**Objetivo:** Sobrescribir variables de entorno en tiempo de ejecución para ejecutar la misma suite contra diferentes entornos sin modificar el código.

#### Instrucciones

1. **Ejecutar apuntando al entorno `staging`** (sobrescribir `ENV` y `BASE_URL`):

   ```bash
   robot \
     --variable ENV:staging \
     --variable BASE_URL:https://staging.telecom.ejemplo.com \
     --include smoke \
     --exclude wip \
     --outputdir results/staging_smoke \
     --output output_staging_smoke.xml \
     --name "Smoke-Staging-Sprint42" \
     tests/
   ```

2. Abre `results/staging_smoke/log.html` y navega a `TC-SMOKE-001`. Verifica que el mensaje de log muestra `staging` y `https://staging.telecom.ejemplo.com` en lugar de los valores por defecto `dev`.

3. **Crear un archivo de variables para producción.** Crea el archivo `resources/vars_prod.py`:

   ```python
   # resources/vars_prod.py
   # Archivo de variables para entorno de producción
   # Telecom Ficticia S.A.

   ENV = "prod"
   BASE_URL = "https://prod.telecom.ejemplo.com"
   API_TOKEN = "token_prod_SECRETO_99999"
   TIMEOUT = "10s"
   ```

4. **Ejecutar usando `--variablefile`:**

   ```bash
   robot \
     --variablefile resources/vars_prod.py \
     --include smoke \
     --exclude wip \
     --outputdir results/prod_smoke \
     --output output_prod_smoke.xml \
     --name "Smoke-Prod-Sprint42" \
     tests/
   ```

5. Verifica en `results/prod_smoke/log.html` que `ENV` ahora es `prod`.

   > **💡 Precedencia de variables:** Si usas `--variable` y `--variablefile` simultáneamente, `--variable` tiene mayor precedencia. El orden de evaluación es: `--variable` > `--variablefile` > variables definidas en el archivo `.robot`.

#### Salida esperada

Los logs de las ejecuciones de staging y prod deben mostrar los valores correctos de `ENV` y `BASE_URL` inyectados desde el CLI, no los valores por defecto del archivo `.robot`.

#### Verificación

```bash
# Buscar la cadena "staging" en el log de staging
# macOS/Linux
grep -c "staging" results/staging_smoke/log.html

# Windows PowerShell
(Select-String -Path results\staging_smoke\log.html -Pattern "staging").Count
```

El conteo debe ser mayor que 0.

---

### Paso 6 — Análisis de `output.xml` con Python

**Objetivo:** Extraer métricas de calidad del archivo `output.xml` usando un script Python con `xml.etree.ElementTree`.

#### Instrucciones

1. Crea el archivo `scripts/analizar_output.py`:

   ```python
   #!/usr/bin/env python3
   """
   analizar_output.py
   Extrae métricas de calidad de un archivo output.xml de Robot Framework.
   Uso: python scripts/analizar_output.py <ruta_output.xml>
   
   Telecom Ficticia S.A. — Equipo QA — Sprint 42
   """

   import sys
   import xml.etree.ElementTree as ET
   from pathlib import Path
   from datetime import datetime


   def parse_rf_timestamp(ts: str) -> datetime | None:
       """Convierte timestamp de RF (YYYYMMDD HH:MM:SS.mmm) a datetime."""
       if not ts or ts == "N/A":
           return None
       try:
           return datetime.strptime(ts[:19], "%Y%m%d %H:%M:%S")
       except ValueError:
           return None


   def analizar_output(ruta_xml: str) -> None:
       """Analiza el output.xml y muestra métricas de calidad."""
       ruta = Path(ruta_xml)
       if not ruta.exists():
           print(f"ERROR: No se encontró el archivo: {ruta_xml}")
           sys.exit(1)

       tree = ET.parse(ruta)
       root = tree.getroot()

       # ── Métricas globales desde <statistics> ──────────────────────────────
       total = passed = failed = 0
       stats_total = root.find(".//statistics/total/stat")
       if stats_total is not None:
           passed = int(stats_total.get("pass", 0))
           failed = int(stats_total.get("fail", 0))
           total = passed + failed

       tasa_exito = (passed / total * 100) if total > 0 else 0

       # ── Tiempo de ejecución desde el elemento raíz ────────────────────────
       start_ts = root.get("generated", "N/A")
       # Tiempo total desde el elemento <suite> raíz
       suite_root = root.find("suite")
       elapsed_ms = 0
       if suite_root is not None:
           status_elem = suite_root.find("status")
           if status_elem is not None:
               start = parse_rf_timestamp(status_elem.get("starttime", ""))
               end = parse_rf_timestamp(status_elem.get("endtime", ""))
               if start and end:
                   elapsed_ms = int((end - start).total_seconds() * 1000)

       # ── Tests fallidos con detalle ─────────────────────────────────────────
       tests_fallidos = []
       for test in root.iter("test"):
           status_elem = test.find("status")
           if status_elem is not None and status_elem.get("status") == "FAIL":
               mensaje = status_elem.get("message", status_elem.text or "Sin mensaje")
               tags = [tag.text for tag in test.findall("tag")]
               tests_fallidos.append({
                   "nombre": test.get("name", "Sin nombre"),
                   "mensaje": mensaje[:100],  # truncar para legibilidad
                   "tags": tags,
               })

       # ── Tags con mayor cantidad de fallos ─────────────────────────────────
       tag_fallos: dict[str, int] = {}
       for tf in tests_fallidos:
           for tag in tf["tags"]:
               tag_fallos[tag] = tag_fallos.get(tag, 0) + 1

       # ── Imprimir reporte ──────────────────────────────────────────────────
       print("=" * 60)
       print("  ANÁLISIS DE OUTPUT.XML — Robot Framework")
       print("=" * 60)
       print(f"  Archivo    : {ruta.name}")
       print(f"  Generado   : {start_ts}")
       print(f"  Tiempo     : {elapsed_ms} ms")
       print("-" * 60)
       print(f"  Total tests: {total}")
       print(f"  Pasados    : {passed}  ✅")
       print(f"  Fallidos   : {failed}  ❌")
       print(f"  Tasa éxito : {tasa_exito:.1f}%")
       print("-" * 60)

       if tests_fallidos:
           print("  TESTS FALLIDOS:")
           for i, tf in enumerate(tests_fallidos, 1):
               print(f"  {i}. {tf['nombre']}")
               print(f"     Tags   : {', '.join(tf['tags'])}")
               print(f"     Error  : {tf['mensaje']}")
       else:
           print("  ¡Todos los tests pasaron! 🎉")

       if tag_fallos:
           print("-" * 60)
           print("  TAGS CON FALLOS:")
           for tag, count in sorted(tag_fallos.items(),
                                    key=lambda x: x[1], reverse=True):
               print(f"    {tag:<20} {count} fallo(s)")

       print("=" * 60)


   if __name__ == "__main__":
       if len(sys.argv) < 2:
           print("Uso: python scripts/analizar_output.py <ruta_output.xml>")
           sys.exit(1)
       analizar_output(sys.argv[1])
   ```

2. Ejecuta el script sobre la ejecución completa:

   ```bash
   python scripts/analizar_output.py results/full/output.xml
   ```

3. Ejecuta el script sobre la ejecución de solo smoke:

   ```bash
   python scripts/analizar_output.py results/smoke/output_smoke.xml
   ```

4. Compara los resultados de ambas ejecuciones. Responde mentalmente:
   - ¿Qué tags aparecen siempre en los tests fallidos?
   - ¿Cuál es la tasa de éxito cuando se excluye `wip`?

#### Salida esperada

```
============================================================
  ANÁLISIS DE OUTPUT.XML — Robot Framework
============================================================
  Archivo    : output.xml
  Generado   : 20XX0101 HH:MM:SS.mmm
  Tiempo     : XXXX ms
------------------------------------------------------------
  Total tests: 15
  Pasados    : 12  ✅
  Fallidos   : 3   ❌
  Tasa éxito : 80.0%
------------------------------------------------------------
  TESTS FALLIDOS:
  1. TC-SMOKE-004 Verificar módulo WIP de portabilidad avanzada
     Tags   : smoke, wip, portabilidad
     Error  : Módulo de portabilidad avanzada aún no implementado
  2. TC-API-004 Eliminar contrato vencido
     Tags   : regression, api, contratos, wip
     Error  : Endpoint DELETE /contratos no disponible en entorno dev
  3. TC-WEB-004 Descargar factura en PDF
     Tags   : web, wip, facturacion
     Error  : Descarga de PDF no implementada en esta versión
------------------------------------------------------------
  TAGS CON FALLOS:
    wip                  3 fallo(s)
    ...
============================================================
```

#### Verificación

El script debe ejecutarse sin errores y mostrar exactamente 3 tests fallidos, todos con el tag `wip`.

---

### Paso 7 — Estrategia `--rerunfailed`: ciclo de corrección eficiente

**Objetivo:** Implementar el flujo completo de re-ejecución de fallos: ejecución completa → introducir corrección → re-ejecutar solo fallidos → combinar con `rebot --merge`.

#### Instrucciones

1. **Primera ejecución completa** (genera la línea base con fallos):

   ```bash
   robot \
     --exclude wip \
     --outputdir results/ciclo \
     --output output_v1.xml \
     --name "Ciclo-Sprint42-v1" \
     tests/
   ```

   Esta ejecución debe pasar todos los tests (los `wip` están excluidos). Resultado esperado: `12 tests, 12 passed, 0 failed`.

2. **Introducir un fallo intencional** para simular una regresión. Edita `tests/suite_api/api_tests.robot` y modifica `TC-API-003`:

   ```robotframework
   TC-API-003 Actualizar plan tarifario
       [Documentation]    PUT /planes/{id} debe actualizar el plan
       [Tags]    regression    api    planes    priority:medium
       Log    PUT ${BASE_URL}/planes/500
       ${status}=    Set Variable    500
       # FALLO INTENCIONAL: se espera 200 pero retorna 500
       Should Be Equal As Integers    ${status}    200
   ```

3. **Segunda ejecución completa** (simula el pipeline que detecta la regresión):

   ```bash
   robot \
     --exclude wip \
     --outputdir results/ciclo \
     --output output_v2.xml \
     --name "Ciclo-Sprint42-v2" \
     tests/
   ```

   Resultado esperado: `12 tests, 11 passed, 1 failed`.

4. **Re-ejecutar SOLO los tests fallidos** usando `--rerunfailed`:

   ```bash
   robot \
     --exclude wip \
     --rerunfailed results/ciclo/output_v2.xml \
     --outputdir results/ciclo \
     --output output_rerun.xml \
     --name "Ciclo-Sprint42-Rerun" \
     tests/
   ```

   Resultado esperado: `1 test, 0 passed, 1 failed` (el fallo persiste porque no hemos corregido el código).

5. **Corregir el fallo intencional.** Restaura `TC-API-003` al valor correcto:

   ```robotframework
   TC-API-003 Actualizar plan tarifario
       [Documentation]    PUT /planes/{id} debe actualizar el plan
       [Tags]    regression    api    planes    priority:medium
       Log    PUT ${BASE_URL}/planes/500
       ${status}=    Set Variable    200
       Should Be Equal As Integers    ${status}    200
   ```

6. **Re-ejecutar después de la corrección:**

   ```bash
   robot \
     --exclude wip \
     --rerunfailed results/ciclo/output_v2.xml \
     --outputdir results/ciclo \
     --output output_rerun_fixed.xml \
     --name "Ciclo-Sprint42-Rerun-Fixed" \
     tests/
   ```

   Resultado esperado: `1 test, 1 passed, 0 failed`.

#### Salida esperada

El flujo completo demuestra que `--rerunfailed` ejecuta **únicamente** el test que falló (1 de 12), reduciendo el tiempo de validación de la corrección en ~92%.

#### Verificación

```bash
python scripts/analizar_output.py results/ciclo/output_rerun_fixed.xml
```

Debe mostrar: `Total tests: 1`, `Pasados: 1`, `Tasa éxito: 100.0%`.

---

### Paso 8 — Herramienta `rebot`: combinar y regenerar reportes

**Objetivo:** Usar `rebot` para combinar múltiples `output.xml` en un reporte consolidado, regenerar reportes filtrados y aplicar `--merge` para el flujo de CI/CD.

#### Instrucciones

1. **Combinar los resultados de smoke y regression en un reporte único:**

   ```bash
   rebot \
     --outputdir results/consolidado \
     --output output_consolidado.xml \
     --report report_consolidado.html \
     --log log_consolidado.html \
     --name "Reporte-Consolidado-Sprint42" \
     --doc "Combinación de ejecuciones Smoke + Regression — Sprint 42" \
     results/smoke_no_wip/output_smoke_no_wip.xml \
     results/regression_clean/output_regression_clean.xml
   ```

2. Abre `results/consolidado/report_consolidado.html` en el navegador. Verifica que contiene tests de ambas ejecuciones y que la sección **Statistics by Suite** muestra las dos suites de origen.

3. **Regenerar un reporte filtrando solo los tests fallidos** (útil para reportes de defectos):

   ```bash
   rebot \
     --include wip \
     --outputdir results/solo_fallos \
     --output output_fallos.xml \
     --report report_fallos.html \
     --log log_fallos.html \
     --name "Reporte-Solo-Fallos-Sprint42" \
     results/full/output.xml
   ```

   > **Nota:** `rebot` acepta las mismas opciones de filtrado que `robot`. Aquí usamos `--include wip` sobre el `output.xml` completo para extraer solo los tests con ese tag.

4. Abre `results/solo_fallos/report_fallos.html`. Debe mostrar únicamente los 3 tests `wip` fallidos.

5. **Aplicar `rebot --merge`** para combinar la ejecución original con el resultado del rerun (flujo estándar de CI/CD):

   ```bash
   rebot \
     --merge \
     --outputdir results/merged \
     --output output_merged.xml \
     --report report_merged.html \
     --log log_merged.html \
     --name "Ciclo-Sprint42-Merged" \
     results/ciclo/output_v2.xml \
     results/ciclo/output_rerun_fixed.xml
   ```

   Con `--merge`, si un test aparece en ambos archivos, `rebot` toma el **resultado más reciente**. El test que falló en `output_v2.xml` y luego pasó en `output_rerun_fixed.xml` aparecerá como **PASS** en el reporte mergeado.

6. Abre `results/merged/report_merged.html` y verifica que la tasa de éxito es **100%** (todos los tests que se ejecutaron en el rerun ahora aparecen como PASS).

7. **Generar un reporte con metadata personalizada** para el equipo directivo:

   ```bash
   rebot \
     --name "Dashboard-QA-Sprint42" \
     --doc "Reporte ejecutivo de calidad — Sprint 42 — Telecom Ficticia S.A." \
     --metadata "Generado_por:Equipo QA Automatizacion" \
     --metadata "Sprint:42" \
     --metadata "Entorno:dev" \
     --metadata "Herramienta:Robot Framework 7.x" \
     --outputdir results/ejecutivo \
     --report report_ejecutivo.html \
     --log log_ejecutivo.html \
     results/merged/output_merged.xml
   ```

8. Abre `results/ejecutivo/report_ejecutivo.html`. En la sección superior del reporte verás los metadatos personalizados que enriquecen el contexto del informe.

#### Salida esperada

- `results/consolidado/report_consolidado.html`: reporte que combina smoke + regression
- `results/solo_fallos/report_fallos.html`: reporte con solo los 3 tests `wip`
- `results/merged/report_merged.html`: reporte merged con 100% de éxito
- `results/ejecutivo/report_ejecutivo.html`: reporte ejecutivo con metadata personalizada

#### Verificación

```bash
# Verificar que el reporte mergeado existe y tiene tamaño razonable
# macOS/Linux
ls -lh results/merged/report_merged.html
ls -lh results/ejecutivo/report_ejecutivo.html

# Windows PowerShell
Get-Item results\merged\report_merged.html | Select-Object Name, Length
Get-Item results\ejecutivo\report_ejecutivo.html | Select-Object Name, Length
```

Ambos archivos deben tener un tamaño mayor a 50 KB.

---

### Paso 9 — Configurar Metadata y tags en archivos `.robot`

**Objetivo:** Enriquecer los archivos `.robot` con `Metadata` de suite y tags estandarizados para que los reportes sean informativos sin necesidad de opciones CLI adicionales.

#### Instrucciones

1. Abre `tests/suite_smoke/smoke_tests.robot` y verifica que la sección `*** Settings ***` ya contiene los campos `Metadata` añadidos en el Paso 1. Si no los tiene, agrégalos ahora:

   ```robotframework
   *** Settings ***
   Documentation     Suite de pruebas de humo — Sistema de Activación de Servicios
   ...               Telecom Ficticia S.A. | Sprint 42 | Entorno: ${ENV}
   Metadata          Version       2.1.0
   Metadata          Sprint        42
   Metadata          Environment   ${ENV}
   Metadata          Owner         Equipo QA
   ```

2. Añade tags de prioridad estandarizados a nivel de suite usando `Force Tags` (RF 7.x usa `Test Tags` en lugar de `Force Tags`):

   Actualiza la sección `*** Settings ***` de `smoke_tests.robot` para incluir:

   ```robotframework
   *** Settings ***
   Documentation     Suite de pruebas de humo — Sistema de Activación de Servicios
   ...               Telecom Ficticia S.A. | Sprint 42 | Entorno: ${ENV}
   Metadata          Version       2.1.0
   Metadata          Sprint        42
   Metadata          Environment   ${ENV}
   Metadata          Owner         Equipo QA
   Test Tags         sprint:42    telecom    activacion-servicios
   ```

   > **Nota RF 7.x:** La directiva `Force Tags` fue deprecada en RF 4+ y eliminada en RF 7. Usa `Test Tags` en la sección `*** Settings ***` para aplicar tags a todos los tests de la suite.

3. Realiza el mismo cambio en `api_tests.robot` y `web_tests.robot`, adaptando el valor de `Test Tags` a cada módulo:

   **api_tests.robot:**
   ```robotframework
   Test Tags         sprint:42    telecom    gestion-clientes
   ```

   **web_tests.robot:**
   ```robotframework
   Test Tags         sprint:42    telecom    portal-autogestion
   ```

4. Ejecuta la suite completa nuevamente para verificar que los nuevos tags aparecen en el reporte:

   ```bash
   robot \
     --exclude wip \
     --outputdir results/con_metadata \
     --output output_metadata.xml \
     --name "Suite-Con-Metadata-Sprint42" \
     tests/
   ```

5. Abre `results/con_metadata/report.html` y navega a **Statistics by Tag**. Deberías ver los nuevos tags `sprint:42`, `telecom`, `activacion-servicios`, `gestion-clientes` y `portal-autogestion` en la tabla de estadísticas.

6. Prueba filtrar por el tag de sprint desde el CLI:

   ```bash
   robot \
     --include "sprint:42" \
     --exclude wip \
     --outputdir results/sprint42 \
     --output output_sprint42.xml \
     tests/
   ```

   Resultado esperado: todos los tests del sprint (12 tests, todos pass).

#### Salida esperada

El reporte HTML debe mostrar los nuevos tags en la sección de estadísticas. La ejecución filtrada por `sprint:42` debe incluir todos los tests de las tres suites.

#### Verificación

```bash
python scripts/analizar_output.py results/con_metadata/output_metadata.xml
```

La sección de tags con fallos debe estar vacía (0 fallos, ya que excluimos `wip`).

---

## Validación y Pruebas

Ejecuta la siguiente secuencia de validación para confirmar que has completado todos los objetivos del laboratorio:

### Lista de verificación final

```bash
# 1. Verificar que existen los artefactos clave
# macOS/Linux
echo "=== Verificando artefactos del laboratorio ==="
test -f results/full/output.xml         && echo "✅ Full output.xml" || echo "❌ FALTA full/output.xml"
test -f results/smoke/output_smoke.xml  && echo "✅ Smoke output.xml" || echo "❌ FALTA smoke output.xml"
test -f results/ciclo/output_rerun_fixed.xml && echo "✅ Rerun fixed output.xml" || echo "❌ FALTA rerun_fixed"
test -f results/merged/report_merged.html && echo "✅ Merged report.html" || echo "❌ FALTA merged report"
test -f results/ejecutivo/report_ejecutivo.html && echo "✅ Reporte ejecutivo" || echo "❌ FALTA ejecutivo"
test -f scripts/analizar_output.py      && echo "✅ Script Python" || echo "❌ FALTA script Python"
echo "=== Verificación completada ==="
```

**Windows PowerShell:**
```powershell
Write-Host "=== Verificando artefactos del laboratorio ===" -ForegroundColor Cyan
$archivos = @(
    "results\full\output.xml",
    "results\smoke\output_smoke.xml",
    "results\ciclo\output_rerun_fixed.xml",
    "results\merged\report_merged.html",
    "results\ejecutivo\report_ejecutivo.html",
    "scripts\analizar_output.py"
)
foreach ($f in $archivos) {
    if (Test-Path $f) { Write-Host "✅ $f" -ForegroundColor Green }
    else { Write-Host "❌ FALTA: $f" -ForegroundColor Red }
}
```

### Prueba de integración final

Ejecuta este comando que combina todas las técnicas aprendidas en un único pipeline:

```bash
# Pipeline completo: staging, smoke sin wip, con metadata de sprint
robot \
  --variable ENV:staging \
  --variable BASE_URL:https://staging.telecom.ejemplo.com \
  --include smokeANDNOTwip \
  --outputdir results/pipeline_final \
  --output output_pipeline.xml \
  --name "Pipeline-Staging-Sprint42" \
  --doc "Ejecución de pipeline CI/CD — Staging — Sprint 42" \
  tests/

# Analizar el resultado
python scripts/analizar_output.py results/pipeline_final/output_pipeline.xml
```

**Resultado esperado:** `5 tests, 5 passed, 0 failed`, tasa de éxito `100.0%`, entorno `staging` visible en los logs.

---

## Resolución de Problemas

### Problema 1: `robot: error: No tests matching name 'TC-API-001 Consultar cliente por ID' found`

**Síntoma:** Al usar `--test` con el nombre completo del test, Robot Framework reporta que no encuentra ningún test con ese nombre, aunque el test existe en el archivo `.robot`.

**Causa:** Robot Framework normaliza los nombres de los tests al comparar con `--test`. Los caracteres especiales como tildes, mayúsculas/minúsculas inconsistentes o espacios extra pueden causar que el nombre no coincida. Además, `--test` busca por nombre normalizado (sin distinguir mayúsculas/minúsculas, pero sí caracteres especiales).

**Solución:**
1. Verifica el nombre exacto del test tal como aparece en el reporte HTML (que muestra el nombre normalizado).
2. Usa comodines para ser menos estricto:
   ```bash
   # En lugar de nombre exacto, usa comodín
   robot --test "*Consultar cliente*" tests/
   ```
3. Alternativamente, usa `--include` con un tag único en lugar de `--test`:
   ```bash
   robot --include "TC-API-001" tests/
   # (requiere agregar [Tags]    TC-API-001 al test)
   ```

---

### Problema 2: `rebot --merge` produce un reporte con tests duplicados en lugar de actualizarlos

**Síntoma:** Al ejecutar `rebot --merge output_v2.xml output_rerun.xml`, el reporte resultante muestra los tests duplicados (una entrada FAIL y una PASS para el mismo test) en lugar de mostrar solo el resultado más reciente.

**Causa:** `rebot --merge` identifica los tests por su **nombre completo de ruta** (suite + nombre del test). Si las dos ejecuciones tienen nombres de suite diferentes (por ejemplo, porque se usó `--name` diferente en cada `robot`), `rebot` no puede reconocer que son el mismo test y los trata como tests distintos.

**Solución:**
1. Asegúrate de que ambas ejecuciones usen el **mismo nombre de suite raíz** (o no uses `--name` en ninguna de las dos):
   ```bash
   # Ejecución v2 — sin --name personalizado
   robot --exclude wip --outputdir results/ciclo --output output_v2.xml tests/
   
   # Rerun — sin --name personalizado
   robot --exclude wip --rerunfailed results/ciclo/output_v2.xml \
         --outputdir results/ciclo --output output_rerun.xml tests/
   
   # Merge — ahora sí funcionará correctamente
   rebot --merge --outputdir results/merged \
         results/ciclo/output_v2.xml results/ciclo/output_rerun.xml
   ```
2. Si necesitas nombres personalizados, usa el mismo valor de `--name` en ambas ejecuciones para que `rebot --merge` pueda emparejarlos correctamente.

---

## Limpieza

Una vez completado el laboratorio, puedes limpiar los artefactos intermedios manteniendo solo los reportes finales:

```bash
# macOS/Linux — eliminar directorios intermedios, conservar consolidado y ejecutivo
rm -rf results/dryrun
rm -rf results/no_wip
rm -rf results/smoke_no_wip
rm -rf results/regression_api
rm -rf results/regression_clean
rm -rf results/smoke_or_security
rm -rf results/only_api
rm -rf results/only_web
rm -rf results/single_test
rm -rf results/web_regression
rm -rf results/staging_smoke
rm -rf results/prod_smoke
rm -rf results/sprint42
rm -rf results/con_metadata

echo "Limpieza completada. Conservados: results/full, results/smoke, results/ciclo, results/merged, results/ejecutivo, results/pipeline_final"
```

**Windows PowerShell:**
```powershell
$directorios_a_eliminar = @(
    "results\dryrun", "results\no_wip", "results\smoke_no_wip",
    "results\regression_api", "results\regression_clean",
    "results\smoke_or_security", "results\only_api", "results\only_web",
    "results\single_test", "results\web_regression", "results\staging_smoke",
    "results\prod_smoke", "results\sprint42", "results\con_metadata"
)
foreach ($dir in $directorios_a_eliminar) {
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
}
Write-Host "Limpieza completada." -ForegroundColor Green
```

**Restaurar el fallo intencional (si no lo hiciste en el Paso 7):**

Verifica que `TC-API-003` en `tests/suite_api/api_tests.robot` tiene `${status}` = `200` (no `500`). Esto es importante para que las prácticas siguientes partan de una suite limpia.

```robotframework
# Verificar que este es el estado correcto de TC-API-003:
TC-API-003 Actualizar plan tarifario
    [Tags]    regression    api    planes    priority:medium
    Log    PUT ${BASE_URL}/planes/500
    ${status}=    Set Variable    200
    Should Be Equal As Integers    ${status}    200
```

---

## Resumen

En este laboratorio aplicaste las técnicas avanzadas del CLI de Robot Framework en un escenario realista de telecomunicaciones:

| Técnica | Comando clave | Caso de uso |
|---|---|---|
| Filtrar por tag simple | `--include smoke` | Pipeline de integración rápida |
| Excluir en desarrollo | `--exclude wip` | Evitar tests incompletos en CI |
| Paretag AND | `--include regressionANDapi` | Regresión de módulo específico |
| Paretag AND NOT | `--include regressionANDNOTwip` | Regresión limpia |
| Selección por suite | `--suite "*web*"` | Ejecución de módulo web |
| Inyección de variables | `--variable ENV:staging` | Multi-entorno sin cambiar código |
| Archivo de variables | `--variablefile vars_prod.py` | Configuración de producción |
| Re-ejecución de fallos | `--rerunfailed output.xml` | Ciclos de corrección eficientes |
| Combinar resultados | `rebot --merge` | Flujo CI/CD completo |
| Reportes filtrados | `rebot --include wip` | Reporte de defectos |
| Metadata enriquecida | `rebot --metadata Sprint:42` | Reportes ejecutivos |

### Puntos clave para recordar

1. **Ninguna opción CLI modifica los archivos `.robot`**: toda la configuración de ejecución vive en el comando o en el pipeline.
2. **Los operadores de paretags** (`AND`, `OR`, `NOT`) van en **mayúsculas y sin espacios** dentro del valor del argumento.
3. **`--rerunfailed` + `rebot --merge`** es el flujo estándar de CI/CD para ciclos de corrección eficientes.
4. **`rebot`** no ejecuta tests; solo procesa y combina archivos `output.xml` ya existentes.
5. **`Test Tags`** (RF 7.x) reemplaza a `Force Tags` para aplicar tags a todos los tests de una suite.
6. **La precedencia de variables** es: `--variable` CLI > `--variablefile` > variables en el archivo `.robot`.

### Recursos adicionales

- [Robot Framework User Guide — Using command line options](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#using-command-line-options)
- [Robot Framework User Guide — Filtering test cases](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#filtering-test-cases)
- [Robot Framework User Guide — Re-executing failed test cases](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#re-executing-failed-test-cases)
- [Robot Framework User Guide — Post-processing outputs (rebot)](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#post-processing-outputs)
- [Robot Framework User Guide — Setting variables in command line](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#setting-variables-in-command-line)

---


