# Práctica 14: Suite API data-driven: smoke y regresión desde CSV

## Metadatos

| Campo            | Valor                                      |
|------------------|--------------------------------------------|
| **Duración**     | 72 minutos                                 |
| **Complejidad**  | Alta                                       |
| **Nivel Bloom**  | Crear                                      |
| **Módulo**       | 07 — Automatización de APIs REST           |
| **Práctica**     | 14 de la secuencia del curso               |

---

## Visión General

En esta práctica diseñarás desde cero una arquitectura de suite API **data-driven** completa, separando los casos de prueba *smoke* (camino feliz) de los casos de *regresión* (errores, límites y casos extremos) mediante archivos CSV externos y la **DataDriver Library**. Aplicarás contract testing básico para garantizar que el esquema JSON de las respuestas no cambia entre ejecuciones, y gestionarás la autenticación Bearer con una sesión compartida inicializada en el `Suite Setup`. Al finalizar, dispondrás de dos suites independientes (`smoke_suite.robot` y `regression_suite.robot`) que se pueden ejecutar por separado o de forma consolidada desde la CLI usando tags.

---

## Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Diseñar una arquitectura data-driven con DataDriver Library parametrizando casos desde archivos CSV diferenciados (smoke vs. regresión).
- [ ] Implementar un template keyword `Execute API Test Case` que despacha dinámicamente diferentes métodos HTTP usando `Run Keyword`.
- [ ] Construir una keyword `Validate Response Schema` que verifica la presencia de campos obligatorios definidos en un esquema JSON externo (contract testing básico).
- [ ] Gestionar autenticación Bearer con `Suite Setup` compartiendo el token entre todos los casos de prueba de la suite.
- [ ] Organizar y ejecutar subconjuntos específicos de pruebas desde la CLI usando tags avanzados (`smoke`, `regression`, `priority:high`).

---

## Prerrequisitos

### Conocimiento previo
- Haber completado la **Práctica 13 (Lab 07-00-01)** satisfactoriamente.
- Comprensión de los métodos HTTP (GET, POST, PUT, DELETE), códigos de estado y estructura de headers/payload (Lección 7.1).
- Conocimiento de autenticación Bearer y validación JSON con JSONPath (Lección 7.2).
- Familiaridad con la estructura de archivos CSV y su uso como fuente de datos en DataDriver Library (Lab 05-00-01).

### Acceso y herramientas
- Entorno virtual Python activado con las dependencias del curso instaladas.
- `robotframework-datadriver[CSV]` instalado (**no** solo el paquete base).
- Conexión a internet estable (mínimo 10 Mbps) para acceder a `jsonplaceholder.typicode.com` y `reqres.in`.
- VS Code con Robot Framework Language Server activo.

---

## Entorno del Laboratorio

### Hardware mínimo requerido

| Componente        | Mínimo                                        |
|-------------------|-----------------------------------------------|
| Procesador        | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos)|
| RAM               | 8 GB (16 GB recomendado)                      |
| Almacenamiento    | 5 GB libres                                   |
| Red               | 10 Mbps estables                              |
| Pantalla          | Resolución mínima 1280×768                    |

### Software requerido

| Paquete                         | Versión mínima |
|---------------------------------|----------------|
| Python                          | 3.10           |
| Robot Framework                 | 7.x            |
| robotframework-requests         | 0.9            |
| robotframework-datadriver[CSV]  | 1.10           |
| JSONLibrary                     | 0.5            |
| openpyxl                        | 3.1            |

### Preparación del entorno

#### 1. Activar el entorno virtual

**Windows (cmd/PowerShell):**
```cmd
cd C:\proyectos\rf-curso
.\venv\Scripts\activate
```

**macOS / Linux (bash/zsh):**
```bash
cd ~/proyectos/rf-curso
source venv/bin/activate
```

#### 2. Verificar e instalar dependencias

```bash
# Verificar que DataDriver con soporte CSV esté instalado
pip show robotframework-datadriver

# Si no está instalado o falta el extra CSV:
pip install "robotframework-datadriver[CSV]"

# Verificar RequestsLibrary y JSONLibrary
pip show robotframework-requests
pip show robotframework-jsonlibrary

# Instalar JSONLibrary si falta
pip install robotframework-jsonlibrary
```

#### 3. Crear la estructura de directorios del proyecto

```bash
# Desde la raíz del proyecto (rf-curso/)
mkdir -p lab07-02/tests
mkdir -p lab07-02/data
mkdir -p lab07-02/resources/schemas
mkdir -p lab07-02/resources/keywords
mkdir -p lab07-02/results
```

**Estructura final esperada:**
```
lab07-02/
├── tests/
│   ├── smoke_suite.robot
│   └── regression_suite.robot
├── data/
│   ├── smoke_data.csv
│   └── regression_data.csv
├── resources/
│   ├── keywords/
│   │   └── api_keywords.resource
│   └── schemas/
│       └── user_schema.json
└── results/
```

---

## Instrucciones Paso a Paso

---

### Paso 1: Diseñar y crear los archivos CSV de datos de prueba

**Objetivo:** Construir los archivos CSV que alimentarán las suites smoke y regresión, justificando la selección de cada caso según criterios de cobertura.

#### Instrucciones

**1.1 Crear el archivo `data/smoke_data.csv`**

Este archivo contiene los 5 casos del camino feliz. Cada fila representa un caso de prueba válido con respuesta exitosa esperada.

Crea el archivo `lab07-02/data/smoke_data.csv` con el siguiente contenido:

```csv
*** Test Cases ***,${endpoint},${method},${payload},${expected_status},${expected_field}
GET All Users,/users,GET,NONE,200,data
GET Single User,/users/2,GET,NONE,200,data
CREATE User,/users,POST,{"name": "Ana López","job": "QA Engineer"},201,name
UPDATE User,/users/2,PUT,{"name": "Ana López","job": "Senior QA"},200,name
GET Non-Paginated Resource,/unknown,GET,NONE,200,data
```

> **Criterio de cobertura smoke:** Se seleccionan los verbos HTTP más frecuentes (GET, POST, PUT) sobre el recurso principal (`/users`), cubriendo operaciones de lectura de colección, lectura individual, creación y actualización. Son los casos que deben pasar en cada despliegue para considerar el sistema operativo.

**1.2 Crear el archivo `data/regression_data.csv`**

Este archivo contiene 8 casos que cubren errores, límites y casos extremos.

Crea el archivo `lab07-02/data/regression_data.csv` con el siguiente contenido:

```csv
*** Test Cases ***,${endpoint},${method},${payload},${expected_status},${expected_field}
GET User Not Found,/users/999,GET,NONE,404,NONE
POST Invalid Payload Missing Name,/users,POST,{"job": "tester"},201,id
POST Empty Payload,/users,POST,{},201,id
PUT Non-Existent User,/users/999,PUT,{"name": "Ghost","job": "none"},200,name
DELETE Existing User,/users/2,DELETE,NONE,204,NONE
DELETE Non-Existent User,/users/999,DELETE,NONE,204,NONE
GET Page Out Of Range,/users?page=9999,GET,NONE,200,data
POST User With Special Characters,/users,POST,{"name": "Ñoño Ñández","job": "Diseño & UX"},201,name
```

> **Criterio de cobertura regresión:** Se incluyen errores 404 (recurso inexistente), payloads con campos faltantes o vacíos (límite de validación), operaciones DELETE (verificar idempotencia), paginación fuera de rango y caracteres especiales (encoding). Estos casos exponen comportamientos en los bordes del contrato de la API.

> **Nota sobre la API objetivo:** Usaremos `https://reqres.in` como servidor de pruebas. Esta API pública simula respuestas realistas para todos los casos de prueba definidos. Reqres.in no requiere autenticación real, pero acepta tokens Bearer en el header `Authorization` sin rechazarlos, lo que permite practicar la gestión de autenticación.

**Resultado esperado:** Dos archivos CSV en `lab07-02/data/` con las cabeceras correctas y el número de filas de datos indicado.

**Verificación:**
```bash
# Contar líneas de cada CSV (debe mostrar 6 y 9 respectivamente: 1 cabecera + datos)
wc -l lab07-02/data/smoke_data.csv
wc -l lab07-02/data/regression_data.csv

# Windows PowerShell:
(Get-Content lab07-02\data\smoke_data.csv).Count
(Get-Content lab07-02\data\regression_data.csv).Count
```

---

### Paso 2: Crear el esquema JSON para contract testing

**Objetivo:** Definir el contrato de la estructura de respuesta del recurso `/users` en un archivo JSON externo que será validado por la keyword de contract testing.

#### Instrucciones

**2.1 Crear el archivo `resources/schemas/user_schema.json`**

Crea el archivo `lab07-02/resources/schemas/user_schema.json`:

```json
{
  "schema_name": "reqres_user_response",
  "version": "1.0",
  "description": "Esquema de contrato para respuestas del recurso /users de reqres.in",
  "required_fields_collection": ["page", "per_page", "total", "total_pages", "data"],
  "required_fields_single": ["data"],
  "required_fields_user_object": ["id", "email", "first_name", "last_name", "avatar"],
  "required_fields_create": ["name", "job", "id", "createdAt"],
  "required_fields_update": ["name", "job", "updatedAt"]
}
```

> **¿Por qué un archivo externo?** Separar el esquema del código de prueba permite actualizar el contrato sin modificar los archivos `.robot`. Es la base del *contract testing*: si la API cambia su estructura, el esquema falla antes de que el equipo lo detecte manualmente.

**Resultado esperado:** Archivo JSON válido en `resources/schemas/user_schema.json`.

**Verificación:**
```bash
# Validar que el JSON es sintácticamente correcto
python -c "import json; json.load(open('lab07-02/resources/schemas/user_schema.json')); print('JSON válido')"
```

---

### Paso 3: Crear el archivo de keywords compartidas

**Objetivo:** Construir el archivo Resource con todas las keywords reutilizables: gestión de sesión, autenticación, despacho dinámico de métodos HTTP y contract testing.

#### Instrucciones

**3.1 Crear `resources/keywords/api_keywords.resource`**

Crea el archivo `lab07-02/resources/keywords/api_keywords.resource`:

```robot
*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    JSONLibrary

*** Variables ***
${BASE_URL}           https://reqres.in/api
${SESSION_ALIAS}      reqres_session
${TOKEN}              Bearer reqres-fake-token-12345
${SCHEMA_FILE}        ${CURDIR}/../schemas/user_schema.json

*** Keywords ***

# ─────────────────────────────────────────────
# GESTIÓN DE SESIÓN Y AUTENTICACIÓN
# ─────────────────────────────────────────────

Inicializar Sesión API
    [Documentation]    Crea la sesión HTTP reutilizable y simula la obtención del token de autenticación.
    ...    En un entorno real, este keyword haría un POST a /auth/login para obtener el token.
    ...    Para reqres.in usamos un token estático que el servidor acepta sin validar.
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    Authorization=${TOKEN}
    Create Session
    ...    alias=${SESSION_ALIAS}
    ...    url=${BASE_URL}
    ...    headers=${headers}
    ...    verify=True
    Log    Sesión '${SESSION_ALIAS}' inicializada contra ${BASE_URL}    level=INFO
    Log    Token de autenticación configurado en headers de sesión    level=INFO

Cerrar Sesión API
    [Documentation]    Elimina la sesión HTTP al finalizar la suite.
    Delete All Sessions
    Log    Todas las sesiones HTTP han sido cerradas    level=INFO

# ─────────────────────────────────────────────
# DESPACHO DINÁMICO DE MÉTODOS HTTP
# ─────────────────────────────────────────────

Ejecutar Petición HTTP
    [Documentation]    Despacha la petición HTTP correcta según el método recibido como parámetro.
    ...    Retorna el objeto response de RequestsLibrary.
    [Arguments]    ${method}    ${endpoint}    ${payload}=NONE
    ${response}=    Run Keyword If    '${method}' == 'GET'
    ...    Ejecutar GET    ${endpoint}
    ...    ELSE IF    '${method}' == 'POST'
    ...    Ejecutar POST    ${endpoint}    ${payload}
    ...    ELSE IF    '${method}' == 'PUT'
    ...    Ejecutar PUT    ${endpoint}    ${payload}
    ...    ELSE IF    '${method}' == 'DELETE'
    ...    Ejecutar DELETE    ${endpoint}
    ...    ELSE    Fail    Método HTTP no soportado: ${method}
    [Return]    ${response}

Ejecutar GET
    [Documentation]    Realiza una petición GET sobre el endpoint indicado.
    [Arguments]    ${endpoint}
    ${response}=    GET On Session    ${SESSION_ALIAS}    ${endpoint}    expected_status=any
    [Return]    ${response}

Ejecutar POST
    [Documentation]    Realiza una petición POST con el payload JSON indicado.
    [Arguments]    ${endpoint}    ${payload_str}
    ${payload_dict}=    Convertir Payload A Diccionario    ${payload_str}
    ${response}=    POST On Session
    ...    ${SESSION_ALIAS}
    ...    ${endpoint}
    ...    json=${payload_dict}
    ...    expected_status=any
    [Return]    ${response}

Ejecutar PUT
    [Documentation]    Realiza una petición PUT con el payload JSON indicado.
    [Arguments]    ${endpoint}    ${payload_str}
    ${payload_dict}=    Convertir Payload A Diccionario    ${payload_str}
    ${response}=    PUT On Session
    ...    ${SESSION_ALIAS}
    ...    ${endpoint}
    ...    json=${payload_dict}
    ...    expected_status=any
    [Return]    ${response}

Ejecutar DELETE
    [Documentation]    Realiza una petición DELETE sobre el endpoint indicado.
    [Arguments]    ${endpoint}
    ${response}=    DELETE On Session    ${SESSION_ALIAS}    ${endpoint}    expected_status=any
    [Return]    ${response}

# ─────────────────────────────────────────────
# UTILIDADES DE DATOS
# ─────────────────────────────────────────────

Convertir Payload A Diccionario
    [Documentation]    Convierte una cadena JSON a diccionario Python.
    ...    Si el valor es 'NONE', retorna un diccionario vacío.
    [Arguments]    ${payload_str}
    ${is_none}=    Run Keyword And Return Status
    ...    Should Be Equal    ${payload_str}    NONE
    ${payload_dict}=    Run Keyword If    ${is_none}
    ...    Create Dictionary
    ...    ELSE    Load JSON From String    ${payload_str}
    [Return]    ${payload_dict}

# ─────────────────────────────────────────────
# VALIDACIONES
# ─────────────────────────────────────────────

Validar Código De Estado
    [Documentation]    Verifica que el código de estado HTTP de la respuesta coincide con el esperado.
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Integers
    ...    ${response.status_code}
    ...    ${expected_status}
    ...    msg=Código de estado incorrecto. Esperado: ${expected_status}, Obtenido: ${response.status_code}
    Log    ✓ Código de estado correcto: ${response.status_code}    level=INFO

Validar Campo En Respuesta
    [Documentation]    Verifica que un campo específico existe en el body JSON de la respuesta.
    ...    Si expected_field es 'NONE', omite la validación (útil para respuestas 204 sin body).
    [Arguments]    ${response}    ${expected_field}
    ${skip}=    Run Keyword And Return Status
    ...    Should Be Equal    ${expected_field}    NONE
    Run Keyword If    ${skip}
    ...    Log    Validación de campo omitida (expected_field=NONE)    level=INFO
    Run Keyword Unless    ${skip}
    ...    Verificar Campo En Body    ${response}    ${expected_field}

Verificar Campo En Body
    [Documentation]    Keyword auxiliar que extrae el JSON y verifica la presencia del campo.
    [Arguments]    ${response}    ${field}
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key
    ...    ${body}
    ...    ${field}
    ...    msg=El campo '${field}' no está presente en la respuesta JSON
    Log    ✓ Campo '${field}' presente en la respuesta    level=INFO

Validar Esquema De Respuesta
    [Documentation]    Contract testing básico: carga el esquema JSON externo y verifica que los campos
    ...    obligatorios definidos para colecciones de usuarios están presentes en la respuesta.
    ...    Solo aplica a respuestas con status 200 que contengan el campo 'data'.
    [Arguments]    ${response}    ${expected_status}
    # Solo validar contrato en respuestas exitosas de colección
    ${is_success}=    Run Keyword And Return Status
    ...    Should Be Equal As Integers    ${expected_status}    200
    ${body}=    Run Keyword If    ${is_success}
    ...    Set Variable    ${response.json()}
    ${has_data}=    Run Keyword If    ${is_success}
    ...    Run Keyword And Return Status    Dictionary Should Contain Key    ${body}    data
    Run Keyword If    ${is_success} and ${has_data}
    ...    Verificar Campos Obligatorios De Esquema    ${body}

Verificar Campos Obligatorios De Esquema
    [Documentation]    Lee el archivo de esquema y verifica cada campo obligatorio de colección.
    [Arguments]    ${body}
    ${schema_content}=    Get File    ${SCHEMA_FILE}
    ${schema}=    Load JSON From String    ${schema_content}
    ${required_fields}=    Get From Dictionary    ${schema}    required_fields_collection
    FOR    ${field}    IN    @{required_fields}
        ${present}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${body}    ${field}
        Run Keyword If    ${present}
        ...    Log    ✓ Campo de esquema '${field}' presente    level=INFO
        Run Keyword Unless    ${present}
        ...    Log    ✗ CONTRATO VIOLADO: Campo '${field}' ausente en respuesta    level=WARN
    END

# ─────────────────────────────────────────────
# TEMPLATE PRINCIPAL
# ─────────────────────────────────────────────

Execute API Test Case
    [Documentation]    Template keyword principal para suites data-driven.
    ...    Recibe todos los parámetros del CSV, ejecuta la petición y realiza las validaciones.
    [Arguments]    ${endpoint}    ${method}    ${payload}    ${expected_status}    ${expected_field}
    Log    ═══════════════════════════════════════    level=INFO
    Log    Ejecutando: ${method} ${endpoint}    level=INFO
    Log    Payload: ${payload}    level=INFO
    Log    Esperado: status=${expected_status} | campo=${expected_field}    level=INFO
    # Ejecutar la petición HTTP con despacho dinámico por método
    ${response}=    Ejecutar Petición HTTP    ${method}    ${endpoint}    ${payload}
    Log    Respuesta recibida: status=${response.status_code}    level=INFO
    # Validación 1: código de estado HTTP
    Validar Código De Estado    ${response}    ${expected_status}
    # Validación 2: campo específico en el body
    Validar Campo En Respuesta    ${response}    ${expected_field}
    # Validación 3: contract testing (solo para respuestas 200 con colección)
    Validar Esquema De Respuesta    ${response}    ${expected_status}
    Log    ✓ Caso de prueba completado exitosamente    level=INFO
```

**Resultado esperado:** Archivo Resource sin errores de sintaxis, con todas las keywords documentadas y organizadas por secciones.

**Verificación:**
```bash
# Verificar sintaxis del archivo Resource con Robot Framework
python -m robot --dryrun --outputdir lab07-02/results lab07-02/resources/keywords/api_keywords.resource
# Nota: el dryrun en un .resource puede mostrar advertencias sobre ausencia de test cases; esto es normal
```

---

### Paso 4: Crear la suite smoke

**Objetivo:** Construir `tests/smoke_suite.robot` usando DataDriver con `smoke_data.csv`, configurando el `Suite Setup` para autenticación compartida y aplicando tags de prioridad.

#### Instrucciones

**4.1 Crear `tests/smoke_suite.robot`**

Crea el archivo `lab07-02/tests/smoke_suite.robot`:

```robot
*** Settings ***
Documentation       Suite de pruebas SMOKE para la API de reqres.in
...                 Objetivo: Verificar que las operaciones fundamentales (happy path) funcionan
...                 correctamente en cada despliegue. Estos casos deben pasar siempre.
...
...                 API objetivo: https://reqres.in/api
...                 Fuente de datos: data/smoke_data.csv
...                 Autenticación: Bearer token (gestionado en Suite Setup)
...
...                 Criterio de selección smoke: Operaciones CRUD básicas sobre /users
...                 con respuestas exitosas esperadas (2xx). Son el mínimo viable de cobertura.

Metadata            version         1.0
Metadata            author          Equipo QA Telecomunicaciones
Metadata            environment     testing
Metadata            api_target      reqres.in

Library             DataDriver
...                 file=${CURDIR}/../data/smoke_data.csv
...                 encoding=utf-8
...                 dialect=excel

Resource            ${CURDIR}/../resources/keywords/api_keywords.resource

Suite Setup         Inicializar Sesión API
Suite Teardown      Cerrar Sesión API

Test Tags           smoke    api    priority:high

*** Test Cases ***
Execute API Test Case
    [Documentation]    Template data-driven: cada fila del CSV genera un caso de prueba independiente.
    ...    Los parámetros son inyectados automáticamente por DataDriver desde smoke_data.csv.
    [Template]    Execute API Test Case
    [Tags]    smoke    api    priority:high
    # DataDriver reemplaza estos valores con cada fila del CSV en tiempo de ejecución
    ${endpoint}    ${method}    ${payload}    ${expected_status}    ${expected_field}
```

> **¿Por qué un solo Test Case con Template?** DataDriver expande el template en tiempo de carga del framework: cada fila del CSV se convierte en un caso de prueba independiente con su propio nombre (tomado de la primera columna del CSV), su propio resultado y su propia entrada en el reporte HTML. El template keyword `Execute API Test Case` contiene toda la lógica de ejecución y validación.

**Resultado esperado:** Archivo suite válido que DataDriver puede expandir en 5 casos de prueba individuales.

**Verificación (dry-run):**
```bash
cd lab07-02
python -m robot --dryrun --outputdir results tests/smoke_suite.robot
```

Debes ver en la salida algo similar a:
```
SUITE: Smoke Suite
  TEST: GET All Users
  TEST: GET Single User
  TEST: CREATE User
  TEST: UPDATE User
  TEST: GET Non-Paginated Resource
```

---

### Paso 5: Crear la suite de regresión

**Objetivo:** Construir `tests/regression_suite.robot` usando DataDriver con `regression_data.csv`, incluyendo documentación de criterios de cobertura y tags diferenciados.

#### Instrucciones

**5.1 Crear `tests/regression_suite.robot`**

Crea el archivo `lab07-02/tests/regression_suite.robot`:

```robot
*** Settings ***
Documentation       Suite de pruebas de REGRESIÓN para la API de reqres.in
...                 Objetivo: Verificar el comportamiento de la API ante casos extremos,
...                 errores esperados, payloads inválidos y condiciones de límite.
...                 Estos casos complementan el smoke test y se ejecutan en cada ciclo de regresión.
...
...                 API objetivo: https://reqres.in/api
...                 Fuente de datos: data/regression_data.csv
...                 Autenticación: Bearer token (gestionado en Suite Setup)
...
...                 Criterio de selección regresión:
...                 - Errores 404: recursos inexistentes
...                 - Payloads incompletos o vacíos: validación de campos opcionales
...                 - Operaciones DELETE: verificación de idempotencia (204 en ambos casos)
...                 - Paginación fuera de rango: comportamiento con parámetros extremos
...                 - Caracteres especiales: verificación de encoding UTF-8

Metadata            version         1.0
Metadata            author          Equipo QA Telecomunicaciones
Metadata            environment     testing
Metadata            api_target      reqres.in
Metadata            coverage_type   edge-cases, error-handling, boundary-values

Library             DataDriver
...                 file=${CURDIR}/../data/regression_data.csv
...                 encoding=utf-8
...                 dialect=excel

Resource            ${CURDIR}/../resources/keywords/api_keywords.resource

Suite Setup         Inicializar Sesión API
Suite Teardown      Cerrar Sesión API

Test Tags           regression    api

*** Test Cases ***
Execute API Test Case
    [Documentation]    Template data-driven: cada fila del CSV genera un caso de prueba independiente.
    ...    Los parámetros son inyectados automáticamente por DataDriver desde regression_data.csv.
    ...    Los casos de error (4xx) son válidos y esperados; no representan fallos del test.
    [Template]    Execute API Test Case
    [Tags]    regression    api
    # DataDriver reemplaza estos valores con cada fila del CSV en tiempo de ejecución
    ${endpoint}    ${method}    ${payload}    ${expected_status}    ${expected_field}
```

**Resultado esperado:** Archivo suite válido que DataDriver puede expandir en 8 casos de prueba individuales.

**Verificación (dry-run):**
```bash
python -m robot --dryrun --outputdir results tests/regression_suite.robot
```

Debes ver 8 casos de prueba listados con sus nombres del CSV.

---

### Paso 6: Ejecutar las suites y verificar resultados

**Objetivo:** Ejecutar ambas suites de forma independiente y consolidada, verificando que los resultados son los esperados y que el reporte HTML es legible.

#### Instrucciones

**6.1 Ejecutar únicamente la suite smoke**

```bash
cd lab07-02
python -m robot \
    --outputdir results/smoke \
    --output smoke_output.xml \
    --report smoke_report.html \
    --log smoke_log.html \
    --loglevel INFO \
    --include smoke \
    tests/smoke_suite.robot
```

**Windows PowerShell:**
```powershell
cd lab07-02
python -m robot `
    --outputdir results\smoke `
    --output smoke_output.xml `
    --report smoke_report.html `
    --log smoke_log.html `
    --loglevel INFO `
    --include smoke `
    tests\smoke_suite.robot
```

**Resultado esperado:**
```
==============================================================================
Smoke Suite
==============================================================================
GET All Users                                                         | PASS |
GET Single User                                                       | PASS |
CREATE User                                                           | PASS |
UPDATE User                                                           | PASS |
GET Non-Paginated Resource                                            | PASS |
==============================================================================
Smoke Suite                                                           | PASS |
5 tests, 5 passed, 0 failed
==============================================================================
```

**6.2 Ejecutar únicamente la suite de regresión**

```bash
python -m robot \
    --outputdir results/regression \
    --output regression_output.xml \
    --report regression_report.html \
    --log regression_log.html \
    --loglevel INFO \
    --include regression \
    tests/regression_suite.robot
```

**Resultado esperado:** 8 tests ejecutados. Los casos con `expected_status=404` y `expected_status=204` deben pasar porque la keyword `Validar Código De Estado` verifica el código esperado (no asume siempre 200).

**6.3 Ejecutar ambas suites de forma consolidada con reporte unificado**

```bash
python -m robot \
    --outputdir results/full \
    --output full_output.xml \
    --report full_report.html \
    --log full_log.html \
    --loglevel INFO \
    tests/smoke_suite.robot tests/regression_suite.robot
```

**6.4 Ejecutar solo casos de alta prioridad (tag `priority:high`)**

```bash
python -m robot \
    --outputdir results/priority \
    --include priority:high \
    tests/smoke_suite.robot tests/regression_suite.robot
```

> Solo se ejecutarán los casos del CSV smoke que tienen el tag `priority:high` heredado del `Test Tags` de la suite.

**6.5 Generar reporte consolidado combinando XMLs existentes**

```bash
python -m rebot \
    --outputdir results/combined \
    --output combined_output.xml \
    --report combined_report.html \
    --log combined_log.html \
    --name "Suite API Data-Driven Completa" \
    results/smoke/smoke_output.xml \
    results/regression/regression_output.xml
```

**Resultado esperado:** Un único reporte HTML en `results/combined/combined_report.html` mostrando las dos suites con sus 13 casos totales (5 smoke + 8 regresión).

---

## Validación y Pruebas

### Lista de verificación de resultados

Ejecuta los siguientes comandos para confirmar que todo funciona correctamente:

```bash
cd lab07-02

# 1. Verificar que los 5 casos smoke pasaron
python -m robot --outputdir results/validate_smoke tests/smoke_suite.robot
# Resultado esperado: "5 tests, 5 passed, 0 failed"

# 2. Verificar que los 8 casos de regresión pasaron
python -m robot --outputdir results/validate_regression tests/regression_suite.robot
# Resultado esperado: "8 tests, 8 passed, 0 failed"

# 3. Verificar filtrado por tag smoke
python -m robot --include smoke --dryrun --outputdir results/dryrun tests/
# Debe listar exactamente 5 tests

# 4. Verificar filtrado por tag regression
python -m robot --include regression --dryrun --outputdir results/dryrun tests/
# Debe listar exactamente 8 tests

# 5. Verificar que el contrato se valida (ejecutar con log verbose)
python -m robot --loglevel DEBUG --outputdir results/contract_check \
    --include smoke tests/smoke_suite.robot
# En el log debe aparecer: "✓ Campo de esquema 'page' presente"
```

### Verificación del reporte HTML

1. Abre `results/full/full_report.html` en tu navegador.
2. Confirma que la vista muestra **dos suites** (`Smoke Suite` y `Regression Suite`).
3. Expande el caso `GET All Users` y verifica que el log muestra los tres pasos de validación: código de estado, campo en body y contract testing.
4. Expande el caso `GET User Not Found` y confirma que el status 404 está registrado como **PASS** (no como fallo), ya que era el comportamiento esperado.
5. Verifica que la sección **Statistics** muestra los tags `smoke`, `regression`, `api` y `priority:high` con sus conteos correctos.

### Verificación de la estructura de archivos final

```bash
# Listar toda la estructura del proyecto
find lab07-02 -type f | sort

# Resultado esperado:
# lab07-02/data/regression_data.csv
# lab07-02/data/smoke_data.csv
# lab07-02/resources/keywords/api_keywords.resource
# lab07-02/resources/schemas/user_schema.json
# lab07-02/tests/regression_suite.robot
# lab07-02/tests/smoke_suite.robot
# (más archivos en results/)
```

**Windows PowerShell:**
```powershell
Get-ChildItem -Path lab07-02 -Recurse -File | Select-Object FullName | Sort-Object FullName
```

---

## Resolución de Problemas

### Problema 1: DataDriver no expande los casos de prueba — el test case se llama literalmente "Execute API Test Case" en el reporte

**Síntomas:**
- El reporte HTML muestra un único caso llamado `Execute API Test Case` en lugar de los 5 o 8 casos individuales con sus nombres del CSV.
- La salida de consola muestra `1 test, 1 passed` en lugar del número esperado.
- No hay errores de importación ni de sintaxis.

**Causa:**
La primera columna del CSV no tiene el encabezado correcto `*** Test Cases ***`. DataDriver requiere exactamente esta cadena (con los asteriscos y espacios) como nombre de la primera columna para identificar los nombres de los casos de prueba. Si la columna tiene otro nombre (por ejemplo `test_name` o `Test Case`), DataDriver no puede mapear los casos y ejecuta el template una sola vez con los valores literales del CSV.

**Solución:**
1. Abre el CSV problemático en un editor de texto plano (no en Excel, que puede alterar el formato).
2. Verifica que la primera línea sea exactamente:
   ```
   *** Test Cases ***,${endpoint},${method},${payload},${expected_status},${expected_field}
   ```
3. Comprueba que no hay espacios extras al inicio ni al final de `*** Test Cases ***`.
4. Si el archivo fue editado con Excel, verifica que no se hayan añadido comillas alrededor de los valores o cambiado el delimitador a punto y coma.
5. Re-ejecuta con `--dryrun` para confirmar que ahora lista los casos individuales.

---

### Problema 2: Error `JSONDecodeError` o `KeyError` en la keyword `Convertir Payload A Diccionario` para casos con payload `NONE`

**Síntomas:**
- Los casos GET y DELETE fallan con un error similar a:
  ```
  JSONDecodeError: Expecting value: line 1 column 1 (char 0)
  ```
  o bien:
  ```
  KeyError: The keyword 'Load JSON From String' got unexpected argument
  ```
- Solo fallan los casos cuyo campo `payload` en el CSV es `NONE`; los casos POST y PUT con payload JSON pasan correctamente.

**Causa:**
La keyword `Convertir Payload A Diccionario` usa `Run Keyword And Return Status` para detectar si el payload es la cadena `NONE`. Sin embargo, si hay espacios en blanco invisibles al inicio o final del valor en el CSV (por ejemplo `NONE ` con un espacio), la comparación `Should Be Equal ${payload_str} NONE` falla, y se intenta parsear la cadena `NONE` como JSON, lo que produce el error. También puede ocurrir si el CSV fue guardado con codificación distinta a UTF-8 y el valor contiene un BOM o carácter invisible.

**Solución:**
1. Abre el CSV con un editor hexadecimal o usa Python para inspeccionar el valor:
   ```python
   import csv
   with open('lab07-02/data/smoke_data.csv', encoding='utf-8') as f:
       reader = csv.DictReader(f)
       for row in reader:
           print(repr(row['${payload}']))
   ```
2. Si hay espacios, corrige el CSV eliminándolos. Los valores `NONE` deben ser exactamente `NONE` sin caracteres adicionales.
3. Alternativamente, modifica la keyword `Convertir Payload A Diccionario` para usar `Strip String` antes de la comparación:
   ```robot
   Convertir Payload A Diccionario
       [Arguments]    ${payload_str}
       ${payload_clean}=    Strip String    ${payload_str}
       ${is_none}=    Run Keyword And Return Status
       ...    Should Be Equal    ${payload_clean}    NONE
       ${payload_dict}=    Run Keyword If    ${is_none}
       ...    Create Dictionary
       ...    ELSE    Load JSON From String    ${payload_clean}
       [Return]    ${payload_dict}
   ```
4. Re-guarda el CSV con codificación UTF-8 sin BOM desde VS Code: `Ctrl+Shift+P` → `Change File Encoding` → `Save with Encoding: UTF-8`.

---

## Limpieza

Una vez completado el laboratorio y verificados todos los resultados:

```bash
# 1. Desactivar el entorno virtual
deactivate

# 2. (Opcional) Comprimir el proyecto para respaldo antes del siguiente laboratorio
# Linux/macOS:
tar -czf lab07-02-backup.tar.gz lab07-02/

# Windows PowerShell:
Compress-Archive -Path lab07-02 -DestinationPath lab07-02-backup.zip

# 3. (Opcional) Limpiar resultados intermedios manteniendo solo el reporte consolidado
# Linux/macOS:
rm -rf lab07-02/results/smoke lab07-02/results/regression lab07-02/results/priority
# Conservar: lab07-02/results/full/ y lab07-02/results/combined/

# Windows PowerShell:
Remove-Item -Recurse -Force lab07-02\results\smoke
Remove-Item -Recurse -Force lab07-02\results\regression
```

> **Importante:** Conserva el directorio `lab07-02/` completo. Los laboratorios posteriores del Módulo 7 pueden requerir los archivos Resource y esquemas JSON creados en esta práctica.

---

## Resumen

En esta práctica construiste una arquitectura de suite API data-driven completa y autónoma. Los conceptos clave aplicados fueron:

| Concepto                        | Implementación en el laboratorio                                               |
|---------------------------------|--------------------------------------------------------------------------------|
| **Data-driven con DataDriver**  | Dos archivos CSV con cabecera `*** Test Cases ***` expandidos en suites independientes |
| **Separación smoke/regresión**  | Criterios de cobertura documentados; smoke = happy path, regresión = edge cases |
| **Despacho dinámico HTTP**      | `Run Keyword If` en `Ejecutar Petición HTTP` selecciona GET/POST/PUT/DELETE     |
| **Contract testing básico**     | `user_schema.json` externo; `Verificar Campos Obligatorios De Esquema` valida campos obligatorios |
| **Sesión compartida**           | `Suite Setup` llama a `Inicializar Sesión API` una vez por suite                |
| **Tags avanzados**              | `smoke`, `regression`, `api`, `priority:high` permiten filtrado desde CLI       |
| **Reporte consolidado**         | `rebot` combina XMLs de ejecuciones separadas en un único reporte HTML          |

### Comandos CLI esenciales aprendidos

```bash
# Ejecutar por tag
python -m robot --include smoke tests/

# Ejecutar múltiples suites
python -m robot tests/smoke_suite.robot tests/regression_suite.robot

# Combinar reportes
python -m rebot --outputdir results/combined output1.xml output2.xml

# Dry-run para verificar expansión DataDriver
python -m robot --dryrun tests/
```

### Recursos de referencia

- [Documentación oficial DataDriver Library](https://github.com/Snooz82/robotframework-datadriver)
- [RequestsLibrary — Keywords de referencia](https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html)
- [reqres.in — API pública para pruebas](https://reqres.in/)
- [Robot Framework — Guía de tags y filtrado CLI](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#tagging-test-cases)
- [RFC 9110 — Métodos HTTP semánticos](https://www.rfc-editor.org/rfc/rfc9110)

---
