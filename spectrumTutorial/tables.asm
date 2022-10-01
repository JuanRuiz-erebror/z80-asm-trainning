org 50000

    ld hl,aliens ; alien data structures
    ld b,55  ; nummber of aliens

; loop0:
;     call show  ; show the alien
;     djnz loop0  ; repeat for all aliens
;     ret 

; show:
;     ld a,(hl) ; fetch alien status
;     cp 255 ; is alien switched off
;     jr z,next ; yes, so dont display him
;     push hl  ; store alien address on the stack
;     inc hl ; point to x coord
;     ld d,(hl)  ; get coord
;     inc hl  ; point to y coord
;     ld e,(hl)  ; get coord
;     call disply  ; display alien at (d,e)
;     pop hl

; next:
;     ld de, 3  ; size of each alien addres from the stack
;     add hl,de ; point the next alien
;     ret ; leave hl pointing to next one

loop0:
    call show ; show this alien
    ld de,3 ; size of each alien table entry
    add ix,de  ; point to next alien
    djnz loop0 ; repeat for all aliens

show:
    ld a,(ix) ; fetch alien status
    cp 255 ; is alien switched off?
    ret z ; yes, so dont display him
    ld d,(ix+1) ; get coord
    ld e,(ix+2)  ; get coord
    jp display ; display alien at (d,e)



end 50000