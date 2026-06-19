"""Tests unitarios (pytest) para ValidadorTelecom.py — Práctica 10, Sesión 5.

Se prueban las funciones Python directamente, sin pasar por Robot
Framework — así se valida la lógica antes de integrarla como keyword.
"""
from pathlib import Path
import sys

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "libs"))

from ValidadorTelecom import calcular_costo_total, validar_numero_telefono  # noqa: E402


@pytest.mark.parametrize(
    "numero,esperado",
    [
        ("50212345", True),
        ("20123456", True),
        ("70123456", True),
        ("80123456", False),  # fuera de rango (8 no es 2-7)
        ("1234567", False),  # solo 7 dígitos
        ("123456789", False),  # 9 dígitos
        ("abcdefgh", False),  # no numérico
    ],
)
def test_validar_numero_telefono(numero, esperado):
    assert validar_numero_telefono(numero) is esperado


def test_calcular_costo_total_con_impuesto_por_defecto():
    assert calcular_costo_total(100) == 112.0


def test_calcular_costo_total_con_impuesto_personalizado():
    assert calcular_costo_total(100, impuesto_porcentaje=10) == 110.0


def test_calcular_costo_total_redondea_a_dos_decimales():
    assert calcular_costo_total(33.333, impuesto_porcentaje=12) == 37.33


def test_calcular_costo_total_con_costo_negativo_lanza_value_error():
    with pytest.raises(ValueError):
        calcular_costo_total(-50)
