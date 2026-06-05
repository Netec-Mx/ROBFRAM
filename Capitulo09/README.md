# Ejecución avanzada por CLI con filtros de tags y regeneración de reportes

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
*Lab 09-00-01 — Práctica 17 | Módulo 9: CLI Avanzado y Reporting | Robot Framework 7.x*

---

# Simulacro RFCP y proyecto final integrador

## Metadatos

| Campo | Detalle |
|---|---|
| **Duración estimada** | 54 minutos |
| **Complejidad** | Alta |
| **Nivel Bloom** | Crear |
| **Módulo** | 9 — Integración final y CI/CD |
| **Práctica** | 18 de 18 |

---

## Visión General

Este laboratorio es el cierre integrador del curso. En **54 minutos** divididos en dos bloques, los estudiantes primero demostrarán dominio técnico resolviendo ejercicios cronometrados tipo RFCP (Bloque A, 20 min) y luego ensamblarán un proyecto final profesional que combina automatización web, API, RPA y un pipeline CI/CD real con quality gates (Bloque B, 34 min). El resultado es un portfolio técnico completo publicable en GitHub que evidencia todas las competencias adquiridas durante el curso.

---

## Objetivos de Aprendizaje

- [ ] Demostrar dominio integrador construyendo un proyecto final que combine suites web (Page Object Model), API data-driven, RPA y reporting consolidado con `rebot`.
- [ ] Aplicar las opciones avanzadas del CLI (`--include smoke`, `--variable`, `--rerunfailed`) dentro de un pipeline GitHub Actions con quality gates definidos.
- [ ] Completar 10 ejercicios prácticos de implementación cronometrados que simulan el formato del examen RFCP.
- [ ] Generar un portfolio técnico completo con `README.md`, badges de CI, `quality_gate.py` y evidencias de ejecución.

---

## Prerequisitos

### Conocimiento previo

| Requisito | Detalle |
|---|---|
| Prácticas P11–P17 completadas | Artefactos de web (POM), API (data-driven) y RPA disponibles y funcionales |
| CLI avanzado de Robot Framework | Lección 9.1: `--variable`, `--include`, `--exclude`, `--suite`, `--rerunfailed`, paretags |
| Conceptos de CI/CD | Comprensión básica de pipelines y YAML |
| Git configurado | `git config --global user.name` y `user.email` establecidos |

### Acceso requerido

| Recurso | Estado necesario |
|---|---|
| Cuenta GitHub activa | Repositorio público o privado disponible |
| Entorno virtual Python activo | `venv` con todas las dependencias del curso |
| Artefactos P11–P17 | Carpetas `web/`, `api/`, `rpa/` del proyecto acumulativo |
| Conexión a internet | Para `git push` y verificación de GitHub Actions |

---

## Entorno de Laboratorio

### Hardware mínimo

| Componente | Mínimo recomendado |
|---|---|
| CPU | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos) |
| RAM | 8 GB (16 GB recomendado para ejecución simultánea) |
| Disco libre | 10 GB |
| Pantalla | 1280×768 para reportes HTML |

### Software requerido

| Herramienta | Versión |
|---|---|
| Python | 3.10+ |
| Robot Framework | 7.x |
| SeleniumLibrary | 6.2+ |
| RequestsLibrary | 0.9+ |
| robotframework-datadriver | 1.x (con extras CSV) |
| openpyxl | 3.1+ |
| Git | 2.40+ |
| Google Chrome | Última estable |
| VS Code | 1.85+ |

### Preparación del entorno

Antes de iniciar, verifica que el entorno virtual está activo y todas las dependencias están instaladas:

```bash
# Windows (PowerShell)
cd C:\curso-robotframework
.\venv\Scripts\Activate.ps1

# macOS / Linux
cd ~/curso-robotframework
source venv/bin/activate
```

```bash
# Verificar instalaciones clave
python --version
robot --version
pip show robotframework-seleniumlibrary robotframework-requests robotframework-datadriver openpyxl
```

```bash
# Instalar dependencias faltantes si es necesario
pip install robotframework==7.* \
            robotframework-seleniumlibrary \
            robotframework-requests \
            robotframework-jsonlibrary \
            robotframework-datadriver[CSV] \
            openpyxl \
            lxml
```

---

## Pasos del Laboratorio

---

### BLOQUE A — Simulacro RFCP (20 minutos)

> ⏱️ **Inicia el cronómetro ahora. Dispones de 20 minutos para los 10 ejercicios.**
> Trabaja en orden. Si un ejercicio te bloquea más de 3 minutos, pasa al siguiente y regresa al final.

---

#### Paso A.1 — Preparar el directorio de simulacro

**Objetivo:** Crear el espacio de trabajo aislado para los ejercicios RFCP.

**Instrucciones:**

1. Crea la carpeta de simulacro dentro del proyecto acumulativo:

```bash
mkdir -p simulacro_rfcp
cd simulacro_rfcp
```

2. Crea el archivo base de ejercicios:

```bash
# Windows
type nul > ejercicios_rfcp.robot

# macOS / Linux
touch ejercicios_rfcp.robot
```

**Resultado esperado:** Carpeta `simulacro_rfcp/` creada con el archivo vacío.

---

#### Paso A.2 — Ejercicios 1–5: Corrección y completado de código

**Objetivo:** Identificar y corregir errores de sintaxis, implementar keywords faltantes y completar validaciones.

**Instrucciones:**

Copia el siguiente bloque completo en `ejercicios_rfcp.robot`. Contiene **5 ejercicios con errores o código incompleto**. Tu tarea es corregir o completar cada sección marcada con `# TODO`:

```robotframework
*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    SeleniumLibrary
Library    OperatingSystem

# ============================================================
# EJERCICIO 1: Corregir la keyword — errores de sintaxis (RF7)
# ============================================================
*** Keywords ***
Verificar Titulo De Pagina
    [Arguments]    ${titulo_esperado}
    # TODO: La siguiente línea usa sintaxis antigua. Reemplázala con la
    # sintaxis de bloque nativa de RF4+ (IF nativo)
    Run Keyword If    '${titulo_esperado}' != ''    Title Should Be    ${titulo_esperado}

# ============================================================
# EJERCICIO 2: Implementar keyword faltante para contexto web
# ============================================================
Navegar Y Verificar Home
    [Documentation]    Navega a la URL base y verifica el título
    [Arguments]    ${url}    ${titulo}
    # TODO: Implementa esta keyword usando SeleniumLibrary.
    # Debe: abrir el navegador Chrome en ${url}, maximizar ventana,
    # verificar que el título contiene ${titulo} y cerrar el navegador.
    Log    Keyword no implementada aún

# ============================================================
# EJERCICIO 3: Completar validación JSON incompleta
# ============================================================
Validar Respuesta Usuario API
    [Documentation]    Valida campos obligatorios de respuesta JSON
    [Arguments]    ${response}
    ${json}=    Set Variable    ${response.json()}
    # TODO: Completa las 3 validaciones faltantes:
    # 1. Verificar que el campo "id" existe en ${json}
    # 2. Verificar que el campo "name" no está vacío
    # 3. Verificar que el campo "email" contiene "@"
    Log    Validaciones pendientes

# ============================================================
# EJERCICIO 4: Agregar manejo de error a proceso RPA
# ============================================================
Leer Archivo CSV Seguro
    [Documentation]    Lee un CSV con manejo de error si no existe
    [Arguments]    ${ruta_csv}
    # TODO: Envuelve la lectura del archivo en un bloque TRY/EXCEPT
    # (sintaxis nativa RF5+). Si el archivo no existe, loguear
    # "Archivo no encontrado: ${ruta_csv}" como WARNING y retornar
    # una lista vacía @{vacia}
    ${contenido}=    Get File    ${ruta_csv}
    [Return]    ${contenido}

# ============================================================
# EJERCICIO 5: Escribir el comando CLI correcto
# ============================================================
# Escenario: Necesitas ejecutar SOLO las pruebas con tag "smoke"
# del directorio tests/, excluyendo las marcadas "wip",
# inyectando ENV=qa y guardando resultados en results/smoke_output.xml
#
# TODO: Escribe el comando robot correcto como comentario debajo:
# RESPUESTA:
```

3. Implementa las correcciones y completados directamente en el archivo.

**Soluciones de referencia** (no leer hasta intentarlo):

<details>
<summary>▶ Expandir soluciones — solo después de intentarlo</summary>

```robotframework
*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    SeleniumLibrary
Library    OperatingSystem

*** Keywords ***

# EJERCICIO 1 — SOLUCIÓN: IF nativo RF4+
Verificar Titulo De Pagina
    [Arguments]    ${titulo_esperado}
    IF    '${titulo_esperado}' != ''
        Title Should Be    ${titulo_esperado}
    END

# EJERCICIO 2 — SOLUCIÓN: Keyword web completa
Navegar Y Verificar Home
    [Documentation]    Navega a la URL base y verifica el título
    [Arguments]    ${url}    ${titulo}
    Open Browser    ${url}    chrome
    Maximize Browser Window
    Title Should Contain    ${titulo}
    Close Browser

# EJERCICIO 3 — SOLUCIÓN: Validación JSON completa
Validar Respuesta Usuario API
    [Documentation]    Valida campos obligatorios de respuesta JSON
    [Arguments]    ${response}
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    id
    Should Not Be Empty    ${json}[name]
    Should Contain    ${json}[email]    @

# EJERCICIO 4 — SOLUCIÓN: TRY/EXCEPT nativo RF5+
Leer Archivo CSV Seguro
    [Documentation]    Lee un CSV con manejo de error si no existe
    [Arguments]    ${ruta_csv}
    TRY
        ${contenido}=    Get File    ${ruta_csv}
        RETURN    ${contenido}
    EXCEPT
        Log    Archivo no encontrado: ${ruta_csv}    level=WARN
        @{vacia}=    Create List
        RETURN    ${vacia}
    END

# EJERCICIO 5 — SOLUCIÓN: Comando CLI correcto
# robot --include smoke --exclude wip --variable ENV:qa \
#       --output results/smoke_output.xml tests/
```

</details>

**Resultado esperado:** 5 ejercicios corregidos/completados en `ejercicios_rfcp.robot`.

**Verificación:**

```bash
# Verificar sintaxis sin ejecutar (dry-run)
robot --dryrun simulacro_rfcp/ejercicios_rfcp.robot
```

Debe mostrar `0 tests, 0 failed` (no hay casos de prueba, solo keywords) sin errores de sintaxis.

---

#### Paso A.3 — Ejercicios 6–10: Preguntas de implementación CLI y arquitectura

**Objetivo:** Demostrar dominio de CLI avanzado y arquitectura de proyectos Robot Framework.

**Instrucciones:**

Crea el archivo `simulacro_rfcp/respuestas_cli.md` y responde cada pregunta:

```bash
# Windows
type nul > simulacro_rfcp\respuestas_cli.md

# macOS / Linux
touch simulacro_rfcp/respuestas_cli.md
```

Escribe tus respuestas en `respuestas_cli.md`:

```markdown
# Respuestas CLI y Arquitectura — Simulacro RFCP

## Ejercicio 6
**Pregunta:** Tienes `results/output.xml` de una ejecución donde fallaron
3 de 20 pruebas. ¿Cuál es el comando exacto para reejecutar SOLO esos 3 casos,
guardando el nuevo resultado en `results/rerun.xml`?

**Respuesta:**
<!-- Escribe aquí -->

## Ejercicio 7
**Pregunta:** Escribe el comando para ejecutar pruebas que tengan el tag
"regresion" Y el tag "api", pero NO el tag "lento", contra el entorno
`https://api.telecom.qa` inyectado como variable BASE_URL.

**Respuesta:**
<!-- Escribe aquí -->

## Ejercicio 8
**Pregunta:** ¿Cuál es la diferencia entre `--suite Login` y `--test Login`
en el CLI de Robot Framework? Da un ejemplo de cuándo usarías cada uno.

**Respuesta:**
<!-- Escribe aquí -->

## Ejercicio 9
**Pregunta:** En un pipeline CI/CD, ¿por qué es preferible usar
`--variable ENV:staging` en el comando CLI en lugar de hardcodear
el valor directamente en el archivo .robot?

**Respuesta:**
<!-- Escribe aquí -->

## Ejercicio 10
**Pregunta:** Describe la estructura de carpetas estándar recomendada
para un proyecto Robot Framework profesional con componentes web, API y RPA.
Incluye al menos 6 carpetas/archivos y explica el propósito de cada uno.

**Respuesta:**
<!-- Escribe aquí -->
```

**Soluciones de referencia:**

<details>
<summary>▶ Expandir soluciones — solo después de intentarlo</summary>

```markdown
## Ejercicio 6 — Solución
robot --rerunfailed results/output.xml --output results/rerun.xml tests/

## Ejercicio 7 — Solución
robot --include regresionANDapiANDNOTlento \
      --variable BASE_URL:https://api.telecom.qa \
      tests/

## Ejercicio 8 — Solución
--suite Login: selecciona el ARCHIVO/DIRECTORIO de suite cuyo nombre
  sea "Login" (ej: tests/Login.robot). Útil cuando quieres ejecutar
  toda una suite completa.
--test Login: selecciona CASOS DE PRUEBA individuales cuyo nombre sea
  "Login" dentro de cualquier suite. Útil para ejecutar un test específico
  sin importar en qué suite esté.

## Ejercicio 9 — Solución
Principio de separación de configuración y código. Al usar --variable en CLI:
1. El mismo .robot funciona en dev/qa/prod sin modificaciones
2. Los secretos/URLs no se versionan en el código fuente
3. El pipeline puede parametrizar la ejecución dinámicamente
4. Facilita el mantenimiento: cambiar entorno = cambiar un argumento CLI

## Ejercicio 10 — Solución
proyecto-telecom/
├── tests/          # Suites .robot organizadas por dominio
│   ├── web/        # Pruebas de interfaz web
│   ├── api/        # Pruebas de servicios REST
│   └── rpa/        # Procesos de automatización RPA
├── resources/      # Keywords reutilizables y Page Objects
│   ├── pages/      # Page Object keywords
│   └── common/     # Keywords compartidas entre suites
├── data/           # Datos de prueba: CSV, Excel, JSON
├── results/        # Artefactos de ejecución (gitignored)
├── docs/           # Documentación del proyecto
├── .github/        # Configuración CI/CD GitHub Actions
│   └── workflows/
└── README.md       # Documentación principal del proyecto
```

</details>

**Resultado esperado:** Archivo `respuestas_cli.md` con las 5 respuestas completas.

> ⏱️ **FIN DEL BLOQUE A. Verifica tu tiempo. Si llevas más de 20 minutos, continúa al Bloque B.**

---

### BLOQUE B — Proyecto Final Integrador (34 minutos)

---

#### Paso B.1 — Crear la estructura de carpetas del proyecto final

**Objetivo:** Establecer la arquitectura de directorios estándar del proyecto integrador.

**Instrucciones:**

1. Desde la raíz del proyecto acumulativo del curso, crea la estructura completa:

```bash
# Volver a la raíz del proyecto
cd ..

# Crear estructura completa del proyecto final
mkdir -p proyecto_final/tests/web
mkdir -p proyecto_final/tests/api
mkdir -p proyecto_final/tests/rpa
mkdir -p proyecto_final/resources/pages
mkdir -p proyecto_final/resources/common
mkdir -p proyecto_final/data
mkdir -p proyecto_final/results
mkdir -p proyecto_final/docs
mkdir -p proyecto_final/.github/workflows
```

2. Verifica la estructura creada:

```bash
# Windows (PowerShell)
Get-ChildItem -Recurse proyecto_final | Where-Object {$_.PSIsContainer}

# macOS / Linux
find proyecto_final -type d
```

**Resultado esperado:**

```
proyecto_final/
├── .github/workflows/
├── data/
├── docs/
├── resources/
│   ├── common/
│   └── pages/
├── results/
└── tests/
    ├── api/
    ├── rpa/
    └── web/
```

**Verificación:** La salida del comando `find` o `Get-ChildItem` muestra exactamente 10 directorios.

---

#### Paso B.2 — Ensamblar la suite web con Page Object Model

**Objetivo:** Integrar los artefactos web de prácticas anteriores en la nueva estructura.

**Instrucciones:**

1. Crea el Page Object de la página principal (reutilizando el patrón de P11/P12):

```bash
# Crear archivo Page Object
# Windows: type nul > proyecto_final\resources\pages\home_page.resource
# macOS/Linux:
touch proyecto_final/resources/pages/home_page.resource
```

2. Escribe el contenido del Page Object en `proyecto_final/resources/pages/home_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para la página principal — Demo telecom
Library          SeleniumLibrary

*** Variables ***
${HOME_URL}         https://demoqa.com
${TITULO_ESPERADO}  DEMOQA
${BTN_ELEMENTS}     //h5[text()='Elements']

*** Keywords ***
Abrir Pagina Principal
    [Documentation]    Abre el navegador y navega a la página principal
    Open Browser    ${HOME_URL}    chrome
    Maximize Browser Window
    Wait Until Page Contains Element    ${BTN_ELEMENTS}    timeout=10s

Verificar Titulo Principal
    [Documentation]    Verifica que el título de la página es correcto
    Title Should Contain    ${TITULO_ESPERADO}

Navegar A Seccion Elements
    [Documentation]    Hace clic en la sección Elements
    Click Element    ${BTN_ELEMENTS}
    Wait Until Page Contains    Text Box    timeout=5s

Cerrar Navegador
    [Documentation]    Cierra el navegador al finalizar
    Close All Browsers

Capturar Evidencia
    [Documentation]    Captura screenshot con nombre descriptivo
    [Arguments]    ${nombre}=evidencia
    Capture Page Screenshot    filename=${OUTPUTDIR}/../results/screenshot_${nombre}.png
```

3. Crea la suite web principal en `proyecto_final/tests/web/suite_web.robot`:

```robotframework
*** Settings ***
Documentation     Suite web integrada — Proyecto Final Telecom
...               Cubre navegación básica con Page Object Model
Resource          ../../resources/pages/home_page.resource
Library           SeleniumLibrary

Suite Setup       Abrir Pagina Principal
Suite Teardown    Cerrar Navegador

*** Variables ***
${ENV}            local

*** Test Cases ***

TC-WEB-001 Verificar Titulo Pagina Principal
    [Documentation]    Verifica que la página principal carga correctamente
    [Tags]    smoke    web    regresion
    Verificar Titulo Principal
    Capturar Evidencia    home_titulo

TC-WEB-002 Navegar A Seccion Elements
    [Documentation]    Verifica la navegación a la sección Elements
    [Tags]    smoke    web    navegacion
    Navegar A Seccion Elements
    Page Should Contain    Text Box
    Capturar Evidencia    elements_section

TC-WEB-003 Verificar Carga De Pagina En Entorno
    [Documentation]    Verifica que la URL del entorno responde correctamente
    [Tags]    regresion    web    entorno
    Log    Ejecutando en entorno: ${ENV}
    Page Should Contain Element    ${BTN_ELEMENTS}
```

**Resultado esperado:** Dos archivos creados sin errores de sintaxis.

**Verificación:**

```bash
robot --dryrun proyecto_final/tests/web/suite_web.robot
```

Debe mostrar `3 tests, 0 failed` en modo dry-run.

---

#### Paso B.3 — Ensamblar la suite API data-driven

**Objetivo:** Integrar la suite API con autenticación Bearer y validación JSON.

**Instrucciones:**

1. Crea el archivo de datos CSV en `proyecto_final/data/usuarios_api.csv`:

```csv
${USER_ID},${EXPECTED_NAME},${EXPECTED_EMAIL_DOMAIN}
1,Leanne Graham,@april.biz
2,Ervin Howell,@melissa.tv
3,Clementine Bauch,@yesenia.net
```

2. Crea el resource de keywords API en `proyecto_final/resources/common/api_keywords.resource`:

```robotframework
*** Settings ***
Documentation    Keywords comunes para pruebas API REST
Library          RequestsLibrary
Library          Collections
Library          JSONLibrary

*** Variables ***
${BASE_URL}      https://jsonplaceholder.typicode.com
${AUTH_TOKEN}    Bearer demo-token-telecom-2024

*** Keywords ***
Crear Sesion API
    [Documentation]    Crea sesión HTTP con headers de autenticación
    ${headers}=    Create Dictionary
    ...    Authorization=${AUTH_TOKEN}
    ...    Content-Type=application/json
    Create Session    api_session    ${BASE_URL}    headers=${headers}

Obtener Usuario Por ID
    [Documentation]    Realiza GET /users/{id} y retorna la respuesta
    [Arguments]    ${user_id}
    ${response}=    GET On Session    api_session    /users/${user_id}
    RETURN    ${response}

Validar Respuesta Exitosa
    [Documentation]    Verifica status 200 y estructura JSON básica
    [Arguments]    ${response}
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    id
    Dictionary Should Contain Key    ${json}    name
    Dictionary Should Contain Key    ${json}    email

Validar Nombre Usuario
    [Documentation]    Verifica que el nombre del usuario es el esperado
    [Arguments]    ${response}    ${expected_name}
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json}[name]    ${expected_name}

Validar Dominio Email
    [Documentation]    Verifica que el email contiene el dominio esperado
    [Arguments]    ${response}    ${expected_domain}
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}[email]    ${expected_domain}
```

3. Crea la suite API data-driven en `proyecto_final/tests/api/suite_api.robot`:

```robotframework
*** Settings ***
Documentation     Suite API data-driven — Proyecto Final Telecom
...               Valida endpoints REST con autenticación Bearer
Resource          ../../resources/common/api_keywords.resource
Library           DataDriver    ../../data/usuarios_api.csv    dialect=excel

Suite Setup       Crear Sesion API

*** Variables ***
${USER_ID}                1
${EXPECTED_NAME}          Leanne Graham
${EXPECTED_EMAIL_DOMAIN}  @april.biz

*** Test Cases ***

TC-API-001 Validar Usuario ${USER_ID} Nombre Y Email
    [Documentation]    Valida datos completos del usuario desde CSV
    [Tags]    smoke    api    data-driven    regresion
    ${response}=    Obtener Usuario Por ID    ${USER_ID}
    Validar Respuesta Exitosa    ${response}
    Validar Nombre Usuario    ${response}    ${EXPECTED_NAME}
    Validar Dominio Email    ${response}    ${EXPECTED_EMAIL_DOMAIN}
    Log    Usuario ${USER_ID} validado correctamente: ${EXPECTED_NAME}
```

**Resultado esperado:** Suite API con 3 iteraciones data-driven (una por fila CSV).

**Verificación:**

```bash
robot --dryrun proyecto_final/tests/api/suite_api.robot
```

---

#### Paso B.4 — Ensamblar el proceso RPA básico

**Objetivo:** Integrar el proceso RPA con manejo de archivos en el proyecto final.

**Instrucciones:**

1. Crea datos de prueba para el RPA en `proyecto_final/data/clientes_telecom.csv`:

```csv
cliente_id,nombre,plan,monto
C001,Ana García,Plan Básico,29.99
C002,Carlos López,Plan Premium,59.99
C003,María Torres,Plan Empresarial,149.99
```

2. Crea la suite RPA en `proyecto_final/tests/rpa/suite_rpa.robot`:

```robotframework
*** Settings ***
Documentation     Suite RPA — Proceso de reporte de clientes Telecom
...               Lee CSV, procesa datos y genera reporte de texto
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime

*** Variables ***
${DATA_DIR}       ${CURDIR}/../../data
${RESULTS_DIR}    ${CURDIR}/../../results
${CSV_CLIENTES}   ${DATA_DIR}/clientes_telecom.csv

*** Test Cases ***

TC-RPA-001 Leer Y Procesar Archivo CSV Clientes
    [Documentation]    Lee el CSV de clientes y valida su estructura
    [Tags]    smoke    rpa    archivos
    Verificar Archivo Existe    ${CSV_CLIENTES}
    ${contenido}=    Get File    ${CSV_CLIENTES}
    Should Contain    ${contenido}    cliente_id
    Should Contain    ${contenido}    Plan Básico
    Log    CSV de clientes leído correctamente

TC-RPA-002 Generar Reporte De Procesamiento
    [Documentation]    Genera un reporte TXT con resumen del procesamiento
    [Tags]    smoke    rpa    reporting
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${reporte}=    Construir Reporte Clientes    ${timestamp}
    ${ruta_reporte}=    Set Variable    ${RESULTS_DIR}/reporte_rpa_${timestamp}.txt
    Create File    ${ruta_reporte}    ${reporte}
    File Should Exist    ${ruta_reporte}
    Log    Reporte generado en: ${ruta_reporte}

TC-RPA-003 Validar Integridad De Datos
    [Documentation]    Verifica que todos los clientes tienen monto válido
    [Tags]    regresion    rpa    validacion
    ${contenido}=    Get File    ${CSV_CLIENTES}
    @{lineas}=    Split To Lines    ${contenido}
    ${total_clientes}=    Evaluate    len($lineas) - 1
    Should Be True    ${total_clientes} >= 3
    Log    Total de clientes procesados: ${total_clientes}

*** Keywords ***

Verificar Archivo Existe
    [Documentation]    Verifica existencia de archivo con manejo de error
    [Arguments]    ${ruta}
    TRY
        File Should Exist    ${ruta}
    EXCEPT
        Log    Archivo no encontrado: ${ruta}    level=WARN
        Fail    El archivo de datos RPA no existe: ${ruta}
    END

Construir Reporte Clientes
    [Documentation]    Construye el contenido del reporte como string
    [Arguments]    ${timestamp}
    ${reporte}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    REPORTE DE PROCESAMIENTO TELECOM
    ...    Timestamp: ${timestamp}
    ...    ========================================
    ...    Clientes procesados: C001, C002, C003
    ...    Planes activos: Básico, Premium, Empresarial
    ...    Estado: COMPLETADO
    ...    ========================================
    RETURN    ${reporte}
```

**Resultado esperado:** Suite RPA con 3 casos de prueba funcionales.

**Verificación:**

```bash
robot --dryrun proyecto_final/tests/rpa/suite_rpa.robot
```

---

#### Paso B.5 — Crear el quality gate en Python

**Objetivo:** Implementar el script `quality_gate.py` que lee `output.xml` y aplica criterios de calidad.

**Instrucciones:**

1. Crea el archivo `proyecto_final/quality_gate.py`:

```python
#!/usr/bin/env python3
"""
quality_gate.py — Quality Gate para el Proyecto Final Telecom
Lee output.xml de Robot Framework y retorna exit code 1 si no se
cumplen los criterios de calidad definidos.

Uso:
    python quality_gate.py results/output.xml [--min-pass-rate 80]
"""

import sys
import argparse
import xml.etree.ElementTree as ET
from pathlib import Path


def parse_output_xml(xml_path: str) -> dict:
    """
    Parsea output.xml de Robot Framework y extrae métricas de calidad.

    Returns:
        dict con keys: total, passed, failed, pass_rate, skipped
    """
    path = Path(xml_path)
    if not path.exists():
        print(f"[ERROR] No se encontró el archivo: {xml_path}")
        sys.exit(2)

    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Buscar el elemento statistics/total/stat[@name='All Tests']
    total = 0
    passed = 0
    failed = 0
    skipped = 0

    # RF7 output.xml: statistics > total > stat
    stats_total = root.find(".//statistics/total/stat")
    if stats_total is not None:
        passed = int(stats_total.get("pass", 0))
        failed = int(stats_total.get("fail", 0))
        skipped = int(stats_total.get("skip", 0))
        total = passed + failed + skipped
    else:
        # Fallback: contar elementos test directamente
        tests = root.findall(".//test")
        total = len(tests)
        for test in tests:
            status = test.find("status")
            if status is not None:
                s = status.get("status", "FAIL")
                if s == "PASS":
                    passed += 1
                elif s == "SKIP":
                    skipped += 1
                else:
                    failed += 1

    pass_rate = (passed / total * 100) if total > 0 else 0.0

    return {
        "total": total,
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "pass_rate": round(pass_rate, 2)
    }


def evaluate_quality_gate(metrics: dict, min_pass_rate: float) -> bool:
    """
    Evalúa si las métricas cumplen el quality gate.

    Returns:
        True si pasa el gate, False si falla.
    """
    print("\n" + "=" * 50)
    print("  QUALITY GATE — PROYECTO FINAL TELECOM")
    print("=" * 50)
    print(f"  Total de pruebas  : {metrics['total']}")
    print(f"  Exitosas (PASS)   : {metrics['passed']}")
    print(f"  Fallidas (FAIL)   : {metrics['failed']}")
    print(f"  Omitidas (SKIP)   : {metrics['skipped']}")
    print(f"  Tasa de éxito     : {metrics['pass_rate']}%")
    print(f"  Umbral mínimo     : {min_pass_rate}%")
    print("-" * 50)

    if metrics['total'] == 0:
        print("  [WARN] No se encontraron pruebas en output.xml")
        print("=" * 50)
        return False

    gate_passed = metrics['pass_rate'] >= min_pass_rate

    if gate_passed:
        print(f"  [PASS] Quality Gate APROBADO ✓")
    else:
        print(f"  [FAIL] Quality Gate RECHAZADO ✗")
        print(f"         Tasa actual ({metrics['pass_rate']}%) < "
              f"Umbral ({min_pass_rate}%)")

    print("=" * 50 + "\n")
    return gate_passed


def main():
    parser = argparse.ArgumentParser(
        description="Quality Gate para suites Robot Framework"
    )
    parser.add_argument(
        "output_xml",
        help="Ruta al archivo output.xml generado por Robot Framework"
    )
    parser.add_argument(
        "--min-pass-rate",
        type=float,
        default=80.0,
        help="Porcentaje mínimo de pruebas exitosas (default: 80.0)"
    )
    args = parser.parse_args()

    metrics = parse_output_xml(args.output_xml)
    gate_passed = evaluate_quality_gate(metrics, args.min_pass_rate)

    sys.exit(0 if gate_passed else 1)


if __name__ == "__main__":
    main()
```

**Resultado esperado:** Script `quality_gate.py` creado con lógica de evaluación completa.

**Verificación rápida de sintaxis:**

```bash
python -c "import py_compile; py_compile.compile('proyecto_final/quality_gate.py'); print('Sintaxis OK')"
```

---

#### Paso B.6 — Crear el pipeline GitHub Actions

**Objetivo:** Configurar el workflow de CI/CD con quality gates y ejecución automática.

**Instrucciones:**

1. Crea el archivo `proyecto_final/.github/workflows/robot_ci.yml`:

```yaml
# robot_ci.yml — Pipeline CI/CD para el Proyecto Final Telecom
# Ejecuta smoke tests, genera reportes y aplica quality gate
name: Robot Framework CI — Proyecto Final Telecom

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Entorno de ejecución'
        required: true
        default: 'qa'
        type: choice
        options:
          - qa
          - staging

env:
  PYTHON_VERSION: '3.11'
  MIN_PASS_RATE: '80'

jobs:
  smoke-tests:
    name: 🚀 Smoke Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout código fuente
        uses: actions/checkout@v4

      - name: Configurar Python ${{ env.PYTHON_VERSION }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Instalar dependencias
        run: |
          python -m pip install --upgrade pip
          pip install \
            robotframework \
            robotframework-seleniumlibrary \
            robotframework-requests \
            robotframework-jsonlibrary \
            robotframework-datadriver[CSV] \
            openpyxl \
            lxml

      - name: Crear directorio de resultados
        run: mkdir -p results

      - name: Ejecutar Smoke Tests — Suite API
        run: |
          robot \
            --include smoke \
            --variable ENV:${{ github.event.inputs.environment || 'qa' }} \
            --output results/smoke_api_output.xml \
            --log results/smoke_api_log.html \
            --report results/smoke_api_report.html \
            tests/api/suite_api.robot
        continue-on-error: true

      - name: Ejecutar Smoke Tests — Suite RPA
        run: |
          robot \
            --include smoke \
            --variable ENV:${{ github.event.inputs.environment || 'qa' }} \
            --output results/smoke_rpa_output.xml \
            --log results/smoke_rpa_log.html \
            --report results/smoke_rpa_report.html \
            tests/rpa/suite_rpa.robot
        continue-on-error: true

      - name: Consolidar reportes con rebot
        run: |
          rebot \
            --output results/consolidated_output.xml \
            --log results/consolidated_log.html \
            --report results/consolidated_report.html \
            --name "Proyecto Final Telecom — Smoke" \
            results/smoke_api_output.xml \
            results/smoke_rpa_output.xml
        continue-on-error: true

      - name: Aplicar Quality Gate (mínimo ${{ env.MIN_PASS_RATE }}%)
        run: |
          python quality_gate.py \
            results/consolidated_output.xml \
            --min-pass-rate ${{ env.MIN_PASS_RATE }}

      - name: Publicar reportes como artefactos
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: robot-reports-${{ github.run_number }}
          path: |
            results/*.html
            results/*.xml
            results/*.png
          retention-days: 30

      - name: Reejecutar fallidos (si los hay)
        if: failure()
        run: |
          robot \
            --rerunfailed results/consolidated_output.xml \
            --variable ENV:${{ github.event.inputs.environment || 'qa' }} \
            --output results/rerun_output.xml \
            --log results/rerun_log.html \
            tests/api/suite_api.robot \
            tests/rpa/suite_rpa.robot
        continue-on-error: true

  regression-tests:
    name: 🔄 Regression Tests
    runs-on: ubuntu-latest
    needs: smoke-tests
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Checkout código fuente
        uses: actions/checkout@v4

      - name: Configurar Python ${{ env.PYTHON_VERSION }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Instalar dependencias
        run: |
          pip install \
            robotframework \
            robotframework-seleniumlibrary \
            robotframework-requests \
            robotframework-jsonlibrary \
            robotframework-datadriver[CSV] \
            openpyxl lxml

      - name: Ejecutar Regresión Completa
        run: |
          robot \
            --include regresion \
            --exclude wip \
            --variable ENV:qa \
            --output results/regression_output.xml \
            --log results/regression_log.html \
            --report results/regression_report.html \
            tests/
        continue-on-error: true

      - name: Quality Gate — Regresión (mínimo ${{ env.MIN_PASS_RATE }}%)
        run: |
          python quality_gate.py \
            results/regression_output.xml \
            --min-pass-rate ${{ env.MIN_PASS_RATE }}
```

**Resultado esperado:** Archivo YAML de 120+ líneas con dos jobs: `smoke-tests` y `regression-tests`.

**Verificación de sintaxis YAML:**

```bash
python -c "
import yaml
with open('proyecto_final/.github/workflows/robot_ci.yml') as f:
    yaml.safe_load(f)
print('YAML válido')
"
```

> Si `yaml` no está instalado: `pip install pyyaml`

---

#### Paso B.7 — Ejecutar el proyecto final localmente

**Objetivo:** Validar que todas las suites se ejecutan correctamente antes del commit.

**Instrucciones:**

1. Navega al directorio del proyecto final:

```bash
cd proyecto_final
```

2. Ejecuta los smoke tests de API y RPA con las opciones CLI aprendidas:

```bash
# Ejecutar smoke tests de API
robot \
  --include smoke \
  --variable ENV:local \
  --output results/smoke_api_output.xml \
  --log results/smoke_api_log.html \
  --report results/smoke_api_report.html \
  tests/api/suite_api.robot
```

```bash
# Ejecutar smoke tests de RPA
robot \
  --include smoke \
  --variable ENV:local \
  --output results/smoke_rpa_output.xml \
  --log results/smoke_rpa_log.html \
  --report results/smoke_rpa_report.html \
  tests/rpa/suite_rpa.robot
```

3. Consolidar reportes con `rebot`:

```bash
rebot \
  --output results/consolidated_output.xml \
  --log results/consolidated_log.html \
  --report results/consolidated_report.html \
  --name "Proyecto Final Telecom" \
  results/smoke_api_output.xml \
  results/smoke_rpa_output.xml
```

4. Aplicar el quality gate:

```bash
python quality_gate.py results/consolidated_output.xml --min-pass-rate 80
echo "Exit code del quality gate: $?"
```

**Resultado esperado:**

```
==================================================
  QUALITY GATE — PROYECTO FINAL TELECOM
==================================================
  Total de pruebas  : 6
  Exitosas (PASS)   : 6
  Fallidas (FAIL)   : 0
  Omitidas (SKIP)   : 0
  Tasa de éxito     : 100.0%
  Umbral mínimo     : 80.0%
--------------------------------------------------
  [PASS] Quality Gate APROBADO ✓
==================================================
```

**Verificación:**

```bash
# El exit code debe ser 0 (gate aprobado)
# Windows PowerShell:
echo $LASTEXITCODE
# macOS/Linux:
echo $?
```

---

#### Paso B.8 — Crear el README.md del portfolio

**Objetivo:** Documentar el proyecto con un README profesional que sirva como portfolio técnico.

**Instrucciones:**

1. Crea `proyecto_final/README.md` con el siguiente contenido:

```markdown
# 🤖 Proyecto Final Telecom — Robot Framework

![CI Status](https://github.com/TU_USUARIO/proyecto-final-telecom/actions/workflows/robot_ci.yml/badge.svg)
![Python](https://img.shields.io/badge/python-3.10%2B-blue)
![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.x-red)
![License](https://img.shields.io/badge/license-MIT-green)

> Proyecto integrador de automatización de pruebas para la empresa ficticia
> **TelecomDemo S.A.** — Cubre automatización web, API REST, RPA y CI/CD.

---

## 📋 Tabla de Contenidos

- [Arquitectura del Proyecto](#arquitectura)
- [Prerrequisitos](#prerrequisitos)
- [Instalación](#instalación)
- [Ejecución](#ejecución)
- [CI/CD Pipeline](#cicd)
- [Quality Gate](#quality-gate)
- [Reportes](#reportes)

---

## 🏗️ Arquitectura del Proyecto <a name="arquitectura"></a>

```
proyecto_final/
├── .github/
│   └── workflows/
│       └── robot_ci.yml      # Pipeline GitHub Actions
├── tests/
│   ├── web/
│   │   └── suite_web.robot   # Suite web con Page Object Model
│   ├── api/
│   │   └── suite_api.robot   # Suite API data-driven
│   └── rpa/
│       └── suite_rpa.robot   # Proceso RPA con archivos
├── resources/
│   ├── pages/
│   │   └── home_page.resource  # Page Objects
│   └── common/
│       └── api_keywords.resource  # Keywords API reutilizables
├── data/
│   ├── usuarios_api.csv      # Datos para pruebas API
│   └── clientes_telecom.csv  # Datos para proceso RPA
├── results/                  # Artefactos de ejecución (gitignored)
├── docs/                     # Documentación adicional
├── quality_gate.py           # Script de quality gate
└── README.md
```

---

## ⚙️ Prerrequisitos <a name="prerrequisitos"></a>

- Python 3.10+
- Git 2.40+
- Google Chrome (última versión estable)
- Cuenta GitHub (para CI/CD)

---

## 📦 Instalación <a name="instalación"></a>

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/proyecto-final-telecom.git
cd proyecto-final-telecom

# 2. Crear y activar entorno virtual
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate

# 3. Instalar dependencias
pip install robotframework \
            robotframework-seleniumlibrary \
            robotframework-requests \
            robotframework-jsonlibrary \
            robotframework-datadriver[CSV] \
            openpyxl lxml pyyaml
```

---

## 🚀 Ejecución <a name="ejecución"></a>

### Smoke Tests (rápidos, ~2 min)

```bash
# Solo API
robot --include smoke --variable ENV:local \
      --output results/smoke_api_output.xml \
      tests/api/suite_api.robot

# Solo RPA
robot --include smoke --variable ENV:local \
      --output results/smoke_rpa_output.xml \
      tests/rpa/suite_rpa.robot
```

### Regresión Completa

```bash
robot --include regresion --exclude wip \
      --variable ENV:qa \
      --output results/regression_output.xml \
      tests/
```

### Reejecutar Solo Fallidos

```bash
robot --rerunfailed results/regression_output.xml \
      --output results/rerun_output.xml \
      tests/
```

### Reporte Consolidado

```bash
rebot --output results/consolidated_output.xml \
      --log results/consolidated_log.html \
      --report results/consolidated_report.html \
      results/smoke_api_output.xml \
      results/smoke_rpa_output.xml
```

---

## 🔄 CI/CD Pipeline <a name="cicd"></a>

El pipeline se activa automáticamente en:
- `push` a `main` o `develop`
- `pull_request` a `main`
- Ejecución manual con selección de entorno

**Jobs:**
1. **smoke-tests**: Ejecuta pruebas con tag `smoke`, consolida reportes y aplica quality gate
2. **regression-tests**: Ejecuta regresión completa (solo en `main`)

---

## 🎯 Quality Gate <a name="quality-gate"></a>

El script `quality_gate.py` lee `output.xml` y retorna:
- **Exit code 0**: Tasa de éxito ≥ 80% → Pipeline continúa ✓
- **Exit code 1**: Tasa de éxito < 80% → Pipeline falla ✗

```bash
# Uso manual
python quality_gate.py results/consolidated_output.xml --min-pass-rate 80
```

---

## 📊 Reportes <a name="reportes"></a>

Los reportes se generan en `results/` después de cada ejecución:

| Archivo | Descripción |
|---|---|
| `consolidated_report.html` | Reporte visual consolidado |
| `consolidated_log.html` | Log detallado de ejecución |
| `consolidated_output.xml` | Datos crudos para quality gate |
| `screenshot_*.png` | Evidencias de pruebas web |

---

## 🏷️ Estrategia de Tags

| Tag | Descripción | Uso en CI |
|---|---|---|
| `smoke` | Pruebas de humo básicas | Gate inicial |
| `regresion` | Regresión completa | Push a main |
| `web` | Pruebas de interfaz web | Filtro por tecnología |
| `api` | Pruebas de servicios REST | Filtro por tecnología |
| `rpa` | Procesos de automatización | Filtro por tecnología |
| `wip` | En desarrollo | Excluido de CI |

---

*Proyecto desarrollado como parte del curso de Robot Framework — Módulo 9*
```

**Resultado esperado:** `README.md` completo con todas las secciones documentadas.

---

#### Paso B.9 — Inicializar repositorio Git y hacer commit

**Objetivo:** Versionar el proyecto final y prepararlo para GitHub Actions.

**Instrucciones:**

1. Crea el archivo `.gitignore`:

```bash
# Crear .gitignore en proyecto_final/
cat > proyecto_final/.gitignore << 'EOF'
# Resultados de ejecución (no versionar)
results/
*.pyc
__pycache__/
venv/
.env

# Screenshots temporales
*.png

# Artefactos Robot Framework
output.xml
log.html
report.html
EOF
```

> **Windows PowerShell:** Crea el archivo manualmente en VS Code con el contenido anterior.

2. Inicializa el repositorio y realiza el primer commit:

```bash
cd proyecto_final
git init
git add .
git status
git commit -m "feat: proyecto final integrador Robot Framework

- Suite web con Page Object Model (TC-WEB-001 a TC-WEB-003)
- Suite API data-driven con autenticación Bearer (TC-API-001)
- Proceso RPA con archivos CSV (TC-RPA-001 a TC-RPA-003)
- Quality gate Python con umbral 80% de éxito
- Pipeline GitHub Actions con smoke + regression jobs
- README completo con badges, arquitectura e instrucciones"
```

3. Conecta con GitHub (reemplaza `TU_USUARIO` con tu usuario real):

```bash
git remote add origin https://github.com/TU_USUARIO/proyecto-final-telecom.git
git branch -M main
git push -u origin main
```

**Resultado esperado:** Repositorio publicado en GitHub con el pipeline visible en la pestaña **Actions**.

**Verificación:**

Navega a `https://github.com/TU_USUARIO/proyecto-final-telecom/actions` y verifica que el workflow `Robot Framework CI — Proyecto Final Telecom` aparece en ejecución o completado.

---

## Validación y Pruebas

### Lista de verificación del proyecto completo

Ejecuta esta secuencia de validación final antes de considerar el laboratorio completo:

```bash
cd proyecto_final

# 1. Verificar estructura de carpetas
echo "=== Estructura del proyecto ==="
find . -not -path './.git/*' -not -path './results/*' -not -path './__pycache__/*' | sort

# 2. Dry-run de todas las suites
echo "=== Dry-run completo ==="
robot --dryrun tests/api/suite_api.robot tests/rpa/suite_rpa.robot

# 3. Ejecutar smoke tests reales
echo "=== Smoke tests reales ==="
robot \
  --include smoke \
  --variable ENV:local \
  --output results/validation_output.xml \
  --log results/validation_log.html \
  --report results/validation_report.html \
  tests/api/suite_api.robot tests/rpa/suite_rpa.robot

# 4. Aplicar quality gate
echo "=== Quality Gate ==="
python quality_gate.py results/validation_output.xml --min-pass-rate 80

# 5. Verificar que el YAML del pipeline es válido
echo "=== Validación YAML ==="
python -c "import yaml; yaml.safe_load(open('.github/workflows/robot_ci.yml')); print('YAML OK')"

# 6. Verificar que el README existe y tiene contenido
echo "=== README ==="
wc -l README.md
```

### Criterios de aprobación

| Criterio | Resultado esperado |
|---|---|
| Dry-run sin errores | `0 tests, 0 failed` (modo dry-run) |
| Smoke tests API | 3 casos PASS (data-driven desde CSV) |
| Smoke tests RPA | 2 casos PASS (TC-RPA-001 y TC-RPA-002) |
| Quality gate | Exit code 0, tasa ≥ 80% |
| YAML válido | `YAML OK` sin excepciones |
| README completo | Más de 80 líneas |
| Commit en GitHub | Pipeline visible en Actions |

---

## Solución de Problemas

### Problema 1: `DataDriver` no genera las iteraciones del CSV

**Síntomas:**
- La suite API ejecuta solo 1 caso de prueba en lugar de 3.
- El log muestra `DataDriver: No test data found` o el test se ejecuta con los valores de `*** Variables ***`.
- `robot --dryrun tests/api/suite_api.robot` muestra `1 test` en lugar de `3 tests`.

**Causa:**
El paquete `robotframework-datadriver` fue instalado sin el extra `[CSV]`, por lo que no puede leer archivos `.csv`. La instalación base (`pip install robotframework-datadriver`) no incluye el parser CSV.

**Solución:**

```bash
# Desinstalar la versión base e instalar con extras CSV
pip uninstall robotframework-datadriver -y
pip install "robotframework-datadriver[CSV]"

# Verificar la instalación
pip show robotframework-datadriver
python -c "from DataDriver.ReaderConfig import ReaderConfig; print('CSV parser OK')"

# Verificar también que la ruta al CSV es correcta (relativa al .robot)
# La línea en *** Settings *** debe ser:
# Library    DataDriver    ../../data/usuarios_api.csv    dialect=excel
```

---

### Problema 2: El quality gate retorna exit code 2 con `No se encontró el archivo`

**Síntomas:**
- `python quality_gate.py results/consolidated_output.xml` imprime `[ERROR] No se encontró el archivo`.
- El pipeline de GitHub Actions falla en el paso "Aplicar Quality Gate" aunque los tests pasaron.
- El archivo `consolidated_output.xml` no existe en `results/`.

**Causa:**
El paso de `rebot` que consolida los outputs falló silenciosamente (porque uno de los `smoke_*_output.xml` no se generó), y el paso de quality gate se ejecuta igualmente porque el paso anterior tiene `continue-on-error: true`. El archivo consolidado no existe porque `rebot` no pudo procesarlo.

**Solución:**

```bash
# Verificar qué archivos existen en results/
ls -la results/

# Si falta smoke_api_output.xml o smoke_rpa_output.xml, reejecutar
# manualmente la suite que falló:
robot --include smoke \
      --variable ENV:local \
      --output results/smoke_api_output.xml \
      tests/api/suite_api.robot

# Luego regenerar el consolidado:
rebot \
  --output results/consolidated_output.xml \
  --log results/consolidated_log.html \
  --report results/consolidated_report.html \
  results/smoke_api_output.xml \
  results/smoke_rpa_output.xml

# Verificar que el XML existe antes de ejecutar el quality gate:
python -c "
from pathlib import Path
p = Path('results/consolidated_output.xml')
print(f'Existe: {p.exists()}, Tamaño: {p.stat().st_size if p.exists() else 0} bytes')
"
```

En el pipeline, considera agregar una verificación explícita antes del quality gate:

```yaml
- name: Verificar que output.xml existe
  run: |
    test -f results/consolidated_output.xml || \
    (echo "consolidated_output.xml no encontrado" && exit 1)
```

---

## Limpieza

Después de completar el laboratorio, ejecuta los siguientes pasos de limpieza:

```bash
# Desde el directorio proyecto_final/

# 1. Limpiar artefactos de resultados locales (ya están en .gitignore)
# Windows PowerShell:
Remove-Item -Recurse -Force results\* -ErrorAction SilentlyContinue

# macOS/Linux:
rm -rf results/*

# 2. Limpiar caché de Python
# Windows:
for /d /r . %d in (__pycache__) do @if exist "%d" rd /s /q "%d"

# macOS/Linux:
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null; true

# 3. Limpiar carpeta de simulacro (opcional, conservar para referencia)
# rm -rf ../simulacro_rfcp/

# 4. Desactivar el entorno virtual
deactivate

# 5. Verificar que el repositorio está limpio
git status
```

> **Nota:** Los artefactos en `results/` están en `.gitignore` y no se versiones. Los archivos de código (`.robot`, `.resource`, `.py`, `.yml`, `.md`) deben permanecer en el repositorio.

---

## Resumen

En este laboratorio final de 54 minutos completaste el ciclo completo de un profesional de automatización:

### Logros del Bloque A — Simulacro RFCP (20 min)

| Ejercicio | Habilidad demostrada |
|---|---|
| E1–E2 | Corrección de sintaxis RF7: IF nativo, keywords web |
| E3 | Validación JSON con `Dictionary Should Contain Key` |
| E4 | Manejo de errores con `TRY/EXCEPT` nativo (RF5+) |
| E5–E7 | Dominio del CLI: `--include`, `--exclude`, `--rerunfailed`, paretags |
| E8–E10 | Arquitectura de proyectos y principios de diseño |

### Logros del Bloque B — Proyecto Final (34 min)

| Entregable | Descripción |
|---|---|
| `tests/web/suite_web.robot` | Suite web con Page Object Model y captura de evidencias |
| `tests/api/suite_api.robot` | Suite API data-driven con autenticación Bearer |
| `tests/rpa/suite_rpa.robot` | Proceso RPA con lectura CSV y generación de reportes |
| `quality_gate.py` | Script Python que lee `output.xml` y aplica umbral del 80% |
| `.github/workflows/robot_ci.yml` | Pipeline GitHub Actions con 2 jobs y quality gates |
| `README.md` | Portfolio técnico con badges, arquitectura e instrucciones |

### Conceptos CLI aplicados en este laboratorio

```bash
# Filtrado por tags (Lección 9.1)
robot --include smoke --exclude wip tests/

# Inyección de variables por entorno
robot --variable ENV:qa --variable BASE_URL:https://api.qa.com tests/

# Reejecutar solo fallidos
robot --rerunfailed results/output.xml tests/

# Paretags para lógica booleana
robot --include regresionANDapiANDNOTlento tests/

# Consolidación con rebot
rebot --output consolidated.xml output1.xml output2.xml
```

### Recursos adicionales

- [Robot Framework User Guide — CLI Options](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#using-command-line-options)
- [GitHub Actions — Workflow syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
- [Robot Framework RFCP Certification](https://robotframework.org/foundation/rfcp.html)
- [rebot — Combining outputs](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#combining-outputs-using-rebot)
- [DataDriver Library](https://github.com/Snooz82/robotframework-datadriver)

---
*Lab 09-00-02 — Módulo 9: Integración Final y CI/CD | Curso Robot Framework Profesional*
