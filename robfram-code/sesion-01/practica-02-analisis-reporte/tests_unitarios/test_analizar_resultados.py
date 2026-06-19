"""Tests unitarios (pytest) para analizar_resultados.py — Práctica 2, Sesión 1.

Se ejecutan contra un output.xml real (no inventado): generado corriendo
tests/suite_demo.robot con `robot`, copiado como fixture en
fixtures/output_1pass_1fail.xml.
"""
from pathlib import Path

import pytest

import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from analizar_resultados import Metricas, analizar_resultados  # noqa: E402

FIXTURES = Path(__file__).parent / "fixtures"


def test_analiza_output_real_con_un_pass_y_un_fail():
    metricas = analizar_resultados(FIXTURES / "output_1pass_1fail.xml")

    assert metricas.total == 2
    assert metricas.passed == 1
    assert metricas.failed == 1


def test_pass_rate_se_calcula_correctamente():
    metricas = analizar_resultados(FIXTURES / "output_1pass_1fail.xml")

    assert metricas.pass_rate == 50.0


def test_archivo_inexistente_lanza_file_not_found():
    with pytest.raises(FileNotFoundError):
        analizar_resultados(FIXTURES / "no_existe.xml")


def test_metricas_pass_rate_con_cero_tests_no_divide_por_cero():
    metricas = Metricas(total=0, passed=0, failed=0)

    assert metricas.pass_rate == 0.0


def test_metricas_pass_rate_con_todos_pasados():
    metricas = Metricas(total=5, passed=5, failed=0)

    assert metricas.pass_rate == 100.0


def test_analiza_output_real_incluye_tests_omitidos_en_el_total():
    metricas = analizar_resultados(FIXTURES / "output_1pass_1fail_1skip.xml")

    assert metricas.skipped == 1
    assert metricas.total == 3
    assert metricas.passed == 1
    assert metricas.failed == 1


def test_pass_rate_considera_omitidos_en_el_denominador():
    metricas = analizar_resultados(FIXTURES / "output_1pass_1fail_1skip.xml")

    # 1 de 3 pasados -> 33.3%, no 50% (si se ignorara skip en el total)
    assert metricas.pass_rate == 33.3


def test_ruta_que_es_un_directorio_lanza_file_not_found():
    with pytest.raises(FileNotFoundError):
        analizar_resultados(FIXTURES)
