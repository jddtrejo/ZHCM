"Name: \PR:MP000200\FO:ONLY_ALFA_CHAR\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH034_PUNTO_0002_P1.
*Se necesita considerar "." en nombre debido a reforma fiscal 4.0 2022
  BREAK JDDTREJO.
  DATA: VG_NOMBRE TYPE CHAR100.

  IF ( SY-TCODE EQ 'PA20' OR
       SY-TCODE EQ 'PA30' OR
       SY-TCODE EQ 'PA40' )  AND T777D-INFTY  EQ '0002' AND ( CAMPO EQ 'Nombre de pila' OR
                                                              CAMPO EQ 'Apellidos' OR
                                                              CAMPO EQ '2° Apellido' ).
    IF P_STRING IS NOT INITIAL.
      MOVE P_STRING TO VG_NOMBRE.
      REPLACE ALL OCCURRENCES OF '.' IN P_STRING WITH SPACE.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
