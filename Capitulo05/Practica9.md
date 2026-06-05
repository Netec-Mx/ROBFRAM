# Práctica 9: Suite data-driven con CSV y segmentación por tags

## 1. Metadatos

| Campo            | Valor                                      |
|------------------|--------------------------------------------|
| **Duración**     | 72 minutos                                 |
| **Complejidad**  | Media                                      |
| **Nivel Bloom**  | Aplicar (*Apply*)                          |
| **Módulo**       | 5 — Testing Avanzado y Data-Driven         |
| **Librería clave** | `robotframework-datadriver 1.x`          |

---

## 2. Descripción General

En este laboratorio construirás una suite de pruebas **data-driven real** para validar tarifas de planes de telecomunicaciones de la empresa ficticia **TelecomNova S.A.** Los datos de prueba provienen de un archivo CSV externo con 12 filas que cubren casos válidos, de límite y valores inválidos. Usarás la librería **DataDriver** junto con `Test Template` para parametrizar automáticamente la ejecución, y aprovecharás una columna `test_tag` del CSV para segmentar las ejecuciones por `smoke` o `edge_cases`. Adicionalmente, implementarás una variante con JSON para comparar ambos formatos de fuente de datos. Todas las keywords seguirán la arquitectura por capas vista en la Lección 5.1: prefijos `Validate_*`, `Assert_*` y `Get_*`.

---

## 3. Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:

- [ ] Configurar `robotframework-datadriver` para ejecutar test cases parametrizados desde un archivo CSV externo con múltiples columnas.
- [ ] Diseñar un archivo CSV con columnas de entrada, valores esperados y tags dinámicos para pruebas de telecomunicaciones.
- [ ] Implementar `Test Template` con DataDriver y asignar tags dinámicos por fila para filtrar ejecuciones por segmento (`smoke`, `edge_cases`).
- [ ] Aplicar la arquitectura de keywords por capas (`Validate_*`, `Assert_*`, `Get_*`) en un contexto data-driven.
- [ ] Comparar el uso de CSV y JSON como fuentes de datos alternativas en Robot Framework.

---

## 4. Prerrequisitos

### Conocimiento previo
- Haber completado los laboratorios de los Módulos 2 y 3 (variables, archivos Resource, estructuras de control IF/FOR).
- Comprensión básica de `Test Template` en Robot Framework.
- Familiaridad con el formato CSV y JSON (lectura e interpretación).
- Conocimiento de keywords BuiltIn: `Should Be Equal`, `Should Be True`, `Convert To Number`.

### Acceso y herramientas
- Python 3.10 o superior instalado y accesible desde terminal.
- Entorno virtual Python (`venv`) **activado** — obligatorio para este laboratorio.
- `robotframework-datadriver` instalado **con soporte CSV** (ver Sección 5).
- Visual Studio Code con la extensión Robot Framework Language Server.
- Conexión a internet no requerida durante la ejecución (todos los datos son locales).

---

## 5. Entorno de Laboratorio

### Hardware mínimo requerido

| Componente        | Mínimo requerido                              |
|-------------------|-----------------------------------------------|
| Procesador        | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos)|
| RAM               | 8 GB                                          |
| Almacenamiento    | 5 GB libres                                   |
| Pantalla          | Resolución 1280×768                           |

### Software requerido

| Herramienta                      | Versión mínima |
|----------------------------------|----------------|
| Python                           | 3.10           |
| Robot Framework                  | 7.x            |
| robotframework-datadriver        | 1.x (con CSV)  |
| pip                              | 23.x           |
| Visual Studio Code               | 1.85           |
| Robot Framework Language Server  | 1.12           |

### Preparación del entorno

> ⚠️ **IMPORTANTE:** Ejecuta todos los comandos dentro de tu entorno virtual. Si no está creado, sigue los pasos A y B antes de continuar.

**Paso A — Crear y activar el entorno virtual**

```bash
# Crear el entorno virtual (solo la primera vez)
python -m venv venv_telecomnova

# Activar en Windows (cmd)
venv_telecomnova\Scripts\activate.bat

# Activar en Windows (PowerShell)
venv_telecomnova\Scripts\Activate.ps1

# Activar en macOS / Linux (bash/zsh)
source venv_telecomnova/bin/activate
```

**Paso B — Instalar dependencias**

```bash
# Instalar Robot Framework
pip install robotframework==7.1

# Instalar DataDriver CON soporte CSV (el extra [CSV] es obligatorio)
pip install "robotframework-datadriver[CSV]"

# Verificar instalaciones
python -m robot --version
python -c "from DataDriver import DataDriver; print('DataDriver OK')"
```

> ⚠️ **Nota crítica:** Instalar solo `robotframework-datadriver` sin el extra `[CSV]` provoca el error `No module named 'csv_lib'` al ejecutar. Siempre usa `robotframework-datadriver[CSV]`.

**Paso C — Crear la estructura del proyecto**

```bash
# Desde la raíz de tu área de trabajo
mkdir -p lab_05_datadriver/tests
mkdir -p lab_05_datadriver/resources/keywords
mkdir -p lab_05_datadriver/resources/data
mkdir -p lab_05_datadriver/results

cd lab_05_datadriver
```

La estructura final del proyecto será:

```
lab_05_datadriver/
├── tests/
│   ├── planes_telecom_csv.robot        # Suite principal (CSV)
│   └── planes_telecom_json.robot       # Suite variante (JSON)
├── resources/
│   ├── keywords/
│   │   └── telecom_keywords.resource   # Keywords por capas
│   └── data/
│       ├── planes_telecom.csv          # Fuente de datos CSV
│       └── planes_telecom.json         # Fuente de datos JSON
└── results/                            # Reportes generados
```

---

## 6. Pasos del Laboratorio

---

### Paso 1 — Crear el archivo CSV de datos de prueba

**Objetivo:** Diseñar el archivo CSV con 12 filas que representen escenarios válidos, de límite e inválidos para los planes de telecomunicaciones de TelecomNova S.A.

#### Instrucciones

1. Abre VS Code y navega hasta `lab_05_datadriver/resources/data/`.
2. Crea el archivo `planes_telecom.csv` con el siguiente contenido exacto:

```csv
*** Test Cases ***,plan_name,monthly_price,data_gb,voice_minutes,expected_category,test_tag
,Plan Básico Prepago,9.99,1,100,basic,smoke
,Plan Familiar Estándar,29.99,10,500,standard,smoke
,Plan Profesional Plus,49.99,25,1000,premium,smoke
,Plan Empresarial Elite,99.99,100,ilimitado,enterprise,smoke
,Plan Límite Inferior,0.01,0,0,invalid,edge_cases
,Plan Precio Cero,0.00,5,200,invalid,edge_cases
,Plan Datos Negativos,15.00,-1,300,invalid,edge_cases
,Plan Minutos Negativos,15.00,5,-100,invalid,edge_cases
,Plan Precio Máximo,999.99,500,ilimitado,enterprise,edge_cases
,Plan Datos Cero GB,19.99,0,500,basic,edge_cases
,Plan Solo Voz,12.50,0,ilimitado,voice_only,smoke
,Plan Datos Ilimitados,79.99,ilimitado,500,premium,smoke
```

> **Nota sobre el formato DataDriver:** La columna `*** Test Cases ***` es el nombre del test case generado. DataDriver la requiere como primera columna. Las columnas restantes se convierten automáticamente en variables `${plan_name}`, `${monthly_price}`, etc.

#### Salida esperada

El archivo `planes_telecom.csv` debe tener exactamente 13 líneas (1 encabezado + 12 filas de datos). Puedes verificarlo con:

```bash
# Windows (PowerShell)
(Get-Content resources\data\planes_telecom.csv).Count

# macOS / Linux
wc -l resources/data/planes_telecom.csv
```

#### Verificación

```bash
# Mostrar las primeras 3 líneas del CSV para confirmar el formato
# Windows (PowerShell)
Get-Content resources\data\planes_telecom.csv | Select-Object -First 3

# macOS / Linux
head -3 resources/data/planes_telecom.csv
```

Debes ver:
```
*** Test Cases ***,plan_name,monthly_price,data_gb,voice_minutes,expected_category,test_tag
,Plan Básico Prepago,9.99,1,100,basic,smoke
,Plan Familiar Estándar,29.99,10,500,standard,smoke
```

---

### Paso 2 — Implementar el archivo Resource con keywords por capas

**Objetivo:** Crear las keywords reutilizables siguiendo la arquitectura de tres capas (técnica, acción, negocio) con las convenciones de nombres `Validate_*`, `Assert_*` y `Get_*`.

#### Instrucciones

1. Crea el archivo `resources/keywords/telecom_keywords.resource`.
2. Implementa el contenido completo siguiente, prestando atención a los comentarios que identifican cada capa:

```robotframework
*** Settings ***
Documentation    Keywords reutilizables para validación de planes TelecomNova S.A.
...              Arquitectura por capas: Técnica → Acción → Negocio
...              Convenciones: Get_* (obtener/transformar), Assert_* (verificar),
...              Validate_* (validar flujo completo de negocio)
Library          BuiltIn
Library          Collections
Library          String

*** Variables ***
# Umbrales de categorización de planes (capa de configuración)
${PRECIO_BASICO_MAX}        20.00
${PRECIO_STANDARD_MAX}      40.00
${PRECIO_PREMIUM_MAX}       80.00
${PRECIO_ENTERPRISE_MIN}    80.01
${DATOS_VOICE_ONLY}         0
${PRECIO_MINIMO_VALIDO}     0.01

*** Keywords ***

# =============================================================================
# CAPA TÉCNICA — Operaciones atómicas de transformación y verificación básica
# Prefijos: Get_* para obtener/transformar valores
# =============================================================================

Get_Precio_Como_Numero
    [Documentation]    Convierte el precio del plan a número flotante.
    ...                Retorna -1 si el valor no es convertible (caso inválido).
    [Arguments]    ${precio_str}
    ${es_numero}=    Run Keyword And Return Status
    ...              Convert To Number    ${precio_str}
    IF    ${es_numero}
        ${precio}=    Convert To Number    ${precio_str}
        RETURN    ${precio}
    ELSE
        RETURN    ${-1}
    END

Get_Datos_Como_Numero
    [Documentation]    Convierte GB de datos a número. Retorna 9999 para 'ilimitado',
    ...                -1 para valores no convertibles.
    [Arguments]    ${datos_str}
    ${datos_lower}=    Convert To Lower Case    ${datos_str}
    IF    '${datos_lower}' == 'ilimitado'
        RETURN    ${9999}
    END
    ${es_numero}=    Run Keyword And Return Status
    ...              Convert To Number    ${datos_str}
    IF    ${es_numero}
        ${datos}=    Convert To Number    ${datos_str}
        RETURN    ${datos}
    ELSE
        RETURN    ${-1}
    END

Get_Minutos_Como_Numero
    [Documentation]    Convierte minutos de voz a número. Retorna 9999 para 'ilimitado',
    ...                -1 para valores no convertibles.
    [Arguments]    ${minutos_str}
    ${min_lower}=    Convert To Lower Case    ${minutos_str}
    IF    '${min_lower}' == 'ilimitado'
        RETURN    ${9999}
    END
    ${es_numero}=    Run Keyword And Return Status
    ...              Convert To Number    ${minutos_str}
    IF    ${es_numero}
        ${minutos}=    Convert To Number    ${minutos_str}
        RETURN    ${minutos}
    ELSE
        RETURN    ${-1}
    END

# =============================================================================
# CAPA DE ACCIÓN — Verificaciones individuales de atributos del plan
# Prefijos: Assert_* para verificar condiciones específicas
# =============================================================================

Assert_Plan_Tiene_Nombre_Valido
    [Documentation]    Verifica que el nombre del plan no esté vacío y tenga
    ...                al menos 5 caracteres.
    [Arguments]    ${plan_name}
    Should Not Be Empty    ${plan_name}
    ...    msg=El nombre del plan no puede estar vacío
    ${longitud}=    Get Length    ${plan_name}
    Should Be True    ${longitud} >= 5
    ...    msg=El nombre '${plan_name}' es demasiado corto (mínimo 5 caracteres)

Assert_Precio_Es_Coherente_Con_Categoria
    [Documentation]    Verifica que el precio numérico sea coherente con la
    ...                categoría esperada del plan.
    [Arguments]    ${precio}    ${expected_category}
    IF    '${expected_category}' == 'invalid'
        Should Be True    ${precio} <= 0
        ...    msg=Plan inválido debería tener precio <= 0, se recibió: ${precio}
    ELSE IF    '${expected_category}' == 'basic'
        Should Be True    ${precio} > 0 and ${precio} <= ${PRECIO_BASICO_MAX}
        ...    msg=Plan básico fuera de rango: ${precio} (esperado: 0 < precio <= ${PRECIO_BASICO_MAX})
    ELSE IF    '${expected_category}' == 'standard'
        Should Be True    ${precio} > 0 and ${precio} <= ${PRECIO_STANDARD_MAX}
        ...    msg=Plan estándar fuera de rango: ${precio} (esperado: 0 < precio <= ${PRECIO_STANDARD_MAX})
    ELSE IF    '${expected_category}' == 'premium'
        Should Be True    ${precio} > 0 and ${precio} <= ${PRECIO_PREMIUM_MAX}
        ...    msg=Plan premium fuera de rango: ${precio} (esperado: 0 < precio <= ${PRECIO_PREMIUM_MAX})
    ELSE IF    '${expected_category}' == 'enterprise'
        Should Be True    ${precio} > ${PRECIO_ENTERPRISE_MIN} or ${precio} == 99.99
        ...    msg=Plan enterprise fuera de rango: ${precio} (esperado: precio > ${PRECIO_ENTERPRISE_MIN})
    ELSE IF    '${expected_category}' == 'voice_only'
        Should Be True    ${precio} > 0
        ...    msg=Plan voz debe tener precio positivo: ${precio}
    END

Assert_Datos_Son_Coherentes_Con_Categoria
    [Documentation]    Verifica que los GB de datos sean coherentes con la categoría.
    [Arguments]    ${datos_num}    ${expected_category}
    IF    '${expected_category}' == 'invalid'
        Should Be True    ${datos_num} < 0
        ...    msg=Plan inválido debería tener datos negativos, se recibió: ${datos_num}
    ELSE IF    '${expected_category}' == 'voice_only'
        Should Be Equal As Numbers    ${datos_num}    0
        ...    msg=Plan voz debe tener 0 GB de datos, se recibió: ${datos_num}
    ELSE
        Should Be True    ${datos_num} >= 0
        ...    msg=Plan válido no puede tener datos negativos: ${datos_num}
    END

# =============================================================================
# CAPA DE NEGOCIO — Flujos completos de validación del plan
# Prefijos: Validate_* para validaciones de negocio end-to-end
# =============================================================================

Validate_Categoria_Del_Plan
    [Documentation]    Keyword de negocio principal. Determina la categoría real
    ...                del plan basándose en precio y datos, y la compara con
    ...                la categoría esperada del CSV.
    [Arguments]    ${plan_name}    ${monthly_price}    ${data_gb}
    ...            ${voice_minutes}    ${expected_category}
    # Obtener valores numéricos (capa técnica)
    ${precio}=      Get_Precio_Como_Numero    ${monthly_price}
    ${datos}=       Get_Datos_Como_Numero     ${data_gb}
    ${minutos}=     Get_Minutos_Como_Numero   ${voice_minutes}
    # Verificaciones de atributos (capa de acción)
    Assert_Plan_Tiene_Nombre_Valido              ${plan_name}
    Assert_Precio_Es_Coherente_Con_Categoria     ${precio}    ${expected_category}
    Assert_Datos_Son_Coherentes_Con_Categoria    ${datos}     ${expected_category}
    # Determinar categoría real y comparar con la esperada
    ${categoria_real}=    Get_Categoria_Calculada
    ...    ${precio}    ${datos}    ${minutos}
    Should Be Equal    ${categoria_real}    ${expected_category}
    ...    msg=Categoría incorrecta para '${plan_name}': esperada='${expected_category}', calculada='${categoria_real}'
    Log    ✔ Plan '${plan_name}' validado correctamente — Categoría: ${categoria_real}    level=INFO

Get_Categoria_Calculada
    [Documentation]    Calcula la categoría del plan según reglas de negocio TelecomNova.
    ...                Reglas: precio<=0 → invalid; datos<0 o minutos<0 → invalid;
    ...                datos==0 y minutos>0 → voice_only; precio<=20 → basic;
    ...                precio<=40 → standard; precio<=80 → premium; resto → enterprise
    [Arguments]    ${precio}    ${datos}    ${minutos}
    IF    ${precio} <= 0
        RETURN    invalid
    END
    IF    ${datos} < 0 or ${minutos} < 0
        RETURN    invalid
    END
    IF    ${datos} == 0 and ${minutos} > 0
        RETURN    voice_only
    END
    IF    ${precio} <= ${PRECIO_BASICO_MAX}
        RETURN    basic
    ELSE IF    ${precio} <= ${PRECIO_STANDARD_MAX}
        RETURN    standard
    ELSE IF    ${precio} <= ${PRECIO_PREMIUM_MAX}
        RETURN    premium
    ELSE
        RETURN    enterprise
    END
```

#### Salida esperada

Al guardar el archivo, VS Code con Robot Framework Language Server debe mostrar las keywords sin errores de sintaxis (sin subrayados rojos). El panel de keywords debe listar las 7 keywords definidas.

#### Verificación

Ejecuta una verificación de sintaxis con `--dryrun`:

```bash
# Desde la raíz lab_05_datadriver/
# Este comando no ejecuta los tests, solo valida la sintaxis del Resource
python -m robot --dryrun --nostatusrc \
    --outputdir results \
    resources/keywords/telecom_keywords.resource 2>&1 | head -20
```

> En Windows PowerShell reemplaza el `\` al final de línea por `` ` `` (backtick) para continuar en la siguiente línea, o escribe el comando en una sola línea.

---

### Paso 3 — Crear la suite principal con DataDriver (fuente CSV)

**Objetivo:** Implementar la suite que usa `Test Template` + DataDriver para parametrizar automáticamente los 12 casos de prueba desde el CSV.

#### Instrucciones

1. Crea el archivo `tests/planes_telecom_csv.robot`:

```robotframework
*** Settings ***
Documentation    Suite data-driven de validación de planes TelecomNova S.A.
...              Fuente de datos: CSV externo (planes_telecom.csv)
...              Estrategia: Test Template + DataDriver con tags dinámicos
...
...              ARQUITECTURA DE KEYWORDS (Lección 5.1):
...              - Validate_* → Capa de negocio (flujos completos)
...              - Assert_*   → Capa de acción (verificaciones individuales)
...              - Get_*      → Capa técnica (transformaciones atómicas)
Library          DataDriver    ../resources/data/planes_telecom.csv
...              dialect=excel
...              encoding=utf-8
Resource         ../resources/keywords/telecom_keywords.resource

Test Template    Validate_Categoria_Del_Plan

*** Test Cases ***
Validar Plan TelecomNova: ${plan_name} — Precio: ${monthly_price} — Categoría: ${expected_category}
    [Tags]    ${test_tag}    data_driven    telecomnova
    [Documentation]    Test generado automáticamente por DataDriver desde CSV.
    ...                Variables inyectadas: plan_name, monthly_price, data_gb,
    ...                voice_minutes, expected_category, test_tag
    ${plan_name}    ${monthly_price}    ${data_gb}    ${voice_minutes}
    ...    ${expected_category}
```

> **Explicación de la sintaxis DataDriver:**
> - La instrucción `Library DataDriver <archivo_csv>` registra el CSV como fuente.
> - `Test Template` define la keyword que se ejecutará para cada fila.
> - El único `*** Test Cases ***` actúa como plantilla; DataDriver lo replica una vez por cada fila del CSV.
> - Las columnas del CSV se convierten en variables `${nombre_columna}` disponibles en el test y en la keyword.
> - La columna `test_tag` se usa en `[Tags]` con `${test_tag}`, lo que permite filtrar por `smoke` o `edge_cases`.

#### Salida esperada

El archivo debe guardarse sin errores de sintaxis. En VS Code, el archivo debe mostrar el decorador `Test Template` resaltado correctamente.

#### Verificación

Ejecuta un `--dryrun` para confirmar que DataDriver puede leer el CSV y generar los 12 test cases:

```bash
# Windows (PowerShell) — una sola línea
python -m robot --dryrun --outputdir results tests/planes_telecom_csv.robot

# macOS / Linux
python -m robot --dryrun --outputdir results tests/planes_telecom_csv.robot
```

Debes ver en la salida algo similar a:

```
==============================================================================
Planes Telecom Csv
==============================================================================
Validar Plan TelecomNova: Plan Básico Prepago — Precio: 9.99 — ...    | SKIP |
Validar Plan TelecomNova: Plan Familiar Estándar — Precio: 29.99 — ...| SKIP |
...
12 tests, 0 passed, 0 failed, 12 skipped (dry run)
==============================================================================
```

> El `SKIP` en `--dryrun` es el comportamiento esperado; significa que la sintaxis es válida y DataDriver generó los 12 casos.

---

### Paso 4 — Ejecutar la suite completa y analizar resultados

**Objetivo:** Ejecutar todos los test cases generados por DataDriver y verificar los resultados en el reporte HTML.

#### Instrucciones

1. Ejecuta la suite completa:

```bash
python -m robot \
    --outputdir results \
    --log log_csv.html \
    --report report_csv.html \
    --output output_csv.xml \
    tests/planes_telecom_csv.robot
```

2. Abre el reporte en el navegador:

```bash
# Windows (cmd)
start results\report_csv.html

# Windows (PowerShell)
Invoke-Item results\report_csv.html

# macOS
open results/report_csv.html

# Linux
xdg-open results/report_csv.html
```

3. En el reporte, verifica:
   - El número total de tests ejecutados (debe ser **12**).
   - Qué tests pasaron y cuáles fallaron (los casos `invalid` deben pasar si las reglas de negocio están correctas).
   - Los tags asignados: `smoke`, `edge_cases`, `data_driven`, `telecomnova`.

#### Salida esperada

```
==============================================================================
Planes Telecom Csv
==============================================================================
Validar Plan TelecomNova: Plan Básico Prepago — Precio: 9.99 ...    | PASS |
Validar Plan TelecomNova: Plan Familiar Estándar — Precio: 29.99 ...| PASS |
Validar Plan TelecomNova: Plan Profesional Plus — Precio: 49.99 ... | PASS |
Validar Plan TelecomNova: Plan Empresarial Elite — Precio: 99.99 ...| PASS |
Validar Plan TelecomNova: Plan Límite Inferior — Precio: 0.01 ...   | PASS |
Validar Plan TelecomNova: Plan Precio Cero — Precio: 0.00 ...       | PASS |
Validar Plan TelecomNova: Plan Datos Negativos — Precio: 15.00 ...  | PASS |
Validar Plan TelecomNova: Plan Minutos Negativos — Precio: 15.00 ...| PASS |
Validar Plan TelecomNova: Plan Precio Máximo — Precio: 999.99 ...   | PASS |
Validar Plan TelecomNova: Plan Datos Cero GB — Precio: 19.99 ...    | PASS |
Validar Plan TelecomNova: Plan Solo Voz — Precio: 12.50 ...         | PASS |
Validar Plan TelecomNova: Plan Datos Ilimitados — Precio: 79.99 ... | PASS |
------------------------------------------------------------------------------
Planes Telecom Csv                                             | PASS |
12 tests, 12 passed, 0 failed
==============================================================================
```

#### Verificación

Confirma el conteo de tests con `grep` sobre el XML de salida:

```bash
# macOS / Linux
grep -c "<test " results/output_csv.xml

# Windows (PowerShell)
(Select-String -Path results\output_csv.xml -Pattern "<test ").Count
```

El resultado debe ser **12**.

---

### Paso 5 — Ejecutar con filtrado por tags

**Objetivo:** Demostrar la segmentación de ejecuciones usando los tags dinámicos definidos en la columna `test_tag` del CSV.

#### Instrucciones

1. **Ejecutar solo los casos `smoke`** (los 6 casos de validación principal):

```bash
python -m robot \
    --include smoke \
    --outputdir results \
    --log log_smoke.html \
    --report report_smoke.html \
    --output output_smoke.xml \
    tests/planes_telecom_csv.robot
```

2. **Ejecutar solo los casos `edge_cases`** (los 6 casos de límite e inválidos):

```bash
python -m robot \
    --include edge_cases \
    --outputdir results \
    --log log_edge.html \
    --report report_edge.html \
    --output output_edge.xml \
    tests/planes_telecom_csv.robot
```

3. **Excluir los casos inválidos** (ejecutar todo excepto los que tienen `expected_category=invalid`):

```bash
# Primero necesitamos agregar un tag adicional. Modifica el CSV para agregar
# una columna 'invalid_tag' o usa el enfoque de excluir por nombre.
# Como alternativa práctica, ejecuta excluyendo edge_cases:
python -m robot \
    --exclude edge_cases \
    --outputdir results \
    --log log_no_edge.html \
    --report report_no_edge.html \
    tests/planes_telecom_csv.robot
```

#### Salida esperada

- Ejecución con `--include smoke`: **6 tests**, todos PASS.
- Ejecución con `--include edge_cases`: **6 tests**, todos PASS.
- Ejecución con `--exclude edge_cases`: **6 tests** (los mismos que smoke).

```
# Salida esperada para --include smoke:
6 tests, 6 passed, 0 failed

# Salida esperada para --include edge_cases:
6 tests, 6 passed, 0 failed
```

#### Verificación

Abre `results/report_smoke.html` y navega a la sección **Statistics by Tag**. Debes ver únicamente el tag `smoke` con 6 tests y 0 fallos.

---

### Paso 6 — Crear la fuente de datos JSON y la suite variante

**Objetivo:** Implementar la variante JSON para comparar ambos formatos como fuentes de datos en DataDriver.

#### Instrucciones

1. Crea el archivo `resources/data/planes_telecom.json` con el siguiente contenido:

```json
[
    {
        "*** Test Cases ***": "",
        "plan_name": "Plan Básico Prepago",
        "monthly_price": "9.99",
        "data_gb": "1",
        "voice_minutes": "100",
        "expected_category": "basic",
        "test_tag": "smoke"
    },
    {
        "*** Test Cases ***": "",
        "plan_name": "Plan Familiar Estándar",
        "monthly_price": "29.99",
        "data_gb": "10",
        "voice_minutes": "500",
        "expected_category": "standard",
        "test_tag": "smoke"
    },
    {
        "*** Test Cases ***": "",
        "plan_name": "Plan Profesional Plus",
        "monthly_price": "49.99",
        "data_gb": "25",
        "voice_minutes": "1000",
        "expected_category": "premium",
        "test_tag": "smoke"
    },
    {
        "*** Test Cases ***": "",
        "plan_name": "Plan Empresarial Elite",
        "monthly_price": "99.99",
        "data_gb": "100",
        "voice_minutes": "ilimitado",
        "expected_category": "enterprise",
        "test_tag": "smoke"
    },
    {
        "*** Test Cases ***": "",
        "plan_name": "Plan Solo Voz",
        "monthly_price": "12.50",
        "data_gb": "0",
        "voice_minutes": "ilimitado",
        "expected_category": "voice_only",
        "test_tag": "smoke"
    },
    {
        "*** Test Cases ***": "",
        "plan_name": "Plan Datos Ilimitados",
        "monthly_price": "79.99",
        "data_gb": "ilimitado",
        "voice_minutes": "500",
        "expected_category": "premium",
        "test_tag": "smoke"
    }
]
```

2. Crea el archivo `tests/planes_telecom_json.robot`:

```robotframework
*** Settings ***
Documentation    Suite data-driven de validación de planes TelecomNova S.A.
...              Fuente de datos: JSON externo (planes_telecom.json)
...              Comparativa con la suite CSV para evaluar ambos formatos.
...
...              DIFERENCIAS vs CSV:
...              - JSON permite tipos nativos (números sin comillas)
...              - JSON es más legible para estructuras anidadas
...              - CSV es más simple para datos tabulares planos
...              - Ambos formatos son igualmente válidos con DataDriver
Library          DataDriver    ../resources/data/planes_telecom.json
...              encoding=utf-8
Resource         ../resources/keywords/telecom_keywords.resource

Test Template    Validate_Categoria_Del_Plan

*** Test Cases ***
JSON - Validar Plan: ${plan_name} — Precio: ${monthly_price} — Categoría: ${expected_category}
    [Tags]    ${test_tag}    data_driven_json    telecomnova    json_source
    [Documentation]    Test generado desde fuente JSON por DataDriver.
    ${plan_name}    ${monthly_price}    ${data_gb}    ${voice_minutes}
    ...    ${expected_category}
```

3. Ejecuta la suite JSON:

```bash
python -m robot \
    --outputdir results \
    --log log_json.html \
    --report report_json.html \
    --output output_json.xml \
    tests/planes_telecom_json.robot
```

#### Salida esperada

```
==============================================================================
Planes Telecom Json
==============================================================================
JSON - Validar Plan: Plan Básico Prepago — Precio: 9.99 ...    | PASS |
JSON - Validar Plan: Plan Familiar Estándar — Precio: 29.99 ...| PASS |
JSON - Validar Plan: Plan Profesional Plus — Precio: 49.99 ... | PASS |
JSON - Validar Plan: Plan Empresarial Elite — Precio: 99.99 ...| PASS |
JSON - Validar Plan: Plan Solo Voz — Precio: 12.50 ...         | PASS |
JSON - Validar Plan: Plan Datos Ilimitados — Precio: 79.99 ... | PASS |
------------------------------------------------------------------------------
Planes Telecom Json                                            | PASS |
6 tests, 6 passed, 0 failed
==============================================================================
```

#### Verificación

Compara los tiempos de ejecución entre la suite CSV (12 tests) y la JSON (6 tests) revisando los reportes HTML. La diferencia en tiempo debe ser proporcional al número de casos.

---

### Paso 7 — Ejecutar ambas suites combinadas con reporte unificado

**Objetivo:** Generar un único reporte consolidado que integre los resultados de ambas suites (CSV y JSON).

#### Instrucciones

1. Ejecuta ambas suites en un único comando:

```bash
python -m robot \
    --outputdir results \
    --log log_combined.html \
    --report report_combined.html \
    --output output_combined.xml \
    tests/planes_telecom_csv.robot \
    tests/planes_telecom_json.robot
```

2. Revisa las estadísticas por tag en `results/report_combined.html`. Debes ver:

| Tag              | Total | Pass | Fail |
|------------------|-------|------|------|
| `smoke`          | 12    | 12   | 0    |
| `edge_cases`     | 6     | 6    | 0    |
| `data_driven`    | 12    | 12   | 0    |
| `data_driven_json` | 6  | 6    | 0    |
| `telecomnova`    | 18    | 18   | 0    |

#### Salida esperada

```
==============================================================================
Robot Framework
==============================================================================
Planes Telecom Csv                                             | PASS |
12 tests, 12 passed, 0 failed
------------------------------------------------------------------------------
Planes Telecom Json                                            | PASS |
6 tests, 6 passed, 0 failed
------------------------------------------------------------------------------
Robot Framework                                                | PASS |
18 tests, 18 passed, 0 failed
==============================================================================
```

#### Verificación

Abre `results/report_combined.html` y navega a **Statistics by Tag**. Confirma que `telecomnova` muestra **18 tests** en total.

---

## 7. Validación y Pruebas

### Lista de verificación de completitud

Ejecuta los siguientes comandos para validar que el laboratorio está completo:

```bash
# 1. Verificar que existen todos los archivos del proyecto
# Windows (PowerShell)
Get-ChildItem -Recurse -File lab_05_datadriver | Select-Object FullName

# macOS / Linux
find lab_05_datadriver -type f | sort
```

Debes ver al menos estos archivos:
```
lab_05_datadriver/resources/data/planes_telecom.csv
lab_05_datadriver/resources/data/planes_telecom.json
lab_05_datadriver/resources/keywords/telecom_keywords.resource
lab_05_datadriver/tests/planes_telecom_csv.robot
lab_05_datadriver/tests/planes_telecom_json.robot
lab_05_datadriver/results/report_combined.html
lab_05_datadriver/results/log_combined.html
```

```bash
# 2. Verificar conteo de tests en el XML combinado
# macOS / Linux
grep -c "<test " results/output_combined.xml
# Resultado esperado: 18

# Windows (PowerShell)
(Select-String -Path results\output_combined.xml -Pattern "<test ").Count
# Resultado esperado: 18
```

```bash
# 3. Verificar que no hay tests fallidos en el reporte combinado
# macOS / Linux
grep "18 tests, 18 passed, 0 failed" results/output_combined.xml || \
    grep -i "failed>0" results/output_combined.xml

# Windows (PowerShell)
Select-String -Path results\output_combined.xml -Pattern "18 passed"
```

### Prueba de regresión rápida

Para confirmar que el filtrado por tags funciona correctamente en ambas suites:

```bash
# Ejecutar solo smoke en ambas suites
python -m robot \
    --include smoke \
    --outputdir results \
    --output output_smoke_combined.xml \
    tests/planes_telecom_csv.robot \
    tests/planes_telecom_json.robot

# Debe mostrar: 12 tests (6 CSV smoke + 6 JSON smoke), todos PASS
```

---

## 8. Resolución de Problemas

### Problema 1: DataDriver no genera los test cases y el reporte muestra 0 tests

**Síntomas:**
```
==============================================================================
Planes Telecom Csv
==============================================================================
Planes Telecom Csv                                             | PASS |
0 tests, 0 passed, 0 failed
==============================================================================
```
O bien el error: `No module named 'csv_lib'` o `DataDriver: No tests generated from data file`.

**Causa:**
Existen dos causas frecuentes: (a) `robotframework-datadriver` fue instalado **sin** el extra `[CSV]`, por lo que falta el parser de CSV; (b) la ruta al archivo CSV en la declaración `Library DataDriver` es incorrecta (relativa vs. absoluta).

**Solución:**

```bash
# Causa (a) — Reinstalar con el extra CSV
pip uninstall robotframework-datadriver -y
pip install "robotframework-datadriver[CSV]"

# Verificar que el módulo csv_lib está disponible
python -c "from DataDriver.csv_lib import CsvLib; print('CSV support OK')"

# Causa (b) — Verificar la ruta relativa desde el archivo .robot
# El archivo tests/planes_telecom_csv.robot usa:
#   Library    DataDriver    ../resources/data/planes_telecom.csv
# La ruta es relativa al directorio del archivo .robot, NO al directorio
# desde donde se ejecuta robot. Verifica que la ruta sea correcta:
python -m robot --dryrun tests/planes_telecom_csv.robot
```

Si la ruta es el problema, usa una ruta absoluta temporalmente para confirmar:

```robotframework
# En tests/planes_telecom_csv.robot — ruta absoluta para diagnóstico
Library    DataDriver    ${CURDIR}/../resources/data/planes_telecom.csv
```

---

### Problema 2: Los tags del CSV no se aplican correctamente y todos los tests se ejecutan con `--include smoke`

**Síntomas:**
Al ejecutar `python -m robot --include smoke tests/planes_telecom_csv.robot`, se ejecutan los 12 tests en lugar de solo 6. O bien, los tags en el reporte aparecen como literales `${test_tag}` en lugar de `smoke` o `edge_cases`.

**Causa:**
La columna `test_tag` en el CSV tiene un nombre diferente al que se referencia en `[Tags]`, o hay un problema de mayúsculas/minúsculas en el nombre de la columna. DataDriver es sensible al nombre exacto de la columna para la inyección de variables. También puede ocurrir si el CSV tiene espacios adicionales alrededor de los valores.

**Solución:**

```bash
# 1. Verificar el encabezado del CSV (sin espacios extra)
# macOS / Linux
head -1 resources/data/planes_telecom.csv | cat -A
# Busca espacios antes/después de las comas: "test_tag " en lugar de "test_tag"

# Windows (PowerShell)
(Get-Content resources\data\planes_telecom.csv)[0]
```

Si hay espacios, limpia el CSV:

```bash
# macOS / Linux — eliminar espacios alrededor de las comas
sed -i 's/ *, */,/g' resources/data/planes_telecom.csv

# Verificar que el nombre de la variable en el .robot coincide exactamente
# En [Tags] debe ser: [Tags]    ${test_tag}    (minúsculas, sin espacios)
# El encabezado CSV debe ser: test_tag (minúsculas, sin espacios)
```

También verifica que la declaración `[Tags]` en el test case usa exactamente `${test_tag}` y no `${Test_Tag}` u otra variante:

```robotframework
# CORRECTO
[Tags]    ${test_tag}    data_driven    telecomnova

# INCORRECTO (no coincide con el nombre de columna del CSV)
[Tags]    ${Test_Tag}    data_driven    telecomnova
```

---

## 9. Limpieza

### Archivar los resultados del laboratorio

```bash
# Desde la raíz del área de trabajo (fuera de lab_05_datadriver/)

# macOS / Linux — crear archivo comprimido con los resultados
tar -czf lab_05_datadriver_backup.tar.gz lab_05_datadriver/

# Windows (PowerShell) — crear archivo ZIP
Compress-Archive -Path lab_05_datadriver -DestinationPath lab_05_datadriver_backup.zip
```

### Desactivar el entorno virtual

```bash
# Windows (cmd / PowerShell)
deactivate

# macOS / Linux
deactivate
```

### Limpiar los reportes temporales (opcional)

Si deseas conservar solo el reporte combinado y eliminar los intermedios:

```bash
# macOS / Linux
rm -f lab_05_datadriver/results/log_csv.html
rm -f lab_05_datadriver/results/log_smoke.html
rm -f lab_05_datadriver/results/log_edge.html
rm -f lab_05_datadriver/results/log_json.html
rm -f lab_05_datadriver/results/log_no_edge.html
rm -f lab_05_datadriver/results/output_csv.xml
rm -f lab_05_datadriver/results/output_smoke.xml
rm -f lab_05_datadriver/results/output_edge.xml
rm -f lab_05_datadriver/results/output_json.xml

# Windows (PowerShell)
Remove-Item lab_05_datadriver\results\log_csv.html -ErrorAction SilentlyContinue
Remove-Item lab_05_datadriver\results\log_smoke.html -ErrorAction SilentlyContinue
# (repetir para cada archivo)
```

> 💡 **Recomendación:** Conserva siempre `report_combined.html`, `log_combined.html` y `output_combined.xml` como evidencia del laboratorio completado. Estos archivos serán referenciados en el laboratorio del Módulo final (proyecto integrador).

---

## 10. Resumen

### Lo que construiste

En este laboratorio implementaste una suite de pruebas **data-driven completa** para TelecomNova S.A. que demuestra los principios fundamentales de la parametrización externa en Robot Framework:

| Componente                        | Descripción                                                         |
|-----------------------------------|---------------------------------------------------------------------|
| `planes_telecom.csv`              | 12 filas con casos válidos, de límite e inválidos                   |
| `planes_telecom.json`             | Variante JSON con 6 filas para comparación de formatos              |
| `telecom_keywords.resource`       | Keywords en 3 capas: `Get_*`, `Assert_*`, `Validate_*`             |
| `planes_telecom_csv.robot`        | Suite principal con DataDriver + Test Template + tags dinámicos     |
| `planes_telecom_json.robot`       | Suite variante con fuente JSON                                      |
| Ejecución filtrada por tags       | `--include smoke` / `--include edge_cases`                         |
| Reporte unificado                 | 18 tests combinados en un único HTML                               |

### Conceptos clave aplicados

- **DataDriver + Test Template:** La combinación que permite que una única definición de test case genere N casos de prueba, uno por fila del archivo de datos.
- **Tags dinámicos desde CSV:** La columna `test_tag` del CSV se inyecta en `[Tags]` del test case, habilitando la segmentación de ejecuciones sin modificar el código.
- **Arquitectura por capas de keywords:** Los prefijos `Get_*` (capa técnica), `Assert_*` (capa de acción) y `Validate_*` (capa de negocio) refuerzan la separación de responsabilidades y hacen el código mantenible.
- **CSV vs JSON:** Ambos formatos son compatibles con DataDriver. CSV es ideal para datos tabulares planos; JSON es preferible cuando los datos tienen estructura jerárquica o tipos nativos.

### Próximos pasos

El siguiente laboratorio del Módulo 5 introduce **pruebas de API REST con autenticación Bearer** usando `RequestsLibrary`. Las keywords por capas que diseñaste en este laboratorio serán el patrón de referencia para organizar las keywords de API: `Send_*` (técnica), `Verify_*` (acción), `Validate_*` (negocio).

### Referencias adicionales

- [Documentación oficial de robotframework-datadriver](https://github.com/Snooz82/robotframework-datadriver)
- [Robot Framework User Guide — Test Templates](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#test-templates)
- [Robot Framework User Guide — Tags](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#tagging-test-cases)
- [Guía de buenas prácticas de Robot Framework (comunidad)](https://github.com/robotframework/HowToWriteGoodTestCases/blob/master/HowToWriteGoodTestCases.rst)
- [Documentación de BuiltIn Library — Should Be Equal, Convert To Number](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html)

---

---

