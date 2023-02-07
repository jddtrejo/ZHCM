"Name: \PR:HMXCISR0\FO:CALC_BASESGR\SE:BEGIN\EI
ENHANCEMENT 0 ZRH_FORM.
 IF sy-cprog EQ 'ZHR_REP_CTNAM'. " Se activa la impresión para habilitar llamado desde programa
   flag_write = true..
 ENDIF.
ENDENHANCEMENT.
