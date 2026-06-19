*** Settings ***
Documentation     Práctica 5 — Sesión 3.
...               Tests con lógica condicional (IF/ELSE IF/ELSE) y bucles
...               (FOR) sobre datos de consumo de clientes telecom.
Library           Collections


*** Variables ***
@{CONSUMOS_GB}    45    72    101    15    99


*** Test Cases ***
TC-01 Clasificar el consumo de cada cliente por rango
    [Documentation]    Recorre @{CONSUMOS_GB} con FOR y clasifica cada
    ...                valor con IF / ELSE IF / ELSE.
    FOR    ${consumo}    IN    @{CONSUMOS_GB}
        Clasificar Consumo
        ...    ${consumo}
    END

TC-02 Detectar clientes que exceden su límite de plan
    [Documentation]    Recorre una lista de diccionarios cliente
    ...                (nombre/límite/consumo) y marca cuáles exceden
    ...                su límite contratado.
    ${cliente_1}=    Create Dictionary    nombre=Ana     limite=${50}    consumo=${45}
    ${cliente_2}=    Create Dictionary    nombre=Luis    limite=${50}    consumo=${72}
    @{clientes}=     Create List    ${cliente_1}    ${cliente_2}

    FOR    ${cliente}    IN    @{clientes}
        IF    ${cliente}[consumo] > ${cliente}[limite]
            Log    ${cliente}[nombre] excede su límite de ${cliente}[limite]GB    WARN
        ELSE
            Log    ${cliente}[nombre] está dentro de su límite
        END
    END


*** Keywords ***
Clasificar Consumo
    [Documentation]    Clasifica un consumo en GB como bajo, medio o alto.
    [Arguments]    ${consumo}
    IF    ${consumo} < 50
        Log    ${consumo}GB -> Consumo bajo
    ELSE IF    ${consumo} < 100
        Log    ${consumo}GB -> Consumo medio
    ELSE
        Log    ${consumo}GB -> Consumo alto
    END
