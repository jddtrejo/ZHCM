"Name: \PR:HMXCINF0\FO:GENERATE_LIST\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH011_ADDVALUES.
TYPES: BEGIN OF  ty_reg_pat,
       werks type t7mx0p-werks,
       btrtl type t7mx0p-btrtl,
       repat type t7mx0p-repat,
       END OF ty_reg_pat.

data: ls_data like line of p_datos.
data: lt_reg_pat type STANDARD TABLE OF ty_reg_pat,
      lw_reg_pat type ty_reg_pat,
      lt_p0369 type P0369 OCCURS 0,
      lwP0369 like P0369.

    select werks btrtl repat
      from t7mx0p
     into TABLE lt_reg_pat
     FOR ALL ENTRIES IN p_datos
     where werks = p_datos-WERKS
       and btrtl = p_datos-BTRTL.
    if sy-subrc ne 0.
      clear: lt_reg_pat  .
    endif.

LOOP AT P_DATOS into ls_Data.
 READ TABLE lt_reg_pat INTO lw_reg_pat
   WITH KEY werks = ls_data-WERKS
            btrtl = ls_data-BTRTL.
 IF sy-subrc eq 0.
   ls_Data-repat = lw_reg_pat-repat.
 ENDIF.

 call function 'HR_READ_INFOTYPE'
    exporting
      pernr           = ls_Data-pernr
      infty           = '0369'
      begda           = '19000101'
      endda           = '99991231'
    importing
      subrc           = okcode
    tables
      infty_tab       = lt_p0369
    exceptions
      infty_not_found = 1
      others          = 2.
 READ TABLE lt_p0369 into lwp0369
   WITH KEY pernr = ls_Data-pernr.
 IF sy-subrc eq 0.
    ls_Data-nimss = lwp0369-nimss.
 ENDIF.
modify P_DATOS FROM ls_Data.
ENDLOOP.


ENDENHANCEMENT.
