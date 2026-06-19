*** Settings ***
Documentation     Práctica 8 — Sesión 4. VERSIÓN ANTES de refactorizar.
...               Toda la lógica de negocio vive directo en el test case:
...               un stakeholder no técnico no podría leer esto.


*** Test Cases ***
Verificar activacion con credito suficiente
    ${credito}=    Set Variable    ${100}
    ${costo}=      Set Variable    ${50}
    IF    ${credito} >= ${costo}
        ${resultado}=    Set Variable    ACTIVO
    ELSE
        ${resultado}=    Set Variable    RECHAZADO
    END
    Should Be Equal    ${resultado}    ACTIVO

Verificar activacion con credito insuficiente
    ${credito}=    Set Variable    ${0}
    ${costo}=      Set Variable    ${50}
    IF    ${credito} >= ${costo}
        ${resultado}=    Set Variable    ACTIVO
    ELSE
        ${resultado}=    Set Variable    RECHAZADO
    END
    Should Be Equal    ${resultado}    RECHAZADO
