"Name: \PR:MP000800\FO:CHECK_AMOUNT\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH008_BANSALUSRESP.
*  Monday, May 20, 2013 11:27:45 GC-DES-073
*--------------------------------------------------------------------*
DATA: lv_nombre TYPE  char40 VALUE 'ZMP000800_USR',
      lv_value  TYPE  char45,
      lv_subrc  TYPE  sy-subrc,
      R_RANGO   TYPE STANDARD TABLE OF TVARVC WITH HEADER LINE. " 16.06.2016 JPM 4852

DATA: lv_amount_min          LIKE p1005-cpmin,
      lv_amount_max          LIKE p1005-cpmax,
      lv_amount_to_check     LIKE p0008-ansal,
      lv_amount_min_str(20)  TYPE c,
      lv_amount_max_str      LIKE lv_amount_min_str,
      lv_amount_to_check_str LIKE lv_amount_min_str,
      lv_msgty               LIKE sy-msgty,
      lv_waers               LIKE p0008-waers,
      lv_plans               LIKE p1005-objid,
      lv_trfst               LIKE p1005-trfs1,
      lv_zeinh_out           LIKE t549r-zeinh,
*       l_pfreq LIKE t549r-zeinh,
      lv_hourly_out          TYPE t_xfeld,
      lv_t710a               LIKE t710a.            "erind = X -> E, sonst W-msg
DATA: lv_ptbindbw LIKE ptbindbw OCCURS 3 WITH HEADER LINE.
DATA: iv1005 LIKE p1005.
*
CHECK psyst-fstat <> fcode_az.
* IF T503-TRFKZ = '1' AND T503-ABART = '1'.                   "N0332799
IF t503-abart = '1'.                                        "N0332799
* Stundenloehner:
  lv_hourly_out = 'X'.
*   l_pfreq = q0008-zeinh.
  lv_waers = p0008-waers.
ELSE.
  lv_zeinh_out = q0008-zeinh.         "Zahlungsperiode
*   L_WAERS = P0008-ANCUR.                                    "N0425504
  IF NOT p0008-ancur IS INITIAL.                            "N0425504
    lv_waers = p0008-ancur.                                 "N0425504
  ELSE.                                                     "N0425504
    lv_waers = p0008-waers.                                 "N0425504
  ENDIF.                                                    "N0425504
ENDIF.
lv_plans = psyst-plans.
lv_trfst = p0008-trfst.
* Sollbezahlung pro Periode/Stunde berechnen:
CALL FUNCTION 'HR_SALARY_RANGE_FROM_P1005'
  EXPORTING
    p_molga                    = t001p-molga
    p_trfar                    = p0008-trfar
    p_trfgb                    = p0008-trfgb
    p_trfgr                    = p0008-trfgr
    p_trfst                    = lv_trfst
    p_cpind                    = p0008-cpind
    p_indda                    = p0008-begda
    p_ancur                    = lv_waers
    p_zeinh_out                = lv_zeinh_out "annual/none
    p_hourly_out               = lv_hourly_out
    p_divgv                    = p0008-divgv
    p_bsgrd                    = p0008-bsgrd           "K057585
    p_pfreq                    = q0008-zeinh
*   p_position                 = l_plans
*   p_job                      = psyst-stell
    p_pernr                    = p0008-pernr          "N0330864
  IMPORTING
    p_amt_min                  = lv_amount_min
    p_amt_max                  = lv_amount_max
    i_t710a                    = lv_t710a
    p_p1005                    = iv1005
  EXCEPTIONS
    comp_data_not_found        = 1
    currency_conversion_failed = 2
    timeunit_conversion_failed = 3
    OTHERS                     = 4.
* IF SY-SUBRC <> 0.                    "QNO 4.0C
IF sy-subrc <> 0 OR lv_t710a-erind IS INITIAL.              "K057585
  EXIT.
ENDIF.
* Periodengehalt berechnen:
* ... l_amount_to_check fuellen
LOOP AT tblgart WHERE lgart <> space.
  MOVE-CORRESPONDING tblgart TO lv_ptbindbw.
  APPEND lv_ptbindbw.
ENDLOOP.
CALL FUNCTION 'RP_PERIOD_AMOUNTS_ADD'
  EXPORTING
    p_bukrs          = psyst-bukrs                     "N0512340
    p_persa          = psyst-werks                     "N0512340
    p_btrtl          = psyst-btrtl                     "N0512340
    p_persk          = psyst-persk                     "N0512340
    p_persg          = psyst-persg                     "N0512340
    p_molga          = t001p-molga
    p_date           = p0008-begda
    p_subty          = p0008-subty                     "N0512340
    p_currency_in    = p0008-waers
    p_currency_out   = lv_waers
*   p_ansal_wagetype = 'CSAL' "Jahresgehaltslgart aus ANSAL "4.0C
    p_ansal_wagetype = lv_t710a-wgtyp                 "QNOK008851
  IMPORTING
    p_summe          = lv_amount_to_check
  TABLES
    p_wagetypes      = lv_ptbindbw
  EXCEPTIONS
    OTHERS           = 1.
CHECK sy-subrc = 0.
* L_AMOUNT_MIN = L_AMOUNT_MIN * P0008-BSGRD / 100.             "K057585
* L_AMOUNT_MAX = L_AMOUNT_MAX * P0008-BSGRD / 100.             "K057585
IF NOT lv_amount_to_check BETWEEN lv_amount_min AND lv_amount_max.
  WRITE: lv_amount_to_check TO lv_amount_to_check_str CURRENCY lv_waers,
         lv_amount_min TO lv_amount_min_str CURRENCY lv_waers,
         lv_amount_max TO lv_amount_max_str CURRENCY lv_waers.
  CONDENSE: lv_amount_to_check_str,
            lv_amount_min_str,
            lv_amount_max_str.
*   IF L_T710A-ERIND = 'X'.                                    "K057585
*     L_MSGTY = 'E'.                                           "K057585
*   ELSE.                                                      "K057585
*     L_MSGTY = 'W'.                                           "K057585
*   ENDIF.                                                     "K057585
  lv_msgty = lv_t710a-erind.                                "K057585
  IF lv_msgty = 'E' AND psyst-msgtp = 'S'.
    MESSAGE ID 'RP' TYPE 'S' NUMBER '360'
         WITH lv_amount_to_check_str
              lv_amount_min_str lv_amount_max_str
              lv_waers.                                     "N0425504
    psyst-nselc = no.
*--------------------------------------------------------------------*
*      Valida usuario parametrizado GC-DES-073
*--------------------------------------------------------------------*
    CALL FUNCTION 'ZCCHRMF003_TVARV'
      EXPORTING
        p_nombre = lv_nombre
      IMPORTING
        v_value  = lv_value
        subrc    = lv_subrc
*------------------------------------------------------------*  JPM INI 4852
       TABLES
         r_rango        = r_rango.
*    IF lv_subrc EQ 0 AND lv_value EQ sy-uname. "se comentariza validacion actual
    IF r_rango[] IS NOT INITIAL.
      lv_subrc = 1. "solo para bandera si encontro o no el usuario en TVARV
      LOOP AT r_rango.
        IF r_rango-low eq sy-uname.
          lv_subrc = 0.
        ENDIF.
      ENDLOOP.
      IF lv_subrc = 0.
        EXIT.
      ENDIF.
*------------------------------------------------------------*  JPM FIN 4852
    ENDIF.
*--------------------------------------------------------------------*
    LEAVE SCREEN.
  ELSE.
* Periodengehalt &1 ist nicht im Bereich (&2 - &3)
    MESSAGE ID 'RP' TYPE lv_msgty NUMBER '360'
         WITH lv_amount_to_check_str
              lv_amount_min_str lv_amount_max_str
              lv_waers.                                     "N0425504
  ENDIF.
ENDIF.
EXIT.
ENDENHANCEMENT.
