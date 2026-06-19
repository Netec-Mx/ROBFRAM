"""Genera Capitulo02.pptx — ver Capitulo01/generar.py para la explicación
del flujo (extraer subconjunto + reescribir texto simplificado)."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo02.pptx"

INDICES = [67, 68, 69, 72, 80, 81, 83, 84, 86, 87, 90, 97, 98, 102, 103, 107, 114, 115, 116, 118, 120]

REEMPLAZOS = {
    1: {  # 2.1 divider
        4: [
            "Un test case dice QUÉ se prueba. Una keyword dice CÓMO se hace.",
            "Las librerías (BuiltIn, Collections, OperatingSystem) ponen las",
            "keywords ya construidas a tu disposición.",
        ],
    },
    4: {  # 2.2 divider
        4: [
            "Tres tipos de variables en Robot Framework: escalares (${...})",
            "para un solo valor, listas (@{...}) para varios valores, y",
            "diccionarios (&{...}) para pares clave-valor.",
        ],
    },
    8: {  # 2.3 divider
        4: [
            "Cuando una suite crece, conviene separar las keywords en un",
            "archivo Resource — así cualquier suite puede reutilizarlas",
            "sin duplicar código.",
        ],
    },
    11: {  # 2.4 divider
        4: [
            "Dos herramientas para ordenar suites grandes: los tags (para",
            "filtrar qué se ejecuta) y Setup/Teardown (para preparar y",
            "limpiar antes/después de los tests).",
        ],
    },
    18: {  # Práctica 3
        4: [
            "Objetivo:",
            "Diseñar una suite con keywords reutilizables, importar un",
            "archivo Resource y validar datos con variables compartidas.",
            "",
            "Guía completa: robfram-guide/Capitulo02/Practica3.md",
        ],
    },
    19: {  # Práctica 4
        4: [
            "Objetivo:",
            "Implementar Suite/Test Setup y Teardown, y ejecutar",
            "subconjuntos de tests usando tags de inclusión/exclusión.",
            "",
            "Guía completa: robfram-guide/Capitulo02/Practica4.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
