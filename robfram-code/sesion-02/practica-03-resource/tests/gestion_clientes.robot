*** Settings ***
Documentation     Práctica 3 — Sesión 2.
...               Suite que importa keywords desde un archivo Resource
...               y valida datos usando variables compartidas.
Resource          ../resources/clientes_keywords.resource


*** Test Cases ***
TC-01 Crear cliente con plan básico
    [Documentation]    Verifica que un cliente nuevo queda con el plan
    ...                Básico cuando así se solicita.
    ${cliente}=    Crear Cliente    Ana Pérez    ${PLAN_BASICO}
    Validar Plan Asignado    ${cliente}    ${PLAN_BASICO}

TC-02 Crear cliente con plan premium
    [Documentation]    Verifica que un cliente nuevo queda con el plan
    ...                Premium cuando así se solicita.
    ${cliente}=    Crear Cliente    Luis Gómez    ${PLAN_PREMIUM}
    Validar Plan Asignado    ${cliente}    ${PLAN_PREMIUM}

TC-03 Dos clientes con planes distintos no se confunden entre sí
    [Documentation]    Confirma que las variables del Resource (PLAN_BASICO,
    ...                PLAN_PREMIUM) no se mezclan entre instancias.
    ${cliente_a}=    Crear Cliente    María Díaz    ${PLAN_BASICO}
    ${cliente_b}=    Crear Cliente    Carlos Ruiz    ${PLAN_PREMIUM}
    Validar Plan Asignado    ${cliente_a}    ${PLAN_BASICO}
    Validar Plan Asignado    ${cliente_b}    ${PLAN_PREMIUM}
