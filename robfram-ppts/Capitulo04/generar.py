"""Genera Capitulo04.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo04.pptx"

INDICES = [174, 175, 176, 177, 178, 180, 181, 183, 184, 185, 191, 193, 194, 196, 197, 205, 220, 221, 222, 224, 226]

REEMPLAZOS = {
    1: {  # 4.1 divider
        4: [
            "BDD describe el comportamiento del sistema en lenguaje de",
            "negocio, no de implementación. Reduce la brecha entre TI y",
            "negocio — clave en procesos regulados de telecomunicaciones.",
        ],
    },
    7: {  # 4.2 divider
        4: [
            "Given/When/Then no son sintaxis especial: son texto que Robot",
            "Framework descarta antes de buscar la keyword. Sirven solo",
            "para que un humano entienda el rol de cada paso.",
        ],
    },
    12: {  # 4.3 divider
        4: [
            "Given/When/Then no basta si la keyword detrás sigue siendo",
            "técnica. El valor real aparece al separar en 3 capas: test",
            "case (negocio), dominio (traducción), técnica (cómo).",
        ],
    },
    15: {  # 4.4 divider
        4: [
            "Un escenario agnóstico describe una regla de negocio sin",
            "mencionar tecnología. Las carpetas separan features/ (negocio)",
            "de technical/ (implementación).",
        ],
    },
    18: {  # Práctica 7
        4: [
            "Objetivo:",
            "Traducir un proceso de negocio real (activación de servicio)",
            "a escenarios Gherkin funcionales en Robot Framework.",
            "",
            "Guía completa: robfram-guide/Capitulo04/Practica7.md",
        ],
    },
    19: {  # Práctica 8
        4: [
            "Objetivo:",
            "Migrar un test tradicional hacia BDD con separación de la",
            "capa de negocio y la capa técnica.",
            "",
            "Guía completa: robfram-guide/Capitulo04/Practica8.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
