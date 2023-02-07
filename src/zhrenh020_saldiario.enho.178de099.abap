"Name: \PR:HMXCALC0\FO:SDI_SET_BASE\SE:END\EI
ENHANCEMENT 0 ZHRENH020_SALDIARIO.

  DATA: ls_intsal type typ_intsal.
" 03.03.2016 JLGF 4358 CAMBIO DE NOMINAS QUINCENALE A SEMANALES
  IF p0001-persk = '16'. "AND p_wa_intsal-inrep NE 'B'.
    LOOP AT p_intsal INTO ls_intsal
      WHERE inrep NE 'B'.
       IF ls_intsal-sdia EQ '0' AND ls_intsal-sdifj NE '0'.
         MOVE '0' TO ls_intsal-sdifj.
         MODIFY p_intsal FROM ls_intsal.
       ENDIF.
    ENDLOOP.
  ENDIF.

ENDENHANCEMENT.
