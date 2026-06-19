"""Genera Capitulo09.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo09.pptx"

INDICES = [454, 455, 456, 458, 460, 461, 465, 466, 467, 470, 472, 474, 475, 479, 487, 490, 491, 492, 494, 496, 499]

REEMPLAZOS = {
    1: {  # 9.1 divider
        4: [
            "Ninguna opción de CLI modifica los archivos .robot. --variable,",
            "--include/--exclude, --suite y --rerunfailed cubren la mayoría",
            "de las necesidades de ejecución avanzada.",
        ],
    },
    6: {  # 9.2 divider
        4: [
            "output.xml es la fuente de verdad. rebot regenera y combina",
            "reportes sin reejecutar tests — rebot --merge es la base del",
            "patrón ejecutar/reintentar/combinar.",
        ],
    },
    11: {  # 9.3 divider
        4: [
            "Un pipeline CI/CD ejecuta smoke en cada commit y regresión",
            "antes de release. Un quality gate usa el exit code de robot",
            "para decidir si el pipeline continúa.",
        ],
    },
    17: {  # Práctica 17
        4: [
            "Objetivo:",
            "Dominar la ejecución selectiva de suites por tag, el rerun",
            "automático de fallidos y la combinación de reportes con rebot.",
            "",
            "Guía completa: robfram-guide/Capitulo09/Practica17.md",
        ],
    },
    18: {  # Práctica 18
        4: [
            "Objetivo:",
            "Resolver preguntas tipo certificación RFCP y presentar un",
            "plan de adopción regional de automatización con RF.",
            "",
            "Guía completa: robfram-guide/Capitulo09/Practica18.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
