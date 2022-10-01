org 50000

atadd:
    ld a,b  ; x position
    rrca  ; multiply by 32
    rrca 
    rrca
    ld l,a  ; store away in l
    and 3  ; mask bit for hight byte
    add a,88  ; 88*256 = 22528 start of attributes
    ld h,a ; hight byte done
    ld a, l ; get x*32 again
    and 224 ; mask low byte
    ld l,a ; put in l
    ld a,c ; get y displacement
    add a,l ; add to low byte
    ld l,a ; hl = addres of attributes
    ld a, (hl) ; return attribute in a
    ret
end 50000
