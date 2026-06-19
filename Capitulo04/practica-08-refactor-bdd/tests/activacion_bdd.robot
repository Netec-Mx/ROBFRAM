*** Settings ***
Documentation     Práctica 8 — Sesión 4. VERSIÓN DESPUÉS de refactorizar:
...               el test case solo conoce lenguaje de negocio (capa de
...               dominio); la capa técnica queda oculta detrás.
Resource          ../resources/dominio_keywords.resource


*** Test Cases ***
Activación de plan con crédito suficiente
    Given un cliente con crédito suficiente solicita activar un plan
    Then el plan queda activo

Activación rechazada por crédito insuficiente
    Given un cliente con crédito insuficiente solicita activar un plan
    Then la activación es rechazada
