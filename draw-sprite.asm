;-------------------------------------------------------------
; DrawSprite_8x8_LD:
; Imprime un sprite de 8x8 pixeles con o sin atributos.
;
; Entrada (paso por parametros en memoria):
; Direccion   Parametro
; 50000       Direccion de la tabla de Sprites
; 50002       Direccion de la tabla de Atribs  (0=no atributos)
; 50004       Coordenada X en baja resolucion
; 50005       Coordenada Y en baja resolucion
; 50006       Numero de sprite a dibujar (0-N) 
;-------------------------------------------------------------
DrawSprite_8x8_LD:
 
   ; Guardamos en BC la pareja (x,y) -> B=COORD_Y y C=COORD_X
   LD BC, (DS_COORD_X)
 
   ;;; Calculamos las coordenadas destino de pantalla en DE:
   LD A, B
   AND $18
   ADD A, $40
   LD D, A           ; Ya tenemos la parte alta calculada (010TT000)
   LD A, B           ; Ahora calculamos la parte baja
   AND 7
   RRCA
   RRCA
   RRCA              ; A = NNN00000b
   ADD A, C          ; Sumamos COLUMNA -> A = NNNCCCCCb
   LD E, A           ; Lo cargamos en la parte baja de la direccion
                     ; DE contiene ahora la direccion destino.
 
   ;;; Calcular posicion origen (array sprites) en HL como:
   ;;;     direccion = base_sprites + (NUM_SPRITE*8)
 
   LD BC, (DS_SPRITES)
   LD A, (DS_NUMSPR)
   LD H, 0
   LD L, A           ; HL = DS_NUMSPR
   ADD HL, HL        ; HL = HL * 2
   ADD HL, HL        ; HL = HL * 4
   ADD HL, HL        ; HL = HL * 8 = DS_NUMSPR * 8
   ADD HL, BC        ; HL = BC + HL = DS_SPRITES + (DS_NUMSPR * 8)
                     ; HL contiene la direccion de inicio en el sprite
 
   EX DE, HL         ; Intercambiamos DE y HL (DE=origen, HL=destino)
 
   ;;; Dibujar 8 scanlines (DE) -> (HL) y bajar scanline
   ;;; Incrementar scanline del sprite (DE)
 
   LD B, 8          ; 8 scanlines -> 8 iteraciones
 
drawsp8x8_loopLD:
   LD A, (DE)       ; Tomamos el dato del sprite
   LD (HL), A       ; Establecemos el valor en videomemoria
   INC DE           ; Incrementamos puntero en sprite
   INC H            ; Incrementamos puntero en pantalla (scanline+=1)
   DJNZ drawsp8x8_loopLD
 
   ;;; En este punto, los 8 scanlines del sprite estan dibujados.
   LD A, H
   SUB 8              ; Recuperamos la posicion de memoria del 
   LD B, A            ; scanline inicial donde empezamos a dibujar
   LD C, L            ; BC = HL - 8
 
   ;;; Considerar el dibujado de los atributos (Si DS_ATTRIBS=0 -> RET)
   LD HL, (DS_ATTRIBS)
 
   XOR A              ; A = 0
   ADD A, H           ; A = 0 + H = H
   RET Z              ; Si H = 0, volver (no dibujar atributos)
 
   ;;; Calcular posicion destino en area de atributos en DE.
   LD A, B            ; Codigo de Get_Attr_Offset_From_Image
   RRCA               ; Obtenemos dir de atributo a partir de
   RRCA               ; dir de zona de imagen.
   RRCA               ; Nos evita volver a obtener X e Y
   AND 3              ; y hacer el calculo completo de la 
   OR $58             ; direccion en zona de atributos
   LD D, A
   LD E, C            ; DE tiene el offset del attr de HL
 
   LD A, (DS_NUMSPR)  ; Cogemos el numero de sprite a dibujar
   LD C, A
   LD B, 0
   ADD HL, BC         ; HL = HL+DS_NUMSPR = Origen de atributo
 
   ;;; Copiar (HL) en (DE) -> Copiar atributo de sprite a pantalla
   LD A, (HL)
   LD (DE), A         ; Mas rapido que LDI (7+7 vs 16 t-estados)
   RET                ; porque no necesitamos incrementar HL y DE 