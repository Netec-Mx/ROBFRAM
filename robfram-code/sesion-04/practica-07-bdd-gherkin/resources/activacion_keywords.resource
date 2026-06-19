*** Settings ***
Documentation     Práctica 7 — Sesión 4.
...               Keywords con sintaxis Gherkin (Given/When/Then se
...               ignoran al resolver el nombre de la keyword).


*** Keywords ***
un cliente con crédito suficiente existe en el sistema
    [Documentation]    Given — establece el contexto inicial del escenario.
    Set Test Variable    ${CREDITO_DISPONIBLE}    ${100}

un cliente con crédito insuficiente existe en el sistema
    [Documentation]    Given — variante con crédito insuficiente.
    Set Test Variable    ${CREDITO_DISPONIBLE}    ${0}

el cliente solicita la activación de un plan de datos adicional
    [Documentation]    When — la acción que dispara el comportamiento a probar.
    ${costo_plan}=    Set Variable    ${50}
    IF    ${CREDITO_DISPONIBLE} >= ${costo_plan}
        Set Test Variable    ${RESULTADO_ACTIVACION}    ACTIVO
    ELSE
        Set Test Variable    ${RESULTADO_ACTIVACION}    RECHAZADO
    END

el plan queda activo y el cliente recibe una confirmación
    [Documentation]    Then — verificación del resultado esperado.
    Should Be Equal    ${RESULTADO_ACTIVACION}    ACTIVO

la activación es rechazada y se informa el motivo
    [Documentation]    Then — verificación del resultado esperado (camino negativo).
    Should Be Equal    ${RESULTADO_ACTIVACION}    RECHAZADO
