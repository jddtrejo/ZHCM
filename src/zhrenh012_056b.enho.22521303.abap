"Name: \PR:RPTQTA00\FO:DISPLAY_LIST\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH012_056B.
*
  DATA: vl_subrc type sy-subrc,
        vl_golive type char45,
        vl_datum type d.
  CONSTANTS: c_golive type char40 value 'ZCCHRTV001_GOLIVE'.

    call function 'ZCCHRMF003_TVARV'
    exporting
      p_nombre = c_golive
    importing
      v_value  = vl_golive
      subrc    = vl_subrc.
  condense vl_golive no-gaps.
  vl_datum = vl_golive.

*  check vl_subrc = 0.
*  check vl_subrc = 0 and sy-datum >= vl_datum.

*  IF vl_datum(4) > pn-begda(4) and pn-begda is NOT INITIAL .
*    MESSAGE e024(zhr01).
  IF vl_datum(4) > PNPENDDA(4) and PNPENDDA is NOT INITIAL .
    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
  ELSEif vl_datum(4) > pnpendda(4) and pnpendda is NOT INITIAL ..
    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
*  ELSEif vl_datum(4) > pn-endda(4) and pn-endda is NOT INITIAL ..
*    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
*  ELSEif vl_datum(4) > pn-BEGPS(4) and pn-BEGPS is NOT INITIAL ..
*    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
*  ELSEif vl_datum(4) > pn-ENDPS(4) and pn-ENDPS is NOT INITIAL ..
*    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
    ENDIF.
    IF vl_datum(4) > PNPENDPS(4) and PNPENDPS is NOT INITIAL .
     MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
    ELSEif vl_datum(4) > PNPENDPS(4) and PNPENDPS is NOT INITIAL ..
    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
    ENDIF.

* Inicio 03092013 CCV 102 Aumento de derecho de contingente absentismo PT_QTA00
if PROC_TYP = '2'.
*BREAK fgarza.
DATA:  BEGIN OF it_20062_01  OCCURS 0.
        INCLUDE STRUCTURE p2006.
DATA:   ban TYPE char1.
DATA:  END OF it_20062_01.

DATA:  BEGIN OF it_20062_02  OCCURS 0.
        INCLUDE STRUCTURE p2006.
DATA:   ban TYPE char1 .
DATA:  END OF it_20062_02.

DATA:  BEGIN OF it_20062  OCCURS 0.
        INCLUDE STRUCTURE p2006.
DATA:  END OF it_20062.
DATA: w_2006 TYPE p2006.

DATA: return_struct TYPE bapireturn1,
      personaldatakey TYPE bapipakey.
DATA:  el_return  TYPE bapireturn1,
      el_return2  TYPE bapiret2.
DATA v_anzhl TYPE p2006-anzhl.

LOOP AT p_default.

  READ TABLE gen_p2006
    WITH KEY ktart = '01'
             anzhl = p_default-anzhl.
  IF sy-subrc EQ 0.
    IF gen_p2006-anzhl < 0.
      it_20062_01-ban = '-'.
      v_anzhl = -1 * gen_p2006-anzhl.
    ELSE.
      it_20062_01-ban = '+'.
      v_anzhl = gen_p2006-anzhl.
    ENDIF.
    MOVE-CORRESPONDING gen_p2006 TO it_20062_01.
    it_20062_01-anzhl = v_anzhl.
    MOVE-CORRESPONDING  gen_p2006 TO w_2006.
    APPEND w_2006 TO it_20062.
    APPEND it_20062_01.
  ENDIF.

  CLEAR v_anzhl.
  READ TABLE gen_p2006
    WITH KEY ktart = '02'
             anzhl = p_default-anzhl.
  IF sy-subrc EQ 0.
    IF gen_p2006-anzhl < 0.
      it_20062_02-ban = '-'.
      v_anzhl = -1 * w_2006-anzhl .
    ELSE.
      it_20062_02-ban = '+'.
      v_anzhl = gen_p2006-anzhl.
    ENDIF.
    MOVE-CORRESPONDING  gen_p2006 TO it_20062_02.
    it_20062_02-anzhl = v_anzhl.
    MOVE-CORRESPONDING  gen_p2006 TO w_2006.
    APPEND w_2006 TO it_20062.
    APPEND it_20062_02.
  ENDIF.
ENDLOOP.

*Eliminar registros Que se acaban de generar
CLEAR w_2006.
LOOP AT it_20062 INTO w_2006.
   w_2006-infty = '2006'.
   w_2006-subty = w_2006-ktart.
   w_2006-seqnr = '001'.
* Bloqueo del empleado
  CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
    EXPORTING
      number = w_2006-pernr
    IMPORTING
      return = el_return.

  CALL FUNCTION 'HR_INFOTYPE_OPERATION'
    EXPORTING
      infty         = '2006'
      number        = w_2006-pernr
      subtype       = w_2006-subty
      objectid      = w_2006-objps
      validityend   = w_2006-endda
      validitybegin = w_2006-begda
      recordnumber  = w_2006-seqnr
      record        = w_2006
      operation     = 'DEL'
      dialog_mode   = '0'
    IMPORTING
      return        = return_struct
      key           = personaldatakey.

  IF return_struct IS NOT INITIAL.
    IF return_struct-type = 'E'  .
*         Desbloqueo del empleado
      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = w_2006-pernr
        IMPORTING
          return = el_return.
    ENDIF .
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      IMPORTING
        return = el_return2.

*         Desbloqueo del empleado
    CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
      EXPORTING
        number = w_2006-pernr
      IMPORTING
        return = el_return.

    DELETE it_20062.

  ENDIF.
ENDLOOP.

CLEAR: it_20062,  w_2006.
REFRESH it_20062[].

it_20062[]  = p2006[].

* Modificar Valor original a actualizar
CLEAR w_2006 .
SORT it_20062 BY anzhl DESCENDING.
LOOP AT it_20062
   INTO w_2006
  WHERE ktart = '01'.

  READ TABLE it_20062_01 WITH KEY begda = w_2006-begda " vbegda
                                  endda = w_2006-endda. "vendda.         "INDEX 1.
  IF sy-subrc EQ 0.
    IF it_20062_01-ban = '-'.
      w_2006-anzhl = w_2006-anzhl - it_20062_01-anzhl.
    ELSE.
      w_2006-anzhl = w_2006-anzhl + it_20062_01-anzhl.
    ENDIF.
    MODIFY it_20062
      FROM w_2006 TRANSPORTING anzhl
     WHERE  ktart = '01'.
    EXIT.
  ENDIF.
ENDLOOP.

CLEAR w_2006.
LOOP AT it_20062
   INTO w_2006
  WHERE ktart = '02'.

  READ TABLE it_20062_02 WITH KEY begda = w_2006-begda" vbegda
                                  endda = w_2006-endda. "vendda.         "INDEX 1.
  IF sy-subrc EQ 0.
    IF it_20062_02-ban = '-'.
      w_2006-anzhl = w_2006-anzhl - it_20062_02-anzhl.
    ELSE.
      w_2006-anzhl = w_2006-anzhl + it_20062_02-anzhl.
    ENDIF.
    MODIFY it_20062
      FROM w_2006 TRANSPORTING anzhl
      WHERE ktart = '02'.
    EXIT.
  ENDIF.
ENDLOOP.


* Modificacion infotipo 2006
LOOP AT it_20062
   INTO w_2006.

  CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
    EXPORTING
      number = w_2006-pernr
    IMPORTING
      return = el_return.

  CALL FUNCTION 'HR_INFOTYPE_OPERATION'
    EXPORTING
      infty         = '2006'
      number        = w_2006-pernr
      subtype       = w_2006-subty
      objectid      = w_2006-objps
      validityend   = w_2006-endda
      validitybegin = w_2006-begda
      recordnumber  = w_2006-seqnr
      record        = w_2006
      operation     = 'MOD'
      dialog_mode   = '0'
    IMPORTING
      return        = return_struct
      key           = personaldatakey.

  IF return_struct IS NOT INITIAL.
    IF return_struct-type = 'E'  .
*         Desbloqueo del empleado
      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = w_2006-pernr
        IMPORTING
          return = el_return.
    ENDIF .
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      IMPORTING
        return = el_return2.

*         Desbloqueo del empleado
    CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
      EXPORTING
        number = w_2006-pernr
      IMPORTING
        return = el_return.

  ENDIF.
ENDLOOP.
endif.
* Fin 03092013 CCV 102 Aumento de derecho de contingente absentismo PT_QTA00
ENDENHANCEMENT.
