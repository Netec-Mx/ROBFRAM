# Práctica 6: Suite robusta con manejo de fallas y recuperación

## Metadatos

| Campo            | Valor                                      |
|------------------|--------------------------------------------|
| **Duración**     | 72 minutos                                 |
| **Complejidad**  | Alta                                       |
| **Nivel Bloom**  | Aplicar (Apply)                            |
| **Módulo**       | 3 — Control de Flujo y Manejo de Errores   |
| **Laboratorio**  | 03-00-02 (Práctica 6)                      |

---

## Descripción General

En este laboratorio construirás una suite de prueba robusta para un flujo ficticio de **activación de servicios de telecomunicaciones**. Aprenderás a provocar errores controlados y capturarlos con `Run Keyword And Expect Error`, a acumular múltiples fallas no críticas con `Run Keyword And Continue On Failure`, y a implementar un mecanismo de limpieza condicional en `Test Teardown` que se ejecuta únicamente cuando un test case falla. Al finalizar, la suite será capaz de completar toda su ejecución reportando todas las fallas encontradas en un único ciclo, en lugar de detenerse ante el primer error.

---

## Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Usar `Run Keyword And Expect Error` para verificar que una keyword falla con el mensaje de error exacto esperado en condiciones de borde.
- [ ] Implementar `Run Keyword And Continue On Failure` para acumular múltiples validaciones independientes sin detener el test case.
- [ ] Diseñar un `Test Teardown` con `Run Keyword If Test Failed` que ejecute lógica de limpieza condicional según el resultado del test.
- [ ] Construir una suite completa que diferencie fallas críticas (que detienen el test) de fallas no críticas (que se acumulan en el reporte).
- [ ] Leer e interpretar correctamente el reporte `log.html` de una suite con múltiples fallas acumuladas.

---

## Prerrequisitos

### Conocimiento previo

- Haber completado el **Laboratorio 03-00-01** con estructuras de control `IF/FOR/WHILE` funcionales.
- Comprensión de `Suite Setup`, `Suite Teardown`, `Test Setup` y `Test Teardown` a nivel de test case y suite.
- Familiaridad con la lectura de mensajes de error en `log.html` y `report.html`.
- Conocimiento básico de keywords de la librería `BuiltIn`: `Log`, `Fail`, `Should Be Equal`, `Should Contain`.

### Acceso y recursos

- Entorno virtual Python activo con Robot Framework 7.x instalado (heredado del Lab 03-00-01).
- Visual Studio Code con la extensión **Robot Framework Language Server** instalada.
- Conexión a internet **no requerida** para este laboratorio (todos los datos son ficticios y locales).

---

## Entorno de Laboratorio

### Requisitos de hardware

| Componente       | Mínimo requerido                              |
|------------------|-----------------------------------------------|
| Procesador       | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos)|
| RAM              | 8 GB                                          |
| Almacenamiento   | 500 MB libres para artefactos del laboratorio |
| Pantalla         | Resolución mínima 1280×768                    |

### Requisitos de software

| Software                        | Versión mínima |
|---------------------------------|----------------|
| Python                          | 3.10+          |
| Robot Framework                 | 7.x            |
| Visual Studio Code              | 1.85+          |
| Robot Framework Language Server | 1.12+          |

### Preparación del entorno

Abre una terminal y verifica que el entorno virtual del módulo 3 esté activo. Si no lo has activado aún, ejecuta los siguientes comandos según tu sistema operativo:

```bash
# ── Windows (cmd) ──────────────────────────────────────────────
cd C:\cursoRF\modulo03
venv\Scripts\activate

# ── Windows (PowerShell) ───────────────────────────────────────
cd C:\cursoRF\modulo03
.\venv\Scripts\Activate.ps1

# ── macOS / Linux (bash/zsh) ───────────────────────────────────
cd ~/cursoRF/modulo03
source venv/bin/activate
```

Confirma que Robot Framework está disponible:

```bash
robot --version
# Salida esperada: Robot Framework 7.x.x (Python 3.x.x ...)
```

Crea la estructura de carpetas para este laboratorio:

```bash
# ── Windows (cmd) ──────────────────────────────────────────────
mkdir lab_03_02\resources
mkdir lab_03_02\tests
mkdir lab_03_02\results

# ── macOS / Linux (bash/zsh) ───────────────────────────────────
mkdir -p lab_03_02/resources lab_03_02/tests lab_03_02/results
```

Cambia al directorio del laboratorio:

```bash
cd lab_03_02
```

> **Nota importante:** Todos los archivos creados en los pasos siguientes se ubican dentro de `lab_03_02/`. Asegúrate de estar posicionado en ese directorio antes de ejecutar cualquier comando `robot`.

---

## Instrucciones Paso a Paso

---

### Paso 1 — Crear el archivo de variables y datos del dominio de telecomunicaciones

**Objetivo:** Definir las variables de negocio que representan el estado de los servicios de telecomunicaciones. Estas variables serán la base de todas las validaciones del laboratorio.

#### Instrucciones

1. En Visual Studio Code, abre la carpeta `lab_03_02`.

2. Crea el archivo `resources/telecom_variables.resource` con el siguiente contenido:

```robotframework
*** Settings ***
Documentation    Variables de dominio para el flujo de activación de servicios
...              de telecomunicaciones — Empresa ficticia TelcoDemo S.A.

*** Variables ***
# ── Datos de cliente ───────────────────────────────────────────
${CLIENTE_ID}           CLI-2024-001
${CLIENTE_NOMBRE}       Juan Pérez
${CLIENTE_PLAN}         PLAN_FIBRA_500

# ── Estados válidos del servicio ───────────────────────────────
${ESTADO_PENDIENTE}     PENDIENTE
${ESTADO_ACTIVO}        ACTIVO
${ESTADO_SUSPENDIDO}    SUSPENDIDO
${ESTADO_ERROR}         ERROR

# ── Límites y umbrales de validación ───────────────────────────
${VELOCIDAD_MINIMA}     ${100}
${VELOCIDAD_MAXIMA}     ${1000}
${LATENCIA_MAXIMA}      ${50}
${PAQUETES_PERDIDOS_MAX}    ${0.05}

# ── Mensajes de error esperados (usados con Run Keyword And Expect Error) ──
${MSG_CLIENTE_INVALIDO}     Cliente no encontrado: CLI-INVALIDO
${MSG_PLAN_INVALIDO}        Plan de servicio no reconocido: PLAN_INEXISTENTE
${MSG_VELOCIDAD_FUERA_RANGO}    Velocidad fuera de rango permitido: -50
${MSG_ESTADO_INVALIDO}      Transición de estado inválida: ACTIVO -> PENDIENTE

# ── Variables de estado del sistema (se modifican durante los tests) ──
${SERVICIO_ACTIVADO}    ${FALSE}
${ROLLBACK_REQUERIDO}   ${FALSE}
```

3. Guarda el archivo.

#### Salida esperada

El archivo `resources/telecom_variables.resource` existe y Visual Studio Code no muestra errores de sintaxis en el panel de problemas.

#### Verificación

```bash
# Verifica que el archivo existe y tiene contenido
# ── Windows (cmd) ──────────────────────────────────────────────
type resources\telecom_variables.resource

# ── macOS / Linux ──────────────────────────────────────────────
cat resources/telecom_variables.resource
```

---

### Paso 2 — Crear el archivo Resource con keywords de negocio (incluyendo keywords que fallan intencionalmente)

**Objetivo:** Implementar las keywords de negocio que simulan el sistema de telecomunicaciones. Algunas keywords están diseñadas para **fallar intencionalmente** con mensajes de error específicos; estas serán el objetivo de `Run Keyword And Expect Error`.

#### Instrucciones

1. Crea el archivo `resources/telecom_keywords.resource`:

```robotframework
*** Settings ***
Documentation    Keywords de negocio para el flujo de activación de servicios
...              TelcoDemo S.A. — Módulo 3, Laboratorio 03-00-02
Library          BuiltIn
Resource         telecom_variables.resource

*** Keywords ***
# ══════════════════════════════════════════════════════════════
# KEYWORDS DE VALIDACIÓN — algunas fallan intencionalmente
# ══════════════════════════════════════════════════════════════

Validar Cliente
    [Documentation]    Valida que el ID de cliente existe en el sistema.
    ...                Falla con mensaje específico si el cliente no es válido.
    [Arguments]    ${cliente_id}
    Log    Validando cliente: ${cliente_id}
    # Simula la lógica de validación: solo acepta IDs con prefijo CLI-
    IF    not '${cliente_id}'.startswith('CLI-')
        Fail    Cliente no encontrado: ${cliente_id}
    END
    Log    Cliente ${cliente_id} validado correctamente

Validar Plan De Servicio
    [Documentation]    Verifica que el plan solicitado existe en el catálogo.
    ...                Falla con mensaje específico si el plan no existe.
    [Arguments]    ${plan}
    Log    Verificando plan de servicio: ${plan}
    @{planes_validos}=    Create List
    ...    PLAN_FIBRA_100    PLAN_FIBRA_500    PLAN_FIBRA_1000
    ...    PLAN_MOVIL_BASICO    PLAN_MOVIL_PRO
    ${plan_existe}=    Run Keyword And Return Status
    ...    Should Contain    ${planes_validos}    ${plan}
    IF    not ${plan_existe}
        Fail    Plan de servicio no reconocido: ${plan}
    END
    Log    Plan ${plan} encontrado en catálogo

Validar Velocidad De Servicio
    [Documentation]    Verifica que la velocidad contratada está dentro del rango permitido.
    ...                Falla si la velocidad es negativa o supera el máximo.
    [Arguments]    ${velocidad}
    Log    Verificando velocidad: ${velocidad} Mbps
    IF    ${velocidad} < 0
        Fail    Velocidad fuera de rango permitido: ${velocidad}
    ELSE IF    ${velocidad} > ${VELOCIDAD_MAXIMA}
        Fail    Velocidad supera el máximo permitido: ${velocidad}
    END
    Log    Velocidad ${velocidad} Mbps dentro del rango permitido

Validar Transicion De Estado
    [Documentation]    Verifica que la transición de estado solicitada es válida.
    ...                No se puede volver a PENDIENTE desde ACTIVO.
    [Arguments]    ${estado_actual}    ${estado_nuevo}
    Log    Verificando transición: ${estado_actual} -> ${estado_nuevo}
    IF    '${estado_actual}' == 'ACTIVO' and '${estado_nuevo}' == 'PENDIENTE'
        Fail    Transición de estado inválida: ${estado_actual} -> ${estado_nuevo}
    END
    Log    Transición ${estado_actual} -> ${estado_nuevo} permitida

# ══════════════════════════════════════════════════════════════
# KEYWORDS DE ACTIVACIÓN DEL SERVICIO
# ══════════════════════════════════════════════════════════════

Activar Servicio Para Cliente
    [Documentation]    Ejecuta el flujo completo de activación de servicio.
    ...                Establece SERVICIO_ACTIVADO en TRUE al completarse.
    [Arguments]    ${cliente_id}    ${plan}
    Log    Iniciando activación de servicio para ${cliente_id} con plan ${plan}
    Validar Cliente    ${cliente_id}
    Validar Plan De Servicio    ${plan}
    # Simula la activación en el sistema backend
    Log    Provisionando servicio en infraestructura...
    Log    Configurando parámetros de red...
    Log    Servicio activado exitosamente para ${cliente_id}
    Set Test Variable    ${SERVICIO_ACTIVADO}    ${TRUE}

Revertir Activacion De Servicio
    [Documentation]    Ejecuta el rollback del servicio activado.
    ...                Se llama desde el Teardown cuando el test falla.
    [Arguments]    ${cliente_id}
    Log    *** ROLLBACK: Revirtiendo activación de servicio para ${cliente_id} ***    WARN
    Log    Desaprovisionando recursos de red...
    Log    Liberando IP asignada...
    Log    Limpiando registros de facturación...
    Log    Rollback completado para ${cliente_id}
    Set Test Variable    ${SERVICIO_ACTIVADO}    ${FALSE}

Registrar Falla En Sistema De Monitoreo
    [Documentation]    Simula el registro de la falla en el sistema de monitoreo.
    ...                Se invoca desde el Teardown para trazabilidad.
    [Arguments]    ${cliente_id}    ${motivo}
    Log    [MONITOREO] Falla registrada — Cliente: ${cliente_id} | Motivo: ${motivo}    WARN

# ══════════════════════════════════════════════════════════════
# KEYWORDS DE VALIDACIÓN POST-ACTIVACIÓN (para Continue On Failure)
# ══════════════════════════════════════════════════════════════

Verificar Velocidad Downstream
    [Documentation]    Verifica que la velocidad de bajada cumple el SLA.
    [Arguments]    ${velocidad_medida}    ${velocidad_contratada}
    Log    Verificando velocidad downstream: ${velocidad_medida} Mbps (contratada: ${velocidad_contratada} Mbps)
    Should Be True    ${velocidad_medida} >= ${velocidad_contratada} * 0.8
    ...    La velocidad downstream ${velocidad_medida} Mbps está por debajo del 80% del SLA

Verificar Latencia
    [Documentation]    Verifica que la latencia está dentro del umbral aceptable.
    [Arguments]    ${latencia_ms}
    Log    Verificando latencia: ${latencia_ms} ms (máximo permitido: ${LATENCIA_MAXIMA} ms)
    Should Be True    ${latencia_ms} <= ${LATENCIA_MAXIMA}
    ...    Latencia ${latencia_ms} ms supera el máximo permitido de ${LATENCIA_MAXIMA} ms

Verificar Perdida De Paquetes
    [Documentation]    Verifica que la pérdida de paquetes está dentro del umbral.
    [Arguments]    ${porcentaje_perdida}
    Log    Verificando pérdida de paquetes: ${porcentaje_perdida}% (máximo: ${PAQUETES_PERDIDOS_MAX}%)
    Should Be True    ${porcentaje_perdida} <= ${PAQUETES_PERDIDOS_MAX}
    ...    Pérdida de paquetes ${porcentaje_perdida}% supera el umbral de ${PAQUETES_PERDIDOS_MAX}%

Verificar DNS Resuelve Correctamente
    [Documentation]    Simula la verificación de resolución DNS post-activación.
    [Arguments]    ${resultado_dns}
    Log    Verificando resolución DNS: ${resultado_dns}
    Should Be Equal    ${resultado_dns}    OK
    ...    La resolución DNS falló con resultado: ${resultado_dns}

# ══════════════════════════════════════════════════════════════
# KEYWORD DE TEARDOWN CONDICIONAL
# ══════════════════════════════════════════════════════════════

Teardown Condicional De Activacion
    [Documentation]    Teardown inteligente: solo ejecuta rollback si el test falló
    ...                y el servicio fue activado previamente.
    [Arguments]    ${cliente_id}
    Log    Ejecutando teardown condicional para ${cliente_id}
    Run Keyword If Test Failed
    ...    Ejecutar Rollback Si Servicio Activo    ${cliente_id}
    Run Keyword If Test Passed
    ...    Log    Test completado exitosamente — no se requiere rollback

Ejecutar Rollback Si Servicio Activo
    [Documentation]    Ejecuta rollback solo si el servicio fue activado en este test.
    [Arguments]    ${cliente_id}
    Log    Test falló — verificando si se requiere rollback...
    ${servicio_esta_activo}=    Get Variable Value    ${SERVICIO_ACTIVADO}    ${FALSE}
    IF    ${servicio_esta_activo}
        Log    Servicio activo detectado — iniciando rollback    WARN
        Revertir Activacion De Servicio    ${cliente_id}
        Registrar Falla En Sistema De Monitoreo
        ...    ${cliente_id}
        ...    Test fallido con servicio parcialmente activado
    ELSE
        Log    Servicio no fue activado — rollback no necesario
    END
```

2. Guarda el archivo.

#### Salida esperada

El archivo `resources/telecom_keywords.resource` existe sin errores de sintaxis. En VS Code, el panel de problemas no muestra errores de indentación ni de sintaxis Robot Framework.

#### Verificación

Ejecuta una validación de sintaxis con `--dryrun`:

```bash
robot --dryrun --outputdir results resources/telecom_keywords.resource
```

> **Nota:** Este comando fallará porque un archivo Resource no es ejecutable directamente, pero no debe mostrar errores de sintaxis. La salida esperada incluye `ERROR: Suite 'Telecom Keywords' contains no tests or tasks.` — esto es **normal** para un archivo Resource.

---

### Paso 3 — Implementar el primer test case: verificación de errores esperados con `Run Keyword And Expect Error`

**Objetivo:** Crear test cases que usen `Run Keyword And Expect Error` para confirmar que el sistema rechaza correctamente entradas inválidas con los mensajes de error exactos definidos en las variables.

#### Instrucciones

1. Crea el archivo `tests/suite_activacion_robusta.robot`:

```robotframework
*** Settings ***
Documentation    Suite robusta de pruebas para el flujo de activación de servicios
...              TelcoDemo S.A. — Demuestra manejo avanzado de errores y recuperación
...
...              Conceptos aplicados:
...              - Run Keyword And Expect Error
...              - Run Keyword And Continue On Failure
...              - Run Keyword If Test Failed / Test Passed
...              - Test Teardown con lógica condicional
Resource         ../resources/telecom_keywords.resource
Library          BuiltIn

Suite Setup      Log    Iniciando suite de pruebas de activación robusta TelcoDemo    console=True
Suite Teardown   Log    Suite de pruebas finalizada — revisar log.html para detalles    console=True

*** Test Cases ***

# ══════════════════════════════════════════════════════════════
# GRUPO 1: Verificación de errores esperados (Run Keyword And Expect Error)
# ══════════════════════════════════════════════════════════════

TC-01 Verificar Rechazo De Cliente Invalido
    [Documentation]    Confirma que el sistema rechaza un ID de cliente inválido
    ...                con el mensaje de error exacto esperado.
    ...                Usa Run Keyword And Expect Error para capturar el error.
    [Tags]    errores-esperados    validacion-cliente
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-01: Verificando rechazo de cliente inválido ===
    Log    Se intentará activar servicio con ID de cliente inválido: CLI-INVALIDO

    # Run Keyword And Expect Error captura el error y verifica el mensaje exacto
    # Si la keyword NO falla, o falla con un mensaje DIFERENTE, este test falla
    Run Keyword And Expect Error
    ...    ${MSG_CLIENTE_INVALIDO}
    ...    Validar Cliente    CLI-INVALIDO

    Log    CORRECTO: El sistema rechazó al cliente inválido con el mensaje esperado

TC-02 Verificar Rechazo De Plan Inexistente
    [Documentation]    Confirma que el sistema rechaza un plan de servicio que no
    ...                existe en el catálogo, verificando el mensaje exacto.
    [Tags]    errores-esperados    validacion-plan
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-02: Verificando rechazo de plan inexistente ===

    Run Keyword And Expect Error
    ...    ${MSG_PLAN_INVALIDO}
    ...    Validar Plan De Servicio    PLAN_INEXISTENTE

    Log    CORRECTO: El sistema rechazó el plan inexistente con el mensaje esperado

TC-03 Verificar Rechazo De Velocidad Negativa
    [Documentation]    Confirma que el sistema rechaza una velocidad negativa
    ...                en la validación de parámetros de servicio.
    [Tags]    errores-esperados    validacion-velocidad
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-03: Verificando rechazo de velocidad negativa ===
    Log    Intentando configurar velocidad: -50 Mbps (valor inválido)

    Run Keyword And Expect Error
    ...    ${MSG_VELOCIDAD_FUERA_RANGO}
    ...    Validar Velocidad De Servicio    ${-50}

    Log    CORRECTO: El sistema rechazó la velocidad negativa con el mensaje esperado

TC-04 Verificar Rechazo De Transicion De Estado Invalida
    [Documentation]    Confirma que el sistema rechaza la transición ACTIVO -> PENDIENTE
    ...                que es una operación no permitida por las reglas de negocio.
    [Tags]    errores-esperados    validacion-estado
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-04: Verificando rechazo de transición de estado inválida ===

    Run Keyword And Expect Error
    ...    ${MSG_ESTADO_INVALIDO}
    ...    Validar Transicion De Estado    ACTIVO    PENDIENTE

    Log    CORRECTO: El sistema rechazó la transición inválida con el mensaje esperado
```

2. Guarda el archivo (aún no está completo; se añadirán más test cases en los pasos siguientes).

#### Salida esperada

El archivo se guarda sin errores de sintaxis visibles en VS Code.

#### Verificación

Ejecuta únicamente el primer grupo de tests con la etiqueta `errores-esperados`:

```bash
robot --include errores-esperados --outputdir results tests/suite_activacion_robusta.robot
```

**Resultado esperado en consola:**

```
==============================================================================
Suite Activacion Robusta
==============================================================================
TC-01 Verificar Rechazo De Cliente Invalido                           | PASS |
TC-02 Verificar Rechazo De Plan Inexistente                           | PASS |
TC-03 Verificar Rechazo De Velocidad Negativa                         | PASS |
TC-04 Verificar Rechazo De Transicion De Estado Invalida              | PASS |
==============================================================================
Suite Activacion Robusta                                              | PASS |
4 tests, 4 passed, 0 failed
```

> **Punto de reflexión:** Los cuatro tests pasan porque `Run Keyword And Expect Error` "consume" el error. Si el mensaje de error no coincide exactamente con el esperado, el test **fallará**. Esto es precisamente lo que queremos: verificar que el sistema falla de la forma correcta.

---

### Paso 4 — Implementar test cases con `Run Keyword And Continue On Failure` para validaciones múltiples

**Objetivo:** Agregar test cases que ejecuten múltiples validaciones independientes dentro de un mismo test case, acumulando todas las fallas en el reporte sin detener la ejecución al primer error.

#### Instrucciones

1. Abre `tests/suite_activacion_robusta.robot` y agrega los siguientes test cases **después de TC-04**:

```robotframework
# ══════════════════════════════════════════════════════════════
# GRUPO 2: Validaciones múltiples con Continue On Failure
# ══════════════════════════════════════════════════════════════

TC-05 Validar Calidad De Servicio Post-Activacion Con Multiples Metricas
    [Documentation]    Activa el servicio y luego verifica múltiples métricas de calidad
    ...                de forma independiente. Usa Run Keyword And Continue On Failure
    ...                para que TODAS las métricas sean verificadas incluso si alguna falla.
    ...
    ...                COMPORTAMIENTO ESPERADO: Este test FALLA porque la latencia
    ...                (75ms) y la pérdida de paquetes (0.08%) superan los umbrales.
    ...                Sin embargo, TODAS las verificaciones se ejecutan y reportan.
    [Tags]    continue-on-failure    calidad-servicio
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-05: Validación de calidad de servicio con múltiples métricas ===

    # Paso 1: Activar el servicio (operación crítica — si falla, detiene el test)
    Log    Paso 1: Activando servicio para el cliente...
    Activar Servicio Para Cliente    ${CLIENTE_ID}    ${CLIENTE_PLAN}
    Log    Servicio activado. Iniciando verificaciones de calidad...

    # Paso 2: Verificar métricas de calidad (no críticas — se acumulan los errores)
    # Simulamos métricas medidas: algunas correctas, algunas con problemas
    Log    Paso 2: Verificando métricas de calidad de forma independiente...

    # Esta verificación PASA (velocidad 420 Mbps >= 80% de 500 Mbps = 400 Mbps)
    Run Keyword And Continue On Failure
    ...    Verificar Velocidad Downstream    ${420}    ${500}

    # Esta verificación FALLA (latencia 75ms > máximo 50ms)
    Run Keyword And Continue On Failure
    ...    Verificar Latencia    ${75}

    # Esta verificación FALLA (pérdida 0.08% > máximo 0.05%)
    Run Keyword And Continue On Failure
    ...    Verificar Perdida De Paquetes    ${0.08}

    # Esta verificación PASA (DNS responde OK)
    Run Keyword And Continue On Failure
    ...    Verificar DNS Resuelve Correctamente    OK

    Log    Todas las verificaciones de calidad completadas — revisar log.html para detalles

TC-06 Validar Calidad De Servicio Optimo
    [Documentation]    Verifica métricas de calidad con valores que cumplen todos los SLAs.
    ...                Todas las verificaciones deben pasar.
    ...                COMPORTAMIENTO ESPERADO: Este test PASA completamente.
    [Tags]    continue-on-failure    calidad-servicio    camino-feliz
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-06: Validación de servicio óptimo (todos los SLAs cumplidos) ===

    # Activar servicio
    Activar Servicio Para Cliente    ${CLIENTE_ID}    ${CLIENTE_PLAN}

    # Verificar métricas óptimas — todas deben pasar
    Run Keyword And Continue On Failure
    ...    Verificar Velocidad Downstream    ${490}    ${500}

    Run Keyword And Continue On Failure
    ...    Verificar Latencia    ${25}

    Run Keyword And Continue On Failure
    ...    Verificar Perdida De Paquetes    ${0.01}

    Run Keyword And Continue On Failure
    ...    Verificar DNS Resuelve Correctamente    OK

    Log    === Servicio verificado: TODOS los SLAs cumplidos ===

TC-07 Validar Multiples Planes Con Errores Mixtos
    [Documentation]    Verifica la validación de múltiples planes en una sola ejecución.
    ...                Mezcla planes válidos e inválidos para demostrar que Continue On Failure
    ...                permite reportar todos los problemas en una sola pasada.
    ...                COMPORTAMIENTO ESPERADO: Este test FALLA por los planes inválidos,
    ...                pero TODOS los planes son evaluados.
    [Tags]    continue-on-failure    validacion-plan    data-driven-manual
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-07: Validación de múltiples planes (mezcla válidos/inválidos) ===
    Log    Verificando catálogo de planes para migración masiva de clientes...

    # Plan válido — PASA
    Run Keyword And Continue On Failure
    ...    Validar Plan De Servicio    PLAN_FIBRA_100

    # Plan inválido — FALLA (acumulado, no detiene el test)
    Run Keyword And Continue On Failure
    ...    Validar Plan De Servicio    PLAN_COAXIAL_LEGACY

    # Plan válido — PASA
    Run Keyword And Continue On Failure
    ...    Validar Plan De Servicio    PLAN_MOVIL_PRO

    # Plan inválido — FALLA (acumulado)
    Run Keyword And Continue On Failure
    ...    Validar Plan De Servicio    PLAN_SATELITAL_BETA

    # Plan válido — PASA
    Run Keyword And Continue On Failure
    ...    Validar Plan De Servicio    PLAN_FIBRA_1000

    Log    Revisión de catálogo completada — 2 planes inválidos detectados (ver log.html)
```

2. Guarda el archivo.

#### Salida esperada

Al ejecutar el grupo `continue-on-failure`, TC-05 y TC-07 fallan pero **completan toda su ejecución**. TC-06 pasa completamente.

#### Verificación

```bash
robot --include continue-on-failure --outputdir results tests/suite_activacion_robusta.robot
```

**Resultado esperado en consola:**

```
TC-05 Validar Calidad De Servicio Post-Activacion Con Multiples Metricas | FAIL |
Several failures occurred:
1) Latencia 75 ms supera el máximo permitido de 50 ms
2) Pérdida de paquetes 0.08% supera el umbral de 0.05%

TC-06 Validar Calidad De Servicio Optimo                               | PASS |

TC-07 Validar Multiples Planes Con Errores Mixtos                      | FAIL |
Several failures occurred:
1) Plan de servicio no reconocido: PLAN_COAXIAL_LEGACY
2) Plan de servicio no reconocido: PLAN_SATELITAL_BETA
```

> **Observación clave:** Nota la frase **"Several failures occurred"** en el reporte. Esta es la señal visual de que `Run Keyword And Continue On Failure` acumuló múltiples fallas. Ábrela en `log.html` para ver cada falla listada individualmente.

---

### Paso 5 — Implementar el Test Teardown con lógica condicional

**Objetivo:** Verificar el comportamiento del `Test Teardown` condicional ya implementado en `telecom_keywords.resource`, y agregar un test case que demuestre explícitamente el rollback cuando el test falla con el servicio parcialmente activado.

#### Instrucciones

1. Agrega los siguientes test cases al final de `tests/suite_activacion_robusta.robot`:

```robotframework
# ══════════════════════════════════════════════════════════════
# GRUPO 3: Teardown condicional y recuperación del sistema
# ══════════════════════════════════════════════════════════════

TC-08 Falla Critica Despues De Activacion Requiere Rollback
    [Documentation]    Demuestra el mecanismo de rollback en Teardown.
    ...                El servicio se activa exitosamente, pero luego ocurre
    ...                una falla crítica que detiene el test.
    ...                El Teardown detecta que el test falló Y que el servicio
    ...                está activo, y ejecuta el rollback automáticamente.
    ...
    ...                COMPORTAMIENTO ESPERADO:
    ...                - El test FALLA (intencionalmente)
    ...                - El Teardown ejecuta el rollback (visible en log.html)
    ...                - El sistema queda en estado limpio
    [Tags]    teardown-condicional    rollback
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-08: Falla crítica post-activación con rollback automático ===

    # Paso 1: Activación exitosa
    Log    Paso 1: Activando servicio...
    Activar Servicio Para Cliente    ${CLIENTE_ID}    ${CLIENTE_PLAN}
    Log    Servicio activado exitosamente. Estado: ${SERVICIO_ACTIVADO}

    # Paso 2: Validaciones previas a la falla
    Log    Paso 2: Ejecutando validaciones post-activación...
    Validar Velocidad De Servicio    ${500}
    Validar Transicion De Estado    ${ESTADO_PENDIENTE}    ${ESTADO_ACTIVO}

    # Paso 3: Falla crítica simulada (detiene el test inmediatamente)
    Log    Paso 3: Detectando condición crítica en el sistema...    WARN
    Fail
    ...    ERROR CRÍTICO: Fallo en el sistema de facturación post-activación — rollback requerido

TC-09 Activacion Exitosa Sin Rollback En Teardown
    [Documentation]    Demuestra que el Teardown NO ejecuta rollback cuando el test pasa.
    ...                Verifica el comportamiento de Run Keyword If Test Passed.
    ...
    ...                COMPORTAMIENTO ESPERADO:
    ...                - El test PASA completamente
    ...                - El Teardown registra éxito pero NO ejecuta rollback
    [Tags]    teardown-condicional    camino-feliz
    [Teardown]    Teardown Condicional De Activacion    ${CLIENTE_ID}

    Log    === TC-09: Activación exitosa — Teardown no debe ejecutar rollback ===

    Activar Servicio Para Cliente    ${CLIENTE_ID}    ${CLIENTE_PLAN}
    Validar Velocidad De Servicio    ${500}
    Validar Transicion De Estado    ${ESTADO_PENDIENTE}    ${ESTADO_ACTIVO}

    Log    Activación completada sin errores — Teardown solo registrará éxito

TC-10 Falla Antes De Activacion No Requiere Rollback
    [Documentation]    Demuestra que el Teardown NO ejecuta rollback cuando el test
    ...                falla ANTES de que el servicio sea activado.
    ...                La variable SERVICIO_ACTIVADO permanece en FALSE.
    ...
    ...                COMPORTAMIENTO ESPERADO:
    ...                - El test FALLA (por cliente inválido)
    ...                - El Teardown detecta que el servicio NO fue activado
    ...                - No se ejecuta rollback (no hay nada que revertir)
    [Tags]    teardown-condicional    rollback    errores-esperados
    [Teardown]    Teardown Condicional De Activacion    CLI-INVALIDO

    Log    === TC-10: Falla antes de activación — rollback no debe ejecutarse ===
    Log    Intentando activar servicio con cliente inválido...

    # Esta llamada falla inmediatamente — SERVICIO_ACTIVADO nunca se establece en TRUE
    Activar Servicio Para Cliente    CLI-INVALIDO    ${CLIENTE_PLAN}

    Log    Esta línea NUNCA se ejecuta porque la anterior falla
```

2. Guarda el archivo.

#### Salida esperada

Los tres test cases se agregan sin errores de sintaxis.

#### Verificación

```bash
robot --include teardown-condicional --outputdir results tests/suite_activacion_robusta.robot
```

**Resultado esperado en consola:**

```
TC-08 Falla Critica Despues De Activacion Requiere Rollback            | FAIL |
ERROR CRÍTICO: Fallo en el sistema de facturación post-activación — rollback requerido

TC-09 Activacion Exitosa Sin Rollback En Teardown                      | PASS |

TC-10 Falla Antes De Activacion No Requiere Rollback                   | FAIL |
Cliente no encontrado: CLI-INVALIDO
```

Abre `results/log.html` y verifica que:
- En **TC-08**: el Teardown muestra los mensajes `*** ROLLBACK: Revirtiendo activación...` y `Rollback completado`.
- En **TC-09**: el Teardown muestra `Test completado exitosamente — no se requiere rollback`.
- En **TC-10**: el Teardown muestra `Servicio no fue activado — rollback no necesario`.

---

### Paso 6 — Ejecutar la suite completa y analizar el reporte

**Objetivo:** Ejecutar todos los test cases en una sola pasada y analizar el reporte HTML para comprender la diferencia entre fallas críticas y no críticas.

#### Instrucciones

1. Ejecuta la suite completa con un nombre de reporte descriptivo:

```bash
robot --outputdir results \
      --log log_suite_robusta.html \
      --report report_suite_robusta.html \
      --output output_suite_robusta.xml \
      tests/suite_activacion_robusta.robot
```

> **Windows (cmd) — usa `^` para continuar en la siguiente línea:**

```cmd
robot --outputdir results ^
      --log log_suite_robusta.html ^
      --report report_suite_robusta.html ^
      --output output_suite_robusta.xml ^
      tests\suite_activacion_robusta.robot
```

2. Observa el resumen en consola. Deberías ver algo similar a:

```
==============================================================================
Suite Activacion Robusta
==============================================================================
TC-01 Verificar Rechazo De Cliente Invalido                           | PASS |
TC-02 Verificar Rechazo De Plan Inexistente                           | PASS |
TC-03 Verificar Rechazo De Velocidad Negativa                         | PASS |
TC-04 Verificar Rechazo De Transicion De Estado Invalida              | PASS |
TC-05 Validar Calidad De Servicio Post-Activacion Con Multiples ...   | FAIL |
TC-06 Validar Calidad De Servicio Optimo                              | PASS |
TC-07 Validar Multiples Planes Con Errores Mixtos                     | FAIL |
TC-08 Falla Critica Despues De Activacion Requiere Rollback           | FAIL |
TC-09 Activacion Exitosa Sin Rollback En Teardown                     | PASS |
TC-10 Falla Antes De Activacion No Requiere Rollback                  | FAIL |
==============================================================================
Suite Activacion Robusta                                              | FAIL |
10 tests, 5 passed, 5 failed
```

3. Abre `results/log_suite_robusta.html` en tu navegador.

4. Realiza las siguientes observaciones en el log:

   **a) Observación en TC-05:** Expande el test case y verifica que aparecen **exactamente 2 entradas de falla** bajo la sección "Several failures occurred". Confirma que las keywords `Verificar Velocidad Downstream` y `Verificar DNS Resuelve Correctamente` aparecen en verde (PASS) mientras que `Verificar Latencia` y `Verificar Perdida De Paquetes` aparecen en rojo (FAIL).

   **b) Observación en TC-08:** Expande la sección **Teardown** del test case. Verifica que aparece la secuencia completa de rollback: mensajes de desaprovisionamiento, liberación de IP y limpieza de registros.

   **c) Observación en TC-10:** Expande el Teardown y confirma que aparece el mensaje `Servicio no fue activado — rollback no necesario`, sin ningún mensaje de rollback.

#### Salida esperada

El archivo `results/log_suite_robusta.html` se abre correctamente en el navegador y muestra los 10 test cases con sus respectivos estados y detalles de ejecución.

#### Verificación

```bash
# Verifica que los archivos de reporte fueron generados
# ── Windows (cmd) ──────────────────────────────────────────────
dir results\

# ── macOS / Linux ──────────────────────────────────────────────
ls -la results/
```

Debes ver al menos:
- `log_suite_robusta.html`
- `report_suite_robusta.html`
- `output_suite_robusta.xml`

---

## Validación y Pruebas

### Lista de verificación final

Completa la siguiente lista de verificación antes de dar por finalizado el laboratorio. Cada ítem debe poder verificarse directamente en `log.html`:

| # | Verificación | Cómo confirmarlo |
|---|---|---|
| 1 | TC-01 al TC-04 pasan usando `Run Keyword And Expect Error` | Estado PASS en report.html, sin errores en log |
| 2 | TC-05 muestra "Several failures occurred" con exactamente 2 fallas | Expandir TC-05 en log.html |
| 3 | TC-05 ejecutó las 4 verificaciones (2 PASS + 2 FAIL) | Contar entradas verdes y rojas en TC-05 |
| 4 | TC-06 pasa completamente con todas las métricas en verde | Estado PASS + 4 entradas verdes en TC-06 |
| 5 | TC-07 muestra exactamente 2 fallas de planes inválidos | Expandir TC-07, contar fallas rojas |
| 6 | TC-08 Teardown muestra la secuencia completa de rollback | Expandir sección Teardown de TC-08 |
| 7 | TC-09 Teardown muestra "no se requiere rollback" | Expandir sección Teardown de TC-09 |
| 8 | TC-10 Teardown muestra "rollback no necesario" (sin rollback ejecutado) | Expandir sección Teardown de TC-10 |
| 9 | El resumen final es: 10 tests, 5 passed, 5 failed | Encabezado de report.html |
| 10 | Ningún test case muestra estado "ERROR" (solo PASS o FAIL) | Columna de estado en report.html |

### Prueba de regresión: verificar que el mensaje de error importa

Ejecuta el siguiente comando para confirmar que `Run Keyword And Expect Error` falla cuando el mensaje NO coincide. Crea temporalmente un archivo de prueba:

```bash
# ── macOS / Linux ──────────────────────────────────────────────
cat > /tmp/test_mensaje_incorrecto.robot << 'EOF'
*** Settings ***
Resource    resources/telecom_keywords.resource

*** Test Cases ***
TC-REGRESION Mensaje De Error Incorrecto Debe Fallar El Test
    [Documentation]    Este test DEBE fallar porque el mensaje esperado
    ...                no coincide con el mensaje real del sistema.
    Run Keyword And Expect Error
    ...    Este mensaje NO es el correcto
    ...    Validar Cliente    CLI-INVALIDO
EOF
robot --outputdir results /tmp/test_mensaje_incorrecto.robot

# ── Windows (cmd) — crea el archivo manualmente en VS Code y ejecuta:
robot --outputdir results tests\test_mensaje_incorrecto.robot
```

**Resultado esperado:** El test falla con un mensaje similar a:

```
Expected error message 'Este mensaje NO es el correcto' but got
'Cliente no encontrado: CLI-INVALIDO'
```

Esto confirma que `Run Keyword And Expect Error` verifica el mensaje con precisión exacta.

---

## Solución de Problemas

### Problema 1: `Run Keyword And Expect Error` falla con "Expected error message ... but got ..."

**Síntoma:** Un test case del Grupo 1 (TC-01 al TC-04) falla con un mensaje como:
```
Expected error message 'Cliente no encontrado: CLI-INVALIDO' but got
'AssertionError: Cliente no encontrado: CLI-INVALIDO'
```

**Causa:** Robot Framework a veces antepone el tipo de excepción Python (`AssertionError:`) al mensaje cuando la keyword usa `Fail` internamente. La versión de RF o la forma en que se lanza el error puede incluir o no este prefijo.

**Solución:** Usa el comodín `*` al inicio del mensaje esperado para ignorar el prefijo:

```robotframework
# En lugar de:
Run Keyword And Expect Error
...    Cliente no encontrado: CLI-INVALIDO
...    Validar Cliente    CLI-INVALIDO

# Usa el comodín:
Run Keyword And Expect Error
...    *Cliente no encontrado: CLI-INVALIDO
...    Validar Cliente    CLI-INVALIDO
```

Alternativamente, actualiza la variable en `telecom_variables.resource`:

```robotframework
${MSG_CLIENTE_INVALIDO}    *Cliente no encontrado: CLI-INVALIDO
```

El asterisco `*` al inicio indica que el mensaje puede comenzar con cualquier texto antes de la cadena especificada.

---

### Problema 2: El Teardown no ejecuta el rollback en TC-08 aunque el test falló

**Síntoma:** En `log.html`, el Teardown de TC-08 muestra el mensaje `Servicio no fue activado — rollback no necesario` en lugar de la secuencia de rollback, a pesar de que el test falló después de activar el servicio.

**Causa:** La variable `${SERVICIO_ACTIVADO}` no se propagó correctamente al scope del test case. Esto ocurre cuando `Set Test Variable` se llama desde dentro de una keyword anidada y la variable no se establece en el scope correcto, o cuando el test se ejecuta de forma aislada sin que `${SERVICIO_ACTIVADO}` tenga un valor inicial definido.

**Solución:** Verifica que la keyword `Activar Servicio Para Cliente` use explícitamente `Set Test Variable` (no `Set Variable`):

```robotframework
# CORRECTO — usa Set Test Variable para que sea visible en el Teardown
Set Test Variable    ${SERVICIO_ACTIVADO}    ${TRUE}

# INCORRECTO — Set Variable solo crea una variable local a la keyword
${SERVICIO_ACTIVADO}=    Set Variable    ${TRUE}
```

Además, verifica que `Get Variable Value` en `Ejecutar Rollback Si Servicio Activo` usa el valor por defecto `${FALSE}` como tercer argumento para evitar errores si la variable nunca fue establecida:

```robotframework
${servicio_esta_activo}=    Get Variable Value    ${SERVICIO_ACTIVADO}    ${FALSE}
```

Si el problema persiste, agrega un `Log Variables` al inicio del Teardown para inspeccionar el estado de todas las variables disponibles en ese momento.

---

## Limpieza

Una vez completado el laboratorio y verificada la lista de verificación, ejecuta los siguientes pasos de limpieza:

1. **Elimina archivos temporales de prueba** (si los creaste):

```bash
# ── macOS / Linux ──────────────────────────────────────────────
rm -f /tmp/test_mensaje_incorrecto.robot

# ── Windows (cmd) ──────────────────────────────────────────────
del tests\test_mensaje_incorrecto.robot
```

2. **Archiva los resultados** para referencia futura:

```bash
# ── macOS / Linux ──────────────────────────────────────────────
cp -r results results_backup_lab03_02

# ── Windows (cmd) ──────────────────────────────────────────────
xcopy results results_backup_lab03_02 /E /I
```

3. **Desactiva el entorno virtual** al finalizar la sesión:

```bash
deactivate
```

4. **Crea una copia de respaldo del proyecto completo** (recomendado antes del siguiente módulo):

```bash
# ── macOS / Linux ──────────────────────────────────────────────
cd ..
cp -r lab_03_02 lab_03_02_BACKUP_$(date +%Y%m%d)

# ── Windows (cmd) ──────────────────────────────────────────────
cd ..
xcopy lab_03_02 lab_03_02_BACKUP /E /I
```

> **Recordatorio:** El proyecto `lab_03_02` puede ser requerido como base para laboratorios del Módulo 4. Mantén la copia de respaldo accesible.

---

## Resumen

En este laboratorio construiste una suite de prueba robusta para un flujo de activación de servicios de telecomunicaciones, aplicando tres mecanismos avanzados de manejo de errores de Robot Framework:

| Mecanismo | Cuándo usarlo | Efecto en el test |
|---|---|---|
| `Run Keyword And Expect Error` | Verificar que el sistema rechaza entradas inválidas con el mensaje correcto | El test **pasa** si el error coincide; **falla** si no hay error o el mensaje difiere |
| `Run Keyword And Continue On Failure` | Ejecutar múltiples validaciones independientes en un mismo test | El test **acumula** fallas y las reporta todas; no se detiene ante la primera |
| `Run Keyword If Test Failed` en Teardown | Ejecutar lógica de limpieza condicional post-falla | El rollback solo se ejecuta cuando es necesario, evitando efectos secundarios |

### Conceptos clave consolidados

- **Falla crítica vs. no crítica:** Una falla crítica (keyword sin `Continue On Failure`) detiene el test inmediatamente. Una falla no crítica (envuelta en `Run Keyword And Continue On Failure`) se acumula y el test continúa.
- **El Teardown siempre se ejecuta:** Independientemente del resultado del test case, el `Test Teardown` se ejecuta. La lógica condicional con `Run Keyword If Test Failed` permite decidir **qué hacer** dentro del Teardown según ese resultado.
- **`Get Variable Value` con valor por defecto:** Es una práctica defensiva esencial en Teardowns para evitar errores cuando una variable puede no haber sido establecida si el test falló antes de alcanzar ese punto.
- **Mensajes de error exactos:** `Run Keyword And Expect Error` verifica el mensaje con precisión. El comodín `*` al inicio permite ignorar prefijos variables del tipo de excepción.

### Recursos adicionales

- [Documentación oficial: BuiltIn — Run Keyword And Expect Error](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Run%20Keyword%20And%20Expect%20Error)
- [Documentación oficial: BuiltIn — Run Keyword And Continue On Failure](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Run%20Keyword%20And%20Continue%20On%20Failure)
- [Documentación oficial: BuiltIn — Run Keyword If Test Failed](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Run%20Keyword%20If%20Test%20Failed)
- [Guía del usuario RF: Test Setup y Teardown](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#test-setup-and-teardown)
- [Guía del usuario RF: Continuar en caso de fallo](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#continuing-on-failure)

---

