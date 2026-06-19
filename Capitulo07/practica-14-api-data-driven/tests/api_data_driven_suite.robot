*** Settings ***
Documentation     Práctica 14 — Sesión 7.
...               Suite API data-driven (DataDriver) que cubre escenarios
...               positivos y negativos, segmentados por tags smoke/
...               regresion.
Library           RequestsLibrary
Library           DataDriver    ${CURDIR}/../data/casos_api.csv    dialect=excel    encoding=utf_8
Suite Setup       Create Session    api    https://postman-echo.com    verify=True
Test Template     Verificar Status Code Del Endpoint


*** Test Cases ***
Caso De Ejemplo De API


*** Keywords ***
Verificar Status Code Del Endpoint
    [Documentation]    expected_status=any evita que RequestsLibrary lance
    ...                una excepción automática ante un 4xx/5xx — así
    ...                podemos validar casos negativos sin que el GET
    ...                "falle" antes de llegar al assert.
    [Arguments]    ${endpoint}    ${status_esperado}
    ${respuesta}=    GET On Session    api    ${endpoint}    expected_status=any
    Should Be Equal As Numbers    ${respuesta.status_code}    ${status_esperado}
