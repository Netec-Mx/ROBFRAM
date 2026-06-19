*** Settings ***
Documentation     Práctica 4 — Sesión 2.
...               Suite Setup/Teardown, Test Setup/Teardown y filtrado
...               de tests por tags de inclusión/exclusión.
Resource          ../resources/clientes_keywords.resource
Suite Setup       Log    Iniciando suite de regresión de clientes
Suite Teardown    Log    Finalizando suite de regresión de clientes
Test Setup        Log    Preparando datos para el siguiente test
Test Teardown     Log    Limpieza posterior al test


*** Test Cases ***
TC-01 Cliente premium tiene soporte prioritario
    [Documentation]    Caso de regresión completo, marcado para ejecución
    ...                normal (no smoke).
    [Tags]    regresion    premium
    ${cliente}=    Crear Cliente    Luis Gómez    ${PLAN_PREMIUM}
    Validar Plan Asignado    ${cliente}    ${PLAN_PREMIUM}

TC-02 Cliente básico no tiene soporte prioritario
    [Documentation]    Caso de regresión completo para el plan básico.
    [Tags]    regresion    basico
    ${cliente}=    Crear Cliente    Ana Pérez    ${PLAN_BASICO}
    Validar Plan Asignado    ${cliente}    ${PLAN_BASICO}

TC-03 El sistema de gestión de clientes responde
    [Documentation]    Verificación rápida (smoke) de que la keyword
    ...                principal no lanza errores inesperados.
    [Tags]    smoke
    ${cliente}=    Crear Cliente    Cliente De Prueba    ${PLAN_BASICO}
    Should Not Be Empty    ${cliente}
