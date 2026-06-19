*** Settings ***
Documentation     Práctica 12 — Sesión 6.
...               Suite web estructurada bajo patrón Page Object, con
...               captura de evidencias automática en CADA test (no solo
...               en fallo) y manejo de alertas de JavaScript.
Library           SeleniumLibrary
Resource          ../resources/LoginPage.resource
Resource          ../resources/AlertsPage.resource
Test Setup        Open Browser    about:blank    headlesschrome
Test Teardown     Run Keywords
...               Capture Page Screenshot
...               AND    Close All Browsers


*** Test Cases ***
TC-01 Iniciar sesión exitosamente usando el Page Object
    [Documentation]    El test no conoce ningún selector técnico — solo
    ...                llama keywords de LoginPage.resource.
    Abrir Pagina De Login
    Ingresar Credenciales    tomsmith    SuperSecretPassword!
    Hacer Clic En Ingresar
    Verificar Mensaje Flash Contiene    You logged into a secure area

TC-02 Rechazar credenciales inválidas usando el Page Object
    Abrir Pagina De Login
    Ingresar Credenciales    usuario_invalido    clave_invalida
    Hacer Clic En Ingresar
    Verificar Mensaje Flash Contiene    Your username is invalid!

TC-03 Aceptar una alerta simple de JavaScript
    [Documentation]    Maneja una alerta nativa del navegador (no es un
    ...                elemento del DOM, requiere Handle Alert).
    Abrir Pagina De Alertas
    Disparar Alerta Simple Y Aceptar
    Verificar Resultado Contiene    You successfully clicked an alert

TC-04 Cancelar una confirmación de JavaScript
    Abrir Pagina De Alertas
    Disparar Confirmacion Y Cancelar
    Verificar Resultado Contiene    You clicked: Cancel
