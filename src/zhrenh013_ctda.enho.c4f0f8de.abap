"Name: \PR:ZHMXCDTA0\FO:CHECK_MANY_SEQNR\SE:END\EI
ENHANCEMENT 0 ZHRENH013_CTDA.
data wa_tabla type pc209.
  field-symbols: <emfsl> type pc209-emfsl.

if EMFSL is not initial.
*loop at p_tab_with_seqnr into wa_tabla.
  loop at p_tab_with_seqnr assigning <wa_tab_with_seqnr>.
    assign component 'EMFSL' of structure <wa_tab_with_seqnr>
        to <emfsl>.
      if sy-subrc = 0.
*    if wa_tabla-emfsl ne emfsl.
        if <emfsl> ne emfsl.
*          delete p_tab_with_seqnr from wa_tabla.
          delete p_tab_with_seqnr.
        endif.
      ENDIF.
  endloop.
endif.
ENDENHANCEMENT.
