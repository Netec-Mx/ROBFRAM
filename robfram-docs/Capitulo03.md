# Capítulo 3 — Control de Flujo y Validaciones

## Información general

Este capítulo agrega lógica condicional e iterativa a las suites, y profundiza en cómo Robot Framework maneja las fallas — tanto las que detienen la ejecución por defecto como las que se pueden controlar deliberadamente. Es uno de los capítulos con más peso en el examen RFCP, porque la discriminación entre keywords de manejo de fallas similares es una fuente común de error.

**Lecciones de este capítulo:**

- 3.1 — IF / ELSE IF / ELSE: ejecución condicional en keywords y test cases
- 3.2 — FOR: iteración sobre listas y rangos
- 3.3 — Asserts y fallas controladas: Should Be, Run Keyword And Expect Error
- 3.4 — Continue On Failure, Run Keyword And Continue On Failure y recuperación

---

## 3.1 IF / ELSE IF / ELSE: ejecución condicional en keywords y test cases

### Objetivos de la lección

- Explicar la sintaxis del bloque `IF` nativo de Robot Framework.
- Aplicar `ELSE IF` y `ELSE` para cubrir múltiples condiciones.
- Diferenciar el bloque `IF` nativo del enfoque heredado `Run Keyword If`.

### ¿Por qué importa?

Rara vez todos los escenarios de prueba son idénticos. Sin lógica condicional, te ves obligado a duplicar test cases casi idénticos solo para cubrir una rama de decisión distinta — lo que multiplica el costo de mantenimiento sin agregar cobertura real.

### Conceptos clave

#### Sintaxis nativa del bloque IF (RF 4.0+)

El bloque `IF` (sintaxis nativa desde Robot Framework 4.0) permite ejecutar keywords distintas según el resultado de una condición:

```robot
IF    ${condicion}
    Log    Se cumple la condición
ELSE IF    ${otra_condicion}
    Log    Se cumple la otra condición
ELSE
    Log    Ninguna condición se cumplió
END
```

Cada bloque `IF` debe cerrarse con `END`, en el mismo nivel de indentación que la palabra `IF` que lo abrió. La condición se evalúa como una expresión Python, lo que permite usar operadores relacionales (`<`, `>`, `<=`, `>=`, `==`, `!=`) directamente sobre variables, así como operadores lógicos (`and`, `or`, `not`) para condiciones compuestas.

#### Condiciones compuestas y anidamiento

```robot
IF    ${edad} >= 18 and ${tiene_documento}
    Log    Cliente puede contratar el servicio
END
```

Anidar bloques `IF` dentro de otro `IF` es válido, pero cada nivel adicional de anidamiento reduce la legibilidad — una buena práctica es extraer la lógica anidada a una keyword propia cuando supera dos niveles.

#### El enfoque heredado: Run Keyword If

Antes de Robot Framework 4.0, el único mecanismo disponible era la keyword `Run Keyword If`, de la biblioteca `BuiltIn`:

```robot
Run Keyword If    ${condicion}    Log    Se cumple
...    ELSE    Log    No se cumple
```

Sigue siendo válida y compatible (la encontrarás en proyectos legados), pero el bloque `IF` nativo es más legible — múltiples ramas con `ELSE IF` son mucho más claras que encadenar `Run Keyword If`/`ELSE IF`/`ELSE` en una sola línea larga — y es el que se enseña y se usa en este curso.

### Ejemplo comentado

```robot
*** Keywords ***
Clasificar Consumo
    [Documentation]    Clasifica un consumo en GB como bajo, medio o alto,
    ...                usando IF / ELSE IF / ELSE con operadores relacionales.
    [Arguments]    ${consumo}
    IF    ${consumo} < 50
        Log    ${consumo}GB -> Consumo bajo
    ELSE IF    ${consumo} < 100
        Log    ${consumo}GB -> Consumo medio
    ELSE
        Log    ${consumo}GB -> Consumo alto
    END
```

Con `${consumo}` = 85: la primera condición (`85 < 50`) es falsa, la segunda (`85 < 100`) es verdadera, así que se ejecuta esa rama y el bloque termina ahí — `ELSE` nunca se evalúa cuando una rama anterior ya se cumplió.

### Tabla de referencia rápida

| Construcción | Disponible desde | ¿Permite múltiples ramas? |
|---|---|---|
| `IF`/`ELSE IF`/`ELSE` nativo | Robot Framework 4.0 | Sí, de forma clara |
| `Run Keyword If` (heredado) | Cualquier versión | Sí, pero menos legible con muchas ramas |

| Operador relacional | Significado |
|---|---|
| `==`, `!=` | Igual, distinto |
| `<`, `>`, `<=`, `>=` | Comparación numérica |
| `and`, `or`, `not` | Combinación lógica de condiciones |

### Errores comunes

- **Olvidar el `END` de cierre** — el error de sintaxis más frecuente en este tema; Robot Framework reporta un error de parseo que puede no señalar exactamente la línea faltante.
- **Comparar strings sin comillas en la condición**, por ejemplo `IF    ${estado} == FAIL` en vez de `IF    '${estado}' == 'FAIL'` — sin comillas, Python (que evalúa la expresión) puede interpretar `FAIL` como un nombre de variable inexistente, no como el texto literal.
- **Anidar más de 2-3 niveles de `IF`** — señal de que la lógica debería extraerse a una o más keywords propias.

### Puntos clave

- El bloque `IF`/`ELSE IF`/`ELSE` nativo está disponible desde Robot Framework 4.0 y siempre se cierra con `END`.
- Las condiciones se evalúan como expresiones Python: operadores relacionales y lógicos funcionan igual que en Python.
- `Run Keyword If` es el equivalente heredado, anterior a la sintaxis nativa, todavía válido pero menos legible con varias ramas.

### Autoevaluación

1. ¿Qué palabra cierra obligatoriamente un bloque `IF`?
2. ¿Por qué `'${estado}' == 'FAIL'` necesita las comillas, a diferencia de `${numero} > 10`?
3. ¿Desde qué versión de Robot Framework está disponible el bloque `IF` nativo?

**Respuestas:** 1. `END`. 2. Porque se está comparando texto (string); sin comillas, la expresión Python podría interpretar `FAIL` como un nombre de variable, no como texto literal. 3. Desde la versión 4.0.

---

## 3.2 FOR: iteración sobre listas y rangos

### Objetivos de la lección

- Aplicar `FOR ... IN ... END` para iterar sobre una lista.
- Usar `IN RANGE` para iterar sobre una secuencia numérica.
- Combinar `FOR` con `IF` para validar colecciones de datos.

### ¿Por qué importa?

Cuando una verificación debe repetirse para varios valores — una lista de clientes, de consumos, de endpoints —, repetir el código manualmente para cada uno no escala: si la lógica de validación cambia, hay que actualizarla en cada copia.

### Conceptos clave

#### Sintaxis básica: iterar sobre una lista

```robot
FOR    ${elemento}    IN    @{lista}
    Log    Elemento actual: ${elemento}
END
```

El bloque `FOR` itera sobre una lista, asignando cada elemento a la variable declarada (`${elemento}` en el ejemplo) en cada vuelta. Igual que `IF`, todo bloque `FOR` debe cerrarse con `END`.

#### Iterar sobre un rango numérico

```robot
FOR    ${indice}    IN RANGE    5
    Log    Iteración número ${indice}
END
```

`IN RANGE` genera una secuencia numérica (0, 1, 2, 3, 4 en el ejemplo) sin necesitar una lista previa — equivalente al `range()` de Python. También admite `IN RANGE inicio fin` y `IN RANGE inicio fin paso`.

#### El patrón más usado: FOR + IF anidado

Combinar `FOR` con `IF` es uno de los patrones más usados en suites reales: recorrer una colección de datos y, para cada elemento, decidir una acción según una condición.

```robot
FOR    ${cliente}    IN    @{clientes}
    IF    ${cliente}[consumo] > ${cliente}[limite]
        Log    ${cliente}[nombre] excede su límite    WARN
    ELSE
        Log    ${cliente}[nombre] está dentro de su límite
    END
END
```

Este patrón es exactamente el que practicarás recorriendo una lista de diccionarios — cada diccionario representando un cliente con su consumo y límite contratado.

### Ejemplo comentado

```robot
*** Test Cases ***
Detectar Clientes Que Exceden Su Límite De Plan
    [Documentation]    FOR + IF anidado: el patrón estándar para validar
    ...                colecciones completas de datos.
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
```

**¿Por qué `limite=${50}` y no `limite=50`?** El prefijo `${50}` convierte el texto en un número entero de Python al construir el diccionario. Sin eso, `limite` sería el string `"50"`, y comparar `${cliente}[consumo] > ${cliente}[limite]` con strings no compara números — compara texto, lo cual produce resultados incorrectos e inconsistentes para números de más de un dígito.

### Tabla de referencia rápida

| Sintaxis | Qué genera |
|---|---|
| `FOR ${x} IN @{lista}` | Itera sobre los elementos de la lista |
| `FOR ${x} IN RANGE 5` | Itera 0, 1, 2, 3, 4 |
| `FOR ${x} IN RANGE 2 5` | Itera 2, 3, 4 |
| `FOR ${x} IN RANGE 0 10 2` | Itera 0, 2, 4, 6, 8 (con paso 2) |

### Errores comunes

- **Olvidar el `END` de cierre** — igual que con `IF`, es el error de sintaxis más frecuente.
- **Construir un diccionario con números sin el prefijo `${...}`**, dejándolos como texto, y luego comparar esos valores numéricamente — produce resultados incorrectos silenciosos (no un error de sintaxis, sino un resultado lógico equivocado).
- **Anidar `FOR` dentro de `FOR` sin necesidad real** — válido, pero revisa primero si la lógica puede simplificarse o extraerse a una keyword.

### Puntos clave

- `FOR ... IN ... END` itera sobre listas; `FOR ... IN RANGE ... END` itera sobre una secuencia numérica.
- `FOR` + `IF` anidado es el patrón estándar para validar colecciones de datos.
- Construir diccionarios con valores numéricos requiere el prefijo `${...}` para que la comparación posterior sea numérica, no textual.

### Autoevaluación

1. ¿Qué genera `FOR ${x} IN RANGE 3`?
2. Si construyes `Create Dictionary    consumo=50` (sin `${...}`), ¿qué tipo de dato queda almacenado en `consumo`?
3. ¿Qué patrón combinado se usa para validar una colección completa de datos, aplicando una condición a cada elemento?

**Respuestas:** 1. La secuencia 0, 1, 2. 2. Un string (texto), no un número entero. 3. `FOR` + `IF` anidado.

---

## 3.3 Asserts y fallas controladas: Should Be, Run Keyword And Expect Error

### Objetivos de la lección

- Aplicar la familia de keywords `Should Be` para aserciones.
- Usar `Run Keyword And Expect Error` para validar errores esperados.
- Diferenciar una falla controlada de una falla no controlada.

### ¿Por qué importa?

Verificar que el sistema bajo prueba se comporta exactamente como se espera — ni más, ni menos — es el corazón de cualquier test. Pero hay un caso que se pasa por alto fácilmente: validar que el sistema **falla correctamente** ante una entrada inválida es tan importante como validar que funciona ante una entrada válida.

### Conceptos clave

#### La familia Should Be: aserciones básicas

La familia de keywords `Should Be` (de `BuiltIn`) cubre las aserciones más comunes: `Should Be Equal` (igualdad exacta), `Should Be True` (la expresión es verdadera), `Should Be Empty` (una colección o string está vacío), `Should Be Equal As Integers`/`As Numbers` (compara convirtiendo a tipo numérico primero, evitando el problema de comparar `"7"` contra `7` directamente). Cada una falla con un mensaje claro si la condición no se cumple, deteniendo el test en ese punto — el comportamiento por defecto, que verás formalizado en la lección 3.4 como *fail fast*.

#### Cuando esperas que algo falle: Run Keyword And Expect Error

Hay un caso distinto al anterior: cuando **esperas que algo falle**, y ese fallo es justamente lo que quieres validar. Por ejemplo, confirmar que el sistema rechaza correctamente una entrada inválida. Para esto existe `Run Keyword And Expect Error`:

```robot
Run Keyword And Expect Error    ValueError: *    Convertir A Entero    no-es-numero
```

Esta keyword ejecuta `Convertir A Entero` esperando que falle con un error que coincida con el patrón `ValueError: *` (el `*` es un wildcard que acepta cualquier texto después de los dos puntos). Si el error ocurre **exactamente como se esperaba**, el test pasa — lo contrario de lo que pasaría si el error fuera inesperado (en cuyo caso `Run Keyword And Expect Error` también falla, porque el comportamiento real no coincidió con el esperado).

#### Patrones de coincidencia de error

El patrón de error admite varios formatos: texto exacto (`ValueError: el valor no es numérico`), wildcard parcial (`ValueError: *`), o incluso expresiones regulares (`regexp: ValueError:.*`, prefijo especial). Usar wildcards es la práctica más común, porque no depende del texto exacto del mensaje de error, que puede variar entre versiones de una librería.

#### Falla controlada vs. no controlada

| | Falla no controlada | Falla controlada |
|---|---|---|
| ¿Qué es? | Un error inesperado que detiene el test | Un error esperado, validado deliberadamente |
| Resultado del test | `FAIL` | `PASS` (si el error coincide con lo esperado) |
| Ejemplo | Selector CSS no encontrado por accidente | Verificar que un login con clave incorrecta es rechazado |

### Ejemplo comentado

```robot
*** Keywords ***
Convertir A Entero
    [Documentation]    Convierte un valor a entero; lanza ValueError si
    ...                el valor no es numérico (vía Convert To Integer).
    [Arguments]    ${valor}
    ${resultado}=    Convert To Integer    ${valor}
    RETURN    ${resultado}

*** Test Cases ***
Capturar Un Error Esperado Sin Marcar El Test Como Fallido
    [Documentation]    Run Keyword And Expect Error confirma que una
    ...                operación inválida lanza exactamente el error
    ...                esperado — y el test queda en PASS si así ocurre.
    Run Keyword And Expect Error    ValueError: *    Convertir A Entero    no-es-numero
```

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Qué keyword valida que un error esperado ocurrió, sin fallar el test? | `Run Keyword And Expect Error` |
| ¿Qué hace el `*` en un patrón de error? | Wildcard, acepta cualquier texto en esa posición |
| ¿Qué keyword compara dos valores convirtiéndolos a número primero? | `Should Be Equal As Integers` / `As Numbers` |

### Errores comunes

- **Usar `Should Be Equal` para comparar un string `"7"` contra el entero `7`** sin conversión — puede comportarse de forma inesperada según el contexto; usa `Should Be Equal As Integers` cuando la comparación es numérica.
- **Escribir el patrón de error sin wildcard**, dependiendo del mensaje exacto — frágil ante actualizaciones de una librería que cambien ligeramente el texto del error.
- **Confundir "el test pasa" con "no hubo ningún error"** — en `Run Keyword And Expect Error`, el test pasa **porque** hubo el error esperado, no porque no hubo ninguno.

### Puntos clave

- `Should Be Equal`, `Should Be True`, etc. son las aserciones básicas de `BuiltIn`.
- `Run Keyword And Expect Error` invierte la lógica: el test pasa si el error esperado ocurre exactamente como se especificó.
- Los patrones de error admiten wildcards (`*`) para no depender del mensaje exacto.

### Autoevaluación

1. ¿Qué keyword usarías para validar que el sistema rechaza correctamente una contraseña inválida con un mensaje de error específico?
2. ¿Qué pasa si `Run Keyword And Expect Error` espera `ValueError: *` pero la keyword no lanza ningún error?
3. ¿Por qué es preferible usar un wildcard en el patrón de error en vez del mensaje exacto?

**Respuestas:** 1. `Run Keyword And Expect Error`. 2. El test falla — se esperaba un error y no ocurrió ninguno. 3. Porque el mensaje exacto puede cambiar entre versiones de una librería; el wildcard hace la validación más resiliente.

---

## 3.4 Continue On Failure, Run Keyword And Continue On Failure y recuperación

### Objetivos de la lección

- Explicar el comportamiento *fail fast* por defecto de Robot Framework.
- Aplicar `Run Keyword And Continue On Failure` y `Run Keyword And Ignore Error`.
- Diferenciar los tres patrones de manejo de fallas del capítulo.

### ¿Por qué importa?

Por defecto, Robot Framework sigue un modelo **fail fast**: en cuanto una keyword falla, el test se detiene ahí mismo — las líneas siguientes no se ejecutan. Esto es correcto la mayoría de las veces (no tiene sentido seguir probando un sistema que ya falló), pero hay situaciones donde conviene ver **todos** los errores de un test, no solo el primero — por ejemplo, validando varios campos de un formulario a la vez, para reportar de una sola vez cuáles fallaron.

### Conceptos clave

#### Run Keyword And Continue On Failure: ver todos los errores

`Run Keyword And Continue On Failure` envuelve una keyword para que, si falla, **el fallo se registre pero la ejecución continúe** con las siguientes líneas del test:

```robot
Run Keyword And Continue On Failure    Should Be Equal    ${1}    ${1}    msg=Campo A
Run Keyword And Continue On Failure    Should Be Equal    ${1}    ${2}    msg=Campo B
Run Keyword And Continue On Failure    Should Be Equal    ${3}    ${3}    msg=Campo C
```

Importante: el test sigue marcado como `FAIL` al final si alguna verificación falló de verdad — esta keyword no oculta errores, solo evita que detengan la ejecución antes de tiempo. En el ejemplo, los tres `Should Be Equal` se ejecutan (Campo A y Campo C pasan, Campo B falla), pero el test completo queda en `FAIL` porque al menos una verificación falló.

#### Run Keyword And Ignore Error: decidir tú el flujo

Cuando necesitas **decidir tú mismo** qué hacer según el resultado de una keyword, sin que el fallo se propague como una excepción, usas `Run Keyword And Ignore Error`. Esta keyword devuelve dos valores: el estado (el string `'PASS'` o `'FAIL'`) y el mensaje. Con eso puedes usar un bloque `IF` para decidir el flujo:

```robot
${estado}    ${mensaje}=    Run Keyword And Ignore Error    Convertir A Entero    abc
IF    '${estado}' == 'FAIL'
    Log    Falló como se esperaba: ${mensaje}
ELSE
    Fail    Se esperaba que la conversión fallara
END
```

#### Las tres patrones del capítulo, comparados explícitamente

```{=typst}
#opciones(("Continue On Failure\n(ver todos los errores)", "Expect Error\n(fallo esperado = PASS)", "Ignore Error\n(decides tú el flujo)"))
```

| Patrón | ¿Qué hace? | ¿Cuándo usarlo? |
|---|---|---|
| `Run Keyword And Continue On Failure` | Ejecuta la keyword; si falla, **registra el fallo pero sigue** | Validar varios campos y ver todos los errores juntos |
| `Run Keyword And Expect Error` | Ejecuta esperando que falle con un mensaje específico; si falla así, el test queda en **PASS** | Probar que el sistema rechaza correctamente una entrada inválida |
| `Run Keyword And Ignore Error` | Devuelve el estado y el mensaje, sin detener nada | Decidir tú mismo, con `IF`, qué hacer según el resultado |

Estos tres patrones no son intercambiables: cada uno resuelve un caso de uso distinto, y elegir el correcto depende de qué necesitas hacer con el resultado del fallo (verlo todo, validarlo como esperado, o decidir tú el flujo). Confundirlos es uno de los errores más comunes al preparar el examen RFCP, precisamente porque sus nombres son similares.

### Ejemplo comentado

```robot
*** Test Cases ***
Validar Varios Campos Sin Detenerse En El Primer Fallo
    [Documentation]    El test SÍ queda en FAIL al final — es intencional:
    ...                el objetivo es ver los 3 mensajes, no evitar el FAIL.
    Run Keyword And Continue On Failure    Should Be Equal    ${1}    ${1}    msg=Campo A
    Run Keyword And Continue On Failure    Should Be Equal    ${1}    ${2}    msg=Campo B (fallo intencional)
    Run Keyword And Continue On Failure    Should Be Equal    ${3}    ${3}    msg=Campo C
```

Ejecutando solo este test, `log.html` muestra los tres mensajes — Campo A y Campo C sí se evaluaron, no se detuvo la ejecución en el Campo B — pero el resultado final del test es `FAIL`, porque el Campo B realmente falló.

### Tabla de referencia rápida

| Pregunta del examen RFCP (estilo) | Respuesta |
|---|---|
| ¿Cuál es el comportamiento por defecto de Robot Framework ante un fallo? | Fail fast: detiene el test inmediatamente |
| ¿Qué keyword permite ver todos los errores de un test, no solo el primero? | `Run Keyword And Continue On Failure` |
| ¿Qué devuelve `Run Keyword And Ignore Error`? | El estado (`'PASS'`/`'FAIL'`) y el mensaje |
| ¿`Run Keyword And Continue On Failure` puede dejar el test en PASS si algo realmente falló? | No — el test queda en FAIL si alguna verificación falló de verdad |

### Errores comunes

- **Pensar que `Run Keyword And Continue On Failure` "perdona" el fallo** — no lo hace; el test sigue marcado como FAIL, solo permite ver más información antes de terminar.
- **Usar `Run Keyword And Ignore Error` cuando en realidad quieres `Run Keyword And Expect Error`** — si ya sabes exactamente qué error esperas y quieres que el test pase si ocurre, `Expect Error` es más directo y explícito.
- **Comparar el estado devuelto sin comillas**: `IF ${estado} == FAIL` en vez de `IF '${estado}' == 'FAIL'` — el mismo error de comparación de strings visto en la lección 3.1.

### Puntos clave

- Comportamiento por defecto: *fail fast* — una keyword fallida detiene el test inmediatamente.
- `Run Keyword And Continue On Failure`: registra el fallo, pero sigue ejecutando; el test queda en `FAIL` si algo falló de verdad.
- `Run Keyword And Ignore Error`: devuelve `(estado, mensaje)` para que decidas tú el flujo con `IF`.
- `Run Keyword And Expect Error` (lección 3.3) es el tercer patrón: valida un error esperado como condición de éxito.

### Autoevaluación

1. ¿Cuál de los tres patrones de este capítulo usarías para validar 5 campos de un formulario y ver todos los errores en un solo reporte?
2. ¿Cuál usarías para que el test pase específicamente porque ocurrió un `ValueError` esperado?
3. ¿Cuál usarías si necesitas decidir manualmente, con un `IF`, qué hacer según si una keyword pasó o falló?
4. Verdadero o falso: `Run Keyword And Continue On Failure` puede hacer que un test con un fallo real termine en PASS.

**Respuestas:** 1. `Run Keyword And Continue On Failure`. 2. `Run Keyword And Expect Error`. 3. `Run Keyword And Ignore Error`. 4. Falso — el test queda en FAIL si alguna verificación falló de verdad; esta keyword solo evita que se detenga antes de tiempo.

---

## Resumen del capítulo

El bloque `IF`/`ELSE IF`/`ELSE` nativo (disponible desde RF 4.0) y el bloque `FOR` (incluyendo `IN RANGE`) cubren la lógica condicional e iterativa de una suite — ambos se cierran siempre con `END`, y su combinación (`FOR` + `IF` anidado) es el patrón estándar para validar colecciones de datos. Las aserciones `Should Be *` validan el comportamiento esperado, mientras que `Run Keyword And Expect Error` valida errores esperados sin fallar el test. Robot Framework usa *fail fast* por defecto; `Run Keyword And Continue On Failure` y `Run Keyword And Ignore Error` son los dos mecanismos restantes para tomar más control sobre cómo se maneja un fallo — los tres patrones de manejo de fallas (junto con `Expect Error`) no son intercambiables, cada uno responde a una pregunta distinta sobre qué hacer con un error.

## Referencias bibliográficas

- IF / ELSE: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#if-else-syntax>
- FOR loops: <https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#for-loops>
- Run Keyword And Continue On Failure: <https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Run%20Keyword%20And%20Continue%20On%20Failure>
- Run Keyword And Expect Error: <https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Run%20Keyword%20And%20Expect%20Error>

```{=typst}
#pagebreak()
```
