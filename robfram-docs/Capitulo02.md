# Capítulo 2 — Sintaxis y Diseño de Suites de Prueba

## Información general

Este capítulo profundiza en la sintaxis que sostiene cualquier suite de prueba seria: cómo se relacionan test cases, keywords y librerías; los tres tipos de variables y su precedencia; cómo separar keywords en archivos reutilizables; y cómo organizar una suite grande con tags y Setup/Teardown. Cada lección incluye ejemplos de código completos — no solo reglas de sintaxis aisladas.

**Lecciones de este capítulo:**

- 2.1 — Test cases, keywords y bibliotecas: BuiltIn, Collections, OperatingSystem
- 2.2 — Variables: escalares, listas y diccionarios
- 2.3 — Archivos Resource: separación de keywords y parametrización de datos
- 2.4 — Tags, Setup/Teardown y organización jerárquica de suites

---

## 2.1 Test cases, keywords y bibliotecas: BuiltIn, Collections, OperatingSystem

### Objetivos de la lección

- Describir la relación entre test case, keyword y biblioteca.
- Diferenciar las responsabilidades de `BuiltIn`, `Collections` y `OperatingSystem`.
- Aplicar keywords de las tres bibliotecas en una sola suite.

### ¿Por qué importa?

Cuando una suite crece más allá de unos pocos test cases, la diferencia entre "qué se prueba" y "cómo se hace" deja de ser una sutileza estilística y se convierte en la diferencia entre una suite mantenible y una que nadie quiere tocar. Entender esta jerarquía desde el principio evita que termines con test cases de 40 líneas que mezclan negocio y detalles técnicos.

### Conceptos clave

#### La jerarquía de tres niveles

En Robot Framework, **test case**, **keyword** y **biblioteca** forman una jerarquía de tres niveles, cada uno con un nivel de abstracción distinto:

- Un **test case** es una unidad de prueba con nombre, legible por cualquier persona del equipo (incluso sin conocimientos técnicos) — describe **el qué**.
- Una **keyword** es una acción reutilizable invocada desde uno o más test cases — el "verbo" de la prueba, describe **el cómo**, a un nivel todavía legible.
- Una **biblioteca** es el contenedor que agrupa keywords relacionadas y las expone al motor de ejecución — es el "proveedor" de las keywords.

Esta jerarquía existe para que un test case **describa el qué**, no **el cómo**: leer `Iniciar Sesión Como Administrador` te dice la intención sin obligarte a leer la implementación (que puede vivir en una keyword propia, posiblemente en varias líneas de Selenium o de llamadas API).

#### BuiltIn: la biblioteca que siempre está ahí

`BuiltIn` es la única biblioteca que no requiere una línea `Library` — sus keywords están disponibles sin que el autor de la suite tenga que pensar en importarlas. Categorías principales: aserciones (`Should Be *`), conversión de tipos (`Convert To Integer`, `Convert To String`), control de flujo (`Run Keyword If`, ya vista parcialmente), y logging (`Log`, `Log To Console`).

#### Collections: operar sobre listas y diccionarios

`Collections` agrega keywords para trabajar con las dos estructuras de datos compuestas de Robot Framework: listas y diccionarios. Las más usadas: `Create List`, `Create Dictionary`, `Append To List`, `Get From Dictionary`, `Should Contain` (también funciona sobre listas), `Dictionary Should Contain Key`. Sin esta biblioteca, modelar datos compuestos en una suite sería mucho más limitado.

#### OperatingSystem: el puente hacia el sistema de archivos

`OperatingSystem` expone keywords para interactuar con archivos, carpetas y variables de entorno del sistema operativo donde corre la suite: `File Should Exist`, `Create Directory`, `Get File`, `Remove File`, `Get Environment Variable`. Es la biblioteca que usarás constantemente en procesos RPA (Capítulo 8), donde leer/escribir archivos es una operación central.

#### Tabla comparativa de las tres bibliotecas

| Biblioteca | Importación | Propósito | Keywords representativas |
|---|---|---|---|
| `BuiltIn` | Automática, siempre disponible | Aserciones, logging, conversiones, control de flujo | `Should Be Equal`, `Log`, `Convert To Integer` |
| `Collections` | `Library Collections` | Listas y diccionarios | `Create Dictionary`, `Append To List` |
| `OperatingSystem` | `Library OperatingSystem` | Archivos, carpetas, entorno | `File Should Exist`, `Get Environment Variable` |

### Ejemplo comentado

```robot
*** Settings ***
Library    Collections
Library    OperatingSystem


*** Test Cases ***
Registrar Un Nuevo Cliente Y Verificar Su Archivo De Respaldo
    [Documentation]    Combina las tres bibliotecas: BuiltIn (implícita)
    ...                para aserciones, Collections para modelar el
    ...                cliente, OperatingSystem para el archivo.

    # Collections: modela el cliente como diccionario
    ${cliente}=    Create Dictionary    nombre=Ana Pérez    plan=Premium

    # BuiltIn: aserción directa sobre el diccionario
    Should Be Equal    ${cliente}[plan]    Premium

    # OperatingSystem: verifica que existe un archivo de respaldo
    File Should Exist    ${CURDIR}/respaldo_clientes.csv

    # BuiltIn: logging del resultado
    Log    Cliente ${cliente}[nombre] registrado con plan ${cliente}[plan]
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué representa "el qué" en la jerarquía de RF? | El test case |
| ¿Qué biblioteca expone `Create Dictionary`? | `Collections` |
| ¿Qué biblioteca expone `File Should Exist`? | `OperatingSystem` |
| ¿Necesita `Library Collections` en Settings? | Sí, no es automática como `BuiltIn` |

### Errores comunes

- **Poner lógica de negocio compleja directamente en el test case** en vez de extraerla a una keyword propia — el test case deja de ser legible para alguien no técnico.
- **Olvidar `Library Collections`** al usar `Create Dictionary` por primera vez, asumiendo que es tan automática como `BuiltIn`.
- **Usar `OperatingSystem.Get File` para archivos binarios** (como imágenes o PDFs) — esa keyword está pensada para texto; archivos binarios requieren un manejo distinto (por ejemplo, desde una librería Python propia, como verás en el Capítulo 5).

### Puntos clave

- Test case = qué verificar; keyword = cómo hacerlo; biblioteca = quién provee la keyword.
- `BuiltIn` se carga automáticamente; el resto de bibliotecas requiere `Library <nombre>`.
- `Collections` trabaja con listas/diccionarios; `OperatingSystem`, con el sistema de archivos.

### Autoevaluación

1. ¿Qué biblioteca necesitas declarar para usar `Append To List`?
2. ¿Por qué un test case no debería contener lógica de negocio extensa directamente?
3. Verdadero o falso: `OperatingSystem.Get File` es apropiada para leer archivos PDF.

**Respuestas:** 1. `Collections`. 2. Porque deja de ser legible para alguien no técnico — esa lógica debería vivir en una keyword propia. 3. Falso — esa keyword está pensada para texto, no para binarios.

---

## 2.2 Variables: escalares, listas y diccionarios

### Objetivos de la lección

- Diferenciar los tres tipos de variables de Robot Framework.
- Elegir el tipo correcto según el dato que se necesita modelar.
- Explicar la precedencia entre variables definidas en distintos lugares.

### ¿Por qué importa?

Las variables son el mecanismo central para parametrizar una suite — evitan repetir el mismo valor en distintos lugares y permiten cambiar configuración (URLs, credenciales, datos de prueba) sin tocar la lógica. Elegir el tipo equivocado (por ejemplo, una lista cuando necesitabas un diccionario) genera código artificialmente complicado más adelante.

### Conceptos clave

#### Variables escalares: el tipo más común

Una variable escalar (`${var}`) almacena un único valor — texto, número, booleano, o incluso un objeto Python completo (como una lista o un diccionario, si así se asignó). Es el tipo más común porque, incluso cuando el valor *es* una lista, puedes referenciarlo como escalar si no necesitas iterarlo elemento por elemento en ese punto del código.

#### Variables de lista: expansión posicional

Una variable de lista (`@{lista}`) almacena varios valores en orden. La diferencia clave está en el **prefijo usado al referenciarla**: con `@{lista}`, Robot Framework expande sus elementos como argumentos posicionales separados (útil al pasarla a una keyword que espera varios argumentos); con `${lista}`, se trata como un solo objeto de tipo lista de Python (útil para pasarla completa a una keyword que espera un solo argumento de tipo lista, como muchas de `Collections`).

#### Variables de diccionario: pares clave-valor

Una variable de diccionario (`&{dict}`) almacena pares clave-valor — el equivalente a `**kwargs` en Python. Se accede a un valor específico con `${dict}[clave]` (nota el prefijo `${...}`, no `&{...}`, al acceder a un valor individual — un detalle de sintaxis que confunde a muchos al empezar).

#### Tabla comparativa de los tres tipos

```{=typst}
#comparacion(
  titulo-a: "${escalar} y @{lista}",
  items-a: ("${escalar}: un único valor", "@{lista}: varios valores en orden", "@{...} expande como argumentos posicionales"),
  titulo-b: "&{dict}",
  items-b: ("Pares clave-valor", "Se accede con ${dict}[clave]", "Equivalente a **kwargs de Python"),
)
```

| Tipo | Sintaxis de declaración | Sintaxis de acceso a un valor | Caso de uso típico |
|---|---|---|---|
| Escalar | `${URL}    https://api.com` | `${URL}` | Un valor de configuración |
| Lista | `@{NUMEROS}    1    2    3` | `${NUMEROS}[0]` (índice) o `@{NUMEROS}` (expandida) | Varios valores relacionados |
| Diccionario | `&{CLIENTE}    nombre=Ana    plan=Premium` | `${CLIENTE}[nombre]` | Datos con nombre de campo |

#### Precedencia: qué variable "gana" cuando hay varias con el mismo nombre

Cuando una variable tiene el mismo nombre en distintos lugares, la precedencia (de más específico a más general) es: **argumento de línea de comandos** (`--variable NOMBRE:valor`) > **variable definida dentro del test case o keyword en ejecución** > **variable de la sección `*** Variables ***`** de la suite que se está ejecutando > **variable importada desde un Resource**. Este orden tiene una lógica: lo más cercano al punto de ejecución (CLI, luego el propio test) siempre puede sobrescribir lo más general (configuración compartida en un Resource).

### Ejemplo comentado

```robot
*** Settings ***
Resource    ../resources/configuracion.resource


*** Variables ***
# Esta variable de suite tiene precedencia sobre la del Resource importado,
# pero será sobrescrita si se pasa --variable BASE_URL:... por CLI.
${BASE_URL}        https://staging.miempresa.com

@{ENDPOINTS}       /clientes    /planes    /facturas

&{CREDENCIALES}    usuario=admin    clave=Admin123!


*** Test Cases ***
Demostrar Los Tres Tipos De Variables En Un Solo Test
    Log    URL base: ${BASE_URL}

    # @{...} expande como argumentos posicionales
    FOR    ${endpoint}    IN    @{ENDPOINTS}
        Log    Endpoint disponible: ${endpoint}
    END

    # Acceso a un valor del diccionario con ${...}, no &{...}
    Should Be Equal    ${CREDENCIALES}[usuario]    admin
```

```bash
# El valor de CLI tiene la máxima precedencia: sobrescribe el de Variables
robot --variable BASE_URL:https://produccion.miempresa.com tests/suite.robot
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué prefijo expande una lista como argumentos posicionales? | `@{...}` |
| ¿Cómo se accede a un valor de un diccionario? | `${dict}[clave]` (con `${...}`, no `&{...}`) |
| ¿Qué tiene mayor precedencia, `--variable` de CLI o `*** Variables ***`? | `--variable` de CLI |

### Errores comunes

- **Usar `&{dict}` para acceder a un valor individual** en vez de `${dict}[clave]` — `&{...}` es solo para declarar o expandir el diccionario completo como kwargs, no para leer un campo.
- **Asumir que una variable de Resource siempre "gana"** sobre la de la suite — es exactamente al revés: la variable de la suite que importa el Resource tiene precedencia.
- **Mezclar tipos sin necesidad** — modelar un cliente con varias variables escalares sueltas (`${CLIENTE_NOMBRE}`, `${CLIENTE_PLAN}`) cuando un solo diccionario (`&{CLIENTE}`) sería más claro y escalable.

### Puntos clave

- `${var}` para un solo valor; `@{lista}` para varios; `&{dict}` para pares clave-valor.
- El prefijo usado al referenciar una variable determina cómo se expande (escalar vs. lista/dict completo vs. acceso a un elemento).
- La precedencia de variables va de más específico (CLI) a más general (Resource importado).

### Autoevaluación

1. ¿Qué tipo de variable usarías para modelar un cliente con nombre, plan y fecha de alta?
2. ¿Cómo se accede al primer elemento de una variable de lista `@{NUMEROS}`?
3. Si defines `${BASE_URL}` en la suite y también en un Resource importado, ¿cuál gana?
4. ¿Qué tiene mayor precedencia que ambas?

**Respuestas:** 1. Un diccionario (`&{CLIENTE}`). 2. `${NUMEROS}[0]`. 3. La definida en la suite (más específica que el Resource). 4. Un valor pasado por `--variable` en la línea de comandos.

---

## 2.3 Archivos Resource: separación de keywords y parametrización de datos

### Objetivos de la lección

- Explicar el propósito de un archivo Resource.
- Diferenciar qué secciones puede contener un Resource frente a una suite.
- Aplicar la importación de un Resource desde una suite.

### ¿Por qué importa?

A medida que una suite de pruebas crece, mantener todas las keywords, variables y configuraciones en un solo archivo `.robot` se vuelve difícil de sostener: corregir un bug en una keyword usada por 10 test cases significa encontrarla entre cientos de líneas. Un archivo Resource resuelve esto formalmente, no como una convención informal.

### Conceptos clave

#### Qué es y qué no es un archivo Resource

Un **archivo Resource** (extensión `.resource`, o también `.robot` aunque no es la convención recomendada) centraliza keywords y variables que **cualquier suite puede importar**. La diferencia formal con una suite: un Resource **no puede contener** la sección `*** Test Cases ***` (ni `*** Tasks ***`) — solo `Settings`, `Variables` y `Keywords`. Esta restricción no es arbitraria: comunica una intención clara — "este archivo no ejecuta nada por sí mismo, solo provee".

| Tipo de archivo | `Test Cases`/`Tasks` | `Keywords`/`Variables` | Se ejecuta directamente con `robot` |
|---|---|---|---|
| Suite (`.robot` con tests) | Sí | Sí | Sí |
| Resource (`.resource`) | **No** | Sí | No (se importa) |

#### Cómo se importa y qué queda disponible

Un Resource se importa en una suite con la línea `Resource    <ruta>` en `*** Settings ***`. A partir de ahí, **todas** las keywords y variables definidas en el Resource quedan disponibles en la suite, como si estuvieran escritas ahí mismo — no hay un mecanismo de "importación selectiva" (como el `from x import y` de Python); se importa el archivo completo.

#### Los Resources también pueden importar Resources

Un archivo Resource puede, a su vez, importar otros Resources en su propia sección `*** Settings ***` — permitiendo construir una jerarquía de capas (por ejemplo, un Resource de "keywords técnicas de API" importado por un Resource de "keywords de dominio de facturación", que a su vez es importado por la suite de pruebas). Esta composición es la base del patrón de capas que formalizarás en el Capítulo 4 (BDD) y el Capítulo 6 (Page Object).

#### Los tres beneficios concretos

1. **Reutilización**: la misma keyword sirve para varias suites, sin copiar y pegar código.
2. **Mantenibilidad**: corregir un bug en una keyword lo corrige automáticamente en todos los lugares que la usan — un solo punto de cambio.
3. **Legibilidad**: el archivo `.robot` de la suite queda enfocado en *qué* se prueba, sin mezclar *cómo* se hace internamente.

### Ejemplo comentado

```robot
# archivo: resources/clientes_keywords.resource
*** Settings ***
Documentation     Keywords reutilizables para gestión de clientes de telecom.
Library           Collections


*** Variables ***
${PLAN_BASICO}      Básico
${PLAN_PREMIUM}     Premium


*** Keywords ***
Crear Cliente
    [Documentation]    Crea un diccionario que representa un cliente.
    [Arguments]    ${nombre}    ${plan}
    ${cliente}=    Create Dictionary    nombre=${nombre}    plan=${plan}
    RETURN    ${cliente}

Validar Plan Asignado
    [Arguments]    ${cliente}    ${plan_esperado}
    Should Be Equal    ${cliente}[plan]    ${plan_esperado}
```

```robot
# archivo: tests/gestion_clientes.robot
*** Settings ***
Documentation     Suite que importa keywords desde un archivo Resource.
Resource          ../resources/clientes_keywords.resource


*** Test Cases ***
Crear Cliente Con Plan Básico
    # ${PLAN_BASICO} viene del Resource — esta suite NUNCA lo declaró.
    ${cliente}=    Crear Cliente    Ana Pérez    ${PLAN_BASICO}
    Validar Plan Asignado    ${cliente}    ${PLAN_BASICO}
```

Observa que **ni `Crear Cliente` ni `${PLAN_BASICO}` están definidas en la suite** — vienen del Resource importado. Eso es justamente lo que se gana al separar capas: la suite es más corta y describe solo el escenario de prueba.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué sección NO puede tener un archivo Resource? | `Test Cases` (ni `Tasks`) |
| ¿Cómo se importa un Resource en una suite? | `Resource    <ruta>` en `Settings` |
| ¿Puede un Resource importar otro Resource? | Sí |
| ¿Se puede importar solo una keyword específica de un Resource? | No, se importa el archivo completo |

### Errores comunes

- **Intentar agregar `*** Test Cases ***` a un archivo `.resource`** — Robot Framework lo rechaza; si necesitas tests, ese archivo debe ser una suite, no un Resource.
- **Duplicar una keyword en varios Resources** en vez de centralizarla en uno solo e importarlo donde se necesite — recrea el problema que el patrón Resource busca resolver.
- **Rutas relativas incorrectas al importar** — la ruta en `Resource <ruta>` es relativa a la ubicación del archivo que la declara, no al directorio desde donde ejecutas `robot`.

### Puntos clave

- Un Resource centraliza keywords/variables reutilizables; no contiene `Test Cases`/`Tasks`.
- Se importa con `Resource    <ruta>` en `Settings`, completo (no selectivo).
- Los Resources pueden importar otros Resources, habilitando arquitecturas en capas.

### Autoevaluación

1. ¿Qué pasa si intentas agregar `*** Test Cases ***` a un archivo `.resource`?
2. ¿Puedes importar solo la keyword `Crear Cliente` de un Resource que tiene 10 keywords, sin las otras 9?
3. ¿Puede un archivo Resource importar a otro Resource?

**Respuestas:** 1. Robot Framework lo rechaza — un Resource no puede tener esa sección. 2. No, la importación de un Resource siempre es completa. 3. Sí, habilitando jerarquías de capas.

---

## 2.4 Tags, Setup/Teardown y organización jerárquica de suites

### Objetivos de la lección

- Explicar el propósito de los tags y cómo filtran la ejecución.
- Describir los cuatro niveles de Setup/Teardown.
- Aplicar organización jerárquica con `__init__.robot`.

### ¿Por qué importa?

Cuando un proyecto de automatización crece a cientos de test cases, ejecutar siempre la suite completa deja de ser práctico — necesitas poder ejecutar "solo lo crítico" o "solo lo de facturación". Y cuando varias suites comparten el mismo estado inicial (por ejemplo, todas necesitan una sesión de base de datos abierta), repetir esa configuración en cada test case es frágil y costoso de mantener.

### Conceptos clave

#### Tags: clasificación y filtrado

Los **tags** son etiquetas de texto libre asignadas a un test case con `[Tags]`, o a toda la suite con `Test Tags` en `Settings` (heredado por todos los test cases de esa suite). Desde la línea de comandos, `--include TAG` ejecuta solo los tests con ese tag, y `--exclude TAG` los omite. Un esquema típico combina varias dimensiones en los mismos test cases: prioridad (`smoke`, `regresion`), dominio (`facturacion`, `clientes`) y ambiente (`staging`, `produccion`) — un mismo test puede llevar varios tags simultáneamente.

#### Los cuatro niveles de Setup/Teardown

| Nivel | ¿Cuándo se ejecuta? | ¿Se ejecuta si el paso anterior falla? |
|---|---|---|
| `Suite Setup` | Una vez, antes del primer test de la suite | N/A (es el primero) |
| `Test Setup` | Antes de cada test case | Sí, salvo que `Suite Setup` haya fallado |
| `Test Teardown` | Después de cada test case | **Sí, incluso si el test falló** |
| `Suite Teardown` | Una vez, después del último test | **Sí, incluso si algún test falló** |

El comportamiento más importante de recordar: **`Teardown` se ejecuta siempre**, sin importar el resultado del paso que protege — es el lugar correcto para liberar recursos (cerrar un navegador, una conexión de base de datos, borrar archivos temporales). Depender de que el test pase para hacer la limpieza es un error de diseño que deja recursos abiertos cuando algo falla — justo cuando más necesitas que el entorno quede limpio para el siguiente intento.

#### Organización jerárquica con directorios

Para proyectos grandes, Robot Framework permite que una suite sea, en vez de un único archivo, **un directorio completo**, donde cada subcarpeta es una "sub-suite" anidada. Un archivo especial `__init__.robot` dentro de un directorio define el `Setup`/`Teardown` que aplica a **todas** las suites de esa carpeta — útil para configuración compartida (por ejemplo, abrir una conexión de base de datos una sola vez para todos los tests de un módulo, en vez de repetirlo en cada archivo).

```
tests/
├── __init__.robot              # Setup/Teardown para TODO el proyecto
├── clientes/
│   ├── __init__.robot          # Setup/Teardown solo para este módulo
│   ├── alta_cliente.robot
│   └── baja_cliente.robot
└── facturacion/
    ├── __init__.robot
    └── generar_factura.robot
```

### Ejemplo comentado

```robot
*** Settings ***
Documentation     Suite con tags y los cuatro niveles de Setup/Teardown.
Suite Setup       Log    Iniciando suite de regresión de clientes
Suite Teardown    Log    Finalizando suite de regresión de clientes
Test Setup        Log    Preparando datos para el siguiente test
Test Teardown     Log    Limpieza posterior al test


*** Test Cases ***
Cliente Premium Tiene Soporte Prioritario
    [Tags]    regresion    premium
    Should Be True    ${True}

Sistema De Gestión De Clientes Responde
    [Tags]    smoke
    Should Be True    ${True}
```

```bash
# Solo los tests marcados como smoke (rápido, para cada despliegue)
robot --include smoke tests/suite.robot

# Todo lo de regresión EXCEPTO lo marcado como básico
robot --include regresion --exclude basico tests/suite.robot
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué nivel de Setup/Teardown se ejecuta una sola vez por suite? | `Suite Setup`/`Suite Teardown` |
| ¿Se ejecuta `Test Teardown` si el test falló? | Sí, siempre |
| ¿Qué archivo define Setup/Teardown para todas las suites de un directorio? | `__init__.robot` |
| ¿Qué hace `--exclude TAG`? | Omite los tests que tienen ese tag |

### Errores comunes

- **Poner lógica de limpieza crítica en el cuerpo del test en vez de en `Teardown`** — si el test falla antes de llegar a esa línea, la limpieza nunca ocurre.
- **Asumir que `Suite Teardown` no se ejecuta si un test falló** — sí se ejecuta, siempre, igual que `Test Teardown`.
- **Usar tags inconsistentes** (`Smoke` en un test, `smoke` en otro) — aunque Robot Framework normaliza algunos aspectos, mantener una convención de escritura consistente evita confusión en el esquema de tags del equipo.

### Puntos clave

- `[Tags]` clasifica un test case; `Test Tags` en Settings aplica a toda la suite; `--include`/`--exclude` filtran la ejecución.
- `Suite Setup/Teardown`: una vez por suite. `Test Setup/Teardown`: una vez por test, siempre — incluso ante fallo.
- Un directorio con `__init__.robot` actúa como una suite jerárquica con Setup/Teardown compartido.

### Autoevaluación

1. Si un test falla a mitad de ejecución, ¿se ejecuta su `Test Teardown`?
2. ¿Qué comando ejecuta solo los tests con el tag `smoke`, excluyendo los que también tengan `wip`?
3. ¿Qué archivo especial define configuración compartida para todas las suites de un directorio?

**Respuestas:** 1. Sí, siempre se ejecuta, sin importar el resultado del test. 2. `robot --include smoke --exclude wip tests/`. 3. `__init__.robot`.

---

## Resumen del capítulo

Los test cases describen el qué; las keywords describen el cómo; las bibliotecas (`BuiltIn`, `Collections`, `OperatingSystem`) proveen el vocabulario técnico. Las variables tienen tres formas — escalar, lista, diccionario — según cuántos valores necesitan modelar, con una precedencia clara entre CLI, test/keyword, suite y Resource. Los archivos Resource separan keywords reutilizables del archivo de la suite, sin poder contener `Test Cases`/`Tasks`, y pueden componerse en jerarquías. Los tags filtran qué se ejecuta, y Setup/Teardown prepara y limpia el entorno en cuatro niveles posibles, con `Teardown` garantizado incluso ante fallo.

## Referencias bibliográficas

- Resource files: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#resource-files>
- Librería Collections: <https://robotframework.org/robotframework/latest/libraries/Collections.html>
- Setups y Teardowns: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#setups-and-teardowns>

```{=typst}
#pagebreak()
```
