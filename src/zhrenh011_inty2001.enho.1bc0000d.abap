"Name: \PR:SAPLPT_GUI_SAP_TMW_TDE\FO:PAI_4000_LOOP\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH011_INTY2001.
data: vl_kwert type abrwt,
      l_value type char04,
      v_horas type tdduration,
      v_fin type abrwt,
      vl_integ type i,
      vl_const TYPE ABRKN, "CCV 26.04.2016 4664
      vl_lecon TYPE ABRKN. "CCV 26.04.2016 4664

DATA: it0000 TYPE STANDARD TABLE OF p0000,
      wa0000 TYPE p0000,
      tl_1008 TYPE TABLE OF p1008 WITH HEADER LINE,"CCV 12.04.2016 4664
      V_OBJID TYPE PLANS,"CCV 12.04.2016 4664
      it0001  TYPE STANDARD TABLE OF p0001, "CCV 26.04.2016 4664
      wa0001  TYPE p0001. "CCV 26.04.2016 4664

l_value = ptm_tde_1m-tdtype.
*break fgarza.
break sgarcia.
break sgarcia_abap.

"JDDTS 08.03.2017 5434
DATA: pi_namee   TYPE rvari_vnam VALUE 'ZCCHRCCNOMAUSENTISMOS',
      c_i(1)     VALUE 'I',
      it_tvarvc  TYPE STANDARD TABLE OF tvarvc,
      wa_tvarvc  TYPE tvarvc.
      "repid      VALUE IS INITIAL.

CALL FUNCTION 'ZSELECT_OPTIONS_TVARVC'
      EXPORTING
        "repid    = repid
        name     = pi_namee
      TABLES
        r_tvarvc = it_tvarvc.

DATA BAND TYPE C LENGTH 1 VALUE ''.
LOOP AT it_tvarvc INTO wa_tvarvc WHERE sign EQ c_i AND  ( low EQ l_value OR high EQ l_value ).
        BAND = 'X'.
ENDLOOP.

"JDDTS 08.03.2017 5434 Aqui empieza de nuevo la validacion que agrego CCV para continuar con el ciclo normal
IF BAND EQ ''.

  if ptm_tde_1m-activ is initial and ptm_tde_1m-alldf is initial and ptm_tde_1m-sprps is initial and ptm_tde_1m-tdduration is initial.

    if (   l_value eq '3208' or l_value eq '3210'
        or l_value eq '3211' or l_value eq '3212'
        or l_value eq '3200' or l_value eq '3202'
        or l_value eq '1002' or l_value eq '2100'
        or l_value eq '2102' or l_value eq '2104'
        or l_value eq '3204' or l_value eq '3214'
        or l_value eq '3216' or l_value eq '3216'
        or l_value eq '3218').
* BREAK FGARZA.

*      if sy-ucomm = 'BACK' OR SY-UCOMM = 'CANCEL'.
**        CLEAR: L_VALUE,
**               l_tde_tc-MAINDOM,
**               T001P.
*
*        EXIT.
*      ENDIF.

*      call function 'ZCCHRMF002_LEE_T511K'"CCV 26.04.2016 4664 quitar constantes fijas
*      exporting
*        i_konst      = 'ZDIAU'
*        i_datum      = g_tde_tc_1m-date
*      importing
*        e_kwert      = vl_kwert
*      exceptions
*        no_hay_datos = 1.

    CALL FUNCTION 'HR_READ_INFOTYPE' "CCV 26.04.2016 4664 quitar constantes fijas
      EXPORTING
        pernr           = g_tde_tc_1m-employee
        infty           = '0000'
        begda           = g_tde_tc_1m-date
        endda           = '99991231'
      TABLES
        infty_tab       =  it0000
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
    ENDIF.
    READ TABLE it0000 INTO wa0000 index 1.

    CALL FUNCTION 'HR_READ_INFOTYPE' "CCV 26.04.2016 4664 quitar constantes fijas
      EXPORTING
        pernr           = g_tde_tc_1m-employee
        infty           = '0001'
      TABLES
        infty_tab       = it0001
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
    ENDIF.
    LOOP AT it0001 INTO wa0001.
      IF wa0001-endda = '99991231'.
        v_objid = wa0001-plans.
      ENDIF.
    ENDLOOP.

     CALL FUNCTION 'RH_READ_INFTY_NNNN' ""CCV 12.04.2016 4664
      EXPORTING
        plvar                 = '01'
        otype                 = 'S'
        objid                 = v_objid
        infty                 = '1008'
        begda                 = g_tde_tc_1m-date
        endda                 = wa0000-endda
      TABLES
        innnn                 = tl_1008
      EXCEPTIONS
        nothing_found         = 1
        wrong_condition       = 2
        infotyp_not_supported = 3
        wrong_parameters      = 4
        OTHERS                = 5.

    IF sy-subrc EQ 0.
      READ TABLE tl_1008 INDEX 1.
    ENDIF.

    vl_const = 'U'.

    CALL FUNCTION 'ZCCHRMF002_LEE_T511K'
      EXPORTING
        i_konst      = vl_const
        i_datum      = g_tde_tc_1m-date
        i_bukrs      = tl_1008-bukrs
        i_band       = 'X'
      IMPORTING
        e_kwert      = vl_kwert
      CHANGING
        c_const      = vl_lecon
      EXCEPTIONS
        no_hay_datos = 1
        OTHERS       = 2.


    if sy-subrc ne 0.

*      message e009(zhr01) with 'ZDIAU' g_tde_tc_1m-date.
      MESSAGE e005(zhr01) WITH 'Error al leer constante "U", Sociedad' TL_1008-bukrs g_tde_tc_1m-date. "CCV 26.04.2016 4664
*   Error al leer la constante & para la fecha &

    else.
      vl_integ = g_tde_tc_1m-date - sy-datum + vl_kwert.

      if vl_integ lt 0.

        if ( sy-ucomm = 'BACK' or sy-ucomm = 'CANCEL' or sy-ucomm = 'EXIT' ).
*    message e001(00) with 'No se guardaran los cambios.'.
            leave program.
       else.
            clear ptm_tde_1m-tdtype.
            message i010(zhr01) with vl_kwert.
*   Ausentismo se est?? creando m??s de & d??as en el pasado. Contactar respons.
      endif.
     endif.
   endif.
 endif.

elseif ptm_tde_1m-sprps is initial and ptm_tde_1m-tdtype <> ptm_tde_1m-awart.

  if ( l_value eq '3208' or l_value eq '3210'
    or l_value eq '3211' or l_value eq '3212'
    or l_value eq '3200' or l_value eq '3202'
    or l_value eq '1002' or l_value eq '2100'
    or l_value eq '2102' or l_value eq '2104'
    or l_value eq '3204' or l_value eq '3214'
    or l_value eq '3216' or l_value eq '3216'
    or l_value eq '3218').
* BREAK FGARZA.

*      if sy-ucomm = 'BACK' OR SY-UCOMM = 'CANCEL'.
**        CLEAR: L_VALUE,
**               l_tde_tc-MAINDOM,
**               T001P.
*
*        EXIT.
*      ENDIF.
*BREAK CCORONA.

*      call function 'ZCCHRMF002_LEE_T511K'"CCV 26.04.2016 4664 quitar constantes fijas
*      exporting
*        i_konst      = 'ZDIAU'
*        i_datum      = g_tde_tc_n1-date
*      importing
*        e_kwert      = vl_kwert
*      exceptions
*        no_hay_datos = 1.
    CALL FUNCTION 'HR_READ_INFOTYPE' "CCV 26.04.2016 4664 quitar constantes fijas
      EXPORTING
        pernr           = g_tde_tc_1m-employee
        infty           = '0000'
        begda           = g_tde_tc_1m-date
        endda           = '99991231'
      TABLES
        infty_tab       =  it0000
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
    ENDIF.
    READ TABLE it0000 INTO wa0000 index 1.

    CALL FUNCTION 'HR_READ_INFOTYPE' "CCV 26.04.2016 4664 quitar constantes fijas
      EXPORTING
        pernr           = g_tde_tc_1m-employee
        infty           = '0001'
      TABLES
        infty_tab       = it0001
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
    ENDIF.
    LOOP AT it0001 INTO wa0001.
      IF wa0001-endda = '99991231'.
        v_objid = wa0001-plans.
      ENDIF.
    ENDLOOP.

     CALL FUNCTION 'RH_READ_INFTY_NNNN' ""CCV 12.04.2016 4664
      EXPORTING
        plvar                 = '01'
        otype                 = 'S'
        objid                 = v_objid
        infty                 = '1008'
        begda                 = g_tde_tc_1m-date
        endda                 = wa0000-endda
      TABLES
        innnn                 = tl_1008
      EXCEPTIONS
        nothing_found         = 1
        wrong_condition       = 2
        infotyp_not_supported = 3
        wrong_parameters      = 4
        OTHERS                = 5.

    IF sy-subrc EQ 0.
      READ TABLE tl_1008 INDEX 1.
    ENDIF.

    vl_const = 'U'.

    CALL FUNCTION 'ZCCHRMF002_LEE_T511K'
      EXPORTING
        i_konst      = vl_const
        i_datum      = g_tde_tc_1m-date
        i_bukrs      = tl_1008-bukrs
        i_band       = 'X'
      IMPORTING
        e_kwert      = vl_kwert
      CHANGING
        c_const      = vl_lecon
      EXCEPTIONS
        no_hay_datos = 1
        OTHERS       = 2.

    if sy-subrc ne 0.

*      message e009(zhr01) with 'ZDIAU' g_tde_tc_1m-date."CCV 26.04.2016 4664
*   Error al leer la constante & para la fecha &
   MESSAGE e005(zhr01) WITH 'Error al leer constante "U", Sociedad' TL_1008-bukrs g_tde_tc_1m-date. "CCV 26.04.2016 4664
    else.

      vl_integ = g_tde_tc_1m-date - sy-datum + vl_kwert.

      if vl_integ lt 0.

          if ( sy-ucomm = 'BACK' or sy-ucomm = 'CANCEL' or sy-ucomm = 'EXIT' ).
*    message e001(00) with 'No se guardaran los cambios.'.
              leave program.
           else.
             ptm_tde_1m-tdtype = ptm_tde_1m-awart.
             message i010(zhr01) with vl_kwert.
*   Ausentismo se est?? creando m??s de & d??as en el pasado. Contactar respons.
          endif.
      endif.
   endif.
 endif.

elseif ptm_tde_1m-activ is initial and ptm_tde_1m-sprps is initial and ptm_tde_1m-tdduration is not initial.

  if (  l_value eq '2102' or l_value eq '2104').


*    v_horas = PTM_TDE_N1-enduz(2) - PTM_TDE_N1-beguz(2).

    if sy-ucomm = 'PICK'.

*      call function 'ZCCHRMF002_LEE_T511K' "CCV 26.04.2016 4664 quitar constantes fijas
*      exporting
*        i_konst      = 'ZDIAU'
*        i_datum      = g_tde_tc_1m-date
*      importing
*        e_kwert      = vl_kwert
*      exceptions
*        no_hay_datos = 1.
    CALL FUNCTION 'HR_READ_INFOTYPE' "CCV 26.04.2016 4664 quitar constantes fijas
      EXPORTING
        pernr           = g_tde_tc_1m-employee
        infty           = '0000'
        begda           = g_tde_tc_1m-date
        endda           = '99991231'
      TABLES
        infty_tab       =  it0000
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
    ENDIF.
    READ TABLE it0000 INTO wa0000 index 1.

    CALL FUNCTION 'HR_READ_INFOTYPE' "CCV 26.04.2016 4664 quitar constantes fijas
      EXPORTING
        pernr           = g_tde_tc_1m-employee
        infty           = '0001'
      TABLES
        infty_tab       = it0001
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
    ENDIF.
    LOOP AT it0001 INTO wa0001.
      IF wa0001-endda = '99991231'.
        v_objid = wa0001-plans.
      ENDIF.
    ENDLOOP.

     CALL FUNCTION 'RH_READ_INFTY_NNNN' ""CCV 12.04.2016 4664
      EXPORTING
        plvar                 = '01'
        otype                 = 'S'
        objid                 = v_objid
        infty                 = '1008'
        begda                 = g_tde_tc_1m-date
        endda                 = wa0000-endda
      TABLES
        innnn                 = tl_1008
      EXCEPTIONS
        nothing_found         = 1
        wrong_condition       = 2
        infotyp_not_supported = 3
        wrong_parameters      = 4
        OTHERS                = 5.

    IF sy-subrc EQ 0.
      READ TABLE tl_1008 INDEX 1.
    ENDIF.

    vl_const = 'U'.

    CALL FUNCTION 'ZCCHRMF002_LEE_T511K'
      EXPORTING
        i_konst      = vl_const
        i_datum      = g_tde_tc_1m-date
        i_bukrs      = tl_1008-bukrs
        i_band       = 'X'
      IMPORTING
        e_kwert      = vl_kwert
      CHANGING
        c_const      = vl_lecon
      EXCEPTIONS
        no_hay_datos = 1
        OTHERS       = 2.

    if sy-subrc ne 0.

*      message e009(zhr01) with 'ZDIAU' g_tde_tc_1m-date.
*   Error al leer la constante & para la fecha &
    MESSAGE e005(zhr01) WITH 'Error al leer constante "U", Sociedad' TL_1008-bukrs g_tde_tc_1m-date. "CCV 26.04.2016 4664

    else.

      vl_integ = g_tde_tc_1m-date - sy-datum + vl_kwert.

      if vl_integ lt 0.

  if ( sy-ucomm = 'BACK' or sy-ucomm = 'CANCEL' or sy-ucomm = 'EXIT' ).
*    message e001(00) with 'No se guardaran los cambios.'.
     leave program.
    else.
*        PTM_TDE_N1-tdtype = PTM_TDE_N1-awart.
*        message i010(zhr01) with vl_kwert.
    free memory id 'HORAS'.
    v_horas = ptm_tde_1m-tdduration.
    export horas from v_horas to memory id 'HORAS'.
        free memory id 'FIN'.
    v_fin = vl_kwert.
    export fin from v_fin to memory id 'FIN'.
*   Ausentismo se est?? creando m??s de & d??as en el pasado. Contactar respons.
      endif.
     endif.
    endif.
    endif.
    endif.
    endif.

ENDIF.
"JDDTS 08.03.2017 5434

ENDENHANCEMENT.
