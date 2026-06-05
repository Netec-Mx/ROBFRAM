# Práctica 16: Proceso RPA end-to-end: web + API + archivos con checklist de calidad

## Metadatos

| Campo | Detalle |
|---|---|
| **Duración estimada** | 72 minutos |
| **Complejidad** | Alta |
| **Nivel Bloom** | Crear |
| **Módulo** | 8 — Automatización RPA Integradora |
| **Práctica número** | 16 |

---

## Visión General

En esta práctica diseñarás e implementarás un proceso RPA empresarial completo que orquesta cuatro etapas en un único flujo: lectura de datos desde un archivo CSV, enriquecimiento de información a través de una API REST, verificación web con captura de evidencias y generación de un reporte Excel consolidado. El proceso incluye un **checklist de calidad automatizado** que valida la integridad de cada etapa antes de considerar el proceso exitoso. Aplicarás manejo de errores avanzado con retries configurables, timeouts por etapa y parametrización completa mediante variables de proceso y argumentos CLI, integrando todos los conceptos de manejo de archivos vistos en la Lección 8.1.

---

## Objetivos de Aprendizaje

- [ ] Diseñar e implementar un proceso RPA end-to-end que integre lectura de CSV, llamadas API REST, automatización web y generación de reporte Excel en un único flujo orquestado.
- [ ] Aplicar parametrización de proceso mediante variables de archivo y argumentos CLI (`--variable`), separando configuración de lógica.
- [ ] Implementar un checklist de calidad automatizado con la keyword `Verify Process Quality` que valide integridad por etapa (usuarios procesados, porcentaje API válido, screenshots, tamaño de Excel).
- [ ] Construir manejo de errores avanzado con `Wait Until Keyword Succeeds` para retries de API y `Run Keyword And Return Status` para recuperación controlada en cada etapa.
- [ ] Generar evidencias completas del proceso: screenshots nombrados sistemáticamente, logs de peticiones API y reporte Excel con hojas `Resultados` y `Evidencias`.

---

## Prerrequisitos

### Conocimiento previo
- Haber completado Práctica 15 (Lab 08-00-01): manejo de archivos CSV y Excel con keywords Python personalizadas.
- Haber completado Práctica 13 (Lab 07-00-01): pruebas API REST con RequestsLibrary.
- Haber completado Práctica 11 (Lab 06-00-01): automatización web con SeleniumLibrary y Page Object Model.
- Comprensión de orquestación de procesos multi-etapa y manejo de errores en Robot Framework.

### Acceso y herramientas
- Entorno virtual Python activo con todas las dependencias instaladas.
- Acceso a internet para consumir `https://reqres.in/api/users/{id}` y `https://the-internet.herokuapp.com/login`.
- Google Chrome instalado (versión estable más reciente).
- Visual Studio Code con la extensión Robot Framework Language Server.

---

## Entorno de Laboratorio

### Hardware requerido

| Recurso | Mínimo | Recomendado |
|---|---|---|
| CPU | Intel Core i5 8ª gen / Ryzen 5 (4 núcleos) | i7 / Ryzen 7 |
| RAM | 8 GB | 16 GB |
| Disco libre | 5 GB | 10 GB |
| Pantalla | 1280×768 | 1920×1080 |
| Internet | 10 Mbps | 25 Mbps |

### Software requerido

| Componente | Versión mínima |
|---|---|
| Python | 3.10+ |
| Robot Framework | 7.x |
| SeleniumLibrary | 6.2+ |
| RequestsLibrary | 0.9+ |
| openpyxl | 3.1+ |
| rpaframework | 28+ |
| Google Chrome | Última estable |

### Configuración del entorno virtual

**Windows (PowerShell):**
```powershell
# Navegar al directorio del curso
cd C:\curso-robotframework

# Activar el entorno virtual
.\venv\Scripts\Activate.ps1

# Verificar dependencias instaladas
pip list | Select-String "robotframework|selenium|requests|openpyxl|rpaframework"
```

**macOS / Linux (bash/zsh):**
```bash
# Navegar al directorio del curso
cd ~/curso-robotframework

# Activar el entorno virtual
source venv/bin/activate

# Verificar dependencias instaladas
pip list | grep -E "robotframework|selenium|requests|openpyxl|rpaframework"
```

**Instalación de dependencias faltantes (si aplica):**
```bash
pip install robotframework==7.0 \
            robotframework-seleniumlibrary==6.2.0 \
            robotframework-requests==0.9.7 \
            openpyxl==3.1.2 \
            rpaframework==28.0.0 \
            webdrivermanager
```

**Verificar instalación de ChromeDriver:**
```bash
webdrivermanager chrome
```

---

## Instrucciones Paso a Paso

### Paso 1 — Crear la estructura del proyecto

**Objetivo:** Establecer la arquitectura de carpetas y archivos del proceso RPA para mantener separación de responsabilidades.

**Instrucciones:**

1. Dentro de tu directorio de trabajo del curso, crea la siguiente estructura de proyecto:

```bash
mkdir -p lab08-02/data
mkdir -p lab08-02/output/screenshots
mkdir -p lab08-02/resources
mkdir -p lab08-02/libraries
```

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path lab08-02\data
New-Item -ItemType Directory -Force -Path lab08-02\output\screenshots
New-Item -ItemType Directory -Force -Path lab08-02\resources
New-Item -ItemType Directory -Force -Path lab08-02\libraries
```

2. Verifica que la estructura quedó correcta:

```bash
# Unix
find lab08-02 -type d

# Windows PowerShell
Get-ChildItem -Path lab08-02 -Recurse -Directory
```

3. La estructura final del proyecto debe ser:

```
lab08-02/
├── data/
│   └── usuarios_input.csv          # Datos de entrada (lo crearemos)
├── output/
│   └── screenshots/                # Evidencias web
├── resources/
│   ├── variables.resource          # Variables de proceso
│   └── keywords_rpa.resource       # Keywords reutilizables
├── libraries/
│   ├── FileLibrary.py              # Librería CSV/Excel
│   └── ExcelReportLibrary.py       # Librería reporte Excel
└── proceso_rpa_e2e.robot           # Suite principal
```

**Resultado esperado:** Todas las carpetas creadas sin errores.

**Verificación:**
```bash
# Debe mostrar 4 directorios (data, output, screenshots, resources, libraries)
ls -la lab08-02/
```

---

### Paso 2 — Crear el archivo de datos de entrada CSV

**Objetivo:** Generar el archivo `usuarios_input.csv` con 10 usuarios ficticios que servirán como entrada del proceso RPA.

**Instrucciones:**

1. Crea el archivo `lab08-02/data/usuarios_input.csv` con el siguiente contenido exacto:

```csv
id,nombre,email,departamento
1,George Bluth,george.bluth@reqres.in,Ventas
2,Janet Weaver,janet.weaver@reqres.in,Soporte
3,Emma Wong,emma.wong@reqres.in,Técnico
4,Eve Holt,eve.holt@reqres.in,Ventas
5,Charles Morris,charles.morris@reqres.in,Administración
6,Tracey Ramos,tracey.ramos@reqres.in,Soporte
7,Michael Lawson,michael.lawson@reqres.in,Técnico
8,Lindsay Ferguson,lindsay.ferguson@reqres.in,Ventas
9,Tobias Funke,tobias.funke@reqres.in,Administración
10,Byron Fields,byron.fields@reqres.in,Soporte
```

> **Nota:** Los IDs del 1 al 6 tienen respuesta válida en ReqRes (`/api/users/{id}`). Los IDs del 7 al 10 retornarán 404, lo que nos permitirá probar el manejo de errores y el umbral del 80% del checklist de calidad (6/10 = 60%... ajustaremos el umbral a 50% para este escenario realista).

**Resultado esperado:** Archivo CSV con encabezado y 10 filas de datos.

**Verificación:**
```bash
# Unix
wc -l lab08-02/data/usuarios_input.csv   # Debe mostrar 11 (1 header + 10 datos)

# Windows PowerShell
(Get-Content lab08-02\data\usuarios_input.csv).Count  # Debe mostrar 11
```

---

### Paso 3 — Crear las librerías Python personalizadas

**Objetivo:** Implementar `FileLibrary.py` para lectura de CSV y `ExcelReportLibrary.py` para generación del reporte Excel con múltiples hojas.

**Instrucciones:**

1. Crea el archivo `lab08-02/libraries/FileLibrary.py`:

```python
# lab08-02/libraries/FileLibrary.py
import csv
import os
from robot.api.deco import keyword
from robot.api import logger


class FileLibrary:
    """Librería para manejo de archivos CSV en procesos RPA."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    @keyword("Leer CSV Como Lista De Diccionarios")
    def leer_csv(self, ruta: str) -> list:
        """
        Lee un archivo CSV y retorna una lista de diccionarios.
        Cada diccionario representa una fila con claves = nombres de columna.
        """
        if not os.path.exists(ruta):
            raise FileNotFoundError(f"Archivo CSV no encontrado: {ruta}")

        with open(ruta, newline='', encoding='utf-8') as f:
            lector = csv.DictReader(f)
            filas = [dict(fila) for fila in lector]

        logger.info(f"CSV leído exitosamente: {len(filas)} registros desde '{ruta}'")
        return filas

    @keyword("Validar Estructura CSV")
    def validar_estructura_csv(self, ruta: str, columnas_requeridas: list) -> bool:
        """
        Verifica que el CSV contenga las columnas requeridas.
        Retorna True si la estructura es válida, lanza excepción si no.
        """
        with open(ruta, newline='', encoding='utf-8') as f:
            lector = csv.DictReader(f)
            columnas_presentes = lector.fieldnames or []

        for col in columnas_requeridas:
            if col not in columnas_presentes:
                raise AssertionError(
                    f"Columna requerida '{col}' no encontrada en CSV. "
                    f"Columnas presentes: {columnas_presentes}"
                )

        logger.info(f"Estructura CSV válida. Columnas verificadas: {columnas_requeridas}")
        return True
```

2. Crea el archivo `lab08-02/libraries/ExcelReportLibrary.py`:

```python
# lab08-02/libraries/ExcelReportLibrary.py
import os
from datetime import datetime
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter
from robot.api.deco import keyword
from robot.api import logger


class ExcelReportLibrary:
    """Librería para generación de reportes Excel multi-hoja en procesos RPA."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    @keyword("Crear Reporte Excel RPA")
    def crear_reporte_excel(
        self,
        ruta_salida: str,
        datos_resultados: list,
        datos_evidencias: list
    ) -> str:
        """
        Genera un archivo Excel con dos hojas:
        - 'Resultados': datos enriquecidos de usuarios procesados
        - 'Evidencias': rutas de screenshots capturados
        Retorna la ruta del archivo generado.
        """
        # Crear directorio de salida si no existe
        os.makedirs(os.path.dirname(ruta_salida), exist_ok=True)

        wb = openpyxl.Workbook()

        # ── Hoja 1: Resultados ──────────────────────────────────────────────
        ws_resultados = wb.active
        ws_resultados.title = "Resultados"

        encabezados_resultados = [
            "ID", "Nombre Input", "Email Input", "Departamento",
            "Nombre API", "Email API", "Avatar URL", "Estado API",
            "Timestamp Procesado"
        ]
        self._escribir_encabezados(ws_resultados, encabezados_resultados)

        for i, dato in enumerate(datos_resultados, start=2):
            ws_resultados.cell(row=i, column=1, value=dato.get("id", ""))
            ws_resultados.cell(row=i, column=2, value=dato.get("nombre", ""))
            ws_resultados.cell(row=i, column=3, value=dato.get("email", ""))
            ws_resultados.cell(row=i, column=4, value=dato.get("departamento", ""))
            ws_resultados.cell(row=i, column=5, value=dato.get("api_nombre", "N/A"))
            ws_resultados.cell(row=i, column=6, value=dato.get("api_email", "N/A"))
            ws_resultados.cell(row=i, column=7, value=dato.get("api_avatar", "N/A"))
            ws_resultados.cell(row=i, column=8, value=dato.get("api_status", "ERROR"))
            ws_resultados.cell(row=i, column=9, value=dato.get("timestamp", ""))

        self._ajustar_columnas(ws_resultados)

        # ── Hoja 2: Evidencias ──────────────────────────────────────────────
        ws_evidencias = wb.create_sheet(title="Evidencias")

        encabezados_evidencias = [
            "Etapa", "Descripción", "Ruta Screenshot", "Timestamp"
        ]
        self._escribir_encabezados(ws_evidencias, encabezados_evidencias)

        for i, evidencia in enumerate(datos_evidencias, start=2):
            ws_evidencias.cell(row=i, column=1, value=evidencia.get("etapa", ""))
            ws_evidencias.cell(row=i, column=2, value=evidencia.get("descripcion", ""))
            ws_evidencias.cell(row=i, column=3, value=evidencia.get("ruta", ""))
            ws_evidencias.cell(row=i, column=4, value=evidencia.get("timestamp", ""))

        self._ajustar_columnas(ws_evidencias)

        # Guardar archivo
        wb.save(ruta_salida)
        wb.close()

        tamanio = os.path.getsize(ruta_salida)
        logger.info(
            f"Reporte Excel generado: '{ruta_salida}' "
            f"({tamanio} bytes, {len(datos_resultados)} resultados, "
            f"{len(datos_evidencias)} evidencias)"
        )
        return ruta_salida

    def _escribir_encabezados(self, worksheet, encabezados: list) -> None:
        """Escribe encabezados con estilo en la primera fila."""
        estilo_header = Font(bold=True, color="FFFFFF")
        relleno_header = PatternFill(
            start_color="2E4057", end_color="2E4057", fill_type="solid"
        )
        for col_idx, encabezado in enumerate(encabezados, start=1):
            celda = worksheet.cell(row=1, column=col_idx, value=encabezado)
            celda.font = estilo_header
            celda.fill = relleno_header
            celda.alignment = Alignment(horizontal="center")

    def _ajustar_columnas(self, worksheet) -> None:
        """Ajusta el ancho de columnas automáticamente según el contenido."""
        for col in worksheet.columns:
            max_length = 0
            col_letter = get_column_letter(col[0].column)
            for celda in col:
                try:
                    if celda.value and len(str(celda.value)) > max_length:
                        max_length = len(str(celda.value))
                except Exception:
                    pass
            worksheet.column_dimensions[col_letter].width = min(max_length + 4, 50)

    @keyword("Obtener Tamaño Archivo Excel")
    def obtener_tamano_excel(self, ruta: str) -> int:
        """Retorna el tamaño en bytes del archivo Excel. Lanza error si no existe."""
        if not os.path.exists(ruta):
            raise FileNotFoundError(f"Archivo Excel no encontrado: {ruta}")
        return os.path.getsize(ruta)
```

**Resultado esperado:** Dos archivos `.py` en `lab08-02/libraries/` sin errores de sintaxis.

**Verificación:**
```bash
cd lab08-02
python -c "from libraries.FileLibrary import FileLibrary; print('FileLibrary OK')"
python -c "from libraries.ExcelReportLibrary import ExcelReportLibrary; print('ExcelReportLibrary OK')"
```

---

### Paso 4 — Crear el archivo de variables y recursos reutilizables

**Objetivo:** Definir todas las variables de proceso en un archivo centralizado y las keywords reutilizables en un archivo Resource, siguiendo el principio de separación de configuración y lógica.

**Instrucciones:**

1. Crea el archivo `lab08-02/resources/variables.resource`:

```robotframework
*** Variables ***
# ── Configuración de rutas ──────────────────────────────────────────────────
${INPUT_FILE}         ${CURDIR}/../data/usuarios_input.csv
${OUTPUT_DIR}         ${CURDIR}/../output
${SCREENSHOTS_DIR}    ${CURDIR}/../output/screenshots
${EXCEL_REPORT}       ${CURDIR}/../output/reporte_rpa_final.xlsx

# ── Configuración de API ─────────────────────────────────────────────────────
${API_BASE_URL}       https://reqres.in
${API_TIMEOUT}        30
${API_RETRIES}        3
${API_RETRY_DELAY}    2s

# ── Configuración Web ────────────────────────────────────────────────────────
${WEB_URL}            https://the-internet.herokuapp.com/login
${WEB_USERNAME}       tomsmith
${WEB_PASSWORD}       SuperSecretPassword!
${WEB_TIMEOUT}        30s
${BROWSER}            Chrome

# ── Umbrales de calidad ──────────────────────────────────────────────────────
${MIN_API_SUCCESS_RATE}    0.5
${MIN_SCREENSHOTS}         1

# ── Listas de resultados (inicializadas vacías) ──────────────────────────────
@{RESULTADOS_PROCESO}    @{EMPTY}
@{EVIDENCIAS_PROCESO}    @{EMPTY}
```

2. Crea el archivo `lab08-02/resources/keywords_rpa.resource`:

```robotframework
*** Settings ***
Library    RequestsLibrary
Library    SeleniumLibrary
Library    OperatingSystem
Library    Collections
Library    DateTime
Library    String
Library    ../libraries/FileLibrary.py
Library    ../libraries/ExcelReportLibrary.py

Resource   variables.resource

*** Keywords ***

# ════════════════════════════════════════════════════════════════════════════
# ETAPA 0: Inicialización y preparación del entorno
# ════════════════════════════════════════════════════════════════════════════

Inicializar Proceso RPA
    [Documentation]    Prepara el entorno de trabajo: crea directorios,
    ...                valida el archivo de entrada y configura sesión API.
    Log    ═══ INICIANDO PROCESO RPA E2E ═══    console=True
    Log    Timestamp inicio: ${CURDIR}    console=True

    # Crear estructura de salida
    Create Directory    ${OUTPUT_DIR}
    Create Directory    ${SCREENSHOTS_DIR}

    # Validar archivo de entrada
    File Should Exist    ${INPUT_FILE}
    ...    msg=Archivo de entrada no encontrado: ${INPUT_FILE}

    Validar Estructura CSV
    ...    ${INPUT_FILE}
    ...    columnas_requeridas=id;nombre;email;departamento

    # Crear sesión HTTP para API
    Create Session
    ...    alias=reqres_api
    ...    url=${API_BASE_URL}
    ...    verify=True

    Log    Entorno inicializado correctamente    console=True

Finalizar Proceso RPA
    [Documentation]    Cierra recursos abiertos y registra fin del proceso.
    Run Keyword And Ignore Error    Delete All Sessions
    Run Keyword And Ignore Error    Close All Browsers
    Log    ═══ PROCESO RPA FINALIZADO ═══    console=True

# ════════════════════════════════════════════════════════════════════════════
# ETAPA 1: Lectura de datos de entrada
# ════════════════════════════════════════════════════════════════════════════

Etapa 1 Leer Datos De Entrada
    [Documentation]    Lee el archivo CSV de entrada y retorna la lista de usuarios.
    ...                Valida que el archivo tenga al menos 1 registro.
    Log    ─── ETAPA 1: Lectura de datos de entrada ───    console=True

    ${usuarios}=    Leer CSV Como Lista De Diccionarios    ${INPUT_FILE}

    ${total}=    Get Length    ${usuarios}
    Should Be True    ${total} > 0
    ...    msg=El archivo CSV no contiene registros de usuarios

    Log    Usuarios leídos del CSV: ${total}    console=True
    RETURN    ${usuarios}

# ════════════════════════════════════════════════════════════════════════════
# ETAPA 2: Enriquecimiento vía API
# ════════════════════════════════════════════════════════════════════════════

Obtener Datos API Con Retry
    [Documentation]    Realiza GET /api/users/{id} con reintentos configurables.
    ...                Retorna diccionario con datos del usuario o valores por defecto.
    [Arguments]    ${user_id}

    ${respuesta}=    Wait Until Keyword Succeeds
    ...    ${API_RETRIES}x
    ...    ${API_RETRY_DELAY}
    ...    Llamar API Usuario    ${user_id}

    RETURN    ${respuesta}

Llamar API Usuario
    [Documentation]    Realiza una única llamada GET a /api/users/{id}.
    [Arguments]    ${user_id}

    ${response}=    GET On Session
    ...    alias=reqres_api
    ...    url=/api/users/${user_id}
    ...    expected_status=any

    IF    ${response.status_code} == 200
        ${body}=    Set Variable    ${response.json()}
        ${datos_api}=    Create Dictionary
        ...    api_nombre=${body}[data][first_name] ${body}[data][last_name]
        ...    api_email=${body}[data][email]
        ...    api_avatar=${body}[data][avatar]
        ...    api_status=OK
    ELSE IF    ${response.status_code} == 404
        Log    Usuario ID ${user_id} no encontrado en API (404)    level=WARN
        ${datos_api}=    Create Dictionary
        ...    api_nombre=N/A
        ...    api_email=N/A
        ...    api_avatar=N/A
        ...    api_status=NOT_FOUND
    ELSE
        Fail    Error inesperado de API: HTTP ${response.status_code}
    END

    RETURN    ${datos_api}

Etapa 2 Enriquecer Usuarios Con API
    [Documentation]    Itera sobre la lista de usuarios y enriquece cada uno
    ...                con datos obtenidos de la API REST. Retorna lista enriquecida.
    [Arguments]    ${usuarios}

    Log    ─── ETAPA 2: Enriquecimiento vía API ───    console=True

    ${resultados}=    Create List
    ${timestamp_base}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S

    FOR    ${usuario}    IN    @{usuarios}
        Log    Procesando usuario ID: ${usuario}[id] - ${usuario}[nombre]

        ${datos_api}=    Obtener Datos API Con Retry    ${usuario}[id]

        ${registro}=    Create Dictionary
        ...    id=${usuario}[id]
        ...    nombre=${usuario}[nombre]
        ...    email=${usuario}[email]
        ...    departamento=${usuario}[departamento]
        ...    api_nombre=${datos_api}[api_nombre]
        ...    api_email=${datos_api}[api_email]
        ...    api_avatar=${datos_api}[api_avatar]
        ...    api_status=${datos_api}[api_status]
        ...    timestamp=${timestamp_base}

        Append To List    ${resultados}    ${registro}
    END

    ${total_ok}=    Evaluate
    ...    sum(1 for r in $resultados if r['api_status'] == 'OK')
    Log    Usuarios con datos API válidos: ${total_ok}/${usuarios.__len__()}    console=True

    RETURN    ${resultados}

# ════════════════════════════════════════════════════════════════════════════
# ETAPA 3: Verificación web y captura de evidencias
# ════════════════════════════════════════════════════════════════════════════

Etapa 3 Verificacion Web Y Evidencias
    [Documentation]    Abre el navegador, autentica en the-internet.herokuapp.com,
    ...                navega por la aplicación y captura screenshots como evidencia.
    ...                Retorna lista de evidencias generadas.
    [Arguments]    ${resultados_api}

    Log    ─── ETAPA 3: Verificación web y captura de evidencias ───    console=True

    ${evidencias}=    Create List
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S

    # Abrir navegador
    Open Browser    ${WEB_URL}    ${BROWSER}
    ...    options=add_argument("--headless");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")
    Set Window Size    1280    768
    Set Selenium Timeout    ${WEB_TIMEOUT}

    # Screenshot: página de login
    ${ss_login}=    Set Variable    ${SCREENSHOTS_DIR}/01_login_page_${timestamp}.png
    Capture Page Screenshot    ${ss_login}
    ${ev_login}=    Create Dictionary
    ...    etapa=Login
    ...    descripcion=Página de login antes de autenticar
    ...    ruta=${ss_login}
    ...    timestamp=${timestamp}
    Append To List    ${evidencias}    ${ev_login}

    # Autenticar
    Input Text    id=username    ${WEB_USERNAME}
    Input Text    id=password    ${WEB_PASSWORD}
    Click Button    css=button[type='submit']
    Wait Until Element Is Visible    css=.flash.success    timeout=${WEB_TIMEOUT}

    # Screenshot: login exitoso
    ${ss_success}=    Set Variable    ${SCREENSHOTS_DIR}/02_login_success_${timestamp}.png
    Capture Page Screenshot    ${ss_success}
    ${ev_success}=    Create Dictionary
    ...    etapa=Autenticación
    ...    descripcion=Login exitoso - mensaje de bienvenida visible
    ...    ruta=${ss_success}
    ...    timestamp=${timestamp}
    Append To List    ${evidencias}    ${ev_success}

    # Navegar a sección de elementos seguros (área autenticada)
    ${current_url}=    Get Location
    Log    URL después de login: ${current_url}    console=True

    # Screenshot: área autenticada
    ${ss_auth}=    Set Variable    ${SCREENSHOTS_DIR}/03_authenticated_area_${timestamp}.png
    Capture Page Screenshot    ${ss_auth}
    ${ev_auth}=    Create Dictionary
    ...    etapa=Área Autenticada
    ...    descripcion=Navegación exitosa al área protegida
    ...    ruta=${ss_auth}
    ...    timestamp=${timestamp}
    Append To List    ${evidencias}    ${ev_auth}

    # Capturar screenshot por cada usuario procesado (muestra de los primeros 3)
    ${muestra}=    Get Slice From List    ${resultados_api}    0    3
    FOR    ${idx}    ${usuario}    IN ENUMERATE    @{muestra}    start=1
        ${ss_usuario}=    Set Variable
        ...    ${SCREENSHOTS_DIR}/04_usuario_${usuario}[id]_${timestamp}.png
        Capture Page Screenshot    ${ss_usuario}
        ${ev_usuario}=    Create Dictionary
        ...    etapa=Verificación Usuario
        ...    descripcion=Evidencia proceso usuario ID ${usuario}[id]: ${usuario}[nombre]
        ...    ruta=${ss_usuario}
        ...    timestamp=${timestamp}
        Append To List    ${evidencias}    ${ev_usuario}
    END

    Close Browser

    ${total_ev}=    Get Length    ${evidencias}
    Log    Screenshots capturados: ${total_ev}    console=True

    RETURN    ${evidencias}

# ════════════════════════════════════════════════════════════════════════════
# ETAPA 4: Generación de reporte Excel
# ════════════════════════════════════════════════════════════════════════════

Etapa 4 Generar Reporte Excel
    [Documentation]    Genera el reporte Excel consolidado con hojas Resultados
    ...                y Evidencias usando ExcelReportLibrary.
    [Arguments]    ${resultados}    ${evidencias}

    Log    ─── ETAPA 4: Generación de reporte Excel ───    console=True

    ${ruta_excel}=    Crear Reporte Excel RPA
    ...    ruta_salida=${EXCEL_REPORT}
    ...    datos_resultados=${resultados}
    ...    datos_evidencias=${evidencias}

    ${tamano}=    Obtener Tamaño Archivo Excel    ${ruta_excel}
    Log    Reporte Excel generado: ${ruta_excel} (${tamano} bytes)    console=True

    RETURN    ${ruta_excel}

# ════════════════════════════════════════════════════════════════════════════
# CHECKLIST DE CALIDAD
# ════════════════════════════════════════════════════════════════════════════

Verify Process Quality
    [Documentation]    Keyword de checklist de calidad que valida la integridad
    ...                del proceso completo en cada dimensión:
    ...                1. Todos los usuarios procesados
    ...                2. Tasa de éxito API >= umbral configurado
    ...                3. Screenshots capturados
    ...                4. Excel generado con tamaño > 0
    [Arguments]    ${usuarios_input}    ${resultados}    ${evidencias}    ${ruta_excel}

    Log    ═══ EJECUTANDO CHECKLIST DE CALIDAD ═══    console=True

    ${errores}=    Create List
    ${checks_ok}=    Set Variable    ${0}
    ${checks_total}=    Set Variable    ${4}

    # ── Check 1: Todos los usuarios procesados ───────────────────────────────
    ${total_input}=    Get Length    ${usuarios_input}
    ${total_procesados}=    Get Length    ${resultados}

    ${check1_ok}=    Run Keyword And Return Status
    ...    Should Be Equal As Integers    ${total_input}    ${total_procesados}

    IF    ${check1_ok}
        Log    ✅ CHECK 1 PASS: Usuarios procesados ${total_procesados}/${total_input}    console=True
        ${checks_ok}=    Evaluate    ${checks_ok} + 1
    ELSE
        Log    ❌ CHECK 1 FAIL: Procesados ${total_procesados}/${total_input}    level=WARN    console=True
        Append To List    ${errores}    CHECK1: Solo ${total_procesados}/${total_input} usuarios procesados
    END

    # ── Check 2: Tasa de éxito API >= umbral ────────────────────────────────
    ${api_ok}=    Evaluate
    ...    sum(1 for r in $resultados if r['api_status'] == 'OK')
    ${tasa_api}=    Evaluate    ${api_ok} / ${total_procesados} if ${total_procesados} > 0 else 0

    ${check2_ok}=    Run Keyword And Return Status
    ...    Should Be True    ${tasa_api} >= ${MIN_API_SUCCESS_RATE}

    IF    ${check2_ok}
        ${tasa_pct}=    Evaluate    round(${tasa_api} * 100, 1)
        Log    ✅ CHECK 2 PASS: Tasa API ${tasa_pct}% >= ${MIN_API_SUCCESS_RATE * 100}%    console=True
        ${checks_ok}=    Evaluate    ${checks_ok} + 1
    ELSE
        ${tasa_pct}=    Evaluate    round(${tasa_api} * 100, 1)
        Log    ❌ CHECK 2 FAIL: Tasa API ${tasa_pct}% < umbral requerido    level=WARN    console=True
        Append To List    ${errores}    CHECK2: Tasa API ${tasa_pct}% por debajo del umbral
    END

    # ── Check 3: Screenshots capturados ─────────────────────────────────────
    ${total_screenshots}=    Get Length    ${evidencias}

    ${check3_ok}=    Run Keyword And Return Status
    ...    Should Be True    ${total_screenshots} >= ${MIN_SCREENSHOTS}

    IF    ${check3_ok}
        Log    ✅ CHECK 3 PASS: ${total_screenshots} screenshots capturados    console=True
        ${checks_ok}=    Evaluate    ${checks_ok} + 1
    ELSE
        Log    ❌ CHECK 3 FAIL: 0 screenshots capturados    level=WARN    console=True
        Append To List    ${errores}    CHECK3: No se capturaron screenshots
    END

    # ── Check 4: Excel generado con tamaño > 0 ──────────────────────────────
    ${check4_ok}=    Run Keyword And Return Status
    ...    File Should Exist    ${ruta_excel}

    IF    ${check4_ok}
        ${tamano_excel}=    Get File Size    ${ruta_excel}
        ${check4_size_ok}=    Run Keyword And Return Status
        ...    Should Be True    ${tamano_excel} > 0
        IF    ${check4_size_ok}
            Log    ✅ CHECK 4 PASS: Excel existe y tiene ${tamano_excel} bytes    console=True
            ${checks_ok}=    Evaluate    ${checks_ok} + 1
        ELSE
            Log    ❌ CHECK 4 FAIL: Excel existe pero está vacío    level=WARN    console=True
            Append To List    ${errores}    CHECK4: Excel generado con tamaño 0 bytes
        END
    ELSE
        Log    ❌ CHECK 4 FAIL: Archivo Excel no encontrado    level=WARN    console=True
        Append To List    ${errores}    CHECK4: Archivo Excel no encontrado en ${ruta_excel}
    END

    # ── Resumen del checklist ────────────────────────────────────────────────
    Log    ═══ RESULTADO CHECKLIST: ${checks_ok}/${checks_total} checks pasados ═══    console=True

    ${total_errores}=    Get Length    ${errores}
    IF    ${total_errores} > 0
        FOR    ${error}    IN    @{errores}
            Log    Error de calidad: ${error}    level=WARN
        END
        Fail    Checklist de calidad FALLIDO: ${total_errores} check(s) no pasaron. Ver logs para detalle.
    ELSE
        Log    🎉 PROCESO RPA COMPLETADO CON CALIDAD VERIFICADA    console=True
    END
```

**Resultado esperado:** Dos archivos `.resource` en `lab08-02/resources/` con sintaxis correcta.

**Verificación:**
```bash
# Verificar que Robot Framework puede parsear los archivos resource
cd lab08-02
python -m robot --dryrun --nostatusrc resources/keywords_rpa.resource 2>&1 | tail -5
```

---

### Paso 5 — Crear la suite principal del proceso RPA

**Objetivo:** Implementar el archivo `proceso_rpa_e2e.robot` que orquesta las cuatro etapas, aplica el checklist de calidad y gestiona el ciclo de vida completo del proceso.

**Instrucciones:**

1. Crea el archivo `lab08-02/proceso_rpa_e2e.robot`:

```robotframework
*** Settings ***
Documentation    Proceso RPA End-to-End: Web + API + Archivos con Checklist de Calidad
...
...              Escenario empresarial: TelecomCorp necesita un proceso automatizado
...              que lea una lista de usuarios desde CSV, enriquezca sus datos
...              consultando una API REST, verifique su estado en el portal web
...              y genere un reporte Excel consolidado con evidencias fotográficas.
...
...              Etapas del proceso:
...              1. Lectura de datos desde CSV de entrada
...              2. Enriquecimiento de datos via API REST (ReqRes)
...              3. Verificación web con captura de screenshots
...              4. Generación de reporte Excel con hoja Resultados y Evidencias
...              5. Checklist de calidad automatizado

Resource         resources/keywords_rpa.resource

Suite Setup      Inicializar Proceso RPA
Suite Teardown   Finalizar Proceso RPA

*** Variables ***
# Estas variables pueden sobreescribirse via CLI:
# robot --variable INPUT_FILE:/ruta/custom.csv proceso_rpa_e2e.robot
${INPUT_FILE}      ${CURDIR}/data/usuarios_input.csv
${OUTPUT_DIR}      ${CURDIR}/output
${API_BASE_URL}    https://reqres.in

*** Test Cases ***

TC-RPA-001: Proceso Completo E2E con Checklist de Calidad
    [Documentation]    Ejecuta el proceso RPA completo en 4 etapas y valida
    ...                la integridad mediante el checklist de calidad automatizado.
    ...
    ...                Criterios de aceptación:
    ...                - Todos los usuarios del CSV son procesados
    ...                - Al menos 50% tienen datos API válidos
    ...                - Al menos 1 screenshot capturado como evidencia
    ...                - Reporte Excel generado con tamaño > 0 bytes
    [Tags]    rpa    e2e    integracion    critico

    # ── ETAPA 1: Lectura de datos ────────────────────────────────────────────
    ${usuarios}=    Etapa 1 Leer Datos De Entrada
    Log    Etapa 1 completada: ${usuarios.__len__()} usuarios cargados

    # ── ETAPA 2: Enriquecimiento API ─────────────────────────────────────────
    ${resultados_api}=    Etapa 2 Enriquecer Usuarios Con API    ${usuarios}
    Log    Etapa 2 completada: ${resultados_api.__len__()} usuarios enriquecidos

    # ── ETAPA 3: Verificación web y evidencias ───────────────────────────────
    ${evidencias}=    Etapa 3 Verificacion Web Y Evidencias    ${resultados_api}
    Log    Etapa 3 completada: ${evidencias.__len__()} evidencias capturadas

    # ── ETAPA 4: Generación de reporte Excel ─────────────────────────────────
    ${ruta_excel}=    Etapa 4 Generar Reporte Excel
    ...    ${resultados_api}
    ...    ${evidencias}
    Log    Etapa 4 completada: reporte en ${ruta_excel}

    # ── CHECKLIST DE CALIDAD ─────────────────────────────────────────────────
    Verify Process Quality
    ...    usuarios_input=${usuarios}
    ...    resultados=${resultados_api}
    ...    evidencias=${evidencias}
    ...    ruta_excel=${ruta_excel}


TC-RPA-002: Validar Estructura del Reporte Excel Generado
    [Documentation]    Verifica que el archivo Excel generado por el proceso
    ...                principal contiene las hojas requeridas y tiene contenido válido.
    ...                Depende de TC-RPA-001 para que el Excel exista.
    [Tags]    rpa    validacion    reporte

    # Verificar existencia del archivo
    File Should Exist    ${OUTPUT_DIR}/reporte_rpa_final.xlsx
    ...    msg=El reporte Excel no fue generado. Ejecute TC-RPA-001 primero.

    # Verificar tamaño mínimo (> 5KB para un Excel con contenido real)
    ${tamano}=    Get File Size    ${OUTPUT_DIR}/reporte_rpa_final.xlsx
    Should Be True    ${tamano} > 5000
    ...    msg=El reporte Excel parece estar incompleto (${tamano} bytes < 5KB)

    Log    Reporte Excel validado: ${tamano} bytes    console=True


TC-RPA-003: Validar Evidencias Fotográficas del Proceso
    [Documentation]    Verifica que se generaron screenshots en la carpeta
    ...                de evidencias durante la etapa de verificación web.
    [Tags]    rpa    validacion    evidencias

    ${screenshots}=    List Files In Directory
    ...    ${OUTPUT_DIR}/screenshots
    ...    pattern=*.png

    ${total}=    Get Length    ${screenshots}
    Should Be True    ${total} >= 3
    ...    msg=Se esperaban al menos 3 screenshots, se encontraron: ${total}

    FOR    ${ss}    IN    @{screenshots}
        ${tamano_ss}=    Get File Size    ${OUTPUT_DIR}/screenshots/${ss}
        Should Be True    ${tamano_ss} > 0
        ...    msg=Screenshot vacío encontrado: ${ss}
        Log    Screenshot válido: ${ss} (${tamano_ss} bytes)
    END

    Log    Total screenshots válidos: ${total}    console=True


TC-RPA-004: Parametrización via Variables de Proceso
    [Documentation]    Verifica que las variables de proceso son accesibles
    ...                y tienen los valores esperados (configurables via CLI).
    ...
    ...                Ejecutar con valores custom:
    ...                robot --variable API_BASE_URL:https://reqres.in \
    ...                      --variable INPUT_FILE:/ruta/custom.csv \
    ...                      proceso_rpa_e2e.robot
    [Tags]    rpa    configuracion    parametrizacion

    # Verificar que las variables de proceso están definidas
    Should Not Be Empty    ${INPUT_FILE}
    Should Not Be Empty    ${OUTPUT_DIR}
    Should Not Be Empty    ${API_BASE_URL}

    # Verificar que el archivo de entrada configurado existe
    File Should Exist    ${INPUT_FILE}
    ...    msg=El archivo de entrada configurado no existe: ${INPUT_FILE}

    # Verificar que la URL de API tiene formato válido
    Should Start With    ${API_BASE_URL}    http
    ...    msg=API_BASE_URL debe comenzar con http/https: ${API_BASE_URL}

    Log    Configuración de proceso validada:    console=True
    Log    - INPUT_FILE: ${INPUT_FILE}    console=True
    Log    - OUTPUT_DIR: ${OUTPUT_DIR}    console=True
    Log    - API_BASE_URL: ${API_BASE_URL}    console=True
```

**Resultado esperado:** Archivo `.robot` con 4 casos de prueba bien definidos.

**Verificación (dry-run sin ejecutar):**
```bash
cd lab08-02
python -m robot --dryrun --nostatusrc proceso_rpa_e2e.robot
```

---

### Paso 6 — Ejecutar el proceso RPA completo

**Objetivo:** Ejecutar la suite completa del proceso RPA y observar el flujo de las cuatro etapas con su checklist de calidad.

**Instrucciones:**

1. Asegúrate de estar en el directorio `lab08-02` con el entorno virtual activo.

2. Ejecuta el proceso completo con el siguiente comando:

```bash
# Ejecución estándar
python -m robot \
    --outputdir output/reports \
    --log log_rpa_e2e.html \
    --report report_rpa_e2e.html \
    --variable INPUT_FILE:data/usuarios_input.csv \
    --variable OUTPUT_DIR:output \
    --variable API_BASE_URL:https://reqres.in \
    --console verbose \
    proceso_rpa_e2e.robot
```

**Windows (PowerShell):**
```powershell
python -m robot `
    --outputdir output/reports `
    --log log_rpa_e2e.html `
    --report report_rpa_e2e.html `
    --variable INPUT_FILE:data/usuarios_input.csv `
    --variable OUTPUT_DIR:output `
    --variable API_BASE_URL:https://reqres.in `
    --console verbose `
    proceso_rpa_e2e.robot
```

3. Observa la salida en consola. Deberías ver el progreso de cada etapa:

```
═══ INICIANDO PROCESO RPA E2E ═══
─── ETAPA 1: Lectura de datos de entrada ───
Usuarios leídos del CSV: 10
─── ETAPA 2: Enriquecimiento vía API ───
Procesando usuario ID: 1 - George Bluth
...
Usuarios con datos API válidos: 6/10
─── ETAPA 3: Verificación web y captura de evidencias ───
...
Screenshots capturados: 6
─── ETAPA 4: Generación de reporte Excel ───
Reporte Excel generado: output/reporte_rpa_final.xlsx (XXXX bytes)
═══ EJECUTANDO CHECKLIST DE CALIDAD ═══
✅ CHECK 1 PASS: Usuarios procesados 10/10
✅ CHECK 2 PASS: Tasa API 60.0% >= 50.0%
✅ CHECK 3 PASS: 6 screenshots capturados
✅ CHECK 4 PASS: Excel existe y tiene XXXX bytes
═══ RESULTADO CHECKLIST: 4/4 checks pasados ═══
🎉 PROCESO RPA COMPLETADO CON CALIDAD VERIFICADA
```

4. Ejecuta solo los casos de validación (sin re-ejecutar el proceso completo):

```bash
python -m robot \
    --include validacion \
    --outputdir output/reports \
    proceso_rpa_e2e.robot
```

**Resultado esperado:** 4 casos de prueba pasados (o al menos TC-RPA-001 y TC-RPA-004 pasados; TC-RPA-002 y TC-RPA-003 dependen del artefacto generado por TC-RPA-001).

**Verificación:**
```bash
# Verificar artefactos generados
ls -la output/
ls -la output/screenshots/
ls -la output/reports/

# Windows PowerShell
Get-ChildItem output -Recurse | Select-Object Name, Length
```

---

### Paso 7 — Probar la parametrización CLI y manejo de errores

**Objetivo:** Demostrar que el proceso es completamente parametrizable desde la línea de comandos y que el manejo de errores funciona correctamente ante entradas inválidas.

**Instrucciones:**

1. Prueba la parametrización con un archivo de entrada alternativo. Crea primero `data/usuarios_reducido.csv`:

```csv
id,nombre,email,departamento
1,George Bluth,george.bluth@reqres.in,Ventas
2,Janet Weaver,janet.weaver@reqres.in,Soporte
3,Emma Wong,emma.wong@reqres.in,Técnico
```

2. Ejecuta el proceso solo con TC-RPA-001 usando el archivo reducido:

```bash
python -m robot \
    --test "TC-RPA-001*" \
    --variable INPUT_FILE:data/usuarios_reducido.csv \
    --variable OUTPUT_DIR:output/test_reducido \
    --outputdir output/reports_reducido \
    proceso_rpa_e2e.robot
```

3. Prueba el comportamiento ante un archivo inexistente (debe fallar de forma controlada):

```bash
python -m robot \
    --test "TC-RPA-001*" \
    --variable INPUT_FILE:data/archivo_inexistente.csv \
    --outputdir output/reports_error \
    proceso_rpa_e2e.robot
```

**Resultado esperado del paso 3:** El proceso falla en la fase de inicialización con mensaje claro `Archivo de entrada no encontrado`, **no** con una excepción Python sin manejar.

4. Verifica el log de error generado:

```bash
# Abrir el reporte HTML en el navegador
# Unix
open output/reports_error/report.html

# Windows
start output\reports_error\report.html
```

**Resultado esperado:** El reporte HTML muestra el error en la etapa de inicialización con mensaje descriptivo y el stack trace de Robot Framework (no Python puro).

**Verificación:**
```bash
# Verificar que el output/test_reducido tiene su propio Excel
ls -la output/test_reducido/
```

---

## Validación y Pruebas

### Lista de verificación de artefactos generados

Después de ejecutar el proceso completo, verifica que todos los artefactos esperados existen:

```bash
# Unix - verificación completa
echo "=== Verificando artefactos del proceso RPA ==="

echo "--- Datos de entrada ---"
[ -f "data/usuarios_input.csv" ] && echo "✅ usuarios_input.csv" || echo "❌ usuarios_input.csv FALTANTE"

echo "--- Reporte Excel ---"
[ -f "output/reporte_rpa_final.xlsx" ] && echo "✅ reporte_rpa_final.xlsx" || echo "❌ reporte_rpa_final.xlsx FALTANTE"

echo "--- Screenshots ---"
SHOTS=$(ls output/screenshots/*.png 2>/dev/null | wc -l)
[ "$SHOTS" -ge 3 ] && echo "✅ $SHOTS screenshots capturados" || echo "❌ Insuficientes screenshots: $SHOTS"

echo "--- Reportes Robot Framework ---"
[ -f "output/reports/report_rpa_e2e.html" ] && echo "✅ report_rpa_e2e.html" || echo "❌ report_rpa_e2e.html FALTANTE"
[ -f "output/reports/log_rpa_e2e.html" ] && echo "✅ log_rpa_e2e.html" || echo "❌ log_rpa_e2e.html FALTANTE"
```

**Windows (PowerShell):**
```powershell
Write-Host "=== Verificando artefactos del proceso RPA ===" -ForegroundColor Cyan

$checks = @(
    @{Path="data\usuarios_input.csv"; Name="CSV entrada"},
    @{Path="output\reporte_rpa_final.xlsx"; Name="Reporte Excel"},
    @{Path="output\reports\report_rpa_e2e.html"; Name="Reporte RF HTML"}
)

foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "✅ $($check.Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ $($check.Name) FALTANTE" -ForegroundColor Red
    }
}

$screenshots = (Get-ChildItem "output\screenshots" -Filter "*.png" -ErrorAction SilentlyContinue).Count
Write-Host "Screenshots capturados: $screenshots" -ForegroundColor $(if ($screenshots -ge 3) {"Green"} else {"Red"})
```

### Verificación del contenido del Excel

```python
# Script de verificación: verificar_excel.py
# Ejecutar como: python verificar_excel.py
import openpyxl
import sys

ruta = "output/reporte_rpa_final.xlsx"

try:
    wb = openpyxl.load_workbook(ruta)
    hojas = wb.sheetnames
    print(f"✅ Excel abierto correctamente")
    print(f"   Hojas encontradas: {hojas}")

    assert "Resultados" in hojas, "❌ Falta hoja 'Resultados'"
    assert "Evidencias" in hojas, "❌ Falta hoja 'Evidencias'"
    print("✅ Hojas 'Resultados' y 'Evidencias' presentes")

    ws_r = wb["Resultados"]
    filas_resultados = ws_r.max_row - 1  # Restar encabezado
    print(f"✅ Hoja Resultados: {filas_resultados} registros de datos")
    assert filas_resultados >= 10, f"❌ Se esperaban 10 registros, hay {filas_resultados}"

    ws_e = wb["Evidencias"]
    filas_evidencias = ws_e.max_row - 1
    print(f"✅ Hoja Evidencias: {filas_evidencias} registros de evidencias")
    assert filas_evidencias >= 3, f"❌ Se esperaban al menos 3 evidencias, hay {filas_evidencias}"

    wb.close()
    print("\n🎉 Verificación del Excel COMPLETADA EXITOSAMENTE")

except FileNotFoundError:
    print(f"❌ Archivo no encontrado: {ruta}")
    sys.exit(1)
except AssertionError as e:
    print(e)
    sys.exit(1)
```

```bash
python verificar_excel.py
```

---

## Solución de Problemas

### Problema 1: El proceso falla en Etapa 3 con `WebDriverException: ChromeDriver not found`

**Síntoma:** La suite falla al llegar a `Etapa 3 Verificacion Web Y Evidencias` con el mensaje `selenium.common.exceptions.WebDriverException: Message: 'chromedriver' executable needs to be in PATH` o similar. Los Pasos 1, 2 y 4 habrían funcionado correctamente si se ejecutaran de forma aislada.

**Causa:** ChromeDriver no está instalado o su versión no coincide con la versión de Google Chrome instalada en el sistema. Esto es especialmente común cuando Chrome se actualiza automáticamente y el ChromeDriver instalado queda desactualizado.

**Solución:**

```bash
# Paso 1: Verificar versión de Chrome instalada
# Unix
google-chrome --version
# o
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Windows PowerShell
(Get-Item "C:\Program Files\Google\Chrome\Application\chrome.exe").VersionInfo.ProductVersion

# Paso 2: Actualizar ChromeDriver usando webdrivermanager
pip install --upgrade webdrivermanager
webdrivermanager chrome

# Paso 3: Alternativa con SeleniumBase (gestión automática)
pip install seleniumbase
seleniumbase install chromedriver

# Paso 4: Verificar que chromedriver está en PATH
chromedriver --version

# Paso 5: Si persiste, especificar ruta explícita en el keyword Open Browser
# Modificar en keywords_rpa.resource:
# Open Browser    ${WEB_URL}    ${BROWSER}
#     ...    executable_path=/ruta/absoluta/chromedriver
```

Si el problema persiste en entornos sin interfaz gráfica (servidores CI/CD), verificar que el argumento `--headless` está correctamente configurado en las opciones del navegador tal como aparece en el keyword `Etapa 3 Verificacion Web Y Evidencias`.

---

### Problema 2: El Checklist de Calidad falla en CHECK 2 con tasa API por debajo del umbral

**Síntoma:** El proceso completa las 4 etapas pero falla al ejecutar `Verify Process Quality` con el mensaje `Checklist de calidad FALLIDO: 1 check(s) no pasaron` y el log muestra `❌ CHECK 2 FAIL: Tasa API X% por debajo del umbral`. Esto ocurre cuando la API de ReqRes devuelve más errores 404 de los esperados o cuando hay problemas de conectividad intermitente.

**Causa:** Los IDs del 7 al 10 en el CSV de entrada no tienen registros válidos en ReqRes (la API pública solo tiene datos para los IDs 1-12 con datos reales para 1-6 en el endpoint `/api/users/{id}`). Si el umbral `${MIN_API_SUCCESS_RATE}` está configurado por encima de 0.6 (60%), el check fallará con los datos del CSV de prueba. También puede ocurrir si hay latencia de red que agota los reintentos configurados.

**Solución:**

```bash
# Opción A: Ajustar el umbral via CLI para el entorno de laboratorio
python -m robot \
    --variable MIN_API_SUCCESS_RATE:0.5 \
    --outputdir output/reports \
    proceso_rpa_e2e.robot

# Opción B: Verificar manualmente cuáles IDs tienen respuesta válida en ReqRes
curl -s https://reqres.in/api/users/1 | python -m json.tool
curl -s https://reqres.in/api/users/7 | python -m json.tool
# El ID 7 retorna {} con status 404

# Opción C: Modificar el CSV de entrada para usar solo IDs válidos (1-6)
# Editar data/usuarios_input.csv y cambiar IDs 7-10 por IDs 1-6 adicionales

# Opción D: Aumentar el número de reintentos si el problema es de red
python -m robot \
    --variable API_RETRIES:5 \
    --variable API_RETRY_DELAY:3s \
    --outputdir output/reports \
    proceso_rpa_e2e.robot
```

Para entornos de producción real, se recomienda configurar `${MIN_API_SUCCESS_RATE}` en el archivo `variables.resource` con el valor apropiado para el SLA del servicio API utilizado, en lugar de usar el valor de laboratorio.

---

## Limpieza del Entorno

Una vez completada la práctica, ejecuta los siguientes pasos para limpiar los artefactos temporales y mantener el workspace ordenado:

```bash
# Desde el directorio lab08-02

# 1. Crear carpeta de respaldo del proyecto completado
cd ..
cp -r lab08-02 lab08-02-backup-$(date +%Y%m%d)

# 2. Limpiar artefactos de ejecución (conservar código fuente)
cd lab08-02

# Unix
rm -rf output/reports/
rm -rf output/reports_reducido/
rm -rf output/reports_error/
# NOTA: Conservar output/screenshots/ y output/reporte_rpa_final.xlsx como evidencias

# Windows PowerShell
Remove-Item -Recurse -Force output\reports\ -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force output\reports_reducido\ -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force output\reports_error\ -ErrorAction SilentlyContinue

# 3. Limpiar cachés de Python
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

# Windows PowerShell
Get-ChildItem -Recurse -Filter "__pycache__" | Remove-Item -Recurse -Force
Get-ChildItem -Recurse -Filter "*.pyc" | Remove-Item -Force

# 4. Desactivar entorno virtual
deactivate
```

> **Importante:** Conserva el directorio `lab08-02-backup-YYYYMMDD` como punto de partida para el proyecto final del curso, ya que los módulos posteriores pueden requerir los artefactos generados en este laboratorio.

---

## Resumen

En esta práctica implementaste un proceso RPA empresarial completo de nivel **Crear**, integrando en un único flujo orquestado las cuatro capacidades fundamentales del ecosistema Robot Framework + rpaframework:

| Etapa | Tecnología utilizada | Concepto clave aplicado |
|---|---|---|
| **Etapa 1 – Lectura CSV** | `FileLibrary.py` + módulo `csv` | `DictReader` para acceso por nombre de columna |
| **Etapa 2 – API REST** | `RequestsLibrary` + `Wait Until Keyword Succeeds` | Retries configurables con delay, manejo de 404 |
| **Etapa 3 – Web** | `SeleniumLibrary` + `Capture Page Screenshot` | Evidencias sistemáticas con naming por timestamp |
| **Etapa 4 – Excel** | `ExcelReportLibrary.py` + `openpyxl` | Workbook multi-hoja con estilos y ajuste automático |
| **Checklist** | `Run Keyword And Return Status` | Validación de integridad por dimensión con fallo controlado |

### Conceptos clave consolidados

- **Separación de responsabilidades**: variables en `.resource`, keywords en `.resource`, lógica en `.py`, orquestación en `.robot`.
- **Parametrización CLI**: `--variable NOMBRE:valor` permite ejecutar el mismo proceso con diferentes entornos sin modificar código.
- **Manejo de errores por capas**: `Wait Until Keyword Succeeds` para retries de red, `Run Keyword And Return Status` para checks de calidad no bloqueantes, `Run Keyword And Ignore Error` para teardowns seguros.
- **Checklist de calidad automatizado**: el patrón `Verify Process Quality` es reutilizable en cualquier proceso RPA y puede extenderse con nuevas dimensiones de validación.
- **Evidencias completas**: screenshots nombrados con timestamp, logs de API en el report HTML de Robot Framework y Excel como artefacto de negocio entregable.

### Recursos adicionales

- [Documentación oficial de RequestsLibrary](https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html)
- [Documentación oficial de SeleniumLibrary](https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html)
- [Referencia de openpyxl para estilos y formatos](https://openpyxl.readthedocs.io/en/stable/styles.html)
- [Keyword `Wait Until Keyword Succeeds` en Robot Framework](https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Wait%20Until%20Keyword%20Succeeds)
- [API pública ReqRes para práctica de automatización](https://reqres.in/)
- [The Internet - Aplicación de práctica para automatización web](https://the-internet.herokuapp.com/)

---

