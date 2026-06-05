# Práctica 10: Creación de librería Python personalizada e integración en suite

## 1. Metadatos

| Campo            | Detalle                                      |
|------------------|----------------------------------------------|
| **Duración**     | 72 minutos                                   |
| **Complejidad**  | Alta                                         |
| **Nivel Bloom**  | Crear (*Create*)                             |
| **Módulo**       | 5 — Keywords Reutilizables y Librerías       |
| **Laboratorio**  | 05-00-02 / Práctica 10                       |

---

## 2. Descripción General

En este laboratorio crearás `TelecomUtils`, una librería Python personalizada con cinco keywords decoradas con `@keyword` que encapsulan lógica de negocio de telecomunicaciones: validación de números telefónicos, cálculo de excedentes de datos, formateo de facturas, lectura de CSV con validación y generación de identificadores únicos. La librería se empaquetará con `pyproject.toml` y se instalará en modo editable (`pip install -e .`) dentro del entorno virtual del proyecto. Finalmente, integrarás `TelecomUtils` con la suite data-driven del laboratorio anterior, demostrando cómo una librería Python personalizada amplía las capacidades nativas de Robot Framework de forma estructurada y reutilizable.

---

## 3. Objetivos de Aprendizaje

- [ ] Desarrollar una librería Python con mínimo cinco keywords decoradas con `@keyword`, incluyendo type hints, docstrings en formato RF y manejo de errores con `robot.api.exceptions`.
- [ ] Empaquetar la librería usando `pyproject.toml` e instalarla en el entorno virtual con `pip install -e .` (modo editable).
- [ ] Integrar la librería personalizada en una suite Robot Framework importándola desde la sección `Settings` y verificando que todas las keywords son reconocidas.
- [ ] Aplicar el principio de separación por capas, ubicando `TelecomUtils` en la capa técnica y consumiéndola desde keywords de acción y negocio en archivos `.robot`.

---

## 4. Prerrequisitos

### Conocimiento previo
- Laboratorio 05-00-01 completado con suite data-driven funcional (archivo `customers.csv` y suite `data_driven_suite.robot` operativos).
- Python 3.10+: funciones, clases, decoradores, type hints (`str`, `float`, `int`, `list`), manejo de excepciones (`try/except/raise`).
- Uso de `pip` y entornos virtuales (`venv`): activación, instalación de paquetes, modo editable.
- Comprensión básica de expresiones regulares (`re` module) y módulos estándar `csv`, `uuid`.

### Acceso y recursos
- Entorno virtual del curso activo con Robot Framework 7.x instalado.
- Proyecto del Laboratorio 05-00-01 disponible en disco (carpeta `lab_05_01/` o equivalente).
- Conexión a internet para instalar dependencias adicionales si fuera necesario.
- VS Code con extensión Robot Framework Language Server activa.

---

## 5. Entorno del Laboratorio

### Hardware mínimo recomendado

| Componente       | Mínimo                                    |
|------------------|-------------------------------------------|
| Procesador       | Intel Core i5 8ª gen / AMD Ryzen 5 (4 núcleos) |
| RAM              | 8 GB (16 GB recomendado)                  |
| Almacenamiento   | 10 GB libres                              |
| Pantalla         | 1280 × 768                                |
| Internet         | 10 Mbps estables                          |

### Software requerido

| Herramienta                   | Versión mínima |
|-------------------------------|----------------|
| Python                        | 3.10           |
| Robot Framework               | 7.x            |
| robotframework-datadriver     | 1.x (con extras CSV) |
| pip                           | 23.x           |
| VS Code                       | 1.85           |
| Robot Framework Language Server | 1.12         |

### Configuración inicial del entorno

> **⚠️ IMPORTANTE:** Activa siempre el entorno virtual antes de comenzar. Nunca instales paquetes en el Python del sistema.

**Windows (PowerShell):**
```powershell
# Navegar al directorio del curso
cd C:\curso_robotframework

# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Verificar Python y RF activos
python --version
robot --version
```

**macOS / Linux (bash/zsh):**
```bash
# Navegar al directorio del curso
cd ~/curso_robotframework

# Activar entorno virtual
source venv/bin/activate

# Verificar Python y RF activos
python --version
robot --version
```

**Salida esperada de verificación:**
```
Python 3.10.x (o superior)
Robot Framework 7.x.x (Python 3.10.x ...)
```

### Estructura de directorios del laboratorio

Antes de comenzar, crea la siguiente estructura dentro del directorio del curso:

```
curso_robotframework/
├── venv/
├── lab_05_01/                    # Proyecto del laboratorio anterior
│   ├── tests/
│   ├── resources/
│   └── data/
└── lab_05_02/                    # ← Directorio de este laboratorio
    ├── libraries/
    │   └── telecom_utils/        # Paquete Python de la librería
    ├── tests/
    ├── resources/
    │   └── keywords/
    └── data/
```

**Comandos para crear la estructura:**

```bash
# Desde el directorio raíz del curso (venv activo)
mkdir -p lab_05_02/libraries/telecom_utils
mkdir -p lab_05_02/tests
mkdir -p lab_05_02/resources/keywords
mkdir -p lab_05_02/data
cd lab_05_02
```

---

## 6. Procedimiento Paso a Paso

---

### Paso 1: Crear el núcleo de la librería `TelecomUtils`

**Objetivo:** Implementar el archivo principal de la librería Python con las cinco keywords requeridas, siguiendo las convenciones de Robot Framework.

#### Instrucciones

**1.1.** Crea el archivo `__init__.py` dentro de `libraries/telecom_utils/` para convertir el directorio en un paquete Python:

```bash
# Desde lab_05_02/
touch libraries/telecom_utils/__init__.py
```

**Windows (PowerShell):**
```powershell
New-Item -ItemType File libraries\telecom_utils\__init__.py
```

**1.2.** Crea el archivo principal de la librería. Abre VS Code y crea `libraries/telecom_utils/telecom_utils.py` con el siguiente contenido completo:

```python
# libraries/telecom_utils/telecom_utils.py
"""
TelecomUtils — Librería personalizada de Robot Framework
para operaciones de telecomunicaciones.

Versión: 1.0.0
Autor: Curso Robot Framework
Contexto: Empresa ficticia TelecomCorp S.A.
"""

import re
import csv
import uuid
from pathlib import Path
from typing import Optional

from robot.api.deco import keyword
from robot.api.exceptions import Error, DataError


class TelecomUtils:
    """
    Librería de keywords para operaciones de telecomunicaciones.

    Proporciona utilidades para validación de números telefónicos (E.164),
    cálculo de excedentes de datos, formateo de facturas, lectura de CSV
    con validación y generación de identificadores únicos de prueba.

    == Uso ==
    | Library | TelecomUtils |

    == Ejemplo ==
    | ${valido} | Validate Phone Number | +5215512345678 |
    """

    # Metadatos de la librería (Robot Framework los usa en documentación)
    ROBOT_LIBRARY_VERSION = "1.0.0"
    ROBOT_LIBRARY_SCOPE = "SUITE"
    ROBOT_LIBRARY_DOC_FORMAT = "reST"

    # Constante: patrón E.164 — + seguido de 7 a 15 dígitos
    _E164_PATTERN = re.compile(r"^\+[1-9]\d{6,14}$")

    # ------------------------------------------------------------------ #
    #  KEYWORD 1: Validate Phone Number                                    #
    # ------------------------------------------------------------------ #

    @keyword(name="Validate Phone Number")
    def validate_phone_number(self, phone_number: str) -> bool:
        """
        Valida que un número telefónico cumpla el estándar E.164.

        El formato E.164 requiere: símbolo ``+``, código de país (1-3 dígitos)
        y número de suscriptor. Total: entre 8 y 15 dígitos incluyendo el ``+``.

        Lanza ``DataError`` si el número no cumple el formato.

        Argumentos:
        - ``phone_number``: Número telefónico a validar (str).

        Retorna:
        - ``True`` si el número es válido.

        Ejemplos:
        | ${ok} | Validate Phone Number | +5215512345678 |
        | ${ok} | Validate Phone Number | +14155552671  |
        """
        if not isinstance(phone_number, str):
            raise DataError(
                f"El argumento 'phone_number' debe ser string, "
                f"se recibió: {type(phone_number).__name__}"
            )

        cleaned = phone_number.strip()

        if not self._E164_PATTERN.match(cleaned):
            raise DataError(
                f"Número telefónico inválido: '{cleaned}'. "
                f"Se esperaba formato E.164 (ej: +5215512345678)."
            )

        return True

    # ------------------------------------------------------------------ #
    #  KEYWORD 2: Calculate Data Overage                                   #
    # ------------------------------------------------------------------ #

    @keyword(name="Calculate Data Overage")
    def calculate_data_overage(
        self,
        used_mb: float,
        plan_mb: float,
        price_per_mb: float = 0.05,
    ) -> dict:
        """
        Calcula el excedente de datos consumidos respecto al plan contratado.

        Si el consumo es menor o igual al plan, el excedente es 0.
        El costo adicional se calcula multiplicando el excedente por
        ``price_per_mb``.

        Lanza ``DataError`` si algún valor numérico es negativo.

        Argumentos:
        - ``used_mb``: Megabytes consumidos en el período (float).
        - ``plan_mb``: Megabytes incluidos en el plan (float).
        - ``price_per_mb``: Precio por MB excedente en USD (float, default 0.05).

        Retorna:
        - Diccionario con claves ``overage_mb`` (float) y ``overage_cost`` (float).

        Ejemplos:
        | ${result} | Calculate Data Overage | 1500 | 1024 | 0.05 |
        | Log | Excedente: ${result}[overage_mb] MB |
        | Log | Costo adicional: $${result}[overage_cost] |
        """
        for name, value in [
            ("used_mb", used_mb),
            ("plan_mb", plan_mb),
            ("price_per_mb", price_per_mb),
        ]:
            try:
                value = float(value)
            except (TypeError, ValueError):
                raise DataError(
                    f"El argumento '{name}' debe ser numérico, "
                    f"se recibió: '{value}'."
                )
            if float(value) < 0:
                raise DataError(
                    f"El argumento '{name}' no puede ser negativo: {value}."
                )

        used_mb = float(used_mb)
        plan_mb = float(plan_mb)
        price_per_mb = float(price_per_mb)

        overage_mb = max(0.0, used_mb - plan_mb)
        overage_cost = round(overage_mb * price_per_mb, 4)

        return {"overage_mb": overage_mb, "overage_cost": overage_cost}

    # ------------------------------------------------------------------ #
    #  KEYWORD 3: Format Invoice                                           #
    # ------------------------------------------------------------------ #

    @keyword(name="Format Invoice")
    def format_invoice(
        self,
        customer_name: str,
        account_id: str,
        plan_name: str,
        base_amount: float,
        overage_cost: float = 0.0,
        tax_rate: float = 0.16,
    ) -> str:
        """
        Genera una cadena de texto con el resumen de una factura de
        telecomunicaciones.

        El formato incluye encabezado, datos del cliente, desglose de cargos
        y total con impuestos.

        Lanza ``DataError`` si ``customer_name`` o ``account_id`` están vacíos.

        Argumentos:
        - ``customer_name``: Nombre completo del cliente (str).
        - ``account_id``: Identificador de cuenta (str).
        - ``plan_name``: Nombre del plan contratado (str).
        - ``base_amount``: Cargo base mensual en USD (float).
        - ``overage_cost``: Costo por excedente en USD (float, default 0.0).
        - ``tax_rate``: Tasa de impuesto como decimal (float, default 0.16 = 16%).

        Retorna:
        - String multilínea con el resumen de la factura.

        Ejemplos:
        | ${factura} | Format Invoice | Juan Pérez | ACC-001 | Plan Pro | 29.99 |
        | Log | ${factura} |
        """
        if not customer_name or not customer_name.strip():
            raise DataError("El argumento 'customer_name' no puede estar vacío.")
        if not account_id or not account_id.strip():
            raise DataError("El argumento 'account_id' no puede estar vacío.")

        base_amount = float(base_amount)
        overage_cost = float(overage_cost)
        tax_rate = float(tax_rate)

        subtotal = base_amount + overage_cost
        tax_amount = round(subtotal * tax_rate, 2)
        total = round(subtotal + tax_amount, 2)

        invoice = (
            f"{'=' * 40}\n"
            f"  FACTURA TELECOMCORP S.A.\n"
            f"{'=' * 40}\n"
            f"  Cliente  : {customer_name.strip()}\n"
            f"  Cuenta   : {account_id.strip()}\n"
            f"  Plan     : {plan_name}\n"
            f"{'-' * 40}\n"
            f"  Cargo base          : ${base_amount:>8.2f}\n"
            f"  Excedente datos     : ${overage_cost:>8.2f}\n"
            f"  Subtotal            : ${subtotal:>8.2f}\n"
            f"  Impuesto ({tax_rate*100:.0f}%)       : ${tax_amount:>8.2f}\n"
            f"{'-' * 40}\n"
            f"  TOTAL               : ${total:>8.2f}\n"
            f"{'=' * 40}"
        )
        return invoice

    # ------------------------------------------------------------------ #
    #  KEYWORD 4: Parse Customer CSV                                       #
    # ------------------------------------------------------------------ #

    @keyword(name="Parse Customer CSV")
    def parse_customer_csv(self, file_path: str) -> list:
        """
        Lee un archivo CSV de clientes y retorna una lista de diccionarios.

        Cada fila del CSV se convierte en un diccionario usando la primera
        fila como cabecera. Se omiten filas con campos obligatorios vacíos
        (``customer_id``, ``name``, ``phone``).

        Lanza ``Error`` si el archivo no existe o no es legible.
        Lanza ``DataError`` si el CSV no contiene las columnas requeridas.

        Columnas requeridas: ``customer_id``, ``name``, ``phone``, ``plan``,
        ``used_mb``, ``plan_mb``.

        Argumentos:
        - ``file_path``: Ruta absoluta o relativa al archivo CSV (str).

        Retorna:
        - Lista de diccionarios, uno por fila válida del CSV.

        Ejemplos:
        | ${clientes} | Parse Customer CSV | ${CURDIR}/data/customers.csv |
        | Length Should Be | ${clientes} | 5 |
        """
        path = Path(file_path)

        if not path.exists():
            raise Error(f"Archivo CSV no encontrado: '{file_path}'")
        if not path.is_file():
            raise Error(f"La ruta no apunta a un archivo: '{file_path}'")

        required_columns = {"customer_id", "name", "phone", "plan", "used_mb", "plan_mb"}
        records = []

        try:
            with open(path, newline="", encoding="utf-8") as csv_file:
                reader = csv.DictReader(csv_file)

                # Validar columnas requeridas
                if reader.fieldnames is None:
                    raise DataError("El archivo CSV está vacío o no tiene cabecera.")

                actual_columns = {col.strip().lower() for col in reader.fieldnames}
                missing = required_columns - actual_columns
                if missing:
                    raise DataError(
                        f"El CSV no contiene las columnas requeridas: "
                        f"{sorted(missing)}. Columnas encontradas: {sorted(actual_columns)}"
                    )

                for row_num, row in enumerate(reader, start=2):
                    # Normalizar claves a minúsculas sin espacios
                    normalized = {k.strip().lower(): v.strip() for k, v in row.items()}

                    # Omitir filas con campos obligatorios vacíos
                    if not all(normalized.get(col) for col in ("customer_id", "name", "phone")):
                        continue

                    records.append(normalized)

        except (OSError, UnicodeDecodeError) as exc:
            raise Error(f"Error al leer el archivo CSV '{file_path}': {exc}") from exc

        return records

    # ------------------------------------------------------------------ #
    #  KEYWORD 5: Generate Test ID                                         #
    # ------------------------------------------------------------------ #

    @keyword(name="Generate Test ID")
    def generate_test_id(
        self,
        prefix: str = "TC",
        suffix: Optional[str] = None,
    ) -> str:
        """
        Genera un identificador único de prueba basado en UUID4.

        El identificador tiene el formato ``PREFIX-<uuid4_corto>[-SUFFIX]``,
        donde ``uuid4_corto`` son los primeros 8 caracteres del UUID en
        mayúsculas.

        Argumentos:
        - ``prefix``: Prefijo del identificador (str, default "TC").
        - ``suffix``: Sufijo opcional (str, default None).

        Retorna:
        - String con el identificador único, ej: ``TC-A3F2B1C4`` o
          ``TC-A3F2B1C4-SMOKE``.

        Ejemplos:
        | ${id} | Generate Test ID |
        | ${id} | Generate Test ID | prefix=REG |
        | ${id} | Generate Test ID | prefix=API | suffix=PROD |
        """
        if not prefix or not str(prefix).strip():
            raise DataError("El argumento 'prefix' no puede estar vacío.")

        short_uuid = str(uuid.uuid4()).replace("-", "")[:8].upper()
        test_id = f"{str(prefix).strip().upper()}-{short_uuid}"

        if suffix and str(suffix).strip():
            test_id = f"{test_id}-{str(suffix).strip().upper()}"

        return test_id
```

**Salida esperada:** El archivo se guarda sin errores. VS Code muestra sintaxis coloreada correctamente.

**Verificación:**
```bash
# Verificar que Python puede importar la librería sin errores
python -c "from libraries.telecom_utils.telecom_utils import TelecomUtils; print('OK:', TelecomUtils.ROBOT_LIBRARY_VERSION)"
```
Salida esperada: `OK: 1.0.0`

---

### Paso 2: Crear el archivo `pyproject.toml` y empaquetar la librería

**Objetivo:** Configurar el empaquetado estándar moderno con `pyproject.toml` e instalar la librería en modo editable para que sea accesible desde cualquier suite del entorno virtual.

#### Instrucciones

**2.1.** En el directorio `lab_05_02/` (no dentro de `libraries/`), crea el archivo `pyproject.toml`:

```toml
# lab_05_02/pyproject.toml
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.backends.legacy:build"

[project]
name = "telecom-utils-rf"
version = "1.0.0"
description = "Librería Robot Framework para operaciones de telecomunicaciones - TelecomCorp S.A."
readme = "README.md"
requires-python = ">=3.10"
license = { text = "MIT" }
authors = [
    { name = "Curso Robot Framework", email = "curso@example.com" }
]
keywords = ["robotframework", "telecom", "testing", "automation"]
classifiers = [
    "Programming Language :: Python :: 3",
    "Framework :: Robot Framework :: Library",
    "Intended Audience :: Developers",
    "Topic :: Software Development :: Testing",
]
dependencies = [
    "robotframework>=7.0",
]

[project.optional-dependencies]
dev = [
    "robotframework-datadriver[CSV]>=1.0",
]

[tool.setuptools.packages.find]
where = ["libraries"]

[tool.setuptools.package-dir]
"" = "libraries"
```

**2.2.** Crea un `README.md` mínimo requerido por el empaquetado:

```markdown
# TelecomUtils — Robot Framework Library

Librería personalizada de Robot Framework para operaciones de telecomunicaciones.

## Keywords disponibles
- `Validate Phone Number` — Valida formato E.164
- `Calculate Data Overage` — Calcula excedente de datos
- `Format Invoice` — Genera resumen de factura
- `Parse Customer CSV` — Lee CSV de clientes con validación
- `Generate Test ID` — Genera ID único de prueba con prefijo

## Instalación
```
pip install -e .
```
```

**2.3.** Instala la librería en modo editable desde el directorio `lab_05_02/`:

```bash
# Asegúrate de estar en lab_05_02/ con el venv activo
pip install -e .
```

**Salida esperada:**
```
Obtaining file:///.../.../lab_05_02
  Installing build dependencies ... done
  ...
Successfully installed telecom-utils-rf-1.0.0
```

**2.4.** Verifica la instalación:

```bash
pip show telecom-utils-rf
```

**Salida esperada:**
```
Name: telecom-utils-rf
Version: 1.0.0
Location: .../lab_05_02
Editable project location: .../lab_05_02
```

**2.5.** Verifica que Robot Framework puede encontrar la librería:

```bash
python -c "from telecom_utils.telecom_utils import TelecomUtils; lib = TelecomUtils(); print('Librería importada correctamente:', lib.ROBOT_LIBRARY_VERSION)"
```

**Salida esperada:**
```
Librería importada correctamente: 1.0.0
```

> **Nota sobre modo editable:** Con `pip install -e .`, cualquier cambio que hagas en `libraries/telecom_utils/telecom_utils.py` se refleja inmediatamente en el entorno virtual sin necesidad de reinstalar. Esto es ideal para desarrollo iterativo.

---

### Paso 3: Crear el archivo de datos CSV para las pruebas

**Objetivo:** Preparar el archivo CSV de clientes que usará tanto la suite data-driven como la keyword `Parse Customer CSV`.

#### Instrucciones

**3.1.** Crea el archivo `data/customers.csv` con datos de clientes ficticios de TelecomCorp:

```csv
customer_id,name,phone,plan,used_mb,plan_mb,email
CUST-001,Ana García,+5215512345678,Plan Básico,800,1024,ana.garcia@example.com
CUST-002,Carlos Mendoza,+5215598765432,Plan Pro,1500,1024,carlos.mendoza@example.com
CUST-003,Laura Torres,+5215511223344,Plan Premium,2200,2048,laura.torres@example.com
CUST-004,Pedro Ramírez,+5215544556677,Plan Básico,950,1024,pedro.ramirez@example.com
CUST-005,María López,+5215577889900,Plan Pro,1024,1024,maria.lopez@example.com
```

> **Nota:** Este CSV tiene las seis columnas requeridas por `Parse Customer CSV` más una columna extra `email` para demostrar que la keyword tolera columnas adicionales.

---

### Paso 4: Crear la suite de pruebas unitarias de la librería

**Objetivo:** Validar cada keyword de `TelecomUtils` de forma aislada antes de la integración, siguiendo el principio de pruebas por capas.

#### Instrucciones

**4.1.** Crea el archivo `tests/test_telecom_utils_unit.robot`:

```robotframework
*** Settings ***
Documentation     Suite de pruebas unitarias para la librería TelecomUtils.
...               Valida cada keyword de forma aislada, incluyendo casos
...               de éxito y casos de error esperado.
Library           telecom_utils.telecom_utils.TelecomUtils
Library           Collections

*** Variables ***
${CSV_PATH}       ${CURDIR}/../data/customers.csv

*** Test Cases ***

# --------------------------------------------------------- #
#  TC-001: Validate Phone Number — casos válidos             #
# --------------------------------------------------------- #
Validar Numero Telefonico Con Formato E164 Correcto
    [Documentation]    Verifica que números en formato E.164 son aceptados.
    [Tags]    unit    phone    smoke
    ${resultado}    Validate Phone Number    +5215512345678
    Should Be True    ${resultado}
    ${resultado2}    Validate Phone Number    +14155552671
    Should Be True    ${resultado2}

# --------------------------------------------------------- #
#  TC-002: Validate Phone Number — caso inválido             #
# --------------------------------------------------------- #
Validar Numero Telefonico Con Formato Incorrecto Lanza Error
    [Documentation]    Verifica que un número sin + lanza DataError.
    [Tags]    unit    phone    error
    Run Keyword And Expect Error    *inválido*    Validate Phone Number    5215512345678
    Run Keyword And Expect Error    *inválido*    Validate Phone Number    +521551234
    Run Keyword And Expect Error    *inválido*    Validate Phone Number    00525512345678

# --------------------------------------------------------- #
#  TC-003: Calculate Data Overage — sin excedente            #
# --------------------------------------------------------- #
Calcular Excedente Cuando Consumo Es Menor Al Plan
    [Documentation]    Verifica que no hay excedente cuando used_mb <= plan_mb.
    [Tags]    unit    overage
    ${result}    Calculate Data Overage    800    1024    0.05
    Should Be Equal As Numbers    ${result}[overage_mb]    0.0
    Should Be Equal As Numbers    ${result}[overage_cost]    0.0

# --------------------------------------------------------- #
#  TC-004: Calculate Data Overage — con excedente            #
# --------------------------------------------------------- #
Calcular Excedente Cuando Consumo Supera El Plan
    [Documentation]    Verifica cálculo correcto cuando used_mb > plan_mb.
    [Tags]    unit    overage
    ${result}    Calculate Data Overage    1500    1024    0.05
    Should Be Equal As Numbers    ${result}[overage_mb]    476.0
    # 476 * 0.05 = 23.8
    Should Be Equal As Numbers    ${result}[overage_cost]    23.8

# --------------------------------------------------------- #
#  TC-005: Format Invoice — factura completa                 #
# --------------------------------------------------------- #
Formatear Factura Con Todos Los Campos
    [Documentation]    Verifica que la factura contiene los datos esperados.
    [Tags]    unit    invoice
    ${factura}    Format Invoice
    ...    customer_name=Ana García
    ...    account_id=CUST-001
    ...    plan_name=Plan Básico
    ...    base_amount=19.99
    ...    overage_cost=5.00
    ...    tax_rate=0.16
    Should Contain    ${factura}    Ana García
    Should Contain    ${factura}    CUST-001
    Should Contain    ${factura}    Plan Básico
    Should Contain    ${factura}    TELECOMCORP

# --------------------------------------------------------- #
#  TC-006: Format Invoice — error con nombre vacío           #
# --------------------------------------------------------- #
Formatear Factura Con Nombre Vacio Lanza Error
    [Documentation]    Verifica que customer_name vacío lanza DataError.
    [Tags]    unit    invoice    error
    Run Keyword And Expect Error    *vacío*    Format Invoice
    ...    customer_name=${EMPTY}
    ...    account_id=CUST-001
    ...    plan_name=Plan Básico
    ...    base_amount=19.99

# --------------------------------------------------------- #
#  TC-007: Parse Customer CSV — lectura exitosa              #
# --------------------------------------------------------- #
Leer CSV De Clientes Con Datos Validos
    [Documentation]    Verifica que el CSV se lee y retorna 5 registros.
    [Tags]    unit    csv
    ${clientes}    Parse Customer CSV    ${CSV_PATH}
    Length Should Be    ${clientes}    5
    ${primer_cliente}    Get From List    ${clientes}    0
    Should Be Equal    ${primer_cliente}[customer_id]    CUST-001
    Should Be Equal    ${primer_cliente}[name]           Ana García

# --------------------------------------------------------- #
#  TC-008: Parse Customer CSV — archivo inexistente          #
# --------------------------------------------------------- #
Leer CSV Inexistente Lanza Error
    [Documentation]    Verifica que un archivo inexistente lanza Error.
    [Tags]    unit    csv    error
    Run Keyword And Expect Error    *no encontrado*
    ...    Parse Customer CSV    /ruta/inexistente/archivo.csv

# --------------------------------------------------------- #
#  TC-009: Generate Test ID — formato correcto               #
# --------------------------------------------------------- #
Generar ID De Prueba Con Prefijo Por Defecto
    [Documentation]    Verifica que el ID generado tiene el formato TC-XXXXXXXX.
    [Tags]    unit    uuid
    ${test_id}    Generate Test ID
    Should Match Regexp    ${test_id}    ^TC-[A-F0-9]{8}$

Generar ID De Prueba Con Prefijo Y Sufijo Personalizados
    [Documentation]    Verifica formato con prefijo y sufijo: REG-XXXXXXXX-SMOKE.
    [Tags]    unit    uuid
    ${test_id}    Generate Test ID    prefix=REG    suffix=SMOKE
    Should Match Regexp    ${test_id}    ^REG-[A-F0-9]{8}-SMOKE$

# --------------------------------------------------------- #
#  TC-010: Generate Test ID — prefijo vacío lanza error      #
# --------------------------------------------------------- #
Generar ID Con Prefijo Vacio Lanza Error
    [Documentation]    Verifica que prefix vacío lanza DataError.
    [Tags]    unit    uuid    error
    Run Keyword And Expect Error    *vacío*    Generate Test ID    prefix=${EMPTY}
```

**4.2.** Ejecuta la suite unitaria:

```bash
# Desde lab_05_02/
robot --outputdir results/unit tests/test_telecom_utils_unit.robot
```

**Salida esperada:**
```
==============================================================================
Test Telecom Utils Unit
==============================================================================
Validar Numero Telefonico Con Formato E164 Correcto              | PASS |
Validar Numero Telefonico Con Formato Incorrecto Lanza Error     | PASS |
Calcular Excedente Cuando Consumo Es Menor Al Plan               | PASS |
Calcular Excedente Cuando Consumo Supera El Plan                 | PASS |
Formatear Factura Con Todos Los Campos                           | PASS |
Formatear Factura Con Nombre Vacio Lanza Error                   | PASS |
Leer CSV De Clientes Con Datos Validos                           | PASS |
Leer CSV Inexistente Lanza Error                                 | PASS |
Generar ID De Prueba Con Prefijo Por Defecto                     | PASS |
Generar ID De Prueba Con Prefijo Y Sufijo Personalizados         | PASS |
Generar ID Con Prefijo Vacio Lanza Error                         | PASS |
==============================================================================
Test Telecom Utils Unit                                          | 11 PASS |
==============================================================================
Output:  .../results/unit/output.xml
Log:     .../results/unit/log.html
Report:  .../results/unit/report.html
```

**Verificación:** Todos los 11 casos deben mostrar `PASS`. Abre `results/unit/report.html` en el navegador para confirmar el reporte.

---

### Paso 5: Crear archivo de keywords reutilizables (capa de acción y negocio)

**Objetivo:** Demostrar la separación por capas creando un archivo Resource que consume `TelecomUtils` desde la capa de acción, siguiendo las convenciones de nombres del Módulo 5.

#### Instrucciones

**5.1.** Crea el archivo `resources/keywords/telecom_business_keywords.robot`:

```robotframework
*** Settings ***
Documentation     Keywords de capa de acción y negocio que consumen TelecomUtils.
...               Aplica separación por capas: este archivo es la capa de acción
...               que abstrae las llamadas directas a la librería TelecomUtils.
Library           telecom_utils.telecom_utils.TelecomUtils
Library           Collections
Library           String

*** Keywords ***

# ============================================================ #
#  CAPA DE ACCIÓN — abstrae llamadas directas a TelecomUtils    #
# ============================================================ #

Validar Y Registrar Número Telefónico
    [Documentation]    Valida un número E.164 y registra el resultado en el log.
    [Arguments]    ${numero}    ${nombre_cliente}
    ${valido}    Validate Phone Number    ${numero}
    Log    ✓ Número ${numero} de ${nombre_cliente} es válido (E.164)    level=INFO
    RETURN    ${valido}

Calcular Cargo Por Excedente De Datos
    [Documentation]    Calcula el excedente y retorna el costo formateado.
    [Arguments]    ${used_mb}    ${plan_mb}    ${price_per_mb}=0.05
    ${result}    Calculate Data Overage    ${used_mb}    ${plan_mb}    ${price_per_mb}
    Log    Excedente: ${result}[overage_mb] MB | Costo: $${result}[overage_cost]    level=INFO
    RETURN    ${result}

Generar Factura Para Cliente
    [Documentation]    Genera y registra la factura completa de un cliente.
    [Arguments]    ${nombre}    ${cuenta}    ${plan}    ${base}    ${excedente}=0.0
    ${factura}    Format Invoice
    ...    customer_name=${nombre}
    ...    account_id=${cuenta}
    ...    plan_name=${plan}
    ...    base_amount=${base}
    ...    overage_cost=${excedente}
    Log    \n${factura}    level=INFO
    RETURN    ${factura}

# ============================================================ #
#  CAPA DE NEGOCIO — flujos completos en lenguaje de dominio    #
# ============================================================ #

Procesar Cliente Y Generar Factura Completa
    [Documentation]    Flujo completo de negocio: valida teléfono, calcula
    ...                excedente y genera factura para un cliente.
    [Arguments]    ${customer_id}    ${name}    ${phone}    ${plan}
    ...            ${used_mb}    ${plan_mb}    ${base_price}=19.99

    # Capa de acción: validar teléfono
    Validar Y Registrar Número Telefónico    ${phone}    ${name}

    # Capa de acción: calcular excedente
    ${overage}    Calcular Cargo Por Excedente De Datos    ${used_mb}    ${plan_mb}

    # Capa de acción: generar factura
    ${factura}    Generar Factura Para Cliente
    ...    ${name}    ${customer_id}    ${plan}
    ...    ${base_price}    ${overage}[overage_cost]

    # Generar ID único para trazabilidad
    ${test_id}    Generate Test ID    prefix=PROC    suffix=${customer_id}
    Log    ID de procesamiento: ${test_id}    level=INFO

    RETURN    ${factura}

Cargar Y Validar Todos Los Clientes Del CSV
    [Documentation]    Lee el CSV, valida cada cliente y retorna estadísticas.
    [Arguments]    ${csv_path}
    ${clientes}    Parse Customer CSV    ${csv_path}
    ${total}       Get Length    ${clientes}
    ${validos}     Set Variable    ${0}

    FOR    ${cliente}    IN    @{clientes}
        TRY
            Validar Y Registrar Número Telefónico
            ...    ${cliente}[phone]    ${cliente}[name]
            ${validos}    Evaluate    ${validos} + 1
        EXCEPT    AS    ${error}
            Log    ✗ Teléfono inválido para ${cliente}[name]: ${error}    level=WARN
        END
    END

    Log    Clientes totales: ${total} | Teléfonos válidos: ${validos}    level=INFO
    RETURN    ${clientes}
```

---

### Paso 6: Crear la suite de integración con DataDriver

**Objetivo:** Integrar `TelecomUtils` con la suite data-driven, demostrando que la librería personalizada funciona en conjunto con `robotframework-datadriver` en un flujo de pruebas completo.

#### Instrucciones

**6.1.** Crea el archivo `tests/test_telecom_integration.robot`:

```robotframework
*** Settings ***
Documentation     Suite de integración: TelecomUtils + DataDriver.
...               Procesa clientes desde CSV y valida el flujo completo
...               de negocio de TelecomCorp S.A.
...
...               Prerrequisito: pip install robotframework-datadriver[CSV]
Library           telecom_utils.telecom_utils.TelecomUtils
Library           DataDriver    ${CURDIR}/../data/customers.csv
...               encoding=utf-8
...               dialect=excel
Resource          ${CURDIR}/../resources/keywords/telecom_business_keywords.robot
Library           OperatingSystem
Library           Collections

Suite Setup       Verificar Que El CSV Existe
Suite Teardown    Log    Suite de integración completada    level=INFO

*** Variables ***
${CSV_PATH}           ${CURDIR}/../data/customers.csv
${BASE_PRICE_BASICO}  19.99
${BASE_PRICE_PRO}     29.99
${BASE_PRICE_PREMIUM} 49.99

*** Test Cases ***
Procesar Cliente De TelecomCorp
    [Documentation]    Caso data-driven: procesa un cliente del CSV,
    ...                valida su teléfono y genera su factura.
    ...                Los datos son inyectados por DataDriver desde customers.csv.
    [Tags]    integration    data-driven    telecom
    [Setup]    Log    Iniciando procesamiento para: ${name}    level=INFO

    # Determinar precio base según plan
    ${base_price}    Obtener Precio Base Por Plan    ${plan}

    # Flujo completo de negocio
    ${factura}    Procesar Cliente Y Generar Factura Completa
    ...    customer_id=${customer_id}
    ...    name=${name}
    ...    phone=${phone}
    ...    plan=${plan}
    ...    used_mb=${used_mb}
    ...    plan_mb=${plan_mb}
    ...    base_price=${base_price}

    # Verificaciones de la factura generada
    Should Contain    ${factura}    ${name}
    Should Contain    ${factura}    ${customer_id}
    Should Contain    ${factura}    TELECOMCORP

    [Teardown]    Log    Procesamiento de ${customer_id} completado    level=INFO

*** Keywords ***
Verificar Que El CSV Existe
    [Documentation]    Verifica que el archivo CSV de datos existe antes de ejecutar.
    File Should Exist    ${CSV_PATH}
    Log    CSV verificado: ${CSV_PATH}    level=INFO

Obtener Precio Base Por Plan
    [Documentation]    Retorna el precio base según el nombre del plan.
    [Arguments]    ${nombre_plan}
    IF    'Básico' in '${nombre_plan}'
        RETURN    ${BASE_PRICE_BASICO}
    ELSE IF    'Pro' in '${nombre_plan}'
        RETURN    ${BASE_PRICE_PRO}
    ELSE
        RETURN    ${BASE_PRICE_PREMIUM}
    END
```

**6.2.** Crea una suite adicional que demuestra el uso de `Parse Customer CSV` de forma directa (sin DataDriver), para contrastar los dos enfoques:

```robotframework
# tests/test_csv_processing.robot
*** Settings ***
Documentation     Suite que demuestra Parse Customer CSV de TelecomUtils
...               procesando el archivo completo en un único test case.
Library           telecom_utils.telecom_utils.TelecomUtils
Resource          ${CURDIR}/../resources/keywords/telecom_business_keywords.robot
Library           Collections

*** Variables ***
${CSV_PATH}    ${CURDIR}/../data/customers.csv

*** Test Cases ***
Cargar Todos Los Clientes Y Validar Teléfonos
    [Documentation]    Carga el CSV completo y valida todos los teléfonos.
    [Tags]    integration    csv    bulk
    ${clientes}    Cargar Y Validar Todos Los Clientes Del CSV    ${CSV_PATH}
    ${total}       Get Length    ${clientes}
    Should Be Equal As Integers    ${total}    5
    Log    Total de clientes procesados: ${total}    level=INFO

Generar Facturas Para Todos Los Clientes Del CSV
    [Documentation]    Genera y registra facturas para todos los clientes.
    [Tags]    integration    invoice    bulk
    ${clientes}    Parse Customer CSV    ${CSV_PATH}

    FOR    ${cliente}    IN    @{clientes}
        ${overage}    Calculate Data Overage
        ...    ${cliente}[used_mb]    ${cliente}[plan_mb]

        ${factura}    Format Invoice
        ...    customer_name=${cliente}[name]
        ...    account_id=${cliente}[customer_id]
        ...    plan_name=${cliente}[plan]
        ...    base_amount=19.99
        ...    overage_cost=${overage}[overage_cost]

        Log    \n${factura}    level=INFO
        Should Contain    ${factura}    ${cliente}[name]
    END

Generar IDs Únicos Para Suite De Pruebas
    [Documentation]    Genera IDs únicos para cada cliente del CSV.
    [Tags]    integration    uuid
    ${clientes}    Parse Customer CSV    ${CSV_PATH}
    ${ids}         Create List

    FOR    ${cliente}    IN    @{clientes}
        ${test_id}    Generate Test ID
        ...    prefix=CUST
        ...    suffix=${cliente}[customer_id]
        Append To List    ${ids}    ${test_id}
        Log    ID generado: ${test_id}    level=INFO
    END

    # Verificar que todos los IDs son únicos
    ${unique_ids}    Remove Duplicates    ${ids}
    Length Should Be    ${unique_ids}    5
```

**6.3.** Ejecuta la suite de integración completa:

```bash
# Desde lab_05_02/ — ejecutar todas las suites de integración
robot --outputdir results/integration \
      --include integration \
      tests/test_telecom_integration.robot \
      tests/test_csv_processing.robot
```

**Windows (PowerShell):**
```powershell
robot --outputdir results\integration `
      --include integration `
      tests\test_telecom_integration.robot `
      tests\test_csv_processing.robot
```

**Salida esperada:**
```
==============================================================================
Results
==============================================================================
Test Telecom Integration :: Suite de integración: TelecomUtils + DataDriver
==============================================================================
Procesar Cliente De TelecomCorp -- CUST-001-Ana García               | PASS |
Procesar Cliente De TelecomCorp -- CUST-002-Carlos Mendoza           | PASS |
Procesar Cliente De TelecomCorp -- CUST-003-Laura Torres             | PASS |
Procesar Cliente De TelecomCorp -- CUST-004-Pedro Ramírez            | PASS |
Procesar Cliente De TelecomCorp -- CUST-005-María López              | PASS |
==============================================================================
Test Telecom Integration                                        | 5 PASS |
==============================================================================
Test Csv Processing
==============================================================================
Cargar Todos Los Clientes Y Validar Teléfonos                        | PASS |
Generar Facturas Para Todos Los Clientes Del CSV                     | PASS |
Generar IDs Únicos Para Suite De Pruebas                             | PASS |
==============================================================================
Test Csv Processing                                             | 3 PASS |
==============================================================================
```

---

### Paso 7: Verificar la documentación generada de la librería

**Objetivo:** Usar `python -m robot.libdoc` para generar la documentación HTML de `TelecomUtils` y verificar que los docstrings y metadatos son correctos.

#### Instrucciones

**7.1.** Genera la documentación HTML de la librería:

```bash
# Desde lab_05_02/
python -m robot.libdoc \
    telecom_utils.telecom_utils.TelecomUtils \
    results/TelecomUtils_doc.html
```

**Windows (PowerShell):**
```powershell
python -m robot.libdoc `
    telecom_utils.telecom_utils.TelecomUtils `
    results\TelecomUtils_doc.html
```

**7.2.** Abre el archivo generado en el navegador:

```bash
# Linux/macOS
open results/TelecomUtils_doc.html

# Windows
start results\TelecomUtils_doc.html
```

**Verificación:** El archivo HTML debe mostrar:
- Nombre de la librería: `TelecomUtils`
- Versión: `1.0.0`
- Scope: `SUITE`
- Las 5 keywords con sus argumentos, tipos y documentación completa.
- Los ejemplos de uso en formato de tabla RF.

---

## 7. Validación y Pruebas

### Ejecución completa del laboratorio

Ejecuta todas las suites en conjunto para obtener un reporte unificado:

```bash
# Desde lab_05_02/
robot --outputdir results/full_run \
      --report report_lab_05_02.html \
      --log log_lab_05_02.html \
      --name "Lab 05-00-02 TelecomUtils" \
      tests/
```

**Criterios de aceptación — todos deben cumplirse:**

| Criterio | Verificación |
|----------|-------------|
| 11 tests unitarios en PASS | `results/full_run/report_lab_05_02.html` → sección unitaria |
| 5 tests data-driven en PASS (uno por cliente) | Sección `test_telecom_integration` |
| 3 tests de procesamiento CSV en PASS | Sección `test_csv_processing` |
| Total: 19 tests, 0 FAIL | Línea final del reporte |
| Documentación HTML generada | `results/TelecomUtils_doc.html` existe y tiene 5 keywords |
| `pip show telecom-utils-rf` muestra versión 1.0.0 | Ejecutar en terminal |

### Verificación de la estructura final del proyecto

```bash
# Verificar estructura completa
find lab_05_02/ -type f | sort
```

**Estructura esperada:**
```
lab_05_02/libraries/telecom_utils/__init__.py
lab_05_02/libraries/telecom_utils/telecom_utils.py
lab_05_02/pyproject.toml
lab_05_02/README.md
lab_05_02/data/customers.csv
lab_05_02/resources/keywords/telecom_business_keywords.robot
lab_05_02/tests/test_telecom_utils_unit.robot
lab_05_02/tests/test_telecom_integration.robot
lab_05_02/tests/test_csv_processing.robot
lab_05_02/results/TelecomUtils_doc.html
```

### Verificación de keywords reconocidas por RF

```bash
python -m robot.libdoc telecom_utils.telecom_utils.TelecomUtils list
```

**Salida esperada:**
```
Calculate Data Overage
Format Invoice
Generate Test ID
Parse Customer CSV
Validate Phone Number
```

---

## 8. Resolución de Problemas

### Problema 1: `ModuleNotFoundError: No module named 'telecom_utils'` al ejecutar la suite

**Síntomas:**
```
[ ERROR ] Error in file '.../tests/test_telecom_utils_unit.robot':
Importing library 'telecom_utils.telecom_utils.TelecomUtils' failed:
ModuleNotFoundError: No module named 'telecom_utils'
```

**Causa:**
La librería no fue instalada correctamente con `pip install -e .`, o el entorno virtual no está activo al momento de ejecutar `robot`. En modo editable, Python busca el paquete en el `sys.path` del entorno virtual; si el venv no está activo, usa el Python del sistema donde el paquete no existe.

**Solución:**

1. Verifica que el venv está activo:
   ```bash
   # El prompt debe mostrar (venv) al inicio
   which python   # Linux/macOS → debe apuntar a venv/bin/python
   where python   # Windows → debe apuntar a venv\Scripts\python.exe
   ```

2. Si el venv no está activo, actívalo y reinstala:
   ```bash
   # Linux/macOS
   source ../venv/bin/activate
   
   # Windows
   ..\venv\Scripts\Activate.ps1
   
   # Reinstalar desde lab_05_02/
   pip install -e .
   ```

3. Verifica que la instalación fue exitosa:
   ```bash
   pip show telecom-utils-rf
   python -c "import telecom_utils; print('OK')"
   ```

4. Si persiste, verifica que `pyproject.toml` tiene la configuración correcta de `[tool.setuptools.package-dir]` apuntando a `libraries/`.

---

### Problema 2: DataDriver no inyecta variables — `Variable '${customer_id}' not found`

**Síntomas:**
```
[ ERROR ] Test 'Procesar Cliente De TelecomCorp' failed:
Variable '${customer_id}' not found.
```
O bien, DataDriver genera solo 1 test case en lugar de 5.

**Causa:**
Hay dos causas posibles: (a) el CSV tiene nombres de columnas con espacios o mayúsculas inconsistentes que DataDriver no mapea correctamente a variables RF, o (b) `robotframework-datadriver` fue instalado sin el extra `[CSV]` y no puede leer el formato CSV correctamente.

**Solución:**

1. Verifica que DataDriver tiene los extras CSV instalados:
   ```bash
   pip show robotframework-datadriver
   # Si no aparece, reinstalar con extras:
   pip install "robotframework-datadriver[CSV]"
   ```

2. Verifica las cabeceras del CSV — deben coincidir exactamente con los nombres de variables usados en la suite:
   ```bash
   head -1 data/customers.csv
   # Salida esperada: customer_id,name,phone,plan,used_mb,plan_mb,email
   ```
   Los nombres de columna en el CSV se convierten en variables RF como `${customer_id}`, `${name}`, etc. No deben tener espacios ni caracteres especiales.

3. Prueba con una ejecución de diagnóstico para ver qué variables inyecta DataDriver:
   ```bash
   robot --dryrun tests/test_telecom_integration.robot
   ```
   El dry-run mostrará cuántos test cases genera DataDriver (debe ser 5) sin ejecutar las keywords.

4. Si el CSV tiene codificación diferente a UTF-8, ajusta el parámetro en la importación:
   ```robotframework
   Library    DataDriver    ${CURDIR}/../data/customers.csv
   ...        encoding=utf-8-sig    # Para archivos con BOM de Windows
   ```

---

## 9. Limpieza del Entorno

Una vez completado el laboratorio y verificados todos los criterios de aceptación, realiza los siguientes pasos de limpieza:

**9.1.** Elimina los artefactos de ejecución temporales (opcional, conserva los reportes HTML):

```bash
# Desde lab_05_02/
# Eliminar solo archivos XML de output (pesados, no necesarios para revisión)
find results/ -name "output.xml" -delete   # Linux/macOS
```

```powershell
# Windows
Get-ChildItem -Path results\ -Filter output.xml -Recurse | Remove-Item
```

**9.2.** Crea una copia de respaldo del proyecto completo (recomendado antes de continuar al siguiente módulo):

```bash
# Desde el directorio raíz del curso
cp -r lab_05_02/ lab_05_02_backup/   # Linux/macOS
```

```powershell
# Windows
Copy-Item -Recurse lab_05_02\ lab_05_02_backup\
```

**9.3.** La librería `telecom-utils-rf` permanece instalada en el venv en modo editable — esto es intencional, ya que los laboratorios posteriores pueden reutilizarla. Si deseas desinstalarla:

```bash
pip uninstall telecom-utils-rf -y
```

**9.4.** Verifica el estado final del entorno:

```bash
pip list | grep -E "robotframework|telecom"
```

**Salida esperada (con librería instalada):**
```
robotframework                7.x.x
robotframework-datadriver     1.x.x
telecom-utils-rf              1.0.0
```

---

## 10. Resumen

### Lo que construiste en este laboratorio

En este laboratorio completaste el ciclo completo de desarrollo de una librería Robot Framework personalizada:

1. **Implementaste `TelecomUtils`** con cinco keywords Python decoradas con `@keyword`, cada una con type hints, docstrings en formato RF y manejo de errores usando `robot.api.exceptions`. Las keywords cubren validación de teléfonos (regex E.164), cálculo de excedentes, formateo de facturas, lectura de CSV y generación de UUIDs.

2. **Empaquetaste la librería** con `pyproject.toml` usando el build backend de setuptools, y la instalaste en modo editable (`pip install -e .`), lo que permite modificar el código fuente sin reinstalar.

3. **Validaste cada keyword de forma aislada** con 11 tests unitarios que cubren tanto casos de éxito como casos de error esperado, usando `Run Keyword And Expect Error` para verificar el comportamiento ante entradas inválidas.

4. **Aplicaste separación por capas**: `TelecomUtils` opera en la capa técnica, `telecom_business_keywords.robot` la consume desde la capa de acción, y las suites de tests expresan flujos en la capa de negocio — siguiendo exactamente el patrón estudiado en la Lección 5.1.

5. **Integraste la librería con DataDriver**, demostrando que una librería personalizada se comporta como cualquier otra librería de Robot Framework dentro de un flujo data-driven.

### Conceptos clave consolidados

| Concepto | Aplicación en el laboratorio |
|----------|------------------------------|
| `@keyword(name=...)` | Nombre personalizado visible en RF, distinto al nombre Python |
| `ROBOT_LIBRARY_SCOPE = "SUITE"` | La instancia de la librería se comparte en toda la suite |
| `robot.api.exceptions.DataError` | Error que RF reporta como fallo de keyword con mensaje claro |
| `pip install -e .` | Modo editable: cambios en `.py` se reflejan sin reinstalar |
| `pyproject.toml` | Estándar moderno de empaquetado Python (PEP 517/518) |
| Separación por capas | Capa técnica (librería) → acción (resource) → negocio (test) |

### Recursos adicionales

- [Robot Framework — Creación de librerías Python](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#creating-test-libraries)
- [robot.api.deco — Decorador @keyword](https://robot-framework.readthedocs.io/en/stable/autodoc/robot.api.html#robot.api.deco.keyword)
- [robot.api.exceptions — Excepciones nativas RF](https://robot-framework.readthedocs.io/en/stable/autodoc/robot.api.html#module-robot.api.exceptions)
- [pyproject.toml — Guía oficial de setuptools](https://setuptools.pypa.io/en/latest/userguide/pyproject_config.html)
- [robot.libdoc — Generador de documentación](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#libdoc)
- [Awesome Robot Framework — Librerías de la comunidad](https://github.com/fkromer/awesome-robotframework)

---
