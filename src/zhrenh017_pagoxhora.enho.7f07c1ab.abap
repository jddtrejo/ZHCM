"Name: \PR:HMXCALC0\FO:CHECK_TOP\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH017_PAGOXHORA.
" 16.02.2016 JPM 4358 CAMBIO DE NOMINAS QUINCENALE A SEMANALES
*  Declara Variables
  DATA: el_wpbp    TYPE pc205,
        el_rt      TYPE pc207.

* Inicia Validación.
  IF p0001-persk = '16' AND  p_sdimx = 0.
    LOOP AT wpbp INTO el_wpbp
         WHERE begda LE P_BEGDA
           AND endda GE P_BEGDA .
    ENDLOOP.

    LOOP AT rt INTO el_rt
       WHERE lgart eq '/305'
         AND apznr EQ el_wpbp-apznr.
      MOVE el_rt-betrg TO p_sdimx.
    ENDLOOP.
  ENDIF.
ENDENHANCEMENT.
