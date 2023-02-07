"Name: \PR:MP000000\FO:RE528T\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH008_VALINF0000.
 data:  vl_kwert TYPE abrwt,
        vl_integ TYPE abrwt,
        vl_dias  TYPE char45,
        tl_medidas TYPE STANDARD TABLE OF tvarvc,
        wa_medidas TYPE tvarvc,
        r_medidas TYPE RANGE OF char45,
        wa_rango LIKE LINE OF r_medidas,
        vl_str TYPE i,
        vl_subrc TYPE sy-subrc,
        vl_golive TYPE char45,
        vl_datum TYPE d,
        vl_const TYPE  ABRKN, " 14.03.2016 10:21:31 JPM 4644
        tl_1008    TYPE TABLE OF p1008 WITH HEADER LINE,"CCV 12.04.2016 4664
        V_OBJID TYPE PLANS,"CCV 12.04.2016 4664
        vl_lecon TYPE  ABRKN."CCV 26.04.2016 4664

 CLEAR: TL_1008[],TL_1008."CCV 12.04.2016 4664

 break: jddtrejo, S101JRH.

if p0000-begda is not initial and fcode is not initial.

    IF p0000-massn EQ 'Z6'
*------------------------------------------------------------*  JPM INI 4644
      OR p0000-massn EQ 'Z2'
      OR p0000-massn EQ 'Z1'.

      V_OBJID = MK_PLANS.
      EXPORT V_OBJID TO MEMORY ID 'V_OBJID'.
*break CCORONA.

       CALL FUNCTION 'RH_READ_INFTY_NNNN'""CCV 12.04.2016 4664
         EXPORTING
           PLVAR                 = '01'
           OTYPE                 = 'S'
           OBJID                 = V_OBJID
           INFTY                 = '1008'
           BEGDA                 = P0000-BEGDA
           ENDDA                 = P0000-endda
         TABLES
           INNNN                 = TL_1008
         EXCEPTIONS
           NOTHING_FOUND         = 1
           WRONG_CONDITION       = 2
           INFOTYP_NOT_SUPPORTED = 3
           WRONG_PARAMETERS      = 4
           OTHERS                = 5.

       IF SY-SUBRC EQ 0.
         READ TABLE TL_1008 INDEX 1.
       ENDIF.

      CASE p0000-massn.
        WHEN 'Z6'.
          vl_const = 'B'.
        WHEN 'Z2'.
          vl_const = 'R'.
        WHEN 'Z1'.
          vl_const = 'A'.
      ENDCASE.
*------------------------------------------------------------*  JPM FIN 4644


   "JDDTS 17.07.2018 6298
   DATA: WA_HRP1013 TYPE HRP1013,
         IT_FEAT    TYPE STANDARD TABLE OF ZRHES_FEATURESABKRS,
         WA_FEAT    TYPE ZRHES_FEATURESABKRS,
         DAT_NEW    TYPE DATUM,
         DAT_BAJ    TYPE DATUM,
         PME03      TYPE PME04,
         MMDD       TYPE CHAR02,
         V_ABKRS    TYPE ABKRS,
         V_DIAS     TYPE I.
   SELECT SINGLE * FROM HRP1013 INTO WA_HRP1013 WHERE OBJID EQ V_OBJID.
   PME03-MOLGA = '32'.
   PME03-PERSK = WA_HRP1013-PERSK.
   PME03-BUKRS = TL_1008-bukrs.
   CALL FUNCTION 'HR_FEATURE_BACKFIELD'
      EXPORTING
        FEATURE                     = 'ABKRS'
        STRUC_CONTENT               = PME03
        KIND_OF_ERROR               = SPACE
      IMPORTING
        BACK                        = MMDD
      EXCEPTIONS
        DUMMY                       = 1
        ERROR_OPERATION             = 2
        NO_BACKVALUE                = 3
        FEATURE_NOT_GENERATED       = 4
        INVALID_SIGN_IN_FUNID       = 5
        FIELD_IN_REPORT_TAB_IN_PE03 = 6
        OTHERS                      = 7.
   MOVE MMDD TO V_ABKRS.
    "JDDTS 17.07.2018 6298

    CALL FUNCTION 'ZCCHRMF002_LEE_T511K'
      EXPORTING
        i_konst            = vl_const
        i_datum            = p0000-begda
        I_BUKRS            = TL_1008-bukrs
        I_BAND             = 'X'
        I_ABKRS            = V_ABKRS "JDDTS 17.07.2018 6298
     IMPORTING
        E_KWERT            = vl_kwert
     CHANGING
        C_CONST            = vl_lecon
     EXCEPTIONS
       NO_HAY_DATOS       = 1
       OTHERS             = 2
          .
      IF sy-subrc NE 0.
         MESSAGE e004(zhr01) WITH 'Error al leer constante' vl_const TL_1008-bukrs p0000-begda.
*   Error al leer la constante & para la fecha &
      ELSE.
*        IF p0000-begda > sy-datum.
*          vl_integ = p0000-begda - sy-datum  - vl_kwert.
*          IF vl_integ > '0.00'.
*            MESSAGE e024(zhr01).
**   La medida & se está creando más de & días en el pasado
*          ENDIF.
*       ELSEIF p0000-begda < sy-datum.
*      CALL FUNCTION 'ZCCHRMF026_CALC'
*        EXPORTING
*          fecha         = p0000-begda
*          hoy           = sy-datum
*          kwert         = vl_kwert
*        CHANGING
*          integ         = VL_INTEG.
*          IF vl_integ < 0.
*            MESSAGE e024(zhr01).
**   La medida & se está creando más de & días en el futuro
*          ENDIF.
*        ENDIF.

          IF vl_kwert IS INITIAL.
*       Medidas bloqueadas
            MESSAGE e024(zhr01).
          ELSEIF vl_kwert EQ '8888888.00'.
*       No validar nada y procesa sin validaciones
          ELSEIF vl_kwert EQ '9999999.00'.
             IF p0000-massn EQ 'Z6'.
               DAT_BAJ = P0000-BEGDA - 1.
               IF DAT_BAJ NE SY-DATUM.
                  MESSAGE e024(zhr01).
               ENDIF.
             ELSE.
                IF P0000-BEGDA NE SY-DATUM.
                  MESSAGE e024(zhr01).
                ENDIF.
             ENDIF.
          ELSE.
             CALL FUNCTION 'ROUND'
             EXPORTING
              DECIMALS = '0'
              input = vl_kwert
             IMPORTING
              OUTPUT = V_DIAS.
             IF V_DIAS GT 0.
               DAT_NEW = SY-DATUM + V_DIAS.
               IF p0000-massn EQ 'Z6'.
                 DAT_BAJ = P0000-BEGDA - 1.
                 IF DAT_BAJ NE DAT_NEW.
                  MESSAGE e024(zhr01).
                 ENDIF.
               ELSE.
                 IF P0000-BEGDA NE DAT_NEW.
                   MESSAGE e024(zhr01).
                 ENDIF.
               ENDIF.
             ELSEIF V_DIAS LT 0.
               V_DIAS = ABS( V_DIAS ).
               DAT_NEW = SY-DATUM - V_DIAS.
               IF p0000-massn EQ 'Z6'.
                  DAT_BAJ = P0000-BEGDA - 1.
                  IF DAT_BAJ NE DAT_NEW.
                    MESSAGE e024(zhr01).
                  ENDIF.
               ELSE.
                  IF P0000-BEGDA NE DAT_NEW.
                    MESSAGE e024(zhr01).
                  ENDIF.
               ENDIF.
             ENDIF.
          ENDIF.

      ENDIF.
ENDIF.

*----------------------------------------------------------*INI JPM 4081
" 13.07.2015 JPM Valida que tenga ITY 0713 por cada baja que tenga
DATA: it0000 TYPE STANDARD TABLE OF p0000,
      wa0000 TYPE p0000,
      it0713 TYPE STANDARD TABLE OF p0713,
      wa0713 TYPE p0713,
      vKONST TYPE ABRKN,
      vKWERT TYPE ABRWT.

  IF p0000-massn EQ 'Z2'. "solo se valida para reingreso
    CLEAR: vkonst,vkwert.                          " 20.07.2015 JPM 4081
    SELECT SINGLE konst kwert INTO (vkonst,vkwert) " 20.07.2015 JPM 4081
      FROM t511k                                   " 20.07.2015 JPM 4081
     WHERE molga = '32'                            " 20.07.2015 JPM 4081
       AND konst = 'REIFI'.                        " 20.07.2015 JPM 4081
    IF sy-subrc EQ 0 AND vkwert eq '0.00'.
      " si encuentra la constante y es igual de 0 no hace validacion.
    ELSE.                                          " 20.07.2015 JPM 4081
      CALL FUNCTION 'HR_READ_INFOTYPE'
        EXPORTING
          pernr           = p0000-pernr
          infty           = '0000'
        TABLES
          infty_tab       = it0000
        EXCEPTIONS
          infty_not_found = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION 'HR_READ_INFOTYPE'
        EXPORTING
          pernr           = p0000-pernr
          infty           = '0713'
        TABLES
          infty_tab       = it0713
        EXCEPTIONS
          infty_not_found = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
      ENDIF.
      SORT it0713 BY pernr begda.

      LOOP AT it0000 INTO wa0000 WHERE massn EQ 'Z6'.
        wa0000-begda = wa0000-begda - 1.

        READ TABLE it0713 INTO wa0713
                      WITH KEY pernr = wa0000-pernr
                               begda = wa0000-begda
                      BINARY SEARCH.
        IF sy-subrc NE 0.
          wa0000-begda = wa0000-begda + 1.
          MESSAGE e042(zhr01) WITH wa0000-pernr wa0000-begda.
*   El empleado & no contiene finiquito para el registro de baja dia &
        ENDIF.
      ENDLOOP.

    ENDIF.                                        " 20.07.2015 JPM 4081
  ENDIF.
*----------------------------------------------------------*FIN JPM 4081
*Ini.- CCV 13.05.2016 4765
  IF p0000-massn EQ 'Z3'.

    IF p0000-MASSG EQ 'O5' OR
       p0000-MASSG EQ 'O6'.
       vl_const = 'O'.
       V_OBJID = MK_PLANS.
       EXPORT V_OBJID TO MEMORY ID 'V_OBJID'.

       CALL FUNCTION 'RH_READ_INFTY_NNNN'""CCV 12.04.2016 4664
         EXPORTING
           PLVAR                 = '01'
           OTYPE                 = 'S'
           OBJID                 = V_OBJID
           INFTY                 = '1008'
           BEGDA                 = P0000-BEGDA
           ENDDA                 = P0000-endda
         TABLES
           INNNN                 = TL_1008
         EXCEPTIONS
           NOTHING_FOUND         = 1
           WRONG_CONDITION       = 2
           INFOTYP_NOT_SUPPORTED = 3
           WRONG_PARAMETERS      = 4
           OTHERS                = 5.

       IF SY-SUBRC EQ 0.
         READ TABLE TL_1008 INDEX 1.
       ENDIF.

       "JDDTS 17.07.2018 6298
       SELECT SINGLE * FROM HRP1013 INTO WA_HRP1013 WHERE OBJID EQ V_OBJID.
       PME03-MOLGA = '32'.
       PME03-PERSK = WA_HRP1013-PERSK.
       PME03-BUKRS = TL_1008-bukrs.
       CALL FUNCTION 'HR_FEATURE_BACKFIELD'
          EXPORTING
            FEATURE                     = 'ABKRS'
            STRUC_CONTENT               = PME03
            KIND_OF_ERROR               = SPACE
          IMPORTING
            BACK                        = MMDD
          EXCEPTIONS
            DUMMY                       = 1
            ERROR_OPERATION             = 2
            NO_BACKVALUE                = 3
            FEATURE_NOT_GENERATED       = 4
            INVALID_SIGN_IN_FUNID       = 5
            FIELD_IN_REPORT_TAB_IN_PE03 = 6
            OTHERS                      = 7.
       MOVE MMDD TO V_ABKRS.
       "JDDTS 17.07.2018 6298

       CALL FUNCTION 'ZCCHRMF002_LEE_T511K'
        EXPORTING
          i_konst            = vl_const
          i_datum            = p0000-begda
          I_BUKRS            = TL_1008-bukrs
          I_BAND             = 'X'
          I_ABKRS            = V_ABKRS "JDDTS 17.07.2018 6298
       IMPORTING
          E_KWERT            = vl_kwert
       CHANGING
          C_CONST            = vl_lecon
       EXCEPTIONS
         NO_HAY_DATOS       = 1
         OTHERS             = 2.
*       IF sy-subrc NE 0.
*         MESSAGE e004(zhr01) WITH 'Error al leer constante' vl_const TL_1008-bukrs p0000-begda.
**   Error al leer la constante & para la fecha &
*       ELSEif vl_kwert eq 0.
*         MESSAGE e024(zhr01).
*       ELSE.
*        IF p0000-begda > sy-datum.
*          vl_integ =  p0000-begda - sy-datum  - vl_kwert.
*          IF vl_integ > 0.
*            MESSAGE e024(zhr01).
**   La medida & se está creando más de & días en el pasado
*          ENDIF.
*        ELSEIF p0000-begda < sy-datum.
*      CALL FUNCTION 'ZCCHRMF026_CALC' "CCV 4765 18.05.2016
*        EXPORTING
*          fecha         = p0000-begda
*          hoy           = sy-datum
*          kwert         = vl_kwert
*        CHANGING
*          integ         = VL_INTEG.
*          IF vl_integ < 0.
*            MESSAGE e024(zhr01).
**   La medida & se está creando más de & días en el futuro
*          ENDIF.
*        endif.
*       endif.

      IF sy-subrc NE 0.
         MESSAGE e004(zhr01) WITH 'Error al leer constante' vl_const TL_1008-bukrs p0000-begda.
*   Error al leer la constante & para la fecha &
      ELSE.
        IF vl_kwert IS INITIAL.
*       Medidas bloqueadas
          MESSAGE e024(zhr01).
        ELSEIF vl_kwert EQ '8888888.00'.
*       No validar nada y procesa sin validaciones
        ELSEIF vl_kwert EQ '9999999.00'.
          IF P0000-BEGDA NE SY-DATUM.
            MESSAGE e024(zhr01).
          ENDIF.
        ELSE.
         CALL FUNCTION 'ROUND'
          EXPORTING
            DECIMALS = '0'
            input = vl_kwert
          IMPORTING
            OUTPUT = V_DIAS.
          IF V_DIAS GT 0.
             DAT_NEW = SY-DATUM + V_DIAS.
             IF P0000-BEGDA NE DAT_NEW.
              MESSAGE e024(zhr01).
             ENDIF.
          ELSEIF V_DIAS LT 0.
             V_DIAS = ABS( V_DIAS ).
             DAT_NEW = SY-DATUM - V_DIAS.
             IF P0000-BEGDA NE DAT_NEW.
              MESSAGE e024(zhr01).
             ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.
*Fin.- CCV 13.05.2016 4765
endif.

*------------------------------------------------------------*  JPM INI
* 19.06.2017 5633	MODIFICACION CAMPO PA41
  LOOP AT SCREEN.
    IF screen-name EQ 'P0000-BEGDA' AND SY-TCODE EQ 'PA41'.
        screen-input = off.
        MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*------------------------------------------------------------*  JPM FIN

*  IF p0000-massn EQ 'Z6'.
*
*    DATA: VL_DATUMCF TYPE DATUM.
*    VL_DATUMCF = P0000-BEGDA - 1.
*
** Modifica compras a futuro de Carnes Frias
*    CALL FUNCTION 'ZCCHRMF060_COMPRAS_FINI_CF'
*      EXPORTING
*        P_PERNR = p0000-pernr
*        P_DATUM = VL_DATUMCF.
*
*  ENDIF.


ENDENHANCEMENT.
