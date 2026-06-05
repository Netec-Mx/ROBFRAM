# Práctica 2: Análisis del reporte HTML generado

## Metadatos

| Campo            | Detalle                                      |
|------------------|----------------------------------------------|
| **Duración**     | 72 minutos                                   |
| **Complejidad**  | Fácil                                        |
| **Nivel Bloom**  | Aplicar                                      |
| **Módulo**       | 01 — Arquitectura y ecosistema de Robot Framework |
| **Laboratorio**  | 01-00-02                                     |

---

## Descripción general

En este laboratorio ampliarás la suite creada en la Práctica 1 con nuevos test cases que producen resultados deliberadamente distintos: un caso exitoso, un caso fallido con `Should Be Equal` y un caso que emite un mensaje de nivel `WARN`. Ejecutarás la suite con distintas combinaciones de flags (`--log`, `--report`, `--output`, `--loglevel`) y analizarás sistemáticamente los artefactos generados: `report.html`, `log.html` y `output.xml`. Al finalizar comprenderás la jerarquía de ejecución que Robot Framework registra y el papel de `output.xml` como fuente de datos para integraciones CI/CD.

---

## Objetivos de aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Navegar e interpretar las secciones principales de `report.html` (estadísticas globales, tabla de tests, estado de la suite) y de `log.html` (árbol de ejecución, timestamps, mensajes por nivel).
- [ ] Identificar en `log.html` la jerarquía completa: **suite → test case → keyword → mensaje de log** con niveles `INFO`, `WARN` y `FAIL`.
- [ ] Introducir un test case fallido y analizar cómo el reporte refleja el código de error, el mensaje y la traza de la excepción.
- [ ] Usar los flags `--log`, `--report`, `--output` y `--loglevel DEBUG` para personalizar los artefactos de salida de Robot Framework.
- [ ] Describir el rol de `output.xml` como fuente de datos de los reportes y su relevancia en pipelines CI/CD.

---

## Prerrequisitos

### Conocimiento previo

| Requisito | Nivel esperado |
|-----------|---------------|
| Haber completado el Lab 01-00-01 | Obligatorio — la suite `mi_primera_suite.robot` debe estar funcional |
| Conocimiento básico de la sintaxis `.robot` (Settings, Test Cases, Keywords) | Básico |
| Navegación de archivos HTML en el navegador | Básico |
| Uso de terminal / línea de comandos | Básico |

### Acceso y recursos

- Proyecto del Lab 01-00-01 ubicado en `~/rf-curso/modulo01/` (o la ruta equivalente usada en la sesión anterior).
- Entorno virtual Python (`venv`) activo con Robot Framework 7.x instalado.
- VS Code abierto sobre la carpeta del proyecto.
- Navegador web (Chrome 120+ o Firefox 121+) disponible para abrir los reportes HTML.

---

## Entorno de laboratorio

### Hardware mínimo recomendado

| Componente | Mínimo |
|------------|--------|
| Procesador | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos) |
| RAM | 8 GB |
| Almacenamiento libre | 5 GB |
| Pantalla | 1280 × 768 px |
| Conexión a internet | No requerida para este lab |

### Software requerido

| Software | Versión mínima |
|----------|---------------|
| Python | 3.10 |
| Robot Framework | 7.x |
| VS Code | 1.85 |
| Robot Framework Language Server (extensión) | 1.12 |
| Navegador web | Chrome 120+ / Firefox 121+ |

### Verificación del entorno y activación del venv

Antes de comenzar, abre una terminal y activa el entorno virtual del curso.

**Windows (cmd):**
```cmd
cd %USERPROFILE%\rf-curso
venv\Scripts\activate
```

**Windows (PowerShell):**
```powershell
cd $HOME\rf-curso
.\venv\Scripts\Activate.ps1
```

**macOS / Linux (bash/zsh):**
```bash
cd ~/rf-curso
source venv/bin/activate
```

Verifica que Robot Framework esté disponible:

```bash
robot --version
```

**Salida esperada:**
```
Robot Framework 7.x.x (Python 3.x.x on ...)
```

> ⚠️ **Importante:** Si el prompt de tu terminal no muestra el prefijo `(venv)`, el entorno virtual **no está activo**. No continúes hasta resolverlo.

---

## Instrucciones paso a paso

### Paso 1 — Revisar la suite existente del Lab 01-00-01

**Objetivo:** Confirmar el estado inicial del proyecto antes de ampliar la suite.

**Instrucciones:**

1. Navega a la carpeta del módulo 01:

   **Windows:**
   ```cmd
   cd %USERPROFILE%\rf-curso\modulo01
   dir
   ```

   **macOS / Linux:**
   ```bash
   cd ~/rf-curso/modulo01
   ls -la
   ```

2. Abre `mi_primera_suite.robot` en VS Code:

   ```bash
   code mi_primera_suite.robot
   ```

3. Confirma que el archivo contiene al menos dos test cases del Lab 01-00-01. El contenido de referencia es similar al siguiente:

   ```robotframework
   *** Settings ***
   Documentation    Mi primera suite de Robot Framework

   *** Test Cases ***
   Primer Test Exitoso
       Log    Hola desde Robot Framework    INFO
       Log To Console    Ejecutando el primer test

   Segundo Test Con Verificacion
       ${resultado}=    Set Variable    42
       Should Be Equal As Integers    ${resultado}    42
   ```

**Salida esperada:** El archivo se abre en VS Code sin errores de sintaxis (el Language Server no muestra subrayados rojos).

**Verificación:** Ejecuta la suite una vez para confirmar que todos los tests pasan:

```bash
robot mi_primera_suite.robot
```

La salida de consola debe terminar con:
```
2 tests, 2 passed, 0 failed
```

---

### Paso 2 — Ampliar la suite con tres nuevos test cases

**Objetivo:** Agregar casos que produzcan resultados variados: un `WARN`, un fallo deliberado y un caso con múltiples niveles de log.

**Instrucciones:**

1. En VS Code, abre `mi_primera_suite.robot` y reemplaza su contenido completo con el siguiente código. Lee cada sección con atención — los comentarios en español explican el propósito de cada bloque:

   ```robotframework
   *** Settings ***
   Documentation    Suite ampliada para análisis de reportes HTML
   ...              Laboratorio 01-00-02 — Robot Framework 7.x

   *** Variables ***
   ${MENSAJE_BIENVENIDA}    Bienvenido al sistema de telecomunicaciones
   ${CODIGO_ESPERADO}       TLC-001
   ${CODIGO_RECIBIDO}       TLC-999

   *** Test Cases ***

   # ─────────────────────────────────────────────
   # Test 1: Caso exitoso heredado del Lab 01-00-01
   # ─────────────────────────────────────────────
   Primer Test Exitoso
       [Documentation]    Verifica que el sistema de log funciona correctamente.
       Log    Hola desde Robot Framework    INFO
       Log To Console    Ejecutando el primer test

   # ─────────────────────────────────────────────
   # Test 2: Verificación exitosa con variable
   # ─────────────────────────────────────────────
   Verificacion De Variable Exitosa
       [Documentation]    Comprueba que una variable tiene el valor esperado.
       ${resultado}=    Set Variable    42
       Should Be Equal As Integers    ${resultado}    42
       Log    Verificacion completada: resultado=${resultado}    INFO

   # ─────────────────────────────────────────────
   # Test 3: Log con nivel WARN
   # ─────────────────────────────────────────────
   Test Con Advertencia De Configuracion
       [Documentation]    Emite un mensaje WARN para simular una condición de alerta.
       Log    Iniciando verificacion de configuracion    INFO
       Log    ADVERTENCIA: El tiempo de respuesta supera el umbral recomendado (200ms)    WARN
       Log    Verificacion completada con advertencias    INFO

   # ─────────────────────────────────────────────
   # Test 4: Fallo deliberado con Should Be Equal
   # ─────────────────────────────────────────────
   Test Con Fallo Deliberado
       [Documentation]    Este test FALLA intencionalmente para analizar el reporte de error.
       Log    Simulando validacion de codigo de cliente    INFO
       Should Be Equal    ${CODIGO_ESPERADO}    ${CODIGO_RECIBIDO}
       Log    Esta linea NO se ejecutara porque el test ya fallo    INFO

   # ─────────────────────────────────────────────
   # Test 5: Múltiples mensajes de log en niveles distintos
   # ─────────────────────────────────────────────
   Test Con Multiples Niveles De Log
       [Documentation]    Demuestra los niveles INFO y WARN en un mismo test case.
       Log    Paso 1: Conectando al sistema de facturacion    INFO
       Log    Paso 2: Autenticacion exitosa    INFO
       Log    Paso 3: Recuperando facturas pendientes    INFO
       Log    Paso 4: Se encontraron 3 facturas con fecha vencida    WARN
       Log    Paso 5: Proceso finalizado    INFO
   ```

2. Guarda el archivo con **Ctrl+S** (Windows/Linux) o **Cmd+S** (macOS).

**Salida esperada:** VS Code muestra el archivo sin errores de sintaxis. El Language Server resalta las keywords correctamente.

**Verificación:** Confirma visualmente que el archivo tiene exactamente 5 secciones `Test Cases` y que las variables están definidas en la sección `*** Variables ***`.

---

### Paso 3 — Primera ejecución: artefactos con nombres por defecto

**Objetivo:** Ejecutar la suite completa y observar los artefactos generados con los nombres estándar de Robot Framework.

**Instrucciones:**

1. Asegúrate de estar en la carpeta `modulo01` con el venv activo.

2. Ejecuta la suite sin flags adicionales:

   ```bash
   robot mi_primera_suite.robot
   ```

3. Observa la salida de consola. Deberías ver algo similar a:

   ```
   ==============================================================================
   Mi Primera Suite
   ==============================================================================
   Primer Test Exitoso                                                   | PASS |
   ------------------------------------------------------------------------------
   Verificacion De Variable Exitosa                                      | PASS |
   ------------------------------------------------------------------------------
   Test Con Advertencia De Configuracion                                 | PASS |
   ------------------------------------------------------------------------------
   Test Con Fallo Deliberado                                             | FAIL |
   AssertionError: TLC-001 != TLC-999
   ------------------------------------------------------------------------------
   Test Con Multiples Niveles De Log                                     | PASS |
   ==============================================================================
   Mi Primera Suite                                                      | FAIL |
   5 tests, 4 passed, 1 failed
   ==============================================================================
   Output:  /ruta/a/modulo01/output.xml
   Log:     /ruta/a/modulo01/log.html
   Report:  /ruta/a/modulo01/report.html
   ```

4. Lista los archivos generados:

   **Windows:**
   ```cmd
   dir *.html *.xml
   ```

   **macOS / Linux:**
   ```bash
   ls -lh output.xml log.html report.html
   ```

**Salida esperada:** Tres archivos presentes — `output.xml`, `log.html` y `report.html`. El tamaño de `log.html` será considerablemente mayor que el de `report.html`.

**Verificación:** El resumen de consola indica `5 tests, 4 passed, 1 failed`. El test `Test Con Fallo Deliberado` aparece marcado como `FAIL`.

---

### Paso 4 — Análisis de report.html

**Objetivo:** Identificar y comprender cada sección del reporte de resumen.

**Instrucciones:**

1. Abre `report.html` en tu navegador:

   **Windows:**
   ```cmd
   start report.html
   ```

   **macOS:**
   ```bash
   open report.html
   ```

   **Linux:**
   ```bash
   xdg-open report.html
   ```

2. Localiza y analiza cada una de las siguientes secciones. Para cada una, anota en un comentario en tu archivo `.robot` (o en papel) lo que observas:

   **Sección A — Encabezado de estado global:**
   - Busca el indicador grande de estado (círculo o banner rojo/verde).
   - El estado debe ser **FAIL** porque uno de los 5 tests falló.
   - Anota la fecha y hora de ejecución que aparece en el encabezado.

   **Sección B — Statistics by Suite:**
   - Observa la barra de progreso para la suite `Mi Primera Suite`.
   - Identifica los números: total de tests, cuántos pasaron (verde) y cuántos fallaron (rojo).
   - Valores esperados: **5 total, 4 pass, 1 fail**.

   **Sección C — Statistics by Tag:**
   - En este punto estará vacía o mostrará "No tags". Esto es normal — aún no hemos asignado tags.
   - Toma nota: en laboratorios posteriores usaremos tags para filtrar ejecuciones.

   **Sección D — Test Details (tabla de tests):**
   - Localiza la tabla que lista los 5 test cases.
   - Identifica la columna de estado: 4 filas en verde (`PASS`) y 1 en rojo (`FAIL`).
   - Haz clic sobre el nombre **Test Con Fallo Deliberado** — esto te llevará directamente a la entrada correspondiente en `log.html`.

3. Observa que `report.html` **no contiene** los detalles de ejecución paso a paso. Su propósito es dar una **vista ejecutiva** rápida.

**Salida esperada:** El reporte muestra el banner rojo de FAIL, las estadísticas correctas y la tabla de tests con los estados correspondientes.

**Verificación:** El enlace desde la tabla de tests lleva a la sección correcta de `log.html` con el detalle del fallo.

---

### Paso 5 — Análisis de log.html: jerarquía de ejecución

**Objetivo:** Navegar el árbol de ejecución en `log.html` e identificar la jerarquía suite → test case → keyword → mensaje.

**Instrucciones:**

1. Abre `log.html` en tu navegador (si no se abrió automáticamente desde el paso anterior):

   **Windows:**
   ```cmd
   start log.html
   ```

   **macOS:**
   ```bash
   open log.html
   ```

   **Linux:**
   ```bash
   xdg-open log.html
   ```

2. **Nivel 1 — Suite:** En la parte superior verás el nodo raíz de la suite: `Mi Primera Suite`. Junto a él aparece el estado global (FAIL) y el tiempo total de ejecución.

3. **Nivel 2 — Test Cases:** Expande la suite haciendo clic en el triángulo/flecha. Aparecerán los 5 test cases. Identifica los íconos de estado:
   - ✅ Verde → PASS
   - ❌ Rojo → FAIL
   - ⚠️ El test `Test Con Advertencia De Configuracion` aparece en verde (PASS) aunque emitió un WARN — esto es correcto porque WARN **no falla** el test.

4. **Nivel 3 — Keywords:** Expande el test case `Test Con Advertencia De Configuracion`. Verás tres entradas de keyword `Log`, cada una con su timestamp y duración.

5. **Nivel 4 — Mensajes de log:** Expande cada keyword `Log`. Observa:
   - La primera entrada muestra el mensaje en nivel **INFO** (texto normal).
   - La segunda entrada muestra el mensaje en nivel **WARN** (texto resaltado en amarillo/naranja).
   - La tercera entrada vuelve a nivel **INFO**.

6. **Análisis del test fallido:** Expande `Test Con Fallo Deliberado`. Observa:
   - El primer `Log` se ejecutó correctamente (nivel INFO).
   - La keyword `Should Be Equal` aparece en rojo con el mensaje de error: `TLC-001 != TLC-999`.
   - La tercera línea (`Log ... Esta linea NO se ejecutara...`) **no aparece** — confirma que la ejecución se detuvo en el punto de fallo.

7. Busca el **timestamp** de la keyword fallida. Robot Framework registra el momento exacto de cada paso con precisión de milisegundos.

**Salida esperada:** Puedes navegar el árbol completo de 5 niveles: suite → test case → keyword → argumento → mensaje. El test fallido muestra claramente la excepción `AssertionError`.

**Verificación:** Responde mentalmente (o por escrito) estas preguntas:
- ¿Cuántos milisegundos tardó la suite completa?
- ¿Qué color diferencia un mensaje WARN de uno INFO en el log?
- ¿Por qué el tercer `Log` del test fallido no aparece en el árbol?

---

### Paso 6 — Personalizar los artefactos de salida con flags

**Objetivo:** Usar los flags `--log`, `--report` y `--output` para generar artefactos con nombres personalizados en una subcarpeta.

**Instrucciones:**

1. Crea una subcarpeta para organizar los reportes:

   **Windows:**
   ```cmd
   mkdir resultados
   ```

   **macOS / Linux:**
   ```bash
   mkdir resultados
   ```

2. Ejecuta la suite especificando nombres y ubicación personalizados para cada artefacto:

   ```bash
   robot --log resultados/log_analisis.html \
         --report resultados/reporte_analisis.html \
         --output resultados/output_analisis.xml \
         mi_primera_suite.robot
   ```

   **Windows (cmd — sin barra invertida para continuación de línea):**
   ```cmd
   robot --log resultados/log_analisis.html --report resultados/reporte_analisis.html --output resultados/output_analisis.xml mi_primera_suite.robot
   ```

3. Verifica que los archivos se crearon en la subcarpeta:

   **Windows:**
   ```cmd
   dir resultados\
   ```

   **macOS / Linux:**
   ```bash
   ls -lh resultados/
   ```

4. Abre `resultados/reporte_analisis.html` en el navegador y confirma que el contenido es idéntico al `report.html` generado anteriormente (mismos resultados, diferente nombre de archivo).

**Salida esperada:**

```
resultados/
├── log_analisis.html
├── output_analisis.xml
└── reporte_analisis.html
```

**Verificación:** Los tres archivos existen en la carpeta `resultados/`. El reporte muestra los mismos 5 tests con los mismos resultados.

> 💡 **Nota práctica:** En pipelines CI/CD (Jenkins, GitHub Actions, GitLab CI) es común usar `--output` para especificar rutas absolutas donde el sistema de CI puede recoger los artefactos. El nombre del archivo `output.xml` puede configurarse libremente.

---

### Paso 7 — Ejecutar con --loglevel DEBUG y comparar verbosidad

**Objetivo:** Observar cómo el flag `--loglevel DEBUG` aumenta la cantidad de información registrada en el log.

**Instrucciones:**

1. Ejecuta la suite con nivel de log `DEBUG`, guardando los artefactos en una subcarpeta separada:

   ```bash
   robot --loglevel DEBUG \
         --log resultados/log_debug.html \
         --report resultados/reporte_debug.html \
         --output resultados/output_debug.xml \
         mi_primera_suite.robot
   ```

   **Windows (cmd):**
   ```cmd
   robot --loglevel DEBUG --log resultados/log_debug.html --report resultados/reporte_debug.html --output resultados/output_debug.xml mi_primera_suite.robot
   ```

2. Compara el tamaño de los dos archivos de log:

   **Windows:**
   ```cmd
   dir resultados\log_analisis.html resultados\log_debug.html
   ```

   **macOS / Linux:**
   ```bash
   ls -lh resultados/log_analisis.html resultados/log_debug.html
   ```

3. Abre `resultados/log_debug.html` en el navegador y expande cualquier keyword, por ejemplo `Should Be Equal` en el test fallido. Observa que ahora aparecen mensajes adicionales de nivel `DEBUG` que muestran los valores internos que Robot Framework evalúa durante la ejecución.

4. Compara visualmente con `resultados/log_analisis.html` (nivel INFO). Nota las diferencias:
   - El log DEBUG contiene entradas adicionales con detalles de resolución de variables.
   - El log INFO solo muestra lo que el test case registró explícitamente.

**Salida esperada:** El archivo `log_debug.html` es notablemente más grande que `log_analisis.html`. El árbol de ejecución contiene más nodos con mensajes de nivel DEBUG (generalmente en color gris o con etiqueta `DEBUG`).

**Verificación:** El tamaño de `log_debug.html` debe ser mayor que el de `log_analisis.html`. Si son idénticos, verifica que el flag `--loglevel DEBUG` se escribió correctamente (mayúsculas).

> ⚠️ **Nota:** El flag `--loglevel` acepta los valores: `TRACE`, `DEBUG`, `INFO` (por defecto), `WARN` y `NONE`. En entornos de producción CI/CD se usa típicamente `INFO` para mantener logs manejables. `DEBUG` es útil durante el desarrollo y depuración.

---

### Paso 8 — Explorar output.xml: la fuente de datos de los reportes

**Objetivo:** Comprender la estructura de `output.xml` y su rol como fuente de datos para reportes e integraciones.

**Instrucciones:**

1. Abre `output.xml` (o `resultados/output_analisis.xml`) en VS Code para inspeccionarlo:

   ```bash
   code output.xml
   ```

   Si el archivo es muy grande, puedes usar el comando `head` para ver las primeras líneas:

   **macOS / Linux:**
   ```bash
   head -50 output.xml
   ```

   **Windows (PowerShell):**
   ```powershell
   Get-Content output.xml | Select-Object -First 50
   ```

2. Identifica la estructura XML. Busca los siguientes elementos clave:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <robot generated="..." generator="Robot Framework 7.x.x ...">
     <suite id="s1" name="Mi Primera Suite" source="...">
       <test id="s1-t1" name="Primer Test Exitoso">
         <kw name="Log" library="BuiltIn">
           <msg timestamp="..." level="INFO">Hola desde Robot Framework</msg>
           <status status="PASS" starttime="..." endtime="..."/>
         </kw>
         <status status="PASS" starttime="..." endtime="..."/>
       </test>
       <test id="s1-t4" name="Test Con Fallo Deliberado">
         ...
         <status status="FAIL" starttime="..." endtime="...">
           TLC-001 != TLC-999
         </status>
       </test>
       <status status="FAIL" starttime="..." endtime="..."/>
     </suite>
     <statistics>...</statistics>
     <errors/>
   </robot>
   ```

3. Responde las siguientes preguntas observando el XML (anótalas en comentarios en tu suite o en papel):

   - ¿Qué atributo del elemento `<test>` identifica unívocamente cada test case?
   - ¿Dónde se almacena el mensaje de error del test fallido?
   - ¿Qué sección del XML contiene las estadísticas totales?

4. Comprende el flujo de datos:

   ```
   robot mi_primera_suite.robot
          │
          ▼
      output.xml  ←── Fuente única de verdad
          │
          ├──► rebot --log log.html --report report.html output.xml
          │         (Robot Framework puede regenerar reportes desde output.xml)
          │
          └──► CI/CD: Jenkins xUnit plugin, GitHub Actions, SonarQube...
                      (parsean output.xml para mostrar resultados en la plataforma)
   ```

5. **Bonus — Regenerar reportes desde output.xml:** Robot Framework incluye el comando `rebot` que permite generar o combinar reportes a partir de archivos `output.xml` existentes **sin re-ejecutar los tests**:

   ```bash
   rebot --log resultados/log_regenerado.html \
         --report resultados/reporte_regenerado.html \
         output.xml
   ```

   **Windows (cmd):**
   ```cmd
   rebot --log resultados/log_regenerado.html --report resultados/reporte_regenerado.html output.xml
   ```

   Verifica que `resultados/reporte_regenerado.html` contiene los mismos resultados que `report.html`.

**Salida esperada:** Puedes identificar la jerarquía XML y localizar el mensaje de error del test fallido dentro del elemento `<status>`. El comando `rebot` genera reportes idénticos sin re-ejecutar la suite.

**Verificación:** El archivo `resultados/reporte_regenerado.html` muestra `5 tests, 4 passed, 1 failed` — idéntico al reporte original.

---

### Paso 9 — Ejecutar con --loglevel WARN y observar el filtrado

**Objetivo:** Verificar que el flag `--loglevel WARN` filtra los mensajes INFO y solo muestra advertencias y errores.

**Instrucciones:**

1. Ejecuta la suite con nivel mínimo `WARN`:

   ```bash
   robot --loglevel WARN \
         --log resultados/log_warn.html \
         --report resultados/reporte_warn.html \
         --output resultados/output_warn.xml \
         mi_primera_suite.robot
   ```

   **Windows (cmd):**
   ```cmd
   robot --loglevel WARN --log resultados/log_warn.html --report resultados/reporte_warn.html --output resultados/output_warn.xml mi_primera_suite.robot
   ```

2. Abre `resultados/log_warn.html` en el navegador.

3. Expande el test case `Test Con Advertencia De Configuracion`. Observa que:
   - Los mensajes de nivel `INFO` **no aparecen** en el log.
   - Solo el mensaje de nivel `WARN` es visible.

4. Expande `Test Con Fallo Deliberado`. Observa que:
   - El primer `Log` (nivel INFO) **no aparece**.
   - El error de `Should Be Equal` **sí aparece** (los errores de fallo siempre se registran independientemente del nivel configurado).

5. Compara el tamaño de los tres logs generados hasta ahora:

   **macOS / Linux:**
   ```bash
   ls -lh resultados/log_analisis.html resultados/log_warn.html resultados/log_debug.html
   ```

   **Windows (PowerShell):**
   ```powershell
   Get-ChildItem resultados\log_analisis.html, resultados\log_warn.html, resultados\log_debug.html | Select-Object Name, Length
   ```

**Salida esperada:** El archivo `log_warn.html` es el más pequeño de los tres. El orden de tamaño esperado es: `log_debug.html` > `log_analisis.html` > `log_warn.html`.

**Verificación:** En `log_warn.html`, el test `Primer Test Exitoso` aparece como PASS pero **sin ningún mensaje de log visible** (porque todos sus mensajes son INFO y el nivel mínimo es WARN).

---

## Validación y pruebas

Al finalizar todos los pasos, realiza esta verificación final integral:

### Lista de verificación de artefactos

Ejecuta el siguiente comando para confirmar que todos los artefactos esperados existen:

**macOS / Linux:**
```bash
echo "=== Artefactos raíz ===" && ls -lh output.xml log.html report.html
echo "=== Artefactos en resultados/ ===" && ls -lh resultados/
```

**Windows (PowerShell):**
```powershell
Write-Host "=== Artefactos raíz ==="
Get-ChildItem output.xml, log.html, report.html | Select-Object Name, Length
Write-Host "=== Artefactos en resultados/ ==="
Get-ChildItem resultados\ | Select-Object Name, Length
```

**Salida esperada:**

```
=== Artefactos raíz ===
output.xml
log.html
report.html

=== Artefactos en resultados/ ===
log_analisis.html
log_debug.html
log_regenerado.html
log_warn.html
output_analisis.xml
output_debug.xml
output_warn.xml
reporte_analisis.html
reporte_debug.html
reporte_regenerado.html
reporte_warn.html
```

### Verificación de resultados de la suite

```bash
robot --dryrun mi_primera_suite.robot
```

Este comando verifica la sintaxis sin ejecutar los tests. La salida debe terminar con `5 tests, 5 passed, 0 failed` (en dryrun todos pasan porque no se ejecutan las keywords reales).

### Cuestionario de validación conceptual

Responde estas preguntas para confirmar la comprensión (las respuestas están implícitas en lo que observaste durante el lab):

1. **¿Cuál es la diferencia entre `report.html` y `log.html`?**
   - `report.html`: vista ejecutiva con estadísticas y estado global.
   - `log.html`: árbol detallado de ejecución con cada keyword y mensaje.

2. **¿Un mensaje de nivel WARN hace que un test falle?**
   - No. WARN es informativo. Solo `Fail` o una keyword que lanza excepción hace fallar un test.

3. **¿Qué ventaja tiene `output.xml` en un pipeline CI/CD?**
   - Es la fuente de datos que herramientas como Jenkins, GitHub Actions o SonarQube parsean para mostrar resultados sin necesidad de abrir un navegador.

4. **¿Cuándo usarías `--loglevel DEBUG` en producción?**
   - Solo durante depuración activa. En producción se usa `INFO` para mantener logs manejables y evitar exponer información sensible.

---

## Resolución de problemas

### Problema 1 — `report.html` y `log.html` no se abren correctamente en el navegador (página en blanco o sin estilos)

**Síntoma:** Al abrir `report.html` o `log.html` directamente desde el sistema de archivos, el navegador muestra una página en blanco, sin estilos CSS o con un error de contenido bloqueado en la consola del navegador.

**Causa:** Algunos navegadores modernos (especialmente Chrome) bloquean la carga de recursos JavaScript locales por políticas de seguridad de origen cruzado (`CORS`) cuando los archivos se abren con el protocolo `file://`. Robot Framework 7.x genera reportes con recursos incrustados (inline) para mitigar esto, pero ciertas configuraciones de seguridad del navegador o extensiones pueden interferir.

**Solución:**

Opción A — Usar Firefox, que tiene políticas más permisivas para archivos locales:
```bash
# macOS
open -a Firefox report.html

# Linux
firefox report.html

# Windows
start firefox report.html
```

Opción B — Servir los archivos con un servidor HTTP local simple:
```bash
# En la carpeta modulo01
python -m http.server 8080
```
Luego abre `http://localhost:8080/report.html` en el navegador.

Opción C — En Chrome, lanzar con el flag de seguridad desactivado (solo para desarrollo local, **nunca en producción**):
```bash
# macOS
open -a "Google Chrome" --args --allow-file-access-from-files

# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --allow-file-access-from-files
```

---

### Problema 2 — El comando `robot` termina con `Return code: 1` y el estudiante cree que hay un error de configuración

**Síntoma:** Después de ejecutar `robot mi_primera_suite.robot`, la terminal muestra `Return code: 1` y el estudiante interpreta esto como un error del entorno o de instalación.

**Causa:** Robot Framework devuelve el **código de retorno 1** cuando al menos un test falla. Esto es comportamiento esperado y correcto — el `Test Con Fallo Deliberado` está diseñado para fallar. El código de retorno 0 significa "todos los tests pasaron"; cualquier número mayor que 0 indica tests fallidos (el número exacto corresponde a la cantidad de tests fallidos, hasta un máximo de 250).

**Solución:**

Verificar que el fallo es intencional revisando el resumen de consola:
```
5 tests, 4 passed, 1 failed
```

Si el estudiante necesita que el comando de shell no propague el código de error (por ejemplo, en un script), puede usar:

**bash/zsh:**
```bash
robot mi_primera_suite.robot || true
echo "Ejecucion completada (ver reportes para resultados)"
```

**PowerShell:**
```powershell
robot mi_primera_suite.robot
# $LASTEXITCODE contiene el número de tests fallidos
Write-Host "Tests fallidos: $LASTEXITCODE"
```

> 💡 Este comportamiento es fundamental en CI/CD: los pipelines usan el código de retorno de `robot` para determinar si el build debe marcarse como fallido. Un código de retorno 0 = build verde; mayor que 0 = build rojo.

---

## Limpieza

Al finalizar el laboratorio, el proyecto debe quedar organizado para ser usado como base en laboratorios posteriores.

### Estructura final esperada del proyecto

```
~/rf-curso/modulo01/
├── mi_primera_suite.robot      ← Suite ampliada (5 test cases)
├── output.xml                  ← Artefacto de la última ejecución
├── log.html                    ← Log de la última ejecución
├── report.html                 ← Reporte de la última ejecución
└── resultados/                 ← Artefactos de ejecuciones con flags personalizados
    ├── log_analisis.html
    ├── log_debug.html
    ├── log_regenerado.html
    ├── log_warn.html
    ├── output_analisis.xml
    ├── output_debug.xml
    ├── output_warn.xml
    ├── reporte_analisis.html
    ├── reporte_debug.html
    ├── reporte_regenerado.html
    └── reporte_warn.html
```

### Desactivar el entorno virtual al finalizar la sesión

**Windows:**
```cmd
deactivate
```

**macOS / Linux:**
```bash
deactivate
```

### Copia de respaldo (recomendado)

```bash
# macOS / Linux
cp -r ~/rf-curso/modulo01 ~/rf-curso/modulo01_backup_lab02

# Windows (PowerShell)
Copy-Item -Recurse $HOME\rf-curso\modulo01 $HOME\rf-curso\modulo01_backup_lab02
```

> ⚠️ **Nota sobre archivos generados:** Los archivos `output.xml`, `log.html` y `report.html` en la raíz del proyecto serán sobreescritos cada vez que ejecutes `robot` sin flags `--output`/`--log`/`--report`. La carpeta `resultados/` contiene las versiones nombradas que puedes conservar para referencia.

---

## Resumen

En este laboratorio has completado un análisis sistemático de los artefactos de salida de Robot Framework:

| Artefacto | Propósito | Audiencia típica |
|-----------|-----------|-----------------|
| `report.html` | Vista ejecutiva: estadísticas, estado global, tabla de tests | Gerentes, Product Owners, QA leads |
| `log.html` | Árbol detallado de ejecución con timestamps y mensajes por nivel | Ingenieros de QA, desarrolladores depurando fallos |
| `output.xml` | Fuente de datos estructurada para reportes e integraciones | Pipelines CI/CD, herramientas de reporting |

### Conceptos clave aprendidos

- **Jerarquía de ejecución:** Suite → Test Case → Keyword → Mensaje. Esta jerarquía se refleja fielmente tanto en `log.html` como en `output.xml`.
- **Niveles de log:** `INFO` (por defecto), `WARN` (alerta no fatal), `FAIL` (fallo que detiene el test), `DEBUG` (máxima verbosidad para depuración).
- **Flags de salida:** `--log`, `--report` y `--output` permiten nombrar y ubicar los artefactos libremente — esencial para integración CI/CD.
- **`--loglevel`:** Controla qué mensajes se registran. `DEBUG` captura todo; `WARN` solo captura advertencias y errores; `INFO` es el equilibrio para uso cotidiano.
- **`rebot`:** Comando complementario que regenera o combina reportes desde `output.xml` sin re-ejecutar tests.
- **Código de retorno:** Robot Framework devuelve el número de tests fallidos como código de salida — comportamiento estándar para integración con pipelines CI/CD.

### Conexión con el contenido de la lección

Este laboratorio ilustra de forma práctica la diferencia conceptual entre **automatización de pruebas** y **RPA** vista en la Lección 1.1: los artefactos `report.html` y `log.html` son el **producto** de la automatización de pruebas — un reporte de pass/fail que informa la calidad del software. En un proceso RPA, el producto sería el resultado operativo (un archivo generado, un registro actualizado), no un reporte de verificación.

### Recursos adicionales

- [Robot Framework User Guide — Sección "Configuring execution"](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#configuring-execution)
- [Robot Framework User Guide — Sección "Output files"](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#output-files)
- [Comando `rebot` — Documentación oficial](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#rebot)
- [BuiltIn Library — Keyword `Log`](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Log)

---
*Lab 01-00-02 — Módulo 01: Arquitectura y ecosistema de Robot Framework*
