"""Genera Capitulo05.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo05.pptx"

INDICES = [227, 228, 229, 233, 236, 237, 239, 247, 248, 251, 255, 258, 261, 262, 268, 279, 280, 281, 283, 285]

REEMPLAZOS = {
    1: {  # 5.1 divider
        4: [
            "El patrón de capas (técnica -> acción -> negocio) que viste en",
            "BDD aplica a cualquier suite. Convenciones de nombres",
            "consistentes reducen la curva de entrada de un equipo nuevo.",
        ],
    },
    4: {  # 5.2 divider
        4: [
            "Cuando la misma lógica se valida con docenas de combinaciones",
            "de datos, DataDriver genera un test por cada fila de un CSV",
            "externo — separa la lógica de los datos.",
        ],
    },
    7: {  # 5.3 divider
        4: [
            "Cuando las librerías nativas no alcanzan, escribes tus propias",
            "keywords en Python. Cualquier función pública se convierte",
            "automáticamente en keyword.",
        ],
    },
    12: {  # 5.4 divider
        4: [
            "Cuando un equipo crece, las librerías Python propias se",
            "benefician de empaquetarse (pip install) y versionarse con",
            "SemVer, en vez de copiarse manualmente entre proyectos.",
        ],
    },
    17: {  # Práctica 9
        4: [
            "Objetivo:",
            "Implementar pruebas parametrizadas desde un CSV externo y",
            "generar reportes segmentados por tag de ambiente y prioridad.",
            "",
            "Guía completa: robfram-guide/Capitulo05/Practica9.md",
        ],
    },
    18: {  # Práctica 10
        4: [
            "Objetivo:",
            "Desarrollar un keyword personalizado en Python con",
            "documentación, probarlo con pytest e integrarlo en una suite.",
            "",
            "Guía completa: robfram-guide/Capitulo05/Practica10.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
