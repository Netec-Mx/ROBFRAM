"""Genera data/clientes.xlsx — el archivo de entrada de la Práctica 15.

Se ejecuta una sola vez para crear el fixture; el .xlsx resultante se
versiona en el repositorio como dato de prueba (no se regenera en cada
ejecución de la suite).
"""
from pathlib import Path

import openpyxl

RUTA_SALIDA = Path(__file__).parent.parent / "data" / "clientes.xlsx"

CLIENTES = [
    ("Ana Pérez", "Premium", 85, 150.0),
    ("Luis Gómez", "Básico", 35, 80.0),
    ("María Díaz", "Premium", 120, 150.0),
    ("Carlos Ruiz", "Básico", 15, 80.0),
]


def generar() -> None:
    wb = openpyxl.Workbook()
    hoja = wb.active
    hoja.title = "Clientes"
    hoja.append(["nombre", "plan", "consumo_gb", "costo_base"])
    for fila in CLIENTES:
        hoja.append(fila)
    RUTA_SALIDA.parent.mkdir(parents=True, exist_ok=True)
    wb.save(RUTA_SALIDA)
    print(f"Generado: {RUTA_SALIDA}")


if __name__ == "__main__":
    generar()
