"Name: \PR:HMXCISR0\FO:SCREEN_DISPLAY_GRID_ALV\SE:BEGIN\EI
ENHANCEMENT 0 ZRH_FORM.
 IF sy-cprog EQ 'ZHR_REP_CTNAM'. " Se omite la impresión de ALV en llamados
   EXIT.
 ENDIF.
ENDENHANCEMENT.
