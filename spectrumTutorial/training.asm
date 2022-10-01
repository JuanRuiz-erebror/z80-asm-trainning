org 50000

ld hl, 23560
ld (hl), 0
loop:
  ld a, (hl)
  cp 0
  jr z, loop
  ret

end 50000