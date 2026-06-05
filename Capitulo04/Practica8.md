# Práctica 8: Refactorización de test tradicional a modelo BDD con separación de capas

## Metadatos

| Campo            | Valor                                      |
|------------------|--------------------------------------------|
| **Duración**     | 72 minutos                                 |
| **Complejidad**  | Alta                                       |
| **Nivel Bloom**  | Crear                                      |
| **Módulo**       | 4 — Behavior-Driven Development            |
| **Laboratorio**  | 04-00-02 (Práctica 8)                      |

---

## Descripción General

En este laboratorio recibirás una suite de pruebas tradicional (estilo keyword-driven) que valida un flujo de gestión de contratos de telecomunicaciones y la refactorizarás completamente al modelo BDD con arquitectura de tres capas. El proceso te llevará desde identificar los comportamientos de negocio detrás de cada test case técnico, redactar los escenarios Gherkin correspondientes, separar las responsabilidades en capas de abstracción, hasta verificar que ambas versiones producen exactamente los mismos resultados de ejecución. Al finalizar, habrás aplicado los principios de BDD presentados en la Lección 4.1 en un escenario realista de telecomunicaciones.

---

## Objetivos de Aprendizaje

Al finalizar este laboratorio serás capaz de:

- [ ] Refactorizar una suite de prueba tradicional a modelo BDD manteniendo la misma cobertura funcional en los 8 test cases originales.
- [ ] Implementar una arquitectura de tres capas: escenarios de negocio (Gherkin) → keywords de dominio → keywords técnicas.
- [ ] Garantizar que los escenarios BDD refactorizados son agnósticos a la implementación técnica subyacente.
- [ ] Comparar métricas de mantenibilidad y legibilidad entre el enfoque tradicional y el BDD refactorizado mediante comentarios documentados.

---

## Prerrequisitos

### Conocimiento previo

- Haber completado el Laboratorio 04-00-01 con escenarios BDD funcionales y sin errores.
- Comprensión sólida de archivos Resource y keywords parametrizadas (Módulo 2).
- Capacidad de leer y entender una suite existente de Robot Framework con keywords anidadas.
- Familiaridad con la sintaxis Gherkin nativa (`Given / When / Then / And / But`) en Robot Framework.

### Acceso y herramientas

- Entorno virtual Python (`venv`) activo con Robot Framework 7.x instalado.
- Visual Studio Code con la extensión Robot Framework Language Server activa.
- Proyecto del Laboratorio 04-00-01 disponible como referencia (no es necesario modificarlo).
- Terminal con permisos de escritura en el directorio de trabajo.

---

## Entorno del Laboratorio

### Requisitos de hardware

| Componente       | Mínimo requerido                                      |
|------------------|-------------------------------------------------------|
| Procesador       | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos)       |
| RAM              | 8 GB (16 GB recomendado)                              |
| Almacenamiento   | 5 GB libres para proyecto, reportes y artefactos      |
| Pantalla         | Resolución mínima 1280×768                            |

### Requisitos de software

| Software                        | Versión mínima |
|---------------------------------|----------------|
| Python                          | 3.10+          |
| Robot Framework                 | 7.x            |
| Visual Studio Code              | 1.85+          |
| RF Language Server (extensión)  | 1.12+          |
| pip                             | 23.x+          |

### Preparación del entorno

Ejecuta los siguientes comandos antes de comenzar. Usa la variante correspondiente a tu sistema operativo.

**Paso 1 — Activar el entorno virtual:**

```bash
# Windows (cmd)
cd C:\cursoRF\modulo04
Scripts\activate

# Windows (PowerShell)
cd C:\cursoRF\modulo04
.\Scripts\Activate.ps1

# macOS / Linux
cd ~/cursoRF/modulo04
source bin/activate
```

**Paso 2 — Verificar la versión de Robot Framework:**

```bash
robot --version
# Salida esperada: Robot Framework 7.x.x (Python 3.x.x ...)
```

**Paso 3 — Crear la estructura del laboratorio:**

```bash
# Windows (cmd / PowerShell)
mkdir lab04-00-02
cd lab04-00-02
mkdir traditional_suite
mkdir bdd_suite\features
mkdir bdd_suite\domain_keywords
mkdir bdd_suite\technical_keywords
mkdir results\traditional
mkdir results\bdd

# macOS / Linux
mkdir -p lab04-00-02
cd lab04-00-02
mkdir -p traditional_suite
mkdir -p bdd_suite/features
mkdir -p bdd_suite/domain_keywords
mkdir -p bdd_suite/technical_keywords
mkdir -p results/traditional
mkdir -p results/bdd
```

La estructura final del proyecto debe verse así:

```
lab04-00-02/
├── traditional_suite/
│   └── contract_management_traditional.robot
├── bdd_suite/
│   ├── features/
│   │   └── contract_management.robot
│   ├── domain_keywords/
│   │   └── contract_domain.resource
│   └── technical_keywords/
│       └── contract_technical.resource
└── results/
    ├── traditional/
    └── bdd/
```

---

## Desarrollo Paso a Paso

---

### Paso 1: Crear y analizar la suite tradicional de referencia

**Objetivo:** Establecer la suite tradicional pre-construida que servirá como punto de partida para la refactorización. Esta suite simula datos en memoria (sin UI ni API real) para que el laboratorio sea autocontenido.

#### Instrucciones

1. Abre Visual Studio Code en la carpeta `lab04-00-02`.
2. Crea el archivo `traditional_suite/contract_management_traditional.robot` con el siguiente contenido completo:

```robot
*** Settings ***
Documentation    Suite tradicional de gestión de contratos de telecomunicaciones.
...              Esta suite será refactorizada al modelo BDD en el laboratorio 04-00-02.
...              NOTA: Los datos son ficticios y autocontenidos. No se requiere conexión externa.
Library          Collections
Library          String
Library          BuiltIn

*** Variables ***
# --- Datos de clientes ficticios ---
${CLIENTE_VALIDO_ID}          CLI-001
${CLIENTE_VALIDO_NOMBRE}      Ana García
${CLIENTE_INVALIDO_ID}        CLI-999
${PLAN_BASICO}                PLAN-DATOS-10GB
${PLAN_PREMIUM}               PLAN-DATOS-50GB
${PLAN_INVALIDO}              PLAN-INEXISTENTE
${CONTRATO_ACTIVO_ID}         CONT-2024-001
${CONTRATO_CANCELADO_ID}      CONT-2024-002
${LIMITE_CREDITO_APROBADO}    500
${LIMITE_CREDITO_RECHAZADO}   50

*** Test Cases ***
TC-001 Verificar que un cliente válido puede ser encontrado en el sistema
    [Documentation]    Verifica la búsqueda de un cliente existente por ID.
    [Tags]    cliente    busqueda    smoke
    ${resultado}=    Buscar Cliente Por ID    ${CLIENTE_VALIDO_ID}
    Should Not Be Empty    ${resultado}
    Dictionary Should Contain Key    ${resultado}    nombre
    Should Be Equal    ${resultado}[nombre]    ${CLIENTE_VALIDO_NOMBRE}
    Log    Cliente encontrado: ${resultado}[nombre]

TC-002 Verificar que un cliente inválido genera error controlado
    [Documentation]    Verifica que buscar un ID inexistente retorna estado de error.
    [Tags]    cliente    busqueda    negativo
    ${resultado}=    Buscar Cliente Por ID    ${CLIENTE_INVALIDO_ID}
    Dictionary Should Contain Key    ${resultado}    error
    Should Be Equal    ${resultado}[error]    CLIENTE_NO_ENCONTRADO
    Log    Error esperado recibido: ${resultado}[error]

TC-003 Verificar que un cliente puede contratar un plan de datos válido
    [Documentation]    Verifica la contratación exitosa de un plan de datos.
    [Tags]    contrato    alta    smoke
    ${cliente}=    Buscar Cliente Por ID    ${CLIENTE_VALIDO_ID}
    ${plan}=       Obtener Detalle Plan    ${PLAN_BASICO}
    ${contrato}=   Crear Contrato    ${cliente}    ${plan}
    Dictionary Should Contain Key    ${contrato}    id_contrato
    Should Be Equal    ${contrato}[estado]    ACTIVO
    Should Be Equal    ${contrato}[plan]      ${PLAN_BASICO}
    Log    Contrato creado: ${contrato}[id_contrato]

TC-004 Verificar que no se puede contratar un plan inexistente
    [Documentation]    Verifica que intentar contratar un plan inválido falla correctamente.
    [Tags]    contrato    alta    negativo
    ${cliente}=    Buscar Cliente Por ID    ${CLIENTE_VALIDO_ID}
    ${plan}=       Obtener Detalle Plan    ${PLAN_INVALIDO}
    Dictionary Should Contain Key    ${plan}    error
    Should Be Equal    ${plan}[error]    PLAN_NO_ENCONTRADO
    Log    Error esperado al buscar plan inválido: ${plan}[error]

TC-005 Verificar que un contrato activo puede ser consultado correctamente
    [Documentation]    Verifica la consulta de un contrato activo existente.
    [Tags]    contrato    consulta    smoke
    ${contrato}=    Consultar Contrato    ${CONTRATO_ACTIVO_ID}
    Should Be Equal    ${contrato}[estado]         ACTIVO
    Should Be Equal    ${contrato}[cliente_id]     ${CLIENTE_VALIDO_ID}
    Dictionary Should Contain Key    ${contrato}   fecha_inicio
    Log    Estado del contrato: ${contrato}[estado]

TC-006 Verificar que un contrato cancelado tiene estado correcto
    [Documentation]    Verifica que un contrato cancelado refleja el estado CANCELADO.
    [Tags]    contrato    consulta    negativo
    ${contrato}=    Consultar Contrato    ${CONTRATO_CANCELADO_ID}
    Should Be Equal    ${contrato}[estado]    CANCELADO
    Log    Contrato cancelado confirmado: ${contrato}[estado]

TC-007 Verificar que un cliente con crédito suficiente puede actualizar su plan
    [Documentation]    Verifica el upgrade de plan cuando el cliente tiene crédito aprobado.
    [Tags]    contrato    upgrade    smoke
    ${cliente}=       Buscar Cliente Por ID       ${CLIENTE_VALIDO_ID}
    ${credito_ok}=    Verificar Credito Cliente   ${cliente}    ${LIMITE_CREDITO_APROBADO}
    Should Be True    ${credito_ok}
    ${resultado}=     Actualizar Plan Contrato    ${CONTRATO_ACTIVO_ID}    ${PLAN_PREMIUM}
    Should Be Equal   ${resultado}[nuevo_plan]    ${PLAN_PREMIUM}
    Should Be Equal   ${resultado}[estado]        ACTUALIZADO
    Log    Plan actualizado a: ${resultado}[nuevo_plan]

TC-008 Verificar que un cliente sin crédito suficiente no puede actualizar su plan
    [Documentation]    Verifica que el upgrade de plan es rechazado por crédito insuficiente.
    [Tags]    contrato    upgrade    negativo
    ${cliente}=       Buscar Cliente Por ID       ${CLIENTE_VALIDO_ID}
    ${credito_ok}=    Verificar Credito Cliente   ${cliente}    ${LIMITE_CREDITO_RECHAZADO}
    Should Not Be True    ${credito_ok}
    Log    Actualización de plan rechazada por crédito insuficiente.

*** Keywords ***
Buscar Cliente Por ID
    [Documentation]    Simula la búsqueda de un cliente en el sistema por su ID.
    [Arguments]    ${id_cliente}
    # Simulación de base de datos en memoria
    ${clientes}=    Create Dictionary
    ...    CLI-001={"nombre": "Ana García", "estado": "ACTIVO", "credito_disponible": 800}
    Run Keyword If    '${id_cliente}' == 'CLI-001'
    ...    Return From Keyword    &{{"nombre": "Ana García", "estado": "ACTIVO", "id": "CLI-001"}}
    ${error}=    Create Dictionary    error=CLIENTE_NO_ENCONTRADO    id=${id_cliente}
    RETURN    ${error}

Obtener Detalle Plan
    [Documentation]    Simula la obtención de detalles de un plan de datos.
    [Arguments]    ${id_plan}
    Run Keyword If    '${id_plan}' == 'PLAN-DATOS-10GB'
    ...    Return From Keyword    &{{"nombre": "Datos 10GB", "precio": 250, "id": "PLAN-DATOS-10GB"}}
    Run Keyword If    '${id_plan}' == 'PLAN-DATOS-50GB'
    ...    Return From Keyword    &{{"nombre": "Datos 50GB Premium", "precio": 450, "id": "PLAN-DATOS-50GB"}}
    ${error}=    Create Dictionary    error=PLAN_NO_ENCONTRADO    id=${id_plan}
    RETURN    ${error}

Crear Contrato
    [Documentation]    Simula la creación de un nuevo contrato.
    [Arguments]    ${cliente}    ${plan}
    ${contrato}=    Create Dictionary
    ...    id_contrato=CONT-NEW-001
    ...    estado=ACTIVO
    ...    plan=${plan}[id]
    ...    cliente_id=${cliente}[id]
    ...    fecha_inicio=2024-01-15
    RETURN    ${contrato}

Consultar Contrato
    [Documentation]    Simula la consulta de un contrato por ID.
    [Arguments]    ${id_contrato}
    Run Keyword If    '${id_contrato}' == 'CONT-2024-001'
    ...    Return From Keyword    &{{"id_contrato": "CONT-2024-001", "estado": "ACTIVO", "cliente_id": "CLI-001", "fecha_inicio": "2024-01-01"}}
    Run Keyword If    '${id_contrato}' == 'CONT-2024-002'
    ...    Return From Keyword    &{{"id_contrato": "CONT-2024-002", "estado": "CANCELADO", "cliente_id": "CLI-001", "fecha_inicio": "2023-06-01"}}
    ${error}=    Create Dictionary    error=CONTRATO_NO_ENCONTRADO    id=${id_contrato}
    RETURN    ${error}

Verificar Credito Cliente
    [Documentation]    Verifica si el cliente tiene crédito disponible suficiente.
    [Arguments]    ${cliente}    ${monto_requerido}
    # Crédito disponible fijo de 500 para el cliente de prueba
    ${credito_disponible}=    Set Variable    ${500}
    ${tiene_credito}=    Evaluate    ${credito_disponible} >= ${monto_requerido}
    RETURN    ${tiene_credito}

Actualizar Plan Contrato
    [Documentation]    Simula la actualización del plan de un contrato existente.
    [Arguments]    ${id_contrato}    ${nuevo_plan_id}
    ${resultado}=    Create Dictionary
    ...    id_contrato=${id_contrato}
    ...    nuevo_plan=${nuevo_plan_id}
    ...    estado=ACTUALIZADO
    RETURN    ${resultado}
```

3. Guarda el archivo.

#### Salida esperada al abrir el archivo

VS Code debe mostrar el archivo sin errores de sintaxis y el Language Server debe reconocer las keywords resaltándolas correctamente.

#### Verificación

Ejecuta la suite tradicional para establecer la línea base:

```bash
# Desde la carpeta lab04-00-02
robot --outputdir results/traditional traditional_suite/contract_management_traditional.robot
```

Debes ver una salida similar a:

```
==============================================================================
Contract Management Traditional
==============================================================================
TC-001 Verificar que un cliente válido puede ser encontrado en el sistema  | PASS |
TC-002 Verificar que un cliente inválido genera error controlado           | PASS |
TC-003 Verificar que un cliente puede contratar un plan de datos válido    | PASS |
TC-004 Verificar que no se puede contratar un plan inexistente             | PASS |
TC-005 Verificar que un contrato activo puede ser consultado correctamente | PASS |
TC-006 Verificar que un contrato cancelado tiene estado correcto           | PASS |
TC-007 Verificar que un cliente con crédito suficiente puede actualizar    | PASS |
TC-008 Verificar que un cliente sin crédito suficiente no puede actualizar | PASS |
==============================================================================
Contract Management Traditional                                             | PASS |
8 tests, 8 passed, 0 failed
```

> **⚠️ Importante:** Si algún test falla en este paso, revisa el archivo antes de continuar. La suite tradicional debe pasar 8/8 tests para que la refactorización tenga sentido.

---

### Paso 2: Analizar y documentar los comportamientos de negocio

**Objetivo:** Identificar el comportamiento de negocio que cada test case técnico valida, separando el *qué* del *cómo*. Este es el paso conceptual más importante del proceso BDD.

#### Instrucciones

1. Crea el archivo `bdd_suite/ANALISIS_REFACTORIZACION.md` con el siguiente análisis:

```markdown
# Análisis de Refactorización: Traditional → BDD
## Laboratorio 04-00-02

### Metodología
Para cada test case técnico se identifica:
- El COMPORTAMIENTO DE NEGOCIO subyacente (independiente de la implementación)
- El ACTOR del escenario (quién realiza la acción)
- La REGLA DE NEGOCIO que se valida

### Mapeo de Test Cases a Comportamientos de Negocio

| TC Original | Comportamiento de Negocio | Actor | Capa BDD |
|---|---|---|---|
| TC-001 | Un cliente registrado puede ser localizado por su identificador | Agente de ventas | Búsqueda de cliente |
| TC-002 | Un identificador inválido no debe retornar datos de cliente | Sistema | Validación de cliente |
| TC-003 | Un cliente activo puede contratar un plan de datos disponible | Cliente / Agente | Contratación de servicio |
| TC-004 | No se puede contratar un plan que no existe en el catálogo | Sistema | Validación de catálogo |
| TC-005 | Un contrato activo refleja su estado y datos correctamente | Agente de soporte | Consulta de contrato |
| TC-006 | Un contrato cancelado refleja el estado CANCELADO | Agente de soporte | Consulta de contrato |
| TC-007 | Un cliente con crédito aprobado puede hacer upgrade de plan | Cliente / Agente | Modificación de contrato |
| TC-008 | Un cliente con crédito insuficiente no puede hacer upgrade | Sistema | Validación financiera |

### Decisiones de Diseño BDD

1. Los escenarios TC-001 y TC-002 se agrupan bajo la Feature "Gestión de Clientes"
2. Los escenarios TC-003 y TC-004 se agrupan bajo "Contratación de Servicios"
3. Los escenarios TC-005 y TC-006 se agrupan bajo "Consulta de Contratos"
4. Los escenarios TC-007 y TC-008 se agrupan bajo "Modificación de Contratos"

### Principio aplicado (Lección 4.1)
Los escenarios BDD describen QUÉ debe ocurrir, no CÓMO se implementa.
Un analista de negocio debe poder leer y validar cada escenario sin conocer
el código de automatización subyacente.
```

2. Revisa el mapeo y asegúrate de entender la diferencia entre el *qué* (comportamiento de negocio) y el *cómo* (implementación técnica) antes de continuar.

#### Verificación

No hay ejecución en este paso. Verifica que el archivo `.md` se creó correctamente y que el mapeo cubre los 8 test cases originales.

---

### Paso 3: Crear la capa técnica (technical_keywords)

**Objetivo:** Extraer todas las implementaciones técnicas a un archivo Resource dedicado que actúa como la capa más baja de la arquitectura. Esta capa contiene el código que interactúa directamente con los datos simulados.

#### Instrucciones

1. Crea el archivo `bdd_suite/technical_keywords/contract_technical.resource`:

```robot
*** Settings ***
Documentation    Capa técnica de la suite de gestión de contratos.
...
...              RESPONSABILIDAD: Esta capa contiene la implementación técnica
...              de las operaciones sobre el sistema de contratos. Es la única
...              capa que "sabe cómo" interactuar con los datos.
...
...              REGLA DE DISEÑO: Las keywords de esta capa NO deben ser
...              llamadas directamente desde los escenarios BDD. Solo deben
...              ser usadas por la capa de domain_keywords.
...
...              DECISIÓN DE REFACTORIZACIÓN: En la suite tradicional, estas
...              keywords estaban mezcladas con los test cases. Separarlas
...              permite cambiar la implementación técnica sin modificar los
...              escenarios de negocio.
Library          Collections
Library          BuiltIn

*** Variables ***
# --- Repositorio de datos simulados (equivalente a una base de datos en memoria) ---
# Estos datos eran variables sueltas en la suite tradicional.
# Al centralizarlos aquí, hay un único punto de mantenimiento.
${TECH_CLIENTE_VALIDO_ID}         CLI-001
${TECH_CLIENTE_VALIDO_NOMBRE}     Ana García
${TECH_CREDITO_DISPONIBLE}        ${500}
${TECH_CONTRATO_ACTIVO_ID}        CONT-2024-001
${TECH_CONTRATO_CANCELADO_ID}     CONT-2024-002

*** Keywords ***
Recuperar Datos De Cliente Por ID
    [Documentation]    Implementación técnica: recupera un registro de cliente por ID.
    ...                Simula una llamada a base de datos o API interna.
    [Arguments]    ${id_cliente}
    IF    '${id_cliente}' == '${TECH_CLIENTE_VALIDO_ID}'
        ${datos_cliente}=    Create Dictionary
        ...    id=${TECH_CLIENTE_VALIDO_ID}
        ...    nombre=${TECH_CLIENTE_VALIDO_NOMBRE}
        ...    estado=ACTIVO
        RETURN    ${datos_cliente}
    END
    ${error}=    Create Dictionary
    ...    error=CLIENTE_NO_ENCONTRADO
    ...    id=${id_cliente}
    RETURN    ${error}

Recuperar Detalle De Plan Por ID
    [Documentation]    Implementación técnica: recupera la definición de un plan del catálogo.
    [Arguments]    ${id_plan}
    IF    '${id_plan}' == 'PLAN-DATOS-10GB'
        ${datos_plan}=    Create Dictionary
        ...    id=PLAN-DATOS-10GB
        ...    nombre=Datos 10GB
        ...    precio=${250}
        RETURN    ${datos_plan}
    END
    IF    '${id_plan}' == 'PLAN-DATOS-50GB'
        ${datos_plan}=    Create Dictionary
        ...    id=PLAN-DATOS-50GB
        ...    nombre=Datos 50GB Premium
        ...    precio=${450}
        RETURN    ${datos_plan}
    END
    ${error}=    Create Dictionary
    ...    error=PLAN_NO_ENCONTRADO
    ...    id=${id_plan}
    RETURN    ${error}

Registrar Nuevo Contrato En Sistema
    [Documentation]    Implementación técnica: persiste un nuevo contrato en el sistema.
    [Arguments]    ${id_cliente}    ${id_plan}
    ${contrato}=    Create Dictionary
    ...    id_contrato=CONT-NEW-001
    ...    estado=ACTIVO
    ...    plan=${id_plan}
    ...    cliente_id=${id_cliente}
    ...    fecha_inicio=2024-01-15
    RETURN    ${contrato}

Recuperar Contrato Por ID
    [Documentation]    Implementación técnica: recupera los datos de un contrato por su ID.
    [Arguments]    ${id_contrato}
    IF    '${id_contrato}' == '${TECH_CONTRATO_ACTIVO_ID}'
        ${datos_contrato}=    Create Dictionary
        ...    id_contrato=${TECH_CONTRATO_ACTIVO_ID}
        ...    estado=ACTIVO
        ...    cliente_id=${TECH_CLIENTE_VALIDO_ID}
        ...    fecha_inicio=2024-01-01
        RETURN    ${datos_contrato}
    END
    IF    '${id_contrato}' == '${TECH_CONTRATO_CANCELADO_ID}'
        ${datos_contrato}=    Create Dictionary
        ...    id_contrato=${TECH_CONTRATO_CANCELADO_ID}
        ...    estado=CANCELADO
        ...    cliente_id=${TECH_CLIENTE_VALIDO_ID}
        ...    fecha_inicio=2023-06-01
        RETURN    ${datos_contrato}
    END
    ${error}=    Create Dictionary
    ...    error=CONTRATO_NO_ENCONTRADO
    ...    id=${id_contrato}
    RETURN    ${error}

Evaluar Credito Disponible Del Cliente
    [Documentation]    Implementación técnica: consulta el crédito disponible y evalúa suficiencia.
    [Arguments]    ${monto_requerido}
    # El crédito disponible es fijo en la simulación (mismo comportamiento que la suite original)
    ${tiene_credito}=    Evaluate    ${TECH_CREDITO_DISPONIBLE} >= ${monto_requerido}
    RETURN    ${tiene_credito}

Modificar Plan De Contrato En Sistema
    [Documentation]    Implementación técnica: actualiza el plan asociado a un contrato.
    [Arguments]    ${id_contrato}    ${nuevo_plan_id}
    ${resultado}=    Create Dictionary
    ...    id_contrato=${id_contrato}
    ...    nuevo_plan=${nuevo_plan_id}
    ...    estado=ACTUALIZADO
    RETURN    ${resultado}

Verificar Que Diccionario No Contiene Error
    [Documentation]    Implementación técnica: valida que un resultado no es un error del sistema.
    [Arguments]    ${resultado}
    Dictionary Should Not Contain Key    ${resultado}    error

Verificar Que Diccionario Contiene Error Especifico
    [Documentation]    Implementación técnica: valida que el resultado contiene el código de error esperado.
    [Arguments]    ${resultado}    ${codigo_error}
    Dictionary Should Contain Key    ${resultado}    error
    Should Be Equal    ${resultado}[error]    ${codigo_error}
```

2. Guarda el archivo.

#### Verificación

Verifica que el archivo existe y tiene sintaxis correcta:

```bash
# Verificación de sintaxis (no ejecuta tests, solo analiza)
python -m robot.libdoc bdd_suite/technical_keywords/contract_technical.resource list
```

Debes ver listadas las 8 keywords definidas en la capa técnica.

---

### Paso 4: Crear la capa de dominio (domain_keywords)

**Objetivo:** Crear la capa intermedia que traduce el lenguaje técnico al lenguaje de negocio. Esta es la capa que hace que los escenarios BDD sean agnósticos a la implementación.

#### Instrucciones

1. Crea el archivo `bdd_suite/domain_keywords/contract_domain.resource`:

```robot
*** Settings ***
Documentation    Capa de dominio de la suite de gestión de contratos.
...
...              RESPONSABILIDAD: Esta capa expresa las operaciones en lenguaje
...              de negocio del dominio de telecomunicaciones. Traduce los
...              conceptos técnicos a conceptos comprensibles por el negocio.
...
...              DECISIÓN DE REFACTORIZACIÓN: Esta capa NO existía en la suite
...              tradicional. En el enfoque keyword-driven, los test cases llamaban
...              directamente a keywords técnicas. Introducir esta capa permite:
...              1) Cambiar la implementación técnica sin tocar los escenarios.
...              2) Reutilizar keywords de dominio en múltiples features.
...              3) Que el equipo de negocio valide los nombres de las keywords.
...
...              REGLA DE DISEÑO: Los nombres de las keywords en esta capa deben
...              ser comprensibles para un analista de negocio sin conocimientos
...              técnicos. Evitar términos como "diccionario", "variable", "objeto".
Resource         ../technical_keywords/contract_technical.resource

*** Variables ***
# --- Variables de dominio (lenguaje de negocio, no técnico) ---
${PLAN_BASICO_ID}       PLAN-DATOS-10GB
${PLAN_PREMIUM_ID}      PLAN-DATOS-50GB
${CONTRATO_VIGENTE}     CONT-2024-001
${CONTRATO_DADO_DE_BAJA}    CONT-2024-002
${CREDITO_PLAN_PREMIUM}     ${450}
${CREDITO_INSUFICIENTE}     ${50}

*** Keywords ***
# ═══════════════════════════════════════════════════════════
# DOMINIO: Gestión de Clientes
# ═══════════════════════════════════════════════════════════

El cliente con identificador "${id_cliente}" existe en el sistema
    [Documentation]    Verifica que un cliente registrado puede ser localizado.
    ...                DOMINIO: Representa la verificación de existencia de un cliente activo.
    ${datos_cliente}=    Recuperar Datos De Cliente Por ID    ${id_cliente}
    Verificar Que Diccionario No Contiene Error    ${datos_cliente}
    Set Test Variable    ${CLIENTE_EN_CONTEXTO}    ${datos_cliente}

El identificador de cliente "${id_cliente}" no corresponde a ningún registro
    [Documentation]    Establece el contexto de un cliente inexistente.
    ...                DOMINIO: Simula un intento de acceso con identificador inválido.
    Set Test Variable    ${ID_CLIENTE_INVALIDO}    ${id_cliente}

El sistema confirma que el cliente "${nombre_cliente}" está registrado
    [Documentation]    Valida que los datos del cliente coinciden con el nombre esperado.
    ...                DOMINIO: Confirmación de identidad del cliente en el sistema.
    Should Be Equal    ${CLIENTE_EN_CONTEXTO}[nombre]    ${nombre_cliente}

El sistema informa que el cliente no fue encontrado
    [Documentation]    Valida que el sistema devuelve el error correcto para cliente inexistente.
    ...                DOMINIO: Comportamiento esperado ante identificador inválido.
    ${resultado}=    Recuperar Datos De Cliente Por ID    ${ID_CLIENTE_INVALIDO}
    Verificar Que Diccionario Contiene Error Especifico    ${resultado}    CLIENTE_NO_ENCONTRADO

# ═══════════════════════════════════════════════════════════
# DOMINIO: Contratación de Servicios
# ═══════════════════════════════════════════════════════════

El cliente selecciona el plan de datos "${id_plan}"
    [Documentation]    Registra la selección de un plan por parte del cliente.
    ...                DOMINIO: Acción de selección de producto en el catálogo de servicios.
    ${datos_plan}=    Recuperar Detalle De Plan Por ID    ${id_plan}
    Verificar Que Diccionario No Contiene Error    ${datos_plan}
    Set Test Variable    ${PLAN_SELECCIONADO}    ${datos_plan}

El cliente intenta seleccionar el plan "${id_plan}" que no existe en el catálogo
    [Documentation]    Intenta seleccionar un plan inexistente.
    ...                DOMINIO: Escenario de error en la selección del catálogo.
    ${resultado}=    Recuperar Detalle De Plan Por ID    ${id_plan}
    Verificar Que Diccionario Contiene Error Especifico    ${resultado}    PLAN_NO_ENCONTRADO

El cliente confirma la contratación del servicio
    [Documentation]    Ejecuta la contratación del plan seleccionado previamente.
    ...                DOMINIO: Confirmación y registro del nuevo contrato de servicio.
    ${nuevo_contrato}=    Registrar Nuevo Contrato En Sistema
    ...    ${CLIENTE_EN_CONTEXTO}[id]
    ...    ${PLAN_SELECCIONADO}[id]
    Set Test Variable    ${CONTRATO_GENERADO}    ${nuevo_contrato}

El contrato queda registrado como activo con el plan seleccionado
    [Documentation]    Verifica que el contrato fue creado en estado ACTIVO con el plan correcto.
    ...                DOMINIO: Validación del resultado exitoso de la contratación.
    Should Be Equal    ${CONTRATO_GENERADO}[estado]    ACTIVO
    Should Be Equal    ${CONTRATO_GENERADO}[plan]      ${PLAN_SELECCIONADO}[id]
    Dictionary Should Contain Key    ${CONTRATO_GENERADO}    id_contrato

El sistema rechaza la contratación informando que el plan no está disponible
    [Documentation]    Verifica que el sistema impide contratar un plan inexistente.
    ...                DOMINIO: Protección del catálogo ante selecciones inválidas.
    # El rechazo ya fue validado en "El cliente intenta seleccionar..."
    # Este step documenta explícitamente el resultado esperado para el lector de negocio.
    Log    El sistema rechazó correctamente la contratación de un plan inválido.

# ═══════════════════════════════════════════════════════════
# DOMINIO: Consulta de Contratos
# ═══════════════════════════════════════════════════════════

El agente consulta el contrato con referencia "${id_contrato}"
    [Documentation]    Recupera los datos de un contrato por su referencia.
    ...                DOMINIO: Consulta de estado de contrato por parte del agente de soporte.
    ${datos_contrato}=    Recuperar Contrato Por ID    ${id_contrato}
    Set Test Variable    ${CONTRATO_CONSULTADO}    ${datos_contrato}

El contrato aparece en estado "${estado_esperado}"
    [Documentation]    Verifica el estado de un contrato consultado.
    ...                DOMINIO: Validación del estado comercial del contrato.
    Should Be Equal    ${CONTRATO_CONSULTADO}[estado]    ${estado_esperado}

El contrato muestra la fecha de inicio y el cliente asociado
    [Documentation]    Verifica que el contrato contiene los datos mínimos requeridos.
    ...                DOMINIO: Completitud de la información del contrato para el agente.
    Dictionary Should Contain Key    ${CONTRATO_CONSULTADO}    fecha_inicio
    Dictionary Should Contain Key    ${CONTRATO_CONSULTADO}    cliente_id

# ═══════════════════════════════════════════════════════════
# DOMINIO: Modificación de Contratos (Upgrade/Downgrade)
# ═══════════════════════════════════════════════════════════

El cliente tiene crédito suficiente para el plan premium
    [Documentation]    Verifica que el cliente tiene capacidad financiera para el upgrade.
    ...                DOMINIO: Validación de elegibilidad financiera para modificación de plan.
    ${tiene_credito}=    Evaluar Credito Disponible Del Cliente    ${CREDITO_PLAN_PREMIUM}
    Should Be True    ${tiene_credito}

El cliente no tiene crédito suficiente para el plan premium
    [Documentation]    Establece el contexto de crédito insuficiente.
    ...                DOMINIO: Escenario de rechazo por capacidad financiera insuficiente.
    ${tiene_credito}=    Evaluar Credito Disponible Del Cliente    ${CREDITO_INSUFICIENTE}
    Should Not Be True    ${tiene_credito}

El cliente solicita cambiar al plan premium en su contrato vigente
    [Documentation]    Ejecuta la solicitud de upgrade de plan en el contrato activo.
    ...                DOMINIO: Solicitud de modificación comercial del servicio contratado.
    ${resultado}=    Modificar Plan De Contrato En Sistema
    ...    ${CONTRATO_VIGENTE}
    ...    ${PLAN_PREMIUM_ID}
    Set Test Variable    ${RESULTADO_UPGRADE}    ${resultado}

El plan del contrato se actualiza al plan premium exitosamente
    [Documentation]    Verifica que el upgrade fue aplicado correctamente.
    ...                DOMINIO: Confirmación de la modificación del servicio.
    Should Be Equal    ${RESULTADO_UPGRADE}[nuevo_plan]    ${PLAN_PREMIUM_ID}
    Should Be Equal    ${RESULTADO_UPGRADE}[estado]        ACTUALIZADO

El sistema deniega el cambio de plan por capacidad financiera insuficiente
    [Documentation]    Documenta el resultado esperado cuando el crédito es insuficiente.
    ...                DOMINIO: El rechazo fue validado en el step de verificación de crédito.
    ...                Este step cierra el escenario con la confirmación explícita del rechazo.
    Log    El sistema denegó correctamente el upgrade por crédito insuficiente.
```

2. Guarda el archivo.

#### Verificación

```bash
python -m robot.libdoc bdd_suite/domain_keywords/contract_domain.resource list
```

Debes ver listadas todas las keywords de dominio. Verifica que los nombres son legibles en lenguaje de negocio.

---

### Paso 5: Crear los escenarios BDD (capa de features)

**Objetivo:** Escribir los 8 escenarios Gherkin que reemplazan a los 8 test cases tradicionales, usando exclusivamente keywords de la capa de dominio.

#### Instrucciones

1. Crea el archivo `bdd_suite/features/contract_management.robot`:

```robot
*** Settings ***
Documentation    Feature: Gestión de Contratos de Telecomunicaciones
...
...              Esta suite representa la refactorización completa de la suite
...              tradicional "contract_management_traditional.robot" al modelo BDD.
...
...              COBERTURA: Los 8 escenarios de esta suite tienen correspondencia
...              exacta con los 8 test cases de la suite tradicional. La cobertura
...              funcional es idéntica; solo cambia el nivel de abstracción.
...
...              PRINCIPIO APLICADO (Lección 4.1):
...              "Los escenarios BDD describen QUÉ debe ocurrir, no CÓMO se implementa."
...              Un analista de negocio puede leer y validar estos escenarios sin
...              conocer el código de automatización subyacente.
...
...              ARQUITECTURA DE TRES CAPAS:
...              features/ → domain_keywords/ → technical_keywords/
...
...              NOTA: Esta capa NO importa technical_keywords directamente.
...              Toda la implementación técnica está encapsulada en domain_keywords.
Resource         ../domain_keywords/contract_domain.resource

*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════════
# FEATURE: Gestión de Clientes
# Corresponde a: TC-001 y TC-002 de la suite tradicional
# ═══════════════════════════════════════════════════════════════════════════

Escenario: Un agente localiza a un cliente registrado por su identificador
    [Documentation]    BDD equivalente a TC-001.
    ...                Valida que un cliente existente puede ser encontrado en el sistema.
    [Tags]    cliente    busqueda    smoke    bdd
    Given el cliente con identificador "CLI-001" existe en el sistema
    Then el sistema confirma que el cliente "Ana García" está registrado

Escenario: El sistema rechaza la búsqueda de un identificador de cliente inválido
    [Documentation]    BDD equivalente a TC-002.
    ...                Valida que un ID inexistente genera el error controlado correcto.
    [Tags]    cliente    busqueda    negativo    bdd
    Given el identificador de cliente "CLI-999" no corresponde a ningún registro
    When el agente intenta localizar al cliente en el sistema
    Then el sistema informa que el cliente no fue encontrado

# ═══════════════════════════════════════════════════════════════════════════
# FEATURE: Contratación de Servicios
# Corresponde a: TC-003 y TC-004 de la suite tradicional
# ═══════════════════════════════════════════════════════════════════════════

Escenario: Un cliente activo contrata exitosamente un plan de datos disponible
    [Documentation]    BDD equivalente a TC-003.
    ...                Valida el flujo completo de contratación de un plan válido.
    [Tags]    contrato    alta    smoke    bdd
    Given el cliente con identificador "CLI-001" existe en el sistema
    When el cliente selecciona el plan de datos "PLAN-DATOS-10GB"
    And el cliente confirma la contratación del servicio
    Then el contrato queda registrado como activo con el plan seleccionado

Escenario: El sistema impide contratar un plan que no existe en el catálogo
    [Documentation]    BDD equivalente a TC-004.
    ...                Valida que el sistema protege al catálogo de selecciones inválidas.
    [Tags]    contrato    alta    negativo    bdd
    Given el cliente con identificador "CLI-001" existe en el sistema
    When el cliente intenta seleccionar el plan "PLAN-INEXISTENTE" que no existe en el catálogo
    Then el sistema rechaza la contratación informando que el plan no está disponible

# ═══════════════════════════════════════════════════════════════════════════
# FEATURE: Consulta de Contratos
# Corresponde a: TC-005 y TC-006 de la suite tradicional
# ═══════════════════════════════════════════════════════════════════════════

Escenario: Un agente de soporte consulta un contrato vigente y verifica su estado
    [Documentation]    BDD equivalente a TC-005.
    ...                Valida que un contrato activo muestra estado y datos correctos.
    [Tags]    contrato    consulta    smoke    bdd
    Given el agente consulta el contrato con referencia "CONT-2024-001"
    Then el contrato aparece en estado "ACTIVO"
    And el contrato muestra la fecha de inicio y el cliente asociado

Escenario: Un agente de soporte verifica que un contrato dado de baja tiene estado cancelado
    [Documentation]    BDD equivalente a TC-006.
    ...                Valida que un contrato cancelado refleja el estado CANCELADO.
    [Tags]    contrato    consulta    negativo    bdd
    Given el agente consulta el contrato con referencia "CONT-2024-002"
    Then el contrato aparece en estado "CANCELADO"

# ═══════════════════════════════════════════════════════════════════════════
# FEATURE: Modificación de Contratos
# Corresponde a: TC-007 y TC-008 de la suite tradicional
# ═══════════════════════════════════════════════════════════════════════════

Escenario: Un cliente con crédito aprobado actualiza su plan al servicio premium
    [Documentation]    BDD equivalente a TC-007.
    ...                Valida el upgrade de plan cuando el cliente tiene crédito suficiente.
    [Tags]    contrato    upgrade    smoke    bdd
    Given el cliente con identificador "CLI-001" existe en el sistema
    And el cliente tiene crédito suficiente para el plan premium
    When el cliente solicita cambiar al plan premium en su contrato vigente
    Then el plan del contrato se actualiza al plan premium exitosamente

Escenario: El sistema deniega el upgrade de plan a un cliente con crédito insuficiente
    [Documentation]    BDD equivalente a TC-008.
    ...                Valida que el sistema protege contra upgrades sin capacidad financiera.
    [Tags]    contrato    upgrade    negativo    bdd
    Given el cliente con identificador "CLI-001" existe en el sistema
    But el cliente no tiene crédito suficiente para el plan premium
    Then el sistema deniega el cambio de plan por capacidad financiera insuficiente

*** Keywords ***
# ─────────────────────────────────────────────────────────────────────────
# NOTA: Esta sección de Keywords locales solo existe para el step que no
# tiene correspondencia directa en domain_keywords. En una suite BDD madura,
# esta sección debería estar vacía o no existir.
# ─────────────────────────────────────────────────────────────────────────

el agente intenta localizar al cliente en el sistema
    [Documentation]    Step intermedio que representa la acción del agente.
    ...                Delega la validación a la keyword de dominio.
    El sistema informa que el cliente no fue encontrado
```

2. Guarda el archivo.

#### Verificación

Verifica la sintaxis del archivo de features:

```bash
python -m robot.libdoc bdd_suite/features/contract_management.robot list
```

---

### Paso 6: Ejecutar la suite BDD y comparar resultados

**Objetivo:** Verificar que la suite BDD refactorizada produce exactamente los mismos resultados que la suite tradicional (8/8 tests pasando) y comparar las métricas de legibilidad.

#### Instrucciones

1. Ejecuta la suite BDD refactorizada:

```bash
robot --outputdir results/bdd \
      --log bdd_log.html \
      --report bdd_report.html \
      bdd_suite/features/contract_management.robot
```

**En Windows (una sola línea):**

```cmd
robot --outputdir results\bdd --log bdd_log.html --report bdd_report.html bdd_suite\features\contract_management.robot
```

2. Ejecuta ambas suites juntas para comparar en un único reporte:

```bash
# macOS / Linux
robot --outputdir results \
      --log comparison_log.html \
      --report comparison_report.html \
      --name "Comparacion_Traditional_vs_BDD" \
      traditional_suite/ \
      bdd_suite/features/

# Windows
robot --outputdir results --log comparison_log.html --report comparison_report.html --name "Comparacion_Traditional_vs_BDD" traditional_suite\ bdd_suite\features\
```

3. Abre el reporte HTML en tu navegador:

```bash
# macOS
open results/comparison_report.html

# Linux
xdg-open results/comparison_report.html

# Windows
start results\comparison_report.html
```

#### Salida esperada

```
==============================================================================
Comparacion Traditional Vs BDD
==============================================================================
Contract Management Traditional                                               | PASS |
8 tests, 8 passed, 0 failed
------------------------------------------------------------------------------
Contract Management                                                           | PASS |
8 tests, 8 passed, 0 failed
==============================================================================
Comparacion Traditional Vs BDD                                               | PASS |
16 tests, 16 passed, 0 failed
```

#### Verificación

Confirma los siguientes puntos en el reporte HTML:

- [ ] La suite tradicional: 8 tests, 8 passed, 0 failed.
- [ ] La suite BDD: 8 tests, 8 passed, 0 failed.
- [ ] Total combinado: 16 tests, 16 passed, 0 failed.
- [ ] En el log de la suite BDD, los nombres de los escenarios son legibles en lenguaje de negocio.
- [ ] En el log de la suite BDD, se puede ver la jerarquía de tres capas en el árbol de keywords.

---

### Paso 7: Documentar la comparación de métricas

**Objetivo:** Comparar cuantitativamente y cualitativamente ambos enfoques para consolidar el aprendizaje sobre el valor de BDD.

#### Instrucciones

1. Crea el archivo `bdd_suite/COMPARACION_METRICAS.md`:

```markdown
# Comparación de Métricas: Suite Tradicional vs Suite BDD
## Laboratorio 04-00-02 — Resultado del análisis de refactorización

---

## 1. Métricas Estructurales

| Métrica                              | Suite Tradicional | Suite BDD (3 capas) |
|--------------------------------------|:-----------------:|:-------------------:|
| Archivos .robot / .resource          | 1                 | 3                   |
| Líneas de código total               | ~130              | ~310                |
| Keywords reutilizables               | 6                 | 6 técnicas + 14 dominio |
| Capas de abstracción                 | 1                 | 3                   |
| Legibilidad por analista de negocio  | Baja              | Alta                |
| Trazabilidad a requisitos            | Manual            | Directa (nombre del escenario) |

---

## 2. Análisis de Mantenibilidad

### Escenario de cambio: "El sistema ahora usa una API REST en lugar de datos simulados"

**Suite Tradicional:**
- Hay que modificar 6 keywords directamente en el archivo de tests.
- Riesgo de romper los test cases al editar el mismo archivo.
- El analista de negocio no puede distinguir qué cambió.

**Suite BDD (3 capas):**
- Solo se modifica `technical_keywords/contract_technical.resource`.
- Las keywords de dominio y los escenarios NO cambian.
- El analista de negocio puede verificar que los escenarios siguen siendo correctos.

---

## 3. Análisis de Legibilidad

### Test case tradicional (TC-007):
```
TC-007 Verificar que un cliente con crédito suficiente puede actualizar su plan
    ${cliente}=       Buscar Cliente Por ID       ${CLIENTE_VALIDO_ID}
    ${credito_ok}=    Verificar Credito Cliente   ${cliente}    ${LIMITE_CREDITO_APROBADO}
    Should Be True    ${credito_ok}
    ${resultado}=     Actualizar Plan Contrato    ${CONTRATO_ACTIVO_ID}    ${PLAN_PREMIUM}
    Should Be Equal   ${resultado}[nuevo_plan]    ${PLAN_PREMIUM}
    Should Be Equal   ${resultado}[estado]        ACTUALIZADO
```

### Escenario BDD equivalente:
```
Escenario: Un cliente con crédito aprobado actualiza su plan al servicio premium
    Given el cliente con identificador "CLI-001" existe en el sistema
    And el cliente tiene crédito suficiente para el plan premium
    When el cliente solicita cambiar al plan premium en su contrato vigente
    Then el plan del contrato se actualiza al plan premium exitosamente
```

**Conclusión:** El escenario BDD puede ser validado por el área comercial sin conocimientos técnicos.

---

## 4. Principios BDD Aplicados (Lección 4.1)

| Principio              | Aplicación en este laboratorio |
|------------------------|-------------------------------|
| **Colaboración**       | Los escenarios usan nombres que el negocio puede validar |
| **Especificación ejecutable** | Los 8 escenarios Gherkin son ejecutables y pasan |
| **Documentación viva** | Los escenarios reflejan el comportamiento actual del sistema |
| **Agnóstico a tecnología** | Los escenarios no mencionan diccionarios, variables ni métodos |
```

2. Guarda el archivo.

---

## Validación y Pruebas

Ejecuta la siguiente secuencia de validación completa para confirmar que el laboratorio está terminado correctamente:

```bash
# 1. Validar suite tradicional (línea base)
robot --outputdir results/traditional \
      --log traditional_log.html \
      traditional_suite/contract_management_traditional.robot
echo "=== Suite tradicional: debe mostrar 8 passed ==="

# 2. Validar suite BDD
robot --outputdir results/bdd \
      --log bdd_log.html \
      bdd_suite/features/contract_management.robot
echo "=== Suite BDD: debe mostrar 8 passed ==="

# 3. Validar que la capa técnica no es accesible directamente desde features
# (verificación manual: abrir bdd_suite/features/contract_management.robot
#  y confirmar que NO hay ningún import de technical_keywords)
grep -r "technical_keywords" bdd_suite/features/
# Debe retornar vacío (sin resultados)

# 4. Reporte comparativo final
robot --outputdir results \
      --log comparison_log.html \
      --report comparison_report.html \
      traditional_suite/ bdd_suite/features/
echo "=== Comparativo: debe mostrar 16 passed ==="
```

**En Windows (PowerShell):**

```powershell
# 1. Suite tradicional
robot --outputdir results\traditional --log traditional_log.html traditional_suite\contract_management_traditional.robot

# 2. Suite BDD
robot --outputdir results\bdd --log bdd_log.html bdd_suite\features\contract_management.robot

# 3. Verificar encapsulamiento de capas
Select-String -Path "bdd_suite\features\*.robot" -Pattern "technical_keywords"
# Debe retornar sin resultados

# 4. Reporte comparativo
robot --outputdir results --log comparison_log.html --report comparison_report.html traditional_suite\ bdd_suite\features\
```

### Lista de verificación final

| Criterio de validación                                              | Estado esperado |
|---------------------------------------------------------------------|:---------------:|
| Suite tradicional: 8/8 tests passing                                | ✅ PASS         |
| Suite BDD: 8/8 tests passing                                        | ✅ PASS         |
| `features/` no importa `technical_keywords/` directamente          | ✅ Verificado   |
| Nombres de escenarios BDD legibles en lenguaje de negocio           | ✅ Verificado   |
| Archivo `ANALISIS_REFACTORIZACION.md` documenta el mapeo de 8 TCs  | ✅ Presente     |
| Archivo `COMPARACION_METRICAS.md` documenta el análisis comparativo | ✅ Presente     |
| Jerarquía de tres capas visible en el log HTML de la suite BDD      | ✅ Verificado   |

---

## Solución de Problemas

### Problema 1: `Variable '${CLIENTE_EN_CONTEXTO}' not found` en la suite BDD

**Síntoma:** Al ejecutar la suite BDD, uno o más escenarios fallan con el mensaje `Variable '${CLIENTE_EN_CONTEXTO}' not found` o similar para otras variables de contexto (`${PLAN_SELECCIONADO}`, `${CONTRATO_CONSULTADO}`, etc.).

**Causa:** Las variables de contexto entre steps de un mismo escenario se establecen con `Set Test Variable`, que las hace visibles dentro del test case en ejecución. El error ocurre cuando el step `Given` que debería establecer la variable no se ejecutó antes del step `Then` que la consume, generalmente porque los steps están en orden incorrecto en el escenario o porque se está ejecutando un step `Then` de forma aislada.

**Solución:**

1. Verifica que el orden de los steps en el escenario sigue la secuencia `Given → When → Then`. Robot Framework ejecuta los steps en orden secuencial.
2. Confirma que el step `Given` que llama a `El cliente con identificador "..." existe en el sistema` está presente antes de cualquier step que use `${CLIENTE_EN_CONTEXTO}`.
3. Si el problema persiste, agrega un `Log Variables` temporal al inicio del step que falla para ver qué variables están disponibles:

```robot
# Diagnóstico temporal — eliminar después de resolver
El contrato queda registrado como activo con el plan seleccionado
    Log Variables
    Should Be Equal    ${CONTRATO_GENERADO}[estado]    ACTIVO
```

4. Verifica que el archivo `contract_domain.resource` usa `Set Test Variable` (no `Set Suite Variable` ni `Set Global Variable`) para las variables de contexto.

---

### Problema 2: La suite BDD muestra 8 tests pero con nombres técnicos en lugar de nombres de negocio en el reporte HTML

**Síntoma:** Al abrir `results/bdd/bdd_report.html`, los test cases aparecen con nombres como `TC-001 Verificar que un cliente válido...` en lugar de `Escenario: Un agente localiza a un cliente registrado...`.

**Causa:** Robot Framework está ejecutando el archivo incorrecto. Probablemente se está ejecutando `traditional_suite/contract_management_traditional.robot` en lugar de `bdd_suite/features/contract_management.robot`. Esto puede ocurrir si el comando `robot` se ejecutó desde una ruta incorrecta o si hay un error tipográfico en la ruta del archivo.

**Solución:**

1. Verifica la ruta desde la que ejecutas el comando. Debes estar en `lab04-00-02/`:

```bash
# Verificar directorio actual
pwd          # macOS / Linux
cd           # Windows (muestra el directorio actual)
```

2. Ejecuta el comando con la ruta explícita y verifica que apunta a `bdd_suite/features/`:

```bash
robot --outputdir results/bdd bdd_suite/features/contract_management.robot
```

3. Si el problema persiste, verifica que el archivo `bdd_suite/features/contract_management.robot` contiene los escenarios con nombres BDD y no fue sobreescrito accidentalmente:

```bash
# macOS / Linux
head -30 bdd_suite/features/contract_management.robot

# Windows
type bdd_suite\features\contract_management.robot | more
```

4. Confirma que el archivo comienza con `*** Settings ***` y que los test cases tienen nombres que empiezan con `Escenario:`.

---

## Limpieza

Al finalizar el laboratorio, ejecuta los siguientes pasos de limpieza:

```bash
# 1. Crear copia de respaldo del proyecto completo (recomendado)
# macOS / Linux
cp -r lab04-00-02 lab04-00-02_backup_$(date +%Y%m%d)

# Windows (PowerShell)
Copy-Item -Recurse lab04-00-02 "lab04-00-02_backup_$(Get-Date -Format 'yyyyMMdd')"

# 2. Limpiar archivos de salida temporales (opcional — conservar si necesitas los reportes)
# macOS / Linux
rm -f results/traditional/output.xml
rm -f results/bdd/output.xml

# Windows
del results\traditional\output.xml
del results\bdd\output.xml

# 3. Desactivar el entorno virtual
deactivate
```

> **💡 Nota:** Conserva los archivos `results/comparison_report.html` y `results/comparison_log.html`. Son evidencia de que ambas suites producen resultados equivalentes y pueden ser útiles como referencia en el Módulo 5.

---

## Resumen

En este laboratorio completaste el proceso completo de refactorización de una suite keyword-driven a una arquitectura BDD de tres capas:

| Capa | Archivo | Responsabilidad |
|------|---------|----------------|
| **Features (Gherkin)** | `bdd_suite/features/contract_management.robot` | Escenarios en lenguaje de negocio, legibles por analistas |
| **Domain Keywords** | `bdd_suite/domain_keywords/contract_domain.resource` | Traducción de lenguaje técnico a lenguaje de dominio |
| **Technical Keywords** | `bdd_suite/technical_keywords/contract_technical.resource` | Implementación técnica encapsulada y aislada |

### Conceptos clave aplicados

- **Principio de separación de responsabilidades:** cada capa tiene una única razón para cambiar. Si cambia la tecnología subyacente, solo cambia `technical_keywords`. Si cambia el lenguaje de negocio, solo cambia `domain_keywords`. Si cambia el requisito, solo cambia `features`.
- **Agnóstico a la implementación:** los escenarios BDD no mencionan diccionarios, variables, ni métodos técnicos. Un analista puede leerlos sin conocer Robot Framework.
- **Cobertura funcional preservada:** los 8 escenarios BDD cubren exactamente los mismos comportamientos que los 8 test cases tradicionales, verificado por ejecución paralela con 16/16 tests passing.
- **Documentación viva (Lección 4.1):** los escenarios son a la vez especificación ejecutable y documentación del comportamiento del sistema.

### Recursos de referencia

- [Robot Framework User Guide — Behavior Driven Style](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#behavior-driven-style)
- [Dan North — Introducing BDD](https://dannorth.net/introducing-bdd/)
- [Cucumber — Referencia de Gherkin](https://cucumber.io/docs/gherkin/reference/)
- [Robot Framework — Set Test Variable](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Set%20Test%20Variable)

---

