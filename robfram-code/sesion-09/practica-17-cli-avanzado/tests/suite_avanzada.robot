*** Settings ***
Documentation     Práctica 17 — Sesión 9.
...               Suite con tags variados para practicar filtrado
...               avanzado por CLI, --rerunfailed y combinación con rebot.


*** Test Cases ***
TC-01 Prueba smoke critica
    [Tags]    smoke    critico
    Should Be True    ${True}

TC-02 Prueba smoke no critica
    [Tags]    smoke
    Should Be True    ${True}

TC-03 Prueba de regresion que falla a proposito
    [Documentation]    Falla intencional para practicar --rerunfailed y
    ...                la combinación de reportes con rebot.
    [Tags]    regresion
    Should Be Equal    ${1}    ${2}

TC-04 Prueba de regresion exitosa
    [Tags]    regresion
    Should Be True    ${True}
