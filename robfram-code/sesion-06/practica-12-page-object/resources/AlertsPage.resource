*** Settings ***
Documentation     Práctica 12 — Sesión 6.
...               Page Object de la página de alertas JS del sitio de
...               práctica (/javascript_alerts).
Library           SeleniumLibrary


*** Variables ***
${URL_ALERTAS}            https://the-internet.herokuapp.com/javascript_alerts
${BOTON_JS_ALERT}         css:button[onclick='jsAlert()']
${BOTON_JS_CONFIRM}       css:button[onclick='jsConfirm()']
${RESULTADO_ALERTA}       id:result


*** Keywords ***
Abrir Pagina De Alertas
    Go To    ${URL_ALERTAS}
    Wait Until Element Is Visible    ${BOTON_JS_ALERT}    timeout=10s

Disparar Alerta Simple Y Aceptar
    Click Element    ${BOTON_JS_ALERT}
    Handle Alert    action=ACCEPT

Disparar Confirmacion Y Cancelar
    Click Element    ${BOTON_JS_CONFIRM}
    Handle Alert    action=DISMISS

Verificar Resultado Contiene
    [Arguments]    ${texto_esperado}
    Element Should Contain    ${RESULTADO_ALERTA}    ${texto_esperado}
