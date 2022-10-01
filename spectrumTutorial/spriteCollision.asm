; Simple collision check 16x16 pixel sprite
; Check (l, h) for collision with (c,b), strict snforcement
colx16 
    ld a,l  ; x coord
    sub c  ; substract x
    add a,15  ; add maximun distance
    cp 31  ; within x range
    ret nc  ; no - they've missed
    ld a,h  ; y coord
    sub b  ; subtract y
    add a,15  ; add maximun distance
    cp 31  ; within y range?
    ret  ; carry flag set if there's a collision


; Check (l,h) for collision with (c,b) cutting corners
colc16:
    ld a,l  ; x coord
    sub c ; subtract x
    jr nc,colc1a  ; result is positive
    neg  ; make negative positive
colc1a:
    cp 16  ; within x range?
    ret nc  ; no - they've missed
    ld e,a  ; store difference
    ld a,h  ; y coord
    sub b  ; subtract y
    jr nc, colc1b  ; result is positive
    neg  ; make negative positive
colc1b:
    cp 16  ;  within y range?
    ret nc  ; no -they've missed
    add a,e  ; add x difference
    cp 26  ; only 5 corner pixels touching?
    ret  ; carry set if there's a collision