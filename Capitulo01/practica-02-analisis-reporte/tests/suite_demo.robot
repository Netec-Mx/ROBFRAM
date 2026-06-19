*** Settings ***
Documentation     Práctica 2 — Sesión 1.
...               Suite con un caso PASS y uno FAIL a propósito,
...               para generar un output.xml real con ambos estados y analizarlo.

*** Test Cases ***
TC-01 Caso que debe pasar
    [Documentation]    Verificación simple que siempre es verdadera.
    Should Be Equal    ${1}    ${1}

TC-02 Caso que debe fallar a propósito
    [Documentation]    Falla intencional para que el reporte tenga 1 PASS y 1 FAIL.
    [Tags]    fallo-esperado
    Should Be Equal    ${1}    ${2}
