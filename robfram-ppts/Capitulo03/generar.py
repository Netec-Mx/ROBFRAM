"""Genera Capitulo03.pptx — ver Capitulo01/generar.py para la explicación."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "_template"))

from extraer_capitulo import extraer  # noqa: E402
from reescribir_texto import aplicar_reemplazos  # noqa: E402

SALIDA = Path(__file__).parent / "Capitulo03.pptx"

# Se omiten WHILE/BREAK/CONTINUE (132,136,137): no forman parte del alcance
# práctico de este curso (Práctica 5 y 6 cubren IF/FOR y manejo de fallas).
INDICES = [121, 122, 123, 124, 131, 133, 134, 142, 144, 147, 148, 151, 153, 154, 156, 158, 167, 168, 169, 171, 173]

REEMPLAZOS = {
    1: {  # 3.1 divider
        4: [
            "Rara vez todos los escenarios de prueba son iguales. El bloque",
            "IF / ELSE IF / ELSE te permite ejecutar keywords distintas",
            "según una condición.",
        ],
    },
    4: {  # 3.2 divider
        4: [
            "Cuando trabajas con varios datos a la vez (una lista de",
            "clientes, de consumos, de endpoints), FOR te permite repetir",
            "una verificación para cada uno sin duplicar código.",
        ],
    },
    7: {  # 3.3 divider (Asserts)
        4: [
            "Validar que el sistema falla CORRECTAMENTE es tan importante",
            "como validar que funciona. Run Keyword And Expect Error",
            "confirma que un error esperado ocurre, sin fallar el test.",
        ],
    },
    12: {  # 3.4 divider (Continue On Failure)
        4: [
            "Por defecto, Robot Framework detiene un test en el primer",
            "fallo (fail fast). Run Keyword And Continue On Failure te",
            "deja ver TODOS los errores de un test, no solo el primero.",
        ],
    },
    18: {  # Práctica 5
        4: [
            "Objetivo:",
            "Crear tests que usen IF/ELSE para clasificar consumos y FOR",
            "para recorrer una lista de clientes validando sus límites.",
            "",
            "Guía completa: robfram-guide/Capitulo03/Practica5.md",
        ],
    },
    19: {  # Práctica 6
        4: [
            "Objetivo:",
            "Diseñar una suite que use Continue On Failure, Expect Error",
            "e Ignore Error para manejar fallas de forma controlada.",
            "",
            "Guía completa: robfram-guide/Capitulo03/Practica6.md",
        ],
    },
}


def main():
    extraer(INDICES, SALIDA)
    aplicar_reemplazos(str(SALIDA), REEMPLAZOS)


if __name__ == "__main__":
    main()
