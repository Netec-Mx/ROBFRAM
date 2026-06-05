# Práctica 7: Escritura de escenarios BDD para un flujo comercial de telecomunicaciones

## Metadatos

| Campo            | Detalle                                      |
|------------------|----------------------------------------------|
| **Duración**     | 72 minutos                                   |
| **Complejidad**  | Media                                        |
| **Nivel Bloom**  | Crear                                        |
| **Módulo**       | 4 — BDD y Gherkin en Robot Framework         |
| **Laboratorio**  | 04-00-01 (Práctica 7)                        |

---

## Descripción General

En este laboratorio aplicarás la sintaxis Gherkin nativa de Robot Framework para escribir escenarios BDD que describan tres flujos comerciales de una empresa de telecomunicaciones ficticia: activación de línea móvil, cambio de plan de datos y procesamiento de pago de factura. Organizarás los escenarios en una estructura de directorios por dominio de negocio (`features/mobile/`, `features/billing/`, `features/plans/`) y mapearás cada paso Gherkin a keywords de implementación ubicadas en archivos `.resource` separados. El objetivo es experimentar de forma directa cómo BDD separa la capa de descripción de negocio de la capa técnica, produciendo especificaciones que pueden ser leídas y validadas por stakeholders no técnicos.

---

## Objetivos de Aprendizaje

Al finalizar este laboratorio, serás capaz de:

- [ ] Escribir escenarios de prueba completos usando las palabras clave Gherkin nativas de Robot Framework (`Given`, `When`, `Then`, `And`, `But`) en lenguaje de negocio comprensible para stakeholders no técnicos.
- [ ] Mapear cada paso Gherkin a una keyword técnica de implementación en archivos `.resource` separados, manteniendo la separación entre la capa de descripción y la capa de ejecución.
- [ ] Organizar múltiples feature files en una estructura de directorios que represente dominios de negocio (`mobile`, `billing`, `plans`) de una empresa de telecomunicaciones.
- [ ] Ejecutar suites BDD y verificar que los reportes HTML de Robot Framework reflejan los pasos Gherkin con nombres legibles por el negocio.
- [ ] Explicar el valor de BDD para la alineación entre equipos de TI y negocio mediante la comparación entre la capa de escenarios y la capa de implementación.

---

## Prerrequisitos

### Conocimientos Previos

| Conocimiento                                                                 | Nivel Requerido |
|------------------------------------------------------------------------------|-----------------|
| Estructura de proyecto Robot Framework (archivos `.robot`, `.resource`)      | Aplicado        |
| Uso de archivos Resource y variables en Robot Framework                      | Aplicado        |
| Comprensión de la diferencia entre descripción de comportamiento e implementación técnica | Conceptual |
| Concepto de criterios de aceptación en metodologías ágiles                  | Básico (deseable) |

### Acceso y Herramientas

- Entorno virtual Python (`venv`) **activo** con Robot Framework 7.x instalado.
- VS Code con la extensión **Robot Framework Language Server** instalada y configurada.
- Haber completado satisfactoriamente los laboratorios de los Módulos 1 y 2.
- Conexión a internet (solo para verificación de instalación de paquetes si fuera necesario).

---

## Entorno de Laboratorio

### Hardware Mínimo

| Componente        | Mínimo Requerido                                      |
|-------------------|-------------------------------------------------------|
| Procesador        | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos)       |
| RAM               | 8 GB                                                  |
| Almacenamiento    | 5 GB libres                                           |
| Pantalla          | Resolución 1280×768 (para reportes HTML)              |
| Red               | No requerida (laboratorio sin llamadas externas)      |

### Software Requerido

| Software                         | Versión Mínima | Propósito                              |
|----------------------------------|----------------|----------------------------------------|
| Python                           | 3.10+          | Entorno de ejecución                   |
| Robot Framework                  | 7.x            | Motor de pruebas y soporte Gherkin     |
| VS Code                          | 1.85+          | Editor con navegación entre steps      |
| Robot Framework Language Server  | 1.12+          | Autocompletado y navegación            |
| pip                              | 23.x+          | Gestión de paquetes                    |

### Configuración del Entorno

> ⚠️ **IMPORTANTE:** Todos los comandos deben ejecutarse con el entorno virtual **activo**. Verifica que el prompt muestra `(venv)` antes de continuar.

#### Verificar y activar el entorno virtual

**Windows (cmd):**
```cmd
cd C:\proyectos\robot-telecom
Scripts\activate
```

**Windows (PowerShell):**
```powershell
cd C:\proyectos\robot-telecom
.\Scripts\Activate.ps1
```

**macOS / Linux (bash/zsh):**
```bash
cd ~/proyectos/robot-telecom
source bin/activate
```

#### Verificar la instalación de Robot Framework

```bash
robot --version
python -m robot --version
```

**Salida esperada:**
```
Robot Framework 7.x.x (Python 3.x.x on ...)
```

#### Verificar que no se requieren librerías adicionales

Este laboratorio utiliza **únicamente** la librería `BuiltIn` de Robot Framework (incluida por defecto). No se requieren instalaciones adicionales.

```bash
pip list | grep -i robot
# Windows cmd:
pip list | findstr robot
```

---

## Pasos del Laboratorio

### Visión General de la Estructura Final

Antes de comenzar, observa la estructura de directorios que construirás durante este laboratorio:

```
robot-telecom/
└── features/
    ├── mobile/
    │   ├── activacion_linea.robot
    │   └── keywords/
    │       └── mobile_steps.resource
    ├── billing/
    │   ├── pago_factura.robot
    │   └── keywords/
    │       └── billing_steps.resource
    └── plans/
        ├── cambio_plan.robot
        └── keywords/
            └── plans_steps.resource
```

---

### Paso 1: Crear la Estructura de Directorios del Proyecto BDD

**Objetivo:** Establecer la organización de directorios por dominio de negocio que refleje la arquitectura BDD propuesta.

#### Instrucciones

1. Abre una terminal con el entorno virtual activo y navega a la raíz de tu proyecto:

   **Windows (cmd/PowerShell):**
   ```cmd
   cd C:\proyectos\robot-telecom
   ```

   **macOS / Linux:**
   ```bash
   cd ~/proyectos/robot-telecom
   ```

2. Crea la estructura de directorios completa con un único comando:

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path `
     features\mobile\keywords, `
     features\billing\keywords, `
     features\plans\keywords
   ```

   **Windows (cmd):**
   ```cmd
   mkdir features\mobile\keywords
   mkdir features\billing\keywords
   mkdir features\plans\keywords
   ```

   **macOS / Linux:**
   ```bash
   mkdir -p features/mobile/keywords \
             features/billing/keywords \
             features/plans/keywords
   ```

3. Verifica la estructura creada:

   **Windows (PowerShell):**
   ```powershell
   Get-ChildItem -Recurse features | Select-Object FullName
   ```

   **macOS / Linux:**
   ```bash
   find features -type d
   ```

#### Salida Esperada

```
features/mobile
features/mobile/keywords
features/billing
features/billing/keywords
features/plans
features/plans/keywords
```

#### Verificación

Confirma en VS Code (panel Explorer) que los tres dominios (`mobile`, `billing`, `plans`) aparecen como subdirectorios de `features/`, cada uno con su carpeta `keywords/` interna.

---

### Paso 2: Crear el Archivo Resource para el Dominio Mobile

**Objetivo:** Implementar las keywords técnicas que soportarán los pasos Gherkin del dominio de activación de línea móvil, separando completamente la implementación de la descripción.

#### Instrucciones

1. Crea el archivo `features/mobile/keywords/mobile_steps.resource` y escribe el siguiente contenido:

   ```robot
   *** Settings ***
   Documentation    Keywords de implementación para el dominio Mobile.
   ...              Simulan operaciones de activación de línea móvil
   ...              usando únicamente la librería BuiltIn.
   Library          BuiltIn

   *** Variables ***
   ${ESTADO_LINEA_INICIAL}    sin_plan_activo
   ${PLAN_SELECCIONADO}       ${EMPTY}
   ${LINEA_ACTIVADA}          ${FALSE}
   ${NOTIFICACION_ENVIADA}    ${FALSE}

   *** Keywords ***
   El cliente "${nombre}" tiene una línea activa sin plan de datos
       [Documentation]    Verifica que el cliente existe y su línea no tiene plan asignado.
       Log    Verificando estado inicial del cliente: ${nombre}
       Log    Estado de la línea: ${ESTADO_LINEA_INICIAL}
       Should Be Equal    ${ESTADO_LINEA_INICIAL}    sin_plan_activo
       Set Test Variable    ${CLIENTE_ACTIVO}    ${nombre}

   El cliente selecciona el plan "${nombre_plan}"
       [Documentation]    Registra la selección del plan de datos por parte del cliente.
       Log    El cliente ${CLIENTE_ACTIVO} selecciona el plan: ${nombre_plan}
       Set Test Variable    ${PLAN_SELECCIONADO}    ${nombre_plan}
       Should Not Be Empty    ${PLAN_SELECCIONADO}

   El cliente confirma la activación con su número de documento
       [Documentation]    Simula la confirmación de identidad para activar la línea.
       Log    Confirmando identidad del cliente: ${CLIENTE_ACTIVO}
       Log    Documento verificado correctamente.
       Set Test Variable    ${CONFIRMACION_IDENTIDAD}    verificada

   El plan "${nombre_plan}" queda activo en la línea del cliente
       [Documentation]    Verifica que el plan fue activado correctamente.
       Log    Activando plan: ${nombre_plan} para el cliente: ${CLIENTE_ACTIVO}
       Set Test Variable    ${LINEA_ACTIVADA}    ${TRUE}
       Should Be True    ${LINEA_ACTIVADA}
       Log    Plan ${nombre_plan} activado exitosamente.

   El cliente recibe una notificación de bienvenida por SMS
       [Documentation]    Simula el envío de SMS de confirmación al cliente.
       Log    Enviando SMS de bienvenida al cliente: ${CLIENTE_ACTIVO}
       Set Test Variable    ${NOTIFICACION_ENVIADA}    ${TRUE}
       Should Be True    ${NOTIFICACION_ENVIADA}
       Log    SMS enviado correctamente.

   El cliente "${nombre}" tiene una línea activa con plan vigente
       [Documentation]    Precondición: cliente con línea y plan ya activos.
       Log    Cliente ${nombre} tiene línea activa con plan vigente.
       Set Test Variable    ${CLIENTE_ACTIVO}    ${nombre}
       Set Test Variable    ${ESTADO_LINEA}    activa_con_plan

   El sistema detecta que el documento de identidad no es válido
       [Documentation]    Simula un fallo de validación de documento.
       Log    Simulando documento de identidad inválido.
       Set Test Variable    ${DOCUMENTO_VALIDO}    ${FALSE}

   El sistema rechaza la activación con el mensaje "${mensaje}"
       [Documentation]    Verifica que el sistema genera el mensaje de rechazo correcto.
       Log    Sistema rechaza activación. Mensaje: ${mensaje}
       Should Not Be Empty    ${mensaje}
       Log    Activación rechazada correctamente con mensaje esperado.

   La línea permanece en estado sin plan activo
       [Documentation]    Verifica que el estado de la línea no cambió.
       Log    Verificando que la línea no fue modificada.
       Log    Estado de línea sin cambios: sin_plan_activo
   ```

2. Guarda el archivo (`Ctrl+S` / `Cmd+S`).

#### Salida Esperada

VS Code debe mostrar el archivo sin errores de sintaxis. El Language Server resaltará las keywords y variables correctamente.

#### Verificación

En la terminal, ejecuta una validación de sintaxis en seco:

```bash
python -m robot --dryrun features/mobile/keywords/mobile_steps.resource
```

> **Nota:** Si el comando reporta que no hay test cases (es un archivo `.resource`, no `.robot`), eso es correcto. Lo importante es que no reporte errores de sintaxis.

---

### Paso 3: Escribir los Escenarios BDD para Activación de Línea Móvil

**Objetivo:** Crear el feature file del dominio mobile con al menos dos escenarios BDD completos usando sintaxis Gherkin nativa.

#### Instrucciones

1. Crea el archivo `features/mobile/activacion_linea.robot` con el siguiente contenido:

   ```robot
   *** Settings ***
   Documentation    Feature: Activación de Línea Móvil
   ...
   ...              Como área comercial de TelecomCorp,
   ...              quiero que los clientes puedan activar su línea móvil
   ...              para que puedan acceder a los servicios de datos de forma inmediata.
   ...
   ...              Dominio: Mobile | Versión: 1.0 | Responsable: QA Comercial
   Resource         keywords/mobile_steps.resource

   *** Test Cases ***
   # ==========================================================================
   # Escenario 1: Activación exitosa de línea móvil con plan de datos
   # Criterio de aceptación: AC-MOB-001
   # ==========================================================================
   Cliente nuevo activa línea móvil con plan de datos pospago exitosamente
       [Documentation]    Escenario: Un cliente nuevo con línea sin plan activo selecciona
       ...                un plan de datos pospago y completa la activación correctamente.
       ...                Trazabilidad: Historia US-MOB-042 / AC-MOB-001
       [Tags]             bdd    mobile    activacion    smoke    positivo

       Given el cliente "María González" tiene una línea activa sin plan de datos
       When el cliente selecciona el plan "Datos 50GB Pospago"
       And el cliente confirma la activación con su número de documento
       Then el plan "Datos 50GB Pospago" queda activo en la línea del cliente
       And el cliente recibe una notificación de bienvenida por SMS

   # ==========================================================================
   # Escenario 2: Rechazo de activación por documento de identidad inválido
   # Criterio de aceptación: AC-MOB-002
   # ==========================================================================
   Sistema rechaza activación de línea cuando el documento de identidad no es válido
       [Documentation]    Escenario: El sistema debe rechazar la solicitud de activación
       ...                cuando el documento presentado no supera la validación,
       ...                manteniendo la línea en su estado original.
       ...                Trazabilidad: Historia US-MOB-042 / AC-MOB-002
       [Tags]             bdd    mobile    activacion    negativo    validacion

       Given el cliente "Carlos Ruiz" tiene una línea activa sin plan de datos
       When el sistema detecta que el documento de identidad no es válido
       Then el sistema rechaza la activación con el mensaje "Documento de identidad no válido. Por favor verifique sus datos."
       And la línea permanece en estado sin plan activo

   # ==========================================================================
   # Escenario 3: Activación con plan de datos prepago
   # Criterio de aceptación: AC-MOB-003
   # ==========================================================================
   Cliente activa línea móvil con plan prepago de entrada
       [Documentation]    Escenario: Un cliente selecciona el plan prepago de menor costo
       ...                disponible y completa la activación sin incidentes.
       ...                Trazabilidad: Historia US-MOB-043 / AC-MOB-003
       [Tags]             bdd    mobile    activacion    prepago    positivo

       Given el cliente "Ana Torres" tiene una línea activa sin plan de datos
       When el cliente selecciona el plan "Prepago Básico 5GB"
       And el cliente confirma la activación con su número de documento
       Then el plan "Prepago Básico 5GB" queda activo en la línea del cliente
       And el cliente recibe una notificación de bienvenida por SMS
   ```

2. Guarda el archivo.

#### Salida Esperada

El archivo debe mostrarse en VS Code con resaltado de sintaxis correcto. Las palabras `Given`, `When`, `Then`, `And` deben aparecer resaltadas, y las keywords referenciadas deben ser navegables (Ctrl+Click / Cmd+Click).

#### Verificación

Ejecuta únicamente este feature file en modo `--dryrun` para validar que todos los pasos resuelven a keywords:

```bash
python -m robot --dryrun features/mobile/activacion_linea.robot
```

**Salida esperada (fragmento):**
```
==============================================================================
Activacion Linea
==============================================================================
Cliente nuevo activa línea móvil con plan de datos pospago exitosamente
...                                                                   | PASS |
Sistema rechaza activación de línea cuando el documento de identidad no es válido
...                                                                   | PASS |
Cliente activa línea móvil con plan prepago de entrada                | PASS |
==============================================================================
Activacion Linea                                                      | PASS |
3 tests, 3 passed, 0 failed
```

---

### Paso 4: Crear el Archivo Resource para el Dominio Billing

**Objetivo:** Implementar las keywords técnicas que soportarán los pasos Gherkin del dominio de procesamiento de pago de facturas.

#### Instrucciones

1. Crea el archivo `features/billing/keywords/billing_steps.resource`:

   ```robot
   *** Settings ***
   Documentation    Keywords de implementación para el dominio Billing.
   ...              Simulan operaciones de procesamiento de pagos de factura
   ...              usando únicamente la librería BuiltIn.
   Library          BuiltIn

   *** Variables ***
   ${FACTURA_PENDIENTE}       ${TRUE}
   ${MONTO_FACTURA}           ${0.0}
   ${PAGO_PROCESADO}          ${FALSE}
   ${RECIBO_GENERADO}         ${FALSE}

   *** Keywords ***
   El cliente "${nombre}" tiene una factura pendiente de pago por "${monto}" pesos
       [Documentation]    Precondición: cliente con factura emitida y pendiente de cobro.
       Log    Cliente: ${nombre} | Factura pendiente: $${monto} pesos
       Set Test Variable    ${CLIENTE_FACTURA}    ${nombre}
       Set Test Variable    ${MONTO_FACTURA}      ${monto}
       Should Be True    ${FACTURA_PENDIENTE}

   El cliente accede al portal de pagos con sus credenciales
       [Documentation]    Simula el inicio de sesión en el portal de pagos en línea.
       Log    El cliente ${CLIENTE_FACTURA} accede al portal de pagos.
       Log    Credenciales verificadas correctamente.
       Set Test Variable    ${SESION_PORTAL}    activa

   El cliente selecciona el método de pago "${metodo}"
       [Documentation]    Registra el método de pago elegido por el cliente.
       Log    Método de pago seleccionado: ${metodo}
       Set Test Variable    ${METODO_PAGO}    ${metodo}
       Should Not Be Empty    ${METODO_PAGO}

   El cliente confirma el pago del monto total
       [Documentation]    Simula la confirmación y procesamiento del pago total.
       Log    Procesando pago de $${MONTO_FACTURA} pesos mediante ${METODO_PAGO}
       Set Test Variable    ${PAGO_PROCESADO}    ${TRUE}
       Should Be True    ${PAGO_PROCESADO}

   La factura queda marcada como pagada en el sistema
       [Documentation]    Verifica que el estado de la factura se actualizó correctamente.
       Log    Factura marcada como PAGADA para el cliente: ${CLIENTE_FACTURA}
       Set Test Variable    ${FACTURA_PENDIENTE}    ${FALSE}
       Should Not Be True    ${FACTURA_PENDIENTE}

   El cliente recibe un recibo de pago por correo electrónico
       [Documentation]    Simula el envío del comprobante de pago por email.
       Log    Enviando recibo de pago por email al cliente: ${CLIENTE_FACTURA}
       Set Test Variable    ${RECIBO_GENERADO}    ${TRUE}
       Should Be True    ${RECIBO_GENERADO}
       Log    Recibo enviado exitosamente.

   El cliente intenta pagar con una tarjeta de crédito vencida
       [Documentation]    Simula el intento de pago con tarjeta expirada.
       Log    Intento de pago con tarjeta vencida detectado.
       Set Test Variable    ${TARJETA_VALIDA}    ${FALSE}
       Log    Tarjeta marcada como vencida en el sistema.

   El sistema detecta que la tarjeta está vencida
       [Documentation]    Simula la validación del sistema que detecta la expiración.
       Log    Sistema detecta: tarjeta de crédito vencida.
       Should Not Be True    ${TARJETA_VALIDA}

   El pago es rechazado con el código de error "${codigo}"
       [Documentation]    Verifica que el sistema genera el código de error correcto.
       Log    Pago rechazado. Código de error: ${codigo}
       Should Not Be Empty    ${codigo}

   La factura permanece en estado pendiente de pago
       [Documentation]    Verifica que la factura no cambió de estado tras el rechazo.
       Log    Verificando que la factura sigue pendiente de pago.
       Should Be True    ${FACTURA_PENDIENTE}
       Log    Estado de factura sin cambios: pendiente.

   El cliente tiene saldo insuficiente en su cuenta digital
       [Documentation]    Simula la condición de saldo insuficiente en billetera digital.
       Log    Saldo insuficiente detectado para el cliente: ${CLIENTE_FACTURA}
       Set Test Variable    ${SALDO_SUFICIENTE}    ${FALSE}

   El sistema notifica al cliente que el saldo es insuficiente
       [Documentation]    Verifica que el sistema envía la notificación de saldo insuficiente.
       Log    Notificando al cliente: saldo insuficiente para completar el pago.
       Should Not Be True    ${SALDO_SUFICIENTE}
       Log    Notificación enviada al cliente.

   El cliente es redirigido a opciones de recarga de saldo
       [Documentation]    Simula la redirección al flujo de recarga de saldo.
       Log    Redirigiendo al cliente a opciones de recarga de saldo.
       Log    Opciones disponibles: transferencia bancaria, efectivo, tarjeta.
   ```

2. Guarda el archivo.

#### Verificación

```bash
python -m robot --dryrun features/billing/keywords/billing_steps.resource
```

---

### Paso 5: Escribir los Escenarios BDD para Procesamiento de Pago de Factura

**Objetivo:** Crear el feature file del dominio billing con escenarios que cubran el flujo de pago exitoso y escenarios alternativos de error.

#### Instrucciones

1. Crea el archivo `features/billing/pago_factura.robot`:

   ```robot
   *** Settings ***
   Documentation    Feature: Procesamiento de Pago de Factura
   ...
   ...              Como cliente de TelecomCorp,
   ...              quiero poder pagar mi factura mensual a través del portal en línea
   ...              para mantener mis servicios activos sin necesidad de ir a una tienda física.
   ...
   ...              Dominio: Billing | Versión: 1.0 | Responsable: QA Facturación
   Resource         keywords/billing_steps.resource

   *** Test Cases ***
   # ==========================================================================
   # Escenario 1: Pago exitoso de factura mediante tarjeta de débito
   # Criterio de aceptación: AC-BILL-001
   # ==========================================================================
   Cliente paga factura mensual exitosamente con tarjeta de débito
       [Documentation]    Escenario: El cliente accede al portal, selecciona tarjeta de débito
       ...                como método de pago, confirma el monto y recibe su recibo.
       ...                Trazabilidad: Historia US-BILL-015 / AC-BILL-001
       [Tags]             bdd    billing    pago    smoke    positivo

       Given el cliente "Roberto Medina" tiene una factura pendiente de pago por "1250" pesos
       And el cliente accede al portal de pagos con sus credenciales
       When el cliente selecciona el método de pago "Tarjeta de Débito"
       And el cliente confirma el pago del monto total
       Then la factura queda marcada como pagada en el sistema
       And el cliente recibe un recibo de pago por correo electrónico

   # ==========================================================================
   # Escenario 2: Rechazo de pago por tarjeta de crédito vencida
   # Criterio de aceptación: AC-BILL-002
   # ==========================================================================
   Sistema rechaza pago cuando la tarjeta de crédito está vencida
       [Documentation]    Escenario: El cliente intenta pagar con una tarjeta expirada.
       ...                El sistema debe detectar la condición y rechazar la transacción
       ...                con el código de error correspondiente.
       ...                Trazabilidad: Historia US-BILL-015 / AC-BILL-002
       [Tags]             bdd    billing    pago    negativo    validacion

       Given el cliente "Lucía Herrera" tiene una factura pendiente de pago por "890" pesos
       And el cliente accede al portal de pagos con sus credenciales
       When el cliente intenta pagar con una tarjeta de crédito vencida
       And el sistema detecta que la tarjeta está vencida
       Then el pago es rechazado con el código de error "ERR-CARD-001"
       And la factura permanece en estado pendiente de pago

   # ==========================================================================
   # Escenario 3: Notificación por saldo insuficiente en billetera digital
   # Criterio de aceptación: AC-BILL-003
   # ==========================================================================
   Sistema notifica saldo insuficiente al cliente que paga con billetera digital
       [Documentation]    Escenario: El cliente intenta pagar usando su billetera digital
       ...                pero el saldo disponible es menor al monto de la factura.
       ...                El sistema debe notificarlo y ofrecer opciones de recarga.
       ...                Trazabilidad: Historia US-BILL-016 / AC-BILL-003
       [Tags]             bdd    billing    pago    negativo    billetera_digital

       Given el cliente "Fernando Castillo" tiene una factura pendiente de pago por "2100" pesos
       And el cliente accede al portal de pagos con sus credenciales
       When el cliente selecciona el método de pago "Billetera Digital TelecomCorp"
       And el cliente tiene saldo insuficiente en su cuenta digital
       Then el sistema notifica al cliente que el saldo es insuficiente
       And el cliente es redirigido a opciones de recarga de saldo
       But la factura permanece en estado pendiente de pago
   ```

2. Observa el uso de `But` en el Escenario 3. Esta palabra clave Gherkin es equivalente a `And` en Robot Framework pero comunica una negación o excepción al resultado esperado, aportando mayor expresividad al escenario.

3. Guarda el archivo.

#### Verificación

```bash
python -m robot --dryrun features/billing/pago_factura.robot
```

**Salida esperada:**
```
==============================================================================
Pago Factura
==============================================================================
Cliente paga factura mensual exitosamente con tarjeta de débito          | PASS |
Sistema rechaza pago cuando la tarjeta de crédito está vencida           | PASS |
Sistema notifica saldo insuficiente al cliente que paga con billetera digital | PASS |
==============================================================================
Pago Factura                                                             | PASS |
3 tests, 3 passed, 0 failed
```

---

### Paso 6: Crear el Archivo Resource para el Dominio Plans

**Objetivo:** Implementar las keywords técnicas para el dominio de cambio de plan de datos, el flujo comercial de mayor complejidad del laboratorio.

#### Instrucciones

1. Crea el archivo `features/plans/keywords/plans_steps.resource`:

   ```robot
   *** Settings ***
   Documentation    Keywords de implementación para el dominio Plans.
   ...              Simulan operaciones de cambio de plan de datos
   ...              usando únicamente la librería BuiltIn.
   Library          BuiltIn

   *** Variables ***
   ${PLAN_ACTUAL}             ${EMPTY}
   ${PLAN_NUEVO}              ${EMPTY}
   ${CAMBIO_EFECTIVO}         inmediato
   ${CAMBIO_APLICADO}         ${FALSE}

   *** Keywords ***
   El cliente "${nombre}" tiene contratado el plan "${plan_actual}"
       [Documentation]    Precondición: cliente con un plan de datos activo específico.
       Log    Cliente: ${nombre} | Plan actual: ${plan_actual}
       Set Test Variable    ${CLIENTE_PLANS}    ${nombre}
       Set Test Variable    ${PLAN_ACTUAL}      ${plan_actual}
       Should Not Be Empty    ${PLAN_ACTUAL}

   El cliente navega a la sección "Gestión de Planes" en el portal
       [Documentation]    Simula la navegación al módulo de gestión de planes.
       Log    El cliente ${CLIENTE_PLANS} accede a la sección Gestión de Planes.
       Set Test Variable    ${SECCION_ACTIVA}    gestion_planes

   El cliente selecciona el nuevo plan "${plan_nuevo}"
       [Documentation]    Registra el plan nuevo seleccionado por el cliente.
       Log    Plan nuevo seleccionado: ${plan_nuevo}
       Set Test Variable    ${PLAN_NUEVO}    ${plan_nuevo}
       Should Not Be Empty    ${PLAN_NUEVO}

   El cliente confirma el cambio de plan
       [Documentation]    Simula la confirmación del cambio de plan por parte del cliente.
       Log    Confirmando cambio de plan: ${PLAN_ACTUAL} → ${PLAN_NUEVO}
       Log    Cambio confirmado por el cliente: ${CLIENTE_PLANS}
       Set Test Variable    ${CONFIRMACION_CAMBIO}    confirmado

   El nuevo plan "${plan_nuevo}" queda activo de forma inmediata
       [Documentation]    Verifica que el cambio de plan se aplicó correctamente.
       Log    Aplicando cambio de plan inmediato para: ${CLIENTE_PLANS}
       Set Test Variable    ${PLAN_ACTUAL}     ${plan_nuevo}
       Set Test Variable    ${CAMBIO_APLICADO}    ${TRUE}
       Should Be True    ${CAMBIO_APLICADO}
       Log    Plan ${plan_nuevo} activado exitosamente.

   El cliente recibe confirmación del cambio por SMS y correo electrónico
       [Documentation]    Simula el envío de confirmación por múltiples canales.
       Log    Enviando confirmación a: ${CLIENTE_PLANS}
       Log    Canal SMS: enviado correctamente.
       Log    Canal Email: enviado correctamente.

   El cliente tiene contratado el plan "${plan_actual}" con permanencia activa hasta "${fecha}"
       [Documentation]    Precondición: cliente con plan en período de permanencia.
       Log    Cliente: ${CLIENTE_PLANS} | Plan: ${plan_actual} | Permanencia hasta: ${fecha}
       Set Test Variable    ${PLAN_ACTUAL}       ${plan_actual}
       Set Test Variable    ${FECHA_PERMANENCIA}    ${fecha}
       Log    Permanencia activa detectada.

   El cliente intenta cambiar al plan "${plan_nuevo}" antes del fin de permanencia
       [Documentation]    Simula el intento de cambio durante período de permanencia.
       Log    Intento de cambio anticipado: ${plan_actual} → ${plan_nuevo}
       Set Test Variable    ${PLAN_NUEVO}    ${plan_nuevo}
       Set Test Variable    ${INTENTO_CAMBIO_ANTICIPADO}    ${TRUE}

   El sistema informa que existe una penalización de "${monto}" pesos por cambio anticipado
       [Documentation]    Verifica que el sistema calcula y comunica la penalización.
       Log    Penalización por cambio anticipado: $${monto} pesos
       Should Not Be Empty    ${monto}
       Log    Información de penalización comunicada al cliente.

   El cliente puede optar por aceptar la penalización o mantener su plan actual
       [Documentation]    Verifica que el sistema ofrece opciones al cliente.
       Log    Opciones presentadas al cliente:
       Log    1. Aceptar penalización y cambiar de plan.
       Log    2. Mantener el plan actual hasta fin de permanencia.

   El plan "${plan_actual}" se mantiene sin cambios hasta el fin del período de permanencia
       [Documentation]    Verifica que el plan no fue modificado cuando el cliente no acepta.
       Log    Plan ${plan_actual} mantenido sin cambios.
       Should Be Equal    ${PLAN_ACTUAL}    ${plan_actual}
       Log    Sin cambios aplicados al plan del cliente.

   El cliente solicita degradar su plan al nivel inferior disponible
       [Documentation]    Simula la solicitud de degradación de plan.
       Log    Solicitud de degradación de plan recibida del cliente: ${CLIENTE_PLANS}
       Set Test Variable    ${TIPO_CAMBIO}    degradacion

   El sistema valida que el cliente no tiene consumo excedente pendiente
       [Documentation]    Simula la validación de consumo antes de permitir la degradación.
       Log    Validando consumo excedente para: ${CLIENTE_PLANS}
       Set Test Variable    ${CONSUMO_EXCEDENTE}    ${FALSE}
       Should Not Be True    ${CONSUMO_EXCEDENTE}
       Log    Sin consumo excedente. Degradación permitida.

   El cambio al plan inferior se programa para el inicio del siguiente ciclo de facturación
       [Documentation]    Verifica que la degradación se programa correctamente.
       Log    Degradación programada para el inicio del próximo ciclo de facturación.
       Set Test Variable    ${CAMBIO_EFECTIVO}    inicio_siguiente_ciclo
       Should Be Equal    ${CAMBIO_EFECTIVO}    inicio_siguiente_ciclo
   ```

2. Guarda el archivo.

#### Verificación

```bash
python -m robot --dryrun features/plans/keywords/plans_steps.resource
```

---

### Paso 7: Escribir los Escenarios BDD para Cambio de Plan de Datos

**Objetivo:** Crear el feature file más completo del laboratorio, con escenarios que cubran el flujo de cambio de plan en sus variantes positiva, con permanencia y de degradación.

#### Instrucciones

1. Crea el archivo `features/plans/cambio_plan.robot`:

   ```robot
   *** Settings ***
   Documentation    Feature: Cambio de Plan de Datos
   ...
   ...              Como cliente de TelecomCorp,
   ...              quiero poder cambiar mi plan de datos desde el portal en línea
   ...              para adaptar mi servicio a mis necesidades actuales de consumo
   ...              sin necesidad de contactar al servicio al cliente.
   ...
   ...              Reglas de Negocio:
   ...              - Los cambios a planes superiores son efectivos de forma inmediata.
   ...              - Los cambios a planes inferiores (degradación) aplican al inicio del siguiente ciclo.
   ...              - Los cambios durante período de permanencia generan penalización.
   ...
   ...              Dominio: Plans | Versión: 1.0 | Responsable: QA Comercial
   Resource         keywords/plans_steps.resource

   *** Test Cases ***
   # ==========================================================================
   # Escenario 1: Upgrade de plan exitoso con aplicación inmediata
   # Criterio de aceptación: AC-PLAN-001
   # ==========================================================================
   Cliente realiza upgrade de plan de datos y el cambio aplica de forma inmediata
       [Documentation]    Escenario: El cliente con un plan básico activo selecciona un plan
       ...                superior. El sistema debe aplicar el cambio inmediatamente
       ...                y confirmar por SMS y correo.
       ...                Trazabilidad: Historia US-PLAN-028 / AC-PLAN-001
       [Tags]             bdd    plans    cambio_plan    upgrade    smoke    positivo

       Given el cliente "Patricia Vega" tiene contratado el plan "Datos 20GB Pospago"
       And el cliente navega a la sección "Gestión de Planes" en el portal
       When el cliente selecciona el nuevo plan "Datos 100GB Pospago Premium"
       And el cliente confirma el cambio de plan
       Then el nuevo plan "Datos 100GB Pospago Premium" queda activo de forma inmediata
       And el cliente recibe confirmación del cambio por SMS y correo electrónico

   # ==========================================================================
   # Escenario 2: Cambio de plan bloqueado por período de permanencia activo
   # Criterio de aceptación: AC-PLAN-002
   # ==========================================================================
   Sistema informa penalización cuando el cliente intenta cambiar plan durante permanencia
       [Documentation]    Escenario: El cliente tiene un plan con permanencia vigente.
       ...                Al intentar cambiarlo antes del vencimiento, el sistema debe
       ...                informar el costo de la penalización y presentar opciones.
       ...                Trazabilidad: Historia US-PLAN-029 / AC-PLAN-002
       [Tags]             bdd    plans    cambio_plan    permanencia    negativo    validacion

       Given el cliente "Miguel Ángel Soto" tiene contratado el plan "Fibra Convergente 300Mbps" con permanencia activa hasta "31/12/2025"
       And el cliente navega a la sección "Gestión de Planes" en el portal
       When el cliente intenta cambiar al plan "Fibra Convergente 600Mbps" antes del fin de permanencia
       Then el sistema informa que existe una penalización de "3500" pesos por cambio anticipado
       And el cliente puede optar por aceptar la penalización o mantener su plan actual
       But el plan "Fibra Convergente 300Mbps" se mantiene sin cambios hasta el fin del período de permanencia

   # ==========================================================================
   # Escenario 3: Downgrade de plan con aplicación diferida al siguiente ciclo
   # Criterio de aceptación: AC-PLAN-003
   # ==========================================================================
   Cliente solicita degradación de plan y el cambio se programa para el siguiente ciclo
       [Documentation]    Escenario: El cliente desea reducir su plan al nivel inferior.
       ...                El sistema valida que no hay consumo excedente y programa
       ...                el cambio para el inicio del siguiente ciclo de facturación.
       ...                Trazabilidad: Historia US-PLAN-030 / AC-PLAN-003
       [Tags]             bdd    plans    cambio_plan    downgrade    positivo    ciclo_facturacion

       Given el cliente "Sofía Ramírez" tiene contratado el plan "Datos 100GB Pospago Premium"
       And el cliente navega a la sección "Gestión de Planes" en el portal
       When el cliente solicita degradar su plan al nivel inferior disponible
       And el sistema valida que el cliente no tiene consumo excedente pendiente
       Then el cambio al plan inferior se programa para el inicio del siguiente ciclo de facturación
       And el cliente recibe confirmación del cambio por SMS y correo electrónico
   ```

2. Guarda el archivo.

#### Verificación

```bash
python -m robot --dryrun features/plans/cambio_plan.robot
```

**Salida esperada:**
```
==============================================================================
Cambio Plan
==============================================================================
Cliente realiza upgrade de plan de datos y el cambio aplica de forma inmediata | PASS |
Sistema informa penalización cuando el cliente intenta cambiar plan durante permanencia | PASS |
Cliente solicita degradación de plan y el cambio se programa para el siguiente ciclo | PASS |
==============================================================================
Cambio Plan                                                              | PASS |
3 tests, 3 passed, 0 failed
```

---

### Paso 8: Ejecutar la Suite Completa y Analizar el Reporte

**Objetivo:** Ejecutar todos los feature files de los tres dominios en una sola invocación y explorar el reporte HTML para verificar la legibilidad de los pasos Gherkin.

#### Instrucciones

1. Desde la raíz del proyecto, ejecuta la suite completa especificando el directorio `features/`:

   ```bash
   python -m robot \
     --outputdir results/lab-04-00-01 \
     --name "Suite BDD TelecomCorp" \
     --variable ENTORNO:laboratorio \
     features/
   ```

   **Windows (cmd — una sola línea):**
   ```cmd
   python -m robot --outputdir results\lab-04-00-01 --name "Suite BDD TelecomCorp" --variable ENTORNO:laboratorio features\
   ```

2. Una vez finalizada la ejecución, abre el reporte HTML:

   **macOS / Linux:**
   ```bash
   open results/lab-04-00-01/report.html
   ```

   **Windows:**
   ```cmd
   start results\lab-04-00-01\report.html
   ```

3. En el reporte HTML, navega a cualquier test case y expande los pasos. Observa que:
   - Los pasos se muestran con sus prefijos `Given`, `When`, `Then`, `And`, `But`.
   - Los nombres de los pasos son completamente legibles en lenguaje de negocio.
   - Los parámetros (nombres de clientes, planes, montos) se muestran en el log.

4. Opcionalmente, ejecuta solo un dominio específico usando el tag `mobile`:

   ```bash
   python -m robot \
     --outputdir results/lab-04-00-01-mobile \
     --include mobile \
     features/
   ```

#### Salida Esperada en Terminal

```
==============================================================================
Suite BDD TelecomCorp
==============================================================================
Suite BDD TelecomCorp.Features
==============================================================================
Suite BDD TelecomCorp.Features.Billing
==============================================================================
Suite BDD TelecomCorp.Features.Billing.Pago Factura
==============================================================================
Cliente paga factura mensual exitosamente con tarjeta de débito          | PASS |
Sistema rechaza pago cuando la tarjeta de crédito está vencida           | PASS |
Sistema notifica saldo insuficiente al cliente que paga con billetera digital | PASS |
==============================================================================
Suite BDD TelecomCorp.Features.Billing.Pago Factura                     | PASS |
3 tests, 3 passed, 0 failed
==============================================================================
...
==============================================================================
Suite BDD TelecomCorp                                                    | PASS |
9 tests, 9 passed, 0 failed
==============================================================================
Output:  .../results/lab-04-00-01/output.xml
Log:     .../results/lab-04-00-01/log.html
Report:  .../results/lab-04-00-01/report.html
```

#### Verificación

- **9 tests pasando** (3 por cada dominio: mobile, billing, plans).
- El archivo `report.html` se abre en el navegador y muestra los tres dominios como suites anidadas.
- Los pasos Gherkin son visibles en el log con sus prefijos correspondientes.

---

## Validación y Pruebas

### Lista de Verificación Final

Ejecuta las siguientes comprobaciones antes de dar el laboratorio por completado:

#### 1. Verificar la estructura de archivos

**macOS / Linux:**
```bash
find features -type f | sort
```

**Windows (PowerShell):**
```powershell
Get-ChildItem -Recurse features -File | Select-Object FullName
```

**Salida esperada:**
```
features/billing/keywords/billing_steps.resource
features/billing/pago_factura.robot
features/mobile/keywords/mobile_steps.resource
features/mobile/activacion_linea.robot
features/plans/keywords/plans_steps.resource
features/plans/cambio_plan.robot
```

#### 2. Verificar conteo de escenarios por dominio

```bash
python -m robot --collect-only features/ 2>&1 | grep "tests\|PASS\|FAIL"
```

**Resultado esperado:** 9 tests recolectados en total (3 por dominio).

#### 3. Verificar uso de todas las palabras clave Gherkin

Confirma que en los archivos `.robot` aparecen los cinco prefijos Gherkin:

```bash
grep -rh "^\s*\(Given\|When\|Then\|And\|But\)" features/*.robot features/**/*.robot 2>/dev/null | \
  awk '{print $1}' | sort | uniq -c | sort -rn
```

**Windows (PowerShell):**
```powershell
Select-String -Path "features\**\*.robot" -Pattern "^\s+(Given|When|Then|And|But)" -AllMatches |
  ForEach-Object { $_.Matches } | ForEach-Object { $_.Value.Trim() } |
  Group-Object | Select-Object Count, Name | Sort-Object Count -Descending
```

**Resultado esperado:** Las palabras `Given`, `When`, `Then`, `And` y `But` deben aparecer todas con al menos una ocurrencia.

#### 4. Ejecutar suite completa y verificar resultado

```bash
python -m robot --outputdir results/lab-04-00-01-final features/
echo "Exit code: $?"
```

**Resultado esperado:** Exit code `0` (todos los tests pasaron).

#### 5. Análisis de separación de capas

Verifica que ningún archivo `.robot` contiene implementación técnica directa (solo debe contener `Settings`, `Test Cases`):

```bash
grep -l "Log\|Should\|Set Test Variable" features/mobile/activacion_linea.robot \
     features/billing/pago_factura.robot features/plans/cambio_plan.robot
```

**Resultado esperado:** El comando no debe devolver ningún archivo (las keywords técnicas están solo en los `.resource`).

---

## Solución de Problemas

### Problema 1: Error "No keyword with name '...' found"

**Síntoma:**
```
No keyword with name 'El cliente "María González" tiene una línea activa sin plan de datos' found.
```
La ejecución falla con error de keyword no encontrada, aunque el archivo `.resource` existe en el directorio `keywords/`.

**Causa:**
La ruta en la directiva `Resource` del archivo `.robot` es incorrecta o relativa al directorio de trabajo de ejecución en lugar de al directorio del archivo `.robot`. Robot Framework resuelve las rutas de `Resource` relativas al directorio del archivo que las declara, no al directorio desde donde se lanza el comando.

**Solución:**

1. Verifica que la directiva `Resource` en el archivo `.robot` usa la ruta relativa correcta:
   ```robot
   # CORRECTO — relativo al archivo .robot
   Resource    keywords/mobile_steps.resource

   # INCORRECTO — ruta absoluta o mal formada
   Resource    features/mobile/keywords/mobile_steps.resource
   ```

2. Confirma que el archivo `.resource` existe en la ubicación esperada:
   ```bash
   ls features/mobile/keywords/mobile_steps.resource
   ```

3. Si el problema persiste, usa `--dryrun` para diagnóstico detallado:
   ```bash
   python -m robot --dryrun features/mobile/activacion_linea.robot
   ```
   El mensaje de error indicará exactamente qué keyword no fue encontrada y en qué archivo.

---

### Problema 2: Los pasos Gherkin aparecen sin prefijo en el reporte HTML

**Síntoma:**
En el reporte HTML (`log.html`), los pasos de los test cases aparecen con el nombre completo de la keyword (por ejemplo, `El cliente "María González" tiene una línea activa sin plan de datos`) pero **sin el prefijo** `Given`, `When`, `Then`, `And` o `But`. El log parece una lista de keywords normales, no un escenario BDD.

**Causa:**
Robot Framework elimina los prefijos Gherkin (`Given`, `When`, `Then`, `And`, `But`) al resolver la keyword, lo que es el comportamiento **correcto y esperado**. El prefijo se usa para la legibilidad en el archivo `.robot` y en el log de ejecución, pero internamente Robot Framework llama a la keyword sin el prefijo. Si los pasos no aparecen con prefijo en el log, es porque el Language Server o el visor del reporte está mostrando el nombre interno de la keyword.

**Solución:**

1. Verifica que estás revisando el archivo `log.html` (no `output.xml`). En `log.html`, expande el test case y busca la columna de "Keyword". Robot Framework 7.x **sí muestra** el prefijo Gherkin en el log cuando se usa correctamente.

2. Confirma que los pasos en el archivo `.robot` usan el prefijo con mayúscula inicial y un espacio:
   ```robot
   # CORRECTO
   Given el cliente "María González" tiene una línea activa sin plan de datos

   # INCORRECTO — sin prefijo
   el cliente "María González" tiene una línea activa sin plan de datos
   ```

3. Si el problema persiste, verifica la versión de Robot Framework:
   ```bash
   python -m robot --version
   ```
   Debe ser 7.x. En versiones anteriores a RF 4.0, el comportamiento del log podía diferir.

4. Como prueba de diagnóstico, ejecuta con nivel de log `DEBUG` y revisa el archivo `log.html`:
   ```bash
   python -m robot --loglevel DEBUG --outputdir results/debug features/mobile/activacion_linea.robot
   ```

---

## Limpieza

### Archivos Generados durante el Laboratorio

Los siguientes directorios y archivos fueron generados durante la ejecución y pueden ser eliminados si se desea liberar espacio:

```bash
# Eliminar resultados de ejecución (mantener los archivos .robot y .resource)
# macOS / Linux:
rm -rf results/lab-04-00-01 results/lab-04-00-01-mobile results/lab-04-00-01-final results/debug

# Windows (PowerShell):
Remove-Item -Recurse -Force results\lab-04-00-01, results\lab-04-00-01-mobile, results\lab-04-00-01-final, results\debug
```

> ⚠️ **No elimines** los directorios `features/` ni los archivos `.robot` y `.resource`. Estos son el producto del laboratorio y serán necesarios en laboratorios posteriores del Módulo 4.

### Desactivar el Entorno Virtual

```bash
deactivate
```

### Respaldo del Proyecto

Se recomienda crear una copia de respaldo del proyecto al finalizar el módulo:

```bash
# macOS / Linux:
cp -r ~/proyectos/robot-telecom ~/proyectos/robot-telecom-backup-lab04

# Windows (PowerShell):
Copy-Item -Recurse C:\proyectos\robot-telecom C:\proyectos\robot-telecom-backup-lab04
```

---

## Resumen

### Lo que Construiste

En este laboratorio creaste desde cero una estructura BDD completa para una empresa de telecomunicaciones ficticia, organizada en tres dominios de negocio independientes:

| Dominio    | Feature File             | Escenarios | Palabras Gherkin Usadas          |
|------------|--------------------------|------------|----------------------------------|
| `mobile`   | `activacion_linea.robot` | 3          | Given, When, And, Then           |
| `billing`  | `pago_factura.robot`     | 3          | Given, And, When, Then, But      |
| `plans`    | `cambio_plan.robot`      | 3          | Given, And, When, Then, But      |
| **Total**  |                          | **9**      | **Given, When, Then, And, But**  |

### Conceptos Clave Aplicados

- **Separación de capas:** Los archivos `.robot` contienen únicamente la descripción del comportamiento (Gherkin), mientras que los archivos `.resource` contienen la implementación técnica. Esta separación permite que un stakeholder no técnico lea y valide los escenarios sin necesidad de entender el código subyacente.

- **Sintaxis Gherkin nativa:** Robot Framework soporta los prefijos `Given`, `When`, `Then`, `And` y `But` de forma nativa, sin requerir librerías externas. Estos prefijos son ignorados al resolver la keyword, lo que significa que `Given el cliente X` y `el cliente X` llaman a la misma keyword.

- **Organización por dominio:** La estructura `features/mobile/`, `features/billing/` y `features/plans/` refleja los dominios de negocio de la empresa y facilita la trazabilidad entre escenarios y áreas funcionales.

- **Trazabilidad:** Cada escenario incluye en su `[Documentation]` la referencia a la historia de usuario y al criterio de aceptación correspondiente, cerrando el ciclo entre requisito de negocio y prueba automatizada.

- **Valor de BDD:** Un analista de negocio de TelecomCorp puede leer el escenario *"Sistema rechaza pago cuando la tarjeta de crédito está vencida"* y validar que el comportamiento descrito es correcto, sin necesidad de revisar código Python o keywords técnicas.

### Recursos Adicionales

- [Robot Framework User Guide — Behavior-Driven Style](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#behavior-driven-style)
- [Dan North — Introducing BDD (artículo original, en inglés)](https://dannorth.net/introducing-bdd/)
- [Cucumber — Referencia oficial de Gherkin](https://cucumber.io/docs/gherkin/reference/)
- [Agile Alliance — Glosario BDD](https://www.agilealliance.org/glossary/bdd/)

---


