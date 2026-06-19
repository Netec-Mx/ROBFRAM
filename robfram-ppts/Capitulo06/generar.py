"""Genera Capitulo06.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo06.pptx"

INDICES = [286, 287, 288, 291, 296, 297, 300, 307, 308, 309, 318, 319, 323, 327, 328, 329, 338, 340, 341, 342, 344, 346]

REEMPLAZOS = {
    1: {  # 6.1 divider
        4: [
            "SeleniumLibrary conecta Robot Framework con un navegador real",
            "(o headless) vía Selenium WebDriver. Desde Selenium 4.6, ya no",
            "necesitas instalar manualmente el driver del navegador.",
        ],
    },
    4: {  # 6.2 divider
        4: [
            "CSS y XPath son los dos lenguajes para localizar elementos.",
            "Cada tipo de control HTML (texto, botón, select) tiene su",
            "propia keyword de interacción.",
        ],
    },
    7: {  # 6.3 divider
        4: [
            "Sleep con tiempo fijo es antipatrón. Wait Until espera",
            "activamente hasta que se cumple una condición, con timeout —",
            "más rápido y más estable.",
        ],
    },
    10: {  # 6.4 divider
        4: [
            "Capturar pantalla (en fallo o siempre) da evidencia de qué",
            "ocurrió. Las alertas de JavaScript no son parte del DOM:",
            "requieren Handle Alert, no un clic normal.",
        ],
    },
    13: {  # 6.5 divider
        4: [
            "Page Object: cada pantalla tiene su propio archivo Resource",
            "con localizadores y keywords. Un cambio de UI se corrige en",
            "un solo lugar.",
        ],
    },
    19: {  # Práctica 11
        4: [
            "Objetivo:",
            "Implementar un flujo completo de autenticación y navegación",
            "usando localizadores CSS con waits explícitos y screenshot",
            "automático en fallo.",
            "",
            "Guía completa: robfram-guide/Capitulo06/Practica11.md",
        ],
    },
    20: {  # Práctica 12
        4: [
            "Objetivo:",
            "Estructurar una suite bajo patrón Page Object, con captura",
            "de evidencias en cada test y manejo de alertas de JavaScript.",
            "",
            "Guía completa: robfram-guide/Capitulo06/Practica12.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
