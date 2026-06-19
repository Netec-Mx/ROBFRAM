*** Settings ***
Documentation     Práctica 8 — Sesión 4. Capa TÉCNICA: el detalle de cómo
...               se calcula el resultado. Solo la capa de dominio la usa.


*** Keywords ***
Calcular Resultado De Activacion
    [Documentation]    Compara crédito disponible contra el costo del plan.
    [Arguments]    ${credito}    ${costo}
    IF    ${credito} >= ${costo}
        RETURN    ACTIVO
    ELSE
        RETURN    RECHAZADO
    END
