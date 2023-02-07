"Name: \PR:MP200000\FO:INPUT_STATUS_CALL\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH008_VALINF2001.
*break fgarza.

    data: el_p2001 type p2001,
          V_PERNR TYPE PERSNO,
          vl_subrc type sy-subrc.

    constants c_letr type string value 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'.

   if cprel-infty eq '2001'.

el_p2001 = p2001.

if el_p2001-refnr is not initial
and sy-ucomm <> 'UPDL'
and PME04-FCODE <> 'MOD'.
*and CSAVE is initial .

**    break fgarza.
    if el_p2001-refnr(2) cn c_letr
      or c_letr ca el_p2001-refnr+2(6).
      message e026(zhr01).
    endif.
*    break fgarza.

call function 'FIELD_EXIT_FRNUM'
  exporting
    p_refnr       = el_p2001-refnr
 importing
   v_subrc       = vl_subrc
   PERNR         = V_PERNR
          .

if vl_subrc <> 0.
*  clear: psave.
*  refresh new_image[].
  message e021(zhr01) with V_pernr.
*   message e001(00) with text-002.
   exit.
endif.
*elseif el_p2001-refnr is initial
*  and sy-ucomm <> 'UPDL'.
*  MESSAGE e023(zhr01).
endif.
endif.

ENDENHANCEMENT.
