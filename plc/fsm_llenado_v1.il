(* ======================================================================
   FSM de llenado — Piloto 1 tina — v1
   Proyecto: FirstTest · POU: Latex pools · TM221CE16R
   Uso: crear un rung por bloque, pulsar "> IL", pegar el texto,
        volver a "> LD". Borrar antes el Rung0 actual (%I0.0 -> %Q1.0).

   Configurar antes en Tools -> Software Objects -> Timers (base 1 s):
     %TM0  TON  preset 2   (nivel bajo confirmado)
     %TM1  TOF  preset 5   (moldes presentes, retención)
     %TM2  TON  preset 30  (tiempo máximo de llenado)
     %TM3  TON  preset 5   (reposo en ESPERA)

   Estados %MW0: 0 = ESPERA · 1 = LLENANDO · 2 = FALLA
   Nota: aquí los rungs van numerados de corrido (0–12). En el documento
   técnico el reposo aparece como "Rung 5b"; desde ahí la numeración se
   corre una posición.
   ====================================================================== *)

(* Rung 0 — Inicialización al pasar a RUN *)
LD    %S13
[%MW0 := 0]

(* Rung 1 — Sensor capacitivo -> NIVEL_OK
   Si en la prueba el sensor da 0 con líquido, cambiar LD por LDN aquí *)
LD    %I0.0
ST    %M0

(* Rung 2 — Fotoeléctrico -> MOLDE_DET
   Mientras no esté instalado: forzar %I0.1 = 1 para probar *)
LD    %I0.1
ST    %M1

(* Rung 3 — Nivel bajo confirmado (antirrebote) *)
BLK   %TM0
LDN   %M0
IN
END_BLK

(* Rung 4 — Moldes presentes con retención entre moldes *)
BLK   %TM1
LD    %M1
IN
END_BLK

(* Rung 5 — Timeout de llenado *)
BLK   %TM2
LD    [%MW0 = 1]
IN
END_BLK

(* Rung 6 — Reposo en ESPERA *)
BLK   %TM3
LD    [%MW0 = 0]
IN
END_BLK

(* Rung 7 — LLENANDO -> FALLA *)
LD    [%MW0 = 1]
AND   %TM2.Q
[%MW0 := 2]

(* Rung 8 — LLENANDO -> ESPERA *)
LD    [%MW0 = 1]
AND(  %M0
ORN   %TM1.Q
)
[%MW0 := 0]

(* Rung 9 — ESPERA -> LLENANDO *)
LD    [%MW0 = 0]
AND   %TM0.Q
AND   %TM1.Q
AND   %TM3.Q
[%MW0 := 1]

(* Rung 10 — FALLA -> ESPERA (reset por pulsador o por software) *)
LD    [%MW0 = 2]
AND(  %I0.2
OR    %M10
)
[%MW0 := 0]

(* Rung 11 — Electroválvula (con enclavamientos redundantes) *)
LD    [%MW0 = 1]
ANDN  %M0
AND   %TM1.Q
ST    %Q1.0

(* Rung 12 — Lámpara de falla parpadeando *)
LD    [%MW0 = 2]
AND   %S6
ST    %Q1.1
