*** Settings ***
# La sección Settings define metadatos de la suite.
# BuiltIn es la librería nativa de Robot Framework: no requiere "Library" explícito.
Documentation     Práctica 1 — Sesión 1.
...               Primera suite: cuatro secciones de un archivo .robot.
Metadata          Curso        Robot Framework y Automatización de Pruebas
Metadata          Sesión       1


*** Variables ***
# Variables escalares (${...}): un solo valor.
${NOMBRE_CURSO}          Robot Framework 7
${HERRAMIENTA_PRUEBAS}    Robot Framework
${HERRAMIENTA_RPA}        Robot Framework

# Variable de lista (@{...}): varios valores, accesibles por índice.
@{DOMINIOS_RF}           Automatización de Pruebas    RPA    Automatización Web


*** Test Cases ***
TC-01 Verificar que el curso tiene nombre asignado
    [Documentation]    Confirma que la variable de suite ${NOMBRE_CURSO} no está vacía.
    Log    Iniciando TC-01
    Should Not Be Empty    ${NOMBRE_CURSO}
    Log    Curso: ${NOMBRE_CURSO}

TC-02 Verificar que la misma herramienta cubre pruebas y RPA
    [Documentation]    Robot Framework es una de las pocas herramientas que cubre
    ...                tanto automatización de pruebas como RPA.
    Should Be Equal    ${HERRAMIENTA_PRUEBAS}    ${HERRAMIENTA_RPA}
    Log    Ambas variables apuntan a: ${HERRAMIENTA_PRUEBAS}

TC-03 Verificar que Robot Framework abarca los tres dominios esperados
    [Documentation]    Recorre la lista @{DOMINIOS_RF} y confirma su contenido.
    Verificar Dominio En Lista    Automatización de Pruebas
    Verificar Dominio En Lista    RPA
    Verificar Dominio En Lista    Automatización Web


*** Keywords ***
Verificar Dominio En Lista
    [Documentation]    Verifica que un dominio dado existe en @{DOMINIOS_RF}.
    [Arguments]    ${dominio}
    Should Contain    ${DOMINIOS_RF}    ${dominio}
    Log    Dominio confirmado: ${dominio}
