"""Práctica 10 — Sesión 5.

Librería Python personalizada para Robot Framework. Cada función pública
se convierte automáticamente en una keyword (snake_case -> Title Case con
espacios). Documentada con docstrings, que Robot Framework usa como la
documentación oficial de cada keyword.
"""
from __future__ import annotations

import re

from robot.api.deco import keyword

NUMERO_TELEFONO_GT_PATTERN = re.compile(r"^[2-7]\d{7}$")


@keyword("Validar Numero De Telefono Guatemalteco")
def validar_numero_telefono(numero: str) -> bool:
    """Valida que un número telefónico guatemalteco tenga 8 dígitos y
    empiece con un dígito entre 2 y 7 (rangos asignados por la
    Superintendencia de Telecomunicaciones de Guatemala).

    Example:
    | ${es_valido}=    Validar Numero De Telefono Guatemalteco    50212345
    | Should Be True    ${es_valido}

    Args:
        numero: número de teléfono como string, sin espacios ni guiones.

    Returns:
        True si el número tiene un formato válido, False en caso contrario.
    """
    return bool(NUMERO_TELEFONO_GT_PATTERN.fullmatch(numero))


@keyword("Calcular Costo Total Del Plan", tags=["facturacion"])
def calcular_costo_total(costo_base: float, impuesto_porcentaje: float = 12.0) -> float:
    """Calcula el costo total de un plan agregando el impuesto.

    Args:
        costo_base: costo del plan antes de impuestos.
        impuesto_porcentaje: porcentaje de impuesto a agregar (IVA en
            Guatemala = 12% por defecto).

    Returns:
        El costo total redondeado a 2 decimales.

    Raises:
        ValueError: si costo_base es negativo.
    """
    if costo_base < 0:
        raise ValueError(f"El costo base no puede ser negativo: {costo_base}")
    total = costo_base * (1 + impuesto_porcentaje / 100)
    return round(total, 2)
