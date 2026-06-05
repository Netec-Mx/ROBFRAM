# Práctica 3: Suite estructurada con keywords reutilizables y archivo Resource

## Metadatos

| Campo | Detalle |
|---|---|
| **Duración estimada** | 72 minutos |
| **Complejidad** | Media |
| **Nivel Bloom** | Aplicar (Apply) |
| **Módulo** | 2 — Test Cases, Keywords y Bibliotecas |
| **Laboratorio** | 02-00-01 |

---

## Descripción General

En este laboratorio construirás un proyecto Robot Framework con separación de responsabilidades: los test cases residirán en la carpeta `tests/` y las keywords reutilizables, junto con las variables compartidas, en un archivo `.resource` dentro de la carpeta `resources/`. El escenario de negocio simula operaciones básicas de un sistema de gestión de clientes de una empresa ficticia de telecomunicaciones llamada **TelecomPlus**. Aprenderás a definir los tres tipos de variables del framework, a construir keywords compuestas con parámetros y a importar el archivo Resource con ruta relativa para ejecutar la suite desde la raíz del proyecto.

---

## Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Crear un archivo `.resource` que centralice keywords reutilizables y variables compartidas, separadas de los test cases
- [ ] Definir y utilizar los tres tipos de variables de Robot Framework: escalares (`${var}`), listas (`@{list}`) y diccionarios (`&{dict}`) en contextos apropiados
- [ ] Construir keywords compuestas con parámetros que encapsulen lógica de negocio reutilizable en múltiples test cases
- [ ] Importar el archivo Resource desde la suite principal usando ruta relativa y verificar que keywords y variables se resuelven correctamente

---

## Prerrequisitos

### Conocimientos

- Haber completado los laboratorios 01-00-01 y 01-00-02 del Módulo 1
- Comprensión de las cuatro secciones de un archivo `.robot` (`Settings`, `Variables`, `Test Cases`, `Keywords`)
- Conocimiento básico de Python sobre listas y diccionarios (analogía con `@{list}` y `&{dict}`)
- Familiaridad con los conceptos de BuiltIn y Collections vistos en la Lección 2.1

### Acceso y Herramientas

- Entorno virtual Python (`venv`) activado con Robot Framework 7.x instalado
- Visual Studio Code con la extensión Robot Framework Language Server
- Terminal (PowerShell/cmd en Windows, bash/zsh en macOS/Linux)
- Permisos de escritura en el directorio de trabajo del proyecto

---

## Entorno de Laboratorio

### Requisitos de Hardware

| Componente | Mínimo |
|---|---|
| Procesador | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos) |
| RAM | 8 GB |
| Almacenamiento libre | 500 MB para este laboratorio |
| Pantalla | 1280 × 768 (para visualizar reportes HTML) |

### Requisitos de Software

| Software | Versión |
|---|---|
| Python | 3.10 o superior |
| Robot Framework | 7.x (última estable) |
| robotframework-collections | Incluida en RF (estándar) |
| Visual Studio Code | 1.85 o superior |
| RF Language Server (extensión) | 1.12 o superior |

### Preparación del Entorno

Sigue estos pasos **antes** de comenzar las actividades del laboratorio.

**Paso 0.1 — Verificar el entorno virtual activo**

> ⚠️ **OBLIGATORIO**: Todos los laboratorios deben ejecutarse dentro de un entorno virtual Python. Nunca instales paquetes en el Python global del sistema.

```bash
# Windows (PowerShell)
# Si el venv aún no existe, créalo primero:
python -m venv venv
# Activar:
.\venv\Scripts\Activate.ps1

# Windows (cmd)
venv\Scripts\activate.bat

# macOS / Linux (bash/zsh)
python3 -m venv venv
source venv/bin/activate
```

Verifica que el prompt muestra `(venv)` al inicio. Luego comprueba las versiones:

```bash
python --version
# Esperado: Python 3.10.x o superior

robot --version
# Esperado: Robot Framework 7.x.x (Python 3.x.x ...)
```

**Paso 0.2 — Instalar dependencias necesarias**

La biblioteca Collections es estándar de Robot Framework y no requiere instalación adicional. Solo necesitas confirmar que RF está instalado:

```bash
pip install robotframework
pip show robotframework
# Verificar que la versión sea 7.x
```

**Paso 0.3 — Crear la estructura base del proyecto**

```bash
# Crear el directorio raíz del proyecto (si no existe desde laboratorios anteriores)
mkdir telecomplus_suite
cd telecomplus_suite

# Crear la estructura de carpetas
# Windows (PowerShell / cmd)
mkdir tests
mkdir resources
mkdir reports

# macOS / Linux
mkdir -p tests resources reports
```

La estructura resultante debe ser:

```
telecomplus_suite/
├── tests/
├── resources/
└── reports/
```

---

## Actividades del Laboratorio

---

### Paso 1 — Comprender la arquitectura del proyecto antes de codificar

**Objetivo:** Establecer mentalmente el modelo de separación de responsabilidades que guiará todo el laboratorio.

#### Instrucciones

1. Abre VS Code en la carpeta `telecomplus_suite`:

   ```bash
   # Desde la raíz del proyecto
   code .
   ```

2. Observa la estructura de carpetas en el explorador de VS Code. El principio de diseño es:
   - `resources/gestion_clientes.resource` → contiene **variables** y **keywords** reutilizables
   - `tests/suite_clientes.robot` → contiene únicamente **test cases** que importan el resource

3. Revisa el siguiente diagrama conceptual antes de escribir código:

   ```
   tests/suite_clientes.robot
   ┌─────────────────────────────────┐
   │ *** Settings ***                │
   │   Resource  ../resources/...   │──┐
   │                                 │  │ importa
   │ *** Test Cases ***              │  │
   │   TC1: Crear Cliente Básico     │  ▼
   │   TC2: Validar Plan Tarifario   │  resources/gestion_clientes.resource
   │   TC3: Calcular Factura         │  ┌──────────────────────────────────┐
   │   TC4: Gestionar Lista Planes   │  │ *** Variables ***                │
   │   TC5: Actualizar Datos Cliente │  │   ${EMPRESA}  TelecomPlus        │
   └─────────────────────────────────┘  │   @{PLANES_DISPONIBLES}  ...     │
                                         │   &{CLIENTE_TEMPLATE}  ...       │
                                         │                                  │
                                         │ *** Keywords ***                 │
                                         │   Crear Cliente                  │
                                         │   Validar Plan Tarifario         │
                                         │   Calcular Factura Mensual       │
                                         │   Agregar Plan A Lista           │
                                         │   Actualizar Datos Cliente       │
                                         └──────────────────────────────────┘
   ```

#### Salida Esperada

No hay archivo creado aún. Este paso es de análisis. El estudiante debe poder responder: *¿Por qué separamos keywords en un archivo `.resource` en lugar de escribirlas directamente en el `.robot`?*

> **Respuesta esperada:** Para reutilizar las mismas keywords en múltiples suites sin duplicar código, y para mantener los test cases enfocados en el *qué* (comportamiento de negocio) en lugar del *cómo* (implementación técnica).

#### Verificación

- [ ] La carpeta `telecomplus_suite/` existe con las subcarpetas `tests/`, `resources/` y `reports/`
- [ ] VS Code muestra la estructura en el explorador lateral

---

### Paso 2 — Crear el archivo Resource con variables de los tres tipos

**Objetivo:** Definir variables escalares, de lista y de diccionario que representen datos del dominio de telecomunicaciones.

#### Instrucciones

1. En VS Code, crea el archivo `resources/gestion_clientes.resource`.

2. Escribe la sección `*** Variables ***` con los tres tipos de variables:

   ```robot
   *** Variables ***
   # ─── Variables Escalares (${var}) ──────────────────────────────────────────
   # Representan un único valor: texto, número o booleano
   ${EMPRESA}              TelecomPlus
   ${VERSION_API}          v2.1
   ${IMPUESTO_PORCENTAJE}  ${0.19}
   ${LIMITE_PLANES}        ${5}

   # ─── Variables de Lista (@{list}) ───────────────────────────────────────────
   # Representan colecciones ordenadas de valores
   @{PLANES_DISPONIBLES}   Básico    Estándar    Premium    Empresarial
   @{REGIONES_COBERTURA}   Norte     Sur         Centro     Oriente     Occidente

   # ─── Variables de Diccionario (&{dict}) ─────────────────────────────────────
   # Representan pares clave-valor (como objetos/registros)
   &{CLIENTE_TEMPLATE}
   ...    nombre=Sin Asignar
   ...    documento=000000000
   ...    plan=Básico
   ...    activo=${TRUE}
   ...    deuda=${0.0}

   &{TARIFAS_PLANES}
   ...    Básico=${29900}
   ...    Estándar=${49900}
   ...    Premium=${79900}
   ...    Empresarial=${149900}
   ```

3. Guarda el archivo con `Ctrl+S` (Windows/Linux) o `Cmd+S` (macOS).

#### Salida Esperada

El archivo `resources/gestion_clientes.resource` existe y VS Code no muestra errores de sintaxis en el panel de problemas. La extensión RF Language Server debe mostrar resaltado de sintaxis para las variables.

#### Verificación

- [ ] Las variables escalares usan el prefijo `${...}` y contienen un único valor
- [ ] La variable de lista `@{PLANES_DISPONIBLES}` contiene exactamente 4 elementos
- [ ] Los diccionarios `&{CLIENTE_TEMPLATE}` y `&{TARIFAS_PLANES}` usan la sintaxis `clave=valor` con `...` para continuación de línea
- [ ] No hay errores de sintaxis reportados por VS Code

> **Nota conceptual:** En Robot Framework, `${IMPUESTO_PORCENTAJE}` con valor `${0.19}` crea una variable con tipo numérico flotante en Python. Sin las llaves internas (`0.19` sin `${}`), se crearía una cadena de texto `"0.19"`. Esta distinción es crítica para operaciones aritméticas.

---

### Paso 3 — Construir las keywords reutilizables en el archivo Resource

**Objetivo:** Definir cinco keywords con parámetros que encapsulen lógica de negocio del sistema TelecomPlus.

#### Instrucciones

1. Continúa editando `resources/gestion_clientes.resource`. Agrega la sección `*** Settings ***` al inicio (antes de `*** Variables ***`) y luego la sección `*** Keywords ***` al final:

   ```robot
   *** Settings ***
   Library    Collections
   ```

2. Agrega la sección `*** Keywords ***` al final del archivo con las cinco keywords:

   ```robot
   *** Keywords ***
   Crear Cliente
       [Documentation]    Crea un nuevo registro de cliente copiando el template
       ...                y actualizando nombre, documento y plan indicados.
       [Arguments]    ${nombre}    ${documento}    ${plan}=Básico
       # Copiar el diccionario template para no modificar el original
       &{nuevo_cliente}=    Copy Dictionary    ${CLIENTE_TEMPLATE}
       Set To Dictionary    ${nuevo_cliente}
       ...    nombre=${nombre}
       ...    documento=${documento}
       ...    plan=${plan}
       Log    Cliente creado: ${nombre} | Doc: ${documento} | Plan: ${plan}
       RETURN    &{nuevo_cliente}

   Validar Plan Tarifario
       [Documentation]    Verifica que el plan indicado existe en la lista
       ...                de planes disponibles de TelecomPlus.
       [Arguments]    ${plan}
       List Should Contain Value    ${PLANES_DISPONIBLES}    ${plan}
       Log    Plan '${plan}' es válido en ${EMPRESA} ${VERSION_API}

   Calcular Factura Mensual
       [Documentation]    Calcula el valor total de la factura aplicando impuesto.
       ...                Retorna el valor total como número.
       [Arguments]    ${plan}    ${meses}=${1}
       ${tarifa_base}=    Get From Dictionary    ${TARIFAS_PLANES}    ${plan}
       ${subtotal}=       Evaluate    ${tarifa_base} * ${meses}
       ${impuesto}=       Evaluate    ${subtotal} * ${IMPUESTO_PORCENTAJE}
       ${total}=          Evaluate    ${subtotal} + ${impuesto}
       Log    Factura ${plan} x${meses} mes(es): subtotal=${subtotal} | IVA=${impuesto} | TOTAL=${total}
       RETURN    ${total}

   Agregar Plan A Lista Activa
       [Documentation]    Agrega un plan a una lista dinámica de planes activos
       ...                y verifica que no supere el límite configurado.
       [Arguments]    ${lista_planes}    ${nuevo_plan}
       ${cantidad_actual}=    Get Length    ${lista_planes}
       Should Be True
       ...    ${cantidad_actual} < ${LIMITE_PLANES}
       ...    msg=No se pueden agregar más planes. Límite es ${LIMITE_PLANES}, actual: ${cantidad_actual}
       Append To List    ${lista_planes}    ${nuevo_plan}
       ${nueva_cantidad}=    Get Length    ${lista_planes}
       Log    Plan '${nuevo_plan}' agregado. Total planes activos: ${nueva_cantidad}
       RETURN    ${lista_planes}

   Actualizar Datos Cliente
       [Documentation]    Actualiza uno o más campos de un diccionario de cliente.
       ...                Retorna el diccionario actualizado.
       [Arguments]    ${cliente}    ${campo}    ${valor}
       Dictionary Should Contain Key    ${cliente}    ${campo}
       ...    msg=El campo '${campo}' no existe en el registro de cliente
       Set To Dictionary    ${cliente}    ${campo}=${valor}
       Log    Campo '${campo}' actualizado a '${valor}' para cliente: ${cliente}[nombre]
       RETURN    ${cliente}
   ```

3. Guarda el archivo.

#### Salida Esperada

El archivo `resources/gestion_clientes.resource` completo debe verse así en el explorador de VS Code, sin errores de sintaxis:

```
resources/
└── gestion_clientes.resource   ← ~70 líneas, sin marcadores de error
```

#### Verificación

- [ ] La keyword `Crear Cliente` tiene el parámetro `${plan}` con valor por defecto `Básico`
- [ ] `Calcular Factura Mensual` usa `Evaluate` para operaciones aritméticas
- [ ] `Agregar Plan A Lista Activa` valida el límite antes de agregar
- [ ] `Actualizar Datos Cliente` verifica que el campo existe antes de modificarlo
- [ ] Todas las keywords usan `RETURN` (sintaxis RF 4+, no `[Return]`)
- [ ] La sección `*** Settings ***` importa `Collections` en el resource

> **Nota sobre sintaxis RF 7.x:** La palabra clave `RETURN` (en mayúsculas, como bloque nativo) es la forma estándar desde Robot Framework 4+. La sintaxis antigua `[Return]` sigue funcionando pero está deprecada. En este curso usamos siempre `RETURN`.

---

### Paso 4 — Crear la suite de test cases que importa el Resource

**Objetivo:** Escribir la suite principal con cinco test cases que usen las keywords y variables del archivo Resource.

#### Instrucciones

1. Crea el archivo `tests/suite_clientes.robot`.

2. Escribe la sección `*** Settings ***` con la importación del resource usando ruta relativa:

   ```robot
   *** Settings ***
   Documentation    Suite de pruebas del sistema de gestión de clientes TelecomPlus.
   ...              Valida operaciones de creación, consulta y actualización de clientes.
   Resource         ../resources/gestion_clientes.resource
   ```

   > **Importante:** La ruta `../resources/gestion_clientes.resource` es **relativa al archivo `.robot`**, no al directorio desde donde se ejecuta `robot`. El archivo está en `tests/`, por lo tanto sube un nivel (`../`) para llegar a `resources/`.

3. Agrega la sección `*** Variables ***` con variables locales de la suite (que complementan las del resource):

   ```robot
   *** Variables ***
   # Variables locales de la suite (complementan las del resource)
   ${DOC_CLIENTE_1}    CC-10234567
   ${DOC_CLIENTE_2}    NIT-900123456
   ${DOC_CLIENTE_3}    CC-55678901
   ```

4. Escribe los cinco test cases:

   ```robot
   *** Test Cases ***
   TC-01: Crear un cliente con plan por defecto
       [Documentation]    Verifica que se puede crear un cliente con el plan
       ...                Básico (valor por defecto del parámetro).
       [Tags]    clientes    creacion
       &{cliente}=    Crear Cliente    nombre=María López    documento=${DOC_CLIENTE_1}
       Should Be Equal    ${cliente}[nombre]      María López
       Should Be Equal    ${cliente}[plan]        Básico
       Should Be Equal    ${cliente}[activo]      ${TRUE}
       Log    TC-01 completado. Cliente creado: ${cliente}

   TC-02: Crear un cliente con plan Premium y validar el plan
       [Documentation]    Crea un cliente con plan Premium y verifica que ese
       ...                plan existe en la lista de planes disponibles.
       [Tags]    clientes    creacion    planes
       &{cliente}=    Crear Cliente
       ...    nombre=Carlos Mendoza
       ...    documento=${DOC_CLIENTE_2}
       ...    plan=Premium
       Should Be Equal    ${cliente}[plan]    Premium
       # Validar que el plan asignado es un plan oficial de TelecomPlus
       Validar Plan Tarifario    ${cliente}[plan]
       Log    TC-02 completado. Plan Premium validado para: ${cliente}[nombre]

   TC-03: Calcular factura mensual y trimestral de un plan
       [Documentation]    Verifica el cálculo de factura para 1 y 3 meses
       ...                del plan Estándar, incluyendo IVA del 19%.
       [Tags]    facturacion    calculos
       # Factura de 1 mes
       ${total_mensual}=    Calcular Factura Mensual    plan=Estándar    meses=${1}
       # Estándar = 49900, con IVA 19% = 49900 * 1.19 = 59381.0
       Should Be Equal As Numbers    ${total_mensual}    ${59381.0}
       # Factura de 3 meses
       ${total_trimestral}=    Calcular Factura Mensual    plan=Estándar    meses=${3}
       # 49900 * 3 = 149700, con IVA = 149700 * 1.19 = 178143.0
       Should Be Equal As Numbers    ${total_trimestral}    ${178143.0}
       Log    TC-03 completado. Mensual: ${total_mensual} | Trimestral: ${total_trimestral}

   TC-04: Gestionar lista dinámica de planes activos de un cliente
       [Documentation]    Verifica que se pueden agregar planes a una lista
       ...                dinámica sin superar el límite configurado (${LIMITE_PLANES}).
       [Tags]    planes    listas
       # Crear lista inicial con un plan base
       @{planes_activos}=    Create List    Básico
       Log    Lista inicial: ${planes_activos}
       # Agregar planes adicionales
       ${planes_activos}=    Agregar Plan A Lista Activa    ${planes_activos}    Estándar
       ${planes_activos}=    Agregar Plan A Lista Activa    ${planes_activos}    Premium
       # Verificar que la lista contiene los planes esperados
       ${cantidad}=    Get Length    ${planes_activos}
       Should Be Equal As Integers    ${cantidad}    ${3}
       List Should Contain Value    ${planes_activos}    Estándar
       List Should Contain Value    ${planes_activos}    Premium
       Log    TC-04 completado. Planes activos: ${planes_activos}

   TC-05: Actualizar datos de un cliente existente
       [Documentation]    Crea un cliente y luego actualiza su plan y estado
       ...                usando la keyword Actualizar Datos Cliente.
       [Tags]    clientes    actualizacion
       # Crear cliente inicial
       &{cliente}=    Crear Cliente
       ...    nombre=Ana Torres
       ...    documento=${DOC_CLIENTE_3}
       ...    plan=Básico
       Should Be Equal    ${cliente}[plan]    Básico
       # Actualizar el plan del cliente
       ${cliente}=    Actualizar Datos Cliente
       ...    cliente=${cliente}
       ...    campo=plan
       ...    valor=Empresarial
       Should Be Equal    ${cliente}[plan]    Empresarial
       # Validar que el nuevo plan es oficial
       Validar Plan Tarifario    ${cliente}[plan]
       # Actualizar deuda del cliente
       ${cliente}=    Actualizar Datos Cliente
       ...    cliente=${cliente}
       ...    campo=deuda
       ...    valor=${149900}
       Should Be Equal As Numbers    ${cliente}[deuda]    ${149900}
       Log    TC-05 completado. Cliente actualizado: ${cliente}
   ```

5. Guarda el archivo.

#### Salida Esperada

```
tests/
└── suite_clientes.robot   ← ~80 líneas, sin errores de sintaxis
```

La extensión RF Language Server debe mostrar las keywords del resource con autocompletado al escribir en VS Code.

#### Verificación

- [ ] La importación `Resource ../resources/gestion_clientes.resource` usa ruta relativa correcta
- [ ] TC-01 usa la keyword `Crear Cliente` sin especificar `plan` (usa el valor por defecto)
- [ ] TC-03 usa `Should Be Equal As Numbers` para comparar valores flotantes
- [ ] TC-04 crea una lista con `Create List` (BuiltIn) antes de pasarla a la keyword del resource
- [ ] TC-05 encadena dos llamadas a `Actualizar Datos Cliente` sobre el mismo objeto
- [ ] Todos los test cases tienen `[Documentation]` y `[Tags]`

---

### Paso 5 — Ejecutar la suite desde la raíz del proyecto

**Objetivo:** Lanzar la ejecución completa de la suite y verificar que todos los test cases pasan.

#### Instrucciones

1. Abre la terminal integrada de VS Code (`Ctrl+ñ` en Windows/Linux, `Ctrl+\`` en macOS) o una terminal externa.

2. Asegúrate de estar en la **raíz del proyecto** (`telecomplus_suite/`) y de que el venv está activo:

   ```bash
   # Verificar directorio actual
   # Windows
   cd
   # macOS/Linux
   pwd
   # Debe mostrar: .../telecomplus_suite

   # Verificar que el venv está activo (debe aparecer (venv) en el prompt)
   ```

3. Ejecuta la suite con el directorio de salida apuntando a `reports/`:

   ```bash
   robot --outputdir reports tests/suite_clientes.robot
   ```

4. Observa la salida en la terminal. Debes ver algo similar a:

   ```
   ==============================================================================
   Suite Clientes :: Suite de pruebas del sistema de gestión de clientes TelecomPlus.
   ==============================================================================
   TC-01: Crear un cliente con plan por defecto                          | PASS |
   ------------------------------------------------------------------------------
   TC-02: Crear un cliente con plan Premium y validar el plan            | PASS |
   ------------------------------------------------------------------------------
   TC-03: Calcular factura mensual y trimestral de un plan               | PASS |
   ------------------------------------------------------------------------------
   TC-04: Gestionar lista dinámica de planes activos de un cliente       | PASS |
   ------------------------------------------------------------------------------
   TC-05: Actualizar datos de un cliente existente                       | PASS |
   ------------------------------------------------------------------------------
   Suite Clientes :: Suite de pruebas...                                 | PASS |
   5 tests, 5 passed, 0 failed
   ==============================================================================
   Output:  .../telecomplus_suite/reports/output.xml
   Log:     .../telecomplus_suite/reports/log.html
   Report:  .../telecomplus_suite/reports/report.html
   ```

5. Abre el reporte HTML en el navegador:

   ```bash
   # Windows
   start reports\report.html

   # macOS
   open reports/report.html

   # Linux
   xdg-open reports/report.html
   ```

#### Salida Esperada

- **5 tests, 5 passed, 0 failed** en la terminal
- El archivo `reports/report.html` se abre en el navegador mostrando todos los tests en verde
- El archivo `reports/log.html` muestra el detalle de cada keyword ejecutada con sus mensajes de `Log`

#### Verificación

- [ ] La terminal muestra `5 tests, 5 passed, 0 failed`
- [ ] Los archivos `reports/output.xml`, `reports/log.html` y `reports/report.html` fueron generados
- [ ] El reporte HTML muestra el nombre de la suite y los cinco test cases
- [ ] En `log.html`, al expandir TC-03, se ven los valores calculados: `59381.0` y `178143.0`

---

### Paso 6 — Explorar la ejecución por etiquetas y validar el Resource de forma aislada

**Objetivo:** Usar filtros de ejecución por tags para ejecutar subconjuntos de la suite y confirmar la flexibilidad del sistema de keywords.

#### Instrucciones

1. Ejecuta solo los test cases relacionados con creación de clientes (tag `creacion`):

   ```bash
   robot --outputdir reports --include creacion tests/suite_clientes.robot
   ```

   Salida esperada:

   ```
   2 tests, 2 passed, 0 failed
   ```

2. Ejecuta solo los test cases de facturación:

   ```bash
   robot --outputdir reports --include facturacion tests/suite_clientes.robot
   ```

   Salida esperada:

   ```
   1 test, 1 passed, 0 failed
   ```

3. Ejecuta todos los tests **excepto** los de cálculos:

   ```bash
   robot --outputdir reports --exclude calculos tests/suite_clientes.robot
   ```

   Salida esperada:

   ```
   4 tests, 4 passed, 0 failed
   ```

4. Ejecuta con nombre de test específico usando `--test`:

   ```bash
   robot --outputdir reports --test "TC-05*" tests/suite_clientes.robot
   ```

   Salida esperada:

   ```
   1 test, 1 passed, 0 failed
   ```

#### Salida Esperada

Cada ejecución filtra correctamente los test cases según el criterio indicado y genera un nuevo reporte en `reports/`.

#### Verificación

- [ ] El filtro `--include creacion` ejecuta exactamente TC-01 y TC-02
- [ ] El filtro `--include facturacion` ejecuta exactamente TC-03
- [ ] El filtro `--exclude calculos` ejecuta TC-01, TC-02, TC-04 y TC-05
- [ ] Todos los subconjuntos pasan sin errores

> **Concepto clave:** Los tags permiten organizar la ejecución sin modificar los archivos de prueba. Esto es esencial en pipelines CI/CD donde se ejecutan subconjuntos de pruebas según el contexto (smoke tests, regression, etc.).

---

## Validación y Pruebas Finales

Una vez completados todos los pasos, realiza esta verificación integral del proyecto.

### Lista de Verificación Final

```bash
# Desde telecomplus_suite/, ejecutar la suite completa con verbose
robot --outputdir reports --loglevel DEBUG tests/suite_clientes.robot
```

Confirma cada punto:

| Verificación | Comando / Acción | Resultado Esperado |
|---|---|---|
| Estructura de archivos | `ls -R` (Linux/Mac) o `tree` (Windows) | Ver `tests/`, `resources/`, `reports/` con sus archivos |
| Suite completa | `robot --outputdir reports tests/suite_clientes.robot` | `5 tests, 5 passed, 0 failed` |
| Reporte HTML | Abrir `reports/report.html` | Todos los tests en verde |
| Log detallado | Abrir `reports/log.html` | Mensajes de Log visibles en cada keyword |
| Variables en log | Expandir TC-01 en log.html | Ver `Cliente creado: {'nombre': 'María López', ...}` |
| Cálculo TC-03 | Expandir TC-03 en log.html | Ver `subtotal=149700 | IVA=28443.0 | TOTAL=178143.0` |

### Estructura Final del Proyecto

Verifica que la estructura de archivos sea exactamente:

```
telecomplus_suite/
├── resources/
│   └── gestion_clientes.resource
├── tests/
│   └── suite_clientes.robot
└── reports/
    ├── log.html
    ├── output.xml
    └── report.html
```

```bash
# Verificación rápida en terminal
# Windows (PowerShell)
Get-ChildItem -Recurse -File | Select-Object FullName

# macOS / Linux
find . -type f | sort
```

---

## Solución de Problemas

### Problema 1: `Resource file 'gestion_clientes.resource' does not exist`

**Síntoma:**

Al ejecutar `robot tests/suite_clientes.robot`, la terminal muestra:

```
[ ERROR ] Error in file '.../tests/suite_clientes.robot' on line 3:
Resource file '../resources/gestion_clientes.resource' does not exist.
```

**Causa:**

La ruta relativa `../resources/gestion_clientes.resource` en la sección `*** Settings ***` es relativa **al archivo `.robot`**, no al directorio de ejecución. Sin embargo, el error más común es ejecutar el comando `robot` desde dentro de la carpeta `tests/` en lugar de desde la raíz del proyecto `telecomplus_suite/`, o que el archivo `.resource` tenga un nombre diferente (mayúsculas/minúsculas incorrectas).

**Solución:**

1. Verifica que estás ejecutando desde la raíz del proyecto:

   ```bash
   # Confirmar directorio actual
   # Windows: cd    |    macOS/Linux: pwd
   # Debe terminar en: telecomplus_suite

   # Si estás en tests/, sube un nivel:
   cd ..
   ```

2. Verifica que el archivo existe con el nombre exacto:

   ```bash
   # Windows
   dir resources\

   # macOS/Linux
   ls resources/
   # Debe mostrar: gestion_clientes.resource
   ```

3. Si el nombre es correcto y el directorio también, verifica la línea de importación en `suite_clientes.robot`:

   ```robot
   # ✅ Correcto (ruta relativa al archivo .robot en tests/)
   Resource    ../resources/gestion_clientes.resource

   # ❌ Incorrecto
   Resource    resources/gestion_clientes.resource
   ```

---

### Problema 2: `ValueError` o `TypeError` en TC-03 al calcular la factura

**Síntoma:**

TC-03 falla con un error similar a:

```
TypeError: unsupported operand type(s) for *: 'str' and 'int'
```

o el test falla con:

```
49900 != 59381.0
```

**Causa:**

Las claves del diccionario `&{TARIFAS_PLANES}` en el archivo Resource fueron definidas sin el delimitador `${}` para los valores numéricos. Por ejemplo:

```robot
# ❌ Incorrecto: el valor '29900' es una cadena de texto
&{TARIFAS_PLANES}
...    Básico=29900

# ✅ Correcto: el valor ${29900} es un entero Python
&{TARIFAS_PLANES}
...    Básico=${29900}
```

Cuando Robot Framework lee `Básico=29900` (sin `${}`), almacena el string `"29900"`, y Python no puede multiplicar una cadena por un número en la keyword `Calcular Factura Mensual`.

**Solución:**

1. Abre `resources/gestion_clientes.resource`

2. Localiza la variable `&{TARIFAS_PLANES}` y asegúrate de que **todos los valores numéricos** usan `${número}`:

   ```robot
   &{TARIFAS_PLANES}
   ...    Básico=${29900}
   ...    Estándar=${49900}
   ...    Premium=${79900}
   ...    Empresarial=${149900}
   ```

3. Guarda el archivo y vuelve a ejecutar:

   ```bash
   robot --outputdir reports tests/suite_clientes.robot
   ```

> **Regla general:** En Robot Framework, cualquier valor que deba ser tratado como número (entero o flotante) en operaciones aritméticas **debe** estar envuelto en `${}`. Sin ese delimitador, todos los valores en variables son cadenas de texto.

---

## Limpieza del Entorno

Una vez finalizado el laboratorio, sigue estos pasos para dejar el entorno ordenado.

### Archivar el proyecto (recomendado)

Antes de limpiar, crea una copia de respaldo del proyecto completo. Los laboratorios posteriores del módulo construyen sobre este trabajo:

```bash
# Desde el directorio padre de telecomplus_suite/
# Windows (PowerShell)
Compress-Archive -Path telecomplus_suite -DestinationPath telecomplus_suite_lab02-00-01_backup.zip

# macOS / Linux
zip -r telecomplus_suite_lab02-00-01_backup.zip telecomplus_suite/
```

### Limpiar reportes generados (opcional)

Si deseas limpiar los reportes de las ejecuciones de prueba sin eliminar el código:

```bash
# Windows
del /Q reports\*.html reports\*.xml

# macOS / Linux
rm reports/*.html reports/*.xml
```

### Desactivar el entorno virtual

```bash
# Windows y macOS/Linux (mismo comando)
deactivate
```

> ⚠️ **No elimines** los archivos `.resource` ni `.robot`. El próximo laboratorio (02-00-02) extenderá este mismo proyecto agregando más keywords y el sistema de variables avanzado.

---

## Resumen

En este laboratorio aplicaste el principio de **separación de responsabilidades** en Robot Framework creando una arquitectura de proyecto de dos capas:

| Capa | Archivo | Contenido |
|---|---|---|
| **Recursos** | `resources/gestion_clientes.resource` | Variables de los 3 tipos + 5 keywords reutilizables |
| **Suite** | `tests/suite_clientes.robot` | 5 test cases que consumen el resource |

### Conceptos Clave Consolidados

- **Archivo `.resource`**: Contiene `*** Settings ***`, `*** Variables ***` y `*** Keywords ***`, pero **no** `*** Test Cases ***`. Es la unidad de reutilización en Robot Framework.
- **Tres tipos de variables**:
  - `${escalar}` → un valor (texto, número, booleano)
  - `@{lista}` → colección ordenada, acceso por índice `${lista}[0]`
  - `&{diccionario}` → pares clave-valor, acceso por clave `${dict}[clave]`
- **Keywords con parámetros opcionales**: `[Arguments]    ${param}=valor_defecto` permite llamar la keyword con o sin ese argumento.
- **`RETURN` nativo (RF 4+)**: Reemplaza la sintaxis antigua `[Return]` y es la forma estándar en RF 7.x.
- **Importación con ruta relativa**: La ruta en `Resource` es relativa al archivo `.robot`, no al directorio de ejecución.
- **Filtros de ejecución**: `--include`, `--exclude` y `--test` permiten ejecutar subconjuntos de la suite sin modificar el código.

### Próximos Pasos

En el laboratorio **02-00-02** profundizarás en el sistema de variables de Robot Framework, explorarás el scope de variables (local, suite, global), aprenderás a pasar variables entre keywords usando `Set Suite Variable` y extenderás el archivo Resource con keywords más complejas que usan estructuras de control (`IF`, `FOR`) nativas de RF 7.x.

### Referencias

- [Guía de usuario de Robot Framework — Archivos Resource](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#resource-and-variable-files)
- [Guía de usuario de Robot Framework — Variables](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variables)
- [Referencia biblioteca Collections](https://robotframework.org/robotframework/latest/libraries/Collections.html)
- [Referencia biblioteca BuiltIn](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html)
- [Robot Framework — Sintaxis RETURN (RF 5+)](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#returning-values-from-keywords)

---

---
