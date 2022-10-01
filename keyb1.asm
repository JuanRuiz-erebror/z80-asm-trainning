;--------------------------------------------------------------
; Prueba de conversion de Scancode a ASCII
; Recuerda que para compilarla necesitarás añadir las rutinas
; Find_Key y Scancode2ASCII a este listado, se han eliminado
; del mismo para reducir la longitud del programa.
;--------------------------------------------------------------
 ;Lectura tecla "P" en un bucle

ORG 32768

START:
    call Wait_For_Keys_Released

chequear_teclas:
    call Find_Key
    jr nz, chequear_teclas  ; Repetir si la tecla no es valida
    inc d
    jr z, chequear_teclas ; Repetir si no se pulsó ninguna tecla
    dec de
    ; en este punto d es un scancode válido
    call Scancode2Ascii
    ; en este punto A contiene el ascii del scancode en d
    ;lo imprimimos por pantalla con rst 16
    rst 16
    call Wait_For_Keys_Released
    jr START




Find_Key:
 
   LD DE, $FF2F         ; Valor inicial "ninguna tecla"
   LD BC, $FEFE         ; Puerto

;-----------------------------------------------------------------------
; Esta rutina espera a que no haya ninguna tecla pulsada para volver,
; consultando las diferentes filas del teclado en un bucle.
;-----------------------------------------------------------------------
Wait_For_Keys_Released:
 XOR A
 IN A, ($FE)
 OR 224
 INC A
 JR NZ, Wait_For_Keys_Released
 RET

 ;-----------------------------------------------------------------------
; Scancode2Ascii: convierte un scancode en un valor ASCII
; IN:  D = scancode de la tecla a analizar
; OUT: A = Codigo ASCII de la tecla
;-----------------------------------------------------------------------
Scancode2Ascii:
 
   push hl
   push bc
 
   ld hl,0
   ld bc, TABLA_S2ASCII
   add hl, bc           ; hl apunta al inicio de la tabla
 
   ; buscamos en la tabla un max de 40 veces por el codigo
   ; le sumamos 40 a HL, leemos el valor de (HL) y ret A
SC2Ascii_1:
   ld a, (hl)           ; leemos un byte de la tabla
   cp "1"               ; Si es "1" fin de la rutina (porque en
                        ; (la tabla habriamos llegado a los ASCIIs)
   jr z, SC2Ascii_Exit  ; (y es condicion de forzado de salida) 
   inc hl               ; incrementamos puntero de HL
   cp d                 ; comparamos si A==D (nuestro scancode)
   jr nz, SC2Ascii_1
 
SC2Ascii_Found:
   ld bc, 39            ; Sumamos 39(+INC HL=40) para ir a la seccion
   add hl, bc           ; de la tabla con los codigos ASCII
   ld a,(hl)            ; leemos el codigo ASCII de esa tabla
 
SC2Ascii_Exit:
   pop bc
   pop hl
   ret
 
   ; 40 scancodes seguidos de sus ASCIIs equivalentes
TABLA_S2ASCII:
   defb $24, $1C, $14, $0C, $04, $03, $0B, $13, $1B, $23
   defb $25, $1D, $15, $0D, $05, $02, $0A, $12, $1A, $22
   defb $26, $1E, $16, $0E, $06, $01, $09, $11, $19, $21
   defb $27, $1F, $17, $0F, $07, $00, $08, $10, $18, $20
   defm "1234567890QWERTYUIOPASDFGHJKLecZXCVBNMys"

end 327668