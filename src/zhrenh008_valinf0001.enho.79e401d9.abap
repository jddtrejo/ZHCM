"Name: \PR:MP000100\FO:RE528T\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH008_VALINF0001.

  DATA: VL_SACHX TYPE SACHX.

  SELECT SINGLE SACHX
    INTO VL_SACHX
    FROM ZHR_ENCARGADO
    WHERE WERKS EQ P0001-WERKS.

  IF SY-SUBRC EQ 0.
    P0001-SACHZ = VL_SACHX.
  ENDIF.

ENDENHANCEMENT.
