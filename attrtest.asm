; Mostrando la organizacion de la videomemoria (atributos)
 
  ORG 50000
 
  ; Pseudocodigo del programa:
  ; 
  ; Borramos la pantalla
  ; Apuntamos HL a 22528
  ; Repetimos 24 veces:
  ;    Esperamos pulsacion de una tecla
  ;    Repetimos 32 veces:
  ;       Escribir un valor de PAPEL 0-7 en la direccion apuntada por HL
  ;       Incrementar HL
 
Start:
  LD A, 0
  CALL ClearScreen           ; Borramos la pantalla
 
  LD HL, 22528               ; HL apunta a la VRAM de atributos
  LD C, 24                  ; Repetimos para 192 lineas
  LD D, 0
  CALL SetBorder       ; Cambiamos el color del borde
 
bucle_lineas:
  LD B, 1
  ;CALL Pausa
 
 
  ;LD B, 24
  ;LD D, C                    ; Nos guardamos el valor de D para el
                             ; bucle exterior (usaremos B ahora en otro)
  LD B, 10                   ; B=32 para el bucle interior
 
                             ; Esperamos que se pulse y libere tecla
  
  ;CALL Wait_For_Keys_Pressed
  ;CALL Wait_For_Keys_Released

  LD A, (papel_2)              ; Cogemos el valor del papel
  INC A                      ; Lo incrementamos
  LD (papel_2), A              ; Lo guardamos de nuevo
  CP 16*8                 ; por cada 8 lineas, cambiamos de color

  JR NZ,continue_1    ; salta si A > 0

   
  LD A, 255
  INC A
  LD (papel_2), A
 
 continue_1:
  LD A, (papel)              ; Cogemos el valor del papel
  INC A                      ; Lo incrementamos
  LD (papel), A              ; Lo guardamos de nuevo
  CP 16                       ; Si es == 8 (>7), resetear
  JR NZ,no_resetear_papel    ; salta si A > 0
 
  LD A, 255
  INC A                      ; incrementamos al siguiente color consecutivo para que no se repita
  LD (papel), A              ; Lo hemos reseteado: lo guardamos
  XOR A                      ; A=0
 
no_resetear_papel:
 
  SLA A                      ; Desplazamos A 3 veces a la izquierda
  SLA A                      ; para colocar el valor 0-7 en los bits
  SLA A                      ; donde se debe ubicar PAPER (bits 3-5).
 
bucle_8_bytes_1:
  LD (HL), A                 ; Almacenamos A en (HL) = attrib de 8x8
  INC HL                    ; siguiente byte (siguientes 8x8 pixeles.)
  DJNZ bucle_8_bytes_1        ; 32 veces = 32 bytes = 1 scanline de bloques
  
  LD A, (papel)              ; Cogemos el valor del papel
  SLA A
  SLA A
  ;SLA A
  LD B, 10

bucle_8_bytes_2:
  LD (HL), A                 ; Almacenamos A en (HL) = attrib de 8x8
  INC HL                    ; siguiente byte (siguientes 8x8 pixeles.)
  DJNZ bucle_8_bytes_2        ; 32 veces = 32 bytes = 1 scanline de bloques
  
  LD B, 12
  LD A, (papel_2)              ; Cogemos el valor del papel
  ;SLA A
  ;SLA A

bucle_8_bytes_3:
  LD (HL), A                ; Almacenamos A en (HL) = attrib de 8x8
  INC HL                    ; siguiente byte (siguientes 8x8 pixeles.)
  DJNZ bucle_8_bytes_3        ; 32 veces = 32 bytes = 1 scanline de bloques
 
  ; LD B, C                     ; gaurdamos attributo 3a columna en B
  ; LD A, B
  ; CP 16                       ; Si es == 8 (>7), resetear
  ; JR NZ, continue    ; salta si A > 0
  ; CP 8
  ; JR NZ, continue    ; salta si A > 0
  ; DJNZ continue    ; salta si A > 0
 

  ;LD A, (papel_2)

  ;SLA A                      ; Desplazamos A 3 veces a la izquierda
  ;SLA A                      ; para colocar el valor 0-7 en los bits
  ;SLA A                      ; donde se debe ubicar PAPER (bits 3-5)
  ;LD (papel_2), A

  
continue:
  
  ;LD (papel_2), A
  ;INC D
  
  ;SLA A
  ;LD A, (papel)              ; Cogemos el valor del papel
  LD B, C                    ; Recuperamos el B del bucle exterior
  DEC C
  DJNZ bucle_lineas          ; Repetir 24 veces
 
  JP Start                   ; Inicio del programa
 
papel  defb   255            ; Valor del papel
papel_2  defb   255            ; Valor del papel
 
;-----------------------------------------------------------------------
; Esta rutina espera a que haya alguna tecla pulsada para volver.
;-----------------------------------------------------------------------
Wait_For_Keys_Pressed:
  XOR A   
  IN A, (254)
  OR 224
  INC A
  JR Z, Wait_For_Keys_Pressed
  RET
 
 
;-----------------------------------------------------------------------
; Esta rutina espera a que no haya ninguna tecla pulsada para volver.
;-----------------------------------------------------------------------
Wait_For_Keys_Released:
  XOR A
  IN A, (254)
  OR 224
  INC A
  JR NZ, Wait_For_Keys_Released
  RET
 
 
;-----------------------------------------------------------------------
; Limpiar la pantalla con el patron de pixeles indicado.
; Entrada:  A = patron a utilizar
;-----------------------------------------------------------------------
ClearScreen:
  LD HL, 16384
  LD (HL), 0
  LD DE, 16385
  LD BC, 192*32-1
  LDIR
  RET

Pausa:  
  HALT
  DJNZ Pausa
  RET
 
resetear_papel_3:
  LD D, 0
  ;RET
  
incrementar_D: 
  INC D
  ;RET

;------------------------------------------------------------
; SetBorder: Cambio del color del borde al del registro A
;------------------------------------------------------------
SetBorder:
  OUT (254), A
  RET

END 50000