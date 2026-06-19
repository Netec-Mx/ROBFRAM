*** Settings ***
Documentation     Práctica 18 — Sesión 9. Proyecto final integrador:
...               ejecuta el simulacro RFCP completo y valida la
...               calificación, integrando todo lo aprendido en el curso
...               (librería Python propia, datos externos, aserciones).
Library           ../scripts/simulacro_rfcp.py
Library           Collections


*** Variables ***
${ARCHIVO_PREGUNTAS}    ${CURDIR}/../data/preguntas_rfcp.json


*** Test Cases ***
Simulacro RFCP: un participante con 8 de 10 correctas aprueba
    [Documentation]    Simula un participante que responde 8 de 10
    ...                preguntas correctamente (80%, por encima del 70%
    ...                requerido por la certificación real).
    @{preguntas}=    Cargar Preguntas    ${ARCHIVO_PREGUNTAS}
    &{respuestas}=    Construir Respuestas Con N Incorrectas    ${preguntas}    ${2}
    ${resultado}=    Calificar Simulacro    ${preguntas}    ${respuestas}
    Log    Resultado: ${resultado.correctas}/${resultado.total_preguntas} (${resultado.porcentaje}%)
    Should Be True    ${resultado.aprobado}

Simulacro RFCP: un participante con 5 de 10 correctas no aprueba
    [Documentation]    Simula un participante con 50% — por debajo del
    ...                umbral de aprobación.
    @{preguntas}=    Cargar Preguntas    ${ARCHIVO_PREGUNTAS}
    &{respuestas}=    Construir Respuestas Con N Incorrectas    ${preguntas}    ${5}
    ${resultado}=    Calificar Simulacro    ${preguntas}    ${respuestas}
    Log    Resultado: ${resultado.correctas}/${resultado.total_preguntas} (${resultado.porcentaje}%)
    Should Not Be True    ${resultado.aprobado}


*** Keywords ***
Construir Respuestas Con N Incorrectas
    [Documentation]    Construye un diccionario {id: respuesta} a partir
    ...                de las preguntas, marcando las primeras N como
    ...                deliberadamente incorrectas — simula un participante
    ...                real sin necesitar datos de entrada externos.
    [Arguments]    ${preguntas}    ${n_incorrectas}
    ${respuestas}=    Create Dictionary
    ${contador}=    Set Variable    ${0}
    FOR    ${pregunta}    IN    @{preguntas}
        IF    ${contador} < ${n_incorrectas}
            Set To Dictionary    ${respuestas}    ${pregunta}[id]    respuesta-incorrecta
        ELSE
            Set To Dictionary    ${respuestas}    ${pregunta}[id]    ${pregunta}[respuesta_correcta]
        END
        ${contador}=    Evaluate    ${contador} + 1
    END
    RETURN    ${respuestas}
