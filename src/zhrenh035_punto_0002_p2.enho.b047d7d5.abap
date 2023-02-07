"Name: \PR:MP000200\FO:ONLY_ALFA_CHAR\SE:END\EI
ENHANCEMENT 0 ZHRENH035_PUNTO_0002_P2.
*Se necesita considerar "." en nombre debido a reforma fiscal 4.0 2022
  BREAK JDDTREJO.

  IF ( SY-TCODE EQ 'PA20' OR
       SY-TCODE EQ 'PA30' OR
       SY-TCODE EQ 'PA40' ) AND T777D-INFTY EQ '0002' AND ( CAMPO EQ 'Nombre de pila' OR
                                                            CAMPO EQ 'Apellidos' OR
                                                            CAMPO EQ '2° Apellido' ).
    IF VG_NOMBRE IS NOT INITIAL.
      MOVE VG_NOMBRE TO P_STRING.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
