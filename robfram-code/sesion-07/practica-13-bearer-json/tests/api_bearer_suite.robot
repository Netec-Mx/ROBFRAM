*** Settings ***
Documentation     Práctica 13 — Sesión 7.
...               Suite de pruebas API con autenticación Bearer y
...               validación de estructura/valores de respuesta JSON.
Library           RequestsLibrary
Library           Collections
Suite Setup       Create Session    api    https://postman-echo.com    verify=True


*** Variables ***
${TOKEN_DEMO}    token-demo-12345


*** Test Cases ***
TC-01 Autenticar con Bearer token y validar que el servidor lo recibió
    [Documentation]    postman-echo.com/headers refleja en la respuesta
    ...                todos los headers recibidos — incluido Authorization
    ...                — ideal para validar el patrón Bearer sin depender
    ...                de un servicio de autenticación real.
    &{headers}=    Create Dictionary    Authorization=Bearer ${TOKEN_DEMO}
    ${respuesta}=    GET On Session    api    /headers    headers=&{headers}
    Should Be Equal As Numbers    ${respuesta.status_code}    200
    Should Be Equal    ${respuesta.json()}[headers][authorization]    Bearer ${TOKEN_DEMO}

TC-02 Enviar payload JSON con POST y validar estructura de respuesta
    [Documentation]    postman-echo.com/post devuelve, dentro de la clave
    ...                "json", exactamente el payload enviado — útil para
    ...                validar que el cuerpo se serializó correctamente.
    &{payload}=    Create Dictionary    cliente=Ana Pérez    plan=Premium
    ${respuesta}=    POST On Session    api    /post    json=${payload}
    Should Be Equal As Numbers    ${respuesta.status_code}    200
    Should Be Equal    ${respuesta.json()}[json][cliente]    Ana Pérez
    Should Be Equal    ${respuesta.json()}[json][plan]    Premium

TC-03 Validar contrato de un endpoint conocido (campos obligatorios)
    [Documentation]    Validación de contrato básica: confirmar que los
    ...                campos esperados existen en la respuesta.
    &{parametros}=    Create Dictionary    plan=premium
    ${respuesta}=    GET On Session    api    /get    params=&{parametros}
    Should Be Equal As Numbers    ${respuesta.status_code}    200
    Dictionary Should Contain Key    ${respuesta.json()}    args
    Should Be Equal    ${respuesta.json()}[args][plan]    premium
