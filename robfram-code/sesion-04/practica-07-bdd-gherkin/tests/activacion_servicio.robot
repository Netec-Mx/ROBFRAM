*** Settings ***
Documentation     Práctica 7 — Sesión 4.
...               Escenarios BDD (Given/When/Then) para un flujo comercial
...               de telecomunicaciones: activación de un plan de datos.
Resource          ../resources/activacion_keywords.resource


*** Test Cases ***
Activación de plan de datos para cliente con crédito suficiente
    Given un cliente con crédito suficiente existe en el sistema
    When el cliente solicita la activación de un plan de datos adicional
    Then el plan queda activo y el cliente recibe una confirmación

Activación rechazada por crédito insuficiente
    Given un cliente con crédito insuficiente existe en el sistema
    When el cliente solicita la activación de un plan de datos adicional
    Then la activación es rechazada y se informa el motivo
