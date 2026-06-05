# Práctica 13: Suite de pruebas API con autenticación Bearer y validación JSON

## Metadatos

| Campo            | Detalle                          |
|------------------|----------------------------------|
| **Duración**     | 72 minutos                       |
| **Complejidad**  | Media                            |
| **Nivel Bloom**  | Aplicar (Apply)                  |
| **Módulo**       | 7 — Pruebas de API REST          |
| **Laboratorio**  | 07-00-01 / Práctica 13           |

---

## Descripción General

En este laboratorio construirás una suite completa de pruebas API contra la API pública **ReqRes** (`https://reqres.in`), que incluye un endpoint de autenticación real con token Bearer. Aplicarás los conceptos de métodos HTTP (GET, POST, PUT, DELETE), códigos de estado y headers aprendidos en la Lección 7.1 para diseñar casos de prueba estructurados, reutilizables y organizados en dos archivos: pruebas *smoke* y pruebas de regresión. Al finalizar dispondrás de una suite profesional con keywords centralizadas, validación JSON con JSONPath y manejo de datos dinámicos entre peticiones encadenadas.

---

## Objetivos de Aprendizaje

- [ ] Configurar `RequestsLibrary` con sesiones persistentes, headers base y timeout para interactuar con una API REST real.
- [ ] Implementar el flujo completo de autenticación Bearer: obtener token vía `POST /api/login`, almacenarlo en variable de suite y reutilizarlo en peticiones subsecuentes.
- [ ] Validar respuestas JSON usando JSONPath, aserciones de código de estado HTTP y verificación básica de contrato (campos obligatorios y tipos de dato).
- [ ] Organizar la suite con separación entre pruebas *smoke* y de regresión usando tags, y centralizar keywords en un archivo `resources/api_keywords.robot`.
- [ ] Encadenar peticiones dependientes extrayendo IDs dinámicos de respuestas previas (POST → GET → DELETE).

---

## Prerrequisitos

### Conocimientos

- Haber completado los Módulos 1–5 del curso (keywords, recursos, variables, estructura de suites).
- Comprensión de los conceptos de la Lección 7.1: métodos HTTP, códigos de estado, headers y payloads JSON.
- Familiaridad básica con formato JSON y estructura de APIs REST.
- Haber explorado manualmente ReqRes con Postman o `curl` (recomendado, no obligatorio).

### Acceso y Software

| Componente                  | Versión mínima | Verificación                              |
|-----------------------------|----------------|-------------------------------------------|
| Python                      | 3.10+          | `python --version`                        |
| Robot Framework             | 7.x            | `robot --version`                         |
| RequestsLibrary             | 0.9+           | `pip show robotframework-requests`        |
| JSONLibrary                 | 0.5+           | `pip show robotframework-jsonlibrary`     |
| Conexión a internet         | 10 Mbps+       | Acceso a `https://reqres.in`              |
| VS Code + RF Language Server| 1.85+ / 1.12+  | Extensión activa en VS Code               |

---

## Entorno de Laboratorio

### Configuración del Entorno Virtual

> ⚠️ **OBLIGATORIO:** Todos los comandos deben ejecutarse dentro del entorno virtual Python del curso. Verifica que esté activo antes de continuar.

**Activar el entorno virtual:**

```bash
# Windows (cmd)
cd C:\curso-robotframework
Scripts\activate

# Windows (PowerShell)
cd C:\curso-robotframework
.\Scripts\Activate.ps1

# macOS / Linux (bash/zsh)
cd ~/curso-robotframework
source bin/activate
```

**Instalar dependencias del laboratorio:**

```bash
pip install robotframework-requests
pip install robotframework-jsonlibrary
```

**Verificar instalación:**

```bash
pip show robotframework-requests robotframework-jsonlibrary
```

Deberías ver la información de ambos paquetes sin errores.

### Estructura de Carpetas del Proyecto

Crea la siguiente estructura dentro de tu directorio de trabajo del curso:

```
lab-07-00-01/
├── resources/
│   └── api_keywords.robot
├── tests/
│   ├── smoke_tests.robot
│   └── regression_tests.robot
├── results/
└── README.md
```

**Crear la estructura con comandos:**

```bash
# Windows (cmd/PowerShell)
mkdir lab-07-00-01
cd lab-07-00-01
mkdir resources tests results

# macOS / Linux
mkdir -p lab-07-00-01/{resources,tests,results}
cd lab-07-00-01
```

---

## Pasos del Laboratorio

---

### Paso 1: Exploración Manual de la API ReqRes

**Objetivo:** Familiarizarse con los endpoints de ReqRes que se usarán en el laboratorio antes de automatizarlos.

#### Instrucciones

1. Abre una terminal (con el venv activo) y ejecuta los siguientes comandos `curl` para explorar la API. Si prefieres Postman, importa las URLs equivalentes.

2. **Explorar endpoint de login (obtención de token):**

```bash
curl -s -X POST https://reqres.in/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "eve.holt@reqres.in", "password": "cityslicka"}' | python -m json.tool
```

3. **Explorar listado de usuarios:**

```bash
curl -s https://reqres.in/api/users?page=1 | python -m json.tool
```

4. **Explorar usuario individual:**

```bash
curl -s https://reqres.in/api/users/2 | python -m json.tool
```

5. **Explorar creación de usuario:**

```bash
curl -s -X POST https://reqres.in/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Ana Lopez", "job": "QA Engineer"}' | python -m json.tool
```

#### Salida Esperada

El endpoint de login debe devolver algo similar a:

```json
{
    "token": "QpwL5tpe83ilfN2"
}
```

El endpoint de usuarios debe devolver una lista con campos `id`, `email`, `first_name`, `last_name`, `avatar`.

#### Verificación

- [ ] El endpoint `/api/login` devuelve un campo `token` en la respuesta.
- [ ] El endpoint `/api/users/2` devuelve un objeto con campo `data.id = 2`.
- [ ] El endpoint `POST /api/users` devuelve código `201` con un campo `id` generado.

---

### Paso 2: Crear el Archivo de Keywords Reutilizables

**Objetivo:** Centralizar toda la lógica de autenticación y validación JSON en un único archivo de recursos, siguiendo el principio DRY (Don't Repeat Yourself).

#### Instrucciones

1. Abre VS Code y navega a `lab-07-00-01/resources/`.

2. Crea el archivo `api_keywords.robot` con el siguiente contenido completo:

```robot
*** Settings ***
Documentation    Recursos compartidos para la suite de pruebas API de ReqRes.
...              Contiene keywords de autenticación, configuración de sesión
...              y validación de respuestas JSON reutilizables.
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections
Library          String

*** Variables ***
${BASE_URL}          https://reqres.in
${API_PREFIX}        /api
${LOGIN_ENDPOINT}    /api/login
${USERS_ENDPOINT}    /api/users
${TIMEOUT}           10
${LOGIN_EMAIL}       eve.holt@reqres.in
${LOGIN_PASSWORD}    cityslicka

# Variable de suite para almacenar el token (se asigna en runtime)
${AUTH_TOKEN}        ${EMPTY}

*** Keywords ***
Inicializar Sesion API
    [Documentation]    Crea una sesión HTTP persistente con headers base y timeout.
    ...                Debe llamarse en Suite Setup antes de cualquier prueba.
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    Create Session
    ...    reqres_session
    ...    ${BASE_URL}
    ...    headers=${headers}
    ...    timeout=${TIMEOUT}
    Log    Sesión HTTP creada contra ${BASE_URL}    level=INFO

Obtener Token De Autenticacion
    [Documentation]    Realiza POST /api/login con las credenciales configuradas,
    ...                extrae el token de la respuesta y lo almacena en la
    ...                variable de suite ${AUTH_TOKEN}.
    ${payload}=    Create Dictionary
    ...    email=${LOGIN_EMAIL}
    ...    password=${LOGIN_PASSWORD}
    ${respuesta}=    POST On Session
    ...    reqres_session
    ...    ${LOGIN_ENDPOINT}
    ...    json=${payload}
    ...    expected_status=200
    # Extraer token del cuerpo de la respuesta
    ${token}=    Get Value From Json    ${respuesta.json()}    $.token
    ${token_valor}=    Get From List    ${token}    0
    # Almacenar en variable de suite para reutilización
    Set Suite Variable    ${AUTH_TOKEN}    ${token_valor}
    Log    Token obtenido y almacenado: ${AUTH_TOKEN}    level=INFO
    [Return]    ${token_valor}

Obtener Header Con Bearer Token
    [Documentation]    Construye y retorna un diccionario de headers que incluye
    ...                el Authorization Bearer Token. Requiere que ${AUTH_TOKEN}
    ...                haya sido inicializado previamente.
    Should Not Be Empty    ${AUTH_TOKEN}
    ...    msg=El token de autenticación está vacío. Llama primero a 'Obtener Token De Autenticacion'.
    ${auth_headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    Authorization=Bearer ${AUTH_TOKEN}
    [Return]    ${auth_headers}

Verificar Codigo De Estado
    [Documentation]    Valida que el código de estado HTTP de la respuesta
    ...                coincide con el valor esperado.
    [Arguments]    ${respuesta}    ${codigo_esperado}
    Should Be Equal As Integers
    ...    ${respuesta.status_code}
    ...    ${codigo_esperado}
    ...    msg=Código de estado inesperado. Esperado: ${codigo_esperado}, Recibido: ${respuesta.status_code}

Verificar Campo Json Existe
    [Documentation]    Verifica que un campo JSONPath existe en la respuesta.
    [Arguments]    ${respuesta}    ${jsonpath}
    ${valores}=    Get Value From Json    ${respuesta.json()}    ${jsonpath}
    Should Not Be Empty    ${valores}
    ...    msg=El campo JSONPath '${jsonpath}' no se encontró en la respuesta.
    [Return]    ${valores}

Verificar Campo Json Es Igual
    [Documentation]    Verifica que un campo JSONPath tiene el valor exacto esperado.
    [Arguments]    ${respuesta}    ${jsonpath}    ${valor_esperado}
    ${valores}=    Get Value From Json    ${respuesta.json()}    ${jsonpath}
    ${valor_actual}=    Get From List    ${valores}    0
    Should Be Equal As Strings
    ...    ${valor_actual}
    ...    ${valor_esperado}
    ...    msg=Campo '${jsonpath}': esperado '${valor_esperado}', obtenido '${valor_actual}'

Verificar Esquema Basico Usuario
    [Documentation]    Verifica que un objeto usuario contiene los campos
    ...                obligatorios del contrato de la API ReqRes.
    [Arguments]    ${respuesta}
    ${body}=    Set Variable    ${respuesta.json()}
    # Verificar existencia de campos de contrato básico
    Verificar Campo Json Existe    ${respuesta}    $.data.id
    Verificar Campo Json Existe    ${respuesta}    $.data.email
    Verificar Campo Json Existe    ${respuesta}    $.data.first_name
    Verificar Campo Json Existe    ${respuesta}    $.data.last_name
    Log    Esquema básico de usuario verificado correctamente    level=INFO

Cerrar Sesion API
    [Documentation]    Elimina la sesión HTTP al finalizar la suite.
    Delete All Sessions
    Log    Sesión HTTP cerrada    level=INFO
```

3. Guarda el archivo (`Ctrl+S` / `Cmd+S`).

#### Salida Esperada

El archivo debe guardarse sin errores de sintaxis. VS Code con RF Language Server mostrará las keywords con resaltado de sintaxis correcto.

#### Verificación

- [ ] El archivo `resources/api_keywords.robot` existe y tiene contenido.
- [ ] VS Code no muestra errores de sintaxis (líneas subrayadas en rojo) en el archivo.
- [ ] La keyword `Obtener Header Con Bearer Token` usa `${AUTH_TOKEN}` como variable de suite.

---

### Paso 3: Crear las Pruebas Smoke

**Objetivo:** Implementar 3 casos de prueba *happy path* que cubran el flujo principal de la API: autenticación, lectura y creación de recursos.

#### Instrucciones

1. Crea el archivo `tests/smoke_tests.robot`:

```robot
*** Settings ***
Documentation    Suite SMOKE — Pruebas de camino feliz para la API ReqRes.
...              Cubre autenticación, lectura y creación de recursos.
...              Ejecutar antes de la suite de regresión.
Resource         ../resources/api_keywords.robot
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections

Suite Setup      Configurar Suite Smoke
Suite Teardown   Cerrar Sesion API

*** Variables ***
${USUARIO_ID_VALIDO}     2
${USUARIO_ID_CREADO}     ${EMPTY}

*** Test Cases ***

# ─────────────────────────────────────────────────────────────────────────────
# TC-SMOKE-01: Autenticación exitosa con credenciales válidas
# ─────────────────────────────────────────────────────────────────────────────
TC-SMOKE-01 Autenticacion Exitosa Con Credenciales Validas
    [Documentation]    Verifica que el endpoint POST /api/login devuelve
    ...                código 200 y un token Bearer no vacío.
    [Tags]    smoke    autenticacion    happy-path
    ${payload}=    Create Dictionary
    ...    email=${LOGIN_EMAIL}
    ...    password=${LOGIN_PASSWORD}
    ${respuesta}=    POST On Session
    ...    reqres_session
    ...    ${LOGIN_ENDPOINT}
    ...    json=${payload}
    # Validar código de estado
    Verificar Codigo De Estado    ${respuesta}    200
    # Validar que el token existe y no está vacío
    ${token_lista}=    Verificar Campo Json Existe    ${respuesta}    $.token
    ${token}=    Get From List    ${token_lista}    0
    Should Not Be Empty    ${token}
    ...    msg=El token devuelto por /api/login está vacío.
    Log    TC-SMOKE-01 PASADO — Token recibido correctamente    level=INFO

# ─────────────────────────────────────────────────────────────────────────────
# TC-SMOKE-02: Obtener usuario existente y validar esquema JSON
# ─────────────────────────────────────────────────────────────────────────────
TC-SMOKE-02 Obtener Usuario Existente Y Validar Esquema
    [Documentation]    Verifica que GET /api/users/{id} devuelve código 200
    ...                y que la respuesta cumple el esquema básico de usuario
    ...                (id, email, first_name, last_name).
    [Tags]    smoke    get    validacion-esquema    happy-path
    ${headers}=    Obtener Header Con Bearer Token
    ${respuesta}=    GET On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}/${USUARIO_ID_VALIDO}
    ...    headers=${headers}
    # Validar código de estado
    Verificar Codigo De Estado    ${respuesta}    200
    # Validar esquema básico de contrato
    Verificar Esquema Basico Usuario    ${respuesta}
    # Validar valor específico del campo id
    Verificar Campo Json Es Igual    ${respuesta}    $.data.id    2
    # Validar que el email tiene formato válido (contiene @)
    ${email_lista}=    Verificar Campo Json Existe    ${respuesta}    $.data.email
    ${email}=    Get From List    ${email_lista}    0
    Should Contain    ${email}    @
    ...    msg=El email del usuario no tiene formato válido: ${email}
    Log    TC-SMOKE-02 PASADO — Usuario ID=${USUARIO_ID_VALIDO} validado    level=INFO

# ─────────────────────────────────────────────────────────────────────────────
# TC-SMOKE-03: Crear usuario y verificar ID generado dinámicamente
# ─────────────────────────────────────────────────────────────────────────────
TC-SMOKE-03 Crear Usuario Y Verificar ID Generado
    [Documentation]    Verifica que POST /api/users devuelve código 201,
    ...                genera un ID dinámico y retorna los datos enviados.
    ...                El ID creado se almacena para uso en pruebas subsecuentes.
    [Tags]    smoke    post    creacion    happy-path
    ${headers}=    Obtener Header Con Bearer Token
    ${payload}=    Create Dictionary
    ...    name=Ana Lopez
    ...    job=QA Engineer - Telecomunicaciones
    ${respuesta}=    POST On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}
    ...    json=${payload}
    ...    headers=${headers}
    # Validar código 201 Created
    Verificar Codigo De Estado    ${respuesta}    201
    # Validar que se generó un ID
    ${id_lista}=    Verificar Campo Json Existe    ${respuesta}    $.id
    ${id_creado}=    Get From List    ${id_lista}    0
    Should Not Be Empty    ${id_creado}
    ...    msg=El campo 'id' en la respuesta de creación está vacío.
    # Validar que los datos enviados están en la respuesta
    Verificar Campo Json Es Igual    ${respuesta}    $.name    Ana Lopez
    Verificar Campo Json Es Igual    ${respuesta}    $.job     QA Engineer - Telecomunicaciones
    # Almacenar ID para uso en otras pruebas
    Set Suite Variable    ${USUARIO_ID_CREADO}    ${id_creado}
    Log    TC-SMOKE-03 PASADO — Usuario creado con ID: ${id_creado}    level=INFO

*** Keywords ***
Configurar Suite Smoke
    [Documentation]    Setup de la suite smoke: inicializa sesión y obtiene token.
    Inicializar Sesion API
    Obtener Token De Autenticacion
    Log    Suite Smoke configurada. Token: ${AUTH_TOKEN}    level=INFO
```

2. Guarda el archivo.

3. Ejecuta **solo las pruebas smoke** para verificar que funcionan:

```bash
# Desde el directorio lab-07-00-01/
robot --outputdir results --include smoke tests/smoke_tests.robot
```

#### Salida Esperada

```
==============================================================================
Smoke Tests :: Suite SMOKE — Pruebas de camino feliz para la API ReqRes.
==============================================================================
TC-SMOKE-01 Autenticacion Exitosa Con Credenciales Validas        | PASS |
TC-SMOKE-02 Obtener Usuario Existente Y Validar Esquema           | PASS |
TC-SMOKE-03 Crear Usuario Y Verificar ID Generado                 | PASS |
==============================================================================
Smoke Tests                                                        | PASS |
3 tests, 3 passed, 0 failed
==============================================================================
```

#### Verificación

- [ ] Los 3 casos smoke pasan (`PASS`).
- [ ] El reporte HTML en `results/report.html` muestra los 3 tests en verde.
- [ ] En el log se puede ver el token obtenido y el ID generado dinámicamente.

---

### Paso 4: Crear las Pruebas de Regresión

**Objetivo:** Implementar 5 casos de prueba que cubran flujos completos (PUT, DELETE), casos límite y errores esperados (4xx), incluyendo peticiones encadenadas.

#### Instrucciones

1. Crea el archivo `tests/regression_tests.robot`:

```robot
*** Settings ***
Documentation    Suite REGRESIÓN — Pruebas de edge cases, flujos completos
...              y errores esperados para la API ReqRes.
...              Incluye cadenas POST→PUT→DELETE y validación de errores 4xx.
Resource         ../resources/api_keywords.robot
Library          RequestsLibrary
Library          JSONLibrary
Library          Collections

Suite Setup      Configurar Suite Regresion
Suite Teardown   Cerrar Sesion API

*** Variables ***
${USUARIO_ID_PARA_UPDATE}    2
${USUARIO_ID_INEXISTENTE}    9999
${PAGINA_USUARIOS}           1

*** Test Cases ***

# ─────────────────────────────────────────────────────────────────────────────
# TC-REG-01: Obtener lista paginada de usuarios y validar estructura
# ─────────────────────────────────────────────────────────────────────────────
TC-REG-01 Obtener Lista Paginada De Usuarios
    [Documentation]    Verifica que GET /api/users?page=1 devuelve código 200,
    ...                una lista de usuarios y metadatos de paginación correctos.
    [Tags]    regression    get    paginacion    lista
    ${headers}=    Obtener Header Con Bearer Token
    ${params}=    Create Dictionary    page=${PAGINA_USUARIOS}
    ${respuesta}=    GET On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}
    ...    params=${params}
    ...    headers=${headers}
    # Validar código de estado
    Verificar Codigo De Estado    ${respuesta}    200
    # Validar campos de paginación
    Verificar Campo Json Existe    ${respuesta}    $.page
    Verificar Campo Json Existe    ${respuesta}    $.total
    Verificar Campo Json Existe    ${respuesta}    $.data
    # Validar que la lista de datos no está vacía
    ${data_lista}=    Get Value From Json    ${respuesta.json()}    $.data
    ${usuarios}=    Get From List    ${data_lista}    0
    Should Not Be Empty    ${usuarios}
    ...    msg=La lista de usuarios en $.data está vacía.
    # Validar número de página
    Verificar Campo Json Es Igual    ${respuesta}    $.page    1
    Log    TC-REG-01 PASADO — Lista paginada validada correctamente    level=INFO

# ─────────────────────────────────────────────────────────────────────────────
# TC-REG-02: Actualizar usuario con PUT y verificar idempotencia
# ─────────────────────────────────────────────────────────────────────────────
TC-REG-02 Actualizar Usuario Con PUT Y Verificar Respuesta
    [Documentation]    Verifica que PUT /api/users/{id} devuelve código 200
    ...                y que los datos actualizados se reflejan en la respuesta.
    ...                PUT es idempotente: se ejecuta dos veces para verificarlo.
    [Tags]    regression    put    actualizacion    idempotencia
    ${headers}=    Obtener Header Con Bearer Token
    ${payload}=    Create Dictionary
    ...    name=Carlos Mendoza
    ...    job=Senior QA Automation - Telecomunicaciones
    # Primera ejecución
    ${respuesta_1}=    PUT On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}/${USUARIO_ID_PARA_UPDATE}
    ...    json=${payload}
    ...    headers=${headers}
    Verificar Codigo De Estado    ${respuesta_1}    200
    Verificar Campo Json Es Igual    ${respuesta_1}    $.name    Carlos Mendoza
    Verificar Campo Json Es Igual    ${respuesta_1}    $.job     Senior QA Automation - Telecomunicaciones
    # Segunda ejecución (verificar idempotencia: mismo resultado)
    ${respuesta_2}=    PUT On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}/${USUARIO_ID_PARA_UPDATE}
    ...    json=${payload}
    ...    headers=${headers}
    Verificar Codigo De Estado    ${respuesta_2}    200
    Verificar Campo Json Es Igual    ${respuesta_2}    $.name    Carlos Mendoza
    Log    TC-REG-02 PASADO — PUT idempotente verificado (2 ejecuciones)    level=INFO

# ─────────────────────────────────────────────────────────────────────────────
# TC-REG-03: Flujo encadenado POST → GET → DELETE
# ─────────────────────────────────────────────────────────────────────────────
TC-REG-03 Flujo Encadenado Crear Leer Y Eliminar Usuario
    [Documentation]    Flujo completo encadenado:
    ...                1. POST /api/users → crea usuario, extrae ID dinámico
    ...                2. GET /api/users/{id} → verifica existencia (simulada)
    ...                3. DELETE /api/users/{id} → elimina y verifica 204
    ...                Demuestra manejo de datos dinámicos entre peticiones.
    [Tags]    regression    post    delete    flujo-encadenado    datos-dinamicos
    ${headers}=    Obtener Header Con Bearer Token

    # PASO 1: Crear usuario y extraer ID dinámico
    ${payload_crear}=    Create Dictionary
    ...    name=Laura Torres
    ...    job=DevOps Engineer - Infraestructura
    ${respuesta_post}=    POST On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}
    ...    json=${payload_crear}
    ...    headers=${headers}
    Verificar Codigo De Estado    ${respuesta_post}    201
    ${id_lista}=    Get Value From Json    ${respuesta_post.json()}    $.id
    ${id_nuevo}=    Get From List    ${id_lista}    0
    Should Not Be Empty    ${id_nuevo}
    Log    Paso 1 completado — Usuario creado con ID dinámico: ${id_nuevo}    level=INFO

    # PASO 2: Verificar que el usuario existe (GET con ID conocido de ReqRes)
    # Nota: ReqRes es una API simulada; el GET usa un ID del dataset fijo.
    # Aquí verificamos el flujo de lectura con el ID válido del dataset.
    ${respuesta_get}=    GET On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}/${USUARIO_ID_PARA_UPDATE}
    ...    headers=${headers}
    Verificar Codigo De Estado    ${respuesta_get}    200
    Verificar Campo Json Existe    ${respuesta_get}    $.data.id
    Log    Paso 2 completado — Lectura de usuario verificada    level=INFO

    # PASO 3: Eliminar el usuario usando el ID dinámico del POST
    ${respuesta_delete}=    DELETE On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}/${id_nuevo}
    ...    headers=${headers}
    Verificar Codigo De Estado    ${respuesta_delete}    204
    # Verificar que el body de respuesta está vacío (correcto para 204)
    ${body_vacio}=    Set Variable    ${respuesta_delete.text}
    Should Be Empty    ${body_vacio}
    ...    msg=DELETE 204 debería retornar body vacío, pero recibió: ${body_vacio}
    Log    Paso 3 completado — Usuario ID ${id_nuevo} eliminado (204 No Content)    level=INFO
    Log    TC-REG-03 PASADO — Flujo POST→GET→DELETE completado    level=INFO

# ─────────────────────────────────────────────────────────────────────────────
# TC-REG-04: Error esperado — Login con credenciales inválidas (400)
# ─────────────────────────────────────────────────────────────────────────────
TC-REG-04 Login Con Credenciales Invalidas Debe Retornar Error
    [Documentation]    Verifica que POST /api/login con contraseña ausente
    ...                devuelve código 400 Bad Request y un mensaje de error
    ...                en el campo 'error' del body de respuesta.
    [Tags]    regression    autenticacion    error-esperado    400
    ${payload_invalido}=    Create Dictionary
    ...    email=usuario.invalido@reqres.in
    # Contraseña intencionalmente omitida para provocar error 400
    ${respuesta}=    POST On Session
    ...    reqres_session
    ...    ${LOGIN_ENDPOINT}
    ...    json=${payload_invalido}
    ...    expected_status=400
    # Validar código de error
    Verificar Codigo De Estado    ${respuesta}    400
    # Validar que el body contiene campo 'error'
    Verificar Campo Json Existe    ${respuesta}    $.error
    ${error_lista}=    Get Value From Json    ${respuesta.json()}    $.error
    ${mensaje_error}=    Get From List    ${error_lista}    0
    Should Not Be Empty    ${mensaje_error}
    ...    msg=El campo 'error' en la respuesta 400 está vacío.
    Log    TC-REG-04 PASADO — Error 400 recibido con mensaje: ${mensaje_error}    level=INFO

# ─────────────────────────────────────────────────────────────────────────────
# TC-REG-05: Error esperado — Obtener usuario inexistente (404)
# ─────────────────────────────────────────────────────────────────────────────
TC-REG-05 Obtener Usuario Inexistente Debe Retornar 404
    [Documentation]    Verifica que GET /api/users/{id_inexistente} con un ID
    ...                que no existe en el sistema devuelve código 404 Not Found
    ...                y un body vacío (comportamiento estándar de ReqRes).
    [Tags]    regression    get    error-esperado    404    not-found
    ${headers}=    Obtener Header Con Bearer Token
    ${respuesta}=    GET On Session
    ...    reqres_session
    ...    ${USERS_ENDPOINT}/${USUARIO_ID_INEXISTENTE}
    ...    headers=${headers}
    ...    expected_status=404
    # Validar código 404
    Verificar Codigo De Estado    ${respuesta}    404
    # ReqRes devuelve body vacío {} para 404
    ${body}=    Set Variable    ${respuesta.json()}
    ${keys}=    Get Dictionary Keys    ${body}
    Should Be Empty    ${keys}
    ...    msg=Se esperaba body vacío para 404, pero se recibió: ${body}
    Log    TC-REG-05 PASADO — 404 recibido para usuario inexistente ID=${USUARIO_ID_INEXISTENTE}    level=INFO

*** Keywords ***
Configurar Suite Regresion
    [Documentation]    Setup de la suite de regresión: inicializa sesión y obtiene token.
    Inicializar Sesion API
    Obtener Token De Autenticacion
    Log    Suite Regresión configurada. Token: ${AUTH_TOKEN}    level=INFO
```

2. Guarda el archivo.

3. Ejecuta las pruebas de regresión:

```bash
robot --outputdir results --include regression tests/regression_tests.robot
```

#### Salida Esperada

```
==============================================================================
Regression Tests :: Suite REGRESIÓN — Pruebas de edge cases, flujos...
==============================================================================
TC-REG-01 Obtener Lista Paginada De Usuarios                      | PASS |
TC-REG-02 Actualizar Usuario Con PUT Y Verificar Respuesta        | PASS |
TC-REG-03 Flujo Encadenado Crear Leer Y Eliminar Usuario          | PASS |
TC-REG-04 Login Con Credenciales Invalidas Debe Retornar Error    | PASS |
TC-REG-05 Obtener Usuario Inexistente Debe Retornar 404           | PASS |
==============================================================================
Regression Tests                                                   | PASS |
5 tests, 5 passed, 0 failed
==============================================================================
```

#### Verificación

- [ ] Los 5 casos de regresión pasan (`PASS`).
- [ ] TC-REG-03 muestra en el log el ID dinámico generado por el POST.
- [ ] TC-REG-04 y TC-REG-05 pasan aunque el servidor devuelve códigos de error (4xx), gracias al uso de `expected_status`.

---

### Paso 5: Ejecución Completa de la Suite con Reporting

**Objetivo:** Ejecutar ambas suites en conjunto, generar reportes combinados y verificar la organización por tags.

#### Instrucciones

1. **Ejecutar toda la suite completa:**

```bash
# Desde el directorio lab-07-00-01/
robot --outputdir results \
      --report report_completo.html \
      --log log_completo.html \
      --title "Suite API ReqRes - Lab 07-00-01" \
      tests/
```

2. **Ejecutar solo pruebas por tag específico:**

```bash
# Solo pruebas de autenticación
robot --outputdir results/por-tag --include autenticacion tests/

# Solo pruebas de error esperado
robot --outputdir results/por-tag --include error-esperado tests/

# Solo smoke tests
robot --outputdir results/por-tag --include smoke tests/
```

3. **Verificar el reporte HTML:**

```bash
# Windows
start results\report_completo.html

# macOS
open results/report_completo.html

# Linux
xdg-open results/report_completo.html
```

4. **Combinar resultados de múltiples ejecuciones (opcional avanzado):**

```bash
rebot --outputdir results \
      --output output_combinado.xml \
      --report report_combinado.html \
      --title "Reporte Combinado API" \
      results/output.xml
```

#### Salida Esperada

Al abrir `results/report_completo.html` deberías ver:

- **8 tests totales** (3 smoke + 5 regresión), todos en verde.
- Sección de **Statistics by Tag** mostrando: `smoke (3)`, `regression (5)`, `autenticacion (2)`, `happy-path (3)`, `error-esperado (2)`, etc.
- Tiempos de ejecución por test case.
- Log detallado con los tokens y IDs dinámicos capturados.

#### Verificación

- [ ] El archivo `results/report_completo.html` existe y se abre en el navegador.
- [ ] La sección "Statistics by Tag" muestra los tags correctamente distribuidos.
- [ ] Los 8 tests aparecen como `PASS` en el resumen.
- [ ] La ejecución filtrada por tag `--include smoke` ejecuta exactamente 3 tests.

---

## Validación y Pruebas

### Lista de Verificación Final

Ejecuta los siguientes comandos de validación y confirma cada punto:

```bash
# 1. Verificar estructura de archivos del proyecto
find lab-07-00-01/ -type f -name "*.robot" 2>/dev/null || \
  dir /s /b lab-07-00-01\*.robot

# 2. Ejecutar suite completa y verificar 0 fallos
robot --outputdir results tests/
echo "Exit code: $?"   # Debe ser 0 (todos pasaron)

# 3. Verificar que el tag 'smoke' ejecuta exactamente 3 tests
robot --dryrun --include smoke tests/

# 4. Verificar que el tag 'regression' ejecuta exactamente 5 tests
robot --dryrun --include regression tests/
```

### Criterios de Aceptación del Laboratorio

| Criterio                                                        | Estado |
|-----------------------------------------------------------------|--------|
| `resources/api_keywords.robot` contiene todas las keywords base | ☐      |
| `tests/smoke_tests.robot` tiene exactamente 3 test cases        | ☐      |
| `tests/regression_tests.robot` tiene exactamente 5 test cases   | ☐      |
| Todos los tests pasan en ejecución completa (8/8)               | ☐      |
| La keyword `Obtener Token De Autenticacion` usa `Set Suite Variable` | ☐ |
| TC-REG-03 demuestra encadenamiento con ID dinámico              | ☐      |
| TC-REG-04 y TC-REG-05 validan correctamente errores 4xx         | ☐      |
| El reporte HTML muestra estadísticas por tag                    | ☐      |

---

## Solución de Problemas

### Problema 1: `RequestsLibrary` lanza `ConnectionError` o `SSLError` al ejecutar las pruebas

**Síntomas:**
```
RequestsLibrary.RequestsError: HTTPSConnectionPool(host='reqres.in', port=443):
Max retries exceeded with url: /api/login
```
O bien el test falla con `SSLError: CERTIFICATE_VERIFY_FAILED`.

**Causa:**
La conexión a `reqres.in` está siendo bloqueada por un firewall corporativo, proxy de red, VPN activa, o la verificación SSL del sistema operativo falla por certificados desactualizados (común en Windows con Python recién instalado).

**Solución:**

Primero, verifica conectividad básica:
```bash
curl -I https://reqres.in/api/users
```

Si el problema es el proxy corporativo, configura las variables de entorno:
```bash
# Windows (cmd)
set HTTPS_PROXY=http://proxy.empresa.com:8080
set HTTP_PROXY=http://proxy.empresa.com:8080

# macOS / Linux
export HTTPS_PROXY=http://proxy.empresa.com:8080
export HTTP_PROXY=http://proxy.empresa.com:8080
```

Si el problema es SSL en Windows, actualiza los certificados:
```bash
pip install --upgrade certifi
python -c "import certifi; print(certifi.where())"
```

Como solución temporal para entornos de laboratorio (no usar en producción), puedes deshabilitar la verificación SSL modificando `Create Session` en `api_keywords.robot`:
```robot
Create Session
...    reqres_session
...    ${BASE_URL}
...    headers=${headers}
...    timeout=${TIMEOUT}
...    verify=False
```

---

### Problema 2: `Get Value From Json` retorna lista vacía o lanza `KeyError` con la expresión JSONPath

**Síntomas:**
```
JSONLibrary.JSONLibraryException: JSONPath expression "$.data.id" did not match any element
```
O bien `Should Not Be Empty` falla indicando que la lista de valores está vacía.

**Causa:**
Hay dos causas frecuentes: (a) la expresión JSONPath no coincide con la estructura real del JSON devuelto por la API (por ejemplo, la respuesta tiene `data` como lista en vez de objeto), o (b) la versión de `robotframework-jsonlibrary` instalada usa una sintaxis JSONPath ligeramente diferente.

**Solución:**

Primero, inspecciona el JSON real de la respuesta agregando un `Log` antes del `Get Value From Json`:
```robot
${body}=    Set Variable    ${respuesta.json()}
Log    Estructura de respuesta: ${body}    level=WARN
```

Ejecuta el test con `--loglevel DEBUG` para ver el JSON completo:
```bash
robot --loglevel DEBUG --outputdir results tests/smoke_tests.robot
```

Verifica la versión de JSONLibrary y su sintaxis soportada:
```bash
pip show robotframework-jsonlibrary
python -c "from JSONLibrary import JSONLibrary; help(JSONLibrary.get_value_from_json)"
```

Si la respuesta tiene `data` como lista (por ejemplo en `/api/users?page=1`), ajusta el JSONPath:
```robot
# Para objeto único: GET /api/users/2
$.data.id          # ✓ correcto

# Para lista: GET /api/users?page=1
$.data[0].id       # ✓ primer elemento de la lista
$.data[*].id       # ✓ todos los IDs de la lista
```

Reinstala JSONLibrary si persisten problemas de compatibilidad:
```bash
pip uninstall robotframework-jsonlibrary
pip install robotframework-jsonlibrary==0.5
```

---

## Limpieza

Una vez completado el laboratorio, realiza las siguientes acciones de limpieza:

### 1. Archivar Resultados

```bash
# Crear archivo comprimido con los resultados del laboratorio
# Windows (PowerShell)
Compress-Archive -Path results\* -DestinationPath resultados-lab-07-00-01.zip

# macOS / Linux
zip -r resultados-lab-07-00-01.zip results/
```

### 2. Limpiar Archivos Temporales de Robot Framework

```bash
# Los archivos de salida XML pueden ser grandes; conserva solo los HTML
# Windows
del results\output.xml
del results\por-tag\output.xml 2>nul

# macOS / Linux
rm -f results/output.xml
rm -f results/por-tag/output.xml
```

### 3. Desactivar el Entorno Virtual

```bash
# Todos los sistemas operativos
deactivate
```

### 4. Verificar Copia de Respaldo del Proyecto

```bash
# Crea una copia de respaldo del proyecto completo antes de continuar
# Windows (PowerShell)
Copy-Item -Recurse lab-07-00-01 lab-07-00-01-backup

# macOS / Linux
cp -r lab-07-00-01 lab-07-00-01-backup
```

> 📌 **Nota:** Los laboratorios posteriores del módulo pueden requerir los archivos de `resources/api_keywords.robot` creados en este laboratorio. Mantén la copia de respaldo.

---

## Resumen

En este laboratorio construiste una suite profesional de pruebas API REST con Robot Framework que cubre el ciclo completo de interacción con una API real:

| Concepto Practicado                        | Implementación Realizada                                          |
|--------------------------------------------|-------------------------------------------------------------------|
| Sesión HTTP persistente                    | `Create Session` con headers base y timeout en `api_keywords.robot` |
| Autenticación Bearer Token                 | `POST /api/login` → extracción con JSONPath → `Set Suite Variable` |
| Keyword `Obtener Header Con Bearer Token`  | Construye headers `Authorization: Bearer` reutilizables           |
| Validación de código de estado             | `Should Be Equal As Integers` con mensaje descriptivo             |
| Validación JSON con JSONPath               | `Get Value From Json` para campos `$.data.id`, `$.token`, etc.    |
| Contract testing básico                    | Keyword `Verificar Esquema Basico Usuario` con campos obligatorios |
| Datos dinámicos encadenados                | POST → extracción de ID → DELETE en TC-REG-03                     |
| Validación de errores esperados (4xx)      | `expected_status=400/404` en TC-REG-04 y TC-REG-05                |
| Organización por tags                      | `smoke`, `regression`, `happy-path`, `error-esperado`             |
| Separación en archivos                     | `smoke_tests.robot` (3 casos) + `regression_tests.robot` (5 casos) |

### Conceptos Clave Consolidados

- **Los métodos HTTP tienen semántica precisa:** GET recupera (idempotente), POST crea (no idempotente), PUT reemplaza (idempotente), DELETE elimina (idempotente). TC-REG-02 demostró la idempotencia de PUT ejecutándolo dos veces.
- **El código de estado es la primera validación:** siempre verifica el status antes de inspeccionar el body. Los tests 4xx son tan válidos como los 2xx.
- **`Set Suite Variable` permite compartir estado entre tests:** el token Bearer obtenido en el Setup está disponible en todos los test cases de la suite sin repetir el login.
- **JSONPath simplifica la extracción de datos:** expresiones como `$.data.id` o `$.token` son más robustas que acceder al diccionario por índice.
- **La separación smoke/regresión es una práctica estándar:** permite ejecutar verificaciones rápidas de salud (`--include smoke`) antes de la suite completa.

### Recursos Adicionales

- [Documentación oficial de RequestsLibrary](https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html)
- [Documentación de JSONLibrary para Robot Framework](https://robotframework-jsonlibrary.readthedocs.io/)
- [ReqRes API — Documentación de endpoints disponibles](https://reqres.in/)
- [JSONPath Online Evaluator — Para probar expresiones JSONPath](https://jsonpath.com/)
- [RFC 9110 — Semántica HTTP (métodos y códigos de estado)](https://www.rfc-editor.org/rfc/rfc9110)
- [MDN Web Docs — Códigos de estado HTTP en español](https://developer.mozilla.org/es/docs/Web/HTTP/Status)

---

---

