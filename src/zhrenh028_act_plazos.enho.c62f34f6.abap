"Name: \PR:SAPUP50R\FO:UPDATE\SE:END\EI
ENHANCEMENT 0 ZHRENH028_ACT_PLAZOS.
*
  data: eg_return TYPE bapireturn1,
        el_pa9002 TYPE pa9002,
        el_p9002  TYPE p9002,
        el_return TYPE BAPIRETURN1,
        el_key    TYPE BAPIPAKEY.

  IF pspar-infty eq '9002' and sy-tcode eq 'PA30'.

    assign component 'MONTO' of structure <prel_db> to <campo_monto>.
    assign component 'SDO_PEND' of structure <prel_db> to <campo_sdo_pend>.

    IF sw_commit_work NE space.
      IF pspar-pbpfl IS INITIAL.

          CHECK opera-update EQ 'U' AND <campo_plazos> NE vg_plazos_ant.

          SUBMIT zcchrre001_modif_plazo
              WITH p_pernr  EQ <campo_pernr>
              WITH p_begda  EQ <campo_begda>
              WITH p_subty  EQ <campo_subty>
              WITH p_monto  EQ <campo_monto>
              WITH p_sdo_pe EQ <campo_sdo_pend>
              WITH p_ref    EQ <campo_ref>
              WITH p_pl_ant EQ vg_plazos_ant
              WITH p_pl_nvo EQ <campo_plazos>
              WITH p_descts EQ vg_desctos
              WITH p_end_f  EQ vg_endda_fin
           AND RETURN.

          IMPORT eg_return FROM MEMORY ID 'RETURN'.

          IF eg_return IS NOT INITIAL.
            MESSAGE ID eg_return-id TYPE eg_return-type NUMBER eg_return-number
             WITH eg_return-message_v1 eg_return-message_v2
                  eg_return-message_v3 eg_return-message_v4.
          ENDIF.
       ENDIF.
    ENDIF.

  ENDIF.

ENDENHANCEMENT.
