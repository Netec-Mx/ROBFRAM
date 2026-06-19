"""Genera Capitulo07.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo07.pptx"

INDICES = [347, 348, 349, 350, 353, 354, 356, 359, 365, 366, 371, 375, 376, 377, 379, 388, 392, 393, 394, 396, 398]

REEMPLAZOS = {
    1: {  # 7.1 divider
        4: [
            "REST organiza recursos como URLs operadas con verbos HTTP:",
            "GET (leer), POST (crear), PUT (reemplazar), DELETE (eliminar).",
            "Los códigos de estado (2xx/4xx/5xx) comunican el resultado.",
        ],
    },
    5: {  # 7.2 divider
        4: [
            "El esquema Bearer Token transmite la credencial en el header",
            "Authorization. Create Session mantiene configuración",
            "persistente entre peticiones de toda la suite.",
        ],
    },
    8: {  # 7.3 divider
        4: [
            "La sintaxis extendida de RF accede a valores anidados del",
            "JSON sin librerías adicionales. Contract testing valida",
            "estructura, no solo valores puntuales.",
        ],
    },
    12: {  # 7.4 divider
        4: [
            "Suite smoke: pocos casos críticos, cada despliegue, rápida.",
            "Suite regresión: cobertura completa, antes de release.",
            "expected_status=any habilita pruebas negativas deliberadas.",
        ],
    },
    18: {  # Práctica 13
        4: [
            "Objetivo:",
            "Consumir endpoints REST autenticados con token, validar",
            "estructura y valores de respuesta JSON.",
            "",
            "Guía completa: robfram-guide/Capitulo07/Practica13.md",
        ],
    },
    19: {  # Práctica 14
        4: [
            "Objetivo:",
            "Construir una suite parametrizada desde CSV que cubra",
            "escenarios positivos y negativos con tags smoke/regresion.",
            "",
            "Guía completa: robfram-guide/Capitulo07/Practica14.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
