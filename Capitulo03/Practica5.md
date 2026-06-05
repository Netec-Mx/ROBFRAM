# Práctica 5: Tests con lógica condicional y bucles de datos

## Metadatos

| Campo            | Detalle                                      |
|------------------|----------------------------------------------|
| **Duración**     | 72 minutos                                   |
| **Complejidad**  | Media                                        |
| **Nivel Bloom**  | Aplicar (Apply)                              |
| **Módulo**       | 3 — Control de flujo avanzado                |
| **Versión RF**   | Robot Framework 7.x                          |

---

## Descripción General

En este laboratorio construirás una suite de pruebas que simula la validación de un catálogo de planes de telecomunicaciones para la empresa ficticia **TelecomRF S.A.** Aplicarás bloques `IF / ELSE IF / ELSE` nativos de Robot Framework para clasificar planes según su precio, bucles `FOR` para iterar sobre una lista de clientes y validar su estado de cuenta, y un bucle `WHILE` para simular reintentos de conexión con límite máximo de intentos. Todas las keywords estarán documentadas con `[Documentation]` y usarán aserciones de la librería `BuiltIn` para garantizar resultados esperados.

---

## Objetivos de Aprendizaje

Al completar este laboratorio, serás capaz de:

- [ ] Implementar bloques `IF / ELSE IF / ELSE` dentro de keywords y test cases para ejecutar lógica condicional basada en valores de variables
- [ ] Utilizar bucles `FOR` sobre listas y rangos, y bucles `WHILE` con condición de parada para iterar sobre conjuntos de datos de prueba
- [ ] Aplicar keywords de aserción de la librería `BuiltIn` (`Should Be Equal As Numbers`, `Should Match Regexp`, `Should Contain`) para validar resultados esperados
- [ ] Combinar estructuras de control anidadas para simular flujos de validación de datos representativos de procesos de telecomunicaciones
- [ ] Documentar keywords con `[Documentation]` y `[Arguments]` siguiendo buenas prácticas de mantenibilidad

---

## Prerrequisitos

### Conocimiento previo

- Haber completado los laboratorios **02-00-01** y **02-00-02** del Módulo 2
- Comprensión de variables escalares `${var}`, listas `@{lista}` y diccionarios `&{dicc}` en Robot Framework
- Conocimiento básico de estructuras de control (if/for/while) en cualquier lenguaje de programación
- Familiaridad con la librería `BuiltIn` y keywords de aserción básicas

### Acceso y herramientas

- Entorno virtual Python activo con Robot Framework 7.x instalado
- Visual Studio Code con la extensión **Robot Framework Language Server** instalada
- Terminal (cmd/PowerShell en Windows; bash/zsh en macOS/Linux)
- Proyecto base del Módulo 2 disponible como referencia (no se modifica)

---

## Entorno de Laboratorio

### Tabla de software requerido

| Componente                    | Versión mínima | Propósito                              |
|-------------------------------|----------------|----------------------------------------|
| Python                        | 3.10           | Intérprete base                        |
| Robot Framework               | 7.x            | Framework de automatización            |
| robotframework-collections    | incluida en RF  | Librería Collections para listas/dicts |
| VS Code                       | 1.85           | Editor principal                       |
| RF Language Server (extensión)| 1.12           | Soporte de sintaxis y autocompletado   |

### Configuración del entorno

Sigue los pasos a continuación **antes** de comenzar el laboratorio. Los comandos se presentan con variantes para Windows y Unix.

**Paso A — Activar el entorno virtual existente:**

```bash
# Windows (cmd)
cd C:\proyectos\telecomrf
venv\Scripts\activate

# Windows (PowerShell)
cd C:\proyectos\telecomrf
.\venv\Scripts\Activate.ps1

# macOS / Linux
cd ~/proyectos/telecomrf
source venv/bin/activate
```

**Paso B — Verificar la versión de Robot Framework:**

```bash
robot --version
# Salida esperada: Robot Framework 7.x.x (Python 3.x.x ...)
```

**Paso C — Verificar que la librería Collections está disponible:**

```bash
python -c "import robot.libraries.Collections; print('Collections OK')"
# Salida esperada: Collections OK
```

**Paso D — Crear la estructura de directorios para este laboratorio:**

```bash
# Windows (cmd / PowerShell)
mkdir labs\lab_03_00_01
mkdir labs\lab_03_00_01\resources
mkdir labs\lab_03_00_01\results

# macOS / Linux
mkdir -p labs/lab_03_00_01/resources
mkdir -p labs/lab_03_00_01/results
```

Al finalizar, la estructura del proyecto debe verse así:

```
telecomrf/
├── venv/
├── labs/
│   ├── lab_02_00_01/          ← laboratorio anterior (no modificar)
│   └── lab_03_00_01/
│       ├── resources/
│       │   └── telecom_data.resource   ← crearemos este archivo
│       ├── results/                    ← carpeta para reportes
│       └── suite_control_flujo.robot   ← suite principal
```

---

## Instrucciones Paso a Paso

---

### Paso 1 — Crear el archivo de datos y recursos compartidos

**Objetivo:** Definir las variables de datos (planes, clientes) que serán consumidas por los bucles y condiciones de la suite, y centralizar keywords de utilidad en un archivo Resource.

#### Instrucciones

1. Abre VS Code y navega a la carpeta `labs/lab_03_00_01/resources/`.

2. Crea el archivo `telecom_data.resource` con el siguiente contenido:

```robotframework
*** Settings ***
Library    Collections

*** Variables ***
# ---------------------------------------------------------------------------
# Catálogo de planes de telecomunicaciones (precio en USD/mes)
# Clasificación esperada:
#   básico    → precio < 20
#   estándar  → precio >= 20 y < 50
#   premium   → precio >= 50
# ---------------------------------------------------------------------------
@{PLANES}
...    Plan Básico 10|10.00|básico
...    Plan Básico 15|15.99|básico
...    Plan Estándar 30|30.00|estándar
...    Plan Estándar 45|45.50|estándar
...    Plan Premium 60|60.00|premium
...    Plan Premium 99|99.99|premium

# ---------------------------------------------------------------------------
# Lista de clientes con formato: nombre|telefono|estado_cuenta|saldo_usd
# Estados válidos: activo, suspendido, moroso
# ---------------------------------------------------------------------------
@{CLIENTES}
...    Ana Torres|+52-555-123-4567|activo|0.00
...    Carlos Ruiz|+52-555-987-6543|moroso|150.75
...    María López|+52-555-456-7890|activo|0.00
...    Jorge Pérez|+52-555-321-0987|suspendido|0.00
...    Laura Gómez|+52-555-654-3210|moroso|89.50

# ---------------------------------------------------------------------------
# Parámetros de simulación de reintentos de conexión
# ---------------------------------------------------------------------------
${MAX_REINTENTOS}    5
${INTERVALO_REINTENTO_SEG}    0
${PATRON_TELEFONO}    ^\\+\\d{2}-\\d{3}-\\d{3}-\\d{4}$

*** Keywords ***
Separar Campos De Cadena
    [Documentation]    Divide una cadena con separador "|" y devuelve una lista de campos.
    ...                Argumento: cadena_datos — string con campos separados por "|"
    ...                Retorna: lista de strings con cada campo
    [Arguments]    ${cadena_datos}
    ${campos}=    Split String    ${cadena_datos}    |
    RETURN    ${campos}

Obtener Campo
    [Documentation]    Extrae un campo específico de una lista por índice.
    ...                Argumentos: lista_campos — lista de strings; indice — entero 0-based
    [Arguments]    ${lista_campos}    ${indice}
    ${valor}=    Get From List    ${lista_campos}    ${indice}
    RETURN    ${valor}
```

3. Guarda el archivo (`Ctrl+S` / `Cmd+S`).

#### Salida esperada

VS Code no debe mostrar errores de sintaxis en el archivo. El Language Server subrayará en verde las keywords definidas en `*** Keywords ***`.

#### Verificación

```bash
# Verifica que el archivo existe y tiene contenido
# Windows
type labs\lab_03_00_01\resources\telecom_data.resource

# macOS / Linux
cat labs/lab_03_00_01/resources/telecom_data.resource
```

La salida debe mostrar el contenido del archivo sin errores.

---

### Paso 2 — Crear la suite principal e importar recursos

**Objetivo:** Establecer la estructura base de la suite con la sección `*** Settings ***` correctamente configurada y crear los primeros test cases vacíos como andamiaje.

#### Instrucciones

1. En la carpeta `labs/lab_03_00_01/`, crea el archivo `suite_control_flujo.robot`.

2. Escribe la sección de configuración inicial:

```robotframework
*** Settings ***
Documentation    Suite de pruebas: Validación de catálogo de planes y clientes
...              Empresa ficticia: TelecomRF S.A.
...              Módulo 3 — Laboratorio 03-00-01
...              Cubre: IF/ELSE IF/ELSE, FOR, WHILE, aserciones BuiltIn
Resource         resources/telecom_data.resource
Library          Collections
Library          String

*** Variables ***
# Variable de control para el bucle WHILE de reintentos
${CONEXION_EXITOSA}    ${FALSE}

*** Test Cases ***
TC-01 Clasificar Planes Por Precio
    [Documentation]    Itera sobre el catálogo de planes e invoca la keyword
    ...                de clasificación para cada uno. Verifica que la categoría
    ...                calculada coincide con la categoría esperada en los datos.
    [Tags]    clasificacion    condicional
    Clasificar Todos Los Planes

TC-02 Validar Estado De Cuenta De Clientes
    [Documentation]    Itera sobre la lista de clientes y valida su estado de cuenta.
    ...                Clientes morosos deben tener saldo > 0; activos y suspendidos
    ...                deben tener saldo = 0.
    [Tags]    clientes    bucle-for
    Validar Todos Los Clientes

TC-03 Simular Reintentos De Conexion
    [Documentation]    Ejecuta un bucle WHILE que simula intentos de conexión.
    ...                El bucle se detiene cuando la conexión es exitosa o se
    ...                alcanza el límite máximo de reintentos.
    [Tags]    conexion    bucle-while
    ${intentos_realizados}=    Simular Conexion Con Reintentos    ${MAX_REINTENTOS}
    Should Be True    ${intentos_realizados} <= ${MAX_REINTENTOS}
    ...    El número de intentos no debe superar el máximo configurado

TC-04 Validar Formato De Telefonos
    [Documentation]    Itera sobre los clientes y valida que el número de teléfono
    ...                cumple el patrón internacional: +XX-XXX-XXX-XXXX
    [Tags]    telefonos    regexp
    Validar Formato Telefonos De Clientes

TC-05 Flujo Integrado Clasificacion Y Validacion
    [Documentation]    Test integrador que combina clasificación de planes y
    ...                validación de clientes en un único flujo con lógica
    ...                condicional anidada.
    [Tags]    integrado    avanzado
    Ejecutar Validacion Integrada

*** Keywords ***
```

3. Guarda el archivo.

#### Salida esperada

El Language Server de VS Code debe reconocer los test cases y no mostrar errores de importación (el archivo resource debe resolverse correctamente).

#### Verificación

En la terminal, ejecuta un dry-run para verificar que la suite se parsea sin errores:

```bash
# Desde la raíz del proyecto (con venv activo)
robot --dryrun --outputdir labs/lab_03_00_01/results labs/lab_03_00_01/suite_control_flujo.robot
```

> **Nota:** El dry-run fallará porque las keywords referenciadas aún no están implementadas. Lo importante es que el error sea `No keyword with name '...' found` y **no** un error de sintaxis o importación.

---

### Paso 3 — Implementar la keyword de clasificación de planes (IF / ELSE IF / ELSE)

**Objetivo:** Crear la keyword `Clasificar Plan Por Precio` que usa un bloque `IF / ELSE IF / ELSE` para asignar una categoría según el precio, y la keyword `Clasificar Todos Los Planes` que la invoca desde un bucle `FOR`.

#### Instrucciones

1. En la sección `*** Keywords ***` del archivo `suite_control_flujo.robot`, agrega las siguientes keywords:

```robotframework
Clasificar Plan Por Precio
    [Documentation]    Clasifica un plan de telecomunicaciones según su precio mensual.
    ...                Reglas de clasificación:
    ...                  - básico    → precio < 20.00 USD
    ...                  - estándar  → precio >= 20.00 y < 50.00 USD
    ...                  - premium   → precio >= 50.00 USD
    ...                Argumentos:
    ...                  nombre_plan     — nombre descriptivo del plan
    ...                  precio          — precio mensual como número (float o int)
    ...                  categoria_esp   — categoría esperada para validación
    [Arguments]    ${nombre_plan}    ${precio}    ${categoria_esp}
    # Convertir precio a número flotante para comparaciones numéricas
    ${precio_num}=    Convert To Number    ${precio}
    # Determinar categoría usando bloque IF nativo (RF 4.0+)
    IF    ${precio_num} < 20.0
        ${categoria_calculada}=    Set Variable    básico
        Log    [BÁSICO] ${nombre_plan} → $${precio_num}/mes    console=True
    ELSE IF    ${precio_num} < 50.0
        ${categoria_calculada}=    Set Variable    estándar
        Log    [ESTÁNDAR] ${nombre_plan} → $${precio_num}/mes    console=True
    ELSE
        ${categoria_calculada}=    Set Variable    premium
        Log    [PREMIUM] ${nombre_plan} → $${precio_num}/mes    console=True
    END
    # Validar que la categoría calculada coincide con la esperada
    Should Be Equal    ${categoria_calculada}    ${categoria_esp}
    ...    Plan "${nombre_plan}": categoría calculada "${categoria_calculada}" ≠ esperada "${categoria_esp}"
    RETURN    ${categoria_calculada}

Clasificar Todos Los Planes
    [Documentation]    Itera sobre la lista global PLANES y clasifica cada uno.
    ...                Usa un bucle FOR con separación de campos por "|".
    ...                Llama a "Clasificar Plan Por Precio" para cada elemento.
    ${planes_procesados}=    Set Variable    ${0}
    FOR    ${plan_raw}    IN    @{PLANES}
        # Separar los campos del string: nombre|precio|categoria_esperada
        ${campos}=    Separar Campos De Cadena    ${plan_raw}
        ${nombre}=      Obtener Campo    ${campos}    ${0}
        ${precio}=      Obtener Campo    ${campos}    ${1}
        ${categoria}=   Obtener Campo    ${campos}    ${2}
        # Invocar clasificación con validación incorporada
        Clasificar Plan Por Precio    ${nombre}    ${precio}    ${categoria}
        ${planes_procesados}=    Evaluate    ${planes_procesados} + 1
    END
    Log    Total de planes clasificados correctamente: ${planes_procesados}    console=True
    Should Be Equal As Numbers    ${planes_procesados}    6
    ...    Se esperaban 6 planes en el catálogo, se procesaron ${planes_procesados}
```

2. Guarda el archivo.

#### Salida esperada al ejecutar solo TC-01

```bash
robot --test "TC-01 Clasificar Planes Por Precio" \
      --outputdir labs/lab_03_00_01/results \
      labs/lab_03_00_01/suite_control_flujo.robot
```

La consola debe mostrar:

```
TC-01 Clasificar Planes Por Precio
[BÁSICO] Plan Básico 10 → $10.0/mes
[BÁSICO] Plan Básico 15 → $15.99/mes
[ESTÁNDAR] Plan Estándar 30 → $30.0/mes
[ESTÁNDAR] Plan Estándar 45 → $45.5/mes
[PREMIUM] Plan Premium 60 → $60.0/mes
[PREMIUM] Plan Premium 99 → $99.99/mes
Total de planes clasificados correctamente: 6
TC-01 Clasificar Planes Por Precio              | PASS |
```

#### Verificación

Confirma que el test case **TC-01** aparece en verde en el reporte HTML:

```bash
# Abrir el reporte (Windows)
start labs\lab_03_00_01\results\report.html

# macOS
open labs/lab_03_00_01/results/report.html

# Linux
xdg-open labs/lab_03_00_01/results/report.html
```

---

### Paso 4 — Implementar validación de clientes con bucle FOR y condicional anidado

**Objetivo:** Crear la keyword `Validar Cliente` que usa `IF / ELSE IF / ELSE` para verificar el estado de cuenta según el estado del cliente, y `Validar Todos Los Clientes` que la invoca en un bucle `FOR`.

#### Instrucciones

1. Agrega las siguientes keywords a la sección `*** Keywords ***`:

```robotframework
Validar Cliente
    [Documentation]    Valida el estado de cuenta de un cliente según su estado.
    ...                Reglas de negocio TelecomRF:
    ...                  - activo     → saldo debe ser 0.00 (cuenta al día)
    ...                  - suspendido → saldo debe ser 0.00 (suspendido por política)
    ...                  - moroso     → saldo debe ser > 0 (tiene deuda pendiente)
    ...                Argumentos:
    ...                  nombre   — nombre completo del cliente
    ...                  telefono — número de teléfono (solo para logging)
    ...                  estado   — estado de la cuenta: activo|suspendido|moroso
    ...                  saldo    — saldo adeudado en USD como string numérico
    [Arguments]    ${nombre}    ${telefono}    ${estado}    ${saldo}
    ${saldo_num}=    Convert To Number    ${saldo}
    Log    Validando cliente: ${nombre} | Estado: ${estado} | Saldo: $${saldo_num}    console=True
    IF    '${estado}' == 'activo'
        Should Be Equal As Numbers    ${saldo_num}    0
        ...    Cliente activo "${nombre}" no debería tener saldo pendiente (saldo: $${saldo_num})
        Log    ✓ Cliente activo sin deuda — OK    console=True
    ELSE IF    '${estado}' == 'suspendido'
        Should Be Equal As Numbers    ${saldo_num}    0
        ...    Cliente suspendido "${nombre}" no debería tener saldo pendiente (saldo: $${saldo_num})
        Log    ✓ Cliente suspendido sin deuda — OK    console=True
    ELSE IF    '${estado}' == 'moroso'
        Should Be True    ${saldo_num} > 0
        ...    Cliente moroso "${nombre}" debe tener saldo > 0 (saldo registrado: $${saldo_num})
        Log    ✓ Cliente moroso con deuda $${saldo_num} — registrado correctamente    console=True
    ELSE
        Fail    Estado de cuenta desconocido "${estado}" para el cliente "${nombre}"
    END

Validar Todos Los Clientes
    [Documentation]    Itera sobre la lista global CLIENTES y valida cada registro.
    ...                Usa bucle FOR con separación de campos por "|".
    ...                Acumula contadores por tipo de estado para reporte final.
    ${total_activos}=      Set Variable    ${0}
    ${total_suspendidos}=  Set Variable    ${0}
    ${total_morosos}=      Set Variable    ${0}
    FOR    ${cliente_raw}    IN    @{CLIENTES}
        ${campos}=    Separar Campos De Cadena    ${cliente_raw}
        ${nombre}=    Obtener Campo    ${campos}    ${0}
        ${tel}=       Obtener Campo    ${campos}    ${1}
        ${estado}=    Obtener Campo    ${campos}    ${2}
        ${saldo}=     Obtener Campo    ${campos}    ${3}
        Validar Cliente    ${nombre}    ${tel}    ${estado}    ${saldo}
        # Contabilizar por estado usando IF anidado
        IF    '${estado}' == 'activo'
            ${total_activos}=    Evaluate    ${total_activos} + 1
        ELSE IF    '${estado}' == 'suspendido'
            ${total_suspendidos}=    Evaluate    ${total_suspendidos} + 1
        ELSE IF    '${estado}' == 'moroso'
            ${total_morosos}=    Evaluate    ${total_morosos} + 1
        END
    END
    # Resumen de validación
    Log    ═══ RESUMEN DE CLIENTES ═══    console=True
    Log    Activos: ${total_activos} | Suspendidos: ${total_suspendidos} | Morosos: ${total_morosos}    console=True
    # Verificar que se procesaron exactamente 5 clientes
    ${total}=    Evaluate    ${total_activos} + ${total_suspendidos} + ${total_morosos}
    Should Be Equal As Numbers    ${total}    5
    ...    Se esperaban 5 clientes en total, se procesaron ${total}
    # Verificar distribución esperada según datos de prueba
    Should Be Equal As Numbers    ${total_morosos}    2
    ...    Se esperaban 2 clientes morosos en los datos de prueba
```

2. Guarda el archivo.

#### Salida esperada al ejecutar TC-02

```bash
robot --test "TC-02 Validar Estado De Cuenta De Clientes" \
      --outputdir labs/lab_03_00_01/results \
      labs/lab_03_00_01/suite_control_flujo.robot
```

```
TC-02 Validar Estado De Cuenta De Clientes
Validando cliente: Ana Torres | Estado: activo | Saldo: $0.0
✓ Cliente activo sin deuda — OK
Validando cliente: Carlos Ruiz | Estado: moroso | Saldo: $150.75
✓ Cliente moroso con deuda $150.75 — registrado correctamente
Validando cliente: María López | Estado: activo | Saldo: $0.0
✓ Cliente activo sin deuda — OK
Validando cliente: Jorge Pérez | Estado: suspendido | Saldo: $0.0
✓ Cliente suspendido sin deuda — OK
Validando cliente: Laura Gómez | Estado: moroso | Saldo: $89.5
✓ Cliente moroso con deuda $89.5 — registrado correctamente
═══ RESUMEN DE CLIENTES ═══
Activos: 2 | Suspendidos: 1 | Morosos: 2
TC-02 Validar Estado De Cuenta De Clientes      | PASS |
```

#### Verificación

Confirma que el log HTML muestra el árbol de keywords con todas las ramas `IF` evaluadas correctamente. En el reporte, cada cliente debe aparecer como una llamada exitosa a `Validar Cliente`.

---

### Paso 5 — Implementar el bucle WHILE con simulación de reintentos

**Objetivo:** Crear la keyword `Simular Conexion Con Reintentos` que usa un bucle `WHILE` con límite máximo de iteraciones y `BREAK` para salir cuando la conexión es exitosa.

#### Instrucciones

1. Agrega las siguientes keywords:

```robotframework
Simular Intento De Conexion
    [Documentation]    Simula un intento de conexión a un servidor de red.
    ...                En este ejercicio, la conexión tiene éxito en el intento
    ...                número 3 (simulado con una comparación de contador).
    ...                Argumento: numero_intento — entero con el número de intento actual
    ...                Retorna: ${TRUE} si la conexión fue exitosa, ${FALSE} si falló
    [Arguments]    ${numero_intento}
    Log    Intento de conexión #${numero_intento}...    console=True
    # Simulación: la conexión tiene éxito en el intento 3
    IF    ${numero_intento} == 3
        Log    ✓ Conexión establecida exitosamente en el intento ${numero_intento}    console=True
        RETURN    ${TRUE}
    ELSE
        Log    ✗ Conexión fallida — reintentando...    console=True
        RETURN    ${FALSE}
    END

Simular Conexion Con Reintentos
    [Documentation]    Ejecuta reintentos de conexión usando un bucle WHILE.
    ...                El bucle se detiene cuando:
    ...                  a) La conexión es exitosa (BREAK), o
    ...                  b) Se alcanza el límite máximo de reintentos
    ...                Argumento: max_intentos — número máximo de intentos permitidos
    ...                Retorna: número total de intentos realizados
    [Arguments]    ${max_intentos}
    ${intento_actual}=    Set Variable    ${1}
    ${conexion_ok}=       Set Variable    ${FALSE}
    WHILE    not ${conexion_ok}    limit=${max_intentos}
        ${conexion_ok}=    Simular Intento De Conexion    ${intento_actual}
        IF    ${conexion_ok}
            Log    Conexión lograda en ${intento_actual} intento(s)    console=True
            BREAK
        END
        ${intento_actual}=    Evaluate    ${intento_actual} + 1
    END
    # Verificar que la conexión fue eventualmente exitosa
    Should Be True    ${conexion_ok}
    ...    La conexión no pudo establecerse en ${max_intentos} intentos
    # Verificar que el número de intentos está dentro del rango esperado
    Should Be True    ${intento_actual} >= 1
    ...    El contador de intentos debe ser al menos 1
    Should Be True    ${intento_actual} <= ${max_intentos}
    ...    El contador de intentos (${intento_actual}) superó el máximo (${max_intentos})
    Log    ═══ RESULTADO CONEXIÓN ═══    console=True
    Log    Intentos realizados: ${intento_actual} / ${max_intentos}    console=True
    RETURN    ${intento_actual}
```

2. Guarda el archivo.

#### Salida esperada al ejecutar TC-03

```bash
robot --test "TC-03 Simular Reintentos De Conexion" \
      --outputdir labs/lab_03_00_01/results \
      labs/lab_03_00_01/suite_control_flujo.robot
```

```
TC-03 Simular Reintentos De Conexion
Intento de conexión #1...
✗ Conexión fallida — reintentando...
Intento de conexión #2...
✗ Conexión fallida — reintentando...
Intento de conexión #3...
✓ Conexión establecida exitosamente en el intento 3
Conexión lograda en 3 intento(s)
═══ RESULTADO CONEXIÓN ═══
Intentos realizados: 3 / 5
TC-03 Simular Reintentos De Conexion            | PASS |
```

#### Verificación

Modifica temporalmente el valor de `Simular Intento De Conexion` para que nunca retorne `${TRUE}` (cambia `== 3` por `== 99`) y ejecuta de nuevo TC-03. Debes observar que el bucle WHILE se detiene al alcanzar el `limit=${max_intentos}` y el test **falla** con el mensaje de aserción. Restaura el valor original después de verificar.

---

### Paso 6 — Implementar validación de formato telefónico con Should Match Regexp

**Objetivo:** Crear la keyword `Validar Formato Telefonos De Clientes` que usa `Should Match Regexp` en un bucle `FOR` para verificar que todos los números de teléfono cumplen el patrón internacional definido.

#### Instrucciones

1. Agrega la siguiente keyword:

```robotframework
Validar Formato Telefono Individual
    [Documentation]    Valida que un número de teléfono cumple el patrón internacional.
    ...                Patrón esperado: +XX-XXX-XXX-XXXX (ej: +52-555-123-4567)
    ...                Argumentos:
    ...                  nombre   — nombre del cliente (para mensajes de error)
    ...                  telefono — número de teléfono a validar
    [Arguments]    ${nombre}    ${telefono}
    Should Not Be Empty    ${telefono}
    ...    El número de teléfono del cliente "${nombre}" no puede estar vacío
    Should Match Regexp    ${telefono}    ${PATRON_TELEFONO}
    ...    Teléfono "${telefono}" del cliente "${nombre}" no cumple el formato +XX-XXX-XXX-XXXX
    Log    ✓ Teléfono válido: ${telefono} (${nombre})    console=True

Validar Formato Telefonos De Clientes
    [Documentation]    Itera sobre todos los clientes y valida el formato de teléfono.
    ...                Usa bucle FOR con CONTINUE para omitir entradas con nombre vacío
    ...                (aunque en este dataset no existen, se incluye como buena práctica).
    ${telefonos_validados}=    Set Variable    ${0}
    FOR    ${cliente_raw}    IN    @{CLIENTES}
        ${campos}=    Separar Campos De Cadena    ${cliente_raw}
        ${nombre}=    Obtener Campo    ${campos}    ${0}
        ${tel}=       Obtener Campo    ${campos}    ${1}
        # Usar CONTINUE para omitir registros con nombre vacío (buena práctica defensiva)
        IF    '${nombre}' == ''
            Log    ADVERTENCIA: Registro sin nombre omitido    console=True
            CONTINUE
        END
        Validar Formato Telefono Individual    ${nombre}    ${tel}
        ${telefonos_validados}=    Evaluate    ${telefonos_validados} + 1
    END
    Log    Total de teléfonos validados: ${telefonos_validados}    console=True
    Should Be Equal As Numbers    ${telefonos_validados}    5
    ...    Se esperaban 5 teléfonos validados, se procesaron ${telefonos_validados}
```

2. Guarda el archivo.

#### Salida esperada al ejecutar TC-04

```bash
robot --test "TC-04 Validar Formato De Telefonos" \
      --outputdir labs/lab_03_00_01/results \
      labs/lab_03_00_01/suite_control_flujo.robot
```

```
TC-04 Validar Formato De Telefonos
✓ Teléfono válido: +52-555-123-4567 (Ana Torres)
✓ Teléfono válido: +52-555-987-6543 (Carlos Ruiz)
✓ Teléfono válido: +52-555-456-7890 (María López)
✓ Teléfono válido: +52-555-321-0987 (Jorge Pérez)
✓ Teléfono válido: +52-555-654-3210 (Laura Gómez)
Total de teléfonos validados: 5
TC-04 Validar Formato De Telefonos              | PASS |
```

#### Verificación

Introduce intencionalmente un número con formato incorrecto en `@{CLIENTES}` del archivo resource (por ejemplo, cambia `+52-555-123-4567` por `555-123-4567`) y ejecuta TC-04. El test debe **fallar** con un mensaje claro indicando qué número no cumple el patrón. Restaura el valor original.

---

### Paso 7 — Implementar el test integrador con lógica anidada

**Objetivo:** Crear la keyword `Ejecutar Validacion Integrada` que combina clasificación de planes y validación de clientes en un único flujo, usando condicionales anidados para generar un reporte de estado consolidado.

#### Instrucciones

1. Agrega la keyword integradora:

```robotframework
Evaluar Estado General Del Plan
    [Documentation]    Keyword auxiliar que determina si un plan es recomendable
    ...                para un cliente según su estado de cuenta.
    ...                Lógica:
    ...                  - Cliente moroso + plan premium → NO recomendable
    ...                  - Cliente activo + cualquier plan → recomendable
    ...                  - Otros casos → evaluación pendiente
    ...                Argumentos:
    ...                  estado_cliente — estado de cuenta del cliente
    ...                  categoria_plan — categoría del plan: básico|estándar|premium
    ...                Retorna: string con la recomendación
    [Arguments]    ${estado_cliente}    ${categoria_plan}
    IF    '${estado_cliente}' == 'activo'
        ${recomendacion}=    Set Variable    RECOMENDABLE
    ELSE IF    '${estado_cliente}' == 'moroso'
        IF    '${categoria_plan}' == 'premium'
            ${recomendacion}=    Set Variable    NO RECOMENDABLE
        ELSE
            ${recomendacion}=    Set Variable    CONDICIONALMENTE RECOMENDABLE
        END
    ELSE
        ${recomendacion}=    Set Variable    EVALUACIÓN PENDIENTE
    END
    RETURN    ${recomendacion}

Ejecutar Validacion Integrada
    [Documentation]    Flujo integrador que combina clasificación de planes y
    ...                validación de clientes. Para cada cliente moroso, evalúa
    ...                si el plan premium sería recomendable.
    ...                Genera un reporte consolidado al finalizar.
    Log    ═══ INICIO VALIDACIÓN INTEGRADA ═══    console=True
    # Paso 1: Clasificar todos los planes y recolectar categorías
    ${categorias}=    Create List
    FOR    ${plan_raw}    IN    @{PLANES}
        ${campos}=       Separar Campos De Cadena    ${plan_raw}
        ${nombre}=       Obtener Campo    ${campos}    ${0}
        ${precio}=       Obtener Campo    ${campos}    ${1}
        ${cat_esp}=      Obtener Campo    ${campos}    ${2}
        ${cat_calc}=     Clasificar Plan Por Precio    ${nombre}    ${precio}    ${cat_esp}
        Append To List    ${categorias}    ${cat_calc}
    END
    Should Contain    ${categorias}    premium
    ...    El catálogo debe contener al menos un plan premium
    Should Contain    ${categorias}    básico
    ...    El catálogo debe contener al menos un plan básico
    # Paso 2: Para cada cliente moroso, evaluar recomendación con plan premium
    Log    ═══ EVALUACIÓN DE CLIENTES MOROSOS ═══    console=True
    ${evaluaciones}=    Create List
    FOR    ${cliente_raw}    IN    @{CLIENTES}
        ${campos}=   Separar Campos De Cadena    ${cliente_raw}
        ${nombre}=   Obtener Campo    ${campos}    ${0}
        ${estado}=   Obtener Campo    ${campos}    ${2}
        IF    '${estado}' == 'moroso'
            ${rec}=    Evaluar Estado General Del Plan    ${estado}    premium
            Log    ${nombre} (moroso) + Plan Premium → ${rec}    console=True
            Append To List    ${evaluaciones}    ${rec}
        END
    END
    # Verificar que todos los clientes morosos recibieron evaluación NO RECOMENDABLE
    FOR    ${evaluacion}    IN    @{evaluaciones}
        Should Be Equal    ${evaluacion}    NO RECOMENDABLE
        ...    Un cliente moroso no debería recibir recomendación positiva para plan premium
    END
    Log    ═══ FIN VALIDACIÓN INTEGRADA ═══    console=True
    Log    Planes categorizados: ${categorias}    console=True
    Log    Evaluaciones morosos: ${evaluaciones}    console=True
```

2. Guarda el archivo.

#### Salida esperada al ejecutar TC-05

```bash
robot --test "TC-05 Flujo Integrado Clasificacion Y Validacion" \
      --outputdir labs/lab_03_00_01/results \
      labs/lab_03_00_01/suite_control_flujo.robot
```

```
TC-05 Flujo Integrado Clasificacion Y Validacion
═══ INICIO VALIDACIÓN INTEGRADA ═══
[BÁSICO] Plan Básico 10 → $10.0/mes
... (clasificación de todos los planes)
═══ EVALUACIÓN DE CLIENTES MOROSOS ═══
Carlos Ruiz (moroso) + Plan Premium → NO RECOMENDABLE
Laura Gómez (moroso) + Plan Premium → NO RECOMENDABLE
═══ FIN VALIDACIÓN INTEGRADA ═══
TC-05 Flujo Integrado Clasificacion Y Validacion | PASS |
```

#### Verificación

Revisa el log HTML y confirma que el árbol de keywords muestra correctamente la anidación: `Ejecutar Validacion Integrada` → `Clasificar Plan Por Precio` (×6) → `Evaluar Estado General Del Plan` (×2).

---

## Validación y Pruebas

### Ejecución completa de la suite

Ejecuta todos los test cases de una vez y genera el reporte completo:

```bash
robot \
    --outputdir labs/lab_03_00_01/results \
    --log log_lab03.html \
    --report report_lab03.html \
    --output output_lab03.xml \
    labs/lab_03_00_01/suite_control_flujo.robot
```

**Variante Windows (una sola línea):**

```cmd
robot --outputdir labs\lab_03_00_01\results --log log_lab03.html --report report_lab03.html --output output_lab03.xml labs\lab_03_00_01\suite_control_flujo.robot
```

### Resultado esperado de la suite completa

```
==============================================================================
Suite Control Flujo :: Suite de pruebas: Validación de catálogo de planes ...
==============================================================================
TC-01 Clasificar Planes Por Precio                              | PASS |
TC-02 Validar Estado De Cuenta De Clientes                      | PASS |
TC-03 Simular Reintentos De Conexion                            | PASS |
TC-04 Validar Formato De Telefonos                              | PASS |
TC-05 Flujo Integrado Clasificacion Y Validacion                | PASS |
==============================================================================
Suite Control Flujo :: Suite de pruebas: Validación de ...      | PASS |
5 tests, 5 passed, 0 failed
==============================================================================
Output:  .../results/output_lab03.xml
Log:     .../results/log_lab03.html
Report:  .../results/report_lab03.html
```

### Lista de verificación de criterios de éxito

Antes de dar por completado el laboratorio, confirma cada punto:

| # | Criterio | Verificación |
|---|----------|--------------|
| 1 | Los 5 test cases pasan sin errores | `5 tests, 5 passed, 0 failed` en consola |
| 2 | TC-01 clasifica correctamente los 6 planes | Log muestra [BÁSICO]×2, [ESTÁNDAR]×2, [PREMIUM]×2 |
| 3 | TC-02 valida los 5 clientes y detecta 2 morosos | Resumen muestra `Morosos: 2` |
| 4 | TC-03 establece conexión en el intento 3 | Log muestra `Intentos realizados: 3 / 5` |
| 5 | TC-04 valida los 5 teléfonos con regexp | Log muestra `Total de teléfonos validados: 5` |
| 6 | TC-05 evalúa 2 clientes morosos como NO RECOMENDABLE | Log muestra evaluaciones de Carlos Ruiz y Laura Gómez |
| 7 | Todas las keywords tienen `[Documentation]` | Visible en el log HTML de cada keyword |
| 8 | El reporte HTML se genera correctamente | Archivo `report_lab03.html` abre en el navegador |

### Ejecución por etiquetas (opcional)

```bash
# Ejecutar solo tests de lógica condicional
robot --include condicional --outputdir labs/lab_03_00_01/results labs/lab_03_00_01/suite_control_flujo.robot

# Ejecutar solo tests de bucles
robot --include bucle-for --include bucle-while --outputdir labs/lab_03_00_01/results labs/lab_03_00_01/suite_control_flujo.robot

# Ejecutar solo el test avanzado
robot --include avanzado --outputdir labs/lab_03_00_01/results labs/lab_03_00_01/suite_control_flujo.robot
```

---

## Resolución de Problemas

### Problema 1: El bucle WHILE no termina o genera error `WHILE loop was aborted`

**Síntomas:**
- El test TC-03 falla con el mensaje `WHILE loop was aborted because it did not finish within the limit of X iterations`
- O bien, el test corre indefinidamente sin terminar

**Causa:**
El parámetro `limit=` del bucle `WHILE` controla el número máximo de iteraciones permitidas. Si la condición de salida (`${conexion_ok}`) nunca se vuelve `${TRUE}` —por ejemplo, porque la lógica de `Simular Intento De Conexion` nunca retorna `${TRUE}`— el bucle alcanza el límite y Robot Framework lo aborta automáticamente lanzando una excepción. Esto es un mecanismo de seguridad para evitar bucles infinitos.

**Solución:**
1. Verifica que `Simular Intento De Conexion` retorna `${TRUE}` cuando `${numero_intento} == 3`:
   ```robotframework
   IF    ${numero_intento} == 3
       RETURN    ${TRUE}
   ```
2. Confirma que `${MAX_REINTENTOS}` en `telecom_data.resource` tiene el valor `5` (mayor que 3).
3. Si modificaste la keyword durante las pruebas del Paso 5, restaura el valor `== 3`.
4. Asegúrate de que el parámetro `limit` usa la sintaxis correcta: `WHILE    not ${conexion_ok}    limit=${max_intentos}` (con el argumento `limit=` sin espacios alrededor del `=`).

---

### Problema 2: `Should Match Regexp` falla con error de patrón inválido o no coincide

**Síntomas:**
- TC-04 falla con el mensaje `Regular expression pattern '...' is not valid` o `'+52-555-123-4567' does not match '^\\+\\d{2}-\\d{3}-\\d{3}-\\d{4}$'`
- El error aparece incluso con números de teléfono que visualmente parecen correctos

**Causa:**
Existen dos causas frecuentes:
1. **Doble escape en el archivo resource:** En archivos `.resource` y `.robot`, las barras invertidas deben escaparse con doble barra `\\` para que el motor de Robot Framework las pase correctamente al motor de expresiones regulares de Python. Si el patrón tiene `\+` en lugar de `\\+`, el carácter `+` no se escapa correctamente.
2. **Espacios invisibles en los datos:** Al separar campos con `Split String`, si los datos en `@{CLIENTES}` tienen espacios antes o después del número de teléfono, la regexp no coincidirá.

**Solución:**
1. Verifica que el patrón en `telecom_data.resource` usa doble barra invertida:
   ```robotframework
   ${PATRON_TELEFONO}    ^\\+\\d{2}-\\d{3}-\\d{3}-\\d{4}$
   ```
2. Si sospechas de espacios, agrega un `Strip String` antes de la validación:
   ```robotframework
   ${tel_limpio}=    Strip String    ${tel}
   Should Match Regexp    ${tel_limpio}    ${PATRON_TELEFONO}
   ```
3. Para depurar, agrega temporalmente un `Log` que muestre la longitud del string:
   ```robotframework
   ${longitud}=    Get Length    ${tel}
   Log    Teléfono: "${tel}" | Longitud: ${longitud}    console=True
   ```
   Un número `+52-555-123-4567` debe tener exactamente 16 caracteres.

---

## Limpieza

Al finalizar el laboratorio, realiza los siguientes pasos de limpieza:

### 1. Guardar una copia de respaldo del proyecto

```bash
# Windows (PowerShell)
Copy-Item -Recurse labs\lab_03_00_01 labs\lab_03_00_01_backup

# macOS / Linux
cp -r labs/lab_03_00_01 labs/lab_03_00_01_backup
```

### 2. Limpiar archivos temporales de resultados (opcional)

Si deseas liberar espacio, puedes eliminar los archivos XML de salida (conserva los HTML para revisión):

```bash
# Windows
del labs\lab_03_00_01\results\output_lab03.xml

# macOS / Linux
rm labs/lab_03_00_01/results/output_lab03.xml
```

### 3. Desactivar el entorno virtual

```bash
deactivate
```

### 4. Verificar estructura final del proyecto

La estructura final del laboratorio debe verse así:

```
labs/lab_03_00_01/
├── resources/
│   └── telecom_data.resource          ✓ Variables y keywords de datos
├── results/
│   ├── log_lab03.html                 ✓ Log detallado con árbol de keywords
│   └── report_lab03.html              ✓ Reporte de ejecución (5/5 PASS)
└── suite_control_flujo.robot          ✓ Suite principal con 5 test cases
```

---

## Resumen

En este laboratorio implementaste un conjunto completo de técnicas de control de flujo avanzado en Robot Framework 7.x aplicadas a un escenario de telecomunicaciones:

| Técnica | Aplicación en el laboratorio |
|---------|------------------------------|
| `IF / ELSE IF / ELSE` | Clasificación de planes por precio y validación de estado de clientes |
| `FOR` sobre lista `@{}` | Iteración sobre catálogo de planes y lista de clientes |
| `WHILE` con `limit=` | Simulación de reintentos de conexión con límite máximo |
| `BREAK` | Salida anticipada del bucle WHILE al lograr la conexión |
| `CONTINUE` | Omisión defensiva de registros vacíos en el bucle FOR |
| `Should Be Equal As Numbers` | Validación numérica de saldos y contadores |
| `Should Match Regexp` | Validación de formato de números telefónicos |
| `Should Contain` | Verificación de presencia de categorías en listas |
| `Should Not Be Empty` | Validación defensiva de campos obligatorios |
| `[Documentation]` | Documentación de todas las keywords con propósito y argumentos |
| IF anidado | Lógica de recomendación en el test integrador TC-05 |

### Conceptos clave reforzados

- La sintaxis `IF / ELSE IF / ELSE` nativa (RF 4.0+) es más legible y mantenible que `Run Keyword If`; ambas son válidas pero se prefiere la nativa en proyectos nuevos.
- Las condiciones en bloques `IF` se evalúan como expresiones Python: las cadenas deben ir entre comillas simples (`'${var}' == 'valor'`), mientras que los números se comparan directamente (`${num} > 20`).
- El parámetro `limit=` en `WHILE` es obligatorio en Robot Framework 7.x para prevenir bucles infinitos; su ausencia genera un error de sintaxis.
- La combinación de `BREAK` y `CONTINUE` permite un control preciso del flujo dentro de bucles sin necesidad de variables de bandera adicionales.

### Recursos adicionales

- [Documentación oficial — IF/ELSE structure](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#if-else-if-else-structure)
- [Documentación oficial — FOR loops](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#for-loops)
- [Documentación oficial — WHILE loops](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#while-loops)
- [Librería BuiltIn — referencia completa de aserciones](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html)
- [Librería Collections — Get From List, Append To List](https://robotframework.org/robotframework/latest/libraries/Collections.html)

---

---

