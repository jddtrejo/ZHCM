"Name: \PR:HMXCALC0\FO:DETERMINE_FIXED_SALARY\SE:END\EI
ENHANCEMENT 0 ZHRENH020_SALDIARIO.

" 03.03.2016 JLGF 4358 CAMBIO DE NOMINAS QUINCENALE A SEMANALES
*  Declara Variables
  DATA: el_wpbp    TYPE pc205,
        el_rt      TYPE pc207,
        el_intsal  LIKE LINE OF pt_intsal,
        vl_tabix   TYPE sy-tabix.
*------------------------------------------------------------*  JPM INI 4673
  " 01.06.2016 JPM 4673
 DATA:  lv_hire_date   TYPE p0001-begda,
        lt_entry_dates TYPE TABLE OF hida,
        lt_integra     TYPE STANDARD TABLE OF zrhes_factorintegra WITH HEADER LINE,
        factor         TYPE zrhes_factorintegra-fact_integra,
        wa0001         TYPE p0001.
  DATA: anios TYPE i.
   " 08.09.2016 JPM 4673 parametro para validar si se ejecuta el factor
   DATA: p_sdi_fact TYPE c.
   IMPORT p_sdi_fact FROM MEMORY ID 'ZSDI_FACT'.

  CALL FUNCTION 'HR_ENTRY_DATE'
    EXPORTING
      persnr               = p0001-pernr
    IMPORTING
      entrydate            = lv_hire_date
    TABLES
      entry_dates          = lt_entry_dates
    EXCEPTIONS
      entry_date_not_found = 1
      OTHERS               = 2.
  IF sy-subrc EQ 0.
    LOOP AT p0001 INTO wa0001
      WHERE begda le pn-begda
        AND endda gt pn-begda.
    ENDLOOP.
    IF wa0001 IS NOT INITIAL
      and p_sdi_fact IS NOT INITIAL. " 08.09.2016 JPM 4673
      CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
        EXPORTING
          begda    = lv_hire_date
*          endda    = sy-datum
          endda    = pn-endda " 17.08.2016 JPM 4673
        IMPORTING
          d_months = anios.
      factor = anios / 12.

      CALL FUNCTION 'ZHR_FACTOR_INTEGRA'
        EXPORTING
          i_bukrs   = wa0001-bukrs
          i_werks   = wa0001-werks
          i_type    = 'AGUI'
        TABLES
          t_integra = lt_integra.
      LOOP AT lt_integra.
        IF factor BETWEEN lt_integra-sebeg AND lt_integra-seend.
          MOVE lt_integra-fact_integra TO factor.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
*------------------------------------------------------------*  JPM FIN 4673
  LOOP AT pt_intsal INTO el_intsal .
    CLEAR el_wpbp.
    vl_tabix = sy-tabix.

    IF el_intsal-inrep NE 'B'.
      LOOP AT wpbp INTO el_wpbp
           WHERE begda LE el_intsal-begda
             AND endda GE el_intsal-begda.
      ENDLOOP.

*     Inicia Validación.
      IF el_wpbp-persk = '16' AND el_wpbp-stat2 NE '0'.
        IF el_intsal-sdia EQ 0.
          LOOP AT rt INTO el_rt
             WHERE lgart eq '/004'
               AND apznr EQ el_wpbp-apznr.
            MOVE el_rt-betpe TO el_intsal-sdifj.

            MODIFY pt_intsal FROM el_intsal INDEX vl_tabix.
          ENDLOOP.
        ENDIF.
        ELSEIF el_wpbp-stat2 NE '0'                       " 01.06.2016 JPM 4673
           AND sy-tcode eq 'ZHRTR142'                    " 08.09.2016 JPM 4673
           AND p_sdi_fact IS NOT INITIAL.                 " 08.09.2016 JPM 4673
          el_intsal-sdifj = el_intsal-sdia * factor.      " 01.06.2016 JPM 4673
          MODIFY pt_intsal FROM el_intsal INDEX vl_tabix. " 01.06.2016 JPM 4673
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDENHANCEMENT.
