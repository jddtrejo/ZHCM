"Name: \PR:MP000100\FO:CHECK_COSTCENTER\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_MESS_KI_100_ITY0001.
* 19.08.2016 JPM 4971 implementacion para mensaje KI 100 Marcar como WARNING solo para
* 19.08.2016 JPM 4971 sociedad configurada en TVARV parametro ZHCMCONSTANTE_MESSEGEKI100

  data: ls_cobl like cobl_ex.
  field-symbols: <fs_budget_period> type fm_budget_period.
  field-symbols  <lv_budget_period1> type fm_budget_period.

  data: begin of ls_cobl_messages occurs 0.
          include structure bapireturn1.
  data: end of ls_cobl_messages.

  data: lv_subrc like sy-subrc. "STRO FUND ACCOUNTING

  data: lv_segment_active type flag.
  data: lv_segment_start_date type sy-datum.
  data: lt_return1 like bapiret2 occurs 0 with header line.

* check not p0001-kostl is initial.                  (del) QICPH9K008033

* if p0001-kostl is initial.            "(del)QICN0364870 "QICPH9K008033
*   if not ( p0001-fistl is initial     "(del)QICN0364870 "QICPH9K008033
*        and p0001-geber is initial ).  "(del)QICN0364870 "QICPH9K008033
*     message E755.                     "(del)QICN0364870 "QICPH9K008033
*   endif.                              "(del)QICN0364870 "QICPH9K008033
* else.                                 "(del)QICN0364870 "QICPH9K008033

* Check switch HRPSM_SFWS_SC_BUDPER_01
  call method cl_hrpsm_switch_check=>hrpsm_sfws_ui_budper_01
    receiving
      rv_active = gv_active_budget_pd_switch.
  if gv_active_budget_pd_switch is initial.
    clear p0001-budget_pd.
  endif.
* move-corresponding p0001 to ls_cobl.
  assign component 'BUDGET_PD' of structure ls_cobl to <lv_budget_period1>.
  if sy-subrc = 0.
    <lv_budget_period1> = p0001-budget_pd.
  endif.
*
  ls_cobl-kokrs = p0001-kokrs.
  ls_cobl-bukrs = p0001-bukrs.
  ls_cobl-kostl = p0001-kostl.
  ls_cobl-fistl = p0001-fistl.
  ls_cobl-geber = p0001-geber.
  ls_cobl-fkber = p0001-fkber.           "STRO FUNDS ACCOUNTING
  ls_cobl-grant_nbr = p0001-grant_nbr.   "STRO FUNDS ACCOUNTING
  ls_cobl-segment = p0001-sgmnt.
  ls_cobl-gsber = p0001-gsber.
  ls_cobl-budat = p0001-begda.
  ls_cobl-vorgn = 'HRBV'.
  ls_cobl-glvor = 'RFBU'.

*   check all fields in structure COBL
  call function 'HRCA_COBL_CHECK'
    exporting
      i_cobl        = ls_cobl
    importing
      e_cobl        = ls_cobl
    tables
      cobl_messages = ls_cobl_messages
    exceptions
      others        = 1.
  lv_subrc = sy-subrc.   "STRO FUND Accounting
* Do extended FM checks    STRO FUND Accounting
  call function 'RH_PM_COBL_CHECK_FPM'
    exporting
      i_date                = ls_cobl-budat
      i_cobl                = ls_cobl
      active_dimensions_tab = fm_act_dim_tab
    importing
      e_cobl                = ls_cobl
    tables
      cobl_messages_tab     = ls_cobl_messages.


  if lv_subrc eq 0.                    "STRO FUND Accounting
    p0001-kokrs = ls_cobl-kokrs.        "XFYAHRK010872
    p0001-gsber = ls_cobl-gsber.

    if ls_cobl-segment is initial.
      call function 'HRCA_GET_ACTIVE_DIMENSIONS'
        exporting
          i_company_code             = p0001-bukrs
       importing
         e_sgmnt_active             = lv_segment_active
         e_sgmnt_start_hr           = lv_segment_start_date
*       E_FM_ACTIVE                =
        tables
          return_table               = lt_return1
        exceptions
          error_occured              = 1
          others                     = 2.

      if sy-subrc = 0.
        if p0001-begda >= lv_segment_start_date and not lv_segment_active is initial.
          if p0001-sgmnt is initial and ls_cobl-segment is initial.
            message w718.
* Es konnte kein Segment abgeleitet werden
          endif.
        endif.
      endif.
    endif.
  endif.                               "XFYAHRK010872
*------------------------------------------------------------*  JPM INI 4971
    DATA: lt_tvarv TYPE STANDARD TABLE OF TVARVC WITH HEADER LINE.
    CALL FUNCTION 'ZSELECT_OPTIONS_TVARVC'
      EXPORTING
        NAME             = 'ZHCMCONSTANTE_MESSEGEKI100'
      TABLES
        R_TVARVC         = lt_tvarv
     EXCEPTIONS
       NO_VARIANT       = 1
       OTHERS           = 2.

    READ TABLE lt_tvarv INDEX 1.

    LOOP AT ls_cobl_messages. " 18.08.2016 JPM 4971
      IF LS_COBL_MESSAGES-MESSAGE_V4 eq lt_tvarv-low
        or LS_COBL_MESSAGES-MESSAGE_V2 eq lt_tvarv-low.
        CASE LS_COBL_MESSAGES-ID.
          WHEN 'KI'.
            IF LS_COBL_MESSAGES-NUMBER eq '100'.
             move 'W' to lS_cobl_messages-type.
             MODIFY ls_cobl_messages.
            ENDIF.
          WHEN 'KM'.
            IF LS_COBL_MESSAGES-NUMBER eq '183'.
              move 'W' to lS_cobl_messages-type.
              MODIFY ls_cobl_messages.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

*------------------------------------------------------------*  JPM FIN 4971
  loop at ls_cobl_messages.
    if p0001-kostl is initial                           "QICN0364870
       and ls_cobl_messages-id eq 'KI'                   "QICN0364870
       and ls_cobl_messages-type eq 'E'                  "QICN0364870
       and ls_cobl_messages-number eq '178'.             "QICN0364870
      continue.                                         "QICN0364870
    endif.                                              "QICN0364870
    message id     ls_cobl_messages-id
            type   ls_cobl_messages-type
            number ls_cobl_messages-number
            with   ls_cobl_messages-message_v1
                   ls_cobl_messages-message_v2
                   ls_cobl_messages-message_v3
                   ls_cobl_messages-message_v4.
*     exit.                            (del)QICN0364870 "QICPH9K008033
  endloop.
* endif.                               (del)QICN0364870 "QICPH9K008033

* STRO FUNDS ACCOUNTING
* Take over PS fields from CO-PA Tool if these fields are
* not maintained in P0001 and if they are active in PS

  if not fm_act_dim-function_active is initial
     and p0001-fkber is initial.
    p0001-fkber = ls_cobl-fkber.
  endif.
  if not fm_act_dim-fund_active is initial
     and p0001-geber is initial.
    p0001-geber = ls_cobl-geber.
  endif.
  if not fm_act_dim-budget_pd_active is initial
     and p0001-budget_pd is initial.
    assign component 'BUDGET_PD' of structure ls_cobl to <fs_budget_period>.
    if sy-subrc = 0.
      p0001-budget_pd = <fs_budget_period>.
    endif.
  endif.
  if not fm_act_dim-grant_active is initial
     and p0001-grant_nbr is initial.
    p0001-grant_nbr = ls_cobl-grant_nbr.
  endif.
  if not fm_act_dim-funds_ctr_active is initial
     and p0001-fistl is initial.
    p0001-fistl = ls_cobl-fistl.
  endif.
  Exit.
ENDENHANCEMENT.
