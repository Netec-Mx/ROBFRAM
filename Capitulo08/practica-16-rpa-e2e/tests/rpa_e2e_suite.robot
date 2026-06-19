*** Settings ***
Documentation     Práctica 16 — Sesión 8.
...               Proceso RPA end-to-end: extrae un dato de una página web,
...               lo envía a una API, lo registra en un archivo local, y
...               cierra con un checklist de calidad sobre las 3 capas.
Library           SeleniumLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Suite Setup       Create Session    api    https://postman-echo.com    verify=True


*** Variables ***
${URL_TABLA}          https://the-internet.herokuapp.com/tables
${SELECTOR_NOMBRE}    css:#table1 tbody tr:nth-child(1) td:nth-child(1)
${ARCHIVO_SALIDA}      ${CURDIR}/../salida/resultado_rpa.csv


*** Test Cases ***
Proceso RPA E2E: extraer, registrar vía API y archivar con checklist
    [Documentation]    Flujo completo en tres capas: Web -> API -> Archivo,
    ...                cerrado con un checklist de calidad.
    [Teardown]    Close All Browsers

    Log    CAPA WEB: extrayendo dato de la tabla
    Open Browser    ${URL_TABLA}    headlesschrome
    Wait Until Element Is Visible    ${SELECTOR_NOMBRE}    timeout=10s
    ${apellido_extraido}=    Get Text    ${SELECTOR_NOMBRE}
    Log    CAPA WEB completada: apellido extraído = ${apellido_extraido}

    Log    CAPA API: registrando el dato extraído
    &{payload}=    Create Dictionary    apellido_cliente=${apellido_extraido}    origen=rpa-practica-16
    ${respuesta}=    POST On Session    api    /post    json=${payload}
    Log    CAPA API completada: status=${respuesta.status_code}

    Log    CAPA ARCHIVO: registrando el resultado localmente
    Create Directory    ${CURDIR}/../salida
    Append To File    ${ARCHIVO_SALIDA}    ${apellido_extraido},${respuesta.status_code}\n
    Log    CAPA ARCHIVO completada: ${ARCHIVO_SALIDA}

    Ejecutar Checklist De Calidad    ${apellido_extraido}    ${respuesta.status_code}    ${ARCHIVO_SALIDA}


*** Keywords ***
Ejecutar Checklist De Calidad
    [Documentation]    Verifica las 3 capas del proceso y falla el test
    ...                con un mensaje claro si alguna condición no se
    ...                cumple — un checklist real, no solo un assert ciego.
    [Arguments]    ${apellido}    ${status_api}    ${ruta_archivo}
    ${checklist}=    Create List
    ${item_web}=    Set Variable If    """${apellido}""" != ""    PASS    FAIL
    Append To List    ${checklist}    Capa Web (dato no vacío): ${item_web}

    ${item_api}=    Set Variable If    ${status_api} == 200    PASS    FAIL
    Append To List    ${checklist}    Capa API (status 200): ${item_api}

    ${archivo_existe}=    Run Keyword And Return Status    File Should Exist    ${ruta_archivo}
    ${item_archivo}=    Set Variable If    ${archivo_existe}    PASS    FAIL
    Append To List    ${checklist}    Capa Archivo (existe): ${item_archivo}

    FOR    ${item}    IN    @{checklist}
        Log    CHECKLIST: ${item}
    END

    Should Not Contain    ${checklist}    Capa Web (dato no vacío): FAIL
    Should Not Contain    ${checklist}    Capa API (status 200): FAIL
    Should Not Contain    ${checklist}    Capa Archivo (existe): FAIL
