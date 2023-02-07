"Name: \PR:HMXCALC0\FO:SDI_SET_BASE\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH020_SALDIARIO.

" 03.03.2016 JLGF 4358 CAMBIO DE NOMINAS QUINCENALE A SEMANALES
  IF p_sdivr NE '0' AND p_wa_intsal-inrep NE 'B'.
    IF p_wa_intsal-sdia EQ '0' AND p_wa_intsal-sdifj NE '0'.
      MOVE '0' TO p_wa_intsal-sdifj.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
