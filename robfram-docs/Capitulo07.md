# Capítulo 7 — Automatización de APIs con RequestsLibrary

## Información general

Las APIs REST son hoy el medio de comunicación predominante entre sistemas, y probarlas directamente (sin pasar por una interfaz web) es más rápido y más estable que la automatización de UI. Este capítulo cubre `RequestsLibrary`, la librería estándar de comunidad para pruebas de API en Robot Framework, con ejemplos de código completos basados en peticiones HTTP reales.

**Lecciones de este capítulo:**

- 7.1 — REST/HTTP: métodos, códigos de estado, headers y payloads
- 7.2 — Autenticación: Bearer tokens, sesiones persistentes y datos dinámicos
- 7.3 — Validación JSON: sintaxis extendida, aserciones de esquema y contract testing básico
- 7.4 — Diseño de suites API: estructura smoke vs. regresión y organización por endpoint

---

## 7.1 REST/HTTP: métodos, códigos de estado, headers y payloads

### Objetivos de la lección

- Describir los métodos HTTP principales y su semántica.
- Interpretar los rangos de códigos de estado HTTP.
- Identificar el rol de headers y payload en una petición.

### ¿Por qué importa?

Probar una API sin entender la semántica de HTTP lleva a tests que validan el código de estado correcto por casualidad, no por diseño — y a no saber qué método usar cuando el escenario de negocio no especifica explícitamente "haz un GET" o "haz un POST".

### Conceptos clave

#### Métodos HTTP y su semántica

REST organiza los recursos de un sistema como URLs, operadas con verbos HTTP estándar:

| Método | Semántica | ¿Tiene efectos secundarios? | ¿Es idempotente? |
|---|---|---|---|
| `GET` | Leer un recurso | No | Sí (repetirlo no cambia el resultado) |
| `POST` | Crear un recurso nuevo | Sí | No (repetirlo crea otro recurso) |
| `PUT` | Reemplazar un recurso completo | Sí | Sí (repetirlo deja el mismo estado) |
| `DELETE` | Eliminar un recurso | Sí | Sí (eliminar dos veces el mismo recurso da el mismo resultado final) |

La **idempotencia** es un concepto que aparece en preguntas de certificación: una operación idempotente produce el mismo resultado final sin importar cuántas veces se repita — `GET` y `PUT` son idempotentes, `POST` no lo es (cada llamada exitosa crea un recurso adicional).

#### Códigos de estado: los rangos que importan

Cada respuesta incluye un **código de estado** de tres dígitos, agrupado en rangos con significado:

| Rango | Significado | Ejemplo común |
|---|---|---|
| `2xx` | Éxito | `200 OK`, `201 Created` |
| `4xx` | Error causado por el cliente | `400 Bad Request`, `401 Unauthorized`, `404 Not Found` |
| `5xx` | Error del servidor | `500 Internal Server Error`, `503 Service Unavailable` |

Distinguir `4xx` de `5xx` importa para el diagnóstico: un `4xx` indica que la petición estaba mal formada o no autorizada (responsabilidad del cliente, en este caso de tu test); un `5xx` indica que el servidor falló al procesar una petición válida (responsabilidad del sistema bajo prueba).

#### Headers y payload

Los **headers** llevan metadatos de la petición o respuesta: `Content-Type` indica el formato del cuerpo (`application/json` es el más común en APIs modernas), `Authorization` lleva las credenciales (lección 7.2). El **payload** (cuerpo de la petición) en `POST`/`PUT` típicamente es JSON — un objeto estructurado que el servidor espera en un formato específico.

### Ejemplo comentado

```robot
*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    api    https://postman-echo.com    verify=True


*** Test Cases ***
Demostrar Los Cuatro Métodos HTTP Principales
    # GET: leer, sin efectos secundarios
    ${respuesta_get}=    GET On Session    api    /get
    Should Be Equal As Numbers    ${respuesta_get.status_code}    200

    # POST: crear, con payload JSON
    &{payload}=    Create Dictionary    cliente=Ana Pérez
    ${respuesta_post}=    POST On Session    api    /post    json=${payload}
    Should Be Equal As Numbers    ${respuesta_post.status_code}    200
    Should Be Equal    ${respuesta_post.json()}[json][cliente]    Ana Pérez
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué rango de código indica error del servidor? | `5xx` |
| ¿Qué método es idempotente pero tiene efectos secundarios? | `PUT` |
| ¿Qué método NO es idempotente? | `POST` |
| ¿Qué header indica el formato del cuerpo de la petición? | `Content-Type` |

### Errores comunes

- **Asumir que `POST` es idempotente** — cada llamada exitosa típicamente crea un nuevo recurso; repetir la misma petición POST puede crear duplicados.
- **Confundir un `4xx` con un `5xx`** al diagnosticar un fallo — el primero apunta a la petición (posiblemente un error en el test), el segundo apunta al servidor.
- **Omitir `Content-Type` al enviar un payload manualmente** (sin usar el parámetro `json=` que lo configura automáticamente) — el servidor puede interpretar el cuerpo incorrectamente.

### Autoevaluación

1. ¿Es `GET` idempotente? ¿Y `POST`?
2. ¿Qué rango de código HTTP indica un error causado por el cliente?
3. ¿Qué header configura automáticamente `RequestsLibrary` cuando usas el parámetro `json=`?

**Respuestas:** 1. `GET` sí es idempotente; `POST` no lo es. 2. `4xx`. 3. `Content-Type: application/json`.

---

## 7.2 Autenticación: Bearer tokens, sesiones persistentes y datos dinámicos

### Objetivos de la lección

- Explicar el patrón de autenticación Bearer.
- Usar sesiones persistentes para evitar repetir configuración en cada petición.
- Encadenar datos dinámicos entre peticiones.

### ¿Por qué importa?

Casi ninguna API de producción es completamente abierta — entender cómo se transmite la autenticación, y cómo mantener una sesión configurada una sola vez para toda la suite, es indispensable para cualquier suite de API realista.

### Conceptos clave

#### El esquema Bearer Token

El esquema **Bearer Token** (basado en RFC 6750, parte del estándar OAuth 2.0) transmite la credencial en el header `Authorization: Bearer <token>` — quien "porta" (*bears*) el token tiene acceso, sin necesidad de reenviar usuario/contraseña en cada petición. `RequestsLibrary` lo implementa simplemente agregando ese header a la petición; **no hay una keyword especial** de "login Bearer" — es responsabilidad del proyecto construir ese header correctamente, típicamente con `Create Dictionary` y pasándolo como `headers=`.

```robot
&{headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
${respuesta}=    GET On Session    api    /recurso-protegido    headers=&{headers}
```

#### Create Session: sesiones HTTP persistentes

`Create Session` crea una sesión HTTP **persistente**: conserva headers, cookies y configuración TLS entre peticiones dentro de la misma suite, evitando repetir la URL base y configuración en cada llamada.

```robot
Suite Setup    Create Session    api    https://api.miempresa.com    verify=True
```

Una vez creada, cualquier `GET On Session`/`POST On Session` que referencie el alias `api` reutiliza esa configuración — incluyendo, si se configuró así, headers de autenticación que aplican a **todas** las peticiones de la sesión, sin tener que repetirlos en cada llamada individual.

#### Encadenar datos dinámicos entre peticiones

Una sesión persistente también permite **encadenar datos dinámicos** entre peticiones — por ejemplo, un `id` devuelto por un `POST` (creación de un recurso) reutilizado en el `GET` posterior que lo consulta:

```robot
*** Test Cases ***
Crear Un Recurso Y Luego Consultarlo Por Su ID Generado
    &{payload}=    Create Dictionary    nombre=Plan Premium
    ${respuesta_creacion}=    POST On Session    api    /planes    json=${payload}
    ${id_generado}=    Set Variable    ${respuesta_creacion.json()}[id]

    ${respuesta_consulta}=    GET On Session    api    /planes/${id_generado}
    Should Be Equal As Numbers    ${respuesta_consulta.status_code}    200
```

Este patrón es exactamente el que necesitarás en la Sesión 8 (RPA), donde un proceso completo encadena varias llamadas API usando el resultado de una como entrada de la siguiente.

### Ejemplo comentado

```robot
*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    api    https://postman-echo.com    verify=True


*** Variables ***
${TOKEN_DEMO}    token-demo-12345


*** Test Cases ***
Autenticar Con Bearer Token Y Validar Que El Servidor Lo Recibió
    [Documentation]    postman-echo.com/headers refleja en la respuesta
    ...                todos los headers recibidos — incluido Authorization
    ...                — ideal para validar el patrón Bearer sin depender
    ...                de un servicio de autenticación real.
    &{headers}=    Create Dictionary    Authorization=Bearer ${TOKEN_DEMO}
    ${respuesta}=    GET On Session    api    /headers    headers=&{headers}
    Should Be Equal As Numbers    ${respuesta.status_code}    200
    Should Be Equal    ${respuesta.json()}[headers][authorization]    Bearer ${TOKEN_DEMO}
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿En qué header se transmite el Bearer Token? | `Authorization`, con el formato `Bearer <token>` |
| ¿Qué keyword crea una sesión persistente? | `Create Session` |
| ¿Qué permite encadenar entre un POST y un GET posterior? | Una variable que captura el dato dinámico (ej. un `id`) de la respuesta del POST |
| ¿RFC en el que se basa Bearer Token? | RFC 6750 |

### Errores comunes

- **Repetir `Create Session` en cada test case** en vez de usarla una sola vez en `Suite Setup` — pierde el beneficio de persistencia y configuración compartida.
- **Olvidar `verify=True` al crear la sesión** — genera advertencias de seguridad y, en proyectos reales, deja sin verificar el certificado TLS del servidor.
- **No capturar el `id` generado por un POST en una variable**, y en su lugar intentar adivinarlo o hardcodearlo — frágil, porque el `id` real puede cambiar entre ejecuciones.

### Autoevaluación

1. ¿En qué formato exacto se transmite un Bearer Token en el header `Authorization`?
2. ¿Qué keyword evita repetir la URL base y configuración en cada petición de una suite?
3. ¿Cómo encadenarías el `id` generado por un `POST` para usarlo en un `GET` posterior?

**Respuestas:** 1. `Authorization: Bearer <token>`. 2. `Create Session`, usada típicamente en `Suite Setup`. 3. Capturando `${respuesta.json()}[id]` en una variable después del POST, y usándola en la URL del GET siguiente.

---

## 7.3 Validación JSON: sintaxis extendida, aserciones de esquema y contract testing básico

### Objetivos de la lección

- Validar valores específicos dentro de una respuesta JSON.
- Describir el concepto de contract testing.
- Diferenciar validación de valor de validación de estructura.

### ¿Por qué importa?

Validar solo el código de estado (`200 OK`) de una respuesta no garantiza que el contenido sea correcto — un servidor puede responder `200` con un cuerpo vacío o con datos incorrectos. La validación real de una API necesita mirar dentro del cuerpo de la respuesta.

### Conceptos clave

#### Acceso a valores anidados con sintaxis extendida

Una vez que tienes la respuesta como diccionario Python (`respuesta.json()`), Robot Framework permite acceder a cualquier valor anidado con la **sintaxis extendida** `${respuesta.json()}[clave][subclave]` — suficiente para la mayoría de las validaciones de una suite de pruebas, sin necesitar ninguna librería adicional:

```robot
${respuesta}=    GET On Session    api    /clientes/123
Should Be Equal    ${respuesta.json()}[nombre]    Ana Pérez
Should Be Equal    ${respuesta.json()}[direccion][ciudad]    Guatemala
```

#### JSONPath para consultas más complejas

Para estructuras muy complejas (listas dentro de listas, búsqueda condicional dentro de un arreglo) o consultas dinámicas, existe `JSONLibrary` (instalada con `pip install robotframework-jsonlibrary`), con soporte de **JSONPath** — un lenguaje de consulta para JSON, análogo a XPath para XML. Para el alcance práctico de este curso, la sintaxis extendida de Robot Framework cubre la gran mayoría de los casos; JSONPath se vuelve valioso cuando necesitas filtrar dentro de listas grandes (`$.items[?(@.precio > 100)]`).

#### Validación de valor vs. validación de estructura

Estas son dos preguntas distintas que conviene no confundir:

- **Validación de valor**: "¿el campo `estado` es exactamente `'ACTIVO'`?" — lo que has hecho hasta ahora con `Should Be Equal`.
- **Validación de estructura**: "¿la respuesta tiene un campo `estado` de tipo string, y un campo `id` de tipo número, sin campos inesperados?" — independiente de cuál sea el valor específico.

#### Contract testing

El **contract testing** valida que la *estructura* de una respuesta (qué campos existen, de qué tipo) se mantiene estable entre versiones de una API — detectando cambios incompatibles (un campo que desaparece, un tipo que cambia de string a número) antes de que lleguen a producción y rompan a los sistemas que consumen esa API. Es un complemento, no un reemplazo, de las validaciones de valor específico: una API puede pasar todas las validaciones de valor de hoy y, sin embargo, romper silenciosamente a un cliente si cambia su estructura sin que nadie lo detecte a tiempo.

### Ejemplo comentado

```robot
*** Test Cases ***
Validar Valor Específico Dentro De Una Respuesta JSON
    ${respuesta}=    GET On Session    api    /clientes/123
    Should Be Equal As Numbers    ${respuesta.status_code}    200
    Should Be Equal    ${respuesta.json()}[nombre]    Ana Pérez
    Should Be Equal    ${respuesta.json()}[plan][nombre]    Premium

Validar Que Un Campo Esperado Existe (Estructura, No Valor)
    [Documentation]    Validación de contrato básica: el campo debe existir,
    ...                independientemente de cuál sea su valor exacto hoy.
    ${respuesta}=    GET On Session    api    /clientes/123
    Dictionary Should Contain Key    ${respuesta.json()}    fecha_alta
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué sintaxis accede a un valor anidado sin librerías adicionales? | `${respuesta.json()}[clave][subclave]` |
| ¿Qué librería agrega soporte de JSONPath? | `JSONLibrary` |
| ¿Qué valida el contract testing? | La estructura de la respuesta, no solo valores puntuales |
| ¿Es lo mismo validar un valor que validar una estructura? | No, son dos preguntas distintas y complementarias |

### Errores comunes

- **Validar solo el código de estado y asumir que el contenido es correcto** — un `200 OK` no garantiza que el cuerpo tenga los datos esperados.
- **Instalar `JSONLibrary` para casos simples** que la sintaxis extendida de Robot Framework ya resuelve — agrega una dependencia innecesaria.
- **Confundir contract testing con validación de valor** — son complementarios, no intercambiables; un proyecto serio necesita ambos tipos de validación.

### Autoevaluación

1. ¿Qué sintaxis usarías para acceder al campo `ciudad` dentro de `direccion` dentro de la respuesta JSON?
2. ¿Qué detecta el contract testing que una validación de valor específico no detecta necesariamente?
3. ¿Cuándo conviene usar JSONLibrary/JSONPath en vez de la sintaxis extendida de Robot Framework?

**Respuestas:** 1. `${respuesta.json()}[direccion][ciudad]`. 2. Cambios de estructura (un campo que desaparece o cambia de tipo) que rompen a los consumidores de la API. 3. Para consultas complejas o condicionales dentro de listas grandes, donde la sintaxis extendida se vuelve impráctica.

---

## 7.4 Diseño de suites API: estructura smoke vs. regresión y organización por endpoint

### Objetivos de la lección

- Diferenciar una suite smoke de una suite de regresión.
- Aplicar `expected_status` para probar deliberadamente respuestas de error.
- Organizar una suite de API por endpoint.

### ¿Por qué importa?

Sin esta distinción, un equipo termina ejecutando la suite completa de API en cada commit (lento, costoso) o, en el otro extremo, evita ejecutar la suite completa con la frecuencia que debería (cobertura insuficiente antes de un release).

### Conceptos clave

#### Smoke vs. regresión

Una suite **smoke** agrupa pocos casos críticos, pensados para ejecutarse en **cada** despliegue, completándose en segundos o pocos minutos — su objetivo es detectar rápidamente si algo básico se rompió (el servicio no responde, la autenticación falla por completo). Una suite de **regresión** cubre exhaustivamente comportamientos, casos límite y escenarios negativos, reservada para ejecutarse antes de un release, donde el tiempo de ejecución es menos crítico que la cobertura.

| | Suite smoke | Suite de regresión |
|---|---|---|
| Cantidad de casos | Pocos, los más críticos | Muchos, cobertura exhaustiva |
| Frecuencia de ejecución | Cada despliegue/commit | Antes de un release |
| Tiempo objetivo | Segundos a pocos minutos | Minutos a horas, según el proyecto |
| Incluye casos negativos extensos | Rara vez | Sí, sistemáticamente |

#### `expected_status=any`: pruebas negativas sin interrupciones

Por defecto, `RequestsLibrary` lanza una excepción ante cualquier respuesta `4xx`/`5xx` — apropiado cuando siempre esperas éxito, pero un obstáculo cuando **el objetivo del test es justamente validar un error esperado** (por ejemplo, que un endpoint rechace correctamente datos inválidos con un `400`). El parámetro `expected_status=any` desactiva esa excepción automática, dejando el código de estado disponible para que el test lo compare explícitamente:

```robot
${respuesta}=    GET On Session    api    /status/404    expected_status=any
Should Be Equal As Numbers    ${respuesta.status_code}    404
```

Sin `expected_status=any`, esta línea lanzaría una excepción al recibir el `404`, deteniendo el test antes de que el `Should Be Equal As Numbers` pudiera ejecutarse — exactamente lo opuesto de lo que el test necesita validar.

#### Organización por endpoint

Para proyectos con muchos endpoints, organizar la suite **por recurso** (un archivo por endpoint o grupo de endpoints relacionados) facilita la navegación:

```
tests/
├── smoke/
│   └── salud_servicio.robot
└── regression/
    ├── clientes/
    │   └── crud_clientes.robot
    └── planes/
        └── crud_planes.robot
```

### Ejemplo comentado

```robot
*** Settings ***
Library           RequestsLibrary
Library           DataDriver    ${CURDIR}/../data/casos_api.csv    dialect=excel    encoding=utf_8
Suite Setup       Create Session    api    https://postman-echo.com    verify=True
Test Template     Verificar Status Code Del Endpoint


*** Test Cases ***
Caso De Ejemplo De API


*** Keywords ***
Verificar Status Code Del Endpoint
    [Documentation]    expected_status=any evita que RequestsLibrary lance
    ...                una excepción automática ante un 4xx/5xx — así
    ...                podemos validar casos negativos sin que el GET
    ...                "falle" antes de llegar al assert.
    [Arguments]    ${endpoint}    ${status_esperado}
    ${respuesta}=    GET On Session    api    ${endpoint}    expected_status=any
    Should Be Equal As Numbers    ${respuesta.status_code}    ${status_esperado}
```

```csv
*** Test Cases ***,${endpoint},${status_esperado},[Tags]
Servicio responde correctamente (200),/status/200,200,"smoke,positivo"
Endpoint inexistente devuelve 404,/status/404,404,"regresion,negativo"
Error interno del servidor devuelve 500,/status/500,500,"regresion,negativo"
```

Combinando DataDriver (Capítulo 5) con esta suite, un solo archivo CSV cubre casos positivos y negativos de forma escalable, sin un test case por cada código de estado.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué tipo de suite se ejecuta en cada despliegue? | Smoke |
| ¿Qué parámetro evita la excepción automática ante un 4xx/5xx? | `expected_status=any` |
| ¿Qué suite tiene mayor cobertura de casos negativos? | Regresión |

### Errores comunes

- **Ejecutar la suite de regresión completa en cada commit** — consume tiempo de pipeline innecesario; reserva eso para antes de un release.
- **Olvidar `expected_status=any` al probar deliberadamente un error** — el test falla con una excepción no controlada antes de llegar a la validación real que querías hacer.
- **No tener ninguna suite smoke**, ejecutando siempre todo o nada — pierde la posibilidad de una verificación rápida tras cada despliegue.

### Puntos clave

- Suite smoke: pocos casos críticos, cada despliegue, rápida. Suite regresión: cobertura completa, antes de release.
- `expected_status=any` es necesario para probar deliberadamente respuestas `4xx`/`5xx`.
- Organizar por endpoint (un archivo por recurso de la API) facilita la navegación en suites grandes.

### Autoevaluación

1. ¿Qué tipo de suite (smoke o regresión) ejecutarías inmediatamente después de cada despliegue a producción?
2. Sin `expected_status=any`, ¿qué pasa al hacer un GET a un endpoint que devuelve 404?
3. ¿Cómo organizarías una suite de API con 20 endpoints distintos?

**Respuestas:** 1. Smoke. 2. `RequestsLibrary` lanza una excepción automática, deteniendo el test antes de cualquier validación explícita. 3. Por endpoint o grupo de endpoints relacionados, en archivos separados dentro de carpetas `smoke/` y `regression/`.

---

## Resumen del capítulo

REST organiza recursos como URLs operadas con verbos HTTP (con semántica e idempotencia distintas para cada uno); los códigos de estado comunican éxito o tipo de error. El patrón Bearer Token transmite la credencial en un header, y `Create Session` mantiene configuración persistente entre peticiones, habilitando el encadenamiento de datos dinámicos entre un POST y un GET posterior. La sintaxis extendida de Robot Framework valida JSON sin librerías adicionales para la mayoría de los casos; el contract testing complementa la validación de valores con la validación de estructura. Las suites de API se organizan en smoke (rápida, crítica, cada despliegue) y regresión (completa, antes de release), y `expected_status=any` habilita pruebas negativas deliberadas sin que `RequestsLibrary` interrumpa la ejecución con una excepción automática.

## Referencias bibliográficas

- RequestsLibrary: <https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html>
- RFC 6750 (Bearer Token Usage): <https://datatracker.ietf.org/doc/html/rfc6750>
- postman-echo.com (servicio de eco para pruebas): <https://learning.postman.com/docs/reference/developer-resources/echo-api/>

```{=typst}
#pagebreak()
```
