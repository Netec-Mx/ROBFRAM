*** Settings ***
Documentation     Práctica 8 — Sesión 4. Capa de DOMINIO/NEGOCIO: traduce
...               el lenguaje del escenario a la capa técnica. Es la única
...               capa que el test case (Given/When/Then) conoce.
Resource          tecnica_keywords.resource


*** Keywords ***
un cliente con crédito suficiente solicita activar un plan
    [Documentation]    Ejemplo de negocio: cliente con 100 de crédito,
    ...                plan que cuesta 50.
    ${resultado}=    Calcular Resultado De Activacion    ${100}    ${50}
    Set Test Variable    ${RESULTADO}    ${resultado}

un cliente con crédito insuficiente solicita activar un plan
    [Documentation]    Ejemplo de negocio: cliente sin crédito disponible.
    ${resultado}=    Calcular Resultado De Activacion    ${0}    ${50}
    Set Test Variable    ${RESULTADO}    ${resultado}

el plan queda activo
    Should Be Equal    ${RESULTADO}    ACTIVO

la activación es rechazada
    Should Be Equal    ${RESULTADO}    RECHAZADO
