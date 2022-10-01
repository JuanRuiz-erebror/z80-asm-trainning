

  ; Ejemplo de uso de LUT
ORG 50000

entrada:
 
  CALL Generate_Scanline_Table
  LD B, 192
 
loop_draw:
  PUSH BC                ; Preservamos B (por el bucle)
 
  LD C, 54              ; X = 127, Y = B
 
  CALL Get_Pixel_Offset_LUT_HR
 
  LD A, 128
  LD (HL), A             ; Imprimimos el pixel
 
 
  POP BC
  DJNZ loop_draw
 
loop:                    ; Bucle para no volver a BASIC y que
  JR loop      
  


; Get_Pixel_Offset_LUT_HR(x,y):
;
; Entrada:   B = Y,  C = X
; Salida:   HL = Direccion de memoria del pixel (x,y)
;            A = Posicion relativa del pixel en el byte
;-------------------------------------------------------------
Get_Pixel_Offset_LUT_HR:
   LD DE, Scanline_Offsets   ; Direccion de nuestra LUT
   LD L, B                   ; L = Y
   LD H, 0
  ADD HL, HL                ; HL = HL * 2 = Y * 2 // se multiplica x2 porque cada direccion de memoria son 2bytes
   ADD HL, DE                ; HL = (Y*2) + ScanLine_Offset
                             ; Ahora Offset = [HL]
   LD A, (HL)                ; Cogemos el valor bajo de la direccion en A
   INC L
   LD H, (HL)                ; Cogemos el valor alto de la direccion en H
   LD L, A                   ; HL es ahora Direccion(0,Y)
                             ; Ahora sumamos la X, para lo cual calculamos CCCCC
   LD A, C                   ; Calculamos columna
   RRA
   RRA
   RRA                       ; A = A>>3 = ???CCCCCb
   AND 31                    ; A = 000CCCCB
   ADD A, L                  ; HL = HL + C
   LD L, A
   LD A, C                   ; Recuperamos la coordenada (X)
   AND 7                     ; A = Posicion relativa del pixel
   RET  
   

   

;--------------------------------------------------------
; Generar LookUp Table de scanlines en memoria.
; Rutina por Derek M. Smith (2005).
;--------------------------------------------------------


Scanline_Offsets EQU $F900
 
Generate_Scanline_Table:
   LD DE, $4000
   LD HL, Scanline_Offsets
   LD B, 192
 
genscan_loop:
   LD (HL), E
   INC L
   LD (HL), D           ; Guardamos en (HL) (tabla)
   INC HL               ; el valor de DE (offset)
 
   ; Recorremos los scanlines y bloques en un bucle generando las
   ; sucesivas direccione en DE para almacenarlas en la tabla. 
   ; Cuando se cambia de caracter, scanline o tercio, se ajusta:
   INC D
   LD A, D
   AND 7
   JR NZ, genscan_nextline
   LD A, E
   ADD A, 32
   LD E, A
   JR C, genscan_nextline
   LD A, D
   SUB 8
   LD D, A
 
genscan_nextline:
   DJNZ genscan_loop
   RET
   

  
END 50000