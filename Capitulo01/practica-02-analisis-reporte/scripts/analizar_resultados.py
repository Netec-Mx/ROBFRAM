"""Práctica 2 — Sesión 1.

Lee el ``output.xml`` generado por Robot Framework y extrae las métricas
clave de la ejecución: total de tests, pasados, fallidos y porcentaje de
éxito. Este script es la base para automatizar quality gates en CI/CD
(Sesión 9) y para entender qué información vive realmente en el output.xml.
"""
from __future__ import annotations

import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Metricas:
    total: int
    passed: int
    failed: int
    skipped: int = 0

    @property
    def pass_rate(self) -> float:
        """Porcentaje de tests pasados, redondeado a 1 decimal."""
        if self.total == 0:
            return 0.0
        return round((self.passed / self.total) * 100, 1)


def analizar_resultados(ruta_output_xml: str | Path) -> Metricas:
    """Parsea un output.xml de Robot Framework y devuelve sus métricas.

    Args:
        ruta_output_xml: ruta al archivo output.xml a analizar.

    Returns:
        Metricas con total, passed, failed y skipped extraídos del nodo
        <statistics><total><stat> del XML. El total incluye los tests
        omitidos (skip), ya que Robot Framework los contempla como parte
        del total de tests ejecutados.

    Raises:
        FileNotFoundError: si la ruta no existe.
        ValueError: si el XML no contiene el nodo de estadísticas totales.
    """
    ruta = Path(ruta_output_xml)
    if not ruta.is_file():
        raise FileNotFoundError(f"No existe el archivo: {ruta}")

    arbol = ET.parse(ruta)
    nodo_total = arbol.find("./statistics/total/stat")
    if nodo_total is None:
        raise ValueError("El output.xml no contiene <statistics><total><stat>")

    passed = int(nodo_total.get("pass", 0))
    failed = int(nodo_total.get("fail", 0))
    skipped = int(nodo_total.get("skip", 0))
    return Metricas(
        total=passed + failed + skipped,
        passed=passed,
        failed=failed,
        skipped=skipped,
    )


if __name__ == "__main__":
    import sys

    ruta = sys.argv[1] if len(sys.argv) > 1 else "reports/output.xml"
    metricas = analizar_resultados(ruta)
    print(f"Total:    {metricas.total}")
    print(f"Pasados:  {metricas.passed}")
    print(f"Fallidos: {metricas.failed}")
    print(f"Omitidos: {metricas.skipped}")
    print(f"% Éxito:  {metricas.pass_rate}%")
