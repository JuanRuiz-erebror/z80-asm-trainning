org 50000

numseg equ 8 ; number of centioede segments

; black screen
    ld a, 71 ; whit ink (7) on black paper (0), bright (64)
    ld (23693), a ; set screen colours
    xor a ; quick way to load accumulator with zero
    call 8859 ; set permament border colours

; set up the graphics
    ld hl, blocks ; addess of user-defined graphics
    ld (23675), hl ; make UDGs point to it

; start the game
    call 3503  ; ROM routine - clear screen open chan 2

    xor a  ; zeroise accumulator
    ld (dead), a  ; set flag to say player is alive

; initialize player coordiantes
    ld hl, 21+15*256  ; load hl pair with starting coords
    ld (plx), hl  ; set player coords
    ld hl, 255+255*256 ; player's bullets defaut
    ld (pbx),hl  ; set bullet coords

; initialise segments
    ld b,10 ; number of segments to initialise
    ld hl,segmnt ; segment table
segint:
    ld (hl),1  ; start off moving right
    inc hl
    ld (hl),0  ; start at top
    inc hl
    ld (hl),b  ; use B register as y coordinate
    inc hl 
    djnz segint  ; repeat unit all initialise

    call basexy ; set x y positions player
    call splayr ; show player base symbol


; fill the play area with mushrooms
    ld a,68  ; green ink(4) on black paper (0), bright (64)
    ld (23695), a ; set our temporary colours
    ld b, 50 ; number of mushrooms

mushlp:
    ld a, 22 ; control code for AT character
    rst 16
    call random ; get a "random" number
    and 15 ; vertical range 0 -15
    rst 16
    call random ; another pseudo random number
    and 31 ; horizontal range 0 -31
    rst 16
    ld a, 145 ; UDG 'B' is the mushroom graphic
    rst 16  ; put mushroom on screen
    djnz mushlp ; loop back until all mushrooms displayer


; Main loop
mloop equ $

; Delete the player
    call basexy ; set x y positions player
    call wspace ; display space over player

; now we-ve deleted the player we can move him before redisplaying him
    ld bc, 63486  ; keyboard row 1-5/joystick port 2
    in a, (c);  se what keys are pressed
    rra ; outermost bit === key 1
    push af ; remember the value
    call nc, mpl  ; it's being pressed, move lef
    pop af ; restore acumulator
    rra ; next bit along (value 2) = key 2
    push af ; remember value
    call nc, mpr ; move right
    pop af ; restore acumulator
    rra; next bit (value 4) = key 3
    push af ; remember value
    call nc, mpd; move down
    pop af ; resotre acumulator
    rra; next bit (value 8) key 4
    push af  ; remember the value
    call nc, mpu ; move up
    pop af   ; restore acummulator
    rra  ;last bit (value 16) reads key 5
    call nc, fire

 ; now he's moved we can redisplay the player
    call basexy ; set x y positions player
    call splayr ; show player
    halt ; delay

; Now for the bullet. Firt let's check to see if it's hit anything
    call bchk  ;  check bullet poistion
    call dbull  ; delete bullets
    call moveb  ; move bullets
    call bchk  ; check new position of bullets
    call pbull  ; print bullets at new position

; Now for the centipede segments
    ld ix,segmnt  ; table of segment data
    ld b,10  ; number of segments in table
    
censeg:
    push bc
    ld a,(ix) ; is segment switched on?
    inc a  ; 255=offm increments to zero
    call nz,proseg  ; it's active, process segment
    pop bc
    ld de,3  ; 3 bytes per segment
    add ix,de  ; get next segment in ix registers
    djnz censeg  ; repeat for all segments

    halt ; delay

    ld a,(dead)  ; was the player killed by a segment
    and a 
    ret nz  ; player killer - los a life

; jump back to begining main loop
    jp mloop

; Move player left
mpl:
    ld hl, ply ; remember, y is the horizonztal coord
    ld a, (hl) ; current value low byte
    and a ; is zero?
    ret z ; yes, we can't go any further left

; now check that there isn't a mushrrom in the way
    ld bc, (plx)  ; current coords
    dec b  ; look 1 square to the left
    call atadd  ; get address of attribute at this position
    cp 68  ; mushrooms are bright (64) + green
    ret z  ; there's a mushrrom - we can't move there

    dec (hl) ; substract 1 from coord
    ret

; Move player right
mpr:
    ld hl, ply  ; remember, y is the horizontal coord
    ld a, (hl) ; current value
    cp 31  ; is the right edge (31)
    ret z ; yes, can¡t go further right

; now check that there isn't a mushrrom in the way
    ld bc, (plx)  ; current coords
    inc b  ; look 1 square to the right
    call atadd  ; get address of attribute at this position
    cp 68  ; mushrooms are bright (64) + green
    ret z  ; there's a mushrrom - we can't move there
    inc (hl) ; add 1 to y coord
    ret

; Move player up
mpu:
    ld hl, plx ; remmember, x is vertical coord
    ld a, (hl) ; current value
    cp 4 ; is upper limit (4)?
    ret z ; yes, we can¡t go further

; now check that there isn't a mushrrom in the way
    ld bc, (plx)  ; current coords
    dec c  ; look 1 square up
    call atadd  ; get address of attribute at this position
    cp 68  ; mushrooms are bright (64) + green
    ret z  ; there's a mushrrom - we can't move there

    dec (hl) ; substract 1 from x coord
    ret

; Move player down
mpd:
    ld hl, plx  ; remmember, x is vertical coord
    ld a, (hl)  ; current value
    cp 21  ; is already bottom (21)?
    ret z ; yes, can't go down anymore

; now check that there isn't a mushrrom in the way
    ld bc, (plx)  ; current coords
    inc c  ; look 1 square down
    call atadd  ; get address of attribute at this position
    cp 68  ; mushrooms are bright (64) + green
    ret z  ; there's a mushrrom - we can't move there

    inc (hl)  ; add 1 to x coord
    ret


; Fire a missile
fire:
    ld a,(pbx)  ; bullet vertical coord
    inc a  ; 255 is default value, increments to zer
    ret nz  ; bullet on screen, can't fire again
    ld hl,(plx)  ; player coords
    dec l  ; 1 square higher up
    ld (pbx), hl ; set bullet coords
    ret

bchk:
    ld a,(pbx)  ; bullet vertical
    inc a  ; is it at 255 (defaut)?
    ret z ; yes, no bullet on screen
    ld bc,(pbx)  ; get coords
    call atadd ; find attribute here
    cp 68  ; mushrooms bright and jgreen
    jr z, hmush  ; hit a mushroom!
    ret

hmush:
    ld a, 22  ; AT control code
    rst 16
    ld a,(pbx) ; bullet vertical
    rst 16
    ld a,(pby)  ; bullet horizontal
    rst 16
    call wspace  ; set INK colour to white

kilbul:
    ld a,255  ; x coord of 255 = switch bullet off
    ld (pbx),a  ; destroy bullet
    ret

; Move the bullet up the screen 1 character position at a time
moveb:
    ld a,(pbx)  ; bullet vertical
    inc a  ; is it at 255 (default) ?
    ret z  ; yes, no bullet screen
    sub 2  ; 1 row up
    ld (pbx),a
    ret


; Set up the x and y coordinates for the player's gunbase position,
; this routine is called prior to display and deletion of gunbase.

basexy: 
    ld a,22 ;  AT code
    rst 16 
    ld a,(plx) ; player vertical coord
    rst 16
    ld a,(ply)  ; player horizontal position
    rst 16
    ret

; Show player at current print position.
splayr: 
    ld a,69  ; cyan ink (5) on black paper (0)
    ld (23695),a  ; temporary screen colours
    ld a,144 ; ASCII code for User Defined Graphic 'A'
    rst 16  ; draw player
    ret

pbull:
    ld a,(pbx)  ; bullet vertical
    inc a  ; is it at 255 (default)?
    ret z  ; yes, no bulet on screen
    call bullxy
    ld a,16  ; INK control char
    rst 16
    ld a,6  ; 6 = yellow
    rst 16
    ld a,147 ; UDG 'D' is used for player bullets
    rst 16
    ret

dbull:
    ld a,(pbx)  ; bullet vertical
    inc a ; is it at 155 (default)?
    ret z  ; yes, no bullet on screen
    call bullxy

wspace:
    ld a, 71 ; white ink (7) on black paper (0), bright (64)
    ld (23695), a  ; set our temporary screen colours
    ld a, 32  ; space character
    rst 16
    ret

; Set up the x and y coords for ghe player's bullet position
; this rooutine is called prior to display and detection of bullets
bullxy:
    ld a,22  ; AT code
    rst 16
    ld a,(pbx)  ; player bullet vertical coord
    rst 16  ; set vertical position of player
    ld a,(pby)  ; bullet's horizontal position
    rst 16
    ret

segxy:
    ld a,22  ; ASCII code for AT character
    rst 16  ; display AT code
    ld a,(ix+1) ; get segment x coord
    rst 16 ; display coordinate code
    ld a,(ix+2)  ; get segment y coordinate
    rst 16  ; display coordinate code
    ret

proseg:
    call segcol  ; segment collision detection
    ld a,(ix)  ; check if segment wat switched off
    inc a  ; by collision detection routine
    ret z  ; it was, so this segment is now dead
    call segxy  ; set up segment coordinates
    call wspace  ; display a space, white ink on black
    call segmov  ; nove segment
    call segcol  ; new segment position collision check
    ld a,(ix)  ; check if segment was switched off
    inc a  ; by collision detectionn routine
    ret z  ; it was, so this segment is no dead
    call segxy  ; set up segment coords
    ld a,2  ; attribute code 2 = red segment
    ld (23695),a  ; set temporary attributes
    ld a,146  ; UDG 'C' to display segment
    rst 16
    ret

segmov:
    ld a,(ix+1)  ; x coord
    ld c,a  ; GP x area
    ld a,(ix+2)  ; y coord
    ld b,a  ; GP y area
    ld a,(ix)  ; status flag
    and a  ; is the segment heading left?
    jr z, segml  ; going lef - jump to that bit of code

; so segment is going to right then!
segmr
    ld a,(ix+2)  ; y coord
    cp 31  ; already at right edge of screen?
    jr z, segmd  ; yes - move segment down
    inc a  ; look right
    ld b,a  ; set up GP y coord
    call atadd ; find attribute address
    cp 68 ; mushrooms are bright (64) + green (4)
    jr z, segmd  ; mushroom to right, move down instead
    inc (ix+2)  ; no obstacles, so move right
    ret


; so segment is going left then!
segml:
    ld a,(ix+2)  ; y coord
    and a  ; already at left edge of screen?
    jr z, segmd  ; res - move down
    dec a  ; look left
    ld b,a  ;  set up GP y coord
    call atadd  ; find attribute addres at (dispx, dispy)
    cp 68  ; mushrooms are bright 64 + green 4
    jr z, segmd  ; mushroom at left, move down instead
    dec (ix+2)  ; no obstacles, move left
    ret

; so segment is going down then!
segmd:
    ld a,(ix)  ; segment direction
    xor 1  ; reverse it
    ld (ix),a  ; store new direction
    ld a,(ix+1) ; x coord
    cp 21  ; already at bottom of sreen?
    jr z, segmt  ; yes - mmove segment to top

; At this point we're moving down regardless of any mushrooms that
; may block the segment's path. Anything in the segment's way will
; be obliterated.
    inc (ix+1)  ; haven't reached the bottom, move down
    ret

; moving segment to the top of the screen
segmt:
    xor a  ; same as ld a,0, but saves 1 byte
    ld (ix+1),a  ; new x coordinate = top of screen
    ret


; Segment collision detection
; Checks for collisions with player and player's bullets
segcol:
    ld a,(ply)  ; bullet y position
    cp (ix+2)  ; is it identical to segment y coord?
    jr nz, bulcol  ; y coords differm try bullet instead
    ld a,(plx)  ; player x coord
    cp (ix+1)  ; same as segment?
    jr nz, bulcol  ; x coord differ, try bullet instead

; So we have a collision with the player
killpl:
    ld (dead),a  ; set flag to say that player is now dead
    ret

; Let's check for a collision with the player's bullet
bulcol:
    ld a,(pbx)  ; bulleet x coords
    inc a  ; at default value?
    ret z  ; yes, no bullet to check for
    cp (ix+1)  ; is bullet x coord same as segment x coord?
    ret nz  ; no, so no collision
    ld a,(pby)  ; bullet y position
    cp (ix+2) ; is it identical to segment y coord?
    ret nz ; no - no collision this time

; So we have a collision with the bullet
    call dbull  ; delete bullet
    ld a,22 ; AT code
    rst 16
    ld a,(pbx)  ;  player bullet vertical coord
    inc a  ; 1 line down
    rst 16  ; set vertical position of mushroom
    ld a,(pby)  ; bullet's horizontal position
    rst 16  ; set the horizontal position
    ld a,16  ; ASCII code for INK control
    rst 16
    ld a,4  ; 4 = colour green
    rst 16  ; we want all mushrooms in this colour!
    ld a,145  ; UDG 'B' is the mushroom graphic
    rst 16  ; put the muhrrom on screen
    call kilbul ; kill the bullet
    ld (ix),a  ; kill the segment
    ld hl,numseg ; number of segments
    dec (hl)  ; decrement it
    ret


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

; Calculate address of attribute for character at (dispx, dispy).
atadd:
    ld a,c  ; vertical coordinate
    rrca  ; multiply by 32
    rrca  ; shifting right with carry 3 time is
    rrca  ; quicker than shifting left 5 times
    ld e,a  ; store away in e
    and 3  ; mask bit for hight byte
    add a,88  ; 88*256 = 22528 start of attributes
    ld d,a ; hight byte done
    ld a,e ; get x*32 again
    and 224 ; mask low byte
    ld e,a ; put in l
    ld a,b ; horizontal position
    add a,e ; add to low byte
    ld e,a ; de = addres of attributes
    ld a, (de) ; return attribute in accumulator
    ret

plx defb 0 ; player's x coordinate.
ply defb 0 ; player's y coordinate.

pbx defb 255  ; player's bullet coords
pby defb 255  

dead  defb 0  ; flag - player dead when non-zero

; UDG graphics.
blocks: 
    defb 16,16,56,56,124,124,254,254 ; player base
    defb 24,126,255,255,60,60,60,60 ; mushroom
    defb 24,126,126,255,255,126,126,24 ; player bullet
    defb 0,102,102,102,102,102,102,0 ; player bullet


; Table of segments
; Format: 3 bytes per entry, 10 segments
; byte 1: 255=segment off, 0=left, 1=right
; byte 2: x (vertical) coord
; byte 3 = y (horizontal) coord

segmnt:
    defb 0,0,0 ; segment 1
    defb 0,0,0 ; segment 2
    defb 0,0,0 ; segment 3
    defb 0,0,0 ; segment 4
    defb 0,0,0 ; segment 5
    defb 0,0,0 ; segment 6
    defb 0,0,0 ; segment 7
    defb 0,0,0 ; segment 8
    defb 0,0,0 ; segment 9
    defb 0,0,0 ; segment 10
    defb 0,0,0 ; segment 10

end 50000