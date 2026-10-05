(* ======================================================================
   FSM de llenado — Piloto 1 tina — v2
   Ultrasónico (control de nivel) + fotoeléctrico (moldes)
   + capacitivo (protección de NIVEL MUY ALTO) + electroválvula
   TM221CE16R · IO Bus: M1 = salidas (%Q1.x), M2 = TM3AI2H (%IW2.x)

   Antes de pegar:
   1) Configuration → TM3AI2H canal 0: tipo 0-10 V, Minimum 20, Maximum 150
      → %IW2.0 queda en mm de DISTANCIA (sensor → superficie).
      Verificar con regla: objeto a 50 mm y a 120 mm. Si sale al revés,
      invertir Min/Max (150 / 20).
   2) Timers (base 1 s): %TM0 TON 1 · %TM1 TOF 5 · %TM2 TON 60 · %TM3 TON 5
   3) Mover el capacitivo arriba del nivel máximo normal (ver doc).

   Estados %MW0: 0 = ESPERA · 1 = LLENANDO · 2 = FALLA
   Código de falla %MW1: 0 = ninguna · 1 = timeout · 2 = nivel muy alto

   Parámetros (mm) — VALORES DE EJEMPLO, calibrar en sitio:
   %MW41 REF_NIVEL  = distancia sensor → nivel cero de referencia
   %MW42 SP_BAJO    = abrir válvula cuando el nivel baja de aquí
   %MW43 SP_ALTO    = cerrar válvula cuando el nivel llega aquí
   ====================================================================== *)

(* Rung 0 — Inicialización y parámetros *)
LD    %S13
[%MW0 := 0]
[%MW1 := 0]
[%MW41 := 150]
[%MW42 := 50]
[%MW43 := 70]

(* Rung 1 — Distancia cruda y nivel en mm
   Si "LD 1" marca error: en ladder conectar los bloques de operación
   directo al riel izquierdo, sin contacto *)
LD    1
[%MW44 := %IW2.0]
[%MW40 := %MW41 - %MW44]

(* Rung 2 — Histéresis: nivel alcanzado (SET) *)
LD    [%MW40 >= %MW43]
S     %M0

(* Rung 3 — Histéresis: nivel bajo (RESET) *)
LD    [%MW40 <= %MW42]
R     %M0

(* Rung 4 — Fotoeléctrico → MOLDE_DET *)
LD    %I0.1
ST    %M1

(* Rung 5 — Capacitivo → NIVEL_MUY_ALTO
   Con la polaridad confirmada en la prueba v1 (ON = hay líquido).
   Si con líquido da 0, usar LDN *)
LD    %I0.0
ST    %M5

(* Rung 6 — Nivel bajo confirmado (filtra oleaje) *)
BLK   %TM0
LDN   %M0
IN
END_BLK

(* Rung 7 — Moldes presentes con retención *)
BLK   %TM1
LD    %M1
IN
END_BLK

(* Rung 8 — Timeout de llenado *)
BLK   %TM2
LD    [%MW0 = 1]
IN
END_BLK

(* Rung 9 — Reposo en ESPERA *)
BLK   %TM3
LD    [%MW0 = 0]
IN
END_BLK

(* Rung 10 — LLENANDO → FALLA por timeout *)
LD    [%MW0 = 1]
AND   %TM2.Q
[%MW0 := 2]
[%MW1 := 1]

(* Rung 11 — LLENANDO → ESPERA *)
LD    [%MW0 = 1]
AND(  %M0
ORN   %TM1.Q
)
[%MW0 := 0]

(* Rung 12 — ESPERA → LLENANDO *)
LD    [%MW0 = 0]
AND   %TM0.Q
AND   %TM1.Q
AND   %TM3.Q
ANDN  %M5
[%MW0 := 1]

(* Rung 13 — NIVEL MUY ALTO → FALLA desde cualquier estado
   Va después de las demás transiciones para que siempre gane *)
LD    %M5
[%MW0 := 2]
[%MW1 := 2]

(* Rung 14 — Reset de falla (solo si ya no hay nivel muy alto) *)
LD    [%MW0 = 2]
ANDN  %M5
AND(  %I0.2
OR    %M10
)
[%MW0 := 0]
[%MW1 := 0]

(* Rung 15 — Electroválvula con enclavamientos redundantes *)
LD    [%MW0 = 1]
ANDN  %M0
ANDN  %M5
AND   %TM1.Q
ST    %Q1.0

(* Rung 16 — Lámpara de falla parpadeando *)
LD    [%MW0 = 2]
AND   %S6
ST    %Q1.1

(* Rung 17 — Espejo de la válvula para monitoreo (PC / HMI) *)
LD    %Q1.0
ST    %M2

(* Rung 18 — Espejo de moldes presentes para monitoreo *)
LD    %TM1.Q
ST    %M3
