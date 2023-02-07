"Name: \PR:RHCMPCOMPARE_ACTUAL_PLANNED\FO:GET_DOM\SE:END\EI
ENHANCEMENT 0 ZHRENH009_DESACTCAMPO.

CHECK sy-tcode eq 'ZHRTR014A'.
 sy-title = 'Comparación sueldo base vs sueldo mínimo puesto'.
loop at screen.
  check screen-name eq 'ZEINH'.
  screen-input = '0'.
  modify screen.
endloop.
ENDENHANCEMENT.
