;-----------------------------------------------------------------------
; Fundido de pantalla decrementando tinta y papel en los atributos.
;-----------------------------------------------------------------------
ORG 50000

FadeAttributes:
   PUSH AF
   PUSH BC
   PUSH DE
   PUSH HL                      ; Preservamos los registros
 
   LD B, 9                      ; Repetiremos el bucle 9 veces
 
fadescreen_loop1:
   LD HL, 16384+6144            ; Apuntamos HL a la zona de atributos
   LD DE, 768                   ; Iteraciones bucle
 
   HALT
   HALT                         ; Ralentizamos el efecto
 
fadescreen_loop2:
   LD A, (HL)                   ; Cogemos el atributo
   AND 127                      ; Eliminamos el bit de flash
   LD C, A
 
   AND 7                        ; Extraemos la tinta (AND 00000111b)
   JR Z, fadescreen_ink_zero    ; Si la tinta ya es cero, no hacemos nada
 
   DEC A                        ; Si no es cero, decrementamos su valor
 
fadescreen_ink_zero:
 
   EX AF, AF'                   ; Nos hacemos una copia de la tinta en A'
   LD A, C                      ; Recuperamos el atributo
   SRA A
   SRA A                        ; Pasamos los bits de paper a 0-2
   SRA A                        ; con 3 instrucciones de desplazamiento >>
 
   AND 7                        ; Eliminamos el resto de bits
   JR Z, fadescreen_paper_zero  ; Si ya es cero, no lo decrementamos
 
   DEC A                        ; Lo decrementamos
 
fadescreen_paper_zero:
   SLA A
   SLA A                        ; Volvemos a color paper en bits 3-5
   SLA A                        ; Con 3 instrucciones de desplazamiento <<
 
   LD C, A                      ; Guardamos el papel decrementado en A
   EX AF, AF'                   ; Recuperamos A'
   OR C                         ; A = A OR C  =  PAPEL OR TINTA
 
   LD (HL), A                   ; Almacenamos el atributo modificado
   INC HL                       ; Avanzamos puntero de memoria
 
   DEC DE
   LD A, D
   OR E
   JP NZ, fadescreen_loop2      ; Hasta que DE == 0
 
   DJNZ fadescreen_loop1        ; Repeticion 9 veces
 
   POP HL
   POP DE
   POP BC
   POP AF                       ; Restauramos registros
   RET

END 50000