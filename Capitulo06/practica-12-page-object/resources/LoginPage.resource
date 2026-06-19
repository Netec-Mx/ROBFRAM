*** Settings ***
Documentation     Práctica 12 — Sesión 6.
...               Page Object de la página de login: variables de
...               localizadores + keywords. Ninguna otra capa debe conocer
...               estos selectores directamente.
Library           SeleniumLibrary


*** Variables ***
${URL_LOGIN}              https://the-internet.herokuapp.com/login
${CAMPO_USUARIO}          id:username
${CAMPO_PASSWORD}         id:password
${BOTON_INGRESAR}         css:button[type='submit']
${MENSAJE_FLASH}          css:#flash


*** Keywords ***
Abrir Pagina De Login
    Go To    ${URL_LOGIN}
    Wait Until Element Is Visible    ${CAMPO_USUARIO}    timeout=10s

Ingresar Credenciales
    [Arguments]    ${usuario}    ${password}
    Input Text        ${CAMPO_USUARIO}      ${usuario}
    Input Password     ${CAMPO_PASSWORD}    ${password}

Hacer Clic En Ingresar
    Click Button    ${BOTON_INGRESAR}

Verificar Mensaje Flash Contiene
    [Arguments]    ${texto_esperado}
    Wait Until Element Is Visible    ${MENSAJE_FLASH}    timeout=10s
    Element Should Contain    ${MENSAJE_FLASH}    ${texto_esperado}
