"Name: \PR:HMXCALC0\IC:RPCHRT09_MAIN\SE:END\EI
ENHANCEMENT 0 ZHRENH021_GUARDASDI.
FORM procesa_sdi.

*  DATA: wa_sdi TYPE pc2qz,       " Base IMSS
  DATA: wa_sdi TYPE pmx01,       " Base IMSS
        vsumbb TYPE sumbb.
  DATA: lt_2001  TYPE STANDARD TABLE OF p2001,
        ls_2001  TYPE p2001,
        vl_massn TYPE massn,
        vindex TYPE SY-TABIX.

  CLEAR: wa_sdi, ls_sdi, vindex.
  " obtiene el ultimo registro de SDI
*  LOOP AT sdi INTO wa_sdi WHERE sdifj GT 0. ENDLOOP.

   " 08.09.2016 JPM 4673 parametro para validar si se ejecuta el factor
   DATA: p_sdi_fact TYPE c.
   IMPORT p_sdi_fact FROM MEMORY ID 'ZSDI_FACT'.



  LOOP AT intsal_per_pernr INTO wa_sdi WHERE sdifj GT 0 "12.05.2017 JLGF 4767
                                         AND begda LE pn-endda
                                         AND begda GE pn-begda.
    vindex = SY-TABIX.
  ENDLOOP.

  IF vindex IS INITIAL.
    LOOP AT intsal_per_pernr INTO wa_sdi WHERE sdifj GT 0.
      vindex = SY-TABIX.
    ENDLOOP.
  ENDIF.

  MOVE-CORRESPONDING wa_sdi TO ls_sdi.
  MOVE: pernr-pernr TO ls_sdi-pernr,
        pernr-werks TO ls_sdi-werks,
        pernr-bukrs TO ls_sdi-bukrs,
        pernr-btrtl TO ls_sdi-btrtl,
        pernr-ename TO ls_sdi-ename,
        sy-datum    TO ls_sdi-aedat.
  "registro patronal
  SELECT SINGLE repat FROM t7mx0p
  INTO ls_sdi-repat
  WHERE werks = ls_sdi-werks
  AND   btrtl = ls_sdi-btrtl.

  SELECT massn "27.07.2015 JLGF - Obtener Ultima Medida
    FROM pa0000
    INTO vl_massn
    WHERE pernr = pernr-pernr
      AND begda <= pn-endda
      AND endda >= pn-endda.
  ENDSELECT.

  "Salario diario
  CALL FUNCTION 'HR_GET_TOTAL_AMOUNT_P0008'
    EXPORTING
      pernr  = pernr-pernr
      date   = pn-endda
*     P0008  = p0008
    IMPORTING
      amount = vsumbb.
  IF sy-subrc <> 0.
  ENDIF.

  ls_sdi-emolb = vsumbb.
  ls_sdi-stats = 2. "Pendiente


  IF vindex GT 0.
    IF vl_massn NE 'Z6'. "27.07.2015 JLGF
      ls_sdi-sdia = vsumbb / 15.
      "factor de integración
      IF ls_sdi-sdia NE 0.
*        ls_sdi-facint = ls_sdi-sdifj / ls_sdi-sdia.
*  ------------------------------------------------------------*  JPM INI 4767
        DATA:  p_antig       TYPE  senio,
               p_factintegra TYPE  bapiamtbase,
               p_flag        TYPE  c.
        IF p_sdi_fact IS NOT INITIAL. " 08.09.2016 JPM 4673
          CALL FUNCTION 'ZHR_CALCULA_FACTOR'
            EXPORTING
              i_datum       = pn-begda
              i_dat01       = p0041-dat01
              i_bukrs       = pernr-bukrs
              i_werks       = pernr-werks
            IMPORTING
              e_antig       = p_antig
              e_factintegra = p_factintegra
              e_flag        = p_flag.
        ENDIF.

        IF p_factintegra IS NOT INITIAL.
          MOVE p_factintegra TO ls_sdi-facint.
        ELSE.
          ls_sdi-facint = ls_sdi-sdifj / ls_sdi-sdia.
        ENDIF.
        ls_sdi-sdifj = ls_sdi-sdia * ls_sdi-facint.
        ls_sdi-sdimx = ls_sdi-sdifj + ls_sdi-SDIVR.
*  ------------------------------------------------------------*  JPM FIN 4767

      ELSE.
        ls_sdi-facint = 0.
      ENDIF.
    ENDIF.
  ELSE.
    "15.05.2017 JLGF 4767 - INI
    LOOP AT intsal_per_pernr INTO wa_sdi WHERE begda LE pn-endda
                                           AND begda GE pn-begda.
      vindex = SY-TABIX.
    ENDLOOP.

    IF vindex IS INITIAL.
      LOOP AT intsal_per_pernr INTO wa_sdi. ENDLOOP.
    ENDIF.

    CLEAR vindex.
    MOVE: wa_sdi-sdia to ls_sdi-sdia,
          wa_sdi-sdifj to ls_sdi-sdifj,
          wa_sdi-sdivr to ls_sdi-sdivr,
          wa_sdi-sdimx to ls_sdi-sdimx.
    "15.05.2017 JLGF 4767 - FIN
  ENDIF.

  "dias del bimestre
  PERFORM obten_dias USING pn-endda CHANGING ls_sdi-dbim.

  DATA: vl_pabrp TYPE pnppabrp,
        vl_pabrj TYPE pnppabrj.

  CALL FUNCTION 'ZCCHRMF021_PERIODO'
   EXPORTING
     IPERNR        = pernr-pernr
     I_BEGDA       = pn-endda
   IMPORTING
     E_PERI        = vl_pabrp
     E_EJER        = vl_pabrj
     E_ABKRS       = ls_sdi-abkrs .

  CONCATENATE vl_pabrj vl_pabrp INTO ls_sdi-fpper. "10.05.2017 JLGF 4767

  " dias de ausentismos e incapacidades

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr     = pernr-pernr
      infty     = '2001'
      begda     = pn-begda
      endda     = pn-endda
    TABLES
      infty_tab = lt_2001.

  LOOP AT lt_2001 INTO ls_2001.
    CASE ls_2001-subty.
      WHEN '3200' OR '3202' OR '3204' OR '3218'.
        "dias de ausentismo
        ADD 1 TO ls_sdi-daus.
      WHEN '3208' OR '3210' OR '3211' OR '3212'.
        "dias de incapacidad
        ADD 1 TO ls_sdi-dinc.
    ENDCASE.
  ENDLOOP.
  "dias base cotizacion
  ls_sdi-dbase = ls_sdi-dbim - ls_sdi-daus - ls_sdi-dinc.
*------------------------------------------------------------*  JPM INI 4767
  IF vindex NE 0.
    MOVE-CORRESPONDING ls_sdi to wa_sdi.
    MODIFY intsal_per_pernr INDEX vindex from wa_sdi.
  ENDIF.
*------------------------------------------------------------*  JPM FIN 4767
  APPEND ls_sdi TO lt_sdi.
ENDFORM.                    "procesa_sdi

*&---------------------------------------------------------------------*
*&      Form  obten_dias
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FECHA    text
*      -->P_BIM      text
*----------------------------------------------------------------------*
FORM obten_dias USING p_fecha CHANGING p_bim.
  DATA: vdia(2) TYPE n,
        vmes(2) TYPE n.
  DATA: vdias TYPE p DECIMALS 0,
        fec1 TYPE sydatum,
        fec2 TYPE sydatum.

  vmes = p_fecha+4(2) / 2.
  vmes = ( vmes * 2 ) - 1. "para obtener el primer mes del bimestre

  CONCATENATE p_fecha(4) vmes '01' INTO fec1. "primer dia del bimestre
  CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH' "dias del primer mes
    EXPORTING
      p_fecha        = fec1
    IMPORTING
      number_of_days = vdias.
  vdia = vdias.
  fec2 = fec1.
  fec2+4(2) = fec2+4(2) + 1. "primer dia del segundo mes del bimestre
  CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH' "dias del segundo mes
    EXPORTING
      p_fecha        = fec2
    IMPORTING
      number_of_days = vdias.

  p_bim = vdia + vdias. "suma para obtener los dias totales del bimestre

ENDFORM.                    " F_OBTEN_FECHAS

ENDENHANCEMENT.
