org 50000

;Frequency of G sharp in octave of middle C = 415.30
;Frequency of G sharp one octave higher = 830.60
;Duration = 830.6 / 4 = 207.65
;Pitch = 437500 / 830.6 - 30.125 = 496.6

;     ld hl, 500 ; pitch
;     ld b, 250 ; length pitch blend
; loop:
;     push bc
;     push hl ; store pitch
;     ld de, 100 ; very short duration
;     call 949 ; ROM beeper routine
;     pop hl ; restore pitch
;     inc hl ; pitch goung up
;     pop bc 
;     djnz loop ; repet
;     ret

noise:
    ld e,250 ; repeat 250 times
    ld hl, 0 ; start pointer in ROM

noise2:
    push de
    ld b,32 ; length step

noise0:
    push bc
    ld a, (hl) ; next "random" number
    inc hl ; pointer
    and 248 ; we want a black border
    out (254), a ; write to speaker
    ld a,e ; as a gets smaller...
    cpl ; ... we increase the delay

noise1:
    dec a; decrement loop counter
    jr nz, noise1 ; delay loop
    pop bc 
    djnz noise0 ; next step
    pop de 
    ld a,e 
    sub 24 ; size of step
    cp 30 ; end of range
    ret z
    ret c 
    ld e,a 
    cpl

noise3:
    ld b,40 ; silent period

noise4:
    djnz noise4
    dec a
    jr nz, noise3
    jr noise2

end 50000