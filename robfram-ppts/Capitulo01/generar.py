"""Genera Capitulo01.pptx: extrae el subconjunto de slides de la plantilla
del cliente y reescribe el texto con lenguaje simple/didáctico, alineado
con robfram-guide/Capitulo01/Practica1.md y Practica2.md.

Uso: python generar.py   (ejecutar dentro del venv pyenv 'robfram')
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo01.pptx"

# Índices dentro del deck de 500 slides de la plantilla del cliente.
INDICES = [9, 10, 11, 12, 13, 14, 19, 20, 21, 25, 29, 33, 35, 39, 43, 44, 49, 60, 61, 62, 64, 66]

# Texto simplificado por slide (índice ya renumerado 0..21 tras la extracción)
# y por shape dentro de esa slide.
REEMPLAZOS = {
    0: {  # Capítulo 1 — divider
        5: [
            "Explicar la diferencia entre automatización de pruebas y RPA",
            "Conocer la arquitectura de Robot Framework y sus librerías nativas",
            "Instalar el entorno: Python, Robot Framework, VS Code",
            "Escribir y ejecutar tu primera suite .robot",
        ],
    },
    1: {  # 1.1 divider
        4: [
            "Dos términos se confunden mucho: automatización de pruebas y RPA.",
            "Ambos usan software para ejecutar tareas automáticamente, pero",
            "tienen objetivos y audiencias distintas. Vamos a aclararlo.",
        ],
    },
    4: {  # Analogía
        3: [
            "▸ Automatización de pruebas → un inspector de calidad que revisa cada pieza.",
            "▸ RPA → un operario que ensambla esas piezas en la línea de producción.",
            "▸ Ambos trabajan en la misma fábrica, con roles distintos.",
            "▸ Confundirlos te hace elegir la herramienta equivocada para el problema.",
        ],
    },
    7: {  # 1.2 divider
        4: [
            "Robot Framework no es solo \"una herramienta de pruebas\".",
            "Es un ecosistema: un núcleo extensible + librerías nativas +",
            "librerías de la comunidad (Selenium, Requests, etc.).",
        ],
    },
    11: {  # 1.3 divider
        4: [
            "Un entorno mal instalado es la causa más común de errores confusos",
            "al empezar. Por eso instalamos en orden: Python → pip → Robot",
            "Framework → IDE, y verificamos cada paso antes de avanzar.",
        ],
    },
    14: {  # 1.4 divider
        4: [
            "Al escribir tu primera prueba, el reto no es la lógica: es saber",
            "dónde va cada cosa. Un archivo .robot tiene 4 secciones fijas,",
            "cada una con una responsabilidad clara.",
        ],
    },
    19: {  # Práctica 1
        4: [
            "Objetivo:",
            "Configurar Python, Robot Framework y VS Code; escribir y ejecutar",
            "un test case básico verificando la salida generada.",
            "",
            "Guía completa: robfram-guide/Capitulo01/Practica1.md",
        ],
    },
    20: {  # Práctica 2
        4: [
            "Objetivo:",
            "Interpretar output.xml, log.html y report.html de una ejecución;",
            "escribir un script Python que analice las métricas con pytest.",
            "",
            "Guía completa: robfram-guide/Capitulo01/Practica2.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
