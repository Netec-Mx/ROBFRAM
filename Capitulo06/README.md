# Automatización de flujo de login y navegación E2E

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
*Lab 06-00-01 — Módulo 6: Automatización Web con SeleniumLibrary y Page Object Model*

---

---LAB_START---
LAB_ID: 06-00-02
---MARKDOWN---
# Suite web con Page Object y captura de evidencias completas

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
LAB_END---
