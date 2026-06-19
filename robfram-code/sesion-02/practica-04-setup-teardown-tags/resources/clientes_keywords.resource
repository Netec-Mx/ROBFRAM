*** Settings ***
Documentation     Keywords reutilizables para gestión de clientes de telecom.
...               Práctica 4 — Sesión 2.
Library           Collections


*** Variables ***
${PLAN_BASICO}      Básico
${PLAN_PREMIUM}     Premium


*** Keywords ***
Crear Cliente
    [Documentation]    Crea un diccionario que representa un cliente con
    ...                su nombre y el plan contratado.
    [Arguments]    ${nombre}    ${plan}
    ${cliente}=    Create Dictionary    nombre=${nombre}    plan=${plan}
    RETURN    ${cliente}

Validar Plan Asignado
    [Documentation]    Verifica que el plan de un cliente coincide con el
    ...                plan esperado.
    [Arguments]    ${cliente}    ${plan_esperado}
    Should Be Equal    ${cliente}[plan]    ${plan_esperado}
