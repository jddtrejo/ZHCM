"Name: \PR:HMXCALC0\FO:TIPO_SAL\SE:END\EI
ENHANCEMENT 0 ZHRENH029_PCMPRMX0_PROV.
*
  DATA: wa_smartdata TYPE zrhes_lista_smartforms,
        it_0008      TYPE STANDARD TABLE OF p0008,
        wa_0008      TYPE p0008,
        VL_BET01     TYPE PAD_AMT7S,
        vcsdoxhr     TYPE lgart VALUE '9101',
        vsubrc       TYPE sysubrc.
  check pernr-BUKRS EQ 'BTK2' AND p_salario is initial.
  CLEAR: wa_0008, it_0008[],VL_BET01.

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr           = pernr-pernr
      infty           = '0008'
      begda           = sy-datum
      endda           = sy-datum
    IMPORTING
      subrc           = vsubrc
    TABLES
      infty_tab       = it_0008
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.

  DELETE it_0008 WHERE endda NE '99991231'.
  LOOP AT it_0008 INTO wa_0008. ENDLOOP.

  IF wa_0008-bet01 IS NOT INITIAL OR wa_0008-bet01 NE '0.00'.
    check wa_0008-LGA01 eq vcsdoxhr.
    MOVE wa_0008-bet01 TO wa_smartdata-s_diario.
  ELSE.
   SELECT BETRG INTO VL_BET01
    FROM T510
   WHERE MOLGA EQ '32'
    AND  TRFAR EQ wa_0008-TRFAR
    AND  TRFGB EQ wa_0008-TRFGB
    AND  TRFGR EQ wa_0008-TRFGR
    AND  LGART EQ vcsdoxhr "concepto de sueldo para pagos por hora
    AND  BEGDA EQ WA_0008-BEGDA.
   ENDSELECT.
  IF VL_BET01 IS NOT INITIAL OR VL_BET01 NE '0.00'.
    MOVE VL_BET01 TO wa_smartdata-s_diario.
  ELSE.
    CALL FUNCTION 'ZBAPI_BASICPAY'
      EXPORTING
        i_pernr      = pernr-pernr
        i_begda      = sy-datum
        i_endda      = '99991231'
        i_record     = 'X'
      IMPORTING
        e_mensual    = wa_smartdata-s_mensual
        e_diario     = wa_smartdata-s_diario
        e_anexo_vol  = wa_smartdata-j_anexo_vol
        e_anexo_dias = wa_smartdata-j_anexo_dias
        e_anexo_conc = wa_smartdata-j_anexo_conc
        e_jorntext   = wa_smartdata-j_jorntext
      CHANGING
        c_jorn       = wa_smartdata-em_jorn.
    ENDIF.
  ENDIF.

  if pernr-abkrs EQ '25'.
    wa_smartdata-s_diario = wa_smartdata-s_diario * 8. "EL IMPORTE VIENE POR HORA, MULTIPLICAR PARA OBTENER DIARIO
  endif.
  MOVE wa_smartdata-s_diario TO p_salario.


ENDENHANCEMENT.
