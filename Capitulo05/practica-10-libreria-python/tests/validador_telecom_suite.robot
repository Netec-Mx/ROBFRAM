*** Settings ***
Documentation     Práctica 10 — Sesión 5.
...               Integra la librería Python ValidadorTelecom como keywords
...               de Robot Framework.
Library           ../libs/ValidadorTelecom.py


*** Test Cases ***
Validar número telefónico guatemalteco correcto
    ${es_valido}=    Validar Numero De Telefono Guatemalteco    50212345
    Should Be True    ${es_valido}

Rechazar número telefónico con rango inválido
    ${es_valido}=    Validar Numero De Telefono Guatemalteco    80123456
    Should Not Be True    ${es_valido}

Calcular costo total de un plan con IVA por defecto
    ${total}=    Calcular Costo Total Del Plan    100
    Should Be Equal As Numbers    ${total}    112.0

Calcular costo total de un plan con impuesto personalizado
    [Tags]    facturacion
    ${total}=    Calcular Costo Total Del Plan    100    impuesto_porcentaje=10
    Should Be Equal As Numbers    ${total}    110.0
