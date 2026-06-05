# Práctica 11: Automatización de flujo de login y navegación E2E

## Metadatos

| Campo | Detalle |
|---|---|
| **Duración estimada** | 72 minutos |
| **Complejidad** | Media |
| **Nivel Bloom** | Aplicar (*Apply*) |
| **Módulo** | 6 — Automatización Web con SeleniumLibrary y Page Object Model |
| **Laboratorio previo requerido** | Módulos 1–5 completados |

---

## Descripción General

En este laboratorio automatizarás el flujo completo de autenticación y navegación post-login en la aplicación demo pública **The Internet** (`https://the-internet.herokuapp.com`), que es un entorno de práctica diseñado específicamente para pruebas de automatización web. Aplicarás el patrón **Page Object Model (POM)** creando archivos de recursos separados por página, configurarás Chrome con opciones avanzadas (modo *headless*, tamaño de ventana) usando la integración de SeleniumLibrary con Selenium Manager, y construirás estrategias de sincronización robustas. Al finalizar, dispondrás de una suite con cuatro casos de prueba respaldados por capturas de pantalla automáticas como evidencia de ejecución.

---

## Objetivos de Aprendizaje

Al completar este laboratorio, serás capaz de:

- [ ] Configurar SeleniumLibrary con opciones de Chrome personalizadas (modo *headless*, tamaño de ventana) usando el patrón de keyword reutilizable `Crear Opciones De Navegador`.
- [ ] Construir al menos 3 localizadores CSS y 3 localizadores XPath robustos para elementos de formularios de login, justificando la elección de cada uno.
- [ ] Implementar estrategias de sincronización con `Wait Until Element Is Visible` y `Set Selenium Timeout` para manejar tiempos de carga variables.
- [ ] Aplicar el patrón Page Object en Robot Framework creando archivos de recursos separados (`login_page.resource` y `dashboard_page.resource`) que encapsulen la interacción con la UI.
- [ ] Capturar screenshots automáticos en puntos críticos del flujo y configurar captura ante fallos en el `Suite Teardown`.

---

## Prerrequisitos

### Conocimientos Previos

- Sintaxis básica de Robot Framework: secciones `*** Settings ***`, `*** Variables ***`, `*** Keywords ***`, `*** Test Cases ***`
- Concepto de archivos Resource y su importación con `Resource`
- Uso básico de variables escalares `${VAR}` y listas `@{LIST}` en Robot Framework
- Comprensión del patrón Page Object Model (conceptual)
- Familiaridad con selectores CSS y XPath básicos

### Acceso y Software Requerido

| Componente | Versión mínima | Verificación |
|---|---|---|
| Python | 3.10+ | `python --version` |
| pip | 23.x+ | `pip --version` |
| Robot Framework | 7.x | `robot --version` |
| SeleniumLibrary | 6.2+ | `pip show robotframework-seleniumlibrary` |
| Selenium | 4.6+ (incluye Selenium Manager) | `pip show selenium` |
| Google Chrome | Última estable | Menú → Ayuda → Acerca de |
| VS Code | 1.85+ | Menú → Ayuda → Acerca de |
| Extensión RobotCode | 1.12+ | VS Code Extensions panel |
| Conexión a internet | 10 Mbps+ | Para acceder a `the-internet.herokuapp.com` |

---

## Entorno de Laboratorio

### Configuración del Entorno Virtual

> **⚠️ OBLIGATORIO:** Todos los comandos deben ejecutarse dentro del entorno virtual del curso. Verifica que el prompt muestre `(venv)` antes de continuar.

**Activar el entorno virtual existente:**

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

**Verificar e instalar dependencias necesarias:**

```bash
# Verificar instalaciones clave
pip show robotframework-seleniumlibrary
pip show selenium

# Si SeleniumLibrary no está instalado:
pip install robotframework-seleniumlibrary>=6.2.0

# Verificar que Selenium >= 4.6 (incluye Selenium Manager automático)
pip install "selenium>=4.6.0"

# Confirmar versiones instaladas
pip show selenium | grep Version
pip show robotframework-seleniumlibrary | grep Version
```

**Verificar que Chrome está disponible:**

```bash
# Windows
where chrome
# o buscar en: C:\Program Files\Google\Chrome\Application\chrome.exe

# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Linux
google-chrome --version
# o
chromium-browser --version
```

> **Nota sobre Selenium Manager:** Con Selenium 4.6+, el `selenium-manager` integrado detecta automáticamente la versión de Chrome instalada y descarga el ChromeDriver compatible. No es necesario instalar `webdriver-manager` por separado para este laboratorio.

### Estructura de Directorios del Proyecto

Al finalizar el laboratorio, la estructura del proyecto será:

```
lab-06-00-01/
├── tests/
│   └── login_suite.robot
├── resources/
│   ├── browser_setup.resource
│   ├── login_page.resource
│   └── dashboard_page.resource
├── results/
│   └── (generado automáticamente por Robot Framework)
└── README.md
```

**Crear la estructura inicial:**

```bash
# Windows (cmd)
mkdir lab-06-00-01
cd lab-06-00-01
mkdir tests resources results

# macOS / Linux
mkdir -p lab-06-00-01/{tests,resources,results}
cd lab-06-00-01
```

---

## Pasos del Laboratorio

---

### Paso 1: Análisis del DOM de la Aplicación Demo

**Objetivo:** Identificar los elementos clave de la página de login de *The Internet* y construir localizadores CSS y XPath robustos antes de escribir código.

#### Instrucciones

1. Abre Google Chrome y navega a `https://the-internet.herokuapp.com/login`.

2. Abre las **DevTools** de Chrome (F12 o Clic derecho → Inspeccionar).

3. Examina el formulario de login y localiza los siguientes elementos. Usa la pestaña **Elements** para inspeccionar el HTML:

   - Campo de nombre de usuario
   - Campo de contraseña
   - Botón de submit
   - Mensaje de error (para login fallido)
   - Mensaje de éxito / área de bienvenida (para login exitoso)

4. Completa la siguiente tabla de localizadores en tu cuaderno o en un archivo de texto:

   | Elemento | Localizador CSS | Localizador XPath |
   |---|---|---|
   | Campo username | `#username` | `//input[@id='username']` |
   | Campo password | `#password` | `//input[@id='password']` |
   | Botón Login | `button[type='submit']` | `//button[@type='submit']` |
   | Mensaje flash (error/éxito) | `#flash` | `//div[@id='flash']` |
   | Enlace Logout | `a[href='/logout']` | `//a[@href='/logout']` |
   | Título de página segura | `h2` | `//h4[@class='subheader']` |

5. **Valida tus localizadores** usando la consola de DevTools:

   ```javascript
   // Validar localizador CSS en la consola del navegador
   document.querySelector('#username')
   document.querySelector('button[type="submit"]')

   // Validar XPath en la consola del navegador
   $x("//input[@id='username']")
   $x("//button[@type='submit']")
   ```

   Cada comando debe devolver el elemento HTML correspondiente, no `null` ni un array vacío.

6. Anota las credenciales de prueba que proporciona la aplicación (visibles en la propia página de login):
   - **Usuario válido:** `tomsmith`
   - **Contraseña válida:** `SuperSecretPassword!`

#### Resultado Esperado

La consola de DevTools devuelve los elementos correctos para cada localizador. Tienes una tabla completa con 3 localizadores CSS y 3 XPath validados manualmente.

#### Verificación

```javascript
// En la consola de Chrome DevTools, estos comandos NO deben devolver null:
console.assert(document.querySelector('#username') !== null, "username field not found");
console.assert(document.querySelector('#password') !== null, "password field not found");
console.assert(document.querySelector('button[type="submit"]') !== null, "submit button not found");
```

---

### Paso 2: Crear el Archivo de Configuración del Navegador

**Objetivo:** Implementar el archivo `browser_setup.resource` con keywords reutilizables para iniciar y cerrar sesiones de Chrome con opciones personalizadas, siguiendo el patrón aprendido en la lección 6.1.

#### Instrucciones

1. Crea el archivo `resources/browser_setup.resource` con el siguiente contenido:

```robotframework
*** Settings ***
Documentation    Configuración centralizada del navegador para todas las suites del Módulo 6.
...              Implementa el patrón de keyword reutilizable para apertura de Chrome con opciones
...              personalizadas (headless, tamaño de ventana, sandbox) según lección 6.1.
Library          SeleniumLibrary

*** Variables ***
# --- Configuración del navegador ---
${NAVEGADOR}          chrome
${HEADLESS}           ${FALSE}
${VENTANA_ANCHO}      1920
${VENTANA_ALTO}       1080
${TIMEOUT_GLOBAL}     15s
${IMPLICIT_WAIT}      0s

# --- URL base de la aplicación bajo prueba ---
${URL_BASE}           https://the-internet.herokuapp.com

*** Keywords ***
Iniciar Sesión De Navegador
    [Documentation]    Keyword reutilizable que abre Chrome con configuración estándar del proyecto.
    ...                Controla el modo headless mediante la variable ${HEADLESS}.
    ...                Configura el timeout global de Selenium para toda la suite.
    [Arguments]    ${url}=${URL_BASE}
    ${opciones}=    Crear Opciones De Chrome
    Open Browser    ${url}    ${NAVEGADOR}    options=${opciones}
    Set Selenium Timeout    ${TIMEOUT_GLOBAL}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Run Keyword If    not ${HEADLESS}    Maximize Browser Window

Crear Opciones De Chrome
    [Documentation]    Construye el objeto ChromeOptions con los argumentos requeridos.
    ...                En modo headless se fija la resolución de ventana virtual.
    ...                Los argumentos --no-sandbox y --disable-dev-shm-usage son necesarios
    ...                en entornos Linux/Docker y no causan problemas en Windows/macOS.
    ${opciones}=    Evaluate    selenium.webdriver.ChromeOptions()    modules=selenium.webdriver
    IF    ${HEADLESS}
        Call Method    ${opciones}    add_argument    --headless=new
        Call Method    ${opciones}    add_argument    --window-size\=${VENTANA_ANCHO},${VENTANA_ALTO}
    END
    Call Method    ${opciones}    add_argument    --no-sandbox
    Call Method    ${opciones}    add_argument    --disable-dev-shm-usage
    Call Method    ${opciones}    add_argument    --disable-extensions
    Call Method    ${opciones}    add_argument    --disable-gpu
    RETURN    ${opciones}

Cerrar Sesión De Navegador
    [Documentation]    Cierra todas las sesiones de navegador activas de forma segura.
    ...                Debe llamarse en Suite Teardown o Test Teardown.
    Close All Browsers

Capturar Evidencia
    [Documentation]    Toma un screenshot con un nombre descriptivo para evidencia de ejecución.
    ...                El archivo se guarda en el directorio de resultados configurado en robot.
    [Arguments]    ${nombre_evidencia}=evidencia
    ${timestamp}=    Get Time    epoch
    Capture Page Screenshot    ${nombre_evidencia}_${timestamp}.png
```

2. Guarda el archivo.

3. **Verifica la sintaxis** abriendo una terminal en el directorio `lab-06-00-01` y ejecutando:

```bash
# Verificar sintaxis del archivo resource (no ejecuta tests, solo valida)
python -m robot --dryrun --nostatusrc resources/browser_setup.resource 2>&1 | head -20
```

#### Resultado Esperado

El comando `--dryrun` finaliza sin errores de sintaxis. Si hay errores, aparecerán con el número de línea para facilitar la corrección.

#### Verificación

```bash
# La salida debe contener "Dry run" y no líneas con "ERROR"
python -m robot --dryrun --nostatusrc resources/browser_setup.resource
```

---

### Paso 3: Crear el Page Object de la Página de Login

**Objetivo:** Implementar `resources/login_page.resource` encapsulando todos los localizadores y keywords de interacción con la página de login, aplicando el patrón Page Object Model.

#### Instrucciones

1. Crea el archivo `resources/login_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para la página de login de The Internet.
...              Encapsula todos los localizadores y keywords de interacción con el formulario
...              de autenticación. Ningún test case debe referenciar localizadores directamente;
...              toda interacción debe pasar por las keywords de este archivo.
Library          SeleniumLibrary
Resource         browser_setup.resource

*** Variables ***
# --- URL de la página ---
${URL_LOGIN}                  ${URL_BASE}/login

# --- Localizadores CSS (preferidos por rendimiento) ---
${LOC_CSS_USERNAME}           #username
${LOC_CSS_PASSWORD}           #password
${LOC_CSS_BTN_SUBMIT}         button[type='submit']
${LOC_CSS_FLASH_MSG}          #flash
${LOC_CSS_FLASH_SUCCESS}      #flash.success
${LOC_CSS_FLASH_ERROR}        #flash.error

# --- Localizadores XPath (para casos donde CSS no es suficiente) ---
${LOC_XPATH_USERNAME}         //input[@id='username']
${LOC_XPATH_PASSWORD}         //input[@id='password']
${LOC_XPATH_BTN_SUBMIT}       //button[@type='submit']
${LOC_XPATH_FLASH_MSG}        //div[@id='flash']
${LOC_XPATH_LOGIN_FORM}       //form[@id='login']
${LOC_XPATH_H2_TITLE}         //h2[contains(text(),'Login Page')]

# --- Textos esperados ---
${TEXTO_LOGIN_EXITOSO}        You logged into a secure area!
${TEXTO_USUARIO_INVALIDO}     Your username is invalid!
${TEXTO_PASSWORD_INVALIDO}    Your password is invalid!
${TEXTO_CAMPOS_VACIOS}        Your username is invalid!

*** Keywords ***
Navegar A Página De Login
    [Documentation]    Navega directamente a la URL del formulario de login y verifica
    ...                que la página cargó correctamente antes de continuar.
    Go To    ${URL_LOGIN}
    Wait Until Element Is Visible    ${LOC_CSS_USERNAME}    timeout=10s
    Element Should Be Visible    ${LOC_CSS_PASSWORD}
    Element Should Be Visible    ${LOC_CSS_BTN_SUBMIT}

Ingresar Credenciales
    [Documentation]    Escribe las credenciales en los campos del formulario de login.
    ...                Limpia los campos antes de escribir para evitar datos residuales.
    [Arguments]    ${usuario}    ${password}
    Wait Until Element Is Visible    ${LOC_CSS_USERNAME}    timeout=10s
    Clear Element Text    ${LOC_CSS_USERNAME}
    Input Text    ${LOC_CSS_USERNAME}    ${usuario}
    Clear Element Text    ${LOC_CSS_PASSWORD}
    Input Password    ${LOC_CSS_PASSWORD}    ${password}

Hacer Clic En Botón Login
    [Documentation]    Hace clic en el botón de submit y espera a que la página responda.
    ...                Usa Wait Until Element Is Visible sobre el mensaje flash como señal
    ...                de que el servidor procesó la solicitud.
    Wait Until Element Is Visible    ${LOC_CSS_BTN_SUBMIT}    timeout=5s
    Click Button    ${LOC_CSS_BTN_SUBMIT}
    Wait Until Element Is Visible    ${LOC_CSS_FLASH_MSG}    timeout=10s

Realizar Login
    [Documentation]    Keyword de alto nivel que ejecuta el flujo completo de login:
    ...                navegar → ingresar credenciales → hacer clic → esperar respuesta.
    [Arguments]    ${usuario}    ${password}
    Navegar A Página De Login
    Ingresar Credenciales    ${usuario}    ${password}
    Hacer Clic En Botón Login

Verificar Login Exitoso
    [Documentation]    Valida que el mensaje flash contiene el texto de éxito y que
    ...                la URL cambió a la sección segura.
    Wait Until Element Is Visible    ${LOC_CSS_FLASH_MSG}    timeout=10s
    Element Should Contain    ${LOC_CSS_FLASH_MSG}    ${TEXTO_LOGIN_EXITOSO}
    Location Should Contain    /secure
    Capturar Evidencia    login_exitoso

Verificar Login Fallido
    [Documentation]    Valida que el mensaje flash contiene un texto de error.
    ...                Acepta cualquier mensaje de error como válido (usuario o password inválido).
    [Arguments]    ${texto_error_esperado}=${TEXTO_USUARIO_INVALIDO}
    Wait Until Element Is Visible    ${LOC_CSS_FLASH_MSG}    timeout=10s
    Element Should Contain    ${LOC_CSS_FLASH_MSG}    ${texto_error_esperado}
    Location Should Contain    /login
    Capturar Evidencia    login_fallido

Verificar Que Los Campos Están Vacíos
    [Documentation]    Confirma que los campos username y password no contienen texto.
    ${valor_username}=    Get Value    ${LOC_CSS_USERNAME}
    ${valor_password}=    Get Value    ${LOC_CSS_PASSWORD}
    Should Be Empty    ${valor_username}
    Should Be Empty    ${valor_password}
```

2. Guarda el archivo.

#### Resultado Esperado

El archivo `login_page.resource` está creado con 6 keywords bien documentadas, 6 localizadores CSS y 6 localizadores XPath definidos como variables.

#### Verificación

```bash
# Verificar que el archivo tiene la sintaxis correcta
python -m robot --dryrun --nostatusrc resources/login_page.resource
```

---

### Paso 4: Crear el Page Object del Dashboard / Área Segura

**Objetivo:** Implementar `resources/dashboard_page.resource` que encapsule la interacción con la página segura post-login, incluyendo la keyword de logout.

#### Instrucciones

1. Crea el archivo `resources/dashboard_page.resource`:

```robotframework
*** Settings ***
Documentation    Page Object para el área segura (Secure Area / Dashboard) de The Internet.
...              Encapsula localizadores y keywords para la página que se muestra tras
...              un login exitoso. Incluye verificaciones de contenido y la acción de logout.
Library          SeleniumLibrary
Resource         browser_setup.resource

*** Variables ***
# --- URL esperada tras login exitoso ---
${URL_SECURE}                 ${URL_BASE}/secure

# --- Localizadores CSS ---
${LOC_CSS_LOGOUT_BTN}         a[href='/logout']
${LOC_CSS_SECURE_HEADER}      h2
${LOC_CSS_FLASH_MSG}          #flash
${LOC_CSS_SUBHEADER}          h4.subheader

# --- Localizadores XPath ---
${LOC_XPATH_LOGOUT_BTN}       //a[@href='/logout']
${LOC_XPATH_SECURE_HEADER}    //h2[contains(text(),'Secure Area')]
${LOC_XPATH_SUBHEADER}        //h4[@class='subheader']
${LOC_XPATH_CONTENT_DIV}      //div[@class='example']

# --- Textos esperados ---
${TEXTO_SECURE_HEADER}        Secure Area
${TEXTO_SUBHEADER}            Welcome to the Secure Area. When you are done click logout below.
${TEXTO_LOGOUT_EXITOSO}       You logged out of the secure area!

*** Keywords ***
Verificar Que Está En El Área Segura
    [Documentation]    Valida que el usuario llegó correctamente a la página segura
    ...                verificando URL, título de página y presencia del botón logout.
    Wait Until Element Is Visible    ${LOC_CSS_SECURE_HEADER}    timeout=10s
    Location Should Be    ${URL_SECURE}
    Element Should Contain    ${LOC_CSS_SECURE_HEADER}    ${TEXTO_SECURE_HEADER}
    Element Should Be Visible    ${LOC_CSS_LOGOUT_BTN}
    Capturar Evidencia    area_segura_verificada

Verificar Contenido Del Dashboard
    [Documentation]    Verifica que los elementos principales del dashboard están presentes
    ...                y contienen el texto esperado.
    Element Should Be Visible    ${LOC_CSS_SECURE_HEADER}
    Element Should Be Visible    ${LOC_CSS_SUBHEADER}
    ${titulo}=    Get Text    ${LOC_CSS_SECURE_HEADER}
    Should Contain    ${titulo}    ${TEXTO_SECURE_HEADER}

Navegar A Sección Protegida Directamente
    [Documentation]    Intenta acceder directamente a la URL segura sin autenticación previa.
    ...                Útil para verificar que la aplicación redirige correctamente.
    Go To    ${URL_SECURE}
    Sleep    1s    reason=Esperar redirección del servidor

Realizar Logout
    [Documentation]    Hace clic en el botón de logout y verifica que la sesión se cerró.
    Wait Until Element Is Visible    ${LOC_CSS_LOGOUT_BTN}    timeout=10s
    Click Link    ${LOC_CSS_LOGOUT_BTN}
    Wait Until Element Is Visible    ${LOC_CSS_FLASH_MSG}    timeout=10s
    Element Should Contain    ${LOC_CSS_FLASH_MSG}    ${TEXTO_LOGOUT_EXITOSO}
    Location Should Contain    /login
    Capturar Evidencia    logout_completado
```

2. Guarda el archivo.

#### Resultado Esperado

El archivo `dashboard_page.resource` está creado con 4 keywords y localizadores para el área segura.

#### Verificación

```bash
python -m robot --dryrun --nostatusrc resources/dashboard_page.resource
```

---

### Paso 5: Construir la Suite de Pruebas Principal

**Objetivo:** Crear el archivo `tests/login_suite.robot` con los 4 casos de prueba requeridos, importando los Page Objects y configurando el Setup/Teardown de suite correctamente.

#### Instrucciones

1. Crea el archivo `tests/login_suite.robot`:

```robotframework
*** Settings ***
Documentation       Suite de pruebas E2E para el flujo de login y navegación en The Internet.
...
...                 Casos de prueba:
...                 1. Login exitoso con credenciales válidas
...                 2. Login fallido con contraseña incorrecta
...                 3. Login fallido con campos vacíos
...                 4. Navegación a sección protegida post-login y logout
...
...                 Aplica el patrón Page Object Model (POM) con archivos de recursos separados
...                 por página. Toda interacción con el DOM pasa por keywords de los Page Objects.
...
...                 Aplicación bajo prueba: https://the-internet.herokuapp.com
...                 Credenciales válidas: tomsmith / SuperSecretPassword!

# Importar la biblioteca directamente para keywords de bajo nivel si se necesitan
Library             SeleniumLibrary

# Importar los Page Objects (ruta relativa desde el directorio de ejecución)
Resource            ../resources/browser_setup.resource
Resource            ../resources/login_page.resource
Resource            ../resources/dashboard_page.resource

# Configuración de Suite: abrir navegador antes de todos los tests, cerrar al final
Suite Setup         Iniciar Sesión De Navegador    ${URL_BASE}
Suite Teardown      Run Keywords
...                 Capturar Evidencia    suite_teardown_final    AND
...                 Cerrar Sesión De Navegador

# Si un test falla, capturar screenshot antes de continuar con el siguiente
Test Teardown       Run Keyword If Test Failed    Capture Page Screenshot    fallo_${TEST_NAME}.png

*** Variables ***
# Credenciales de prueba
${USUARIO_VALIDO}       tomsmith
${PASSWORD_VALIDO}      SuperSecretPassword!
${USUARIO_INVALIDO}     usuario_inexistente
${PASSWORD_INVALIDO}    password_incorrecta
${USUARIO_VACIO}        ${EMPTY}
${PASSWORD_VACIO}       ${EMPTY}

*** Test Cases ***

TC-01: Login Exitoso Con Credenciales Válidas
    [Documentation]    Verifica que un usuario con credenciales correctas puede autenticarse
    ...                exitosamente y accede al área segura de la aplicación.
    ...                Criterio de aceptación: mensaje de éxito visible, URL contiene /secure.
    [Tags]    login    smoke    positivo
    Realizar Login    ${USUARIO_VALIDO}    ${PASSWORD_VALIDO}
    Verificar Login Exitoso
    Verificar Que Está En El Área Segura
    Verificar Contenido Del Dashboard

TC-02: Login Fallido Con Contraseña Incorrecta
    [Documentation]    Verifica que un usuario con contraseña incorrecta recibe un mensaje
    ...                de error apropiado y permanece en la página de login.
    ...                Criterio de aceptación: mensaje de error visible, URL contiene /login.
    [Tags]    login    negativo    seguridad
    Navegar A Página De Login
    Ingresar Credenciales    ${USUARIO_VALIDO}    ${PASSWORD_INVALIDO}
    Hacer Clic En Botón Login
    Verificar Login Fallido    ${TEXTO_PASSWORD_INVALIDO}

TC-03: Login Fallido Con Campos Vacíos
    [Documentation]    Verifica que intentar hacer login sin ingresar credenciales muestra
    ...                el mensaje de error correspondiente y no permite el acceso.
    ...                Criterio de aceptación: mensaje de error visible, URL contiene /login.
    [Tags]    login    negativo    validacion
    Navegar A Página De Login
    Verificar Que Los Campos Están Vacíos
    Hacer Clic En Botón Login
    Verificar Login Fallido    ${TEXTO_CAMPOS_VACIOS}

TC-04: Navegación A Sección Protegida Post-Login Y Logout
    [Documentation]    Verifica el flujo completo: login → navegación al área segura →
    ...                verificación de contenido → logout exitoso.
    ...                Este caso prueba la integración entre LoginPage y DashboardPage.
    ...                Criterio de aceptación: logout exitoso, usuario regresa a /login.
    [Tags]    login    navegacion    flujo-completo    e2e
    Realizar Login    ${USUARIO_VALIDO}    ${PASSWORD_VALIDO}
    Verificar Login Exitoso
    Verificar Que Está En El Área Segura
    Verificar Contenido Del Dashboard
    Realizar Logout
    # Verificar que después del logout no se puede acceder al área segura
    Navegar A Sección Protegida Directamente
    Wait Until Element Is Visible    ${LOC_CSS_FLASH_MSG}    timeout=10s
    Capturar Evidencia    post_logout_redireccion
```

2. Guarda el archivo.

3. **Verifica la sintaxis completa** de toda la suite:

```bash
# Desde el directorio lab-06-00-01
python -m robot --dryrun --nostatusrc tests/login_suite.robot
```

#### Resultado Esperado

El `--dryrun` muestra los 4 test cases identificados sin errores de sintaxis. La salida debe indicar que todas las keywords están resueltas correctamente.

#### Verificación

```bash
# La salida debe mostrar exactamente 4 tests encontrados
python -m robot --dryrun tests/login_suite.robot 2>&1 | grep -E "test|Test|ERROR"
```

---

### Paso 6: Ejecutar la Suite Completa

**Objetivo:** Ejecutar los 4 casos de prueba, verificar que pasan correctamente y revisar los artefactos generados (reporte HTML, log, screenshots).

#### Instrucciones

1. Asegúrate de estar en el directorio raíz del proyecto (`lab-06-00-01`) con el venv activado.

2. **Ejecutar la suite completa** con salida de resultados en el directorio `results/`:

```bash
# Ejecución estándar (con interfaz gráfica de Chrome visible)
python -m robot --outputdir results --loglevel DEBUG tests/login_suite.robot
```

3. **Observa la salida en consola** durante la ejecución. Deberías ver:

```
==============================================================================
Login Suite
==============================================================================
TC-01: Login Exitoso Con Credenciales Válidas                         | PASS |
TC-02: Login Fallido Con Contraseña Incorrecta                        | PASS |
TC-03: Login Fallido Con Campos Vacíos                                | PASS |
TC-04: Navegación A Sección Protegida Post-Login Y Logout             | PASS |
==============================================================================
Login Suite                                                           | PASS |
4 tests, 4 passed, 0 failed
==============================================================================
```

4. **Ejecutar en modo headless** (sin interfaz gráfica):

```bash
# Pasar la variable HEADLESS=True por línea de comandos
python -m robot --outputdir results --variable HEADLESS:${TRUE} tests/login_suite.robot

# Alternativa con sintaxis de variable string que Robot Framework interpreta como booleano
python -m robot --outputdir results -v HEADLESS:True tests/login_suite.robot
```

> **Nota:** Al pasar `-v HEADLESS:True` desde línea de comandos, Robot Framework recibe el string `"True"`. La keyword `IF ${HEADLESS}` evalúa strings no vacíos como verdaderos. Si necesitas pasar un booleano estricto, usa la variable en el archivo `.robot` directamente o ajusta la keyword `Crear Opciones De Chrome` para comparar con `Should Be Equal As Strings`.

5. **Ejecutar solo tests con un tag específico:**

```bash
# Ejecutar solo tests de smoke
python -m robot --outputdir results --include smoke tests/login_suite.robot

# Ejecutar solo tests negativos
python -m robot --outputdir results --include negativo tests/login_suite.robot

# Ejecutar el flujo completo E2E
python -m robot --outputdir results --include flujo-completo tests/login_suite.robot
```

6. **Abrir el reporte HTML** generado:

```bash
# Windows
start results\report.html

# macOS
open results/report.html

# Linux
xdg-open results/report.html
```

#### Resultado Esperado

- Los 4 tests pasan (verde en el reporte HTML).
- El directorio `results/` contiene: `output.xml`, `log.html`, `report.html` y los archivos `.png` de screenshots.
- El reporte HTML muestra el árbol de keywords ejecutadas con tiempos de ejecución.

#### Verificación

```bash
# Verificar que los archivos de resultados fueron generados
ls -la results/
# Debe mostrar: output.xml, log.html, report.html y archivos .png

# Windows
dir results\
```

---

### Paso 7: Revisar Evidencias y Reporte HTML

**Objetivo:** Navegar el reporte HTML y el log detallado para verificar que las evidencias (screenshots) están embebidas correctamente y que el flujo de ejecución es trazable.

#### Instrucciones

1. Abre `results/report.html` en Chrome.

2. Verifica la **sección de estadísticas** en la parte superior:
   - Total: 4 tests
   - Passed: 4
   - Failed: 0

3. Navega al **Log** (`results/log.html`) y expande el árbol de TC-01:
   - Verifica que la keyword `Realizar Login` aparece con sus sub-keywords anidadas.
   - Localiza los screenshots capturados por `Capturar Evidencia`.
   - Confirma que las imágenes muestran el estado correcto de la pantalla en cada punto.

4. Busca en el log los screenshots capturados por el `Test Teardown` (deben aparecer solo si algún test falló).

5. **Verificar screenshots individuales:**

```bash
# Listar todos los screenshots generados
ls results/*.png

# Windows
dir results\*.png
```

6. Abre al menos 2 screenshots y verifica que muestran el estado correcto de la aplicación en el momento de la captura.

#### Resultado Esperado

El log HTML muestra el árbol completo de keywords con tiempos de ejecución. Los screenshots están embebidos en el log y muestran el estado correcto de la aplicación. El reporte confirma 4/4 tests pasados.

#### Verificación

```bash
# Verificar que se generaron screenshots de evidencia
ls results/ | grep -E "\.png$" | wc -l
# Debe mostrar al menos 4 archivos PNG (uno por cada Capturar Evidencia llamado)
```

---

## Validación y Pruebas

### Lista de Verificación Final

Completa esta checklist antes de dar por terminado el laboratorio:

| # | Criterio de Validación | Estado |
|---|---|---|
| 1 | Los 4 test cases pasan en ejecución normal (con Chrome visible) | ☐ |
| 2 | Los 4 test cases pasan en modo headless (`-v HEADLESS:True`) | ☐ |
| 3 | El archivo `browser_setup.resource` contiene `Crear Opciones De Chrome` con manejo de `IF ${HEADLESS}` | ☐ |
| 4 | `login_page.resource` define exactamente 6 localizadores CSS y 6 XPath | ☐ |
| 5 | `dashboard_page.resource` define keywords para verificación y logout | ☐ |
| 6 | Ningún test case referencia localizadores directamente (solo a través de keywords POM) | ☐ |
| 7 | El `Suite Teardown` cierra todas las sesiones de navegador | ☐ |
| 8 | El `Test Teardown` captura screenshot automáticamente ante fallos | ☐ |
| 9 | El directorio `results/` contiene `report.html`, `log.html`, `output.xml` y archivos `.png` | ☐ |
| 10 | El reporte HTML es legible en resolución 1280x768 o superior | ☐ |

### Prueba de Regresión Rápida

Ejecuta este comando para confirmar que toda la suite pasa limpiamente:

```bash
python -m robot \
    --outputdir results \
    --loglevel INFO \
    --report report_final.html \
    --log log_final.html \
    tests/login_suite.robot

# Verificar el código de retorno (0 = todos los tests pasaron)
echo "Código de retorno: $?"
# Windows PowerShell:
# echo "Código de retorno: $LASTEXITCODE"
```

La salida debe terminar con `4 tests, 4 passed, 0 failed` y el código de retorno debe ser `0`.

---

## Solución de Problemas

### Problema 1: `WebDriverException: Chrome failed to start` o `SessionNotCreatedException`

**Síntoma:**
La ejecución falla inmediatamente al intentar abrir el navegador con un error similar a:
```
WebDriverException: Message: unknown error: Chrome failed to start: exited abnormally.
  (unknown error: DevToolsActivePort file doesn't exist)
```
o
```
SessionNotCreatedException: Message: session not created: This version of ChromeDriver
only supports Chrome version XX
```

**Causa:**
Hay dos causas posibles: (a) la versión de ChromeDriver no coincide con la versión de Chrome instalada, o (b) Chrome no puede iniciarse en el entorno actual (especialmente en Linux sin display o en contenedores).

**Solución:**

```bash
# Paso 1: Verificar versión de Chrome instalada
google-chrome --version    # Linux
# Windows: chrome.exe --version en PowerShell

# Paso 2: Forzar actualización de Selenium Manager
pip install --upgrade selenium

# Paso 3: Limpiar caché de Selenium Manager
# Linux/macOS:
rm -rf ~/.cache/selenium/
# Windows:
# rmdir /s /q %USERPROFILE%\.cache\selenium

# Paso 4: Si el problema es el entorno (Linux sin display), agregar estos argumentos
# en Crear Opciones De Chrome:
#   Call Method    ${opciones}    add_argument    --headless=new
#   Call Method    ${opciones}    add_argument    --no-sandbox
#   Call Method    ${opciones}    add_argument    --disable-dev-shm-usage

# Paso 5: Verificar que Chrome está en el PATH del sistema
which google-chrome    # Linux/macOS
where chrome           # Windows cmd
```

Si el problema persiste, instala explícitamente `webdriver-manager` como alternativa:

```bash
pip install webdriver-manager

# Y modifica Crear Opciones De Chrome para usar ChromeDriverManager:
# En el archivo browser_setup.resource, reemplaza Open Browser por:
# ${service}=    Evaluate
# ...    __import__('webdriver_manager.chrome', fromlist=['ChromeDriverManager']).ChromeDriverManager().install()
# ...    modules=webdriver_manager.chrome
# Create Webdriver    Chrome    service=${service}
```

---

### Problema 2: `ElementNotVisibleException` o los tests fallan intermitentemente por timeouts

**Síntoma:**
Los tests fallan con mensajes como:
```
ElementNotVisibleException: Message: element not interactable
```
o
```
Keyword 'Wait Until Element Is Visible' failed after 10 seconds.
Element '#flash' did not appear in 10 seconds.
```
Los fallos son intermitentes (a veces pasan, a veces fallan).

**Causa:**
La aplicación `the-internet.herokuapp.com` está alojada en un servidor gratuito con latencia variable. En conexiones lentas o cuando el servidor está bajo carga, los tiempos de respuesta pueden superar los timeouts configurados. También puede ocurrir si la red del estudiante tiene latencia alta hacia servidores en EE.UU.

**Solución:**

```bash
# Paso 1: Aumentar el timeout global en browser_setup.resource
# Cambiar: ${TIMEOUT_GLOBAL}    15s
# Por:     ${TIMEOUT_GLOBAL}    30s

# Paso 2: O pasar el timeout como variable en línea de comandos sin modificar el archivo:
python -m robot --variable TIMEOUT_GLOBAL:30s --outputdir results tests/login_suite.robot

# Paso 3: Verificar conectividad con la aplicación
curl -I https://the-internet.herokuapp.com/login
# Debe devolver HTTP/2 200

# Paso 4: Si la latencia es consistentemente alta (>5s), considerar ejecutar
# los tests en horarios de menor carga o usar una instancia local de la aplicación:
# La aplicación está en GitHub: https://github.com/saucelabs/the-internet
# Se puede ejecutar localmente con Docker:
docker run -d -p 7080:80 gprestes/the-internet
# Y cambiar URL_BASE a http://localhost:7080
```

Si los fallos son solo en modo headless, verificar que el tamaño de ventana virtual está configurado correctamente (`--window-size=1920,1080`) ya que algunos elementos pueden no ser visibles en ventanas muy pequeñas.

---

## Limpieza del Entorno

### Pasos de Limpieza

1. **Cerrar todos los procesos de Chrome** que pudieran haber quedado abiertos:

```bash
# Linux/macOS
pkill -f chrome
pkill -f chromedriver

# Windows (cmd)
taskkill /F /IM chrome.exe /T
taskkill /F /IM chromedriver.exe /T

# Windows (PowerShell)
Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "chromedriver" -Force -ErrorAction SilentlyContinue
```

2. **Archivar los resultados** antes de limpiar (opcional pero recomendado):

```bash
# Crear un ZIP con los resultados del laboratorio
# Linux/macOS
zip -r lab-06-00-01-results.zip results/

# Windows PowerShell
Compress-Archive -Path results\ -DestinationPath lab-06-00-01-results.zip
```

3. **Limpiar resultados temporales** si se desea empezar de nuevo:

```bash
# Eliminar solo los archivos de resultados (no el código)
# Linux/macOS
rm -f results/*.xml results/*.html results/*.png

# Windows (cmd)
del /Q results\*.xml results\*.html results\*.png
```

4. **Desactivar el entorno virtual** al terminar la sesión:

```bash
deactivate
```

> **💡 Recordatorio:** Mantén una copia del directorio `lab-06-00-01/` completo. Los laboratorios posteriores del Módulo 6 construirán sobre esta estructura de Page Objects.

---

## Resumen

En este laboratorio has construido una suite de automatización web E2E completa aplicando el **patrón Page Object Model** en Robot Framework. Los logros principales son:

| Habilidad Desarrollada | Implementación Realizada |
|---|---|
| Configuración de SeleniumLibrary | `browser_setup.resource` con `Crear Opciones De Chrome` y soporte headless |
| Localizadores robustos | 6 CSS + 6 XPath definidos como variables en `login_page.resource` |
| Sincronización | `Wait Until Element Is Visible` con timeout configurable en todos los puntos de interacción |
| Page Object Model | Tres archivos de recursos separados por responsabilidad: `browser_setup`, `login_page`, `dashboard_page` |
| Gestión de evidencias | `Capturar Evidencia` en puntos clave + `Test Teardown` automático ante fallos |
| Suite estructurada | 4 casos de prueba con tags, documentación y Setup/Teardown de suite |

### Conceptos Clave Reforzados

- **Selenium Manager** (incluido en Selenium 4.6+) elimina la necesidad de gestionar ChromeDriver manualmente.
- El **patrón POM** en Robot Framework se implementa con archivos `.resource` separados por página, donde cada keyword encapsula la interacción con elementos específicos del DOM.
- El uso de **variables para localizadores** permite actualizar selectores en un único lugar cuando la UI cambia.
- `Set Selenium Timeout` establece un timeout global que aplica a todas las keywords de espera, evitando repetir el parámetro `timeout=` en cada llamada.
- `Suite Teardown` con `Close All Browsers` garantiza que los procesos del navegador se liberan independientemente del resultado de los tests.

### Recursos Adicionales

- [Documentación oficial de SeleniumLibrary](https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html)
- [Repositorio de The Internet (aplicación demo)](https://github.com/saucelabs/the-internet)
- [Selenium Manager documentation](https://www.selenium.dev/documentation/selenium_manager/)
- [Robot Framework User Guide — Resource Files](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#resource-files)
- [CSS Selectors Reference — MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_selectors)
- [XPath Axes — W3Schools](https://www.w3schools.com/xml/xpath_axes.asp)

---

