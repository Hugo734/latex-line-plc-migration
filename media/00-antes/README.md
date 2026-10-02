# Fase 0 — Levantamiento del estado actual

Registro fotográfico de la línea de inmersión en látex y de su control **antes** de la migración al PLC Schneider TM221. Sirve como referencia para comparar el antes y el después.

> Las observaciones marcadas con *(por confirmar)* se dedujeron de la foto y deben validarse en planta.

---

## 1. Vista general de la línea

![Vista de las tinas de latex](Vista%20de%20las%20tinas%20de%20latex.jpeg)

**Archivo:** `Vista de las tinas de latex.jpeg`

- Tinas largas en paralelo, cada una con látex de un color distinto (rosa, amarillo, azul, naranja, verde…).
- Los **moldes** cuelgan de la cadena transportadora superior, en varias filas, y bajan a las tinas para la inmersión.
- En el borde frontal de las tinas hay cuerpos roscados montados en soportes, uno por tina. Por su forma (rosca M18 con tuercas), es probable que sean los **sensores capacitivos Autonics CR18** actuales *(por confirmar)*.
- Debajo pasa un colector/tubería (azul) con abundantes salpicaduras de látex, junto con mangueras y cableado.

**Relevancia para el proyecto:**
- Ubicación del **sensor fotoeléctrico**: la barrera debe ir en el recorrido de la cadena, antes de que los moldes entren a la zona de tinas. Así detecta su llegada.
- El nivel de suciedad y salpicaduras confirma que se necesitan cable **PUR** y conectores **IP67** en los sensores.

---

## 2. Ingreso de látex a las tinas

![Ingreso de Latex a tinas](Ingreso%20de%20Latex%20a%20tinas.jpeg)

**Archivo:** `Ingreso de Latex a tinas.jpeg`

- Bajo la línea están las tuberías de alimentación de látex (PVC blanco vertical) que suben hacia cada tina.
- Hay actuadores/válvulas **numerados por tina** (se leen 9, 10, 12, 14…).
- La tubería delgada azul parece **neumática** (aire comprimido) *(por confirmar)*. Si es así, las válvulas de producción podrían ser **válvulas de accionamiento neumático comandadas por una solenoide piloto**, no solenoides de látex directas.
- A la derecha hay un banco de válvulas manuales (manijas rojas) y mangueras de colores sin orden.

**Relevancia para el proyecto:**
- Esto afecta directamente el pendiente *"Confirmar voltaje/corriente de las bobinas de las electroválvulas reales de producción"*. Hay que identificar el modelo de la válvula y de su piloto, y si existe una isla de válvulas neumáticas.
- La numeración por tina ya existe en campo. Conviene **respetarla** en los símbolos del PLC (`EV_TINA_09`, etc.) y en el HMI.

---

## 3. Motores agitadores

![Motores agitadores latex](Motores%20agitadores%20latex.jpeg)

**Archivo:** `Motores agitadores latex.jpeg`

- Hay un **motorreductor agitador por tina**, montado en un soporte azul en el borde de cada tina.
- El cableado de los motores está expuesto y cubierto de látex seco.
- Al fondo se ven los moldes sobre las tinas de colores.

**Relevancia para el proyecto:**
- Los agitadores hoy se arrancan desde el gabinete (botones *AGITADOR-1* y *AGITADOR-2*, ver foto 4). Para una fase posterior: integrar marcha/paro y estado de los agitadores al PLC y al HMI.
- Los agitadores agitan la superficie del látex, lo que puede generar **oleaje en la lectura de nivel**. Eso justifica el antirrebote de %TM0 en la FSM y, en su momento, la histéresis del ultrasónico.

---

## 4. Gabinete de control — exterior

![Gabinete Tina Latex](Gabinete%20Tina%20Latex.jpeg)

**Archivo:** `Gabinete Tina Latex.jpeg`

- Gabinete identificado como **"GABINETE TINAS DE LATEX B24"**, con letrero de riesgo eléctrico "Panel de Tina de Látex".
- Mandos en la puerta:
  - **AGITADOR-1:** pulsador doble marcha/paro (verde/rojo).
  - **AGITADOR-2:** pulsador doble marcha/paro (verde/rojo).
  - **ELECTROVÁLVULAS:** selector de dos posiciones (habilita/deshabilita las válvulas).
- **No hay indicación de nivel, de alarmas ni de qué tina está llenando.**

**Relevancia para el proyecto:**
- El selector **ELECTROVÁLVULAS** debería conservarse como **habilitación general** de la FSM: cablearlo a una entrada del PLC y usarlo como permisivo adicional de llenado.
- La puerta tiene espacio para montar el **HMI Wecon** y una lámpara de falla. Hay que medir el recorte disponible antes de elegir el modelo.

---

## 5. Gabinete de control — interior

![Circuito electrico del gabinete](Circuito%20electrico%20del%20gabinete.jpeg)

**Archivo:** `Circuito electrico del gabinete.jpeg`

De arriba hacia abajo:

| Zona | Contenido observado |
|---|---|
| Fila superior | 6 guardamotores y 1 relé térmico. A la derecha, el interruptor principal en caja moldeada. |
| Fila media | 3 variadores de frecuencia: uno pequeño sin rotular y dos rotulados **"PRESECADO COAGULANTE"** y **"PRESECADO LÁTEX"** (modelo PI160 según la carátula). A la derecha, guardamotores y protecciones adicionales. |
| Fila de control | 6 relés de interfaz + **2 Siemens LOGO!** (con display) + guardamotor y bornes. |
| Filas inferiores | **2 filas de ~24 relés** numerados (1–24 aprox.). Es probable que haya un relé por tina en cada fila: una para sensores y otra para válvulas *(por confirmar trazando el cableado)*. |
| Lateral izquierdo | Fuente conmutada grande (probablemente 24VDC; *verificar placa y capacidad libre*). |
| Inferior izquierdo | Transformador de control. |
| Ventilación | 6 ventiladores (2 arriba, 2 abajo, 1 lateral, 1 en puerta), coherente con los ~50°C de la planta. |

**Relevancia para el proyecto:**
- El conteo de relés (~6 + 48) es coherente con los "~48 relés" del documento técnico. Si se confirma que hay **un relé de sensor y uno de válvula por tina**, el despliegue completo necesita como mínimo **24 entradas y 24 salidas** digitales, más la periferia: selector, agitadores, fotoeléctrico y reset.
- La **fuente existente** podría alimentar el HMI si tiene capacidad libre. Revisar su placa antes de comprar una nueva.
- El gabinete está **lleno**. El TM221 y sus módulos ocuparían el espacio que liberan los LOGO! y parte de los relés. Hay que planear el retiro por etapas.
- Los variadores de presecado y los agitadores quedan **fuera del alcance del piloto**, pero son candidatos a integrarse después (marcha/paro, falla y velocidad por Modbus).

---

## 6. Video de la operación actual

▶️ [Video de tinas latex.mp4](Video%20de%20tinas%20latex.mp4)

**Archivo:** `Video de tinas latex.mp4` (~2.4 MB)

- Registro en video del funcionamiento actual de las tinas de látex.
- *Pendiente: agregar descripción de lo que muestra (duración, qué tina, si se ve un ciclo de llenado).*

> GitHub no reproduce videos del repositorio dentro del README. El enlace abre el archivo para descargarlo o verlo.
