*** Settings ***
Documentation     Práctica 6 — Sesión 3.
...               Suite que demuestra tres patrones de manejo de fallas:
...               Continue On Failure, Run Keyword And Expect Error y
...               Run Keyword And Ignore Error.


*** Test Cases ***
TC-01 Validar varios campos sin detenerse en el primer fallo
    [Documentation]    Run Keyword And Continue On Failure envuelve cada
    ...                verificación para que las siguientes se ejecuten
    ...                aunque una falle. El test completo SÍ queda en
    ...                FAIL al final — eso es esperado e intencional para
    ...                esta demostración: el objetivo es ver los 3
    ...                mensajes, no evitar el FAIL.
    Run Keyword And Continue On Failure    Should Be Equal    ${1}    ${1}    msg=Campo A
    Run Keyword And Continue On Failure    Should Be Equal    ${1}    ${2}    msg=Campo B (fallo intencional para la demo)
    Run Keyword And Continue On Failure    Should Be Equal    ${3}    ${3}    msg=Campo C

TC-02 Capturar un error esperado sin marcar el test como fallido
    [Documentation]    Run Keyword And Expect Error confirma que una
    ...                operación inválida lanza exactamente el error
    ...                esperado — y el test queda en PASS si así ocurre.
    Run Keyword And Expect Error    ValueError: *    Convertir A Entero    no-es-numero

TC-03 Ignorar un error y decidir el flujo según el resultado
    [Documentation]    Run Keyword And Ignore Error captura el estado
    ...                (PASS/FAIL) y el mensaje sin propagar la excepción,
    ...                permitiendo decidir manualmente cómo continuar.
    ${estado}    ${mensaje}=    Run Keyword And Ignore Error    Convertir A Entero    abc
    IF    '${estado}' == 'FAIL'
        Log    Conversión falló como se esperaba: ${mensaje}
    ELSE
        Fail    Se esperaba que la conversión fallara y no fue así
    END


*** Keywords ***
Convertir A Entero
    [Documentation]    Convierte un valor a entero; lanza ValueError si
    ...                el valor no es numérico (vía Convert To Integer).
    [Arguments]    ${valor}
    ${resultado}=    Convert To Integer    ${valor}
    RETURN    ${resultado}
