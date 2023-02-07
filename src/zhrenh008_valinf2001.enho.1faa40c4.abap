"Name: \PR:MP200000\FO:PROCESS_NEW_DYNPRO\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH008_VALINF2001.
*break fgarza.
break sgarcia_abap.
    data: el_p2001 type p2001,
          v_pernr type persno,
          vl_subrc type sy-subrc,
          v_begda  type begda,
          v_endda  type endda.
    constants c_letr type string value 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'.

   if cprel-infty eq '2001'.

el_p2001-pernr = PRELP-pernr.
el_p2001-refnr = PRELP-data1+177(8).

if el_p2001-refnr is not initial
and sy-ucomm <> 'UPDL'
and PME04-FCODE <> 'MOD'.
*and CSAVE is initial .

    break fgarza.
    if el_p2001-refnr(2) cn c_letr
      or c_letr ca el_p2001-refnr+2(6).
      message e026(zhr01).
    endif.

call function 'FIELD_EXIT_FRNUM'
  exporting
    p_refnr       = el_p2001-refnr
 importing
   v_subrc       = vl_subrc
   pernr         = v_pernr
            .

if vl_subrc <> 0.
*  clear: psave.
*  refresh new_image[].
  MESSAGE e021(zhr01) WITH v_PERNR.
*   message e001(00) with text-002.
   exit.
endif.
*elseif el_p2001-refnr is initial
*  and sy-ucomm <> 'UPDL'.
*  MESSAGE e023(zhr01).
endif.

" 18.12.2019 SAGA W:DSHR_6889_PAYCODE
if sy-ucomm = 'UPD'
and PME04-FCODE = 'INS'.

  CALL FUNCTION 'ZDSRHMFPAYCODE_INS'
   EXPORTING
     I_BEGDA       = cprel-begda
     I_ENDDA       = cprel-endda
     I_SUBTY       = cprel-subty
     I_PERNR       = cprel-pernr
            .

endif.

" 31.12.2019 SAGA W:DSHR_6889_PAYCODE
if sy-ucomm = 'UPD'
and PME04-FCODE = '****'.

  CALL FUNCTION 'ZDSRHMFPAYCODE_INS'
   EXPORTING
     I_BEGDA       = cprel-begda
     I_ENDDA       = cprel-endda
     I_SUBTY       = cprel-subty
     I_PERNR       = cprel-pernr
            .

endif.

" 18.12.2019 SAGA W:DSHR_6889_PAYCODE
if sy-ucomm = 'UPD'
and PME04-FCODE = 'MOD'.
  MOVE: <BEGDA> TO V_BEGDA.
  MOVE: <ENDDA> TO V_ENDDA.

  IF SY-SUBRC IS INITIAL.

  CALL FUNCTION 'ZDSRHMFPAYCODE_REM'
  EXPORTING

   PI_BEGDA               = csave-begda
   PI_ENDDA               = csave-endda
   PI_SUBTY               = csave-subty
   PI_PERNR               = csave-pernr
          .

  CALL FUNCTION 'ZDSRHMFPAYCODE_INS'
   EXPORTING
     I_BEGDA       = V_BEGDA
     I_ENDDA       = V_ENDDA
     I_SUBTY       = cprel-subty
     I_PERNR       = cprel-pernr
            .
ENDIF.
endif.

" 09.09.2019 SAGA W:DSHR_6889_PAYCODE
if sy-ucomm = 'UPDL'
and PME04-FCODE = 'DEL'.

CALL FUNCTION 'ZDSRHMFPAYCODE_REM'
  EXPORTING

   PI_BEGDA               = cprel-begda
   PI_ENDDA               = cprel-endda
   PI_SUBTY               = cprel-subty
   PI_PERNR               = cprel-pernr
          .

endif.
endif.


ENDENHANCEMENT.
