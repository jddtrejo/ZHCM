"Name: \PR:MP000800\FO:SET_SEQNR\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH009_BANSAL.
data: wa_lgart like line of TBLGART.

read table TBLGART into
wa_lgart index 1.
if sy-ucomm <> 'DEL'.
if p0008-CPIND = 'T'.
if P0008-beT01 is not initial.
  if q0008-betrg <> p0008-bet01.
    q0008-betrg = p0008-bet01.
      wa_lgart-betrg = p0008-bet01.
      TBLGART-BETRG = P0008-BET01.
*      clear wa_lgart-INDBW.
   modify table TBLGART from wa_lgart.

*   append wa_lgart to tblgart.
*   delete tblgart where BETRG IS INITIAL.
    message w027(zhr01) display like 'I'.
  endif.
 endif.
endif.
endif.
*break fgarza.
  if p0008-CPIND <> 'T'.
if p0008-bet01 is not initial.
 if wa_lgart-betrg  is initial.
  wa_lgart-betrg = p0008-bet01.

*  if p0008-CPIND <> 'T'.
  clear wa_lgart-INDBW.
*  endif.
*   modify table TBLGART from wa_lgart.
   append wa_lgart to tblgart.
*   clear tblgart-INDBW.
 endif.

  if tblgart-INDBW = 'I'.
   delete tblgart where INDBW = 'I'.
  endif.
*
  clear: Q0008-INDBW .
*         tblgart-INDBW .
ENDIF.
*    delete adjacent duplicates from tblgart.
endif.

ENDENHANCEMENT.
