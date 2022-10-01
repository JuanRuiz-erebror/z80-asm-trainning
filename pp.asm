; Comparacion entre A y B (=, >, <)
ORG 50000
  LD B, 7
  LD A, 8

  CP B  ; Flags = estado (A-B)
  JP Z, A_Igual_que_B ; IF (a-b)=0 THEN a=b
  JP NC, A_Mayor_que_B ; IF(a-b)>0 THEN a>b
  JP C, A_Menor_que_B ; IF(a-b)<0 THEN a<b

A_Mayor_que_B:
  LD A, 255
  LD (16690), A  ; 8 pixeles en la parte sup-izq
  LD (16688), A; 8 pixeles en la parte sup-izq
  JP fin

A_Menor_que_B:
  LD A, 120
  LD (19056), A ; centro pantalla
  JP fin

A_Igual_que_B:
  LD A, 255
  LD (21470), A ; inf-der

fin:
  RET
;  JP fin  ; bucle infinito

END 50000