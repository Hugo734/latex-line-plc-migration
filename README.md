# latex-line-plc-migration

Migración del control de una línea industrial de inmersión en látex de 24 tinas: de dos Siemens LOGO! con ~48 relés a un PLC Schneider Modicon TM221, con integración de sensores, arquitectura de I/O, HMI y documentación del proceso.

*Migrating a 24-tank industrial latex dipping line from Siemens LOGO! relays to a Schneider TM221 PLC — sensor integration, I/O architecture, HMI, and documentation.*

## Por qué existe este proyecto

La línea actual se controla con dos LOGO! y lógica de relés. Ya hubo **rebalses de tinas** en producción. El objetivo es:

- llenar solo cuando hace falta (nivel bajo) **y** cuando hay moldes en la línea;
- detectar fallas (sensor dañado, válvula pegada) y cortar el llenado antes de rebalsar;
- dar visibilidad al operador con una pantalla HMI;
- dejar la base para registrar datos y escalar a las 24 tinas.

## Documentación

| Documento | Contenido |
|---|---|
| [proyecto_plc_tinas_latex.md](proyecto_plc_tinas_latex.md) | Documento técnico: hardware, mapa de I/O, FSM de llenado, conexiones, HMI, commissioning y pendientes |
| [media/](media/) | Fotografías y videos del proceso (antes / durante / después) |

## Hoja de ruta

### Fase 0 — Levantamiento del estado actual
- [ ] Fotos y videos del tablero actual (LOGO! + relés), de las tinas y de los sensores instalados
- [ ] Registrar cómo opera hoy el llenado y qué hace el operador cuando hay un problema
- [ ] Tomar métricas base (ver [Métricas de mejora](#métricas-de-mejora))

### Fase 1 — Piloto de una tina (capacitivo + fotoeléctrico) ← **en curso**
- [x] Firmware del TM221 actualizado (1.14.1.0) y comunicación con Machine Expert Basic
- [x] Rung simple de prueba compilado sin errores
- [x] Diseño de la FSM de llenado (ESPERA / LLENANDO / FALLA) con timeout y permisivo de moldes
- [ ] Prueba física del capacitivo (confirmar polaridad)
- [ ] Instalación y prueba del fotoeléctrico
- [ ] Cargar la FSM y probar cada transición, incluida la falla por timeout
- [ ] Calibrar tiempos (nivel bajo, hueco entre moldes, tiempo máximo de llenado)

### Fase 2 — Nivel analógico (ultrasónico SICK UM18)
- [ ] Recibir e instalar el sensor
- [ ] Integrar a la FSM con histéresis (dos umbrales)
- [ ] Comparar el comportamiento contra el capacitivo

### Fase 3 — HMI Wecon
- [ ] Confirmar modelo de pantalla y software (PIStudio / LeviStudioU)
- [ ] Comunicación Modbus TCP con el TM221
- [ ] Pantallas: principal, alarmas, parámetros, contadores
- [ ] Detalle técnico en [proyecto_plc_tinas_latex.md](proyecto_plc_tinas_latex.md#hmi-wecon)

### Fase 4 — Despliegue a 24 tinas
- [ ] Confirmar bobinas de las electroválvulas de producción y dimensionar relés
- [ ] Definir arquitectura de I/O remota centralizada (límites del M221 vs. M241/M251)
- [ ] Evaluar IO-Link vs. 4-20mA
- [ ] Plan de migración por grupos de tinas sin detener la producción

### Fase 5 — Datos y mejora continua
- [ ] Registro de llenados, fallas y tiempos por tina
- [ ] Tendencias de nivel en el HMI
- [ ] Reporte antes/después

## Documentación visual del proceso

### Qué capturar

| Momento | Fotos | Videos |
|---|---|---|
| **Antes** | Tablero LOGO! y relés; tinas; sensores capacitivos instalados; evidencia de rebalses (látex derramado, limpieza) | Un ciclo completo de llenado actual; un rebalse o casi-rebalse si ocurre |
| **Piloto** | Tablero del TM221 armado; cableado de sensores; relé auxiliar y válvula; pantalla de Machine Expert en línea | Prueba de cada transición de la FSM: llenado normal, corte por falta de moldes, falla por timeout y reset |
| **HMI** | Pantallas en operación; instalación en campo | Operador usando la HMI (reset de falla, cambio de parámetros) |
| **Después** | Tablero final; tinas funcionando; nivel estable | Línea operando con moldes entrando y llenado automático |

**Recomendaciones:**
- Toma el mismo encuadre antes y después (mismo punto, misma altura). Así la comparación se ve directa.
- En los videos de prueba, deja visible al mismo tiempo la tina y el LED de la entrada/salida del PLC, o la pantalla en línea.
- Confirma con la empresa qué se puede publicar. Si el repositorio es público, revisa que no aparezcan rostros, marcas de clientes ni información de producción sensible.
- Usa el EPP de la planta (presencia de amoniaco en las tinas de látex).

### Organización de archivos

```
media/
├── 00-antes/
├── 01-piloto/
├── 02-ultrasonico/
├── 03-hmi/
└── 04-despliegue/
```

Nombre sugerido: `AAAA-MM-DD_tema_descripcion.ext`, por ejemplo `2026-10-05_piloto_falla-timeout.mp4`.

> Los videos pesan mucho para Git. Usa **Git LFS** o súbelos a una carpeta compartida (Drive/OneDrive) y deja aquí solo el enlace y una miniatura.

## Métricas de mejora

Para demostrar la mejora con datos y no solo con fotos, registrar antes y después:

| Métrica | Cómo medirla antes | Cómo medirla después |
|---|---|---|
| Rebalses por semana | Bitácora del operador | Bitácora + contador de fallas en el PLC |
| Látex desperdiciado / tiempo de limpieza | Estimación por evento | Igual |
| Intervenciones manuales del operador | Observación / bitácora | Bitácora |
| Tiempo de llenado por ciclo | Cronómetro en video | Registrado por el PLC/HMI |
| Paros de línea por llenado | Bitácora de producción | Igual |

## Hardware principal

- PLC: Schneider Modicon **TM221CE16R** + módulo analógico **TM3AI2H/G**
- Sensores: capacitivo **Autonics CR18-8A**, fotoeléctrico de barrera, ultrasónico **SICK UM18-21712D211** (0-10V)
- Actuador: electroválvula **Microair FV5221-8** (24VDC) mediante relé auxiliar
- HMI: **Wecon** (modelo por confirmar)
- Software: EcoStruxure Machine Expert – Basic
