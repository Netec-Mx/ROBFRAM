# Capítulo 9 — Ejecución Avanzada, Reporting y Preparación RFCP

## Información general

Este capítulo de cierre consolida el dominio del CLI de Robot Framework, profundiza en el reporting (la base de cualquier *quality gate*), y conecta todo lo aprendido con la integración en pipelines de CI/CD — preparando explícitamente para la certificación RFCP con una visión integrada de las 9 sesiones del curso.

**Lecciones de este capítulo:**

- 9.1 — CLI avanzado: `--variable`, `--include`/`--exclude`, `--suite`, `--rerunfailed` y paretags
- 9.2 — Reporting: análisis de `report.html`, `log.html`, métricas y `output.xml` con `rebot`
- 9.3 — Integración CI/CD conceptual: pipelines GitHub Actions/Jenkins y quality gates

---

## 9.1 CLI avanzado: variables, filtros y paretags

### Objetivos de la lección

- Aplicar las opciones de CLI más usadas en proyectos reales.
- Combinar tags con operadores lógicos (paretags).
- Reejecutar selectivamente los tests fallidos de una ejecución previa.

### ¿Por qué importa?

Dominar el CLI de Robot Framework es, en la práctica, tan importante como dominar la sintaxis `.robot` — un proyecto real rara vez ejecuta "toda la suite, siempre, igual"; necesita adaptarse a distintos contextos (un commit, un release, un diagnóstico puntual) sin tocar el código fuente.

### Conceptos clave

#### El patrón general y su filosofía

El patrón general del CLI de Robot Framework es `robot [opciones] [fuente]`. **Ninguna opción modifica los archivos `.robot`** — toda la configuración vive en el comando de ejecución, lo que permite adaptar una misma suite a distintos entornos (staging, producción, distintos conjuntos de datos) sin tocar el código fuente ni mantener copias paralelas de la suite.

#### Las opciones más usadas

| Opción | Qué hace | Ejemplo |
|---|---|---|
| `--variable NOMBRE:valor` | Inyecta o sobrescribe una variable en tiempo de ejecución | `--variable BASE_URL:https://staging.com` |
| `--include TAG` / `--exclude TAG` | Filtra por tag | `--include smoke` |
| `--suite NOMBRE` | Delimita la ejecución a una suite específica | `--suite Facturacion` |
| `--rerunfailed <output.xml>` | Reejecuta solo los tests que fallaron en esa ejecución previa | `--rerunfailed reports/output.xml` |
| `--outputdir <carpeta>` | Define dónde se guardan los reportes | `--outputdir reports` |

`--variable` tiene **precedencia sobre las variables definidas en el archivo** — recordando la jerarquía de precedencia completa vista en el Capítulo 2 (CLI > test/keyword > suite > Resource).

#### Paretags: combinación lógica de tags

Los **paretags** combinan condiciones de tags con operadores `AND`, `OR`, `NOT` — siempre **en mayúsculas y sin espacios** alrededor del operador:

```bash
# Solo tests que tienen AMBOS tags
robot --include smokeANDcritico tests/

# Tests que tienen AL MENOS UNO de los dos tags
robot --include criticoORregresion tests/

# Tests de regresión que NO sean básicos
robot --include regresion --exclude basico tests/
```

Esto permite expresar filtros precisos como "ejecuta los tests críticos de regresión, pero no los que están marcados como en progreso", sin necesitar tags compuestos artificiales como `regresion-critico-no-wip`.

#### --rerunfailed: ahorro de tiempo en suites grandes

`--rerunfailed <output.xml>` reejecuta solo los tests que fallaron en una ejecución previa, ahorrando tiempo en suites grandes — particularmente valioso para distinguir un fallo real (que persiste en el rerun) de un fallo intermitente (*flaky*, que podría no reproducirse en el rerun).

### Ejemplo comentado

```bash
# Ejecución completa, guardando el output con un nombre específico
robot --outputdir reports --output output1.xml tests/suite.robot

# Reejecutar SOLO lo que falló en esa ejecución
robot --outputdir reports --rerunfailed reports/output1.xml --output output2.xml tests/suite.robot
```

Si la suite original tenía 100 tests con 3 fallidos, el rerun ejecuta exactamente esos 3 — no los 100 — ahorrando el tiempo de los 97 que ya se sabe que pasaron.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Modifica `--variable` el archivo `.robot`? | No, ninguna opción de CLI lo hace |
| ¿Cómo se escriben los operadores de paretags? | En mayúsculas, sin espacios (`smokeANDcritico`) |
| ¿Qué reejecuta `--rerunfailed`? | Solo los tests que fallaron en la ejecución indicada |

### Errores comunes

- **Escribir paretags con espacios** (`smoke AND critico`) — Robot Framework no lo reconoce como un operador lógico, lo trata como dos tags separados sin relación.
- **Asumir que `--variable` cambia el archivo fuente** — solo afecta esa ejecución específica; el archivo `.robot` permanece sin cambios.
- **Usar `--rerunfailed` sin haber guardado el `output.xml` de la ejecución original con `--output`** — sin ese archivo, no hay nada que reejecutar selectivamente.

### Autoevaluación

1. ¿Cómo escribirías un filtro para ejecutar tests que sean `smoke` o `critico` (cualquiera de los dos)?
2. ¿Qué comando reejecuta solo los tests que fallaron en `reports/output1.xml`?
3. Verdadero o falso: `--variable BASE_URL:https://x.com` modifica permanentemente el valor de `${BASE_URL}` en el archivo `.robot`.

**Respuestas:** 1. `--include smokeORcritico`. 2. `robot --rerunfailed reports/output1.xml tests/`. 3. Falso — solo afecta esa ejecución, el archivo fuente no cambia.

---

## 9.2 Reporting: report.html, log.html y rebot

### Objetivos de la lección

- Interpretar la información de cada artefacto de reporte.
- Combinar varios `output.xml` en un solo reporte con `rebot`.
- Aplicar `rebot --merge` al patrón ejecutar/reintentar/combinar.

### ¿Por qué importa?

Sin entender `rebot`, el patrón "ejecutar, reintentar fallidos, combinar resultados" (lección 9.1) se queda incompleto — tendrías dos reportes separados (la ejecución original y el rerun) sin una forma clara de presentar un resultado final unificado.

### Conceptos clave

#### Los tres artefactos, repaso integrador

Robot Framework genera siempre tres artefactos, ya familiares desde el Capítulo 1: `output.xml` (los datos en bruto, la fuente de verdad), `log.html` (detalle de cada keyword ejecutada) y `report.html` (resumen ejecutivo con estadísticas, incluyendo el desglose "by tag" que viste en el Capítulo 5).

#### rebot: regenerar sin reejecutar

**`rebot`** es la herramienta que regenera `log.html`/`report.html` a partir de uno o varios `output.xml`, **sin necesidad de volver a ejecutar los tests**. Esto es posible porque `output.xml` contiene toda la información necesaria para reconstruir las vistas HTML — son completamente derivadas, no datos adicionales.

```bash
# Regenerar solo los reportes HTML a partir de un output.xml existente
rebot --outputdir reports output.xml
```

#### rebot --merge: el mecanismo formal detrás del patrón de reintento

El uso más valioso de `rebot` es **`--merge`**: combina varios archivos `output.xml` (por ejemplo, una ejecución original y su rerun de fallidos) en un solo reporte consolidado, usando el **resultado más reciente** de cada test que se repite entre los archivos:

```bash
rebot --outputdir reports --merge --output merged.xml reports/output1.xml reports/output2.xml
```

Si un test falló en `output1.xml` pero pasó en el rerun (`output2.xml`), el reporte combinado lo muestra como `PASS` — el resultado más reciente "gana". Este es el mecanismo formal detrás del patrón "ejecutar, reintentar fallidos, combinar" que practicaste en sesiones anteriores: no es solo una conveniencia de presentación, es la forma correcta de reportar un resultado final cuando hubo reintentos.

#### rebot también filtra

Además de combinar, `rebot` puede aplicar los mismos filtros de tags (`--include`/`--exclude`) sobre un `output.xml` ya existente, generando un reporte filtrado sin volver a ejecutar nada — útil para producir, por ejemplo, un reporte ejecutivo que solo muestre los resultados de `smoke` a partir de una ejecución completa que incluía mucho más.

### Ejemplo comentado

```bash
# 1. Ejecución completa
robot --outputdir reports --output output1.xml tests/suite.robot
# Resultado: 4 tests, 3 passed, 1 failed

# 2. Reintentar solo el fallido
robot --outputdir reports --rerunfailed reports/output1.xml --output output2.xml tests/suite.robot

# 3. Combinar ambos en un solo reporte final
rebot --outputdir reports --merge --output merged.xml reports/output1.xml reports/output2.xml
# El reporte combinado refleja el resultado MÁS RECIENTE de cada test
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿`rebot` reejecuta los tests? | No, solo regenera/combina reportes desde `output.xml` existentes |
| ¿Qué resultado "gana" al combinar con `--merge`? | El más reciente de cada test repetido entre los archivos |
| ¿Puede `rebot` aplicar `--include`/`--exclude`? | Sí, sobre un `output.xml` ya existente |

### Errores comunes

- **Intentar usar `rebot` para "arreglar" un test que falló** — `rebot` solo regenera/combina reportes; no puede cambiar el resultado real de una ejecución, solo presentarlo de otra forma.
- **Olvidar `--output` al ejecutar la versión original**, dejando el nombre por defecto (`output.xml`), y luego sobrescribirlo accidentalmente con el rerun antes de poder combinarlos.
- **Asumir que `--merge` promedia o suma resultados** — no lo hace; toma el resultado más reciente de cada test, no un cálculo agregado.

### Puntos clave

- `output.xml` es la fuente de verdad; `log.html`/`report.html` se derivan completamente de él.
- `rebot` regenera reportes sin reejecutar tests, y puede aplicar filtros de tags sobre un `output.xml` existente.
- `rebot --merge` combina varios `output.xml`, priorizando el resultado más reciente de cada test repetido — el mecanismo formal del patrón "ejecutar, reintentar, combinar".

### Autoevaluación

1. ¿Necesita `rebot` ejecutar los tests de nuevo para generar un reporte?
2. Si un test falló en la primera ejecución y pasó en el rerun, ¿qué muestra el reporte combinado con `--merge`?
3. ¿Puede `rebot` filtrar por tags sobre un `output.xml` ya existente, sin reejecutar nada?

**Respuestas:** 1. No, regenera/combina a partir de `output.xml` existentes. 2. `PASS` — el resultado más reciente de cada test repetido es el que se refleja. 3. Sí.

---

## 9.3 Integración CI/CD conceptual: pipelines y quality gates

### Objetivos de la lección

- Describir las etapas típicas de un pipeline CI/CD con Robot Framework.
- Explicar el concepto de quality gate.
- Conectar el contenido del curso con la preparación para RFCP.

### ¿Por qué importa?

La automatización solo alcanza su máximo valor operativo cuando deja de ejecutarse manualmente y se integra en el flujo de trabajo normal del equipo — un pipeline que ejecuta pruebas automáticamente ante cada cambio de código, sin que nadie tenga que recordar hacerlo.

### Conceptos clave

#### Las etapas típicas de un pipeline con Robot Framework

Un pipeline de CI/CD (GitHub Actions, Jenkins, GitLab CI, entre otros) ejecuta automáticamente una secuencia de pasos ante un evento (un `push`, un *pull request*):

1. Instalar dependencias (`pip install -r requirements.txt`, dentro de un entorno aislado — recordando el Capítulo 1).
2. Ejecutar la suite `smoke` (rápida) en cada commit.
3. Reservar la suite de `regresion` completa para antes de un release — el mismo patrón smoke/regresión que practicaste en el Capítulo 7.
4. Publicar los artefactos de reporte (`output.xml`, `log.html`, `report.html`) como evidencia de la ejecución.

#### Quality gate: la condición que decide si el pipeline avanza

Un **quality gate** es una condición mínima que debe cumplirse para que el pipeline continúe — por ejemplo, "0 tests fallidos" o "pass rate >= 95%". El **exit code** de `robot` (0 si todo pasó, distinto de 0 si hubo fallos) es la señal técnica que cualquier pipeline usa para decidir si avanza o se detiene — la misma señal que viste por primera vez en el Capítulo 1, al ejecutar tu primera suite con un fallo intencional y observar que el comando terminaba con un código distinto de cero.

```yaml
# Fragmento conceptual de un workflow de GitHub Actions
- name: Ejecutar suite smoke
  run: robot --include smoke tests/
  # Si robot termina con exit code != 0, este step falla,
  # y el pipeline se detiene automáticamente (comportamiento por defecto).
```

#### Cómo este curso te preparó para RFCP

Este capítulo, junto con todo el curso, te deja preparado para la certificación **RFCP**: el examen evalúa exactamente el lenguaje y la plataforma central que cubrieron las 9 sesiones —

- Sintaxis y estructura de archivos (Capítulo 1).
- Variables, Resources, tags, Setup/Teardown (Capítulo 2).
- Control de flujo y manejo de fallas (Capítulo 3).
- BDD nativo y separación de capas (Capítulo 4).
- Data-driven testing y extensión con Python (Capítulo 5).
- (Las librerías de dominio — Selenium, Requests — de los Capítulos 6 y 7 son valiosas profesionalmente, pero **no entran en el examen RFCP**, como aprendiste en la lección 1.2.)
- Aplicación a RPA (Capítulo 8).
- Ejecución avanzada por CLI y reporting (este capítulo).

— sin depender de ninguna librería de dominio específico. Repasar las autoevaluaciones de cada lección de este manual, junto con el simulacro completo de la Práctica 18 de la guía práctica, es la preparación más directa para el examen real.

### Ejemplo comentado

```bash
# Patrón típico de quality gate en un script de pipeline
robot --include smoke --outputdir results/ tests/
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Quality gate falló: hay tests smoke fallidos. Deteniendo el pipeline."
    exit 1
fi

echo "Quality gate superado. Continuando con el despliegue."
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué suite se ejecuta típicamente en cada commit? | `smoke` |
| ¿Qué señal usa un quality gate para decidir si el pipeline continúa? | El exit code de `robot` |
| ¿Las librerías de dominio (Selenium, Requests) entran en el examen RFCP? | No |

### Errores comunes

- **Ejecutar la suite de regresión completa en cada commit dentro del pipeline** — vuelve el ciclo de desarrollo innecesariamente lento; reserva eso para antes de un release.
- **No revisar el exit code de `robot` en un script de pipeline personalizado** — sin verificarlo explícitamente, el pipeline puede continuar incluso si la suite falló.
- **Estudiar `SeleniumLibrary`/`RequestsLibrary` en profundidad para el examen RFCP** — son valiosas profesionalmente, pero no son el foco de esa certificación específica; repasa mejor los Capítulos 1-5, 8 y 9.

### Puntos clave

- Un pipeline CI/CD típico ejecuta `smoke` en cada commit y `regresion` antes de release.
- Un quality gate usa el exit code de `robot` para decidir si el pipeline continúa o se detiene.
- La certificación RFCP evalúa precisamente el lenguaje y la plataforma central — los Capítulos 1 al 5, 8 y 9 de este manual (incluyendo `*** Tasks ***`, parte del lenguaje central), sin las librerías de dominio de los Capítulos 6-7 (Selenium, Requests).

### Autoevaluación

1. ¿Qué suite (smoke o regresión) es más apropiada para ejecutar en cada commit de un pipeline?
2. ¿Qué usa un quality gate para decidir si el pipeline continúa?
3. Para preparar el examen RFCP específicamente, ¿qué capítulos de este manual son más relevantes: 1-5, 8 y 9, o 6-7?

**Respuestas:** 1. Smoke. 2. El exit code de `robot` (0 = todo pasó, distinto de 0 = hubo fallos). 3. Los Capítulos 1-5, 8 y 9 — cubren el lenguaje y la plataforma central, incluyendo `*** Tasks ***`/RPA; los Capítulos 6-7 cubren librerías de dominio específico (Selenium, Requests), fuera del alcance de RFCP.

---

## Resumen del capítulo

El CLI de Robot Framework es completamente configurable sin tocar el código fuente: `--variable`, `--include`/`--exclude`, `--suite`, `--rerunfailed` y los paretags (siempre en mayúsculas, sin espacios) cubren la mayoría de las necesidades de ejecución avanzada. `rebot` regenera y combina reportes sin reejecutar tests — `--merge` es la pieza formal detrás del patrón "ejecutar, reintentar, combinar", priorizando siempre el resultado más reciente de cada test repetido. Un pipeline de CI/CD ejecuta smoke en cada commit y regresión antes de release, usando el exit code de `robot` como quality gate. La certificación RFCP evalúa precisamente el lenguaje y la plataforma central — los Capítulos 1 a 5, 8 y 9 de este manual (incluyendo RPA y `*** Tasks ***`, parte del lenguaje central), en contraste con las librerías de dominio específico (Selenium, Requests) de los Capítulos 6 y 7, que son valiosas profesionalmente pero no forman parte de ese examen.

## Referencias bibliográficas

- Robot Framework User Guide — Configuring execution: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#configuring-execution>
- rebot: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#rebot>
- Robot Framework Foundation (certificación RFCP): <https://robotframework.org/foundation/>
