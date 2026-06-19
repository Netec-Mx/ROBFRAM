*** Settings ***
Documentation     Práctica 15 — Sesión 8.
...               Proceso RPA: lee clientes desde Excel, transforma los
...               datos y genera un reporte PDF, con logging de cada etapa.
Library           ../scripts/procesar_clientes.py
Library           OperatingSystem


*** Variables ***
${ARCHIVO_ENTRADA}    ${CURDIR}/../data/clientes.xlsx
${ARCHIVO_SALIDA}     ${CURDIR}/../reportes/reporte_clientes.pdf


*** Test Cases ***
Proceso RPA completo: leer, transformar y generar reporte
    [Documentation]    Ejecuta el proceso de punta a punta y verifica el
    ...                resultado de cada etapa.
    Log    ETAPA 1/3: Leyendo clientes desde ${ARCHIVO_ENTRADA}
    @{clientes}=    Leer Clientes Excel    ${ARCHIVO_ENTRADA}
    Log    ETAPA 1/3 completada: ${{len($clientes)}} clientes leídos

    Log    ETAPA 2/3: Transformando datos (IVA + clasificación de consumo)
    @{clientes_transformados}=    Transformar Clientes    ${clientes}
    Log    ETAPA 2/3 completada

    Log    ETAPA 3/3: Generando reporte PDF en ${ARCHIVO_SALIDA}
    ${ruta_generada}=    Generar Reporte Pdf    ${clientes_transformados}    ${ARCHIVO_SALIDA}
    Log    ETAPA 3/3 completada: reporte en ${ruta_generada}

    File Should Exist    ${ARCHIVO_SALIDA}
    ${tamano}=    Get File Size    ${ARCHIVO_SALIDA}
    Should Be True    ${tamano} > 0

Clasificar consumo de un cliente individual
    [Documentation]    Verifica la keyword de clasificación de forma aislada.
    ${clasificacion}=    Clasificar Consumo    ${85}
    Should Be Equal    ${clasificacion}    medio
