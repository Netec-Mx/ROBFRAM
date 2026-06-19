# Capítulo 4 — Behavior-Driven Development (BDD) y Pruebas Orientadas a Negocio

## Información general

Este capítulo introduce BDD: un enfoque que acerca el lenguaje de las pruebas al lenguaje del negocio, particularmente valioso en telecomunicaciones, donde los flujos (activación de servicios, portabilidad, facturación) involucran reglas regulatorias y comerciales que un analista de negocio necesita poder leer y validar sin depender de un ingeniero.

**Lecciones de este capítulo:**

- 4.1 — Introducción a BDD: impacto en la alineación TI-Negocio y telecomunicaciones
- 4.2 — Sintaxis Gherkin nativa en RF: Given, When, Then, And, But
- 4.3 — Abstracción de capas: escenarios de negocio en lenguaje natural → keywords técnicas
- 4.4 — Organización de features y escenarios para flujos comerciales agnósticos

---

## 4.1 Introducción a BDD: impacto en la alineación TI-Negocio y telecomunicaciones

### Objetivos de la lección

- Explicar qué es BDD y de dónde surge.
- Describir el valor de BDD para reducir la brecha entre TI y negocio.
- Identificar casos de uso de BDD específicos de telecomunicaciones.

### ¿Por qué importa?

La mayoría de los defectos de software no nacen de un error de programación, sino de un malentendido sobre qué debía construirse. BDD ataca directamente esa causa raíz, no el síntoma.

### Conceptos clave

#### Qué es BDD y de dónde viene

BDD (*Behavior-Driven Development*) es una evolución de TDD (*Test-Driven Development*) enfocada en describir el **comportamiento** del sistema desde la perspectiva del negocio, no de la implementación técnica. Mientras TDD pregunta "¿este código hace lo que el código debería hacer?", BDD pregunta "¿el sistema se comporta como el negocio espera que se comporte?" — un cambio de perspectiva que mueve la conversación de la implementación al resultado observable.

#### Las Tres Amigos: el origen del proceso

El origen práctico de BDD está en la dinámica de las **Tres Amigos**: una reunión entre alguien que representa al negocio, alguien que desarrolla y alguien que prueba, para acordar — **antes** de escribir una sola línea de código — qué comportamiento exacto se espera, usando ejemplos concretos en lugar de descripciones abstractas. Esta conversación temprana es, en la práctica, más valiosa que la sintaxis Gherkin en sí misma: el formato Given/When/Then es solo el vehículo para capturar lo que ya se acordó.

#### Por qué reduce la brecha TI-Negocio

La brecha conceptual entre TI y negocio es una causa frecuente de defectos: un requisito ambiguo ("el sistema debe validar el crédito del cliente") se interpreta de una forma por el desarrollador (verificar que el campo no esté vacío) y de otra por quien lo solicitó (verificar que el cliente tenga saldo disponible para el monto exacto del plan). BDD reduce esa brecha escribiendo los escenarios en un lenguaje estructurado pero natural — Gherkin —, que cualquiera de las Tres Amigos puede leer y validar sin ambigüedad, porque el escenario usa datos concretos, no descripciones generales.

#### Casos de uso concretos en telecomunicaciones

En telecomunicaciones, este valor es especialmente concreto porque varios procesos tienen reglas regulatorias estrictas:

- **Portabilidad numérica**: tiene tiempos máximos de respuesta definidos por regulación; un escenario BDD ("Dado un cliente solicita portabilidad, cuando se procesa dentro del tiempo regulatorio, entonces se confirma el cambio de operador") sirve simultáneamente como especificación, documentación viva, y prueba automatizada — sin que el área de cumplimiento regulatorio necesite leer código.
- **Activación de planes**: las reglas de crédito, promociones y restricciones por tipo de cliente cambian con frecuencia comercial; BDD permite que el equipo comercial valide directamente los escenarios sin depender de un intermediario técnico.
- **Facturación**: los cálculos de prorrateo, impuestos y descuentos suelen tener casos límite (cambios de plan a mitad de ciclo, por ejemplo) que se comunican mejor como ejemplos concretos que como reglas abstractas.

### Ejemplo comentado

```gherkin
# Esto NO es código ejecutable — es el "boceto" del escenario que el
# negocio y TI acuerdan ANTES de escribir nada en Robot Framework.
Escenario: Activación de plan de datos para cliente con crédito suficiente
  Dado un cliente con crédito suficiente existe en el sistema
  Cuando el cliente solicita la activación de un plan de datos adicional
  Entonces el plan queda activo y el cliente recibe una confirmación
```

Este boceto, una vez acordado entre negocio y TI, se traduce casi literalmente a Robot Framework en la lección 4.2 — esa traducción casi directa es justamente el punto: el escenario de negocio y el código de prueba quedan alineados palabra por palabra.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿De qué enfoque evoluciona BDD? | TDD |
| ¿Qué pregunta central hace BDD, a diferencia de TDD? | ¿El sistema se comporta como el negocio espera? |
| ¿Qué reunión origina la dinámica de BDD? | Las Tres Amigos (negocio, desarrollo, pruebas) |

### Errores comunes

- **Saltarse la conversación de las Tres Amigos y escribir Gherkin directamente desde TI** — se pierde el propósito central de BDD; el formato sin el acuerdo previo es solo sintaxis, no alineación real.
- **Escribir escenarios con descripciones abstractas en vez de ejemplos concretos** ("el sistema valida correctamente" en vez de "un cliente con crédito de Q100 y un plan de Q50 puede activarlo") — pierde la claridad que hace que BDD funcione.
- **Asumir que BDD es solo "una forma bonita de escribir tests"** — su valor real está en la conversación previa y en la documentación viva compartida, no en la sintaxis por sí sola.

### Puntos clave

- BDD describe comportamiento en lenguaje de negocio, usando ejemplos concretos, no implementación abstracta.
- Las "Tres Amigos" acuerdan el comportamiento esperado antes de codificar — la conversación es más valiosa que la sintaxis.
- En telecom, BDD sirve como especificación + documentación + prueba en un solo artefacto, especialmente valioso en procesos regulados (portabilidad, facturación).

### Autoevaluación

1. ¿Qué pregunta hace BDD que TDD no enfatiza de la misma forma?
2. ¿Por qué un escenario BDD con datos concretos (Q100 de crédito, plan de Q50) es mejor que uno abstracto ("el sistema valida correctamente")?
3. Menciona un proceso de telecomunicaciones donde BDD aporta valor regulatorio específico.

**Respuestas:** 1. ¿El sistema se comporta como el negocio espera? (en vez de ¿el código hace lo que el código debe hacer?). 2. Porque elimina la ambigüedad — cualquiera de las Tres Amigos puede verificar el ejemplo concreto sin interpretación. 3. Portabilidad numérica (tiempos de respuesta regulados).

---

## 4.2 Sintaxis Gherkin nativa en RF: Given, When, Then, And, But

### Objetivos de la lección

- Explicar cómo Robot Framework procesa los prefijos Gherkin.
- Aplicar Given/When/Then/And/But en un test case.
- Compartir estado entre pasos Given/When/Then con `Set Test Variable`.

### ¿Por qué importa?

Entender que Gherkin en Robot Framework no es "magia" especial, sino un mecanismo de texto simple, te permite usarlo con confianza y depurarlo cuando algo no funciona — sin tener que aprender una sintaxis paralela.

### Conceptos clave

#### El mecanismo exacto: eliminación de prefijo

Robot Framework **no tiene una sintaxis BDD separada** — los prefijos `Given`, `When`, `Then`, `And` y `But` son simplemente texto que Robot Framework **elimina** antes de resolver el nombre de la keyword. Esto significa que:

```robot
Given un cliente con crédito suficiente existe en el sistema
```

busca **exactamente la misma keyword** que:

```robot
un cliente con crédito suficiente existe en el sistema
```

El prefijo existe únicamente para que un humano entienda el rol de cada paso — no para que el motor de ejecución tome una decisión distinta.

#### El rol semántico de cada prefijo

- `Given` — establece el **contexto** inicial (qué condiciones existen antes de la acción).
- `When` — ejecuta la **acción** que se quiere probar (el evento central del escenario).
- `Then` — verifica el **resultado** esperado (la consecuencia observable de la acción).
- `And` / `But` — continúan el paso anterior (otro Given, otro When, u otro Then), usados cuando un mismo rol necesita varios pasos consecutivos.

Para Robot Framework, los cinco prefijos son **mecánicamente equivalentes**: el motor no distingue significados entre ellos, simplemente los descarta antes de buscar la keyword. La diferencia entre ellos es una convención de Gherkin para el lector humano, no una regla que el motor interprete o valide.

#### Compartir estado entre pasos: Set Test Variable

Un desafío práctico al escribir escenarios Given/When/Then en varias keywords distintas: el contexto que `Given` establece necesita estar disponible cuando `When` y `Then` se ejecutan. `Set Test Variable` resuelve esto creando una variable visible para **todo el test case actual**, sin importar en qué keyword se definió:

```robot
*** Keywords ***
un cliente con crédito suficiente existe en el sistema
    Set Test Variable    ${CREDITO_DISPONIBLE}    ${100}

el cliente solicita la activación de un plan de datos adicional
    ${costo_plan}=    Set Variable    ${50}
    IF    ${CREDITO_DISPONIBLE} >= ${costo_plan}
        Set Test Variable    ${RESULTADO_ACTIVACION}    ACTIVO
    ELSE
        Set Test Variable    ${RESULTADO_ACTIVACION}    RECHAZADO
    END

el plan queda activo y el cliente recibe una confirmación
    Should Be Equal    ${RESULTADO_ACTIVACION}    ACTIVO
```

Sin `Set Test Variable` (usando, por ejemplo, `Set Variable` normal), la variable `${CREDITO_DISPONIBLE}` solo existiría dentro de la keyword donde se creó — `When` no podría leerla, porque cada keyword tiene su propio alcance local por defecto.

### Ejemplo comentado

```robot
*** Settings ***
Resource          ../resources/activacion_keywords.resource


*** Test Cases ***
Activación De Plan De Datos Para Cliente Con Crédito Suficiente
    Given un cliente con crédito suficiente existe en el sistema
    When el cliente solicita la activación de un plan de datos adicional
    Then el plan queda activo y el cliente recibe una confirmación

Activación Rechazada Por Crédito Insuficiente
    Given un cliente con crédito insuficiente existe en el sistema
    When el cliente solicita la activación de un plan de datos adicional
    Then la activación es rechazada y se informa el motivo
```

Cualquier persona del negocio, sin conocer Robot Framework, puede leer estos dos test cases y entender exactamente qué se está probando — ese es el resultado tangible de aplicar BDD correctamente.

### Tabla de referencia rápida

| Prefijo | Rol semántico | ¿Lo interpreta el motor de RF? |
|---|---|---|
| `Given` | Contexto | No — se descarta antes de buscar la keyword |
| `When` | Acción | No |
| `Then` | Resultado esperado | No |
| `And`/`But` | Continuación del paso anterior | No |

### Errores comunes

- **Esperar que Robot Framework valide el orden Given→When→Then** — no lo hace; podrías escribir `Then` antes de `Given` y el motor lo ejecutaría igual (aunque sería confuso de leer y rompería la convención).
- **Usar `Set Variable` en vez de `Set Test Variable`** cuando el valor necesita estar disponible en otro paso del mismo test — la variable quedaría fuera de alcance.
- **Escribir el nombre de la keyword distinto entre el Resource y el test case** (incluso un espacio extra) — Robot Framework no encuentra la keyword porque el texto, sin el prefijo, debe coincidir exactamente.

### Puntos clave

- Los prefijos Gherkin son solo legibilidad — Robot Framework los descarta mecánicamente al resolver la keyword, sin validar su orden ni su semántica.
- `Given`/`When`/`Then` corresponden a contexto/acción/resultado; `And`/`But` continúan el paso anterior.
- `Set Test Variable` comparte una variable entre todas las keywords de un mismo test case — necesario para mantener estado entre Given/When/Then.

### Autoevaluación

1. ¿Qué hace Robot Framework con el texto `Given` antes de buscar la keyword?
2. Si escribes los pasos en el orden Then/Given/When, ¿el motor lo rechaza?
3. ¿Qué keyword usarías para que una variable definida en el paso `Given` esté disponible en el paso `Then`?

**Respuestas:** 1. Lo elimina/descarta — no afecta la búsqueda de la keyword. 2. No, el motor no valida el orden; solo sería una mala práctica de legibilidad. 3. `Set Test Variable`.

---

## 4.3 Abstracción de capas: escenarios de negocio en lenguaje natural → keywords técnicas

### Objetivos de la lección

- Explicar por qué Given/When/Then no es suficiente sin separación de capas.
- Describir el patrón de tres capas: test case, dominio, técnica.
- Aplicar el criterio práctico para asignar una keyword a su capa correcta.

### ¿Por qué importa?

Escribir Given/When/Then no garantiza, por sí solo, que el escenario sea legible para el negocio. Si la keyword detrás de `When` contiene cálculos numéricos crudos o detalles de implementación, el escenario sigue siendo técnico — solo que con un prefijo Gherkin encima, lo cual puede ser peor que no usar BDD: da una falsa sensación de legibilidad de negocio.

### Conceptos clave

#### Las tres capas

```{=typst}
#flujo-vertical(("Test case (Given/When/Then, lenguaje de negocio)", "Capa de dominio (traduce negocio a operaciones)", "Capa técnica (el cómo: cálculos, llamadas HTTP, DOM, etc.)"))
```

1. **Test case**: solo lenguaje de negocio, en Given/When/Then. No debería contener ningún número, ningún selector, ninguna URL.
2. **Capa de dominio**: keywords con nombres de negocio (`Activar Plan Para Cliente`, `Un Cliente Con Crédito Suficiente Solicita Activar Un Plan`) que traducen ese lenguaje a operaciones concretas, llamando a la capa técnica. Es la única capa que el test case conoce directamente.
3. **Capa técnica**: el detalle de implementación (cálculos, llamadas a una API, interacción con el DOM). El test case **nunca** debería llamar directamente a esta capa, saltándose la capa de dominio.

#### El criterio práctico de asignación

El criterio para decidir a qué capa pertenece una keyword es preguntarse: **¿un analista de negocio entendería esta keyword sin conocer la tecnología subyacente?** Si la respuesta es sí, es capa de dominio. Si necesita conocer detalles técnicos (un selector CSS, el nombre exacto de un endpoint, una fórmula de cálculo), es capa técnica.

| Keyword | ¿Capa? | Por qué |
|---|---|---|
| `El plan queda activo` | Dominio | Lenguaje de negocio puro |
| `Calcular Resultado De Activacion` | Técnica | Contiene la lógica de comparación numérica |
| `Click Element css:#boton-activar` | Técnica | Selector CSS, detalle de implementación |
| `Un cliente con crédito suficiente solicita activar un plan` | Dominio | Describe la intención de negocio, delega el cálculo a la capa técnica |

#### El beneficio de aislar el impacto del cambio tecnológico

Esta separación también aísla el impacto de los cambios tecnológicos: migrar de REST a GraphQL para consumir el sistema de activaciones, por ejemplo, **solo modifica la capa técnica** — los escenarios Gherkin y la capa de dominio permanecen completamente intactos, porque nunca mencionaron la tecnología en primer lugar.

### Ejemplo comentado

```robot
# Capa TÉCNICA: el detalle de cómo se calcula el resultado.
*** Keywords ***
Calcular Resultado De Activacion
    [Arguments]    ${credito}    ${costo}
    IF    ${credito} >= ${costo}
        RETURN    ACTIVO
    ELSE
        RETURN    RECHAZADO
    END
```

```robot
# Capa de DOMINIO: traduce el lenguaje de negocio a la capa técnica.
# Es la ÚNICA capa que el test case conoce.
*** Keywords ***
un cliente con crédito suficiente solicita activar un plan
    ${resultado}=    Calcular Resultado De Activacion    ${100}    ${50}
    Set Test Variable    ${RESULTADO}    ${resultado}

el plan queda activo
    Should Be Equal    ${RESULTADO}    ACTIVO
```

```robot
# Test case: SOLO lenguaje de negocio.
*** Test Cases ***
Activación De Plan Con Crédito Suficiente
    Given un cliente con crédito suficiente solicita activar un plan
    Then el plan queda activo
```

Observa que el test case no contiene ningún número, ningún detalle de cómo se calcula el resultado — todo eso vive en las capas que el test case no conoce directamente.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Cuántas capas tiene el patrón de abstracción de BDD? | Tres: test case, dominio, técnica |
| ¿Qué capa conoce directamente el test case? | Solo la capa de dominio |
| ¿Qué capa cambia si migras de REST a GraphQL? | Solo la capa técnica |
| Criterio para asignar una keyword a la capa de dominio | ¿Un analista de negocio la entendería sin contexto técnico? |

### Errores comunes

- **Llamar directamente a una keyword técnica desde el test case**, saltándose la capa de dominio — rompe el aislamiento que el patrón busca dar.
- **Poner un cálculo o un selector dentro de una keyword de dominio** — mezcla responsabilidades; ese detalle debería vivir en la capa técnica.
- **Crear una capa de dominio "de paso" que solo reenvía la llamada sin traducir nada** — si la keyword de dominio tiene exactamente los mismos parámetros y nombre técnico que la de la capa técnica, no está cumpliendo su propósito de traducción.

### Puntos clave

- Tres capas: test case (negocio) → dominio (traducción) → técnica (implementación) — el test case solo conoce la capa de dominio.
- Criterio de separación: ¿un analista de negocio entendería esta keyword sin contexto técnico?
- Un cambio tecnológico (REST → GraphQL, por ejemplo) solo debería afectar la capa técnica.

### Autoevaluación

1. ¿Qué capa del patrón de abstracción debería conocer directamente un test case?
2. Si migras la capa técnica de Selenium a Playwright, ¿qué otras capas deberían cambiar?
3. Aplica el criterio práctico: ¿la keyword `Verificar Que El Código De Respuesta HTTP Es 200` es de dominio o técnica?

**Respuestas:** 1. Solo la capa de dominio. 2. Ninguna otra — el cambio debería quedar aislado en la capa técnica. 3. Técnica — menciona un detalle de implementación (código HTTP) que un analista de negocio no necesitaría conocer.

---

## 4.4 Organización de features y escenarios para flujos comerciales agnósticos

### Objetivos de la lección

- Explicar qué significa que un escenario sea "agnóstico" a la tecnología.
- Describir una estructura de carpetas para proyectos BDD.
- Aplicar tags multidimensionales en un esquema de clasificación.

### ¿Por qué importa?

Sin una convención de organización, un proyecto BDD que crece termina con escenarios de negocio mezclados físicamente con detalles técnicos en el mismo árbol de carpetas — perdiendo, en la práctica, el beneficio de la separación de capas que se diseñó en la lección anterior.

### Conceptos clave

#### Qué significa "agnóstico"

Un escenario **agnóstico** describe una regla de negocio sin mencionar tecnología: "un cliente con crédito insuficiente no puede activar un plan" es agnóstico; "el endpoint POST /activaciones devuelve 402" **no lo es** — esa segunda frase pertenece a la capa técnica, no al escenario de negocio. Un escenario agnóstico sigue siendo válido aunque la tecnología subyacente cambie por completo.

#### Estructura de carpetas recomendada

```
tests/
├── features/
│   ├── contratos/
│   │   └── activacion_servicio.robot
│   └── facturacion/
│       └── calculo_prorrateo.robot
└── technical/
    ├── api_keywords.resource
    └── web_keywords.resource
```

Los escenarios de negocio (`features/`) se organizan **por dominio** (contratos, facturación, clientes) — la misma forma en que el negocio piensa su propio trabajo. Las keywords técnicas (`technical/`) se organizan **por tecnología** (API, web) — la forma en que un ingeniero piensa la implementación. Esta diferencia de criterio de organización no es casualidad: cada carpeta está pensada para la audiencia que más la usa.

#### Tags multidimensionales

Las etiquetas se vuelven más valiosas en proyectos BDD organizados, porque permiten clasificar escenarios en **varias dimensiones simultáneamente**: dominio de negocio, prioridad y canal/integración. Por ejemplo, un escenario puede llevar los tags `contratos`, `regresion` y `api` a la vez, y filtrarse por cualquiera de esos criterios desde la línea de comandos — útil para ejecutar, por ejemplo, "todo lo de contratos que sea regresión, sin importar el canal" o "todo lo que toque la API, sin importar el dominio de negocio".

| Dimensión | Ejemplos de tags |
|---|---|
| Dominio de negocio | `contratos`, `facturacion`, `clientes` |
| Prioridad | `smoke`, `regresion` |
| Canal/integración | `web`, `api`, `movil` |

### Ejemplo comentado

```robot
# archivo: tests/features/contratos/activacion_servicio.robot
*** Settings ***
Documentation    Feature: Activación de Servicio (agnóstico a tecnología)
Resource         ../../technical/api_keywords.resource


*** Test Cases ***
La Activación Es Rechazada Por Crédito Insuficiente
    [Tags]    contratos    regresion    api
    Given un cliente con crédito insuficiente existe en el sistema
    When el cliente solicita la activación de un plan de datos adicional
    Then la activación es rechazada y se informa el motivo
```

```bash
# Filtrar por una sola dimensión
robot --include contratos tests/

# Combinar dos dimensiones (paretags, formalizado en la Sesión 9)
robot --include contratosANDregresion tests/
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Cómo se organiza `features/`? | Por dominio de negocio |
| ¿Cómo se organiza `technical/`? | Por tecnología |
| ¿Es agnóstico un escenario que menciona un código HTTP? | No |
| ¿Cuántas dimensiones de tags se mencionan como ejemplo? | Tres: dominio, prioridad, canal |

### Errores comunes

- **Organizar `features/` por tecnología en vez de por dominio** — pierde el sentido de la separación; el negocio no piensa en "API" o "web", piensa en "contratos" o "facturación".
- **Mencionar un detalle técnico dentro de un escenario Gherkin** ("el campo `status_code` debe ser 200") — rompe el carácter agnóstico del escenario.
- **No usar tags multidimensionales**, dejando solo un tag por test case — limita drásticamente la flexibilidad de filtrado en proyectos grandes.

### Puntos clave

- Un escenario agnóstico describe una regla de negocio, no un detalle técnico — sigue siendo válido aunque cambie la tecnología subyacente.
- Las carpetas separan `features/` (negocio, por dominio) de `technical/` (tecnología, por tipo de implementación).
- Los tags multidimensionales (dominio + prioridad + canal) facilitan el filtrado preciso de suites grandes.

### Autoevaluación

1. ¿Por qué `features/` se organiza por dominio de negocio y no por tecnología?
2. ¿Es agnóstico el escenario "el cliente recibe un SMS de confirmación"? ¿Y "la API responde con el header X-Confirmacion"?
3. Menciona las tres dimensiones de tags descritas en esta lección.

**Respuestas:** 1. Porque esa es la forma en que el negocio piensa su propio trabajo — facilita que negocio navegue y entienda la organización. 2. El primero es agnóstico (describe un resultado de negocio); el segundo no lo es (menciona un detalle técnico de implementación). 3. Dominio de negocio, prioridad, canal/integración.

---

## Resumen del capítulo

BDD reduce la brecha TI-Negocio describiendo comportamiento en lenguaje natural estructurado (Gherkin), acordado primero en la dinámica de las Tres Amigos — particularmente valioso en telecomunicaciones por sus reglas regulatorias. Robot Framework no requiere sintaxis adicional: los prefijos Given/When/Then/And/But son simple texto descartado mecánicamente al resolver la keyword; `Set Test Variable` comparte estado entre los pasos de un mismo test. El valor real de BDD aparece al separar en tres capas — test case, dominio, técnica —, con el criterio de "¿lo entendería un analista de negocio?" para asignar cada keyword a su capa, lo que aísla el impacto de cambios tecnológicos. Los escenarios agnósticos y una organización de carpetas por dominio de negocio (no por tecnología), reforzada con tags multidimensionales, sostienen esta separación a medida que el proyecto crece.

## Referencias bibliográficas

- BDD con Gherkin en RF: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#behavior-driven-style>
- Introducción a BDD (Cucumber/Gherkin, referencia conceptual): <https://cucumber.io/docs/bdd/>

```{=typst}
#pagebreak()
```
