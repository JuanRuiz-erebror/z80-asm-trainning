org 50000

; Simple pseudo-random number generator.
; Steps a pointer through the ROM (held in seed), returning
; the contents of the byte at that location.

random:
    ld hl, (seed) ; Pointer
    ld a,h ;
    and 31 ; keep it within first 8k of ROM
    ld h,a 
    ld a, (hl) ; get "random" number from location
    inc hl ; increment pointer
    ld (seed), hl
    ret

seed defw 0


end 50000