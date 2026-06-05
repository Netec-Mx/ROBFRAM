# Práctica 1: Instalación del entorno y ejecución del primer test case

## Metadatos

| Campo         | Detalle                                      |
|---------------|----------------------------------------------|
| **Duración**  | 72 minutos                                   |
| **Complejidad** | Fácil                                      |
| **Nivel Bloom** | Aplicar (Apply)                            |
| **Módulo**    | 01 — Fundamentos y Ecosistema                |
| **Versión RF** | Robot Framework 7.x                         |

---

## Descripción General

En este laboratorio configurarás desde cero el entorno completo de trabajo para el curso: Python 3.10+, un entorno virtual (`venv`), Robot Framework 7.x y el Language Server de VS Code. Una vez preparado el entorno, explorarás brevemente la distinción conceptual entre automatización de pruebas y RPA, y luego crearás y ejecutarás tu primera suite de pruebas `.robot` con las cuatro secciones principales del framework. Al finalizar, verificarás que los tres artefactos de reporte (`log.html`, `report.html`, `output.xml`) fueron generados correctamente.

---

## Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Instalar y verificar Python 3.10+, Robot Framework 7.x y el plugin de VS Code de forma funcional en el entorno local.
- [ ] Distinguir conceptualmente entre automatización de pruebas y RPA, identificando el rol de Robot Framework en cada dominio.
- [ ] Crear una suite de prueba `.robot` con las cuatro secciones principales: `*** Settings ***`, `*** Variables ***`, `*** Test Cases ***` y `*** Keywords ***`.
- [ ] Ejecutar la suite desde la línea de comandos e interpretar la salida de consola producida por el comando `robot`.
- [ ] Identificar y abrir los archivos de reporte generados (`log.html`, `report.html`, `output.xml`) en el directorio de salida.

---

## Prerrequisitos

### Conocimientos previos

| Área | Nivel requerido |
|------|----------------|
| Uso de terminal / línea de comandos (`cd`, `mkdir`, `ls`/`dir`) | Básico |
| Navegación de sistema de archivos | Básico |
| Conceptos generales de programación (variables, funciones) | Básico |

### Acceso y software

| Requisito | Estado esperado al iniciar |
|-----------|---------------------------|
| Python 3.10+ descargado **o** acceso a internet para descargarlo | Disponible |
| VS Code 1.85+ instalado **o** acceso a internet para instalarlo | Disponible |
| Conexión a internet (mínimo 10 Mbps) | Activa |
| Permisos de administrador local | Confirmados |
| Resolución de pantalla mínima 1280×768 | Verificada |

---

## Entorno del Laboratorio

### Hardware recomendado

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| Procesador | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos) | Intel Core i7 / AMD Ryzen 7 |
| RAM | 8 GB | 16 GB |
| Espacio en disco | 5 GB libres | 10 GB libres |

### Software que se instalará en este laboratorio

| Herramienta | Versión objetivo | Instalación |
|-------------|-----------------|-------------|
| Python | 3.10 o superior | Manual / verificación |
| pip | 23.x o superior | Incluido con Python |
| Robot Framework | 7.x (última estable) | `pip install robotframework` |
| VS Code | 1.85 o superior | Manual / verificación |
| Robot Framework Language Server | 1.12 o superior | Extensión de VS Code |

### Estructura de directorios del laboratorio

Al finalizar el laboratorio, tu proyecto tendrá la siguiente estructura:

```
rf-curso/
└── lab-01-00-01/
    ├── venv/                   ← entorno virtual Python
    ├── tests/
    │   └── primera_suite.robot ← suite de prueba principal
    └── reports/                ← directorio de salida de reportes
        ├── log.html
        ├── report.html
        └── output.xml
```

---

## Pasos del Laboratorio

### Paso 1 — Verificar e instalar Python 3.10+

**Objetivo:** Confirmar que Python 3.10 o superior está disponible en el sistema. Si no está instalado, completar la instalación antes de continuar.

#### Instrucciones

1. Abre una terminal (PowerShell en Windows, Terminal en macOS/Linux).

2. Verifica la versión de Python instalada:

```bash
# Windows (cmd o PowerShell)
python --version

# macOS / Linux
python3 --version
```

3. La salida debe mostrar `Python 3.10.x` o superior. Ejemplo de salida correcta:

```
Python 3.11.7
```

4. **Si Python NO está instalado o la versión es inferior a 3.10:**
   - Descarga el instalador desde [https://www.python.org/downloads/](https://www.python.org/downloads/)
   - **Windows:** durante la instalación, marca obligatoriamente la casilla **"Add Python to PATH"** antes de hacer clic en *Install Now*.
   - **macOS:** usa el instalador `.pkg` descargado o ejecuta `brew install python@3.11` si tienes Homebrew.
   - **Linux (Ubuntu/Debian):** ejecuta `sudo apt update && sudo apt install python3.11 python3.11-venv python3-pip`

5. Verifica también que `pip` está disponible:

```bash
# Windows
pip --version

# macOS / Linux
pip3 --version
```

**Salida esperada:**
```
pip 23.3.1 from /usr/lib/python3.11/site-packages/pip (python 3.11)
```

**Verificación:** La versión de Python reportada debe ser `3.10.x` o superior. La versión de pip debe ser `23.x` o superior. Si ambos comandos responden sin error, continúa al Paso 2.

---

### Paso 2 — Crear el directorio del proyecto y el entorno virtual

**Objetivo:** Establecer la estructura de directorios del proyecto y crear un entorno virtual Python aislado para el curso.

> ⚠️ **Nota importante:** Todos los laboratorios del curso deben ejecutarse dentro de un entorno virtual (`venv`). Esto evita conflictos de versiones entre paquetes de diferentes proyectos. **No instales Robot Framework de forma global.**

#### Instrucciones

1. Crea el directorio raíz del curso y el subdirectorio del laboratorio:

```bash
# Windows (cmd o PowerShell)
mkdir rf-curso
cd rf-curso
mkdir lab-01-00-01
cd lab-01-00-01

# macOS / Linux
mkdir -p rf-curso/lab-01-00-01
cd rf-curso/lab-01-00-01
```

2. Crea el entorno virtual dentro del directorio del laboratorio:

```bash
# Windows
python -m venv venv

# macOS / Linux
python3 -m venv venv
```

3. **Activa el entorno virtual:**

```bash
# Windows (cmd)
venv\Scripts\activate.bat

# Windows (PowerShell)
venv\Scripts\Activate.ps1

# macOS / Linux (bash/zsh)
source venv/bin/activate
```

> 💡 **PowerShell en Windows:** Si recibes un error de política de ejecución (`execution policy`), ejecuta primero: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` y luego vuelve a intentar la activación.

4. Confirma que el entorno virtual está activo. El prompt de tu terminal debe mostrar el prefijo `(venv)`:

```
(venv) C:\Users\alumno\rf-curso\lab-01-00-01>
```

**Salida esperada:** El prefijo `(venv)` aparece al inicio del prompt de la terminal en todas las plataformas.

**Verificación:** Ejecuta `python --version` con el venv activo. Debe responder con la versión de Python del entorno virtual, no con una versión del sistema diferente.

---

### Paso 3 — Instalar Robot Framework

**Objetivo:** Instalar Robot Framework 7.x dentro del entorno virtual activo y verificar la instalación.

#### Instrucciones

1. Con el entorno virtual activo (el prompt muestra `(venv)`), actualiza pip a la última versión:

```bash
pip install --upgrade pip
```

2. Instala Robot Framework:

```bash
pip install robotframework
```

3. Verifica que la instalación fue exitosa comprobando la versión:

```bash
robot --version
```

**Salida esperada:**
```
Robot Framework 7.1.1 (Python 3.11.7 on win32)
```

> La versión exacta puede variar (7.0.x, 7.1.x, etc.). Lo importante es que el número mayor sea **7**.

4. Verifica también que el comando `rebot` (para combinar reportes) está disponible:

```bash
rebot --version
```

**Salida esperada:**
```
Rebot 7.1.1 (Python 3.11.7 on win32)
```

**Verificación:** Ambos comandos (`robot` y `rebot`) deben responder con la versión 7.x sin errores. Si ves `command not found` o `not recognized`, el venv puede no estar activo — vuelve al Paso 2, instrucción 3.

---

### Paso 4 — Configurar VS Code con el Language Server de Robot Framework

**Objetivo:** Instalar la extensión Robot Framework Language Server en VS Code para obtener autocompletado, resaltado de sintaxis y navegación de keywords.

#### Instrucciones

1. Abre VS Code. Si no está instalado, descárgalo desde [https://code.visualstudio.com/](https://code.visualstudio.com/) e instálalo.

2. Abre el panel de extensiones con el atajo de teclado:
   - **Windows/Linux:** `Ctrl + Shift + X`
   - **macOS:** `Cmd + Shift + X`

3. En el campo de búsqueda, escribe:
   ```
   Robot Framework Language Server
   ```

4. Selecciona la extensión publicada por **Robocorp** (identificador: `robocorp.robotframework-lsp`) y haz clic en **Install**.

5. Espera a que la instalación termine. VS Code puede solicitarte recargar la ventana — acepta haciendo clic en **Reload Window**.

6. Abre el directorio del laboratorio en VS Code:

```bash
# Desde la terminal (con el venv activo, dentro de lab-01-00-01)
code .
```

7. Si VS Code no detecta automáticamente el intérprete de Python del venv, configúralo manualmente:
   - Presiona `Ctrl+Shift+P` (o `Cmd+Shift+P` en macOS)
   - Escribe `Python: Select Interpreter`
   - Selecciona el intérprete dentro de `venv/Scripts/python.exe` (Windows) o `venv/bin/python` (macOS/Linux)

**Salida esperada:** En el panel de extensiones, la extensión **Robot Framework Language Server** aparece con estado "Installed" y sin errores. La barra inferior de VS Code muestra el intérprete Python del venv seleccionado.

**Verificación:** Crea un archivo temporal llamado `test.robot` en el explorador de VS Code. Si el Language Server está activo, verás resaltado de sintaxis inmediatamente al escribir `*** Test Cases ***`. Puedes eliminar este archivo temporal una vez confirmado.

---

### Paso 5 — Exploración conceptual: Automatización de Pruebas vs. RPA

**Objetivo:** Reflexionar sobre la distinción conceptual entre automatización de pruebas y RPA antes de escribir código, para contextualizar el propósito de la suite que crearás a continuación.

#### Instrucciones

1. Crea el directorio `tests` dentro de `lab-01-00-01`:

```bash
# Windows
mkdir tests

# macOS / Linux
mkdir tests
```

2. En VS Code, crea un nuevo archivo llamado `conceptos.md` dentro de `tests/` y escribe las respuestas a las siguientes preguntas de reflexión. Este archivo no es ejecutable; es tu bitácora conceptual:

```markdown
# Reflexión Conceptual — Lab 01-00-01

## ¿Cuál es el propósito principal de la automatización de pruebas?
_Tu respuesta aquí_

## ¿Cuál es el propósito principal de la RPA?
_Tu respuesta aquí_

## ¿Cuál de los siguientes escenarios corresponde a automatización de pruebas y cuál a RPA?
- Escenario A: Verificar que el botón "Pagar" de un portal web muestra el mensaje correcto.
  → Tipo: _______
- Escenario B: Descargar facturas PDF de un correo y registrarlas en un ERP.
  → Tipo: _______

## ¿Qué herramienta usaremos en este curso que puede abordar AMBOS dominios?
_Tu respuesta aquí_
```

3. Completa el archivo con tus respuestas basándote en el contenido de la Lección 1.1. Las respuestas correctas son:
   - **Automatización de pruebas:** verificar la calidad del software; producto = reporte pass/fail.
   - **RPA:** ejecutar procesos de negocio de forma autónoma; producto = resultado operativo.
   - **Escenario A:** Automatización de pruebas. **Escenario B:** RPA.
   - **Herramienta:** Robot Framework.

**Salida esperada:** Archivo `tests/conceptos.md` guardado con las respuestas completas.

**Verificación:** Este paso es de reflexión. No hay comando de verificación. Continúa al Paso 6 una vez que hayas completado el archivo.

---

### Paso 6 — Crear la primera suite de prueba `.robot`

**Objetivo:** Crear el archivo `primera_suite.robot` con las cuatro secciones principales de Robot Framework y al menos dos test cases funcionales.

#### Instrucciones

1. En VS Code, crea el archivo `tests/primera_suite.robot`.

2. Escribe el siguiente contenido completo en el archivo. Lee cada sección y los comentarios explicativos antes de guardar:

```robot
*** Settings ***
# La sección Settings define metadatos de la suite y las librerías que se importan.
# En este primer laboratorio usamos solo la librería BuiltIn, que es nativa de
# Robot Framework y NO requiere importación explícita. La declaramos con Documentation
# para describir el propósito de la suite.

Documentation    Suite de demostración — Lab 01-00-01
...              Cubre las cuatro secciones principales de Robot Framework.
...              Contexto: diferencia entre automatización de pruebas y RPA.


*** Variables ***
# La sección Variables define variables reutilizables a nivel de suite.
# Los tipos más comunes son escalares (${}) y listas (@{}).

${NOMBRE_CURSO}       Robot Framework 7
${VERSION_RF}         7
${HERRAMIENTA_RPA}    Robot Framework
${HERRAMIENTA_QA}     Robot Framework

@{DOMINIOS_RF}        Automatización de Pruebas    RPA    Automatización Web


*** Test Cases ***
# Cada bloque con nombre en esta sección es un caso de prueba independiente.
# La indentación usa CUATRO ESPACIOS o un TAB (Robot Framework acepta ambos,
# pero el equipo del curso usa cuatro espacios como estándar).

TC-01 Verificar que las variables de suite están definidas correctamente
    [Documentation]    Valida que las variables declaradas en *** Variables ***
    ...                tienen los valores esperados usando Should Be Equal.
    Log    Iniciando verificación de variables de suite
    Should Be Equal    ${VERSION_RF}    7
    Should Be Equal    ${HERRAMIENTA_RPA}    ${HERRAMIENTA_QA}
    Log    Ambas variables apuntan a: ${HERRAMIENTA_RPA}
    Log    Verificación completada exitosamente

TC-02 Demostrar el uso de Set Variable y comparaciones de strings
    [Documentation]    Muestra cómo crear variables locales dentro de un test case
    ...                usando Set Variable y cómo validar su contenido.
    ${proposito_pruebas}=    Set Variable    Verificar calidad del software
    ${proposito_rpa}=        Set Variable    Ejecutar procesos de negocio
    Log    Propósito de automatización de pruebas: ${proposito_pruebas}
    Log    Propósito de RPA: ${proposito_rpa}
    Should Be Equal    ${proposito_pruebas}    Verificar calidad del software
    Should Be Equal    ${proposito_rpa}        Ejecutar procesos de negocio
    Log    TC-02 completado — ambos propósitos verificados correctamente

TC-03 Verificar que Robot Framework abarca múltiples dominios
    [Documentation]    Valida conceptualmente que Robot Framework cubre
    ...                tanto automatización de pruebas como RPA.
    Verificar Dominio En Lista    Automatización de Pruebas
    Verificar Dominio En Lista    RPA
    Log    Robot Framework cubre ${DOMINIOS_RF}[0] y ${DOMINIOS_RF}[1]


*** Keywords ***
# La sección Keywords define palabras clave (funciones) reutilizables.
# Encapsulan lógica que puede ser invocada desde múltiples test cases.

Verificar Dominio En Lista
    [Documentation]    Verifica que un dominio dado existe en la lista @{DOMINIOS_RF}.
    [Arguments]    ${dominio}
    Should Contain    ${DOMINIOS_RF}    ${dominio}
    Log    Dominio confirmado: ${dominio} está en la lista de dominios de RF
```

3. Guarda el archivo con `Ctrl+S` (o `Cmd+S` en macOS).

4. Revisa que VS Code muestre resaltado de sintaxis en las secciones (`*** Settings ***`, `*** Variables ***`, etc.) y en las keywords (`Log`, `Should Be Equal`, `Set Variable`). Esto confirma que el Language Server está activo.

**Salida esperada:** El archivo `tests/primera_suite.robot` está guardado y VS Code muestra resaltado de sintaxis correcto. No debe haber líneas subrayadas en rojo indicando errores de sintaxis.

**Verificación:** En la terminal (con venv activo), ejecuta una verificación de sintaxis en seco:

```bash
# Desde el directorio lab-01-00-01
robot --dryrun tests/primera_suite.robot
```

La salida debe terminar con:
```
1 suite, 3 tests, 3 passed, 0 failed
```
(En modo `--dryrun` los tests se validan sin ejecutarse realmente.)

---

### Paso 7 — Ejecutar la suite y analizar la salida de consola

**Objetivo:** Ejecutar la suite completa con el comando `robot`, interpretar la salida de consola línea por línea e identificar el significado de cada sección del output.

#### Instrucciones

1. Crea el directorio de reportes:

```bash
# Windows
mkdir reports

# macOS / Linux
mkdir reports
```

2. Ejecuta la suite especificando el directorio de salida con la opción `--outputdir`:

```bash
# Desde el directorio lab-01-00-01 (con venv activo)
robot --outputdir reports tests/primera_suite.robot
```

3. Observa la salida de consola. Deberías ver algo similar a:

```
==============================================================================
Primera Suite                                                                 
==============================================================================
TC-01 Verificar que las variables de suite están definidas correctamente      | PASS |
------------------------------------------------------------------------------
TC-02 Demostrar el uso de Set Variable y comparaciones de strings             | PASS |
------------------------------------------------------------------------------
TC-03 Verificar que Robot Framework abarca múltiples dominios                 | PASS |
==============================================================================
Primera Suite                                                                 | PASS |
3 tests, 3 passed, 0 failed
==============================================================================
Output:  /ruta/a/lab-01-00-01/reports/output.xml
Log:     /ruta/a/lab-01-00-01/reports/log.html
Report:  /ruta/a/lab-01-00-01/reports/report.html
```

4. Analiza cada parte de la salida:

| Elemento en consola | Significado |
|---------------------|-------------|
| `==============================================================================` | Delimitador de inicio/fin de suite |
| `Primera Suite` | Nombre de la suite (derivado del nombre del archivo) |
| `TC-01 ... \| PASS \|` | Resultado individual de cada test case |
| `3 tests, 3 passed, 0 failed` | Resumen de ejecución de la suite |
| `Output: .../output.xml` | Ruta al archivo XML con datos brutos de ejecución |
| `Log: .../log.html` | Ruta al log detallado con cada keyword ejecutada |
| `Report: .../report.html` | Ruta al reporte ejecutivo de alto nivel |

5. Ejecuta también la suite con mayor verbosidad para ver los mensajes de `Log` en consola:

```bash
robot --outputdir reports --loglevel DEBUG tests/primera_suite.robot
```

Con `--loglevel DEBUG` verás en consola cada mensaje generado por la keyword `Log`.

**Salida esperada:** Los tres test cases muestran `| PASS |` en la consola. El resumen final indica `3 tests, 3 passed, 0 failed`. Las rutas a los tres archivos de reporte aparecen al final.

**Verificación:** Confirma que los tres archivos existen en el directorio `reports/`:

```bash
# Windows (cmd)
dir reports

# Windows (PowerShell)
Get-ChildItem reports

# macOS / Linux
ls -la reports/
```

Debes ver: `log.html`, `report.html` y `output.xml`.

---

### Paso 8 — Explorar los archivos de reporte generados

**Objetivo:** Abrir e interpretar los tres archivos de reporte generados por Robot Framework para entender qué información proporciona cada uno.

#### Instrucciones

1. **Abre `report.html`** en tu navegador web:

```bash
# Windows (cmd)
start reports\report.html

# Windows (PowerShell)
Invoke-Item reports\report.html

# macOS
open reports/report.html

# Linux
xdg-open reports/report.html
```

2. En `report.html` identifica los siguientes elementos:
   - **Resumen de estadísticas** en la parte superior (Total, Passed, Failed).
   - **Gráfico de resultados** (verde = passed, rojo = failed).
   - **Lista de test cases** con su estado y tiempo de ejecución.
   - **Timestamp** de inicio y fin de la ejecución.

3. **Abre `log.html`** en tu navegador web:

```bash
# Windows (cmd)
start reports\log.html

# Windows (PowerShell)
Invoke-Item reports\log.html

# macOS
open reports/log.html

# Linux
xdg-open reports/log.html
```

4. En `log.html` identifica los siguientes elementos:
   - Cada test case expandible con su lista de keywords ejecutadas.
   - Los mensajes generados por la keyword `Log` (aparecen en color verde con nivel INFO).
   - El tiempo de ejecución de cada keyword individual.
   - La sección **"Suite Setup / Teardown"** (vacía en este lab, pero visible en la estructura).

5. Expande el test case **TC-02** en `log.html` y verifica que puedes ver los mensajes:
   - `Propósito de automatización de pruebas: Verificar calidad del software`
   - `Propósito de RPA: Ejecutar procesos de negocio`

6. **Inspecciona `output.xml`** brevemente. No necesitas abrirlo en el navegador; ábrelo en VS Code:

```bash
# Desde la terminal
code reports/output.xml
```

Observa que es un archivo XML estructurado que contiene todos los datos de la ejecución. Este archivo es la fuente de verdad que usa Robot Framework para generar `log.html` y `report.html`, y es el formato que consumen herramientas de CI/CD como Jenkins o GitHub Actions.

**Salida esperada:** Los tres archivos se abren correctamente. `report.html` muestra `3/3 tests passed` en color verde. `log.html` muestra los mensajes de `Log` de cada test case. `output.xml` contiene la estructura XML de la ejecución.

**Verificación:** En `report.html`, el indicador de estado general de la suite debe ser **verde** con el texto "All tests passed" o equivalente. Si algún test aparece en rojo, vuelve al Paso 6 y revisa la sintaxis del archivo `.robot`.

---

## Validación y Pruebas

Una vez completados todos los pasos, ejecuta la siguiente secuencia de validación final para confirmar que el entorno está correctamente configurado:

```bash
# 1. Confirmar que el venv está activo (debe mostrar prefijo (venv))
# Windows
venv\Scripts\activate.bat
# macOS/Linux
source venv/bin/activate

# 2. Verificar versiones instaladas
python --version
robot --version

# 3. Ejecutar la suite completa con reporte limpio
robot --outputdir reports --timestampoutputs tests/primera_suite.robot
```

La opción `--timestampoutputs` agrega un timestamp al nombre de los archivos de reporte, lo que permite conservar el historial de ejecuciones anteriores.

### Lista de verificación final

| Criterio | Verificación | Estado |
|----------|-------------|--------|
| Python 3.10+ instalado | `python --version` muestra 3.10+ | ☐ |
| Robot Framework 7.x instalado | `robot --version` muestra 7.x | ☐ |
| Entorno virtual activo | Prompt muestra `(venv)` | ☐ |
| Language Server instalado en VS Code | Resaltado de sintaxis visible en `.robot` | ☐ |
| Suite ejecutada sin errores | `3 tests, 3 passed, 0 failed` en consola | ☐ |
| `log.html` generado y accesible | Archivo existe en `reports/` y abre en navegador | ☐ |
| `report.html` generado y accesible | Archivo existe en `reports/` y muestra verde | ☐ |
| `output.xml` generado | Archivo existe en `reports/` | ☐ |

---

## Solución de Problemas

### Problema 1: El comando `robot` no se reconoce después de instalar Robot Framework

**Síntoma:**
```
# Windows
'robot' is not recognized as an internal or external command

# macOS / Linux
command not found: robot
```

**Causa:** El entorno virtual no está activo al momento de ejecutar el comando, o Robot Framework fue instalado fuera del venv (globalmente) pero el PATH del sistema no incluye el directorio de scripts del venv.

**Solución:**

1. Verifica que el venv esté activo — el prompt debe mostrar `(venv)`:
```bash
# Windows (cmd)
venv\Scripts\activate.bat

# Windows (PowerShell)
venv\Scripts\Activate.ps1

# macOS / Linux
source venv/bin/activate
```

2. Con el venv activo, verifica que Robot Framework está instalado en él:
```bash
pip show robotframework
```
Si no aparece, instálalo:
```bash
pip install robotframework
```

3. Si el problema persiste en PowerShell en Windows, verifica la política de ejecución:
```powershell
Get-ExecutionPolicy
# Si responde "Restricted", ejecuta:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### Problema 2: Los test cases fallan con `ValueError` o `TypeError` al ejecutar la suite

**Síntoma:**
```
TC-01 Verificar que las variables de suite están definidas correctamente      | FAIL |
ValueError: Argument types do not match...
```
o
```
Should Be Equal    ${VERSION_RF}    7
AssertionError: 7 != 7
```
(Aparentemente iguales pero falla.)

**Causa:** El problema más común es una discrepancia de tipos de datos. En Robot Framework, todas las variables definidas en `*** Variables ***` son cadenas de texto (`string`) por defecto. Si intentas comparar `${VERSION_RF}` (string `"7"`) con el entero `7` usando `Should Be Equal` sin conversión de tipos, puede fallar dependiendo del contexto. También puede ser causado por espacios invisibles en el archivo (mezcla de tabs y espacios en la indentación).

**Solución:**

1. Verifica que la comparación en el test case usa el mismo tipo. Para comparar strings, asegúrate de que ambos lados sean strings:
```robot
# Correcto: ambos lados son strings
Should Be Equal    ${VERSION_RF}    7

# Si necesitas comparar como entero, usa el prefijo de tipo:
Should Be Equal As Integers    ${VERSION_RF}    7
```

2. Verifica la indentación del archivo. En VS Code, activa la visualización de caracteres especiales:
   - `Ctrl+Shift+P` → "Toggle Render Whitespace"
   - Asegúrate de que toda la indentación usa **espacios** (4 espacios por nivel), no tabs.

3. Si sospechas de caracteres invisibles, recrea el archivo copiando el contenido del Paso 6 desde cero en un archivo nuevo.

4. Ejecuta con `--loglevel DEBUG` para ver el valor exacto de las variables en tiempo de ejecución:
```bash
robot --outputdir reports --loglevel DEBUG tests/primera_suite.robot
```

---

## Limpieza del Entorno

Al finalizar el laboratorio, ejecuta los siguientes pasos para dejar el entorno en un estado ordenado:

1. **Desactiva el entorno virtual:**

```bash
# Funciona igual en Windows, macOS y Linux
deactivate
```

El prompt de la terminal debe volver a su estado normal (sin el prefijo `(venv)`).

2. **Crea una copia de respaldo del proyecto** (recomendado antes de iniciar el siguiente laboratorio):

```bash
# Windows (PowerShell)
Copy-Item -Recurse lab-01-00-01 lab-01-00-01-backup

# macOS / Linux
cp -r lab-01-00-01 lab-01-00-01-backup
```

> ⚠️ **Nota sobre progresión acumulativa:** Los laboratorios del curso son acumulativos. El directorio `rf-curso/` que creaste hoy será la base de los laboratorios siguientes. **No elimines** el directorio `lab-01-00-01/` ni el entorno virtual `venv/`.

3. Los archivos en `reports/` pueden eliminarse de forma segura si necesitas liberar espacio; se regeneran en cada ejecución:

```bash
# Windows (cmd)
del /Q reports\*.html reports\*.xml

# macOS / Linux
rm reports/*.html reports/*.xml
```

---

## Resumen

En este laboratorio completaste los siguientes logros:

| Logro | Descripción |
|-------|-------------|
| **Entorno configurado** | Python 3.10+, venv, Robot Framework 7.x y VS Code Language Server instalados y verificados |
| **Distinción conceptual** | Identificaste la diferencia entre automatización de pruebas (verificar calidad) y RPA (ejecutar procesos de negocio), y reconociste que Robot Framework abarca ambos dominios |
| **Primera suite creada** | Archivo `primera_suite.robot` con las 4 secciones: `*** Settings ***`, `*** Variables ***`, `*** Test Cases ***` y `*** Keywords ***` |
| **Keywords BuiltIn aplicadas** | Uso práctico de `Log`, `Should Be Equal`, `Set Variable` y `Should Contain` |
| **Suite ejecutada** | Comando `robot --outputdir reports tests/primera_suite.robot` ejecutado con 3/3 tests passed |
| **Reportes interpretados** | `log.html`, `report.html` y `output.xml` identificados, abiertos y comprendidos |

### Conceptos clave reforzados

- **Automatización de pruebas** → propósito: verificar calidad → producto: reporte pass/fail → audiencia: equipo QA/Dev.
- **RPA** → propósito: ejecutar procesos de negocio → producto: resultado operativo → audiencia: áreas operativas.
- **Robot Framework** es una de las pocas herramientas que cubre ambos dominios desde una sintaxis unificada.
- Las **cuatro secciones** de una suite `.robot` son: `Settings`, `Variables`, `Test Cases` y `Keywords`.
- El comando `robot` genera siempre tres artefactos: `output.xml` (datos brutos), `log.html` (detalle de ejecución) y `report.html` (resumen ejecutivo).

### Próximos pasos

En el **Lab 01-00-02** explorarás en profundidad la arquitectura interna de Robot Framework: sus capas (core, librerías, plugins), el sistema de librerías nativas vs. externas, y comenzarás a trabajar con `SeleniumLibrary` para automatización web. El entorno virtual que configuraste hoy será la base de ese laboratorio.

### Recursos adicionales

| Recurso | URL |
|---------|-----|
| Documentación oficial de Robot Framework | [https://robotframework.org/](https://robotframework.org/) |
| Robot Framework User Guide (7.x) | [https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html) |
| Referencia de keywords BuiltIn | [https://robotframework.org/robotframework/latest/libraries/BuiltIn.html](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html) |
| Robot Framework Language Server (extensión) | [https://marketplace.visualstudio.com/items?itemName=robocorp.robotframework-lsp](https://marketplace.visualstudio.com/items?itemName=robocorp.robotframework-lsp) |
| Diferencias entre automatización de pruebas y RPA | [https://www.guru99.com/rpa-vs-test-automation.html](https://www.guru99.com/rpa-vs-test-automation.html) |

