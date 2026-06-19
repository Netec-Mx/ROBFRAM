*** Settings ***
Documentation     Práctica 11 — Sesión 6.
...               Flujo completo de autenticación y navegación E2E usando
...               localizadores CSS/XPath con waits explícitos y
...               screenshot automático en fallo.
Library           SeleniumLibrary
Test Setup        Open Browser    ${URL_LOGIN}    headlesschrome
Test Teardown     Close All Browsers


*** Variables ***
${URL_LOGIN}              https://the-internet.herokuapp.com/login
${CAMPO_USUARIO}          id:username
${CAMPO_PASSWORD}         id:password
${BOTON_INGRESAR}         css:button[type='submit']
${MENSAJE_FLASH}          css:#flash
${BOTON_CERRAR_SESION}    css:a.button.secondary
${USUARIO_VALIDO}         tomsmith
${PASSWORD_VALIDO}        SuperSecretPassword!


*** Test Cases ***
TC-01 Iniciar sesión con credenciales válidas
    [Documentation]    Verifica el flujo completo de autenticación exitosa.
    Go To    ${URL_LOGIN}
    Wait Until Element Is Visible    ${CAMPO_USUARIO}    timeout=10s
    Input Text        ${CAMPO_USUARIO}      ${USUARIO_VALIDO}
    Input Password     ${CAMPO_PASSWORD}    ${PASSWORD_VALIDO}
    Click Button    ${BOTON_INGRESAR}
    Wait Until Location Contains    /secure    timeout=10s
    Wait Until Element Is Visible    ${MENSAJE_FLASH}    timeout=10s
    Element Should Contain    ${MENSAJE_FLASH}    You logged into a secure area

TC-02 Rechazar credenciales inválidas con captura de pantalla en fallo
    [Documentation]    Verifica el mensaje de error; el Teardown solo
    ...                captura pantalla SI el test falla (no en cada caso).
    [Teardown]    Run Keywords
    ...    Run Keyword If Test Failed    Capture Page Screenshot
    ...    AND    Close All Browsers
    Go To    ${URL_LOGIN}
    Input Text        ${CAMPO_USUARIO}      usuario_invalido
    Input Password     ${CAMPO_PASSWORD}    clave_invalida
    Click Button    ${BOTON_INGRESAR}
    Wait Until Element Is Visible    ${MENSAJE_FLASH}    timeout=10s
    Element Should Contain    ${MENSAJE_FLASH}    Your username is invalid!

TC-03 Navegar al área segura y cerrar sesión
    [Documentation]    Inicia sesión, espera la navegación a /secure por
    ...                URL, y cierra sesión.
    Go To    ${URL_LOGIN}
    Input Text        ${CAMPO_USUARIO}      ${USUARIO_VALIDO}
    Input Password     ${CAMPO_PASSWORD}    ${PASSWORD_VALIDO}
    Click Button    ${BOTON_INGRESAR}
    Wait Until Location Contains    /secure    timeout=10s
    Click Element    ${BOTON_CERRAR_SESION}
    Wait Until Element Is Visible    ${MENSAJE_FLASH}    timeout=10s
    Element Should Contain    ${MENSAJE_FLASH}    You logged out of the secure area!
