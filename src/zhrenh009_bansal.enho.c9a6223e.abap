"Name: \PR:MP000800\FO:INDBW_LGART\SE:END\EI
ENHANCEMENT 0 ZHRENH009_BANSAL.
data: wa_tblgart like line of tblgart.

loop at tblgart into wa_tblgart
  where betrg is not initial.

  if p0008-CPIND = 'T'
    and p0008-bet01 is initial.
  p0008-bet01 = wa_tblgart-betrg.
  endif.
  endloop.


ENDENHANCEMENT.
