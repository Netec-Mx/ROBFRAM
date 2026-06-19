"""Genera Capitulo08.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo08.pptx"

INDICES = [399, 400, 401, 404, 406, 410, 412, 415, 416, 422, 423, 424, 427, 432, 437, 447, 448, 449, 451, 453]

REEMPLAZOS = {
    1: {  # 8.1 divider
        4: [
            "En RPA, los archivos son el medio de entrada/salida más",
            "común. csv, openpyxl y fpdf2 cubren CSV, Excel y PDF sin",
            "depender de licencias de Office.",
        ],
    },
    4: {  # 8.2 divider
        4: [
            "Un proceso RPA modela entradas (archivo, CLI, API) y salidas",
            "(resultado operativo). El logging explícito por etapa es",
            "indispensable cuando el proceso corre desatendido.",
        ],
    },
    7: {  # 8.3 divider
        4: [
            "Los procesos RPA reales combinan tecnologías: extraer un",
            "dato web, registrarlo vía API, archivarlo localmente — en un",
            "solo flujo secuencial.",
        ],
    },
    10: {  # 8.4 divider
        4: [
            "Un fallo en una capa no debe producir un error genérico.",
            "Un checklist de calidad explícito localiza en cuál de las",
            "capas ocurrió el problema.",
        ],
    },
    13: {  # 8.5 divider
        4: [
            "output.xml sirve como registro de auditoría completo, sin",
            "sistemas de logging adicionales. Estandarizar el formato de",
            "los mensajes facilita el diagnóstico entre procesos.",
        ],
    },
    17: {  # Práctica 15
        4: [
            "Objetivo:",
            "Construir un flujo que lea datos de Excel, los transforme y",
            "genere un reporte PDF con logging de cada etapa.",
            "",
            "Guía completa: robfram-guide/Capitulo08/Practica15.md",
        ],
    },
    18: {  # Práctica 16
        4: [
            "Objetivo:",
            "Implementar un proceso RPA completo que integre web, API y",
            "archivos, con checklist de calidad explícito.",
            "",
            "Guía completa: robfram-guide/Capitulo08/Practica16.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
