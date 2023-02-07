"Name: \PR:RPITRF00\FO:FILL_DL_IL\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH016_DISNOM.
data: wa_p0008 type p0008,
      wa_ant type p0008,
      vl_begda type bdcdata-fval,
      vl_bet01 type bdcdata-fval,
      vl_subty type bdcdata-fval,
      vl_plans type bdcdata-fval,
      vl_massg type bdcdata-fval,
      vl_pernr type bdcdata-fval,
      vl_werks type bdcdata-fval,
      vl_persg type bdcdata-fval,
      vl_persk type bdcdata-fval,
      vl_TRFAR type bdcdata-fval,
      vl_TRFgb type bdcdata-fval,
      vl_TRFGR type bdcdata-fval,
      vl_TRFST type bdcdata-fval,
      VL_SUBRC like SYST-SUBRC,
      tl_ant type standard table of p0008,
      wa_p0000 type p0000,
      tl_p0000 type standard table of p0000,
      wa_p0001 type p0001,
      tl_p0001 type standard table of p0001,
      v_por type string,
      vl_anio type datum,
      vl_anio2 type datum,
      vl_fecha type datum,
      messtab type standard table of bdcmsgcoll,
      return_struct type bapireturn1,
      personaldatakey type bapipakey,
      el_return  type bapireturn1,
      el_return2  type bapiret2,
       rutyp like t511-rutyp,
       rudiv like t511-rudiv,
       v_valor like p0014-betrg,
       factor like p0014-betrg,
       V_FLAG TYPE CHAR1.

*if v_batch = 'X'.

if 'S' in CPIND.
  CLEAR: v_flag.
  move-corresponding p0008 to wa_p0008.

* vl_anio = wa_p0008-begda(4).
 vl_anio2 = wa_p0008-begda.

 if vl_anio2 < t_DATUm.

*vl_anio2 = vl_anio2 - 1.
*concatenate vl_anio2 HILFS_DATUM+4(4) into wa_p0008-begda.

 call function 'HR_READ_INFOTYPE'
    exporting
      pernr           = wa_p0008-pernr
      infty           = '0008'
      begda           = wa_p0008-begda
      endda           = wa_p0008-endda
    tables
      infty_tab       = tl_ant
    exceptions
      infty_not_found = 1
      others          = 2.
  if sy-subrc eq 0.
    read table tl_ant into wa_ant index 1.
    if sy-subrc eq 0.

  if p0008-bet01 > wa_ant-bet01.
    p0008-bet01 = wa_ant-bet01.
  endif.

  v_valor = wa_ant-bet01 * mehrproz.
  v_valor = v_valor /  100000.
  wa_p0008-bet01 = wa_ant-bet01 + v_valor.
*  wa_p0008-begda = HILFS_DATUM.
  wa_p0008-begda = t_datum.
  wa_p0008-AEDTM = sy-datum.
  v_aumento = WA_P0008-BET01.



   call function 'HR_READ_INFOTYPE'
    exporting
      pernr           = wa_p0008-pernr
      infty           = '0000'
      begda           = vl_anio2
      endda           = wa_p0008-endda
    tables
      infty_tab       = tl_p0000
    exceptions
      infty_not_found = 1
      others          = 2.
  if sy-subrc eq 0.
    read table tl_p0000 into wa_p0000 index 1.
    if sy-subrc eq 0.

    call function 'HR_READ_INFOTYPE'
    exporting
      pernr           = wa_p0008-pernr
      infty           = '0001'
      begda           = wa_p0000-begda
      endda           = wa_p0008-endda
    tables
      infty_tab       = tl_p0001
    exceptions
      infty_not_found = 1
      others          = 2.
  if sy-subrc eq 0.
    read table tl_p0001 into wa_p0001 index 1.
    if sy-subrc eq 0.

*********Redondeo************
  IF RUDIF IS NOT INITIAL.
  RUDIV = RUDIF ."* 100.
    if rutyp_d eq 'X'.
    rutyp = 'A'.
  elseif rutyp_du eq 'X'.
    rutyp = 'B'.
  elseif rutyp_u eq 'X'.
    rutyp = 'C'.
  endif.

  factor = WA_P0008-BET01 / rudiv.                                    "N0790906
  multiply factor by rudiv.
* FACTOR is now rounded to nearest
  case rutyp.
    when 'A'.                          "rounding down
      if factor gt WA_P0008-BET01.
        subtract rudif from factor.
      endif.
    when 'B'.                          "already rounded nearest
    when 'C'.                          "rounding up
      if factor lt WA_P0008-BET01.
        add rudif to factor.
      endif.
  endcase.
  move factor to WA_P0008-BET01.

endif.

v_aumento = WA_P0008-BET01.
wa_p0008-seqnr = wa_p0008-seqnr + 1.
*  PERFORM RUNDUNG CHANGING WA_P0008-BET01.

*                           "RUNDUNG

*  call function 'BAPI_EMPLOYEE_ENQUEUE'
*      exporting
*        number = wa_p0008-pernr
*      importing
*        return = el_return.

*  move-corresponding wa_p0008 to wa_p0000.

*  move TRFMASSN(2) to wa_p0000-MASSN.
  wa_p0000-begda = t_datum.
  move TRFMASSN(2) to wa_p0000-subty.
  move trfmassn+2(2) to wa_p0000-massg.

move: wa_p0008-pernr to vl_pernr,
*      wa_p0008-begda to vl_begda,
      wa_p0000-subty to vl_subty,
      wa_p0000-massg to vl_massg,
      wa_p0001-plans to vl_plans,
      wa_p0001-werks to vl_werks,
      wa_p0001-persg to vl_persg,
      wa_p0001-persk to vl_persk,
      wa_p0008-TRFAR to vl_TRFAR,
      wa_p0008-TRFgb to vl_TRFgb,
      wa_p0008-TRFGR to vl_TRFGR,
      wa_p0008-TRFST to vl_TRFST,
      wa_p0008-bet01 to vl_bet01.

CONDENSE VL_BET01 NO-GAPS.

CONCATENATE wa_p0008-begda+6(2) wa_p0008-begda+4(2) wa_p0008-begda(4)
            INTO VL_BEGDA SEPARATED BY '.'.

V_FLAG = 'X'. "27.08.2013 17:06:26 & JPM Indica si procesa ITY 0008
**                call function 'BAPI_EMPLOYEE_DEQUEUE'
**                exporting
**                  number = wa_P0000-pernr
**                importing
**                  return = el_return.
**
**CALL FUNCTION 'ZCCHRMF024_0000'

** EXPORTING
**   CTU                = 'X'
**   MODE               = 'N'
**   UPDATE             = 'L'
***   GROUP              =
***   USER               =
***   KEEP               =
***   HOLDDATE           =
***   NODATA             = '/'
**   PERNR_001          = vl_pernr
**   TIMR6_002          = 'X'
**   BEGDA_003          = vl_begda
**   CHOIC_004          = '0000'
**   SUBTY_005          = vl_subty
**   BEGDA_006          = vl_begda
**   MASSG_007          = vl_massg
**   PLANS_008          = vl_plans
**   WERKS_009          = vl_werks
**   PERSG_010          = vl_persg
**   PERSK_011          = vl_persk
**   BEGDA_012          = vl_begda
**   ENDDA_013          = '31.12.9999'
**   TRFAR_014          = vl_TRFAR
**   TRFGB_015          = vl_TRFGB
**   IBBEG_016          = vl_begda
**   WAERS_017          = 'MXN'
**   BETRG_01_018       = vl_bet01
** IMPORTING
**   SUBRC              = vl_subrc
** TABLES
**   MESSTAB            = MESSTAB
**          .
**
**            .
**            if  vL_subrc eq 0.
**            call function 'BAPI_TRANSACTION_COMMIT'
**                importing
**                  return = el_return2.
**            commit work and wait.
**
**            call function 'HR_PSBUFFER_INITIALIZE'.
**
**          endif.

*         Bloqueo del empleado
*            call function 'BAPI_EMPLOYEE_ENQUEUE'
*              exporting
*                number = wa_P0000-pernr
*              importing
*                return = el_return.


*      call function 'HR_INFOTYPE_OPERATION'
*      exporting
*        infty         = '0000'
*        number        = wa_p0000-pernr
*        subtype       = wa_p0000-subty
*        objectid      = wa_p0000-objps
*        validityend   = wa_p0000-endda
*        validitybegin = wa_p0000-begda
*        recordnumber  = wa_p0000-seqnr
*        record        = wa_p0000
*        operation     = 'COP'
**        TCLAS         = 'A'
*        dialog_mode   = '2'
*      importing
*        return        = return_struct
*        key           = personaldatakey.
*
*    if return_struct is not initial.
*      if return_struct-type = 'E'  .

*    call function 'HR_INFOTYPE_OPERATION'
*      exporting
*        infty         = '0008'
*        number        = wa_p0008-pernr
*        subtype       = wa_p0008-subty
*        objectid      = wa_p0008-objps
*        validityend   = wa_p0008-endda
*        validitybegin = wa_p0008-begda
*        recordnumber  = wa_p0008-seqnr
*        record        = wa_p0008
*        operation     = 'INS'
**        TCLAS         = 'A'
*        dialog_mode   = '0'
*      importing
*        return        = return_struct
*        key           = personaldatakey.
*
*    if return_struct is not initial.
*      if return_struct-type = 'E'  .
*         Desbloqueo del empleado
*           call function 'BAPI_EMPLOYEE_ENQUEUE'
*        call function 'BAPI_EMPLOYEE_DEQUEUE'
*          exporting
*            number = wa_p0008-pernr
*          importing
*            return = el_return.
*      endif .
*    else.
*
*      call function 'BAPI_TRANSACTION_COMMIT'
*        importing
*          return = el_return2.
*
**         Desbloqueo del empleado
*       call function 'BAPI_EMPLOYEE_DEQUEUE'
*        exporting
*          number = wa_p0008-pernr
*        importing
*          return = el_return.
*
    endif.
    endif.
endif.
endif.
endif.
endif.
endif.
endif.
*endif.

"27.08.2013 17:02:49 & jpm SACAR DE BLOQUE EL LA FUNCION CREACION 0008
if v_batch = 'X' AND V_FLAG EQ 'X'.

  CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
    EXPORTING
      number = wa_p0000-pernr
    IMPORTING
      return = el_return.

*                  CALL FUNCTION 'ZCCHRMF024_0000'
*                   EXPORTING
*                     CTU                = 'X'
*                     MODE               = 'N'
*                     UPDATE             = 'L'
**                     GROUP              =
**                     USER               =
**                     KEEP               =
**                     HOLDDATE           =
**                     NODATA             = '/'
*                     PERNR_001          = VL_PERNR
*                     TIMR6_002          = 'X'
*                     BEGDA_003          = VL_BEGDA
*                     CHOIC_004          = '0000'
*                     SUBTY_005          = VL_SUBTY
*                     BEGDA_006          = VL_BEGDA
*                     MASSG_007          = VL_MASSG
*                     PLANS_008          = VL_PLANS
*                     WERKS_009          = VL_WERKS
*                     PERSG_010          = VL_PERSG
*                     PERSK_011          = VL_PERSK
*                     BEGDA_012          = VL_BEGDA
*                     MASSG_013          = VL_MASSG
*                     PLANS_014          = VL_PLANS
*                     WERKS_015          = VL_WERKS
*                     PERSG_016          = VL_PERSG
*                     PERSK_017          = VL_PERSK
*                     BEGDA_018          = VL_BEGDA
*                     ENDDA_019          = '31.12.9999'
*                     TRFAR_020          = VL_TRFAR
*                     TRFGB_021          = VL_TRFGB
*                     IBBEG_022          = VL_BEGDA
*                     WAERS_023          = 'MXN'
*                     BETRG_01_024       = VL_BET01
*                     BEGDA_025          = VL_BEGDA
*                     ENDDA_026          = '31.12.9999'
*                     TRFAR_027          = VL_TRFAR
*                     TRFGB_028          = VL_TRFGB
*                     IBBEG_029          = VL_BEGDA
*                     WAERS_030          = 'MXN'
*                   IMPORTING
*                     SUBRC              = VL_SUBRC
*                   TABLES
*                     MESSTAB            = MESSTAB
*                            .
CALL FUNCTION 'ZCCHRMF024_INCRBS'
 EXPORTING
   CTU                = 'X'
   MODE               = 'N'
   UPDATE             = 'L'
*   GROUP              =
*   USER               =
*   KEEP               =
*   HOLDDATE           =
*   NODATA             = '/'
   PERNR_001          = vl_pernr
   TIMR6_002          = 'X'
   BEGDA_003          = vl_begda
   CHOIC_004          = '0000'
   SUBTY_005          = vl_subty
   BEGDA_006          = vl_begda
   MASSG_007          = vl_massg
   PLANS_008          = vl_plans
   BEGDA_009          = vl_begda
   MASSG_010          = vl_massg
   PLANS_011          = vl_plans
   BEGDA_012          = vl_begda
   ENDDA_013          = '31.12.9999'
   TRFAR_014          = vl_trfar
   TRFGB_015          = vl_trfgb
   IBBEG_016          = vl_begda
   WAERS_017          = 'MXN'
   BETRG_01_018       = vl_bet01
 IMPORTING
   SUBRC              = vl_subrc
 TABLES
   MESSTAB            = messtab
          .




  IF  vl_subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      IMPORTING
        return = el_return2.
    COMMIT WORK AND WAIT.

    CALL FUNCTION 'HR_PSBUFFER_INITIALIZE'.

  else.

    wa_log-pernr = wa_p0008-pernr.
    wa_log-msj = 'El empleado actualmente esta bloqueado'.
    wa_log-type = 'E'.

    append wa_log to t_log.
 endif.

ENDIF.

*  form rundung changing value(result).
*  data: factor like p0014-betrg.
*  check rutyp ne space.
*  check rudiv ne 0.
** MOVE result TO factor.                                      "N0790906
** DIVIDE factor BY rudiv.                                     "N0790906
*  factor = result / rudiv.                                    "N0790906
*  multiply factor by rudiv.
** FACTOR is now rounded to nearest
*  case rutyp.
*    when 'A'.                          "rounding down
*      if factor gt result.
*        subtract rudif from factor.
*      endif.
*    when 'B'.                          "already rounded nearest
*    when 'C'.                          "rounding up
*      if factor lt result.
*        add rudif to factor.
*      endif.
*  endcase.
*  move factor to result.
*endform.


ENDENHANCEMENT.
