# Robot Framework — Código del curso

Código fuente, ejecutable y validado, de las 18 prácticas del curso **Robot Framework y Automatización de Pruebas** (NETEC / Claro Guatemala).

## Entorno

Gestionado con `pyenv` (nunca Python global):

```bash
pyenv virtualenv 3.12.0 robfram   # una sola vez
cd robfram-code
pyenv local robfram               # ya queda fijado en .python-version
pip install -r requirements.txt
cp .env.example .env               # ajustar valores si aplica
```

## Estructura

Cada sesión es independiente y autocontenida:

```
sesion-01/
├── practica-01-<slug>/
│   ├── tests/            # suites .robot
│   ├── scripts/          # librerías/keywords Python propias (si aplica)
│   ├── tests_unitarios/  # pytest sobre el código Python
│   └── reports/          # salida de robot (gitignored)
└── practica-02-<slug>/
    └── ...
```

## Ejecutar una práctica

```bash
cd sesion-01/practica-01-primer-test
robot --outputdir reports tests/primera_suite.robot
```

## Ejecutar los tests unitarios de una práctica (si tiene código Python)

```bash
cd sesion-01/practica-02-analisis-reporte
pytest tests_unitarios/ -v
```

## Versionado

`MAJOR.MINOR.PATCH` — `MINOR` se incrementa al cerrar cada sesión, `PATCH` ante cualquier corrección posterior. `v1.0.0` marca el curso completo (9 sesiones, 18 prácticas).

## Sesiones — curso completo ✅

| Sesión | Tema | Estado |
|---|---|---|
| 1 | Fundamentos y ecosistema RF | ✅ |
| 2 | Sintaxis y diseño de suites | ✅ |
| 3 | Control de flujo y validaciones | ✅ |
| 4 | BDD y pruebas orientadas a negocio | ✅ |
| 5 | RF avanzado, data-driven y Python | ✅ |
| 6 | Automatización web con SeleniumLibrary | ✅ |
| 7 | Automatización de APIs con RequestsLibrary | ✅ |
| 8 | RF aplicado a RPA | ✅ |
| 9 | Ejecución avanzada, reporting y RFCP | ✅ |

Cada sesión fue validada con ejecución real (`robot`/`pytest`, sin simulaciones) y revisada por sub-agentes especializados (`test-engineer`, `docs-writer`) antes de cerrarse.
