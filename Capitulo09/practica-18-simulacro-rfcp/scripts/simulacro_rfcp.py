"""Práctica 18 — Sesión 9.

Motor de calificación para el simulacro de certificación RFCP: carga
preguntas desde JSON, califica las respuestas de un participante y
determina si aprueba según el umbral de la certificación real (70%).
"""
from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

UMBRAL_APROBACION = 70.0


@dataclass
class ResultadoSimulacro:
    total_preguntas: int
    correctas: int
    porcentaje: float
    aprobado: bool


def cargar_preguntas(ruta_json: str | Path) -> list[dict]:
    """Carga las preguntas del simulacro desde un archivo JSON.

    Raises:
        FileNotFoundError: si la ruta no existe.
    """
    ruta = Path(ruta_json)
    if not ruta.is_file():
        raise FileNotFoundError(f"No existe el archivo: {ruta}")
    with ruta.open(encoding="utf-8") as f:
        return json.load(f)


def calificar_simulacro(preguntas: list[dict], respuestas: dict[int, str]) -> ResultadoSimulacro:
    """Califica las respuestas de un participante contra las preguntas.

    Args:
        preguntas: lista de preguntas (ver estructura en preguntas_rfcp.json).
        respuestas: diccionario {id_pregunta: respuesta_dada}.

    Returns:
        ResultadoSimulacro con el detalle de la calificación.
    """
    total = len(preguntas)
    correctas = 0
    for pregunta in preguntas:
        respuesta_dada = respuestas.get(pregunta["id"])
        if respuesta_dada == pregunta["respuesta_correcta"]:
            correctas += 1

    porcentaje = round((correctas / total) * 100, 1) if total else 0.0
    return ResultadoSimulacro(
        total_preguntas=total,
        correctas=correctas,
        porcentaje=porcentaje,
        aprobado=porcentaje >= UMBRAL_APROBACION,
    )


if __name__ == "__main__":
    import sys

    ruta_preguntas = sys.argv[1] if len(sys.argv) > 1 else "data/preguntas_rfcp.json"
    preguntas = cargar_preguntas(ruta_preguntas)
    print(f"Simulacro RFCP cargado: {len(preguntas)} preguntas.")
    for p in preguntas:
        print(f"\n{p['id']}. {p['pregunta']}")
        for opcion in p["opciones"]:
            print(f"   - {opcion}")
