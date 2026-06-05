# Práctica 4: Parametrización con Setup/Teardown y filtrado por tags

## 1. Metadatos

| Campo            | Detalle                                      |
|------------------|----------------------------------------------|
| **Duración**     | 72 minutos                                   |
| **Complejidad**  | Media                                        |
| **Nivel Bloom**  | Aplicar (Apply)                              |
| **Módulo**       | 02 — Test Cases, Keywords y Bibliotecas      |
| **Laboratorio**  | 02-00-02 (Práctica 4)                        |

---

## 2. Descripción General

En este laboratorio el estudiante extiende el proyecto construido en la Práctica 3 (Lab 02-00-01) añadiendo mecanismos de control de ejecución profesionales. Se implementarán **Suite Setup**, **Suite Teardown**, **Test Setup** y **Test Teardown** para gestionar el ciclo de vida completo de la suite, usando la biblioteca **OperatingSystem** para inicializar y limpiar archivos temporales. Adicionalmente, se asignarán **tags** a cada test case para habilitar la ejecución selectiva mediante los argumentos `--include` y `--exclude`, se creará una segunda suite en un subdirectorio para demostrar la jerarquía de suites, y se implementará un **Test Template** con tabla de datos para validar múltiples entradas de forma compacta.

---

## 3. Objetivos de Aprendizaje

- [ ] Implementar `Suite Setup`, `Suite Teardown`, `Test Setup` y `Test Teardown` para gestionar precondiciones y postcondiciones de ejecución usando `OperatingSystem`
- [ ] Asignar tags significativos a los test cases y ejecutar subconjuntos de la suite usando `--include`, `--exclude` y los operadores `AND` / `OR`
- [ ] Organizar una suite jerárquica con subdirectorios que Robot Framework trate como sub-suites anidadas
- [ ] Aplicar la directiva `Test Template` para parametrizar un test case con múltiples conjuntos de datos en formato tabla
- [ ] Verificar el comportamiento de `Run Keywords` y `No Operation` dentro de las fases de setup y teardown

---

## 4. Prerequisitos

### Conocimiento previo
- Haber completado el **Lab 02-00-01** con el proyecto de suite estructurada funcional
- Comprensión de keywords reutilizables, archivos `Resource` y variables de distintos tipos (`${scalar}`, `@{list}`, `&{dict}`)
- Familiaridad básica con la terminal para crear subdirectorios y ejecutar comandos `robot`

### Acceso requerido
- Entorno virtual Python (`venv`) activado con Robot Framework 7.x instalado
- Proyecto del Lab 02-00-01 disponible en disco (o la copia de respaldo)
- Conexión a internet no requerida para este laboratorio (todo es local)

---

## 5. Entorno de Laboratorio

### Hardware mínimo recomendado

| Componente       | Mínimo                                      |
|------------------|---------------------------------------------|
| Procesador       | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos) |
| RAM              | 8 GB                                        |
| Almacenamiento   | 5 GB libres                                 |
| Pantalla         | 1280 × 768 para reportes HTML               |

### Software requerido

| Paquete                  | Versión mínima |
|--------------------------|----------------|
| Python                   | 3.10+          |
| Robot Framework          | 7.x            |
| Visual Studio Code       | 1.85+          |
| RF Language Server (ext) | 1.12+          |

### Verificación del entorno y activación del venv

Antes de comenzar, abre una terminal en la raíz del proyecto del Lab 02-00-01 y ejecuta:

```bash
# ── Windows (cmd) ──────────────────────────────────────────────────────────
.venv\Scripts\activate

# ── Windows (PowerShell) ───────────────────────────────────────────────────
.venv\Scripts\Activate.ps1

# ── macOS / Linux (bash/zsh) ───────────────────────────────────────────────
source .venv/bin/activate
```

Confirma que el entorno está activo y que Robot Framework está disponible:

```bash
python --version
robot --version
```

**Salida esperada (ejemplo):**
```
Python 3.11.7
Robot Framework 7.1.1 (Python 3.11.7 on win32)
```

> ⚠️ **IMPORTANTE:** Si el prompt no muestra el prefijo `(.venv)`, el entorno virtual NO está activo. No continúes hasta resolverlo.

---

## 6. Pasos del Laboratorio

---

### Paso 1 — Revisar la estructura del proyecto y planificar las extensiones

**Objetivo:** Confirmar que el proyecto del Lab 02-00-01 está completo y trazar el mapa de los nuevos archivos que se crearán.

#### Instrucciones

1. Abre una terminal en la raíz del proyecto (la carpeta que contiene `tests/`, `resources/`, `variables/`, etc.) y ejecuta:

```bash
# ── Windows ────────────────────────────────────────────────────────────────
tree /F

# ── macOS / Linux ──────────────────────────────────────────────────────────
find . -not -path './.venv/*' | sort
```

2. Confirma que existe al menos la siguiente estructura mínima del lab anterior:

```
proyecto-telecom/
├── tests/
│   └── facturacion_suite.robot
├── resources/
│   └── telecom_keywords.resource
├── variables/
│   └── config_vars.robot
└── results/
```

3. Crea los nuevos directorios que se necesitarán en este laboratorio:

```bash
# ── Windows (cmd) ──────────────────────────────────────────────────────────
mkdir tests\clientes
mkdir temp_data

# ── macOS / Linux ──────────────────────────────────────────────────────────
mkdir -p tests/clientes
mkdir -p temp_data
```

4. La estructura objetivo al finalizar este laboratorio será:

```
proyecto-telecom/
├── tests/
│   ├── facturacion_suite.robot       ← modificado en este lab
│   └── clientes/                     ← nuevo subdirectorio (sub-suite)
│       └── clientes_suite.robot      ← nuevo archivo
├── resources/
│   └── telecom_keywords.resource     ← modificado en este lab
├── variables/
│   └── config_vars.robot
├── temp_data/                        ← creado por Suite Setup
└── results/
```

#### Salida esperada
Los directorios `tests/clientes/` y `temp_data/` aparecen en el árbol del proyecto.

#### Verificación
```bash
# ── Windows ────────────────────────────────────────────────────────────────
if exist tests\clientes echo OK
if exist temp_data echo OK

# ── macOS / Linux ──────────────────────────────────────────────────────────
test -d tests/clientes && echo OK
test -d temp_data && echo OK
```

---

### Paso 2 — Actualizar el archivo de variables con rutas de archivos temporales

**Objetivo:** Centralizar en `variables/config_vars.robot` las rutas que usarán los setup/teardown para no repetir strings literales.

#### Instrucciones

1. Abre `variables/config_vars.robot` en VS Code.

2. Añade las siguientes variables al final del bloque `*** Variables ***` existente (conserva todo lo que ya tenías del lab anterior):

```robot
# ── Rutas para Setup/Teardown ──────────────────────────────────────────────
${TEMP_DIR}           ${CURDIR}/../temp_data
${LOG_INIT_FILE}      ${TEMP_DIR}/suite_init.log
${LOG_BILLING_FILE}   ${TEMP_DIR}/billing_test.log
${LOG_CUSTOMER_FILE}  ${TEMP_DIR}/customer_test.log

# ── Datos de prueba para Test Template ────────────────────────────────────
${PLAN_BASICO}        Plan Básico 50MB
${PLAN_ESTANDAR}      Plan Estándar 200MB
${PLAN_PREMIUM}       Plan Premium 1GB
```

3. Guarda el archivo (`Ctrl+S` / `Cmd+S`).

> **Nota:** `${CURDIR}` es una variable automática de Robot Framework que apunta al directorio del archivo `.robot` o `.resource` que la usa. Cuando se use desde `tests/`, resolverá correctamente hacia `temp_data/` en la raíz del proyecto.

#### Salida esperada
El archivo `config_vars.robot` contiene las nuevas variables sin errores de sintaxis (VS Code no muestra subrayados rojos con el Language Server activo).

#### Verificación
Ejecuta una comprobación rápida de sintaxis:
```bash
python -m robot --dryrun --nostatusrc variables/config_vars.robot 2>&1 | head -5
```
El resultado debe indicar `0 tests, 0 passed` sin errores de parseo.

---

### Paso 3 — Implementar keywords de Setup/Teardown en el archivo Resource

**Objetivo:** Añadir al archivo `resources/telecom_keywords.resource` las keywords que gestionarán el ciclo de vida de la suite y de cada test case.

#### Instrucciones

1. Abre `resources/telecom_keywords.resource` en VS Code.

2. Asegúrate de que la sección `*** Settings ***` importa `OperatingSystem` y las variables:

```robot
*** Settings ***
Library     OperatingSystem
Library     Collections
Resource    ../variables/config_vars.robot
```

3. Al final de la sección `*** Keywords ***` existente, añade las siguientes keywords nuevas:

```robot
# ══════════════════════════════════════════════════════════════════════════
# KEYWORDS DE SUITE SETUP / TEARDOWN
# ══════════════════════════════════════════════════════════════════════════

Inicializar Entorno De Suite
    [Documentation]    Crea el directorio temporal y el archivo de log de
    ...                inicialización. Se invoca como Suite Setup.
    Log    Iniciando Suite Setup de Telecom    console=True
    Create Directory    ${TEMP_DIR}
    Directory Should Exist    ${TEMP_DIR}
    ${timestamp}=    Get Time    format=%Y-%m-%d %H:%M:%S
    Create File    ${LOG_INIT_FILE}
    ...    Suite iniciada: ${timestamp}\nEntorno: TEST\nProyecto: Telecom-Lab\n
    Log    Directorio temporal creado: ${TEMP_DIR}
    Log    Archivo de inicialización creado: ${LOG_INIT_FILE}

Limpiar Entorno De Suite
    [Documentation]    Elimina los archivos temporales generados durante la
    ...                suite. Se invoca como Suite Teardown.
    Log    Iniciando Suite Teardown de Telecom    console=True
    Run Keyword And Ignore Error    Remove File    ${LOG_INIT_FILE}
    Run Keyword And Ignore Error    Remove File    ${LOG_BILLING_FILE}
    Run Keyword And Ignore Error    Remove File    ${LOG_CUSTOMER_FILE}
    Log    Archivos temporales eliminados correctamente

# ══════════════════════════════════════════════════════════════════════════
# KEYWORDS DE TEST SETUP / TEARDOWN
# ══════════════════════════════════════════════════════════════════════════

Preparar Test De Facturación
    [Documentation]    Crea el archivo de log para el test de facturación
    ...                y registra el inicio del test.
    [Arguments]    ${nombre_test}=Test de Facturación
    ${timestamp}=    Get Time    format=%Y-%m-%d %H:%M:%S
    Create File    ${LOG_BILLING_FILE}
    ...    Test iniciado: ${nombre_test}\nTimestamp: ${timestamp}\n
    Log    Test Setup ejecutado para: ${nombre_test}

Finalizar Test De Facturación
    [Documentation]    Registra el resultado en el log y realiza limpieza
    ...                post-test. Usa No Operation si no hay nada que limpiar.
    Log    Test Teardown ejecutado — registrando resultado
    ${existe}=    Run Keyword And Return Status
    ...    File Should Exist    ${LOG_BILLING_FILE}
    IF    ${existe}
        ${contenido}=    Get File    ${LOG_BILLING_FILE}
        Log    Contenido del log de billing:\n${contenido}
    ELSE
        No Operation
    END

Preparar Test De Clientes
    [Documentation]    Inicializa el contexto para tests de clientes.
    Log    Preparando contexto de test de clientes

Finalizar Test De Clientes
    [Documentation]    Limpieza post-test para tests de clientes.
    Run Keyword And Ignore Error    Remove File    ${LOG_CUSTOMER_FILE}
    Log    Contexto de clientes limpiado

# ══════════════════════════════════════════════════════════════════════════
# KEYWORDS DE NEGOCIO (para Test Template)
# ══════════════════════════════════════════════════════════════════════════

Validar Plan De Telecomunicaciones
    [Documentation]    Verifica que el nombre del plan contiene la palabra
    ...                clave esperada y que la velocidad es válida.
    [Arguments]    ${nombre_plan}    ${velocidad_mb}    ${precio_usd}
    Log    Validando plan: ${nombre_plan} | ${velocidad_mb} MB | $${precio_usd}
    Should Contain    ${nombre_plan}    Plan
    ...    msg=El nombre del plan debe comenzar con 'Plan'
    Should Be True    ${velocidad_mb} > 0
    ...    msg=La velocidad debe ser mayor que cero
    Should Be True    ${precio_usd} > 0
    ...    msg=El precio debe ser mayor que cero
    Log    Plan '${nombre_plan}' validado exitosamente
```

4. Guarda el archivo.

#### Salida esperada
El archivo `telecom_keywords.resource` contiene las 6 nuevas keywords sin errores de sintaxis.

#### Verificación
```bash
python -m robot --dryrun --nostatusrc resources/telecom_keywords.resource 2>&1 | tail -3
```
Debe aparecer `0 tests, 0 passed` sin mensajes de error.

---

### Paso 4 — Modificar `facturacion_suite.robot` con Setup/Teardown y Tags

**Objetivo:** Actualizar la suite principal para incorporar `Suite Setup`, `Suite Teardown`, `Test Setup`, `Test Teardown` y asignar tags a cada test case.

#### Instrucciones

1. Abre `tests/facturacion_suite.robot` en VS Code.

2. Reemplaza (o actualiza) el contenido completo del archivo con lo siguiente. Conserva los test cases que ya tenías del lab anterior; el ejemplo muestra la estructura completa con test cases representativos:

```robot
*** Settings ***
Documentation       Suite de pruebas de Facturación — Telecom Lab
...                 Módulo 02 | Lab 02-00-02
...                 Demuestra Suite Setup/Teardown, Test Setup/Teardown y Tags.
Library             OperatingSystem
Library             Collections
Resource            ../resources/telecom_keywords.resource
Resource            ../variables/config_vars.robot

# ── Control de ejecución a nivel de suite ─────────────────────────────────
Suite Setup         Inicializar Entorno De Suite
Suite Teardown      Limpiar Entorno De Suite

# ── Setup/Teardown por defecto para TODOS los tests de esta suite ──────────
Test Setup          Preparar Test De Facturación
Test Teardown       Finalizar Test De Facturación


*** Variables ***
${DESCUENTO_PROMO}      15
${UMBRAL_CREDITO}       100


*** Test Cases ***

# ──────────────────────────────────────────────────────────────────────────
# TESTS DE HUMO (smoke) — Validaciones rápidas de sanidad
# ──────────────────────────────────────────────────────────────────────────

El sistema de facturación responde correctamente
    [Documentation]    Verifica que las variables de configuración básica
    ...                están disponibles y tienen valores válidos.
    [Tags]    smoke    critical
    Log    Verificando configuración básica del sistema de facturación
    Should Not Be Empty    ${DESCUENTO_PROMO}
    Should Be True    ${DESCUENTO_PROMO} > 0
    Log    Configuración básica validada — descuento: ${DESCUENTO_PROMO}%

El directorio temporal fue creado por Suite Setup
    [Documentation]    Confirma que el Suite Setup creó correctamente
    ...                el directorio de trabajo temporal.
    [Tags]    smoke    infrastructure
    Directory Should Exist    ${TEMP_DIR}
    File Should Exist         ${LOG_INIT_FILE}
    ${contenido}=    Get File    ${LOG_INIT_FILE}
    Should Contain    ${contenido}    Suite iniciada
    Log    Directorio temporal verificado: ${TEMP_DIR}

# ──────────────────────────────────────────────────────────────────────────
# TESTS DE FACTURACIÓN (billing) — Lógica de negocio de facturación
# ──────────────────────────────────────────────────────────────────────────

Calcular factura con descuento promocional
    [Documentation]    Aplica un descuento del ${DESCUENTO_PROMO}% y verifica
    ...                que el monto final es correcto.
    [Tags]    smoke    billing    regression
    ${monto_original}=    Set Variable    ${200.00}
    ${descuento}=         Evaluate    ${monto_original} * ${DESCUENTO_PROMO} / 100
    ${monto_final}=       Evaluate    ${monto_original} - ${descuento}
    Should Be True    ${monto_final} < ${monto_original}
    ...    msg=El monto con descuento debe ser menor al original
    Should Be True    ${monto_final} == 170.0
    ...    msg=Esperado 170.0, obtenido: ${monto_final}
    Log    Factura calculada: original=$${monto_original} | final=$${monto_final}

Verificar umbral de crédito para cliente moroso
    [Documentation]    Confirma que un cliente con deuda superior al umbral
    ...                queda marcado como bloqueado.
    [Tags]    billing    regression    critical
    ${deuda_cliente}=    Set Variable    ${150}
    Should Be True    ${deuda_cliente} > ${UMBRAL_CREDITO}
    ...    msg=La deuda ${deuda_cliente} debería superar el umbral ${UMBRAL_CREDITO}
    Log    Cliente con deuda ${deuda_cliente} supera umbral — acción: bloquear

Generar resumen de facturación mensual
    [Documentation]    Construye un diccionario de resumen y valida sus campos.
    [Tags]    billing    regression    low
    &{resumen}=    Create Dictionary
    ...    mes=Enero
    ...    total_facturas=${42}
    ...    monto_total=${85000.00}
    ...    moneda=USD
    Dictionary Should Contain Key    ${resumen}    mes
    Dictionary Should Contain Key    ${resumen}    total_facturas
    Dictionary Should Contain Key    ${resumen}    monto_total
    ${total}=    Get From Dictionary    ${resumen}    total_facturas
    Should Be True    ${total} > 0
    Log    Resumen de ${resumen}[mes]: ${total} facturas por $${resumen}[monto_total]

# ──────────────────────────────────────────────────────────────────────────
# TEST CON TEMPLATE — Validación parametrizada de planes
# ──────────────────────────────────────────────────────────────────────────

Validar catálogo de planes de telecomunicaciones
    [Documentation]    Utiliza Test Template para validar múltiples planes
    ...                con distintos valores de velocidad y precio.
    [Tags]    billing    smoke    regression
    [Template]    Validar Plan De Telecomunicaciones
    # nombre_plan              velocidad_mb    precio_usd
    Plan Básico 50MB           50              19.99
    Plan Estándar 200MB        200             39.99
    Plan Premium 1GB           1024            79.99

# ──────────────────────────────────────────────────────────────────────────
# TEST DE BAJA PRIORIDAD — Verificación auxiliar
# ──────────────────────────────────────────────────────────────────────────

Verificar lista de regiones de cobertura
    [Documentation]    Confirma que la lista de regiones contiene los valores
    ...                esperados para el sistema de facturación regional.
    [Tags]    billing    low
    @{regiones}=    Create List    Norte    Sur    Este    Oeste    Centro
    List Should Contain Value    ${regiones}    Norte
    List Should Contain Value    ${regiones}    Sur
    ${total_regiones}=    Get Length    ${regiones}
    Should Be True    ${total_regiones} == 5
    Log    Regiones validadas: ${regiones}
```

3. Guarda el archivo.

> **Nota sobre `Test Setup` / `Test Teardown` a nivel de suite vs. test case individual:**
> Las directivas `Test Setup` y `Test Teardown` en `*** Settings ***` aplican a **todos** los tests de la suite. Si un test individual necesita un setup diferente, puede sobreescribirlo con `[Setup]` y `[Teardown]` dentro del propio test case. En este laboratorio todos los tests usan el mismo setup/teardown de facturación para simplificar.

#### Salida esperada
VS Code no muestra errores de sintaxis y el archivo tiene exactamente 6 test cases.

#### Verificación
```bash
python -m robot --dryrun --nostatusrc tests/facturacion_suite.robot 2>&1 | tail -5
```
Salida esperada:
```
6 tests, 6 passed, 0 failed
```

---

### Paso 5 — Crear la sub-suite de clientes en el subdirectorio

**Objetivo:** Demostrar la jerarquía de suites creando `tests/clientes/clientes_suite.robot` con sus propios tags y setup/teardown independientes.

#### Instrucciones

1. Crea el archivo `tests/clientes/clientes_suite.robot` con el siguiente contenido:

```robot
*** Settings ***
Documentation       Sub-suite de pruebas de Clientes — Telecom Lab
...                 Módulo 02 | Lab 02-00-02
...                 Demuestra jerarquía de suites mediante subdirectorios.
Library             OperatingSystem
Library             Collections
Resource            ../../resources/telecom_keywords.resource
Resource            ../../variables/config_vars.robot

# ── Control de ejecución independiente para esta sub-suite ────────────────
Suite Setup         Preparar Test De Clientes
Suite Teardown      Finalizar Test De Clientes


*** Variables ***
${MAX_CLIENTES_ACTIVOS}     1000
${SEGMENTO_RESIDENCIAL}     residencial
${SEGMENTO_EMPRESARIAL}     empresarial


*** Test Cases ***

Verificar registro de cliente residencial nuevo
    [Documentation]    Simula el registro de un cliente residencial y valida
    ...                que los datos obligatorios están presentes.
    [Tags]    customer    smoke    critical
    &{cliente}=    Create Dictionary
    ...    id=CLI-00123
    ...    nombre=María López
    ...    segmento=${SEGMENTO_RESIDENCIAL}
    ...    plan=Plan Básico 50MB
    ...    activo=${TRUE}
    Dictionary Should Contain Key    ${cliente}    id
    Dictionary Should Contain Key    ${cliente}    nombre
    Dictionary Should Contain Key    ${cliente}    segmento
    ${segmento}=    Get From Dictionary    ${cliente}    segmento
    Should Be Equal    ${segmento}    ${SEGMENTO_RESIDENCIAL}
    Log    Cliente registrado: ${cliente}[nombre] | Segmento: ${segmento}

Verificar límite de clientes activos por segmento
    [Documentation]    Confirma que el contador de clientes no supera el
    ...                máximo permitido para el segmento empresarial.
    [Tags]    customer    regression
    ${clientes_empresariales}=    Set Variable    ${248}
    Should Be True    ${clientes_empresariales} <= ${MAX_CLIENTES_ACTIVOS}
    ...    msg=Se superó el límite de ${MAX_CLIENTES_ACTIVOS} clientes activos
    Log    Clientes empresariales activos: ${clientes_empresariales} (límite: ${MAX_CLIENTES_ACTIVOS})

Validar campos obligatorios de alta de cliente
    [Documentation]    Usa una lista de campos requeridos para verificar
    ...                que ninguno está vacío en el formulario de alta.
    [Tags]    customer    regression    low
    @{campos_requeridos}=    Create List
    ...    nombre    apellido    documento    email    telefono    plan
    @{datos_cliente}=    Create List
    ...    Carlos    Mendoza    DNI-45678    cmendoza@email.com    555-0198    Plan Estándar 200MB
    ${longitud_campos}=    Get Length    ${campos_requeridos}
    ${longitud_datos}=     Get Length    ${datos_cliente}
    Should Be Equal As Integers    ${longitud_campos}    ${longitud_datos}
    ...    msg=El número de campos requeridos debe coincidir con los datos provistos
    Log    Validación de ${longitud_campos} campos obligatorios completada

Buscar cliente por ID en lista de activos
    [Documentation]    Simula una búsqueda de cliente en la lista de IDs
    ...                activos del sistema.
    [Tags]    customer    smoke
    @{ids_activos}=    Create List
    ...    CLI-00120    CLI-00121    CLI-00122    CLI-00123    CLI-00124
    ${id_buscado}=    Set Variable    CLI-00123
    List Should Contain Value    ${ids_activos}    ${id_buscado}
    ...    msg=El cliente ${id_buscado} no fue encontrado en el sistema
    Log    Cliente ${id_buscado} encontrado en el sistema de clientes activos
```

2. Guarda el archivo.

> **¿Cómo trata Robot Framework los subdirectorios?**
> Cuando se ejecuta `robot tests/`, Robot Framework recorre recursivamente todos los subdirectorios y trata cada directorio como una **sub-suite** cuyo nombre es el del directorio. Así, `tests/clientes/` se convierte en la sub-suite `Clientes` dentro de la suite raíz `Tests`. No se requiere ninguna configuración adicional.

#### Salida esperada
El archivo `tests/clientes/clientes_suite.robot` existe y contiene 4 test cases.

#### Verificación
```bash
python -m robot --dryrun --nostatusrc tests/clientes/clientes_suite.robot 2>&1 | tail -5
```
Salida esperada:
```
4 tests, 4 passed, 0 failed
```

---

### Paso 6 — Ejecutar la suite completa y verificar la jerarquía

**Objetivo:** Ejecutar ambas suites juntas desde el directorio `tests/` para observar cómo Robot Framework construye la jerarquía automáticamente.

#### Instrucciones

1. Desde la raíz del proyecto, ejecuta la suite completa:

```bash
robot --outputdir results tests/
```

2. Observa la salida en consola. Deberías ver la jerarquía de suites:

```
==============================================================================
Tests
==============================================================================
Tests.Facturacion Suite
==============================================================================
...
Tests.Clientes
==============================================================================
Tests.Clientes.Clientes Suite
==============================================================================
...
```

3. Una vez finalizada la ejecución, abre el reporte HTML:

```bash
# ── Windows ────────────────────────────────────────────────────────────────
start results\report.html

# ── macOS ──────────────────────────────────────────────────────────────────
open results/report.html

# ── Linux ──────────────────────────────────────────────────────────────────
xdg-open results/report.html
```

4. En el reporte, navega a la vista de **Statistics by Tag** y confirma que aparecen los tags: `smoke`, `billing`, `customer`, `regression`, `critical`, `low`, `infrastructure`.

#### Salida esperada
```
==============================================================================
Tests                                                                         
==============================================================================
Tests.Facturacion Suite                                                       
==============================================================================
El sistema de facturación responde correctamente              | PASS |
El directorio temporal fue creado por Suite Setup             | PASS |
Calcular factura con descuento promocional                    | PASS |
Verificar umbral de crédito para cliente moroso               | PASS |
Generar resumen de facturación mensual                        | PASS |
Validar catálogo de planes de telecomunicaciones              | PASS |
Verificar lista de regiones de cobertura                      | PASS |
Tests.Facturacion Suite                                       | PASS |
7 tests, 7 passed, 0 failed
==============================================================================
Tests.Clientes                                                                
==============================================================================
Tests.Clientes.Clientes Suite                                                 
==============================================================================
Verificar registro de cliente residencial nuevo               | PASS |
Verificar límite de clientes activos por segmento             | PASS |
Validar campos obligatorios de alta de cliente                | PASS |
Buscar cliente por ID en lista de activos                     | PASS |
Tests.Clientes.Clientes Suite                                 | PASS |
4 tests, 4 passed, 0 failed
==============================================================================
Tests                                                         | PASS |
11 tests, 11 passed, 0 failed
==============================================================================
```

#### Verificación
```bash
# Verificar que el archivo de output existe y tiene el resultado correcto
python -c "
import xml.etree.ElementTree as ET
tree = ET.parse('results/output.xml')
root = tree.getroot()
stats = root.find('.//total/stat')
print('Total tests:', stats.get('pass'), 'passed,', stats.get('fail'), 'failed')
"
```

---

### Paso 7 — Ejecutar subconjuntos de tests con `--include` y `--exclude`

**Objetivo:** Demostrar el filtrado de ejecución usando tags simples, combinaciones con `AND` / `OR` y exclusiones con `--exclude`.

#### Instrucciones

Ejecuta cada uno de los siguientes comandos y observa cuántos tests se ejecutan en cada caso:

**7a. Solo tests con tag `smoke`:**
```bash
robot --include smoke --outputdir results/smoke tests/
```
Resultado esperado: **5 tests** (los que tienen el tag `smoke` en ambas suites).

**7b. Solo tests con tag `billing`:**
```bash
robot --include billing --outputdir results/billing tests/
```
Resultado esperado: **5 tests** de la suite de facturación.

**7c. Tests con tag `smoke` AND `billing` (deben tener AMBOS tags):**
```bash
robot --include smokeANDbilling --outputdir results/smoke_billing tests/
```
Resultado esperado: **3 tests** (los que tienen simultáneamente `smoke` y `billing`).

**7d. Tests con tag `smoke` OR `customer` (cualquiera de los dos):**
```bash
robot --include smoke --include customer --outputdir results/smoke_or_customer tests/
```
Resultado esperado: **8 tests** (unión de ambos conjuntos sin duplicados).

**7e. Todos los tests EXCEPTO los de baja prioridad (`low`):**
```bash
robot --exclude low --outputdir results/no_low tests/
```
Resultado esperado: **9 tests** (excluye los 2 tests con tag `low`).

**7f. Tests `critical` de cualquier suite:**
```bash
robot --include critical --outputdir results/critical tests/
```
Resultado esperado: **3 tests** marcados como `critical`.

> **Referencia rápida de sintaxis de filtros:**
>
> | Comando | Semántica |
> |---------|-----------|
> | `--include tagA` | Tests que tienen `tagA` |
> | `--include tagANDtagB` | Tests que tienen `tagA` Y `tagB` |
> | `--include tagA --include tagB` | Tests que tienen `tagA` O `tagB` |
> | `--exclude tagA` | Tests que NO tienen `tagA` |
> | `--include tagA --exclude tagB` | Tests con `tagA` pero sin `tagB` |

#### Salida esperada (ejemplo para comando 7c)
```
==============================================================================
Tests
==============================================================================
...
3 tests, 3 passed, 0 failed
==============================================================================
Output:  .../results/smoke_billing/output.xml
```

#### Verificación
Confirma que el directorio `results/` contiene los subdirectorios de cada ejecución:
```bash
# ── Windows ────────────────────────────────────────────────────────────────
dir results /B

# ── macOS / Linux ──────────────────────────────────────────────────────────
ls results/
```

---

### Paso 8 — Verificar el comportamiento del Test Template

**Objetivo:** Inspeccionar en detalle el log del test con `Test Template` para entender cómo Robot Framework itera sobre las filas de datos.

#### Instrucciones

1. Ejecuta únicamente el test de template usando su nombre exacto:

```bash
robot --test "Validar catálogo de planes de telecomunicaciones" --outputdir results/template tests/facturacion_suite.robot
```

2. Abre `results/template/log.html` en el navegador.

3. Expande el test case `Validar catálogo de planes de telecomunicaciones` en el log. Deberías ver **3 iteraciones** del template, cada una con sus propios argumentos:

```
Validar catálogo de planes de telecomunicaciones
  ├── Validar Plan De Telecomunicaciones  Plan Básico 50MB  50  19.99     → PASS
  ├── Validar Plan De Telecomunicaciones  Plan Estándar 200MB  200  39.99 → PASS
  └── Validar Plan De Telecomunicaciones  Plan Premium 1GB  1024  79.99   → PASS
```

4. Ahora añade una **cuarta fila** al template con un valor intencionalmente incorrecto para ver cómo falla una iteración individual sin detener las demás. Edita el test case en `facturacion_suite.robot`:

```robot
Validar catálogo de planes de telecomunicaciones
    [Documentation]    ...
    [Tags]    billing    smoke    regression
    [Template]    Validar Plan De Telecomunicaciones
    # nombre_plan              velocidad_mb    precio_usd
    Plan Básico 50MB           50              19.99
    Plan Estándar 200MB        200             39.99
    Plan Premium 1GB           1024            79.99
    Tarifa Especial            -10             0.00      # ← valor inválido
```

5. Ejecuta nuevamente:
```bash
robot --test "Validar catálogo de planes de telecomunicaciones" --outputdir results/template_fail tests/facturacion_suite.robot
```

6. Observa que **las 3 primeras iteraciones pasan** y solo la cuarta falla. El test case completo se marca como FAIL, pero el log muestra exactamente cuál iteración falló y por qué.

7. **Restaura** el test case a su versión original (sin la cuarta fila) antes de continuar.

#### Salida esperada (con la fila inválida)
```
Validar catálogo de planes de telecomunicaciones             | FAIL |
Several template iterations failed:
  Round 4: 'La velocidad debe ser mayor que cero'
```

#### Verificación
Después de restaurar el archivo, ejecuta:
```bash
robot --test "Validar catálogo de planes de telecomunicaciones" --outputdir results/template_ok tests/facturacion_suite.robot
```
Resultado: `1 test, 1 passed, 0 failed`.

---

### Paso 9 — Verificar el ciclo completo de Setup/Teardown con evidencias

**Objetivo:** Confirmar que los archivos temporales son creados por el Suite Setup y eliminados por el Suite Teardown, validando el ciclo completo.

#### Instrucciones

1. Antes de ejecutar, confirma que `temp_data/` está vacío (o no existe):

```bash
# ── Windows ────────────────────────────────────────────────────────────────
if exist temp_data\suite_init.log (echo "EXISTE - limpiar antes de probar") else (echo "OK - directorio limpio")

# ── macOS / Linux ──────────────────────────────────────────────────────────
[ -f temp_data/suite_init.log ] && echo "EXISTE - limpiar antes de probar" || echo "OK - directorio limpio"
```

2. Ejecuta **solo** el Suite Setup y los tests de smoke para observar la creación de archivos. Usa `--include smoke` para ejecutar rápido:

```bash
robot --include smoke --outputdir results/setup_teardown_test tests/facturacion_suite.robot
```

3. **Inmediatamente después** de que termine la ejecución (antes de que el Suite Teardown elimine los archivos), el log habrá registrado su creación. Revisa el log HTML:

```bash
# ── Windows ────────────────────────────────────────────────────────────────
start results\setup_teardown_test\log.html

# ── macOS ──────────────────────────────────────────────────────────────────
open results/setup_teardown_test/log.html
```

4. En el log, busca la sección **Suite Setup** y confirma que aparece:
   - `Iniciando Suite Setup de Telecom`
   - `Directorio temporal creado: .../temp_data`
   - `Archivo de inicialización creado: .../temp_data/suite_init.log`

5. Busca la sección **Suite Teardown** y confirma que aparece:
   - `Iniciando Suite Teardown de Telecom`
   - `Archivos temporales eliminados correctamente`

6. Verifica en el sistema de archivos que `temp_data/suite_init.log` ya **no existe** (fue eliminado por el Teardown):

```bash
# ── Windows ────────────────────────────────────────────────────────────────
if exist temp_data\suite_init.log (echo "ERROR: el teardown no eliminó el archivo") else (echo "OK: teardown funcionó correctamente")

# ── macOS / Linux ──────────────────────────────────────────────────────────
[ -f temp_data/suite_init.log ] && echo "ERROR: el teardown no eliminó el archivo" || echo "OK: teardown funcionó correctamente"
```

#### Salida esperada
```
OK: teardown funcionó correctamente
```

#### Verificación
Abre `results/setup_teardown_test/log.html` y confirma que las secciones de Setup y Teardown están marcadas en verde (PASS).

---

## 7. Validación y Pruebas Finales

Ejecuta la batería de validación completa para confirmar que todo el laboratorio funciona correctamente:

```bash
# ── 1. Ejecución completa con todos los tests ──────────────────────────────
robot --outputdir results/final_validation tests/

# ── 2. Filtro smoke AND critical ──────────────────────────────────────────
robot --include smokeANDcritical --outputdir results/final_smoke_critical tests/

# ── 3. Solo suite de clientes ─────────────────────────────────────────────
robot --outputdir results/final_customers tests/clientes/

# ── 4. Excluir tests de baja prioridad ────────────────────────────────────
robot --exclude low --outputdir results/final_no_low tests/
```

### Tabla de resultados esperados

| Comando                             | Tests esperados | Resultado esperado |
|-------------------------------------|-----------------|--------------------|
| `robot tests/`                      | 11              | 11 passed, 0 failed |
| `--include smokeANDcritical`        | 3               | 3 passed, 0 failed  |
| `robot tests/clientes/`             | 4               | 4 passed, 0 failed  |
| `--exclude low`                     | 9               | 9 passed, 0 failed  |

### Checklist de validación

- [ ] El directorio `results/final_validation/` contiene `output.xml`, `log.html` y `report.html`
- [ ] En `report.html`, la sección **Statistics by Tag** muestra todos los tags definidos
- [ ] El test `Validar catálogo de planes de telecomunicaciones` muestra 3 iteraciones en el log
- [ ] El Suite Setup crea `temp_data/` y el Suite Teardown lo limpia (verificado en el log)
- [ ] La sub-suite `Tests.Clientes` aparece anidada bajo `Tests` en el reporte
- [ ] Ningún test muestra estado FAIL en la ejecución final

---

## 8. Solución de Problemas

### Problema 1: `Variable '${TEMP_DIR}' not found` al ejecutar la suite

**Síntoma:**
```
Variable '${TEMP_DIR}' not found.
```
El Suite Setup falla en la primera línea con un error de variable no encontrada.

**Causa:**
El archivo `resources/telecom_keywords.resource` no tiene importado `../variables/config_vars.robot` en su sección `*** Settings ***`, o la ruta relativa es incorrecta. Dado que `${TEMP_DIR}` se define en `config_vars.robot`, si ese archivo no se carga en el contexto de la keyword, la variable no está disponible.

**Solución:**
1. Abre `resources/telecom_keywords.resource` y verifica que la sección `*** Settings ***` contiene exactamente:
   ```robot
   *** Settings ***
   Library     OperatingSystem
   Library     Collections
   Resource    ../variables/config_vars.robot
   ```
2. Confirma que la ruta `../variables/config_vars.robot` es correcta relativa a la ubicación de `telecom_keywords.resource`. Si el archivo resource está en `resources/`, entonces `../variables/` apunta correctamente a `variables/`.
3. Ejecuta el dry-run para verificar:
   ```bash
   python -m robot --dryrun --nostatusrc resources/telecom_keywords.resource
   ```

---

### Problema 2: Los tests de la sub-suite `clientes/` no aparecen al ejecutar `robot tests/`

**Síntoma:**
Solo se ejecutan los 7 tests de `facturacion_suite.robot` y los 4 tests de `clientes_suite.robot` no aparecen. El total es 7 en lugar de 11.

**Causa:**
El subdirectorio `tests/clientes/` no fue creado correctamente, o el archivo `clientes_suite.robot` tiene una extensión incorrecta (por ejemplo, `.txt` o `.Robot` con mayúscula en Windows). Robot Framework solo reconoce archivos con extensión `.robot` o `.resource` (en minúsculas en sistemas case-sensitive como Linux).

**Solución:**
1. Verifica que el directorio y el archivo existen con el nombre correcto:
   ```bash
   # ── Windows ──────────────────────────────────────────────────────────────
   dir tests\clientes
   
   # ── macOS / Linux ────────────────────────────────────────────────────────
   ls -la tests/clientes/
   ```
2. Confirma que el archivo se llama exactamente `clientes_suite.robot` (sin mayúsculas, sin espacios, con extensión `.robot`).
3. En Linux/macOS, si el archivo tiene extensión `.Robot`, renómbralo:
   ```bash
   mv tests/clientes/clientes_suite.Robot tests/clientes/clientes_suite.robot
   ```
4. Ejecuta el dry-run apuntando directamente al subdirectorio para confirmar que Robot Framework lo detecta:
   ```bash
   python -m robot --dryrun --nostatusrc tests/clientes/
   ```
   Debe mostrar `4 tests, 4 passed`.

---

## 9. Limpieza

Al finalizar el laboratorio, ejecuta los siguientes pasos para dejar el entorno en estado limpio:

```bash
# ── 1. Verificar que temp_data está limpio (el Teardown debería haberlo hecho)
# ── Windows ────────────────────────────────────────────────────────────────
if exist temp_data\*.log del /Q temp_data\*.log

# ── macOS / Linux ──────────────────────────────────────────────────────────
rm -f temp_data/*.log

# ── 2. Consolidar todos los resultados en una carpeta final ────────────────
robot --outputdir results/lab-02-00-02-final tests/

# ── 3. Opcional: eliminar carpetas de resultados intermedios ───────────────
# ── Windows ────────────────────────────────────────────────────────────────
for /D %i in (results\smoke results\billing results\smoke_billing results\smoke_or_customer results\no_low results\critical results\template results\template_fail results\template_ok results\setup_teardown_test results\final_validation results\final_smoke_critical results\final_customers results\final_no_low) do if exist %i rmdir /S /Q %i

# ── macOS / Linux ──────────────────────────────────────────────────────────
rm -rf results/smoke results/billing results/smoke_billing results/smoke_or_customer \
       results/no_low results/critical results/template results/template_fail \
       results/template_ok results/setup_teardown_test results/final_validation \
       results/final_smoke_critical results/final_customers results/final_no_low

# ── 4. Desactivar el entorno virtual ──────────────────────────────────────
deactivate
```

> 💡 **Recomendación:** Guarda una copia de respaldo del proyecto completo antes de comenzar el siguiente módulo:
> ```bash
> # ── Windows ──────────────────────────────────────────────────────────────
> xcopy /E /I proyecto-telecom proyecto-telecom-backup-lab02-00-02
> 
> # ── macOS / Linux ────────────────────────────────────────────────────────
> cp -r proyecto-telecom proyecto-telecom-backup-lab02-00-02
> ```

---

## 10. Resumen

En este laboratorio implementaste los mecanismos de control de ejecución más importantes de Robot Framework 7.x:

| Concepto | Lo que aprendiste |
|----------|-------------------|
| **Suite Setup / Teardown** | Inicialización y limpieza a nivel de suite usando `OperatingSystem` para gestionar archivos temporales |
| **Test Setup / Teardown** | Precondiciones y postcondiciones aplicadas automáticamente a todos los tests de una suite |
| **Tags y filtrado** | Asignación de tags por categoría y criticidad; uso de `--include`, `--exclude` y operadores `AND` / `OR` |
| **Jerarquía de suites** | Cómo Robot Framework trata subdirectorios como sub-suites anidadas sin configuración adicional |
| **Test Template** | Parametrización compacta de un test case con múltiples filas de datos en formato tabla |
| **Run Keywords / No Operation** | Uso de keywords BuiltIn para control de flujo condicional en setup/teardown |

### Patrones clave para recordar

```robot
# ── Patrón 1: Setup/Teardown a nivel de suite ─────────────────────────────
Suite Setup      Mi Keyword De Inicialización
Suite Teardown   Mi Keyword De Limpieza

# ── Patrón 2: Setup/Teardown a nivel de test ──────────────────────────────
Test Setup       Preparar Contexto De Test
Test Teardown    Limpiar Contexto De Test

# ── Patrón 3: Tags y filtrado ─────────────────────────────────────────────
[Tags]    smoke    billing    critical
# Ejecución: robot --include smokeANDbilling --exclude low tests/

# ── Patrón 4: Test Template con tabla ─────────────────────────────────────
Mi Test Con Template
    [Template]    Mi Keyword
    argumento1    argumento2    argumento3
    valor1a       valor2a       valor3a
    valor1b       valor2b       valor3b
```

### Recursos adicionales

- [Robot Framework User Guide — Suite Setup and Teardown](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#suite-setup-and-teardown)
- [Robot Framework User Guide — Tagging test cases](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#tagging-test-cases)
- [Robot Framework User Guide — Test templates](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#test-templates)
- [OperatingSystem Library — Referencia completa](https://robotframework.org/robotframework/latest/libraries/OperatingSystem.html)
- [Robot Framework User Guide — Organizing test suites](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#organizing-test-suites)

---
