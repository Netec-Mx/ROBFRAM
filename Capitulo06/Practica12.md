# Práctica 12: Suite web con Page Object y captura de evidencias completas

## Metadatos

| Campo | Valor |
|---|---|
| **Duración estimada** | 72 minutos |
| **Complejidad** | Alta |
| **Nivel Bloom** | Crear |
| **Módulo** | 6 — Automatización Web con Robot Framework |
| **Laboratorio previo requerido** | Lab 06-00-01 (Práctica 11) |

---

## Visión General

En este laboratorio diseñarás desde cero una suite web completa para la aplicación **Swag Labs** (`https://www.saucedemo.com`) aplicando el patrón **Page Object Model (POM)** con cuatro páginas encapsuladas como recursos independientes. Automatizarás un flujo E2E completo —login → selección de productos → carrito → checkout → confirmación— e implementarás un sistema de captura de evidencias con nomenclatura estructurada y organización por subcarpetas. Al finalizar, dispondrás de un proyecto mantenible, etiquetado por criticidad y ejecutable tanto en modo completo como filtrado por tags.

---

## Objetivos de Aprendizaje

- [ ] Diseñar y construir una suite web multi-página con al menos 4 recursos Page Object independientes (`LoginPage`, `InventoryPage`, `CartPage`, `CheckoutPage`).
- [ ] Implementar un sistema de captura de evidencias automatizado con nomenclatura `timestamp_testname_step` y organización en subcarpetas por caso de prueba.
- [ ] Construir una capa de keywords reutilizables que minimice la duplicación de código y maximice la mantenibilidad.
- [ ] Aplicar la configuración de navegador con opciones avanzadas (headless, tamaño de ventana) usando el patrón `browser_setup.resource` aprendido en la lección 6.1.
- [ ] Generar una suite con mínimo 6 casos de prueba etiquetados (`smoke`, `regression`, `critical`) ejecutables con filtrado por tags.

---

## Prerrequisitos

### Conocimiento previo
- Haber completado Lab 06-00-01 (Práctica 11) satisfactoriamente.
- Comprensión del patrón Page Object y su implementación con archivos `.resource` en Robot Framework.
- Familiaridad con localizadores CSS y XPath robustos.
- Conocimiento de keywords de sincronización de SeleniumLibrary (`Wait Until Element Is Visible`, `Wait Until Page Contains`, etc.).
- Manejo de variables de entorno y archivos de configuración en Robot Framework.

### Acceso y software
- Entorno virtual Python activo con las dependencias del módulo 6 instaladas.
- Acceso a internet para cargar `https://www.saucedemo.com`.
- Google Chrome (última versión estable) instalado.
- VS Code con la extensión Robot Framework Language Server activa.

---

## Entorno de Laboratorio

### Hardware mínimo recomendado

| Componente | Mínimo | Recomendado |
|---|---|---|
| CPU | Intel Core i5 8ª gen / Ryzen 5 | i7 10ª gen / Ryzen 7 |
| RAM | 8 GB | 16 GB |
| Disco libre | 5 GB | 10 GB |
| Resolución | 1280×768 | 1920×1080 |
| Internet | 10 Mbps | 25 Mbps |

### Software requerido

| Componente | Versión mínima |
|---|---|
| Python | 3.10+ |
| Robot Framework | 7.x |
| SeleniumLibrary | 6.2+ |
| selenium (Python) | 4.6+ (incluye selenium-manager) |
| Google Chrome | Última estable |
| VS Code | 1.85+ |

### Preparación del entorno

Abre una terminal y ejecuta los siguientes comandos según tu sistema operativo:

```bash
# ── Windows (PowerShell) ──────────────────────────────────────────────
cd %USERPROFILE%\curso-robot
python -m venv venv
venv\Scripts\activate

# ── macOS / Linux (bash/zsh) ─────────────────────────────────────────
cd ~/curso-robot
python -m venv venv
source venv/bin/activate
```

Instala las dependencias necesarias:

```bash
pip install robotframework>=7.0 \
            robotframework-seleniumlibrary>=6.2 \
            selenium>=4.6.0

# Verifica las instalaciones
pip show robotframework robotframework-seleniumlibrary selenium
```

Salida esperada (las versiones pueden variar):

```
Name: robotframework
Version: 7.0.1
...
Name: robotframework-seleniumlibrary
Version: 6.2.0
...
Name: selenium
Version: 4.18.1
```

---

## Procedimiento Paso a Paso

### Paso 1: Crear la estructura de directorios del proyecto

**Objetivo:** Establecer la arquitectura de carpetas del proyecto siguiendo las convenciones de Page Object Model para Robot Framework.

#### Instrucciones

1. Con el entorno virtual activo, crea la estructura de directorios completa:

```bash
# ── Windows (PowerShell) ──────────────────────────────────────────────
mkdir lab06-02
cd lab06-02
mkdir tests
mkdir resources\pages
mkdir resources\common
mkdir results\screenshots
mkdir results\reports

# ── macOS / Linux ────────────────────────────────────────────────────
mkdir -p lab06-02/{tests,resources/pages,resources/common,results/screenshots,results/reports}
cd lab06-02
```

2. Verifica la estructura creada:

```bash
# ── Windows ──────────────────────────────────────────────────────────
tree /F

# ── macOS / Linux ────────────────────────────────────────────────────
find . -type d | sort
```

#### Salida esperada

```
lab06-02/
├── resources/
│   ├── common/
│   └── pages/
├── results/
│   ├── reports/
│   └── screenshots/
└── tests/
```

#### Verificación

Confirma que todas las carpetas existen antes de continuar. La carpeta `results/screenshots` es crítica para el sistema de evidencias.

---

### Paso 2: Crear el recurso de configuración de navegador

**Objetivo:** Implementar el patrón `browser_setup.resource` aprendido en la lección 6.1, adaptado al proyecto Swag Labs.

#### Instrucciones

1. Crea el archivo `resources/common/browser_setup.resource`:

```robotframework
*** Settings ***
Documentation    Configuración centralizada del navegador para la suite Swag Labs.
...              Implementa el patrón de sesión reutilizable de la lección 6.1.
Library          SeleniumLibrary
Library          OperatingSystem
Library          DateTime

*** Variables ***
${NAVEGADOR}          chrome
${HEADLESS}           ${FALSE}
${TIMEOUT_GLOBAL}     15s
${IMPLICIT_WAIT}      0s
${VENTANA_ANCHO}      1920
${VENTANA_ALTO}       1080
${URL_BASE}           https://www.saucedemo.com
${SCREENSHOTS_DIR}    ${CURDIR}${/}..${/}..${/}results${/}screenshots

*** Keywords ***
Iniciar Sesión De Navegador
    [Documentation]    Abre el navegador con configuración estándar del proyecto.
    ...                Soporta modo headless controlado por la variable ${HEADLESS}.
    ...                Crea el directorio de screenshots si no existe.
    [Arguments]    ${url}=${URL_BASE}
    Create Directory    ${SCREENSHOTS_DIR}
    ${opciones}=    Crear Opciones De Navegador
    Open Browser    ${url}    ${NAVEGADOR}    options=${opciones}
    Set Selenium Timeout    ${TIMEOUT_GLOBAL}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Run Keyword Unless    ${HEADLESS}    Maximize Browser Window

Crear Opciones De Navegador
    [Documentation]    Construye el objeto ChromeOptions según el entorno de ejecución.
    ...                Aplica --headless=new cuando la variable HEADLESS es TRUE.
    ${opciones}=    Evaluate    selenium.webdriver.ChromeOptions()    modules=selenium.webdriver
    Call Method    ${opciones}    add_argument    --no-sandbox
    Call Method    ${opciones}    add_argument    --disable-dev-shm-usage
    Call Method    ${opciones}    add_argument    --disable-extensions
    IF    ${HEADLESS}
        Call Method    ${opciones}    add_argument    --headless=new
        Call Method    ${opciones}    add_argument    --window-size\=${VENTANA_ANCHO},${VENTANA_ALTO}
    END
    RETURN    ${opciones}

Cerrar Sesión De Navegador
    [Documentation]    Cierra todas las sesiones de navegador de forma segura.
    Close All Browsers

Capturar Evidencia
    [Documentation]    Captura un screenshot con nomenclatura estructurada:
    ...                {timestamp}_{nombre_test}_{paso}.png
    ...                Almacena en subcarpeta por nombre de test dentro de screenshots/.
    [Arguments]    ${paso}    ${test_name}=${TEST NAME}
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    # Sanitizar el nombre del test para usarlo como nombre de archivo
    ${nombre_limpio}=    Evaluate    re.sub(r'[^a-zA-Z0-9_]', '_', '${test_name}')    modules=re
    ${subcarpeta}=    Set Variable    ${SCREENSHOTS_DIR}${/}${nombre_limpio}
    Create Directory    ${subcarpeta}
    ${nombre_archivo}=    Set Variable    ${timestamp}_${nombre_limpio}_${paso}.png
    ${ruta_completa}=    Set Variable    ${subcarpeta}${/}${nombre_archivo}
    Capture Page Screenshot    ${ruta_completa}
    Log    Screenshot guardado: ${ruta_completa}    level=INFO
    RETURN    ${ruta_completa}

Capturar Evidencia En Fallo
    [Documentation]    Keyword diseñada para usarse en Test Teardown.
    ...                Solo captura screenshot si el test falló.
    Run Keyword If    '${TEST STATUS}' == 'FAIL'
    ...    Capturar Evidencia    FALLO_FINAL
```

#### Salida esperada

El archivo se guarda correctamente. No hay salida en consola en este paso.

#### Verificación

Abre el archivo en VS Code y confirma que la extensión Robot Framework Language Server no marca errores de sintaxis (no debe haber subrayados rojos en los keywords).

---

### Paso 3: Crear el Page Object de la página de Login

**Objetivo:** Encapsular todos los localizadores y acciones de la página de login de Swag Labs en un recurso independiente.

#### Instrucciones

1. Crea el archivo `resources/pages/login_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para la página de Login de Swag Labs.
...              URL: https://www.saucedemo.com
...              Encapsula localizadores y keywords de interacción con el formulario de login.
Library          SeleniumLibrary
Resource         ../common/browser_setup.resource

*** Variables ***
# ── Localizadores ────────────────────────────────────────────────────
${LOGIN_INPUT_USUARIO}       id:user-name
${LOGIN_INPUT_PASSWORD}      id:password
${LOGIN_BOTON_SUBMIT}        id:login-button
${LOGIN_MENSAJE_ERROR}       css:[data-test="error"]
${LOGIN_LOGO}                css:.login_logo
${LOGIN_CONTENEDOR}          id:login_button_container

# ── Credenciales de prueba ───────────────────────────────────────────
${USUARIO_ESTANDAR}          standard_user
${USUARIO_BLOQUEADO}         locked_out_user
${USUARIO_PROBLEMA}          problem_user
${PASSWORD_VALIDO}           secret_sauce
${MENSAJE_ERROR_BLOQUEADO}   Epic sadface: Sorry, this user has been locked out.
${MENSAJE_ERROR_CREDENCIAL}  Epic sadface: Username and password do not match any user in this service.

*** Keywords ***
Verificar Página De Login Cargada
    [Documentation]    Valida que la página de login está completamente cargada.
    Wait Until Element Is Visible    ${LOGIN_LOGO}    timeout=10s
    Wait Until Element Is Visible    ${LOGIN_INPUT_USUARIO}
    Wait Until Element Is Visible    ${LOGIN_INPUT_PASSWORD}
    Wait Until Element Is Visible    ${LOGIN_BOTON_SUBMIT}
    Element Should Be Enabled        ${LOGIN_BOTON_SUBMIT}
    Capturar Evidencia               01_login_page_cargada

Ingresar Credenciales
    [Documentation]    Rellena el formulario de login con usuario y contraseña.
    [Arguments]    ${usuario}    ${password}
    Clear Element Text    ${LOGIN_INPUT_USUARIO}
    Input Text            ${LOGIN_INPUT_USUARIO}    ${usuario}
    Clear Element Text    ${LOGIN_INPUT_PASSWORD}
    Input Password        ${LOGIN_INPUT_PASSWORD}    ${password}
    Capturar Evidencia    02_credenciales_ingresadas

Hacer Clic En Login
    [Documentation]    Hace clic en el botón de submit del formulario.
    Click Button         ${LOGIN_BOTON_SUBMIT}

Realizar Login Exitoso
    [Documentation]    Ejecuta el flujo completo de login con credenciales válidas.
    ...                Verifica que la página de inventario se cargó correctamente.
    [Arguments]    ${usuario}=${USUARIO_ESTANDAR}    ${password}=${PASSWORD_VALIDO}
    Verificar Página De Login Cargada
    Ingresar Credenciales    ${usuario}    ${password}
    Hacer Clic En Login
    Capturar Evidencia    03_post_login_click

Realizar Login Fallido
    [Documentation]    Intenta login con credenciales inválidas y verifica el mensaje de error.
    [Arguments]    ${usuario}    ${password}    ${mensaje_esperado}
    Verificar Página De Login Cargada
    Ingresar Credenciales    ${usuario}    ${password}
    Hacer Clic En Login
    Verificar Mensaje De Error Login    ${mensaje_esperado}

Verificar Mensaje De Error Login
    [Documentation]    Valida que el mensaje de error del login contiene el texto esperado.
    [Arguments]    ${mensaje_esperado}
    Wait Until Element Is Visible    ${LOGIN_MENSAJE_ERROR}    timeout=5s
    Element Should Contain           ${LOGIN_MENSAJE_ERROR}    ${mensaje_esperado}
    Capturar Evidencia               04_error_login_verificado

Verificar Que El Botón Login Está Deshabilitado
    [Documentation]    Verifica que el botón de login está en estado deshabilitado.
    Element Should Be Disabled    ${LOGIN_BOTON_SUBMIT}
```

#### Salida esperada

Archivo creado sin errores de sintaxis.

#### Verificación

En VS Code, pasa el cursor sobre `Wait Until Element Is Visible` y confirma que el Language Server resuelve el keyword desde SeleniumLibrary.

---

### Paso 4: Crear los Page Objects de Inventario, Carrito y Checkout

**Objetivo:** Implementar los tres Page Objects restantes que completan la arquitectura POM del flujo E2E.

#### Instrucciones

1. Crea el archivo `resources/pages/inventory_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para la página de Inventario (catálogo de productos) de Swag Labs.
Library          SeleniumLibrary
Resource         ../common/browser_setup.resource

*** Variables ***
# ── Localizadores ────────────────────────────────────────────────────
${INV_TITULO_PAGINA}           css:.title
${INV_LISTA_PRODUCTOS}         id:inventory_container
${INV_ITEMS}                   css:.inventory_item
${INV_BOTON_AGREGAR_SAUCE}     id:add-to-cart-sauce-labs-backpack
${INV_BOTON_AGREGAR_TSHIRT}    id:add-to-cart-sauce-labs-bolt-t-shirt
${INV_BOTON_AGREGAR_JACKET}    id:add-to-cart-sauce-labs-fleece-jacket
${INV_ICONO_CARRITO}           css:.shopping_cart_link
${INV_BADGE_CARRITO}           css:.shopping_cart_badge
${INV_MENU_BOTON}              id:react-burger-menu-btn
${INV_LOGOUT_LINK}             id:logout_sidebar_link
${INV_ORDENAR_SELECT}          css:[data-test="product_sort_container"]

*** Keywords ***
Verificar Página De Inventario Cargada
    [Documentation]    Valida que la página de inventario está completamente cargada.
    Wait Until Element Is Visible    ${INV_TITULO_PAGINA}    timeout=15s
    Element Text Should Be           ${INV_TITULO_PAGINA}    Products
    Wait Until Element Is Visible    ${INV_LISTA_PRODUCTOS}
    ${cantidad}=    Get Element Count    ${INV_ITEMS}
    Should Be True    ${cantidad} >= 6    msg=Se esperaban al menos 6 productos, se encontraron: ${cantidad}
    Capturar Evidencia    05_inventario_cargado

Agregar Producto Al Carrito
    [Documentation]    Agrega un producto específico al carrito por su ID de botón.
    [Arguments]    ${boton_id}    ${nombre_paso}
    Wait Until Element Is Visible    ${boton_id}
    Click Button                     ${boton_id}
    Capturar Evidencia               ${nombre_paso}

Agregar Mochila Al Carrito
    [Documentation]    Agrega la Sauce Labs Backpack al carrito.
    Agregar Producto Al Carrito    ${INV_BOTON_AGREGAR_SAUCE}    06_mochila_agregada

Agregar Camiseta Al Carrito
    [Documentation]    Agrega la Sauce Labs Bolt T-Shirt al carrito.
    Agregar Producto Al Carrito    ${INV_BOTON_AGREGAR_TSHIRT}    07_camiseta_agregada

Verificar Badge Del Carrito
    [Documentation]    Verifica que el badge del carrito muestra el número esperado de items.
    [Arguments]    ${cantidad_esperada}
    Wait Until Element Is Visible    ${INV_BADGE_CARRITO}    timeout=5s
    Element Text Should Be           ${INV_BADGE_CARRITO}    ${cantidad_esperada}
    Capturar Evidencia               08_badge_carrito_verificado

Navegar Al Carrito
    [Documentation]    Hace clic en el ícono del carrito para ir a la página de carrito.
    Click Element      ${INV_ICONO_CARRITO}
    Capturar Evidencia    09_navegando_al_carrito

Ordenar Productos Por Precio Ascendente
    [Documentation]    Selecciona la opción de ordenamiento por precio (menor a mayor).
    Select From List By Value    ${INV_ORDENAR_SELECT}    lohi
    Capturar Evidencia           10_productos_ordenados_precio_asc

Realizar Logout
    [Documentation]    Ejecuta el flujo de logout desde el menú lateral.
    Click Element    ${INV_MENU_BOTON}
    Wait Until Element Is Visible    ${INV_LOGOUT_LINK}    timeout=5s
    Click Element                    ${INV_LOGOUT_LINK}
    Capturar Evidencia               11_logout_realizado
```

2. Crea el archivo `resources/pages/cart_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para la página del Carrito de Swag Labs.
Library          SeleniumLibrary
Resource         ../common/browser_setup.resource

*** Variables ***
# ── Localizadores ────────────────────────────────────────────────────
${CART_TITULO_PAGINA}        css:.title
${CART_LISTA_ITEMS}          css:.cart_list
${CART_ITEMS}                css:.cart_item
${CART_BOTON_CHECKOUT}       id:checkout
${CART_BOTON_CONTINUAR}      id:continue-shopping
${CART_ITEM_NOMBRE}          css:.inventory_item_name
${CART_ITEM_PRECIO}          css:.inventory_item_price
${CART_BOTON_REMOVER}        css:[id^="remove-"]

*** Keywords ***
Verificar Página De Carrito Cargada
    [Documentation]    Valida que la página del carrito está completamente cargada.
    Wait Until Element Is Visible    ${CART_TITULO_PAGINA}    timeout=10s
    Element Text Should Be           ${CART_TITULO_PAGINA}    Your Cart
    Wait Until Element Is Visible    ${CART_LISTA_ITEMS}
    Capturar Evidencia               12_carrito_cargado

Verificar Cantidad De Items En Carrito
    [Documentation]    Verifica que el carrito contiene exactamente N items.
    [Arguments]    ${cantidad_esperada}
    ${cantidad_actual}=    Get Element Count    ${CART_ITEMS}
    Should Be Equal As Integers    ${cantidad_actual}    ${cantidad_esperada}
    ...    msg=Carrito tiene ${cantidad_actual} items, se esperaban ${cantidad_esperada}
    Capturar Evidencia    13_cantidad_items_verificada

Verificar Producto En Carrito
    [Documentation]    Verifica que un producto específico está presente en el carrito.
    [Arguments]    ${nombre_producto}
    Page Should Contain    ${nombre_producto}
    Capturar Evidencia     14_producto_en_carrito_verificado

Proceder Al Checkout
    [Documentation]    Hace clic en el botón de checkout para avanzar al proceso de pago.
    Wait Until Element Is Visible    ${CART_BOTON_CHECKOUT}
    Click Button                     ${CART_BOTON_CHECKOUT}
    Capturar Evidencia               15_procediendo_checkout

Continuar Comprando
    [Documentation]    Regresa al inventario desde el carrito.
    Click Button       ${CART_BOTON_CONTINUAR}

Remover Primer Item Del Carrito
    [Documentation]    Elimina el primer item encontrado en el carrito.
    Wait Until Element Is Visible    ${CART_BOTON_REMOVER}
    Click Button                     ${CART_BOTON_REMOVER}
    Capturar Evidencia               16_item_removido_carrito
```

3. Crea el archivo `resources/pages/checkout_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para el flujo de Checkout de Swag Labs.
...              Cubre Step One (información personal), Step Two (resumen) y Confirmation.
Library          SeleniumLibrary
Resource         ../common/browser_setup.resource

*** Variables ***
# ── Step One (Información personal) ─────────────────────────────────
${CHK_INPUT_NOMBRE}          id:first-name
${CHK_INPUT_APELLIDO}        id:last-name
${CHK_INPUT_POSTAL}          id:postal-code
${CHK_BOTON_CONTINUAR}       id:continue
${CHK_BOTON_CANCELAR}        id:cancel
${CHK_MENSAJE_ERROR}         css:[data-test="error"]

# ── Step Two (Resumen de orden) ──────────────────────────────────────
${CHK_TITULO_OVERVIEW}       css:.title
${CHK_SUBTOTAL}              css:.summary_subtotal_label
${CHK_TAX}                   css:.summary_tax_label
${CHK_TOTAL}                 css:.summary_total_label
${CHK_BOTON_FINISH}          id:finish

# ── Confirmation ─────────────────────────────────────────────────────
${CHK_TITULO_COMPLETO}       css:.complete-header
${CHK_TEXTO_COMPLETO}        css:.complete-text
${CHK_BOTON_HOME}            id:back-to-products
${CHK_ICONO_PONY}            css:.pony_express

*** Keywords ***
Verificar Página Checkout Step One Cargada
    [Documentation]    Valida que el formulario de información personal está cargado.
    Wait Until Element Is Visible    ${CHK_INPUT_NOMBRE}    timeout=10s
    Wait Until Element Is Visible    ${CHK_INPUT_APELLIDO}
    Wait Until Element Is Visible    ${CHK_INPUT_POSTAL}
    Capturar Evidencia               17_checkout_step1_cargado

Ingresar Información Personal
    [Documentation]    Rellena el formulario de checkout con los datos del comprador.
    [Arguments]    ${nombre}    ${apellido}    ${codigo_postal}
    Input Text    ${CHK_INPUT_NOMBRE}      ${nombre}
    Input Text    ${CHK_INPUT_APELLIDO}    ${apellido}
    Input Text    ${CHK_INPUT_POSTAL}      ${codigo_postal}
    Capturar Evidencia    18_informacion_personal_ingresada

Continuar Al Resumen De Orden
    [Documentation]    Hace clic en Continue para avanzar al resumen de la orden.
    Click Button       ${CHK_BOTON_CONTINUAR}
    Capturar Evidencia    19_avanzando_a_resumen

Verificar Página De Resumen Cargada
    [Documentation]    Valida que la página de resumen (Step Two) está cargada correctamente.
    Wait Until Element Is Visible    ${CHK_TITULO_OVERVIEW}    timeout=10s
    Element Text Should Be           ${CHK_TITULO_OVERVIEW}    Checkout: Overview
    Wait Until Element Is Visible    ${CHK_SUBTOTAL}
    Wait Until Element Is Visible    ${CHK_TOTAL}
    Capturar Evidencia               20_resumen_orden_cargado

Verificar Totales De Orden
    [Documentation]    Captura y registra los valores de subtotal, impuestos y total.
    ${subtotal}=    Get Text    ${CHK_SUBTOTAL}
    ${tax}=         Get Text    ${CHK_TAX}
    ${total}=       Get Text    ${CHK_TOTAL}
    Log    Subtotal: ${subtotal} | Tax: ${tax} | Total: ${total}    level=INFO
    Should Contain    ${subtotal}    Item total:
    Should Contain    ${total}       Total:
    Capturar Evidencia    21_totales_verificados

Finalizar Compra
    [Documentation]    Hace clic en el botón Finish para completar la orden.
    Wait Until Element Is Visible    ${CHK_BOTON_FINISH}
    Click Button                     ${CHK_BOTON_FINISH}
    Capturar Evidencia               22_compra_finalizada

Verificar Confirmación De Orden
    [Documentation]    Valida que la pantalla de confirmación se muestra correctamente.
    Wait Until Element Is Visible    ${CHK_TITULO_COMPLETO}    timeout=10s
    Element Text Should Be           ${CHK_TITULO_COMPLETO}    Thank you for your order!
    Wait Until Element Is Visible    ${CHK_ICONO_PONY}
    Capturar Evidencia               23_orden_confirmada

Verificar Mensaje De Error En Checkout
    [Documentation]    Valida que aparece un mensaje de error al enviar el formulario incompleto.
    [Arguments]    ${mensaje_esperado}
    Wait Until Element Is Visible    ${CHK_MENSAJE_ERROR}    timeout=5s
    Element Should Contain           ${CHK_MENSAJE_ERROR}    ${mensaje_esperado}
    Capturar Evidencia               24_error_checkout_verificado

Regresar A La Tienda Desde Confirmación
    [Documentation]    Hace clic en "Back Home" para regresar al inventario.
    Click Button       ${CHK_BOTON_HOME}
```

#### Salida esperada

Tres archivos creados en `resources/pages/`. La estructura del proyecto debe verse así:

```
resources/
├── common/
│   └── browser_setup.resource
└── pages/
    ├── cart_page.resource
    ├── checkout_page.resource
    ├── inventory_page.resource
    └── login_page.resource
```

#### Verificación

Ejecuta el siguiente comando para confirmar que todos los archivos existen:

```bash
# ── Windows ──────────────────────────────────────────────────────────
dir resources\pages\

# ── macOS / Linux ────────────────────────────────────────────────────
ls -la resources/pages/
```

Deben aparecer los 4 archivos `.resource`.

---

### Paso 5: Crear la suite de pruebas principal

**Objetivo:** Construir el archivo de suite con los 6 casos de prueba mínimos requeridos, etiquetados correctamente y con teardowns de captura de evidencias.

#### Instrucciones

1. Crea el archivo `tests/swag_labs_suite.robot`:

```robotframework
*** Settings ***
Documentation    Suite completa de automatización web para Swag Labs (saucedemo.com).
...
...              Arquitectura: Page Object Model con 4 recursos independientes.
...              Evidencias: Screenshots estructurados en results/screenshots/.
...              Tags disponibles: smoke, regression, critical, negative.
...
...              Ejecución completa:
...                robot --outputdir results/reports tests/swag_labs_suite.robot
...
...              Ejecución filtrada por tag:
...                robot --outputdir results/reports --include smoke tests/swag_labs_suite.robot
...                robot --outputdir results/reports --include critical tests/swag_labs_suite.robot

Library          SeleniumLibrary
Library          OperatingSystem

Resource         ../resources/common/browser_setup.resource
Resource         ../resources/pages/login_page.resource
Resource         ../resources/pages/inventory_page.resource
Resource         ../resources/pages/cart_page.resource
Resource         ../resources/pages/checkout_page.resource

Suite Setup      Configurar Suite Swag Labs
Suite Teardown   Cerrar Sesión De Navegador

*** Variables ***
${NOMBRE_COMPRADOR}      Juan
${APELLIDO_COMPRADOR}    Pérez
${POSTAL_COMPRADOR}      28001

*** Test Cases ***

# ══════════════════════════════════════════════════════════════════════
# TC-01: Login exitoso con usuario estándar
# Tags: smoke, critical
# ══════════════════════════════════════════════════════════════════════
TC-01 Login Exitoso Con Usuario Estándar
    [Documentation]    Verifica que un usuario válido puede autenticarse correctamente
    ...                y accede al inventario de productos.
    [Tags]    smoke    critical
    [Setup]    Navegar A Página De Login
    [Teardown]    Capturar Evidencia En Fallo
    Realizar Login Exitoso    ${USUARIO_ESTANDAR}    ${PASSWORD_VALIDO}
    Verificar Página De Inventario Cargada

# ══════════════════════════════════════════════════════════════════════
# TC-02: Login fallido con usuario bloqueado
# Tags: smoke, negative
# ══════════════════════════════════════════════════════════════════════
TC-02 Login Fallido Con Usuario Bloqueado
    [Documentation]    Verifica que un usuario bloqueado recibe el mensaje de error
    ...                correspondiente y no puede acceder al inventario.
    [Tags]    smoke    negative
    [Setup]    Navegar A Página De Login
    [Teardown]    Capturar Evidencia En Fallo
    Realizar Login Fallido
    ...    ${USUARIO_BLOQUEADO}
    ...    ${PASSWORD_VALIDO}
    ...    ${MENSAJE_ERROR_BLOQUEADO}

# ══════════════════════════════════════════════════════════════════════
# TC-03: Flujo E2E completo - Compra exitosa de un producto
# Tags: regression, critical
# ══════════════════════════════════════════════════════════════════════
TC-03 Flujo E2E Completo Compra Un Producto
    [Documentation]    Verifica el flujo completo de compra: login → agregar producto
    ...                al carrito → checkout → confirmación de orden.
    [Tags]    regression    critical
    [Setup]    Navegar A Página De Login
    [Teardown]    Capturar Evidencia En Fallo
    # Login
    Realizar Login Exitoso    ${USUARIO_ESTANDAR}    ${PASSWORD_VALIDO}
    Verificar Página De Inventario Cargada
    # Agregar producto al carrito
    Agregar Mochila Al Carrito
    Verificar Badge Del Carrito    1
    # Navegar al carrito
    Navegar Al Carrito
    Verificar Página De Carrito Cargada
    Verificar Cantidad De Items En Carrito    1
    Verificar Producto En Carrito    Sauce Labs Backpack
    # Iniciar checkout
    Proceder Al Checkout
    Verificar Página Checkout Step One Cargada
    Ingresar Información Personal    ${NOMBRE_COMPRADOR}    ${APELLIDO_COMPRADOR}    ${POSTAL_COMPRADOR}
    Continuar Al Resumen De Orden
    # Verificar resumen y finalizar
    Verificar Página De Resumen Cargada
    Verificar Totales De Orden
    Finalizar Compra
    Verificar Confirmación De Orden

# ══════════════════════════════════════════════════════════════════════
# TC-04: Flujo E2E - Compra de múltiples productos
# Tags: regression
# ══════════════════════════════════════════════════════════════════════
TC-04 Flujo E2E Compra Múltiples Productos
    [Documentation]    Verifica que se pueden agregar múltiples productos al carrito
    ...                y completar el checkout correctamente.
    [Tags]    regression
    [Setup]    Navegar A Página De Login
    [Teardown]    Capturar Evidencia En Fallo
    # Login y agregar dos productos
    Realizar Login Exitoso    ${USUARIO_ESTANDAR}    ${PASSWORD_VALIDO}
    Verificar Página De Inventario Cargada
    Agregar Mochila Al Carrito
    Agregar Camiseta Al Carrito
    Verificar Badge Del Carrito    2
    # Verificar carrito con 2 items
    Navegar Al Carrito
    Verificar Página De Carrito Cargada
    Verificar Cantidad De Items En Carrito    2
    # Completar checkout
    Proceder Al Checkout
    Verificar Página Checkout Step One Cargada
    Ingresar Información Personal    Ana    García    08001
    Continuar Al Resumen De Orden
    Verificar Página De Resumen Cargada
    Finalizar Compra
    Verificar Confirmación De Orden

# ══════════════════════════════════════════════════════════════════════
# TC-05: Validación de ordenamiento de productos
# Tags: regression
# ══════════════════════════════════════════════════════════════════════
TC-05 Ordenamiento De Productos Por Precio
    [Documentation]    Verifica que el ordenamiento de productos por precio
    ...                (menor a mayor) funciona correctamente en el inventario.
    [Tags]    regression
    [Setup]    Navegar A Página De Login
    [Teardown]    Capturar Evidencia En Fallo
    Realizar Login Exitoso    ${USUARIO_ESTANDAR}    ${PASSWORD_VALIDO}
    Verificar Página De Inventario Cargada
    Ordenar Productos Por Precio Ascendente
    # Verificar que el primer producto tiene el precio más bajo
    ${precios}=    Get WebElements    css:.inventory_item_price
    ${primer_precio}=    Get Text    ${precios}[0]
    Log    Primer precio tras ordenar: ${primer_precio}    level=INFO
    Should Contain    ${primer_precio}    $7.99
    Capturar Evidencia    25_ordenamiento_verificado

# ══════════════════════════════════════════════════════════════════════
# TC-06: Validación de checkout con formulario incompleto
# Tags: regression, negative
# ══════════════════════════════════════════════════════════════════════
TC-06 Checkout Con Formulario Incompleto
    [Documentation]    Verifica que el sistema muestra mensajes de error apropiados
    ...                cuando se intenta avanzar en checkout sin completar el formulario.
    [Tags]    regression    negative
    [Setup]    Navegar A Página De Login
    [Teardown]    Capturar Evidencia En Fallo
    # Preparar: login y llegar al checkout
    Realizar Login Exitoso    ${USUARIO_ESTANDAR}    ${PASSWORD_VALIDO}
    Verificar Página De Inventario Cargada
    Agregar Mochila Al Carrito
    Navegar Al Carrito
    Proceder Al Checkout
    Verificar Página Checkout Step One Cargada
    # Intentar continuar sin datos → debe mostrar error
    Click Button    id:continue
    Verificar Mensaje De Error En Checkout    First Name is required

*** Keywords ***
Configurar Suite Swag Labs
    [Documentation]    Setup de la suite: inicializa el navegador y navega a la URL base.
    Iniciar Sesión De Navegador    ${URL_BASE}

Navegar A Página De Login
    [Documentation]    Setup individual de test: navega a la página de login.
    ...                Se usa como [Setup] en cada test case para garantizar estado limpio.
    Go To    ${URL_BASE}
    Verificar Página De Login Cargada
```

#### Salida esperada

Archivo creado en `tests/swag_labs_suite.robot` sin errores de sintaxis visibles en el Language Server.

#### Verificación

Ejecuta una verificación de sintaxis en seco:

```bash
# ── Verificación de sintaxis sin ejecutar pruebas ─────────────────────
robot --dryrun --outputdir results/reports tests/swag_labs_suite.robot
```

Salida esperada (fragmento):

```
==============================================================================
Swag Labs Suite
==============================================================================
TC-01 Login Exitoso Con Usuario Estándar                              | PASS |
TC-02 Login Fallido Con Usuario Bloqueado                             | PASS |
TC-03 Flujo E2E Completo Compra Un Producto                          | PASS |
TC-04 Flujo E2E Compra Múltiples Productos                           | PASS |
TC-05 Ordenamiento De Productos Por Precio                            | PASS |
TC-06 Checkout Con Formulario Incompleto                              | PASS |
==============================================================================
Swag Labs Suite                                                       | PASS |
6 tests, 6 passed, 0 failed
==============================================================================
```

> **Nota:** El modo `--dryrun` no abre el navegador; solo valida que los keywords y la sintaxis son correctos.

---

### Paso 6: Crear el archivo README del proyecto

**Objetivo:** Documentar el proyecto con instrucciones de ejecución claras, como se requiere en el entregable del laboratorio.

#### Instrucciones

1. Crea el archivo `README.md` en la raíz del proyecto:

```markdown
# Lab 06-00-02 — Suite Web Swag Labs con Page Object Model

## Descripción
Suite de automatización web completa para https://www.saucedemo.com
implementando el patrón Page Object Model con 4 páginas encapsuladas.

## Estructura del Proyecto
```
lab06-02/
├── README.md
├── resources/
│   ├── common/
│   │   └── browser_setup.resource     # Configuración de navegador (lección 6.1)
│   └── pages/
│       ├── login_page.resource        # PO: Página de Login
│       ├── inventory_page.resource    # PO: Catálogo de Productos
│       ├── cart_page.resource         # PO: Carrito de Compras
│       └── checkout_page.resource     # PO: Flujo de Checkout
├── results/
│   ├── reports/                       # Reportes HTML/XML de Robot Framework
│   └── screenshots/                   # Evidencias capturadas por caso
└── tests/
    └── swag_labs_suite.robot          # Suite principal (6 casos de prueba)
```

## Prerrequisitos
- Python 3.10+, Robot Framework 7.x, SeleniumLibrary 6.2+
- Google Chrome (última versión)
- Entorno virtual activo

## Ejecución

### Suite completa
```bash
robot --outputdir results/reports tests/swag_labs_suite.robot
```

### Solo pruebas smoke
```bash
robot --outputdir results/reports --include smoke tests/swag_labs_suite.robot
```

### Solo pruebas críticas
```bash
robot --outputdir results/reports --include critical tests/swag_labs_suite.robot
```

### Solo pruebas de regresión
```bash
robot --outputdir results/reports --include regression tests/swag_labs_suite.robot
```

### Modo headless (sin interfaz gráfica)
```bash
robot --outputdir results/reports --variable HEADLESS:True tests/swag_labs_suite.robot
```

### Excluir pruebas negativas
```bash
robot --outputdir results/reports --exclude negative tests/swag_labs_suite.robot
```

## Tags disponibles
| Tag | Descripción | Cantidad de tests |
|---|---|---|
| smoke | Pruebas de humo básicas | 2 |
| regression | Pruebas de regresión completas | 4 |
| critical | Casos críticos de negocio | 2 |
| negative | Casos de validación de errores | 2 |

## Evidencias
Los screenshots se guardan en `results/screenshots/{nombre_test}/`
con nomenclatura: `{timestamp}_{nombre_test}_{paso}.png`
```

#### Salida esperada

Archivo `README.md` creado en la raíz del proyecto.

---

### Paso 7: Ejecutar la suite completa y verificar resultados

**Objetivo:** Ejecutar la suite completa, verificar que los 6 casos de prueba pasan y revisar las evidencias generadas.

#### Instrucciones

1. Asegúrate de estar en el directorio raíz del proyecto (`lab06-02`) con el entorno virtual activo.

2. Ejecuta la suite completa:

```bash
# ── Ejecución completa ────────────────────────────────────────────────
robot --outputdir results/reports \
      --loglevel DEBUG \
      tests/swag_labs_suite.robot

# ── Windows (una sola línea) ──────────────────────────────────────────
robot --outputdir results\reports --loglevel DEBUG tests\swag_labs_suite.robot
```

3. Una vez finalizada la ejecución, verifica los resultados:

```bash
# ── Contar screenshots generados ─────────────────────────────────────
# macOS / Linux
find results/screenshots -name "*.png" | wc -l

# Windows PowerShell
(Get-ChildItem -Recurse results\screenshots -Filter "*.png").Count
```

4. Ejecuta la suite filtrada solo por tags `smoke`:

```bash
robot --outputdir results/reports \
      --include smoke \
      --output smoke_output.xml \
      --report smoke_report.html \
      --log smoke_log.html \
      tests/swag_labs_suite.robot
```

5. Ejecuta la suite filtrada solo por tags `critical`:

```bash
robot --outputdir results/reports \
      --include critical \
      --output critical_output.xml \
      --report critical_report.html \
      --log critical_log.html \
      tests/swag_labs_suite.robot
```

#### Salida esperada

```
==============================================================================
Swag Labs Suite
==============================================================================
TC-01 Login Exitoso Con Usuario Estándar                              | PASS |
TC-02 Login Fallido Con Usuario Bloqueado                             | PASS |
TC-03 Flujo E2E Completo Compra Un Producto                          | PASS |
TC-04 Flujo E2E Compra Múltiples Productos                           | PASS |
TC-05 Ordenamiento De Productos Por Precio                            | PASS |
TC-06 Checkout Con Formulario Incompleto                              | PASS |
==============================================================================
Swag Labs Suite                                                       | PASS |
6 tests, 6 passed, 0 failed
==============================================================================
Output:  /ruta/lab06-02/results/reports/output.xml
Log:     /ruta/lab06-02/results/reports/log.html
Report:  /ruta/lab06-02/results/reports/report.html
```

#### Verificación

Abre el reporte HTML en el navegador:

```bash
# ── macOS ──────────────────────────────────────────────────────────
open results/reports/report.html

# ── Linux ──────────────────────────────────────────────────────────
xdg-open results/reports/report.html

# ── Windows ────────────────────────────────────────────────────────
start results\reports\report.html
```

Confirma los siguientes puntos en el reporte:

- [ ] 6 tests en total, 6 passed, 0 failed.
- [ ] Los tags `smoke`, `regression`, `critical` y `negative` aparecen en la sección de estadísticas.
- [ ] La columna "Statistics by Tag" muestra: smoke=2, regression=4, critical=2.
- [ ] Los screenshots aparecen embebidos en el log HTML de cada test.

---

## Validación y Pruebas

### Lista de verificación del entregable

Ejecuta cada verificación y marca como completada:

```bash
# 1. Verificar que existen los 4 Page Objects
ls resources/pages/*.resource
# Esperado: cart_page.resource  checkout_page.resource
#           inventory_page.resource  login_page.resource

# 2. Verificar que existen screenshots para cada test
ls results/screenshots/
# Esperado: 6 subcarpetas (una por test case)

# 3. Verificar que los screenshots tienen nomenclatura correcta
# macOS/Linux
ls results/screenshots/TC_01_Login_Exitoso_Con_Usuario_Est_ndar/ | head -5
# Esperado: archivos con formato YYYYMMDD_HHMMSS_nombre_paso.png

# 4. Verificar el reporte de ejecución filtrada por smoke
robot --dryrun --include smoke --outputdir results/reports tests/swag_labs_suite.robot
# Esperado: 2 tests seleccionados

# 5. Verificar el reporte de ejecución filtrada por critical
robot --dryrun --include critical --outputdir results/reports tests/swag_labs_suite.robot
# Esperado: 2 tests seleccionados

# 6. Verificar modo headless
robot --outputdir results/reports \
      --variable HEADLESS:True \
      --include smoke \
      tests/swag_labs_suite.robot
# Esperado: 2 tests passed sin abrir ventana del navegador
```

### Tabla de criterios de aceptación

| Criterio | Verificación | Estado |
|---|---|---|
| 4 Page Objects creados | `ls resources/pages/*.resource` → 4 archivos | ☐ |
| 6 casos de prueba en la suite | Reporte muestra 6 tests | ☐ |
| Tags smoke=2, regression=4, critical=2 | Statistics by Tag en report.html | ☐ |
| Screenshots en subcarpetas por test | `ls results/screenshots/` → 6 carpetas | ☐ |
| Nomenclatura `timestamp_test_paso.png` | Inspección visual de nombres de archivo | ☐ |
| Captura en fallo funciona | Forzar fallo en TC-01 y verificar screenshot | ☐ |
| Ejecución headless funciona | `--variable HEADLESS:True` sin ventana visible | ☐ |
| README con instrucciones completas | Archivo `README.md` presente y legible | ☐ |

### Prueba de captura en fallo (opcional pero recomendada)

Para verificar que el sistema de captura en fallo funciona, modifica temporalmente TC-01 añadiendo una aserción que falle:

```robotframework
# Añadir temporalmente al final de TC-01 para probar el teardown
    Should Be Equal    forzar_fallo    esto_fallara
```

Ejecuta TC-01 y verifica que se genera un screenshot con sufijo `FALLO_FINAL` en la subcarpeta correspondiente. Revierte el cambio después de verificar.

---

## Solución de Problemas

### Problema 1: `SessionNotCreatedException` — El driver de Chrome no coincide con la versión del navegador

**Síntoma:**
```
selenium.common.exceptions.SessionNotCreatedException:
Message: session not created: This version of ChromeDriver only supports Chrome version XX
Current browser version is YY.Z.AAAA.BB
```

**Causa:**
Selenium Manager no pudo descargar el driver correcto (falta de conexión a internet, caché corrupta) o se está usando una versión de Selenium anterior a 4.6 que no incluye Selenium Manager.

**Solución:**
```bash
# 1. Verificar versión de Selenium instalada
pip show selenium

# 2. Si la versión es < 4.6, actualizar
pip install --upgrade selenium

# 3. Limpiar caché de Selenium Manager
# macOS/Linux
rm -rf ~/.cache/selenium

# Windows PowerShell
Remove-Item -Recurse -Force "$env:USERPROFILE\.cache\selenium"

# 4. Si el problema persiste, instalar webdriver-manager como respaldo
pip install webdriver-manager

# 5. Modificar browser_setup.resource para usar webdriver-manager explícitamente
# En Crear Opciones De Navegador, agregar antes de Open Browser:
# ${service}=    Evaluate
# ...    __import__('webdriver_manager.chrome', fromlist=['ChromeDriverManager']).ChromeDriverManager().install()
# ...    modules=webdriver_manager.chrome
```

---

### Problema 2: Los screenshots se guardan con rutas incorrectas o la carpeta no se crea

**Síntoma:**
```
OSError: [Errno 2] No such file or directory:
'/ruta/lab06-02/resources/common/../../results/screenshots/TC_01.../screenshot.png'
```
O bien, los screenshots aparecen en el directorio de trabajo actual en lugar de en `results/screenshots/`.

**Causa:**
La variable `${CURDIR}` en `browser_setup.resource` resuelve al directorio donde está ubicado el archivo `.resource` (`resources/common/`), no al directorio raíz del proyecto. La ruta relativa `../../results/screenshots` puede no resolverse correctamente en todos los sistemas operativos.

**Solución:**
Cambia la definición de `${SCREENSHOTS_DIR}` en `browser_setup.resource` para usar una ruta absoluta basada en el directorio de ejecución:

```robotframework
# Opción 1: Usar variable de Robot Framework basada en el directorio de salida
${SCREENSHOTS_DIR}    ${OUTPUT DIR}${/}screenshots

# Opción 2: Definir la ruta desde la suite principal y pasarla como variable
# En swag_labs_suite.robot, añadir en *** Variables ***:
# ${SCREENSHOTS_DIR}    ${CURDIR}${/}..${/}results${/}screenshots
# Y en browser_setup.resource, eliminar la definición de ${SCREENSHOTS_DIR}
# para que tome el valor de la suite.
```

La opción 1 es la más robusta: `${OUTPUT DIR}` es una variable automática de Robot Framework que apunta al directorio donde se generan los reportes (el valor de `--outputdir`), garantizando que screenshots y reportes estén siempre en la misma ubicación.

---

## Limpieza del Entorno

Una vez completado el laboratorio y verificado el entregable, ejecuta los siguientes pasos de limpieza:

```bash
# 1. Cerrar todos los procesos de Chrome/ChromeDriver residuales
# macOS/Linux
pkill -f chromedriver || true
pkill -f "Google Chrome" || true

# Windows PowerShell
Stop-Process -Name "chromedriver" -ErrorAction SilentlyContinue
Stop-Process -Name "chrome" -ErrorAction SilentlyContinue

# 2. Crear copia de respaldo del proyecto completado (recomendado)
# macOS/Linux
cp -r lab06-02 lab06-02_backup_$(date +%Y%m%d)

# Windows PowerShell
$fecha = Get-Date -Format "yyyyMMdd"
Copy-Item -Recurse lab06-02 "lab06-02_backup_$fecha"

# 3. Limpiar archivos temporales de resultados (opcional, conservar para revisión)
# Solo si deseas liberar espacio en disco:
# rm -rf lab06-02/results/screenshots/*
# rm -rf lab06-02/results/reports/*

# 4. Desactivar el entorno virtual
deactivate
```

> **Importante:** Conserva la carpeta `lab06-02_backup_YYYYMMDD` como punto de partida para los laboratorios posteriores del módulo 6. Los módulos 4 y 5 del curso pueden requerir este proyecto como base.

---

## Resumen

En este laboratorio construiste desde cero una suite web completa aplicando todos los conceptos clave del módulo:

| Concepto | Implementación realizada |
|---|---|
| **Configuración de navegador (lección 6.1)** | `browser_setup.resource` con `ChromeOptions`, headless, timeout global |
| **Page Object Model** | 4 recursos independientes: `LoginPage`, `InventoryPage`, `CartPage`, `CheckoutPage` |
| **Sistema de evidencias** | Keyword `Capturar Evidencia` con nomenclatura `timestamp_test_paso.png` y subcarpetas |
| **Captura en fallo** | `Capturar Evidencia En Fallo` en `[Teardown]` de cada test |
| **Tags y filtrado** | `smoke`(2), `regression`(4), `critical`(2), `negative`(2) |
| **Flujo E2E** | Login → Inventario → Carrito → Checkout → Confirmación |
| **Keywords reutilizables** | Capa de abstracción que elimina duplicación entre los 6 test cases |

### Principios de diseño aplicados

- **Separación de responsabilidades:** Cada Page Object conoce solo su propia página; la suite orquesta el flujo entre páginas.
- **Estado limpio por test:** El `[Setup]` de cada test navega a la página de login, garantizando independencia entre casos.
- **Configuración externalizable:** Las opciones de navegador, URL base y modo headless son variables sobrescribibles desde la línea de comandos.
- **Evidencias estructuradas:** El sistema de screenshots permite trazabilidad completa de cada ejecución sin intervención manual.

### Recursos adicionales

- [SeleniumLibrary Keywords Reference](https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html)
- [Swag Labs — Aplicación de práctica](https://www.saucedemo.com)
- [Robot Framework User Guide — Tags](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#tagging-test-cases)
- [Selenium Manager Documentation](https://www.selenium.dev/documentation/selenium_manager/)
- [Page Object Model en Robot Framework (RFBestPractices)](https://docs.robotframework.org/docs/examples/page_object_model)

---

