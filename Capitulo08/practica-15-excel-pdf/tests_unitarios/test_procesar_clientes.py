"""Tests unitarios (pytest) para procesar_clientes.py — Práctica 15, Sesión 8."""
from pathlib import Path
import sys

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from procesar_clientes import (  # noqa: E402
    Cliente,
    clasificar_consumo,
    generar_reporte_pdf,
    leer_clientes_excel,
    transformar_clientes,
)

DATA = Path(__file__).resolve().parents[1] / "data"


@pytest.mark.parametrize(
    "consumo,esperado",
    [(35, "bajo"), (49.9, "bajo"), (50, "medio"), (85, "medio"), (99.9, "medio"), (100, "alto"), (120, "alto")],
)
def test_clasificar_consumo(consumo, esperado):
    assert clasificar_consumo(consumo) == esperado


def test_leer_clientes_excel_lee_los_4_clientes_del_fixture():
    clientes = leer_clientes_excel(DATA / "clientes.xlsx")
    assert len(clientes) == 4
    assert clientes[0].nombre == "Ana Pérez"
    assert clientes[0].plan == "Premium"


def test_leer_clientes_excel_archivo_inexistente_lanza_file_not_found():
    with pytest.raises(FileNotFoundError):
        leer_clientes_excel(DATA / "no_existe.xlsx")


def test_transformar_clientes_calcula_costo_con_iva():
    clientes = [Cliente(nombre="Ana", plan="Premium", consumo_gb=85, costo_base=150.0)]
    transformados = transformar_clientes(clientes)
    assert transformados[0].costo_total == 168.0  # 150 * 1.12
    assert transformados[0].clasificacion_consumo == "medio"


def test_transformar_clientes_no_muta_la_lista_original():
    clientes = [Cliente(nombre="Ana", plan="Premium", consumo_gb=85, costo_base=150.0)]
    transformar_clientes(clientes)
    assert clientes[0].costo_total == 0.0  # la lista original no cambió


def test_generar_reporte_pdf_crea_un_archivo(tmp_path):
    clientes = transformar_clientes(leer_clientes_excel(DATA / "clientes.xlsx"))
    ruta_pdf = generar_reporte_pdf(clientes, tmp_path / "reporte.pdf")
    assert ruta_pdf.is_file()
    assert ruta_pdf.stat().st_size > 0
