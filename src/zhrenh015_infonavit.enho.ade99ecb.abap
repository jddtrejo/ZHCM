"Name: \PR:HMXCINF0\FO:USERCOMMAND\SE:END\EI
ENHANCEMENT 0 ZHRENH015_INFONAVIT.
*Descargar Informacion de Credito Infonavit a archivo .TXT

 case ucomm.
   WHEN 'EXP'.
   IF CINFO = 'X'. " Infonavit

   data: lv_send type char1.

     CALL FUNCTION 'ZCCRHGF037_TXT_INFONAVIT'
       EXPORTING
         zbegda         = pn-begda
         zendda         = pn-endda
       IMPORTING
         V_SEND         = lv_send
       tables
         it_datos       = datos[] .
     IF sy-subrc eq 0.
       if lv_send = 'X'.
         message s899(3l) WITH 'Archivo creado'.
       else.
         message s899(3l) WITH 'Archivo no creado'.
       endif.
     ENDIF.

   ENDIF.


 ENDCASE.




ENDENHANCEMENT.
