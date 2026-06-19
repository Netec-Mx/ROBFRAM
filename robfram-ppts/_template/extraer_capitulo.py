"""Extrae un subconjunto de slides de la plantilla del cliente, preservando
100% el master/layout/diseño visual, para usarlo como base de cada deck de
capítulo. El contenido textual se reescribe después con reescribir_texto.py.

Uso:
    python extraer_capitulo.py <indices_separados_por_coma> <salida.pptx>

Ejemplo (Capítulo 1):
    python extraer_capitulo.py 9,10,11,12,13,14,19,20,21,25,29,33,35,39,43,44,49,60,61,62,64,66 \
        ../Capitulo01/Capitulo01.pptx
"""
import sys
from pathlib import Path

from pptx import Presentation

PLANTILLA = Path(__file__).parent.parent / "assets" / "_plantilla_referencia.pptx"


def extraer(indices_mantener: list[int], salida: Path) -> None:
    prs = Presentation(str(PLANTILLA))
    xml_slides = prs.slides._sldIdLst
    todos = list(xml_slides)

    mantener = set(indices_mantener)
    for i in range(len(todos) - 1, -1, -1):
        if i not in mantener:
            nodo = todos[i]
            r_id = nodo.get(
                "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"
            )
            xml_slides.remove(nodo)
            # Sin esto, la parte (slide + sus imágenes embebidas) queda
            # huérfana pero sigue serializándose en el .pptx final, y el
            # archivo no reduce su tamaño real.
            prs.part.drop_rel(r_id)

    salida.parent.mkdir(parents=True, exist_ok=True)
    prs.save(str(salida))
    print(f"Guardado: {salida} ({len(indices_mantener)} slides)")


if __name__ == "__main__":
    indices = [int(x) for x in sys.argv[1].split(",")]
    extraer(indices, Path(sys.argv[2]))
