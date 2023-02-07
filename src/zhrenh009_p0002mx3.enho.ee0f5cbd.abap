"Name: \PR:MP000200\FO:CHECK_DUP_MX_PERID\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH009_P0002MX3.
CHECK PSPAR-TCLAS EQ 'A'.

DATA: LV_BUKRS TYPE BUKRS.
DATA: LV_PERNR TYPE PERSNO.
*DATA: LV_PERID TYPE PRDNI.
CLEAR: LV_BUKRS, LV_PERNR.

 CHECK PSPAR-TCLAS EQ 'A'.

* Check to see if the CURP entered already exists for another employee.
* If the CURP exists already, then issue a warning message.
  SELECT * FROM M_PREMC WHERE PERMO EQ P_PERMO
                        AND   PERID EQ P_PERID
                        AND   PERNR NE P_PERNR.
    EXIT.
  ENDSELECT.
*
  IF SY-SUBRC EQ 0.                    "CURP match found

* read infotype 0031 (reference personnel no.)
    PERFORM READ_INFOTYPE(SAPFP50P) USING M_PREMC-PERNR
                                          '0031'
                                          SPACE
                                          SPACE
                                          SPACE
                                          LOW_DATE
                                          HIGH_DATE
                                          LAST
                                          NOP
                                          *P0031.
    IF SY-SUBRC NE 0.                  "if Infotype 0031 does not exist
*      MESSAGE e028(3L) WITH M_PREMC-PERNR.
*--------------------------------------------------------------------*
*---------------------------------------------------
* Busqueda de Número de personal en Infotipo P0002
*---------------------------------------------------
 SELECT SINGLE PA0001~BUKRS
               PA0001~PERNR
          INTO (LV_BUKRS, LV_PERNR)
          FROM PA0001
         WHERE PERNR EQ P_PERNR.

      IF SY-SUBRC EQ 0.
*   ---------------------------------------------------
*    Si la Sociedad se encuentra entre las siguientes
*   ---------------------------------------------------
           IF ( LV_BUKRS EQ 'ASEJ' ) OR ( LV_BUKRS EQ 'DOME' )
           OR ( LV_BUKRS EQ 'DSWW' ) OR ( LV_BUKRS EQ 'CONF' )
           OR ( LV_BUKRS EQ 'SCCO' ) OR ( LV_BUKRS EQ 'PREJ' )
           OR ( LV_BUKRS EQ 'SOCO' ).
              EXIT.
             ELSE.
              MESSAGE e028(3L) WITH M_PREMC-PERNR.
           ENDIF.

       ENDIF.
    ELSE.

* check to see if the match is due to reference personnel no.
      MATCH_FOUND_MX = NO.
      DO NRFPN31 TIMES VARYING P0031_PERNR_MX FROM *P0031-RFP01
                                           NEXT *P0031-RFP02.
        IF P0031_PERNR_MX EQ P_PERNR.
          MATCH_FOUND_MX = YES.
          EXIT.
        ENDIF.
      ENDDO.
*only accept CURP if this PERNR is referenced by M_PREMC in IT0031
      IF MATCH_FOUND_MX = NO.
        "Sustituimos mss por validacion
*        MESSAGE e028(3L) WITH M_PREMC-PERNR.
*--------------------------------------------------------------------*
*---------------------------------------------------
* Busqueda de Número de personal en Infotipo P0002
*---------------------------------------------------
 SELECT SINGLE PA0001~BUKRS
               PA0001~PERNR
          INTO (LV_BUKRS, LV_PERNR)
          FROM PA0001
         WHERE PERNR EQ P_PERNR.

      IF SY-SUBRC EQ 0.
*   ---------------------------------------------------
*    Si la Sociedad se encuentra entre las siguientes
*   ---------------------------------------------------
           IF ( LV_BUKRS EQ 'ASEJ' ) OR ( LV_BUKRS EQ 'DOME' )
           OR ( LV_BUKRS EQ 'DSWW' ) OR ( LV_BUKRS EQ 'CONF' )
           OR ( LV_BUKRS EQ 'SCCO' ) OR ( LV_BUKRS EQ 'PREJ' )
           OR ( LV_BUKRS EQ 'SOCO' ).
             EXIT.

             ELSE.
*                  IF SY-SUBRC EQ 0.
*                     MESSAGE E874(ES) WITH 'Registro Duplicado con' LV_PERNR.
                    MESSAGE e028(3L) WITH M_PREMC-PERNR.
*                  ENDIF.
           ENDIF.

       ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
EXIT.
ENDENHANCEMENT.
