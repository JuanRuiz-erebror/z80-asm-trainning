; Mr. Jones' keyboard test routine.

org 50000
ktest:
    ld c,15  ; key to test in c
    and 7 ; mask bits d0-d2 for row
    inc a ; in range 1-8
    ld b,a ; place in b
    srl c ; divide c by 8
    srl c ; to find position within row
    srl c
    ld a,5 ; only 5 keys per row
    sub c  ; substract position
    ld c, a  ; put in c
    ld a, 254  ; high byte of port to read

ktest0:
    rrca ; rotate into position
    djnz ktest0 ; repeat until we've found relevant row
    in a, (254) ; read port (a=hight, 254=low)

ktest1:
    rra ; rotate bit out of result
    dec c ; loop counter
    jp nz, ktest1 ; repeat until bit position in carry
    ret

end 50000