# Capítulo 5 — RF Avanzado: Buenas Prácticas, Data-Driven y Extensión con Python

## Información general

Este capítulo cierra los fundamentos del lenguaje antes de pasar a los dominios de aplicación (web, API, RPA). Cubre cómo diseñar keywords reutilizables a escala, cómo evitar escribir un test case por cada combinación de datos, y cómo extender Robot Framework cuando las librerías nativas no alcanzan — con ejemplos de código completos en cada lección, no solo reglas abstractas.

**Lecciones de este capítulo:**

- 5.1 — Diseño de keywords reutilizables: separación por capas y convenciones de nombres
- 5.2 — Data-driven testing: DataDriver con CSV/JSON y trazabilidad con tags
- 5.3 — Librerías personalizadas en Python: keywords, tipos, documentación y decoradores
- 5.4 — Empaquetado, versionado y repositorios compartidos de librerías RF

---

## 5.1 Diseño de keywords reutilizables: separación por capas y convenciones de nombres

### Objetivos de la lección

- Aplicar el patrón de tres capas (visto en BDD) a keywords reutilizables en general.
- Adoptar convenciones de nombres consistentes.
- Reconocer cuándo una keyword debería dividirse en otras más pequeñas.

### ¿Por qué importa?

Un proyecto de automatización que crece sin convenciones claras de diseño de keywords se vuelve, en la práctica, ilegible para cualquiera que no sea su autor original — incluso para el propio autor, meses después.

### Conceptos clave

#### El mismo patrón de capas, generalizado

El patrón de separación por capas que conociste en el Capítulo 4 (test case → dominio → técnica) no es exclusivo de BDD: aplica a **cualquier** proyecto de automatización que quiera escalar, con o sin Gherkin. Una keyword de **capa técnica** (`Hacer Clic En Boton Login`) interactúa directamente con la tecnología; una keyword de **capa de acción** combina varias técnicas en un paso coherente (`Iniciar Sesion`, que internamente llama a "escribir usuario", "escribir contraseña" y "hacer clic en login"); una keyword de **capa de negocio** describe el resultado deseado en lenguaje de dominio (`El Usuario Esta Autenticado`).

#### Convenciones de nombres que reducen fricción

Las convenciones de nombres reducen la fricción de un equipo que crece:

- **Title Case** para keywords: `Verificar Que El Usuario Está Autenticado`, no `verificar_usuario` ni `VERIFICAR_USUARIO`.
- **Empezar con un verbo de acción**: `Crear`, `Verificar`, `Calcular`, `Obtener` — comunica inmediatamente qué hace la keyword.
- **Evitar abreviaturas ambiguas**: `Calcular Costo Total Del Plan` es preferible a `Calc Costo Tot Plan` — el ahorro de caracteres no compensa la pérdida de claridad.
- **Nombrar por el resultado, no por el mecanismo**, en la capa de negocio: `El Plan Queda Activo` en vez de `Verificar Status Code 200`.

Estas convenciones no son estéticas — afectan directamente qué tan rápido alguien nuevo en el equipo entiende una suite ajena, y qué tan fácil es para el Language Server (Capítulo 1) ofrecer autocompletado útil.

#### Cuándo dividir una keyword

Una señal práctica de que una keyword debería dividirse: si su `[Documentation]` necesita la palabra "y" más de una vez para describir lo que hace ("valida el formato del email y registra el cliente y envía la confirmación"), probablemente está haciendo demasiado y debería separarse en keywords más pequeñas, cada una con una sola responsabilidad, orquestadas desde una keyword de nivel superior.

### Ejemplo comentado

```robot
*** Keywords ***
# Capa técnica — interacción directa con SeleniumLibrary
Escribir En Campo Usuario
    [Arguments]    ${usuario}
    Input Text    id:username    ${usuario}

Escribir En Campo Contraseña
    [Arguments]    ${password}
    Input Password    id:password    ${password}

Hacer Clic En Botón Login
    Click Button    css:button[type='submit']

# Capa de acción — combina varias técnicas en un paso coherente
Iniciar Sesión
    [Arguments]    ${usuario}    ${password}
    Escribir En Campo Usuario    ${usuario}
    Escribir En Campo Contraseña    ${password}
    Hacer Clic En Botón Login

# Capa de negocio — lenguaje de dominio, sin ningún detalle técnico
El Usuario Está Autenticado Correctamente
    [Arguments]    ${usuario}    ${password}
    Iniciar Sesión    ${usuario}    ${password}
    Wait Until Element Is Visible    css:#bienvenida
```

Cada capa tiene exactamente una responsabilidad, y un test case solo debería llamar a la capa de negocio (`El Usuario Está Autenticado Correctamente`), nunca directamente a `Escribir En Campo Usuario`.

### Tabla de referencia rápida

| Capa | Ejemplo | Conoce detalles técnicos |
|---|---|---|
| Técnica | `Escribir En Campo Usuario` | Sí (selector CSS/id) |
| Acción | `Iniciar Sesión` | Indirectamente (llama a la técnica) |
| Negocio | `El Usuario Está Autenticado Correctamente` | No |

### Errores comunes

- **Nombrar keywords por el mecanismo en la capa de negocio** (`Verificar Response 200` en vez de `El Plan Queda Activo`) — mezcla niveles de abstracción.
- **Crear una keyword que hace 5 cosas distintas sin dividirla** — dificulta la reutilización parcial (¿qué pasa si solo necesitas la mitad de esa lógica en otro escenario?).
- **Usar snake_case o mayúsculas completas para nombres de keywords**, rompiendo la convención Title Case del resto del proyecto.

### Puntos clave

- El patrón de tres capas (técnica → acción → negocio) aplica a cualquier suite, no solo a BDD.
- Las convenciones de nombres (Title Case, verbo inicial, sin abreviaturas ambiguas) reducen la curva de entendimiento de un proyecto.
- Si la documentación de una keyword necesita varios "y" para describirla, probablemente debería dividirse.

### Autoevaluación

1. ¿En qué capa debería vivir el detalle de un selector CSS?
2. ¿Por qué `Calcular Costo Tot Plan` es una convención de nombre desaconsejada?
3. ¿Qué señal indica que una keyword probablemente hace demasiado y debería dividirse?

**Respuestas:** 1. La capa técnica. 2. Usa abreviaturas ambiguas que reducen la claridad sin un ahorro real significativo. 3. Que su documentación necesite la palabra "y" varias veces para describir lo que hace.

---

## 5.2 Data-driven testing: DataDriver con CSV/JSON y trazabilidad con tags

### Objetivos de la lección

- Explicar el problema que resuelve el testing data-driven.
- Describir cómo DataDriver genera tests desde un archivo externo.
- Configurar correctamente `dialect` y `encoding` según el origen de los datos.

### ¿Por qué importa?

Cuando la misma lógica de prueba debe validarse contra docenas de combinaciones de datos, escribir un test case por combinación duplica esfuerzo y dificulta el mantenimiento: un cambio en la lógica obliga a tocar N test cases en vez de uno.

### Conceptos clave

#### El problema que resuelve

El **testing data-driven** separa la lógica (una sola keyword "plantilla") de los datos (un archivo externo, CSV o JSON). En vez de escribir:

```robot
*** Test Cases ***
Activar Plan Cliente Con Credito 100 Y Costo 50
    ...
Activar Plan Cliente Con Credito 0 Y Costo 50
    ...
Activar Plan Cliente Con Credito 200 Y Costo 150
    ...
```

con la lógica repetida (o casi repetida) en cada uno, defines la lógica **una sola vez** y dejas que los datos vengan de afuera.

#### Cómo DataDriver genera los tests

**DataDriver** (librería de comunidad, se instala con `pip install robotframework-datadriver`) implementa este patrón con `Test Template`: declaras una keyword plantilla en `Settings`, y DataDriver genera **un test case por cada fila** del archivo de datos, usando los nombres de columna (con el formato `${nombre_argumento}`) para mapear a los argumentos de la keyword.

```robot
*** Settings ***
Library           DataDriver    ${CURDIR}/casos.csv    dialect=excel    encoding=utf_8
Test Template     Verificar Resultado De Activacion

*** Test Cases ***
Caso De Ejemplo    # Este test "plantilla" es reemplazado por DataDriver
```

```csv
*** Test Cases ***,${credito},${costo},${resultado_esperado},[Tags]
Cliente con crédito suficiente,100,50,ACTIVO,"smoke,positivo"
Cliente sin crédito,0,50,RECHAZADO,"regresion,negativo"
```

#### Un detalle técnico que casi siempre necesita ajustarse

DataDriver tiene valores por defecto pensados para configuraciones europeas: `dialect='Excel-EU'` (separador `;`, no `,`) y `encoding='cp1252'` (no UTF-8). En la práctica, casi siempre necesitas sobreescribir ambos parámetros explícitamente si tu archivo usa comas como separador y contiene caracteres con tilde o ñ — de lo contrario obtienes errores de "argumento no asignado" (porque el separador no coincide y las columnas no se detectan correctamente) o texto corrupto (mojibake, por ejemplo `crÃ©dito` en vez de `crédito`, por una codificación incorrecta).

#### Trazabilidad con la columna `[Tags]`

La columna especial `[Tags]` en el archivo de datos permite asignar tags **por fila** (con varios tags separados por coma dentro de la misma celda, entre comillas si hay coma en el contenido). Esto entrega **trazabilidad**: cada test generado lleva sus propios tags, visibles en las estadísticas "by tag" de `report.html`, sin escribir código adicional para segmentarlos.

#### Una limitación documentada del filtrado por CLI

El filtrado por `--include`/`--exclude` de la línea de comandos (que aprendiste en el Capítulo 2) ocurre **antes** de que DataDriver genere los tests reales — actúa sobre el test case "plantilla" original, que no tiene tags propios. Por eso, `--include` de CLI normalmente **no filtra correctamente** los tests generados por DataDriver. La forma correcta de filtrar es usando los parámetros propios de la librería (`Library DataDriver ... include=...`) en vez del flag de CLI, o revisar la segmentación directamente en `report.html` sin intentar filtrar la ejecución.

### Ejemplo comentado

```robot
*** Settings ***
Documentation     Suite data-driven con DataDriver, segmentada por tags.
Library           DataDriver    ${CURDIR}/../data/casos_activacion.csv    dialect=excel    encoding=utf_8
Test Template     Verificar Resultado De Activacion


*** Test Cases ***
Caso De Ejemplo De Activación


*** Keywords ***
Verificar Resultado De Activacion
    [Arguments]    ${credito}    ${costo}    ${resultado_esperado}
    ${resultado}=    Calcular Resultado De Activacion    ${credito}    ${costo}
    Should Be Equal    ${resultado}    ${resultado_esperado}

Calcular Resultado De Activacion
    [Arguments]    ${credito}    ${costo}
    ${credito_num}=    Convert To Integer    ${credito}
    ${costo_num}=      Convert To Integer    ${costo}
    IF    ${credito_num} >= ${costo_num}
        RETURN    ACTIVO
    ELSE
        RETURN    RECHAZADO
    END
```

Con un CSV de 4 filas, esta suite genera 4 test cases reales — visibles individualmente en `report.html` con sus propios nombres (tomados de la primera columna del CSV) y tags.

### Tabla de referencia rápida

| Parámetro de `Library DataDriver` | Valor por defecto | Valor típico necesario |
|---|---|---|
| `dialect` | `Excel-EU` (separador `;`) | `excel` (separador `,`) |
| `encoding` | `cp1252` | `utf_8` |

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué genera DataDriver por cada fila del archivo de datos? | Un test case independiente |
| ¿Qué columna especial define tags por fila? | `[Tags]` |
| ¿`--include` de CLI filtra correctamente tests generados por DataDriver? | No, hay una limitación documentada |

### Errores comunes

- **No especificar `dialect=excel` con un CSV separado por comas** — produce errores de argumento no asignado, porque DataDriver intenta separar por `;` y no encuentra las columnas esperadas.
- **No especificar `encoding=utf_8` con texto en español** — produce caracteres corruptos en los nombres de los tests generados.
- **Intentar filtrar tests de DataDriver con `--include` de CLI** y sorprenderse de que no funciona como con una suite normal — es una limitación documentada, no un bug del proyecto.

### Puntos clave

- DataDriver separa lógica (keyword plantilla) de datos (archivo CSV/JSON externo), generando un test por fila.
- Los valores por defecto de `dialect` y `encoding` son europeos; casi siempre se sobreescriben explícitamente.
- `--include`/`--exclude` de CLI tiene una limitación documentada con tests generados dinámicamente; usa la segmentación de `report.html` o los parámetros propios de la librería.

### Autoevaluación

1. ¿Qué dos parámetros de `Library DataDriver` casi siempre necesitas sobreescribir con un CSV típico en español?
2. ¿Qué error produce omitir `dialect=excel` con un CSV separado por comas?
3. ¿Por qué `--include smoke` puede no funcionar como esperas con una suite que usa DataDriver?

**Respuestas:** 1. `dialect` (a `excel`) y `encoding` (a `utf_8`). 2. Error de "argumento no asignado", porque las columnas no se detectan correctamente con el separador equivocado. 3. Porque el filtrado de CLI ocurre antes de que DataDriver genere los tests reales — actúa sobre el test plantilla, que no tiene tags propios.

---

## 5.3 Librerías personalizadas en Python: keywords, tipos, documentación y decoradores

### Objetivos de la lección

- Explicar cómo una función Python se convierte en keyword.
- Aplicar el decorador `@keyword` para personalizar nombre y tags.
- Aplicar la práctica de probar con pytest antes de integrar a Robot Framework.

### ¿Por qué importa?

Cuando las librerías nativas y de comunidad no cubren una necesidad específica del dominio, Robot Framework permite escribir keywords directamente en Python — sin esto, ciertos problemas (validaciones de dominio muy específicas, cálculos complejos) serían torpes de expresar solo con keywords `.robot`.

### Conceptos clave

#### La conversión automática snake_case → Title Case

Cualquier función pública (sin guion bajo al inicio) de un módulo `.py` importado con `Library` se convierte automáticamente en keyword. El nombre se traduce de `snake_case` a `Title Case Con Espacios`: una función `validar_numero_telefono` se convierte en la keyword `Validar Numero Telefono`.

#### El decorador `@keyword`: control explícito

El decorador `@keyword`, de `robot.api.deco`, permite personalizar ese comportamiento por defecto:

```python
from robot.api.deco import keyword

@keyword("Validar Numero De Telefono Guatemalteco")
def validar_numero_telefono(numero: str) -> bool:
    ...
```

- **Cambiar el nombre visible**: sin el decorador, esta función se vería como `Validar Numero Telefono` (sin "De" ni "Guatemalteco") — el decorador da control total sobre el nombre que verá quien escriba `.robot`.
- **Asignar tags automáticos**: `@keyword("...", tags=["facturacion"])` agrega ese tag a cualquier test que use la keyword, sin que el autor del test tenga que declararlo manualmente.
- **Declarar tipos de argumento**: combinado con *type hints* de Python (`numero: str`), Robot Framework puede validar o convertir automáticamente el tipo del argumento recibido.

#### El docstring como documentación dual

El **docstring** de la función cumple un rol doble: es la documentación del código Python para cualquier desarrollador que lo lea, y es también la **documentación oficial de la keyword** dentro de Robot Framework, visible en `log.html` y en el autocompletado de los IDEs con Language Server (Capítulo 1). Esto significa que escribir un buen docstring no es solo buena práctica de Python — tiene un beneficio directo y visible para quien use la keyword desde `.robot`.

```python
def calcular_costo_total(costo_base: float, impuesto_porcentaje: float = 12.0) -> float:
    """Calcula el costo total de un plan agregando el impuesto.

    Example:
    | ${total}=    Calcular Costo Total Del Plan    100
    | Should Be Equal As Numbers    ${total}    112.0
    """
    ...
```

El bloque `Example:` dentro del docstring, con la sintaxis de tabla de Robot Framework, aparece formateado correctamente en la documentación generada — una convención que vale la pena adoptar.

#### Por qué probar con pytest antes de integrar

Una práctica recomendada, no solo para librerías Python sino para cualquier lógica no trivial: **probar la función con `pytest` antes de integrarla a Robot Framework**. Esto separa dos preguntas distintas — ¿la lógica Python es correcta? y ¿la integración con Robot Framework funciona? — facilitando enormemente el diagnóstico cuando algo falla: si el test de `pytest` pasa pero el test de Robot Framework falla, el problema está en la integración (nombres de keyword, tipos de argumento), no en la lógica.

### Ejemplo comentado

```python
"""Librería Python personalizada para Robot Framework."""
from __future__ import annotations
import re
from robot.api.deco import keyword

NUMERO_TELEFONO_GT_PATTERN = re.compile(r"^[2-7]\d{7}$")


@keyword("Validar Numero De Telefono Guatemalteco")
def validar_numero_telefono(numero: str) -> bool:
    """Valida que un número guatemalteco tenga 8 dígitos y empiece
    entre 2 y 7 (rangos asignados por la Superintendencia de
    Telecomunicaciones de Guatemala).
    """
    return bool(NUMERO_TELEFONO_GT_PATTERN.fullmatch(numero))


@keyword("Calcular Costo Total Del Plan", tags=["facturacion"])
def calcular_costo_total(costo_base: float, impuesto_porcentaje: float = 12.0) -> float:
    """Calcula el costo total de un plan agregando el impuesto (IVA de
    Guatemala = 12% por defecto)."""
    if costo_base < 0:
        raise ValueError(f"El costo base no puede ser negativo: {costo_base}")
    total = costo_base * (1 + impuesto_porcentaje / 100)
    return round(total, 2)
```

```python
# Probado primero con pytest, ANTES de usarlo desde Robot Framework
def test_calcular_costo_total_con_impuesto_por_defecto():
    assert calcular_costo_total(100) == 112.0

def test_calcular_costo_total_con_costo_negativo_lanza_value_error():
    with pytest.raises(ValueError):
        calcular_costo_total(-50)
```

### Tabla de referencia rápida

| Elemento Python | Efecto en Robot Framework |
|---|---|
| Función pública (sin `_` inicial) en un `.py` importado con `Library` | Se convierte automáticamente en keyword (snake_case → Title Case) |
| `@keyword("Nombre Personalizado")` | Cambia el nombre visible de la keyword |
| `@keyword(tags=[...])` | Asigna tags automáticos a tests que usan esa keyword |
| Docstring de la función | Documentación oficial de la keyword en `log.html` |

### Errores comunes

- **Nombrar la función con un guion bajo inicial** (`_validar_numero`) pensando que se convertirá en keyword igual — las funciones "privadas" (con `_`) **no** se exponen como keywords.
- **Omitir el docstring** pensando que es solo para Python — se pierde la documentación visible desde Robot Framework, afectando a cualquiera que use la keyword sin leer el código fuente.
- **Saltar la prueba con pytest** e ir directo a probar desde Robot Framework — dificulta saber si un fallo es de lógica o de integración.

### Puntos clave

- Funciones públicas en un `.py` se convierten automáticamente en keywords (snake_case → Title Case); las funciones con `_` inicial no se exponen.
- `@keyword` personaliza nombre, tags y tipos de argumento, dando control explícito sobre el comportamiento por defecto.
- El docstring es documentación de Python **y** de la keyword en Robot Framework simultáneamente.
- Probar con `pytest` antes de integrar separa el error de lógica del error de integración.

### Autoevaluación

1. ¿Qué pasa si una función Python se llama `_calcular_total` (con guion bajo inicial)?
2. ¿Para qué sirve el parámetro `tags=` del decorador `@keyword`?
3. ¿Por qué es recomendable probar una función Python con pytest antes de integrarla a Robot Framework?

**Respuestas:** 1. No se expone como keyword — las funciones con guion bajo inicial se consideran privadas. 2. Asigna automáticamente esos tags a cualquier test que use esa keyword, sin que el autor del test los declare manualmente. 3. Para separar si un fallo es de lógica (pytest) o de integración (Robot Framework), facilitando el diagnóstico.

---

## 5.4 Empaquetado, versionado y repositorios compartidos de librerías RF

### Objetivos de la lección

- Describir cómo empaquetar una librería Python como artefacto distribuible.
- Aplicar versionado semántico (SemVer) a una librería propia.
- Diferenciar índices públicos y privados de paquetes Python.

### ¿Por qué importa?

Sin empaquetado ni versionado, compartir una librería Python entre varios proyectos de un equipo significa copiar y pegar archivos manualmente — perdiendo trazabilidad de qué versión usa cada proyecto y arriesgando que una corrección en un proyecto no llegue nunca a los demás.

### Conceptos clave

#### Por qué empaquetar

Cuando un equipo de automatización crece más allá de un solo proyecto, las librerías Python personalizadas se benefician de convertirse en **paquetes distribuibles** (`.whl`), instalables con `pip install` igual que cualquier librería de PyPI, en lugar de copiarse manualmente entre proyectos. Un paquete mínimo necesita una estructura estándar de Python:

```
mi_libreria_rf/
├── src/
│   └── MiLibreriaRF/
│       ├── __init__.py
│       └── keywords.py
└── pyproject.toml
```

El archivo `pyproject.toml` declara metadatos del paquete (nombre, versión, dependencias) y se construye con herramientas como `build` y `twine` para publicarlo en un índice de paquetes.

#### Versionado semántico (SemVer)

El **versionado semántico** (`MAJOR.MINOR.PATCH`) comunica el impacto de un cambio sin necesidad de leer el changelog completo:

| Componente | Cuándo incrementarlo | Ejemplo |
|---|---|---|
| `PATCH` | Correcciones que no rompen nada existente | `1.2.0` → `1.2.1` |
| `MINOR` | Keywords nuevas que tampoco rompen lo existente | `1.2.1` → `1.3.0` |
| `MAJOR` | Cambios incompatibles (renombrar/eliminar una keyword usada por otros) | `1.3.0` → `2.0.0` |

Este mismo curso usa SemVer para versionar cada sesión cerrada en sus repositorios — la convención no es exclusiva de librerías Python, es un lenguaje compartido para comunicar el alcance de un cambio en cualquier artefacto de software.

#### Índices públicos vs. privados

PyPI (el índice público estándar de Python) es apropiado para librerías open source que cualquiera puede usar. Para librerías internas de una empresa — que contienen lógica de negocio o credenciales de configuración que no deberían ser públicas — existen **índices privados** (GitLab Package Registry, Azure Artifacts, JFrog Artifactory) que funcionan **exactamente igual** desde la perspectiva de `pip install`, solo apuntando a una URL distinta mediante el parámetro `--index-url`.

### Ejemplo comentado

```toml
# pyproject.toml — configuración mínima para empaquetar una librería RF
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "mi-libreria-rf"
version = "1.2.0"
dependencies = ["robotframework>=7.0"]
```

```bash
# Construir el paquete distribuible (.whl)
python -m build

# Publicar en un índice privado de la empresa
twine upload --repository-url https://gitlab.empresa.com/api/v4/projects/123/packages/pypi dist/*

# Instalar desde ese índice privado en otro proyecto
pip install mi-libreria-rf --index-url https://gitlab.empresa.com/api/v4/projects/123/packages/pypi/simple
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué incrementa SemVer ante un cambio incompatible? | `MAJOR` |
| ¿Qué incrementa SemVer ante una corrección que no rompe nada? | `PATCH` |
| ¿Qué archivo declara metadatos de un paquete Python moderno? | `pyproject.toml` |
| ¿Un índice privado usa una sintaxis distinta de `pip install`? | No, solo cambia la URL del índice |

### Errores comunes

- **Incrementar solo `PATCH` al renombrar una keyword existente** — eso es un cambio incompatible (`MAJOR`), porque rompe a cualquier proyecto que ya use el nombre anterior.
- **Publicar una librería con lógica de negocio interna en el índice público de PyPI** por desconocer la opción de índices privados.
- **Copiar y pegar el código de una librería entre proyectos** en vez de empaquetarla — pierde trazabilidad de versión y dificulta propagar correcciones.

### Puntos clave

- Empaquetar una librería propia la convierte en instalable con `pip`, evitando copiar archivos entre proyectos.
- SemVer (`MAJOR.MINOR.PATCH`) comunica el impacto de un cambio: parche, funcionalidad nueva, o cambio incompatible.
- Los índices privados permiten compartir librerías internas sin publicarlas en PyPI público, usando la misma sintaxis de `pip install` con una URL distinta.

### Autoevaluación

1. Si renombras una keyword existente que otros proyectos ya usan, ¿qué componente de SemVer deberías incrementar?
2. ¿Qué herramienta(s) se mencionan para construir y publicar un paquete Python?
3. ¿Cambia la sintaxis de `pip install` al usar un índice privado en vez de PyPI público?

**Respuestas:** 1. `MAJOR` — es un cambio incompatible. 2. `build` (para construir) y `twine` (para publicar). 3. No, solo cambia la URL del índice (`--index-url`), la sintaxis del comando es la misma.

---

## Resumen del capítulo

El diseño de keywords reutilizables se beneficia del mismo patrón de capas que BDD (técnica → acción → negocio), más convenciones de nombres consistentes y la disciplina de dividir keywords que hacen demasiado. El testing data-driven (DataDriver) separa lógica de datos, generando un test por fila de un CSV/JSON externo — con cuidado explícito en los valores por defecto de `dialect`/`encoding` (europeos) y en la limitación de filtrado por CLI con tests generados dinámicamente. Las librerías Python extienden Robot Framework con funciones convertidas automáticamente en keywords (snake_case → Title Case), personalizables con `@keyword`, documentadas con docstrings que sirven doble propósito, e idealmente probadas con `pytest` antes de integrarse. Para escalar a varios proyectos, esas librerías se empaquetan con `pyproject.toml`, se versionan con SemVer, y se distribuyen vía índices públicos o privados sin cambiar la sintaxis de instalación.

## Referencias bibliográficas

- Creating test libraries: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#creating-test-libraries>
- robotframework-datadriver: <https://github.com/Snooz82/robotframework-datadriver>
- Decorador `@keyword`: <https://robot-framework.readthedocs.io/en/stable/autodoc/robot.api.html#robot.api.deco.keyword>
- Versionado semántico: <https://semver.org/lang/es/>

```{=typst}
#pagebreak()
```
