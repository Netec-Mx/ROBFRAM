---LAB_START---
LAB_ID: 08-00-01
---MARKDOWN---
# Proceso RPA con lectura de Excel, transformación y generación de reporte PDF

## Metadatos

| Campo | Detalle |
|---|---|
| **Duración estimada** | 72 minutos |
| **Complejidad** | Alta (Hard) |
| **Nivel Bloom** | Crear (Create) |
| **Módulo** | 8 — Automatización RPA con Robot Framework |
| **Práctica** | 15 |

---

## Descripción General

En este laboratorio construirás un proceso RPA completo que simula el flujo de trabajo mensual de una empresa ficticia de telecomunicaciones: **TelecomSur S.A.** El robot leerá un archivo Excel con registros de ventas, aplicará transformaciones de datos (filtrado, cálculos de totales y agrupación por región), y generará un reporte PDF ejecutivo con métricas clave. A lo largo del proceso implementarás manejo robusto de errores con reintentos, registro de filas rechazadas y trazabilidad completa mediante logs estructurados. Este laboratorio integra los conceptos de la Lección 8.1 sobre manejo de archivos CSV, Excel, PDF y gestión de carpetas dentro de un flujo RPA orquestado.

---

## Objetivos de Aprendizaje

Al finalizar este laboratorio serás capaz de:

- [ ] Leer un archivo `.xlsx` con datos de ventas usando una keyword Python personalizada basada en `openpyxl`, accediendo a filas como lista de diccionarios.
- [ ] Aplicar transformaciones de datos en Robot Framework: filtrar filas inválidas, calcular campos derivados (`total_venta`) y agrupar resultados por región con subtotales.
- [ ] Generar un reporte PDF estructurado desde una plantilla HTML usando `RPA.PDF`, incluyendo tabla de resultados y métricas ejecutivas.
- [ ] Implementar manejo de errores con `Run Keyword And Continue On Failure`, reintentos y registro de filas rechazadas en archivo separado.
- [ ] Gestionar la estructura de carpetas del proceso con `OperatingSystem` y producir logs estructurados con niveles `INFO`, `WARN` y `ERROR`.

---

## Prerrequisitos

### Conocimiento Previo

- Haber completado los Módulos 1 al 5 del curso (keywords, variables, suites, ResourceFiles, DataDriver).
- Comprensión de estructuras de datos Python: listas y diccionarios.
- Familiaridad con el patrón de keyword Python personalizada (`robot.api.deco`).
- Haber leído la Lección 8.1 sobre manejo de archivos en Robot Framework.

### Acceso y Herramientas

- Entorno virtual Python activo con `rpaframework` y `openpyxl` instalados.
- VS Code con extensión **RobotCode** (Robot Framework Language Server) configurada.
- Permisos de escritura en el directorio del proyecto.
- Conexión a internet no requerida durante la ejecución (todo es local).

---

## Entorno de Laboratorio

### Hardware Recomendado

| Componente | Mínimo | Recomendado |
|---|---|---|
| Procesador | Intel Core i5 8ª gen / Ryzen 5 | Intel Core i7 / Ryzen 7 |
| RAM | 8 GB | 16 GB |
| Almacenamiento libre | 5 GB | 10 GB |
| Resolución pantalla | 1280×768 | 1920×1080 |

### Software Requerido

| Paquete | Versión mínima | Instalación |
|---|---|---|
| Python | 3.10+ | Sistema operativo |
| Robot Framework | 6.1+ | `pip install robotframework` |
| rpaframework | 28+ | `pip install rpaframework` |
| openpyxl | 3.1+ | `pip install openpyxl` |
| VS Code + RobotCode | 1.85+ / 1.12+ | marketplace |

### Preparación del Entorno Virtual

> ⚠️ **OBLIGATORIO**: Activa el entorno virtual antes de comenzar. Todos los comandos deben ejecutarse dentro del `venv`.

**Crear y activar el entorno virtual:**

```bash
# Crear el entorno virtual (solo la primera vez)
python -m venv venv

# Activar en Windows (cmd)
venv\Scripts\activate.bat

# Activar en Windows (PowerShell)
venv\Scripts\Activate.ps1

# Activar en macOS/Linux
source venv/bin/activate
```

**Instalar dependencias:**

```bash
pip install robotframework rpaframework openpyxl
```

**Verificar instalaciones:**

```bash
python -m robot --version
python -c "import openpyxl; print('openpyxl:', openpyxl.__version__)"
python -c "from RPA.Excel.Files import Files; print('RPA.Excel.Files OK')"
python -c "from RPA.PDF import PDF; print('RPA.PDF OK')"
```

**Salida esperada de verificación:**

```
Robot Framework 6.1.1 (Python 3.10.x ...)
openpyxl: 3.1.x
RPA.Excel.Files OK
RPA.PDF OK
```

---

## Pasos del Laboratorio

### Paso 1: Crear la Estructura de Carpetas del Proyecto

**Objetivo:** Establecer la organización de directorios que el proceso RPA utilizará durante toda su ejecución.

#### Instrucciones

1. Crea el directorio raíz del proyecto y navega a él:

```bash
# Windows (cmd/PowerShell)
mkdir lab08_rpa_ventas
cd lab08_rpa_ventas

# macOS/Linux
mkdir lab08_rpa_ventas && cd lab08_rpa_ventas
```

2. Crea la estructura de subdirectorios:

```bash
# Windows (PowerShell)
New-Item -ItemType Directory -Path data, output, libraries, resources, logs

# macOS/Linux
mkdir -p data output libraries resources logs
```

3. Verifica la estructura creada:

```bash
# Windows
dir

# macOS/Linux
ls -la
```

**Estructura esperada del proyecto:**

```
lab08_rpa_ventas/
├── data/                  ← Archivo Excel de entrada
├── output/                ← PDFs y reportes generados
├── libraries/             ← Keywords Python personalizadas
├── resources/             ← Archivos Resource de Robot Framework
├── logs/                  ← Logs de filas rechazadas
└── main_process.robot     ← Suite principal (se crea en pasos posteriores)
```

**Salida esperada:** Los directorios `data`, `output`, `libraries`, `resources` y `logs` existen en el directorio del proyecto.

**Verificación:**

```bash
# Windows
dir /B

# macOS/Linux
ls
```

Deben aparecer las 5 carpetas listadas.

---

### Paso 2: Generar el Archivo Excel de Datos de Entrada

**Objetivo:** Crear el archivo `ventas_entrada.xlsx` con 22 filas de datos ficticios de ventas (incluyendo filas intencionalmente inválidas para practicar el manejo de errores).

#### Instrucciones

1. Crea el script de setup `create_test_data.py` en la raíz del proyecto:

```python
# create_test_data.py
# Script de setup: genera el archivo Excel de prueba
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from datetime import date, timedelta
import random

def crear_excel_ventas():
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Ventas"

    # Encabezados
    encabezados = [
        "producto", "cantidad", "precio_unitario",
        "fecha", "vendedor", "region"
    ]
    ws.append(encabezados)

    # Estilo de encabezado
    for celda in ws[1]:
        celda.font = Font(bold=True, color="FFFFFF")
        celda.fill = PatternFill("solid", fgColor="1F4E79")
        celda.alignment = Alignment(horizontal="center")

    # Datos ficticios de TelecomSur S.A.
    productos = ["Plan Hogar 100MB", "Plan Empresarial 500MB",
                 "Plan Móvil 5G", "Router WiFi 6", "Decodificador TV"]
    vendedores = ["Ana Torres", "Luis Gómez", "Carla Ruiz",
                  "Pedro Sanz", "María López"]
    regiones = ["Norte", "Sur", "Centro", "Este", "Oeste"]

    random.seed(42)  # Semilla fija para reproducibilidad
    fecha_base = date(2024, 11, 1)

    filas_validas = [
        ("Plan Hogar 100MB",    5,  49.99, fecha_base + timedelta(days=0),  "Ana Torres",  "Norte"),
        ("Plan Empresarial 500MB", 2, 199.99, fecha_base + timedelta(days=1), "Luis Gómez",  "Sur"),
        ("Plan Móvil 5G",       10, 29.99, fecha_base + timedelta(days=2),  "Carla Ruiz",  "Centro"),
        ("Router WiFi 6",        3, 89.99, fecha_base + timedelta(days=3),  "Pedro Sanz",  "Este"),
        ("Decodificador TV",     7, 39.99, fecha_base + timedelta(days=4),  "María López", "Oeste"),
        ("Plan Hogar 100MB",     8, 49.99, fecha_base + timedelta(days=5),  "Luis Gómez",  "Norte"),
        ("Plan Móvil 5G",       15, 29.99, fecha_base + timedelta(days=6),  "Ana Torres",  "Sur"),
        ("Router WiFi 6",        1, 89.99, fecha_base + timedelta(days=7),  "Carla Ruiz",  "Centro"),
        ("Plan Empresarial 500MB", 4, 199.99, fecha_base + timedelta(days=8), "María López", "Este"),
        ("Decodificador TV",     6, 39.99, fecha_base + timedelta(days=9),  "Pedro Sanz",  "Oeste"),
        ("Plan Hogar 100MB",    12, 49.99, fecha_base + timedelta(days=10), "Ana Torres",  "Centro"),
        ("Plan Móvil 5G",        9, 29.99, fecha_base + timedelta(days=11), "Luis Gómez",  "Este"),
        ("Router WiFi 6",        5, 89.99, fecha_base + timedelta(days=12), "Pedro Sanz",  "Norte"),
        ("Plan Empresarial 500MB", 3, 199.99, fecha_base + timedelta(days=13), "Carla Ruiz", "Sur"),
        ("Decodificador TV",    11, 39.99, fecha_base + timedelta(days=14), "María López", "Oeste"),
        ("Plan Hogar 100MB",     2, 49.99, fecha_base + timedelta(days=15), "Pedro Sanz",  "Este"),
        ("Plan Móvil 5G",       20, 29.99, fecha_base + timedelta(days=16), "Ana Torres",  "Norte"),
        ("Router WiFi 6",        4, 89.99, fecha_base + timedelta(days=17), "Luis Gómez",  "Centro"),
    ]

    # Filas intencionalmente inválidas para probar manejo de errores
    filas_invalidas = [
        ("Plan Hogar 100MB", -3,  49.99, fecha_base + timedelta(days=18), "Carla Ruiz",  "Sur"),    # cantidad negativa
        ("",                  5,  29.99, fecha_base + timedelta(days=19), "María López", "Oeste"),   # producto vacío
        ("Plan Móvil 5G",     0,  29.99, fecha_base + timedelta(days=20), "Pedro Sanz",  "Norte"),   # cantidad cero
        ("Router WiFi 6",     2, -10.00, fecha_base + timedelta(days=21), "Ana Torres",  "Este"),    # precio negativo
    ]

    for fila in filas_validas + filas_invalidas:
        ws.append(list(fila))

    # Ajustar ancho de columnas
    anchos = [25, 10, 17, 12, 15, 10]
    for i, ancho in enumerate(anchos, 1):
        ws.column_dimensions[openpyxl.utils.get_column_letter(i)].width = ancho

    ruta = "data/ventas_entrada.xlsx"
    wb.save(ruta)
    print(f"✅ Archivo creado: {ruta}")
    print(f"   Total filas de datos: {len(filas_validas) + len(filas_invalidas)}")
    print(f"   Filas válidas: {len(filas_validas)}")
    print(f"   Filas inválidas (para prueba de errores): {len(filas_invalidas)}")

if __name__ == "__main__":
    crear_excel_ventas()
```

2. Ejecuta el script de setup:

```bash
python create_test_data.py
```

**Salida esperada:**

```
✅ Archivo creado: data/ventas_entrada.xlsx
   Total filas de datos: 22
   Filas válidas: 18
   Filas inválidas (para prueba de errores): 4
```

**Verificación:**

```bash
# Windows
dir data\

# macOS/Linux
ls -lh data/
```

Debe aparecer `ventas_entrada.xlsx` con un tamaño aproximado de 6–10 KB.

---

### Paso 3: Crear la Librería Python para Procesamiento de Datos

**Objetivo:** Implementar la keyword Python personalizada que encapsula la lógica de lectura del Excel, transformación de datos y cálculos derivados usando `openpyxl`.

#### Instrucciones

1. Crea el archivo `libraries/VentasLibrary.py`:

```python
# libraries/VentasLibrary.py
"""
Librería Python personalizada para el proceso RPA de ventas.
Encapsula operaciones de lectura Excel, transformación y cálculos.
"""
import openpyxl
from robot.api.deco import keyword
from robot.api import logger
from datetime import datetime


class VentasLibrary:
    """Librería para procesamiento de datos de ventas desde Excel."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    @keyword("Leer Ventas Desde Excel")
    def leer_ventas_desde_excel(self, ruta: str, hoja: str = "Ventas") -> list:
        """
        Lee el archivo Excel y retorna una lista de diccionarios.
        Cada diccionario representa una fila con los encabezados como claves.

        Args:
            ruta: Ruta al archivo .xlsx
            hoja: Nombre de la hoja a leer (por defecto 'Ventas')

        Returns:
            Lista de diccionarios con los datos de ventas.
        """
        logger.info(f"Abriendo archivo Excel: {ruta}", also_console=True)
        wb = openpyxl.load_workbook(ruta, data_only=True)

        if hoja not in wb.sheetnames:
            raise ValueError(f"La hoja '{hoja}' no existe en {ruta}. "
                             f"Hojas disponibles: {wb.sheetnames}")

        ws = wb[hoja]
        filas = list(ws.iter_rows(values_only=True))

        if not filas:
            logger.warn("El archivo Excel está vacío.")
            wb.close()
            return []

        encabezados = [str(h).strip().lower() if h else f"col_{i}"
                       for i, h in enumerate(filas[0])]
        logger.info(f"Encabezados detectados: {encabezados}", also_console=True)

        datos = []
        for i, fila in enumerate(filas[1:], start=2):
            registro = {}
            for j, valor in enumerate(fila):
                clave = encabezados[j] if j < len(encabezados) else f"col_{j}"
                # Convertir fechas de Excel a string ISO
                if isinstance(valor, datetime):
                    registro[clave] = valor.strftime("%Y-%m-%d")
                elif valor is None:
                    registro[clave] = ""
                else:
                    registro[clave] = valor
            registro["_fila_excel"] = i  # Número de fila para trazabilidad
            datos.append(registro)

        wb.close()
        logger.info(f"Total registros leídos: {len(datos)}", also_console=True)
        return datos

    @keyword("Validar Y Filtrar Ventas")
    def validar_y_filtrar_ventas(self, datos: list) -> dict:
        """
        Valida cada registro y separa los válidos de los rechazados.

        Criterios de validación:
        - producto no vacío
        - cantidad > 0
        - precio_unitario > 0

        Returns:
            Diccionario con claves 'validos' y 'rechazados'.
        """
        validos = []
        rechazados = []

        for registro in datos:
            errores = []

            producto = str(registro.get("producto", "")).strip()
            if not producto:
                errores.append("producto vacío")

            try:
                cantidad = float(registro.get("cantidad", 0) or 0)
                if cantidad <= 0:
                    errores.append(f"cantidad inválida: {cantidad}")
            except (ValueError, TypeError):
                errores.append(f"cantidad no numérica: {registro.get('cantidad')}")
                cantidad = 0

            try:
                precio = float(registro.get("precio_unitario", 0) or 0)
                if precio <= 0:
                    errores.append(f"precio_unitario inválido: {precio}")
            except (ValueError, TypeError):
                errores.append(f"precio_unitario no numérico: {registro.get('precio_unitario')}")
                precio = 0

            if errores:
                registro["_errores_validacion"] = "; ".join(errores)
                rechazados.append(registro)
                logger.warn(
                    f"Fila {registro.get('_fila_excel', '?')} rechazada: {errores}"
                )
            else:
                registro["cantidad"] = cantidad
                registro["precio_unitario"] = precio
                validos.append(registro)

        logger.info(
            f"Validación completada: {len(validos)} válidos, "
            f"{len(rechazados)} rechazados.",
            also_console=True
        )
        return {"validos": validos, "rechazados": rechazados}

    @keyword("Calcular Totales Por Venta")
    def calcular_totales_por_venta(self, ventas_validas: list) -> list:
        """
        Calcula el campo derivado total_venta = cantidad × precio_unitario
        para cada registro válido.
        """
        for venta in ventas_validas:
            venta["total_venta"] = round(
                float(venta["cantidad"]) * float(venta["precio_unitario"]), 2
            )
        logger.info("Campo 'total_venta' calculado para todos los registros.")
        return ventas_validas

    @keyword("Agrupar Ventas Por Region")
    def agrupar_ventas_por_region(self, ventas: list) -> dict:
        """
        Agrupa las ventas por región y calcula subtotales.

        Returns:
            Diccionario {region: {subtotal, cantidad_registros, ventas: [...]}}
        """
        grupos = {}
        for venta in ventas:
            region = str(venta.get("region", "Desconocida")).strip()
            if region not in grupos:
                grupos[region] = {
                    "subtotal": 0.0,
                    "cantidad_registros": 0,
                    "ventas": []
                }
            grupos[region]["subtotal"] = round(
                grupos[region]["subtotal"] + venta["total_venta"], 2
            )
            grupos[region]["cantidad_registros"] += 1
            grupos[region]["ventas"].append(venta)

        logger.info(
            f"Agrupación por región completada: {list(grupos.keys())}",
            also_console=True
        )
        return grupos

    @keyword("Calcular Metricas Ejecutivas")
    def calcular_metricas_ejecutivas(self, ventas: list, grupos: dict) -> dict:
        """
        Calcula métricas de alto nivel para el reporte ejecutivo:
        - Total general de ventas
        - Top 3 vendedores por monto
        - Venta promedio por región
        """
        total_general = round(sum(v["total_venta"] for v in ventas), 2)

        # Top 3 vendedores
        ventas_por_vendedor = {}
        for venta in ventas:
            vendedor = str(venta.get("vendedor", "Desconocido")).strip()
            ventas_por_vendedor[vendedor] = round(
                ventas_por_vendedor.get(vendedor, 0.0) + venta["total_venta"], 2
            )
        top3 = sorted(
            ventas_por_vendedor.items(),
            key=lambda x: x[1],
            reverse=True
        )[:3]

        # Promedio por región
        promedio_region = {
            region: round(datos["subtotal"] / datos["cantidad_registros"], 2)
            for region, datos in grupos.items()
        }

        metricas = {
            "total_general": total_general,
            "total_registros": len(ventas),
            "top3_vendedores": top3,
            "promedio_por_region": promedio_region,
            "fecha_proceso": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        logger.info(f"Métricas ejecutivas calculadas: total={total_general}", also_console=True)
        return metricas
```

**Salida esperada:** El archivo `libraries/VentasLibrary.py` se crea sin errores de sintaxis.

**Verificación:**

```bash
python -c "from libraries.VentasLibrary import VentasLibrary; v = VentasLibrary(); print('VentasLibrary OK')"
```

---

### Paso 4: Crear el Archivo Resource con Keywords de Infraestructura

**Objetivo:** Centralizar en un archivo Resource las keywords de configuración del entorno, gestión de carpetas, generación de HTML para el PDF y logging de rechazados.

#### Instrucciones

1. Crea el archivo `resources/rpa_keywords.resource`:

```robotframework
*** Settings ***
Documentation    Keywords de infraestructura para el proceso RPA de ventas.
...              Gestión de carpetas, logging y generación de reportes.
Library          OperatingSystem
Library          Collections
Library          String
Library          DateTime
Library          RPA.PDF


*** Variables ***
${DIR_DATA}         ${CURDIR}/../data
${DIR_OUTPUT}       ${CURDIR}/../output
${DIR_LOGS}         ${CURDIR}/../logs
${EXCEL_ENTRADA}    ventas_entrada.xlsx
${PDF_REPORTE}      reporte_ventas.pdf
${LOG_RECHAZADOS}   filas_rechazadas.log


*** Keywords ***
Inicializar Estructura De Directorios
    [Documentation]    Crea los directorios necesarios si no existen.
    [Tags]    setup    infraestructura
    Create Directory    ${DIR_OUTPUT}
    Create Directory    ${DIR_LOGS}
    Log    Directorios de trabajo verificados.    level=INFO
    Log To Console    [SETUP] Directorios listos: output/ y logs/

Verificar Archivo De Entrada
    [Documentation]    Verifica que el archivo Excel de entrada exista.
    [Arguments]    ${nombre_archivo}=${EXCEL_ENTRADA}
    [Tags]    validacion    infraestructura
    ${ruta_completa}=    Join Path    ${DIR_DATA}    ${nombre_archivo}
    File Should Exist    ${ruta_completa}
    ...    msg=Archivo de entrada no encontrado: ${ruta_completa}
    ${tamanio}=    Get File Size    ${ruta_completa}
    Log    Archivo de entrada verificado: ${ruta_completa} (${tamanio} bytes)    level=INFO
    Log To Console    [SETUP] Archivo Excel encontrado: ${nombre_archivo}
    RETURN    ${ruta_completa}

Registrar Filas Rechazadas
    [Documentation]    Escribe las filas rechazadas en un archivo de log separado.
    [Arguments]    ${rechazados}
    [Tags]    logging    trazabilidad
    ${ruta_log}=    Join Path    ${DIR_LOGS}    ${LOG_RECHAZADOS}
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${linea_cabecera}=    Set Variable
    ...    \n=== PROCESO: ${timestamp} | Filas rechazadas: ${rechazados.__len__()} ===\n
    ${contenido}=    Set Variable    ${linea_cabecera}
    FOR    ${fila}    IN    @{rechazados}
        ${linea}=    Set Variable
        ...    Fila Excel ${fila}[_fila_excel]: ${fila}[_errores_validacion]\n
        ${contenido}=    Catenate    SEPARATOR=    ${contenido}    ${linea}
    END
    Append To File    ${ruta_log}    ${contenido}    encoding=utf-8
    Log    Filas rechazadas registradas en: ${ruta_log}    level=WARN
    Log To Console    [WARN] ${rechazados.__len__()} filas rechazadas → ${ruta_log}

Construir HTML Para Reporte
    [Documentation]    Genera el contenido HTML que se convertirá en PDF.
    [Arguments]    ${ventas}    ${grupos}    ${metricas}
    [Tags]    reporte    pdf
    # Construir filas de la tabla de ventas
    ${filas_tabla}=    Set Variable    ${EMPTY}
    FOR    ${venta}    IN    @{ventas}
        ${fila}=    Set Variable
        ...    <tr><td>${venta}[producto]</td><td>${venta}[vendedor]</td><td>${venta}[region]</td><td style="text-align:right">${venta}[cantidad]</td><td style="text-align:right">$${venta}[precio_unitario]</td><td style="text-align:right; font-weight:bold">$${venta}[total_venta]</td></tr>
        ${filas_tabla}=    Catenate    SEPARATOR=\n    ${filas_tabla}    ${fila}
    END
    # Construir tabla de subtotales por región
    ${filas_region}=    Set Variable    ${EMPTY}
    ${regiones}=    Get Dictionary Keys    ${grupos}
    FOR    ${region}    IN    @{regiones}
        ${datos_region}=    Get From Dictionary    ${grupos}    ${region}
        ${fila_r}=    Set Variable
        ...    <tr><td>${region}</td><td style="text-align:right">${datos_region}[cantidad_registros]</td><td style="text-align:right; font-weight:bold">$${datos_region}[subtotal]</td></tr>
        ${filas_region}=    Catenate    SEPARATOR=\n    ${filas_region}    ${fila_r}
    END
    # Construir top 3 vendedores
    ${filas_top3}=    Set Variable    ${EMPTY}
    ${posicion}=    Set Variable    ${1}
    FOR    ${entry}    IN    @{metricas}[top3_vendedores]
        ${nombre_v}=    Set Variable    ${entry}[0]
        ${monto_v}=    Set Variable    ${entry}[1]
        ${fila_v}=    Set Variable
        ...    <tr><td style="text-align:center">${posicion}</td><td>${nombre_v}</td><td style="text-align:right; font-weight:bold">$${monto_v}</td></tr>
        ${filas_top3}=    Catenate    SEPARATOR=\n    ${filas_top3}    ${fila_v}
        ${posicion}=    Evaluate    ${posicion} + 1
    END
    ${html}=    Set Variable
    ...    <!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><style>body{font-family:Arial,sans-serif;margin:30px;color:#1a1a1a}h1{color:#1F4E79;border-bottom:3px solid #1F4E79;padding-bottom:8px}h2{color:#2E75B6;margin-top:25px}table{border-collapse:collapse;width:100%;margin-bottom:20px}th{background:#1F4E79;color:white;padding:8px 12px;text-align:left}td{padding:6px 12px;border-bottom:1px solid #ddd}tr:nth-child(even){background:#f2f8ff}.metric-box{display:inline-block;background:#E8F4FD;border:2px solid #2E75B6;border-radius:8px;padding:12px 20px;margin:8px;text-align:center}.metric-value{font-size:1.8em;font-weight:bold;color:#1F4E79}.metric-label{font-size:0.85em;color:#555}.footer{margin-top:30px;font-size:0.8em;color:#888;text-align:center}</style></head><body><h1>📊 Reporte Ejecutivo de Ventas — TelecomSur S.A.</h1><div class="metric-box"><div class="metric-value">$${metricas}[total_general]</div><div class="metric-label">Total General</div></div><div class="metric-box"><div class="metric-value">${metricas}[total_registros]</div><div class="metric-label">Registros Procesados</div></div><div class="metric-box"><div class="metric-value">${metricas}[fecha_proceso]</div><div class="metric-label">Fecha de Proceso</div></div><h2>Detalle de Ventas</h2><table><thead><tr><th>Producto</th><th>Vendedor</th><th>Región</th><th>Cantidad</th><th>Precio Unit.</th><th>Total Venta</th></tr></thead><tbody>${filas_tabla}</tbody></table><h2>Subtotales por Región</h2><table><thead><tr><th>Región</th><th>Registros</th><th>Subtotal</th></tr></thead><tbody>${filas_region}</tbody></table><h2>🏆 Top 3 Vendedores</h2><table><thead><tr><th>#</th><th>Vendedor</th><th>Monto Total</th></tr></thead><tbody>${filas_top3}</tbody></table><div class="footer">Generado automáticamente por el proceso RPA — Robot Framework | ${metricas}[fecha_proceso]</div></body></html>
    RETURN    ${html}

Generar PDF Desde HTML
    [Documentation]    Crea el archivo PDF a partir del contenido HTML.
    [Arguments]    ${contenido_html}    ${nombre_pdf}=${PDF_REPORTE}
    [Tags]    reporte    pdf
    ${ruta_html_temp}=    Join Path    ${DIR_OUTPUT}    reporte_temp.html
    ${ruta_pdf}=          Join Path    ${DIR_OUTPUT}    ${nombre_pdf}
    Create File    ${ruta_html_temp}    ${contenido_html}    encoding=utf-8
    RPA.PDF.HTML To PDF    ${ruta_html_temp}    ${ruta_pdf}
    File Should Exist    ${ruta_pdf}
    ...    msg=El PDF no fue generado correctamente en: ${ruta_pdf}
    ${tamanio}=    Get File Size    ${ruta_pdf}
    Log    PDF generado exitosamente: ${ruta_pdf} (${tamanio} bytes)    level=INFO
    Log To Console    [OK] PDF generado: ${nombre_pdf} (${tamanio} bytes)
    # Limpiar HTML temporal
    Remove File    ${ruta_html_temp}
    RETURN    ${ruta_pdf}
```

**Salida esperada:** El archivo `resources/rpa_keywords.resource` se crea sin errores de sintaxis.

**Verificación:** Abre el archivo en VS Code. La extensión RobotCode no debe mostrar errores de sintaxis en el panel de problemas.

---

### Paso 5: Crear la Suite Principal del Proceso RPA

**Objetivo:** Implementar el archivo `main_process.robot` que orquesta todo el flujo: lectura, validación, transformación, agrupación, generación del PDF y manejo de errores.

#### Instrucciones

1. Crea el archivo `main_process.robot` en la raíz del proyecto:

```robotframework
*** Settings ***
Documentation     Proceso RPA: Procesamiento mensual de ventas TelecomSur S.A.
...               Lee datos desde Excel, aplica transformaciones y genera reporte PDF.
...               Laboratorio 08-00-01 — Módulo 8: Automatización de Archivos.
Metadata          Empresa          TelecomSur S.A.
Metadata          Proceso          Reporte Mensual de Ventas
Metadata          Versión          1.0.0

Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           ${CURDIR}/libraries/VentasLibrary.py
Resource          ${CURDIR}/resources/rpa_keywords.resource

Suite Setup       Preparar Entorno Del Proceso
Suite Teardown    Finalizar Proceso RPA

*** Variables ***
${EXCEL_ARCHIVO}          ventas_entrada.xlsx
${PDF_NOMBRE}             reporte_ventas_noviembre_2024.pdf
${MAX_REINTENTOS}         ${3}
${PAUSA_REINTENTO_SEG}    ${2}
${UMBRAL_RECHAZO_PCT}     ${20}    # Porcentaje máximo de filas rechazadas aceptable

*** Test Cases ***

TC-01: Lectura Y Validación De Datos Excel
    [Documentation]    Lee el archivo Excel de ventas y valida la integridad de los datos.
    ...                Registra las filas rechazadas en log separado.
    [Tags]    RPA    data-processing    lectura    validacion
    Log To Console    \n╔══════════════════════════════════════╗
    Log To Console    ║  INICIO: Lectura y Validación Excel  ║
    Log To Console    ╚══════════════════════════════════════╝

    # Verificar archivo de entrada con reintento
    ${ruta_excel}=    Verificar Archivo Con Reintento    ${EXCEL_ARCHIVO}

    # Leer datos del Excel
    ${datos_crudos}=    Leer Ventas Desde Excel
    ...    ruta=${ruta_excel}    hoja=Ventas
    ${total_leidos}=    Get Length    ${datos_crudos}
    Log    Total registros leídos del Excel: ${total_leidos}    level=INFO
    Should Be True    ${total_leidos} > 0
    ...    msg=El archivo Excel no contiene datos en la hoja 'Ventas'.

    # Validar y filtrar
    ${resultado_validacion}=    Validar Y Filtrar Ventas    ${datos_crudos}
    ${ventas_validas}=      Get From Dictionary    ${resultado_validacion}    validos
    ${ventas_rechazadas}=   Get From Dictionary    ${resultado_validacion}    rechazados

    # Verificar umbral de rechazo
    ${pct_rechazo}=    Evaluate
    ...    round((${ventas_rechazadas.__len__()} / ${total_leidos}) * 100, 1)
    Log    Porcentaje de rechazo: ${pct_rechazo}%    level=INFO
    Run Keyword If    ${pct_rechazo} > ${UMBRAL_RECHAZO_PCT}
    ...    Log    ALERTA: Porcentaje de rechazo (${pct_rechazo}%) supera umbral (${UMBRAL_RECHAZO_PCT}%)    level=WARN

    # Registrar rechazados si existen
    ${hay_rechazados}=    Run Keyword And Return Status
    ...    Should Be True    ${ventas_rechazadas.__len__()} > 0
    Run Keyword If    ${hay_rechazados}
    ...    Registrar Filas Rechazadas    ${ventas_rechazadas}

    # Guardar en variables de suite para uso posterior
    Set Suite Variable    ${VENTAS_VALIDAS}      ${ventas_validas}
    Set Suite Variable    ${VENTAS_RECHAZADAS}   ${ventas_rechazadas}
    Set Suite Variable    ${TOTAL_LEIDOS}        ${total_leidos}

    Log To Console    [TC-01] ✅ Lectura completada: ${ventas_validas.__len__()} válidas, ${ventas_rechazadas.__len__()} rechazadas.

TC-02: Transformación Y Cálculo De Métricas
    [Documentation]    Calcula total_venta por registro, agrupa por región y
    ...                obtiene métricas ejecutivas (total general, top 3 vendedores).
    [Tags]    RPA    data-processing    transformacion    calculo
    Log To Console    \n╔══════════════════════════════════════════╗
    Log To Console    ║  INICIO: Transformación y Cálculo        ║
    Log To Console    ╚══════════════════════════════════════════╝

    # Calcular total_venta por registro
    ${ventas_con_total}=    Calcular Totales Por Venta    ${VENTAS_VALIDAS}

    # Agrupar por región
    ${grupos_region}=    Agrupar Ventas Por Region    ${ventas_con_total}

    # Calcular métricas ejecutivas
    ${metricas}=    Calcular Metricas Ejecutivas
    ...    ${ventas_con_total}    ${grupos_region}

    # Logging de resultados
    Log    Total general de ventas: $${metricas}[total_general]    level=INFO
    ${top3}=    Get From Dictionary    ${metricas}    top3_vendedores
    Log    Top 3 vendedores calculados: ${top3}    level=INFO

    # Guardar en variables de suite
    Set Suite Variable    ${VENTAS_CON_TOTAL}    ${ventas_con_total}
    Set Suite Variable    ${GRUPOS_REGION}       ${grupos_region}
    Set Suite Variable    ${METRICAS}            ${metricas}

    Log To Console    [TC-02] ✅ Total general: $${metricas}[total_general] | Registros: ${metricas}[total_registros]

TC-03: Generación De Reporte PDF Ejecutivo
    [Documentation]    Genera el reporte PDF ejecutivo con tabla de ventas,
    ...                subtotales por región y métricas del top 3 vendedores.
    [Tags]    RPA    data-processing    reporte    pdf    evidencia
    Log To Console    \n╔══════════════════════════════════════════╗
    Log To Console    ║  INICIO: Generación de Reporte PDF       ║
    Log To Console    ╚══════════════════════════════════════════╝

    # Construir contenido HTML
    ${html_reporte}=    Construir HTML Para Reporte
    ...    ${VENTAS_CON_TOTAL}    ${GRUPOS_REGION}    ${METRICAS}

    # Generar PDF con manejo de error
    ${pdf_ok}=    Run Keyword And Return Status
    ...    Generar PDF Desde HTML    ${html_reporte}    ${PDF_NOMBRE}

    Run Keyword If    not ${pdf_ok}
    ...    Fail    msg=No se pudo generar el PDF. Revisa los logs para más detalles.

    # Verificar que el PDF tiene contenido
    ${ruta_pdf}=    Join Path    ${DIR_OUTPUT}    ${PDF_NOMBRE}
    ${tamanio_pdf}=    Get File Size    ${ruta_pdf}
    Should Be True    ${tamanio_pdf} > 1000
    ...    msg=El PDF generado parece estar vacío o corrupto (${tamanio_pdf} bytes).

    Log    Reporte PDF generado exitosamente: ${ruta_pdf}    level=INFO
    Log To Console    [TC-03] ✅ PDF generado: ${PDF_NOMBRE} (${tamanio_pdf} bytes)

TC-04: Validación Final Y Resumen Del Proceso
    [Documentation]    Verifica la integridad de todos los artefactos generados
    ...                y produce el resumen final del proceso RPA.
    [Tags]    RPA    data-processing    validacion    resumen
    Log To Console    \n╔══════════════════════════════════════════╗
    Log To Console    ║  INICIO: Validación Final                ║
    Log To Console    ╚══════════════════════════════════════════╝

    # Verificar artefactos generados
    ${ruta_pdf}=    Join Path    ${DIR_OUTPUT}    ${PDF_NOMBRE}
    File Should Exist    ${ruta_pdf}

    ${ruta_log_rechazados}=    Join Path    ${DIR_LOGS}    filas_rechazadas.log
    ${log_existe}=    Run Keyword And Return Status
    ...    File Should Exist    ${ruta_log_rechazados}

    # Resumen ejecutivo en log
    Log    ══════════════════════════════════════    level=INFO
    Log    RESUMEN DEL PROCESO RPA — TelecomSur    level=INFO
    Log    ══════════════════════════════════════    level=INFO
    Log    Archivo entrada: ${EXCEL_ARCHIVO}        level=INFO
    Log    Total leídos:    ${TOTAL_LEIDOS}         level=INFO
    Log    Válidos:         ${VENTAS_VALIDAS.__len__()}    level=INFO
    Log    Rechazados:      ${VENTAS_RECHAZADAS.__len__()}    level=INFO
    Log    Total ventas:    $${METRICAS}[total_general]    level=INFO
    Log    PDF generado:    ${PDF_NOMBRE}           level=INFO
    Log    ══════════════════════════════════════    level=INFO

    Log To Console    \n══════════════════════════════════════
    Log To Console    RESUMEN PROCESO RPA — TelecomSur S.A.
    Log To Console    ══════════════════════════════════════
    Log To Console    Registros leídos:  ${TOTAL_LEIDOS}
    Log To Console    Válidos:           ${VENTAS_VALIDAS.__len__()}
    Log To Console    Rechazados:        ${VENTAS_RECHAZADAS.__len__()}
    Log To Console    Total ventas:      $${METRICAS}[total_general]
    Log To Console    PDF:               ${PDF_NOMBRE}
    Log To Console    ══════════════════════════════════════


*** Keywords ***
Preparar Entorno Del Proceso
    [Documentation]    Suite Setup: inicializa directorios y verifica prerequisitos.
    [Tags]    setup
    Log To Console    \n🤖 Iniciando proceso RPA — TelecomSur S.A.
    Inicializar Estructura De Directorios
    Log    Suite Setup completado.    level=INFO

Finalizar Proceso RPA
    [Documentation]    Suite Teardown: registra el fin del proceso.
    [Tags]    teardown
    Log    Suite Teardown: Proceso RPA finalizado.    level=INFO
    Log To Console    \n🏁 Proceso RPA finalizado.

Verificar Archivo Con Reintento
    [Documentation]    Intenta verificar el archivo de entrada hasta MAX_REINTENTOS veces.
    [Arguments]    ${nombre_archivo}
    [Tags]    infraestructura    retry
    ${intentos}=    Set Variable    ${0}
    ${ruta_ok}=    Set Variable    ${NONE}
    WHILE    ${intentos} < ${MAX_REINTENTOS}
        ${exito}=    Run Keyword And Return Status
        ...    Verificar Archivo De Entrada    ${nombre_archivo}
        IF    ${exito}
            ${ruta_ok}=    Join Path    ${DIR_DATA}    ${nombre_archivo}
            Log    Archivo verificado en intento ${intentos + 1}.    level=INFO
            BREAK
        ELSE
            ${intentos}=    Evaluate    ${intentos} + 1
            Log    Intento ${intentos} fallido. Reintentando...    level=WARN
            Sleep    ${PAUSA_REINTENTO_SEG}s
        END
    END
    Should Not Be Equal    ${ruta_ok}    ${NONE}
    ...    msg=No se pudo verificar el archivo '${nombre_archivo}' tras ${MAX_REINTENTOS} intentos.
    RETURN    ${ruta_ok}
```

**Salida esperada:** El archivo `main_process.robot` se crea correctamente. VS Code muestra la estructura de keywords sin errores.

**Verificación:** Ejecuta una validación sintáctica sin correr los tests:

```bash
python -m robot --dryrun main_process.robot
```

La salida debe terminar con `0 tests, 0 failures` (dry run no ejecuta, solo valida sintaxis).

---

### Paso 6: Ejecutar el Proceso RPA Completo

**Objetivo:** Ejecutar la suite completa y verificar que todos los artefactos se generan correctamente.

#### Instrucciones

1. Asegúrate de estar en la raíz del proyecto con el venv activo.

2. Ejecuta el proceso RPA con configuración de log detallado:

```bash
python -m robot \
  --outputdir output/robot_results \
  --loglevel DEBUG \
  --variable DIR_DATA:data \
  --variable DIR_OUTPUT:output \
  --variable DIR_LOGS:logs \
  --report report.html \
  --log log.html \
  main_process.robot
```

**Para Windows (cmd) — en una sola línea:**

```cmd
python -m robot --outputdir output\robot_results --loglevel DEBUG --variable DIR_DATA:data --variable DIR_OUTPUT:output --variable DIR_LOGS:logs --report report.html --log log.html main_process.robot
```

3. Observa la salida en consola durante la ejecución. Deberías ver:

```
╔══════════════════════════════════════╗
║  INICIO: Lectura y Validación Excel  ║
╚══════════════════════════════════════╝
[SETUP] Directorios listos: output/ y logs/
[SETUP] Archivo Excel encontrado: ventas_entrada.xlsx
[OK] Abriendo archivo Excel: data/ventas_entrada.xlsx
[OK] Encabezados detectados: ['producto', 'cantidad', 'precio_unitario', 'fecha', 'vendedor', 'region']
[OK] Total registros leídos: 22
[WARN] 4 filas rechazadas → logs/filas_rechazadas.log
[TC-01] ✅ Lectura completada: 18 válidas, 4 rechazadas.

╔══════════════════════════════════════════╗
║  INICIO: Transformación y Cálculo        ║
╚══════════════════════════════════════════╝
[TC-02] ✅ Total general: $XXXX.XX | Registros: 18

╔══════════════════════════════════════════╗
║  INICIO: Generación de Reporte PDF       ║
╚══════════════════════════════════════════╝
[OK] PDF generado: reporte_ventas_noviembre_2024.pdf (XXXXX bytes)
[TC-03] ✅ PDF generado: reporte_ventas_noviembre_2024.pdf (XXXXX bytes)
```

**Salida esperada al finalizar:**

```
==============================================================================
Main Process                                                                  
==============================================================================
TC-01: Lectura Y Validación De Datos Excel                            | PASS |
TC-02: Transformación Y Cálculo De Métricas                           | PASS |
TC-03: Generación De Reporte PDF Ejecutivo                            | PASS |
TC-04: Validación Final Y Resumen Del Proceso                         | PASS |
==============================================================================
Main Process                                                          | PASS |
4 tests, 0 failures
==============================================================================
```

**Verificación de artefactos generados:**

```bash
# Verificar PDF generado
# Windows
dir output\

# macOS/Linux
ls -lh output/
```

Deben existir:
- `output/reporte_ventas_noviembre_2024.pdf` (> 5 KB)
- `logs/filas_rechazadas.log`
- `output/robot_results/report.html`
- `output/robot_results/log.html`

---

## Validación y Pruebas

### Lista de Verificación de Artefactos

Después de la ejecución exitosa, verifica cada elemento de la siguiente lista:

| Artefacto | Ruta Esperada | Criterio de Éxito |
|---|---|---|
| PDF ejecutivo | `output/reporte_ventas_noviembre_2024.pdf` | Existe y tiene > 5 KB |
| Log de rechazados | `logs/filas_rechazadas.log` | Existe y contiene 4 entradas |
| Reporte Robot HTML | `output/robot_results/report.html` | 4 tests PASS, 0 FAIL |
| Log Robot HTML | `output/robot_results/log.html` | Existe y es navegable |

### Verificación del Contenido del PDF

1. Abre el archivo `output/reporte_ventas_noviembre_2024.pdf` en un visor de PDF.
2. Verifica que contiene:
   - [ ] Título "Reporte Ejecutivo de Ventas — TelecomSur S.A."
   - [ ] Tres cajas de métricas: Total General, Registros Procesados, Fecha de Proceso
   - [ ] Tabla de detalle con 18 filas de ventas
   - [ ] Tabla de subtotales con 5 regiones (Norte, Sur, Centro, Este, Oeste)
   - [ ] Tabla de Top 3 Vendedores con posiciones 1, 2, 3

### Verificación del Log de Rechazados

```bash
# Windows
type logs\filas_rechazadas.log

# macOS/Linux
cat logs/filas_rechazadas.log
```

**Salida esperada:**

```
=== PROCESO: 2024-XX-XX XX:XX:XX | Filas rechazadas: 4 ===
Fila Excel 20: cantidad inválida: -3.0
Fila Excel 21: producto vacío
Fila Excel 22: cantidad inválida: 0.0
Fila Excel 23: precio_unitario inválido: -10.0
```

### Verificación de Métricas Calculadas

Ejecuta el siguiente script de verificación para confirmar que los cálculos son correctos:

```python
# verify_results.py
from libraries.VentasLibrary import VentasLibrary

lib = VentasLibrary()
datos = lib.leer_ventas_desde_excel("data/ventas_entrada.xlsx")
resultado = lib.validar_y_filtrar_ventas(datos)
validos = resultado["validos"]
validos = lib.calcular_totales_por_venta(validos)
grupos = lib.agrupar_ventas_por_region(validos)
metricas = lib.calcular_metricas_ejecutivas(validos, grupos)

print(f"\n✅ VERIFICACIÓN DE RESULTADOS")
print(f"   Registros válidos:  {len(validos)}")
print(f"   Total general:      ${metricas['total_general']:.2f}")
print(f"   Regiones:           {list(grupos.keys())}")
print(f"\n   Top 3 Vendedores:")
for i, (nombre, monto) in enumerate(metricas['top3_vendedores'], 1):
    print(f"   {i}. {nombre}: ${monto:.2f}")
```

```bash
python verify_results.py
```

**Salida esperada (valores aproximados):**

```
✅ VERIFICACIÓN DE RESULTADOS
   Registros válidos:  18
   Total general:      $XXXX.XX
   Regiones:           ['Norte', 'Sur', 'Centro', 'Este', 'Oeste']

   Top 3 Vendedores:
   1. [Nombre]: $XXX.XX
   2. [Nombre]: $XXX.XX
   3. [Nombre]: $XXX.XX
```

---

## Solución de Problemas

### Problema 1: `AttributeError: 'NoneType' object has no attribute 'sheetnames'` al leer el Excel

**Síntoma:** El proceso falla en `TC-01` con un error similar a:
```
AttributeError: 'NoneType' object has no attribute 'sheetnames'
```
o bien:
```
KeyError: 'Ventas'
```
El log indica que el archivo se abre pero la hoja no se encuentra.

**Causa:** El archivo Excel fue creado con el script de setup pero la hoja activa tiene un nombre diferente al esperado (`Sheet` en lugar de `Ventas`), o el script `create_test_data.py` no se ejecutó correctamente y el archivo está vacío o corrupto.

**Solución:**

1. Verifica el nombre de la hoja en el Excel:
```python
import openpyxl
wb = openpyxl.load_workbook("data/ventas_entrada.xlsx")
print("Hojas disponibles:", wb.sheetnames)
wb.close()
```
2. Si el nombre es incorrecto, vuelve a ejecutar el script de setup:
```bash
python create_test_data.py
```
3. Si el problema persiste, verifica que el entorno virtual está activo y que `openpyxl` está instalado en él:
```bash
pip show openpyxl
```
4. Como solución temporal, puedes pasar el nombre correcto de la hoja como variable al ejecutar Robot Framework:
```bash
python -m robot --variable HOJA_EXCEL:Sheet1 main_process.robot
```

---

### Problema 2: `RPA.PDF.HTML To PDF` falla con error de dependencia o genera un PDF vacío

**Síntoma:** El proceso falla en `TC-03` con alguno de estos mensajes:
```
No module named 'fpdf2'
```
o el PDF se genera pero tiene 0 bytes o no abre correctamente.

**Causa:** La keyword `HTML To PDF` de `RPA.PDF` requiere la librería `fpdf2` como dependencia interna. En algunas versiones de `rpaframework`, esta dependencia no se instala automáticamente. Alternativamente, el contenido HTML puede tener caracteres especiales que no se codificaron correctamente al escribir el archivo temporal.

**Solución:**

1. Instala explícitamente `fpdf2`:
```bash
pip install fpdf2
```
2. Verifica la instalación de RPA.PDF completa:
```bash
pip install "rpaframework[pdf]"
```
3. Si el problema es la codificación del HTML, verifica que el archivo temporal se escribe con UTF-8. En la keyword `Generar PDF Desde HTML` del resource, la línea `Create File` ya incluye `encoding=utf-8`. Confirma que no hay caracteres problemáticos en los datos de prueba.
4. Como alternativa de diagnóstico, prueba generar el PDF desde Python directamente:
```python
from RPA.PDF import PDF
pdf = PDF()
pdf.html_to_pdf("<html><body><h1>Test</h1></body></html>", "output/test.pdf")
print("PDF de prueba generado OK")
```
5. Si ninguna solución funciona, usa `weasyprint` como alternativa:
```bash
pip install weasyprint
```
Y modifica la keyword `Generar PDF Desde HTML` para usar:
```robotframework
Evaluate    __import__('weasyprint').HTML(filename='${ruta_html_temp}').write_pdf('${ruta_pdf}')
```

---

## Limpieza del Entorno

Una vez completado el laboratorio, puedes limpiar los artefactos generados manteniendo el código fuente:

```bash
# Eliminar artefactos generados (mantiene el código)
# Windows (PowerShell)
Remove-Item -Recurse -Force output\robot_results -ErrorAction SilentlyContinue
Remove-Item -Force output\*.pdf -ErrorAction SilentlyContinue
Remove-Item -Force logs\*.log -ErrorAction SilentlyContinue

# macOS/Linux
rm -rf output/robot_results
rm -f output/*.pdf
rm -f logs/*.log
```

Para una limpieza completa del proyecto (incluyendo el Excel de prueba):

```bash
# Windows (PowerShell)
Remove-Item -Recurse -Force output, logs
Remove-Item -Force data\ventas_entrada.xlsx

# macOS/Linux
rm -rf output logs
rm -f data/ventas_entrada.xlsx
```

> 💡 **Recomendación:** Antes de limpiar, guarda una copia del directorio completo como respaldo del módulo 8. Los laboratorios posteriores pueden requerir la librería `VentasLibrary.py` y la estructura de `resources/`.

---

## Resumen

En este laboratorio construiste un proceso RPA completo de extremo a extremo que integra las tres capacidades fundamentales de manejo de archivos cubiertas en la Lección 8.1:

| Capacidad | Implementación en el Lab |
|---|---|
| **Lectura Excel** | `VentasLibrary.py` con `openpyxl` y `data_only=True` |
| **Gestión de carpetas** | `OperatingSystem` en `Inicializar Estructura De Directorios` |
| **Generación PDF** | `RPA.PDF.HTML To PDF` desde plantilla HTML dinámica |
| **Manejo de errores** | `Run Keyword And Continue On Failure`, WHILE con reintentos, log de rechazados |
| **Trazabilidad** | `Log`, `Log To Console`, tags `RPA`/`data-processing`, `output.xml` |

### Conceptos Clave Aplicados

- El parámetro `data_only=True` en `openpyxl.load_workbook` es esencial para leer valores calculados en lugar de fórmulas.
- La separación de responsabilidades entre `VentasLibrary.py` (lógica de datos) y `rpa_keywords.resource` (infraestructura) facilita el mantenimiento.
- El bloque `WHILE` con `Run Keyword And Return Status` implementa reintentos sin detener el proceso ante fallos transitorios.
- Las variables de suite (`Set Suite Variable`) permiten compartir estado entre test cases dentro de la misma ejecución.
- La generación de PDF desde HTML permite crear reportes ricos con estilos CSS sin dependencias externas de procesadores de texto.

### Recursos Adicionales

- [Documentación de RPA.Excel.Files (rpaframework)](https://robocorp.com/docs/libraries/rpa-framework/rpa-excel-files)
- [Documentación de RPA.PDF (rpaframework)](https://robocorp.com/docs/libraries/rpa-framework/rpa-pdf)
- [openpyxl — Documentación oficial](https://openpyxl.readthedocs.io/en/stable/)
- [OperatingSystem Library — Robot Framework](https://robotframework.org/robotframework/latest/libraries/OperatingSystem.html)
- [Robot Framework User Guide — Creating Libraries](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#creating-test-libraries)

---
LAB_END---

---

# Proceso RPA end-to-end: web + API + archivos con checklist de calidad

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
