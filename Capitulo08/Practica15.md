# Práctica 15: Proceso RPA con lectura de Excel, transformación y generación de reporte PDF

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


