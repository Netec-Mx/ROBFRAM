# Capítulo 6 — Automatización Web con SeleniumLibrary

## Información general

Este capítulo aplica todo lo aprendido sobre sintaxis, variables y manejo de fallas a un dominio concreto: la automatización de interfaces web, usando `SeleniumLibrary` — la librería de comunidad más usada para este propósito en Robot Framework. Cada lección incluye ejemplos de código reales, incluyendo una lección aprendida del desarrollo de este mismo curso sobre un error de sincronización entre tests.

**Lecciones de este capítulo:**

- 6.1 — Configuración de navegador, Selenium Manager, sesiones y opciones
- 6.2 — Localizadores CSS y XPath: selección robusta, acciones e interacción con formularios
- 6.3 — Sincronización: Wait Until, timeouts, elementos dinámicos y estabilidad
- 6.4 — Evidencias: screenshots automáticos, manejo de alertas, frames e iframes
- 6.5 — Patrón Page Object en RF: capa de keywords por página y mantenibilidad

---

## 6.1 Configuración de navegador, Selenium Manager, sesiones y opciones

### Objetivos de la lección

- Explicar el rol de `SeleniumLibrary` como puente hacia el navegador.
- Describir cómo Selenium Manager resuelve la gestión de drivers.
- Configurar sesiones de navegador, incluyendo el modo headless.

### ¿Por qué importa?

Antes de Selenium Manager, sincronizar la versión del navegador con la versión de su driver era una fuente constante de fricción y de errores difíciles de diagnosticar ("el navegador no abre" sin mensaje claro). Entender qué resuelve automáticamente la herramienta moderna evita perder tiempo en un problema que ya no debería ocurrir.

### Conceptos clave

#### SeleniumLibrary como puente

`SeleniumLibrary` conecta keywords `.robot` con la API de **Selenium WebDriver**, que a su vez controla un navegador real (o headless, sin interfaz visual) a través de un *driver* específico — ChromeDriver para Chrome, GeckoDriver para Firefox. La librería traduce cada keyword (`Click Element`, `Input Text`) en llamadas equivalentes de la API de Selenium.

#### Selenium Manager: fin de la gestión manual de drivers

Históricamente, sincronizar la versión del navegador instalado con la versión exacta del driver correspondiente era responsabilidad manual del equipo — y un navegador que se autoactualiza (como Chrome) podía romper esa sincronización sin aviso. Desde **Selenium 4.6**, **Selenium Manager** resuelve esto automáticamente: detecta la versión del navegador instalado en la máquina y descarga el driver compatible en segundo plano, sin configuración manual ni necesidad de instalar `chromedriver` por separado.

#### Abrir una sesión: Open Browser y sus opciones

```robot
Open Browser    https://miempresa.com/login    headlesschrome
```

`Open Browser` abre una sesión — identificada internamente por un alias si necesitas manejar varias sesiones simultáneas (por ejemplo, para probar un flujo entre dos usuarios distintos al mismo tiempo). El segundo argumento indica el navegador y modo: `chrome`, `firefox`, `headlesschrome` (sin interfaz visual). El **modo headless** es esencial para ejecutar en pipelines de CI/CD, donde no hay pantalla disponible — y suele ser más rápido que el modo con interfaz, porque no renderiza gráficamente nada.

#### Opciones adicionales del navegador

Para necesidades más específicas (tamaño de ventana, perfil de usuario, deshabilitar notificaciones), `Open Browser` acepta un parámetro `options` con la sintaxis de Selenium directamente:

```robot
Open Browser    ${URL}    chrome    options=add_argument("--window-size=1920,1080")
```

### Ejemplo comentado

```robot
*** Settings ***
Library    SeleniumLibrary


*** Test Cases ***
Abrir El Portal En Modo Headless Para CI/CD
    [Documentation]    headlesschrome es el modo recomendado para
    ...                ejecución automática sin interfaz gráfica.
    Open Browser    https://the-internet.herokuapp.com/login    headlesschrome
    Title Should Be    The Internet
    Close Browser
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué API usa SeleniumLibrary internamente? | Selenium WebDriver |
| ¿Desde qué versión de Selenium existe Selenium Manager? | 4.6 |
| ¿Qué modo de navegador es esencial para CI/CD? | Headless (`headlesschrome`) |
| ¿Hay que instalar `chromedriver` manualmente con Selenium 4.6+? | No, Selenium Manager lo gestiona automáticamente |

### Errores comunes

- **Instalar manualmente `chromedriver` "por si acaso"** con Selenium 4.6+ — innecesario, y puede generar conflicto de versiones si la instalación manual queda desactualizada respecto al navegador.
- **Olvidar el modo headless en un pipeline de CI/CD** sin pantalla disponible — el navegador falla al abrir, con un error que no siempre comunica claramente la causa real.
- **Abrir múltiples sesiones sin gestionar el alias correctamente** — sin un alias claro, es fácil terminar interactuando con la sesión equivocada cuando hay varias abiertas.

### Puntos clave

- `SeleniumLibrary` traduce keywords `.robot` a llamadas de Selenium WebDriver, que a su vez controla un navegador real a través de un driver.
- Selenium Manager (desde 4.6) descarga el driver correcto automáticamente, eliminando la sincronización manual de versiones.
- El modo headless (`headlesschrome`) es esencial para ejecutar en CI/CD sin interfaz gráfica, y suele ser más rápido.

### Autoevaluación

1. ¿Qué problema resolvía manualmente un equipo antes de Selenium Manager?
2. ¿Qué modo de `Open Browser` usarías en un pipeline de CI/CD sin pantalla?
3. Verdadero o falso: con Selenium 4.6+, sigue siendo necesario instalar `chromedriver` aparte.

**Respuestas:** 1. Sincronizar la versión del navegador con la versión exacta de su driver. 2. `headlesschrome` (o el equivalente headless del navegador elegido). 3. Falso — Selenium Manager lo gestiona automáticamente.

---

## 6.2 Localizadores CSS y XPath: selección robusta e interacción con formularios

### Objetivos de la lección

- Diferenciar localizadores CSS y XPath.
- Aplicar las keywords de interacción según el tipo de control HTML.
- Diseñar localizadores robustos ante cambios menores de la interfaz.

### ¿Por qué importa?

Un localizador frágil (por ejemplo, basado en la posición exacta de un elemento en el DOM) se rompe con cualquier cambio menor de diseño, generando falsos fallos que erosionan la confianza del equipo en la suite de automatización.

### Conceptos clave

#### CSS vs. XPath: cuándo usar cada uno

Un **localizador** es la dirección que usa Selenium para encontrar un elemento en el DOM. Los dos lenguajes más usados:

- **CSS**: más legible, generalmente más rápido de evaluar, cubre la mayoría de los casos prácticos (selección por id, clase, atributo, jerarquía).
- **XPath**: más expresivo — puede navegar **hacia arriba** en el árbol del DOM (un padre desde un hijo) y seleccionar elementos **por su texto visible** (`//button[text()='Enviar']`), algo que CSS no puede hacer de forma nativa.

`SeleniumLibrary` distingue el lenguaje con un prefijo explícito: `css:` o `xpath:`. Si omites el prefijo, Robot Framework intenta inferir el formato (generalmente asumiendo XPath si empieza con `//` o `(`), pero declarar el prefijo explícitamente es la práctica recomendada — elimina la ambigüedad.

| Necesidad | Lenguaje recomendado |
|---|---|
| Seleccionar por id, clase o atributo simple | CSS (`css:#id`, `css:.clase`) |
| Seleccionar por texto visible del elemento | XPath (`xpath://button[text()='Enviar']`) |
| Navegar hacia un elemento padre | XPath (`xpath://input[@id='x']/..`) |
| Selección jerárquica simple (hijo directo) | Ambos funcionan; CSS suele ser más legible |

#### Keywords de interacción por tipo de control

Cada tipo de control HTML tiene su keyword específica para interactuar con él:

| Control HTML | Keyword |
|---|---|
| Campo de texto | `Input Text` |
| Campo de contraseña | `Input Password` (oculta el valor en los logs) |
| Botón | `Click Button` |
| Cualquier elemento clicleable genérico | `Click Element` |
| Lista desplegable (`<select>`) | `Select From List By Label` / `By Value` / `By Index` |
| Checkbox | `Select Checkbox` / `Unselect Checkbox` |

`Input Password` existe como keyword separada de `Input Text` por una razón concreta: oculta el valor real en `log.html`, evitando que una contraseña de prueba quede expuesta en texto plano en un artefacto que puede compartirse o almacenarse.

#### Diseñar localizadores robustos

Un localizador robusto prefiere atributos estables (`id`, `data-testid` si la aplicación lo expone para pruebas) sobre estructura posicional (`div > div > span:nth-child(3)`), que se rompe con cualquier cambio de maquetación que no afecte la funcionalidad real de la página.

### Ejemplo comentado

```robot
*** Test Cases ***
Inicio De Sesión Con CSS Y XPath Combinados
    [Documentation]    Demuestra ambos lenguajes de localización en un
    ...                mismo flujo, eligiendo el más apropiado para cada caso.
    Open Browser    https://the-internet.herokuapp.com/login    headlesschrome

    # CSS: selección simple por id
    Input Text        id:username    tomsmith
    Input Password     id:password    SuperSecretPassword!

    # CSS: selección por atributo
    Click Button    css:button[type='submit']

    # XPath: selección por texto visible (CSS no puede hacer esto de forma nativa)
    Page Should Contain Element    xpath://h2[contains(text(), 'Secure Area')]

    Close Browser
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué keyword oculta el valor en los logs? | `Input Password` |
| ¿Qué lenguaje permite seleccionar por texto visible? | XPath |
| ¿Qué prefijo indica a SeleniumLibrary usar CSS? | `css:` |
| ¿Qué keyword interactúa con un `<select>` por su texto visible? | `Select From List By Label` |

### Errores comunes

- **Usar `Input Text` para un campo de contraseña** — funciona técnicamente, pero el valor queda expuesto en texto plano en `log.html`; usa `Input Password`.
- **Construir localizadores basados en posición exacta** (`div:nth-child(4) > span`) en vez de atributos estables — se rompe con cambios de maquetación irrelevantes para la funcionalidad.
- **Omitir el prefijo `css:`/`xpath:`** confiando en la inferencia automática — funciona la mayoría de las veces, pero declarar el prefijo explícitamente elimina cualquier ambigüedad y hace el código más legible.

### Puntos clave

- CSS es más legible y rápido para la mayoría de los casos; XPath es más expresivo (navega hacia arriba, busca por texto visible).
- El prefijo (`css:`, `xpath:`) le indica a SeleniumLibrary qué motor de localización usar; declararlo explícitamente es la práctica recomendada.
- Cada tipo de control HTML tiene su propia keyword de interacción — `Input Password` oculta el valor en los logs por una razón de seguridad concreta.

### Autoevaluación

1. ¿Qué lenguaje de localización usarías para seleccionar un botón por su texto visible "Enviar"?
2. ¿Por qué `Input Password` es preferible a `Input Text` para un campo de contraseña?
3. ¿Qué tipo de localizador (posicional vs. por atributo estable) es más resistente a cambios de diseño?

**Respuestas:** 1. XPath (`xpath://button[text()='Enviar']`) — CSS no soporta selección por texto de forma nativa. 2. Porque oculta el valor real en `log.html`, evitando exponer la contraseña en un artefacto compartible. 3. Por atributo estable (`id`, `data-testid`).

---

## 6.3 Sincronización: Wait Until, timeouts y estabilidad

### Objetivos de la lección

- Explicar por qué `Sleep` es una mala práctica en automatización web.
- Aplicar la familia de keywords `Wait Until` para sincronización robusta.
- Identificar la contaminación de sesión entre tests como causa de inestabilidad.

### ¿Por qué importa?

La inestabilidad por sincronización (*flaky tests*) es, probablemente, la causa más frecuente de desconfianza hacia una suite de automatización web: si una suite falla intermitentemente sin que el sistema realmente tenga un defecto, el equipo deja de confiar en sus resultados y empieza a ignorarlos — el peor desenlace posible para una suite de pruebas.

### Conceptos clave

#### El problema: contenido cargado de forma asíncrona

El problema más frecuente en automatización web es la **inestabilidad por sincronización**: el script intenta interactuar con un elemento antes de que la página termine de cargarlo, generalmente porque hay contenido cargado de forma asíncrona (AJAX, JavaScript) después de la carga inicial del HTML.

#### Por qué Sleep es la solución equivocada

La solución correcta **nunca** es `Sleep` con un tiempo fijo:

```robot
# Antipatrón — evitar
Click Button    Guardar
Sleep    3s
Element Should Be Visible    css:#confirmacion
```

Este enfoque tiene dos problemas simultáneos: **ralentiza la suite** cuando el elemento aparece en 200ms (esperaste 3 segundos innecesarios), y **sigue fallando** cuando el sistema tarda más de 3 segundos en un momento de carga alta — el peor de ambos mundos.

#### La familia Wait Until: espera activa con timeout

```robot
Click Button    Guardar
Wait Until Element Is Visible    css:#confirmacion    timeout=10s
```

La familia `Wait Until *` (`Wait Until Element Is Visible`, `Wait Until Location Contains`, `Wait Until Element Is Not Visible`, `Wait Until Keyword Succeeds`) espera **activamente** hasta que se cumple una condición — verificando repetidamente en intervalos cortos — con un **timeout máximo configurable**, fallando explícitamente solo si se agota ese tiempo. Esto hace que la suite sea tan rápida como pueda serlo el sistema real, sin sacrificar estabilidad: si el elemento aparece en 200ms, la espera termina en 200ms; si tarda 8 segundos, la espera termina en 8 segundos (siempre que el timeout configurado sea mayor).

#### Una causa de inestabilidad menos obvia: contaminación de sesión

Hay una causa de inestabilidad que no tiene que ver con tiempos de carga, sino con **compartir una sesión de navegador entre tests independientes**. Si un test deja una sesión autenticada o un estado residual (cookies, alertas abiertas) y el siguiente test reutiliza el mismo navegador, puede comportarse de forma impredecible — no porque el sistema bajo prueba tenga un defecto, sino porque el segundo test arrancó desde un estado que no controló.

> **Lección real de este curso:** durante el desarrollo de las prácticas de este capítulo, se encontró exactamente este problema: una suite que usaba `Suite Setup` para abrir un único navegador compartido entre tres test cases mostraba campos de formulario vacíos de forma intermitente en el segundo y tercer test, después de que el primero completara un login exitoso. La causa no era un problema de espera (los `Wait Until` estaban correctamente configurados) — era que el segundo test heredaba un navegador con una sesión autenticada de un login anterior, y la combinación de navegación y formularios no se comportaba de forma predecible. La solución fue cambiar de `Suite Setup`/`Suite Teardown` (un navegador compartido) a `Test Setup`/`Test Teardown` (un navegador nuevo por test), garantizando que cada test arrancara desde un estado limpio. Este es un ejemplo real, no hipotético, de por qué la independencia de tests importa incluso cuando "ahorra tiempo" compartir recursos.

### Ejemplo comentado

```robot
*** Settings ***
Library           SeleniumLibrary
Test Setup        Open Browser    ${URL_LOGIN}    headlesschrome
Test Teardown     Close All Browsers


*** Test Cases ***
Iniciar Sesión Con Espera Explícita
    Go To    ${URL_LOGIN}
    Input Text          id:username      tomsmith
    Input Password       id:password      SuperSecretPassword!
    Click Button    css:button[type='submit']
    # Espera activa, no un tiempo fijo arbitrario
    Wait Until Location Contains    /secure    timeout=10s
    Wait Until Element Is Visible    css:#flash    timeout=10s
```

`Test Setup`/`Test Teardown` (en vez de `Suite Setup`/`Suite Teardown`) garantiza que cada test arranca con un navegador completamente nuevo, sin estado heredado del test anterior.

### Tabla de referencia rápida

| Estrategia de espera | ¿Recomendada? | Razón |
|---|---|---|
| `Sleep` con tiempo fijo | No | Ni rápida cuando no se necesita, ni confiable cuando se necesita más |
| `Wait Until Element Is Visible` | Sí | Espera activa con timeout configurable |
| `Wait Until Location Contains` | Sí | Espera a que la URL cambie (navegación completada) |
| Navegador compartido entre tests (`Suite Setup`) | Con cautela | Riesgo de contaminación de sesión entre tests |

### Errores comunes

- **Usar `Sleep` "para estar seguro"** — incluso como solución temporal, tiende a quedarse permanentemente en el código y a acumularse en suites grandes, ralentizándolas innecesariamente.
- **Compartir un navegador entre tests que no son verdaderamente independientes entre sí** — la causa raíz real documentada en este mismo curso.
- **Configurar un timeout demasiado corto** "para que la suite sea más rápida" — produce fallos intermitentes exactamente en los momentos de carga más lenta del sistema, que es precisamente cuando más necesitas que la prueba sea confiable.

### Puntos clave

- `Sleep` con tiempo fijo es antipatrón: ni rápido cuando no se necesita, ni confiable cuando se necesita más tiempo.
- `Wait Until *` espera activamente con un timeout, balanceando velocidad y estabilidad.
- Compartir navegador entre tests independientes es una causa real de tests inestables — usa `Test Setup`/`Teardown` por test salvo que el estado compartido sea una decisión deliberada y documentada.

### Autoevaluación

1. ¿Por qué `Sleep` con tiempo fijo es problemático incluso si "funciona la mayoría de las veces"?
2. ¿Qué cambio de Setup/Teardown resolvió el problema real de contaminación de sesión descrito en esta lección?
3. ¿Qué keyword usarías para esperar a que la URL cambie tras un envío de formulario?

**Respuestas:** 1. Porque es lento cuando no se necesita y poco confiable cuando se necesita más tiempo del estimado — no se adapta al comportamiento real del sistema. 2. Cambiar de `Suite Setup`/`Suite Teardown` (navegador compartido) a `Test Setup`/`Test Teardown` (navegador nuevo por test). 3. `Wait Until Location Contains`.

---

## 6.4 Evidencias: screenshots, alertas, frames e iframes

### Objetivos de la lección

- Aplicar captura de pantalla manual y automática.
- Manejar alertas nativas de JavaScript con `Handle Alert`.
- Explicar por qué un frame requiere cambio explícito de contexto.

### ¿Por qué importa?

La capacidad de **demostrar** qué ocurrió durante una ejecución es tan importante como la ejecución misma — especialmente al diagnosticar un fallo que ocurrió en un pipeline de CI/CD, donde nadie estaba mirando la pantalla en tiempo real.

### Conceptos clave

#### Capturas de pantalla: manual vs. automática en fallo

`Capture Page Screenshot` toma una captura manual en cualquier punto del test. Combinada con `Run Keyword If Test Failed`, captura **solo cuando el test falla**:

```robot
[Teardown]    Run Keywords
...           Run Keyword If Test Failed    Capture Page Screenshot
...           AND    Close All Browsers
```

Este patrón evita generar cientos de capturas innecesarias en una suite grande donde la mayoría de los tests pasa. También es válido — y a veces preferible — capturar en **cada** test, no solo en fallo, cuando se necesita evidencia completa para una auditoría o un reporte de regresión exhaustivo; la decisión depende del propósito de la suite, no de una regla universal.

#### Alertas de JavaScript: por qué necesitan una keyword especial

Las **alertas de JavaScript** (`alert()`, `confirm()`, `prompt()`) **no son parte del árbol DOM** — son ventanas nativas del navegador, renderizadas por el sistema operativo o el motor del navegador, fuera del documento HTML. Por eso `SeleniumLibrary` necesita una keyword especial, `Handle Alert`, para interactuar con ellas:

```robot
Click Element    css:button[onclick='jsAlert()']
Handle Alert    action=ACCEPT
```

Intentar interactuar con una alerta usando `Click Element` (como si fuera un elemento normal del DOM) produce un error, porque Selenium no puede "ver" la alerta como parte de la página — `Handle Alert` opera a un nivel distinto, el del navegador mismo, no el del documento.

| Tipo de diálogo | Acciones disponibles |
|---|---|
| `alert()` | Solo `ACCEPT` (un botón OK) |
| `confirm()` | `ACCEPT` (OK) o `DISMISS` (Cancelar) |
| `prompt()` | `ACCEPT` con texto de entrada, o `DISMISS` |

#### Frames e iframes: cambio explícito de contexto

Los **frames e iframes** representan documentos HTML **independientes**, embebidos dentro de la página principal — técnicamente, cada uno tiene su propio árbol DOM. Selenium **no puede interactuar** con elementos dentro de un frame sin que el script cambie explícitamente de contexto hacia ese frame primero, usando `Select Frame`; de lo contrario, el elemento "no existe" desde la perspectiva del documento principal (un error `NoSuchElementException`), aunque sea perfectamente visible en pantalla para un humano. Para volver al documento principal después de trabajar dentro de un frame, se usa `Unselect Frame`.

### Ejemplo comentado

```robot
*** Test Cases ***
Aceptar Una Alerta Simple De JavaScript
    Open Browser    https://the-internet.herokuapp.com/javascript_alerts    headlesschrome
    Click Element    css:button[onclick='jsAlert()']
    Handle Alert    action=ACCEPT
    Element Should Contain    id:result    You successfully clicked an alert
    Close Browser

Interactuar Con Un Elemento Dentro De Un Iframe
    Open Browser    https://the-internet.herokuapp.com/iframe    headlesschrome
    # Sin Select Frame, el siguiente paso fallaría con NoSuchElementException
    Select Frame    css:#mce_0_ifr
    Input Text    css:#tinymce    Texto escrito dentro del iframe
    Unselect Frame
    Close Browser
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué keyword maneja una alerta de JavaScript? | `Handle Alert` |
| ¿Por qué no se puede usar `Click Element` en una alerta? | No es parte del DOM; es una ventana nativa del navegador |
| ¿Qué keyword cambia el contexto hacia un iframe? | `Select Frame` |
| ¿Qué error ocurre si interactúas con un elemento de un iframe sin cambiar de contexto? | `NoSuchElementException` (u equivalente) |

### Errores comunes

- **Intentar usar `Click Element` sobre una alerta de JavaScript** — falla porque la alerta no es parte del DOM.
- **Olvidar `Unselect Frame` después de trabajar dentro de un iframe** — los pasos siguientes del test pueden fallar inesperadamente al buscar elementos que están en el documento principal, no en el frame.
- **Capturar pantalla solo en fallo en una suite que necesita evidencia de auditoría completa** — revisar primero el propósito real de la suite antes de aplicar la regla por defecto.

### Puntos clave

- Capturar pantalla en fallo (no en cada test) es la estrategia más común para evitar ruido; capturar siempre es válido para auditorías completas.
- Las alertas de JavaScript requieren `Handle Alert`, porque no son parte del DOM — son ventanas nativas del navegador.
- Un frame/iframe requiere cambio explícito de contexto (`Select Frame`/`Unselect Frame`) antes y después de interactuar con su contenido.

### Autoevaluación

1. ¿Por qué una alerta de JavaScript no se puede manejar con `Click Element`?
2. ¿Qué keyword usarías para interactuar con un campo de texto que está dentro de un iframe?
3. ¿Cuándo conviene capturar pantalla en cada test, no solo en fallo?

**Respuestas:** 1. Porque no es parte del árbol DOM — es una ventana nativa del navegador, fuera del alcance normal de Selenium sin `Handle Alert`. 2. Primero `Select Frame` hacia ese iframe, luego la keyword de interacción normal (`Input Text`). 3. Cuando se necesita evidencia completa para una auditoría o reporte de regresión exhaustivo, no solo diagnóstico de fallos.

---

## 6.5 Patrón Page Object en RF: capa de keywords por página y mantenibilidad

### Objetivos de la lección

- Describir el patrón Page Object aplicado a Robot Framework.
- Explicar su beneficio principal de mantenibilidad.
- Aplicar el patrón estructurando localizadores y keywords en un Resource por página.

### ¿Por qué importa?

Sin este patrón, un cambio de interfaz (un selector que cambia, un campo que se mueve) obliga a buscar y corregir el mismo selector repetido en docenas de test cases — un costo de mantenimiento que crece linealmente con el tamaño de la suite.

### Conceptos clave

#### Qué es el patrón Page Object

El patrón **Page Object** propone que cada pantalla de la aplicación tenga su propia representación en código: un archivo Resource dedicado, con los localizadores como variables y las keywords de interacción de esa pantalla. Es, en esencia, una aplicación del mismo principio de separación por capas visto en BDD (Capítulo 4) y en el diseño de keywords reutilizables (Capítulo 5): el test case habla en lenguaje de negocio, el Page Object traduce ese lenguaje a interacciones concretas con el DOM.

#### Las dos capas dentro de un Page Object

Dentro de un mismo archivo Resource de Page Object, conviene distinguir dos niveles:

- **Variables de localizadores**: declaradas en `*** Variables ***`, agrupan todos los selectores de esa página en un solo lugar visible.
- **Keywords de interacción**: en `*** Keywords ***`, usan esas variables y exponen acciones con nombres de negocio (`Ingresar Credenciales`, no `Escribir En Dos Campos Y Hacer Clic`).

```robot
# resources/LoginPage.resource
*** Variables ***
${CAMPO_USUARIO}          id:username
${CAMPO_PASSWORD}         id:password
${BOTON_INGRESAR}         css:button[type='submit']

*** Keywords ***
Ingresar Credenciales
    [Arguments]    ${usuario}    ${password}
    Input Text          ${CAMPO_USUARIO}      ${usuario}
    Input Password       ${CAMPO_PASSWORD}    ${password}

Hacer Clic En Ingresar
    Click Button    ${BOTON_INGRESAR}
```

#### El beneficio principal: mantenibilidad

El beneficio principal es la **mantenibilidad**: cuando la interfaz cambia (un selector, una estructura de página), el ajuste se hace en **un solo lugar** — el Page Object correspondiente — sin tocar ningún test case que lo use. Sin este patrón, un cambio de UI obligaría a buscar y corregir el mismo selector repetido en docenas de test cases, con el riesgo real de dejar alguno sin actualizar.

#### Cómo se ve un test case que usa un Page Object

```robot
*** Settings ***
Resource    ../resources/LoginPage.resource

*** Test Cases ***
Iniciar Sesión Exitosamente Usando El Page Object
    Abrir Pagina De Login
    Ingresar Credenciales    tomsmith    SuperSecretPassword!
    Hacer Clic En Ingresar
    Verificar Mensaje Flash Contiene    You logged into a secure area
```

Observa que **ningún selector CSS aparece en el test case** — todo vive dentro del Page Object. Esta es, en la práctica, la señal de que el patrón se aplicó correctamente: si encuentras un `css:` o `xpath:` dentro de un archivo de test cases, es una fuga de abstracción que debería moverse al Page Object correspondiente.

### Ejemplo comentado

```robot
# resources/AlertsPage.resource — Page Object de una segunda pantalla
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL_ALERTAS}            https://the-internet.herokuapp.com/javascript_alerts
${BOTON_JS_ALERT}         css:button[onclick='jsAlert()']
${RESULTADO_ALERTA}       id:result

*** Keywords ***
Abrir Pagina De Alertas
    Go To    ${URL_ALERTAS}
    Wait Until Element Is Visible    ${BOTON_JS_ALERT}    timeout=10s

Disparar Alerta Simple Y Aceptar
    Click Element    ${BOTON_JS_ALERT}
    Handle Alert    action=ACCEPT

Verificar Resultado Contiene
    [Arguments]    ${texto_esperado}
    Element Should Contain    ${RESULTADO_ALERTA}    ${texto_esperado}
```

Cada pantalla de la aplicación (login, alertas, y cualquier otra) tiene su propio Resource — un proyecto con 10 pantallas tendría 10 Page Objects, cada uno autocontenido.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Dónde viven los selectores en el patrón Page Object? | En el Resource de esa página, como variables |
| ¿Qué beneficio principal aporta el patrón? | Mantenibilidad — el cambio de UI se corrige en un solo lugar |
| ¿Es correcto encontrar un `css:` directamente en un archivo de test cases? | No, es una fuga de abstracción del patrón |
| ¿Cuántos Page Objects necesita un proyecto con 10 pantallas? | 10, uno por pantalla |

### Errores comunes

- **Dejar un selector CSS/XPath directamente en el test case**, "por simplicidad" en un caso puntual — rompe la mantenibilidad que el patrón busca garantizar de forma consistente.
- **Crear un único Page Object gigante para toda la aplicación** en vez de uno por pantalla — pierde la cohesión y la facilidad de localizar qué archivo modificar ante un cambio de UI específico.
- **Nombrar las keywords del Page Object con el mecanismo técnico** (`Click En Boton Con Id Submit`) en vez de la intención de negocio (`Hacer Clic En Ingresar`) — mezcla la capa de negocio que el test case espera con detalles técnicos.

### Puntos clave

- Page Object = localizadores + keywords de una pantalla, encapsulados en un Resource dedicado a esa pantalla.
- El test case solo conoce keywords de negocio del Page Object — nunca selectores directamente.
- Un cambio de interfaz se corrige en un solo lugar (el Page Object de esa pantalla), no en cada test case que la usa.

### Autoevaluación

1. Si encuentras un selector CSS directamente dentro de un archivo de test cases, ¿qué patrón se está violando?
2. ¿Cuántos archivos Page Object necesitarías para un proyecto con login, dashboard y configuración (3 pantallas)?
3. ¿Cuál es el beneficio principal del patrón Page Object?

**Respuestas:** 1. El patrón Page Object — el selector debería vivir en el Resource de esa pantalla, no en el test case. 2. Tres, uno por pantalla. 3. Mantenibilidad: un cambio de interfaz se corrige en un solo lugar.

---

## Resumen del capítulo

`SeleniumLibrary` conecta Robot Framework con el navegador vía Selenium WebDriver; Selenium Manager (4.6+) elimina la gestión manual de drivers. CSS y XPath son los dos lenguajes de localización, cada uno con sus keywords de interacción correspondientes según el tipo de control HTML. La sincronización correcta usa `Wait Until *`, nunca `Sleep` fijo, y cada test debería manejar su propia sesión de navegador (`Test Setup`/`Teardown`) para evitar contaminación de estado — una lección real, no hipotética, encontrada durante el desarrollo de este curso. Las capturas de pantalla y el manejo de alertas/frames dan evidencia y cobertura completa, cada uno con su propia keyword especializada (`Handle Alert`, `Select Frame`) porque no son parte del flujo normal del DOM. El patrón Page Object aplica separación por capas a pantallas web, concentrando el impacto de cambios de UI en un solo lugar por pantalla.

## Referencias bibliográficas

- SeleniumLibrary: <https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html>
- Selenium Manager: <https://www.selenium.dev/documentation/selenium_manager/>
- Patrón Page Object: <https://www.selenium.dev/documentation/test_practices/encouraged/page_object_models/>

```{=typst}
#pagebreak()
```
