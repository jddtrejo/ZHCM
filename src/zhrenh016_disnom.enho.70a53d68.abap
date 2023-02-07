"Name: \PR:RPITRF00\FO:PERNR_CHANGE_PROTOCOL\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH016_DISNOM.
if v_aumento is not initial.
LOOP AT l_logtab INTO wa_logtab_line
where ges_betrag is not initial.
  wa_logtab_line-ges_betrag = v_aumento.
  modify l_logtab from wa_logtab_line.
endloop.
clear v_aumento.
endif.

ENDENHANCEMENT.
