"""Tests unitarios (pytest) para simulacro_rfcp.py — Práctica 18, Sesión 9."""
from pathlib import Path
import sys

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from simulacro_rfcp import calificar_simulacro, cargar_preguntas  # noqa: E402

DATA = Path(__file__).resolve().parents[1] / "data"


def test_cargar_preguntas_lee_las_10_preguntas_del_fixture():
    preguntas = cargar_preguntas(DATA / "preguntas_rfcp.json")
    assert len(preguntas) == 10


def test_cargar_preguntas_archivo_inexistente_lanza_file_not_found():
    with pytest.raises(FileNotFoundError):
        cargar_preguntas(DATA / "no_existe.json")


def test_calificar_simulacro_con_todas_correctas_aprueba_con_100():
    preguntas = cargar_preguntas(DATA / "preguntas_rfcp.json")
    respuestas = {p["id"]: p["respuesta_correcta"] for p in preguntas}

    resultado = calificar_simulacro(preguntas, respuestas)

    assert resultado.correctas == 10
    assert resultado.porcentaje == 100.0
    assert resultado.aprobado is True


def test_calificar_simulacro_con_todas_incorrectas_no_aprueba():
    preguntas = cargar_preguntas(DATA / "preguntas_rfcp.json")
    respuestas = {p["id"]: "respuesta-deliberadamente-incorrecta" for p in preguntas}

    resultado = calificar_simulacro(preguntas, respuestas)

    assert resultado.correctas == 0
    assert resultado.porcentaje == 0.0
    assert resultado.aprobado is False


def test_calificar_simulacro_con_70_porciento_exacto_aprueba():
    preguntas = cargar_preguntas(DATA / "preguntas_rfcp.json")
    respuestas = {p["id"]: p["respuesta_correcta"] for p in preguntas}
    # Marcar 3 de 10 como incorrectas -> 70% exacto (umbral de aprobación)
    for p in preguntas[:3]:
        respuestas[p["id"]] = "incorrecta"

    resultado = calificar_simulacro(preguntas, respuestas)

    assert resultado.porcentaje == 70.0
    assert resultado.aprobado is True


def test_calificar_simulacro_con_pregunta_sin_responder_la_cuenta_como_incorrecta():
    preguntas = cargar_preguntas(DATA / "preguntas_rfcp.json")
    respuestas = {p["id"]: p["respuesta_correcta"] for p in preguntas[1:]}  # falta la pregunta 1

    resultado = calificar_simulacro(preguntas, respuestas)

    assert resultado.correctas == 9
