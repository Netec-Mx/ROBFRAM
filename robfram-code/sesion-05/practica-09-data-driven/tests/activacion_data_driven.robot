*** Settings ***
Documentation     Práctica 9 — Sesión 5.
...               Suite data-driven con DataDriver leyendo casos desde un
...               CSV externo, segmentada por tags de ambiente y prioridad.
Library           DataDriver    ${CURDIR}/../data/casos_activacion.csv    dialect=excel    encoding=utf_8
Test Template     Verificar Resultado De Activacion


*** Test Cases ***
Caso de Ejemplo De Activación


*** Keywords ***
Verificar Resultado De Activacion
    [Documentation]    Keyword plantilla: cada fila del CSV genera un test
    ...                case independiente que la invoca con sus valores.
    [Arguments]    ${credito}    ${costo}    ${resultado_esperado}
    ${resultado}=    Calcular Resultado De Activacion    ${credito}    ${costo}
    Should Be Equal    ${resultado}    ${resultado_esperado}

Calcular Resultado De Activacion
    [Arguments]    ${credito}    ${costo}
    ${credito_num}=    Convert To Integer    ${credito}
    ${costo_num}=      Convert To Integer    ${costo}
    IF    ${credito_num} >= ${costo_num}
        RETURN    ACTIVO
    ELSE
        RETURN    RECHAZADO
    END
