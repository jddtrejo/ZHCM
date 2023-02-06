"Name: \PR:SAPUP50R\FO:UPDATE\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH028_ACT_PLAZOS.
*
  data: vg_desctos    type i,
        l_t777d_ant   type t777d,
        vg_plazos_ant type zhred_plazos,
        vg_plazos_val type zhred_plazos,
        vg_endda_fin  type endda,
        vg_subrc      TYPE sy-subrc,
        tg_detalle_compra type standard table of zcchrtt_desc,
        tl_detalle_compra type zcchrtt_desc,
        it_pa0001      type standard table of P0001,
        wa_pa0001      type P0001,
        wa_t549t       type t549t,
        e_return       type bal_s_msg.

  field-symbols: <campo_liq> type any,
                 <campo_plazos> type any,
                 <campo_ref> type any,
                 <campo_pernr> type any,
                 <campo_subty> type any,
                 <campo_objps> type any,
                 <campo_sprps> type any,
                 <campo_endda> type any,
                 <campo_begda> type any,
                 <campo_seqnr> type any,
                 <campo_monto> type any,
                 <campo_saldo> type any,
                 <campo_sdo_pend> type any,
                 <campo_fecha_compra> type any,
                 <pnnnn_ant> TYPE ANY.

  IF pspar-infty eq '9002' and sy-tcode eq 'PA30'.

      LOOP AT psoper WHERE infty EQ '9002'.

        CALL FUNCTION 'HR_T777D_READ'
          EXPORTING
             infty                 = pspar-infty
          IMPORTING
             t777d                 = l_t777d_ant
          EXCEPTIONS
             entry_not_found       = 1
          OTHERS                   = 2.

        ASSIGN psoper TO <pnnnn_ant> CASTING TYPE (l_t777d_ant-ppnnn).

        assign component 'PERNR'  of structure <pnnnn_ant> to <campo_pernr>.
        assign component 'SUBTY'  of structure <pnnnn_ant> to <campo_subty>.
        assign component 'OBJPS'  of structure <pnnnn_ant> to <campo_objps>.
        assign component 'SPRPS'  of structure <pnnnn_ant> to <campo_sprps>.
        assign component 'ENDDA'  of structure <pnnnn_ant> to <campo_endda>.
        assign component 'BEGDA'  of structure <pnnnn_ant> to <campo_begda>.
        assign component 'SEQNR'  of structure <pnnnn_ant> to <campo_seqnr>.
        assign component 'LIQ'    of structure <pnnnn_ant> to <campo_liq>.
        assign component 'PLAZOS' of structure <pnnnn_ant> to <campo_plazos>.
        assign component 'REF'    of structure <pnnnn_ant> to <campo_ref>.
        assign component 'FECHA_REAL' of structure <pnnnn_ant> to <campo_fecha_compra>.

        refresh tg_detalle_compra.

        select *
          into table tg_detalle_compra
        from zcchrtt_desc
        where pernr eq <campo_pernr> and
              ref   eq <campo_ref>.

        sort tg_detalle_compra descending by inper fpper.

        describe table tg_detalle_compra lines vg_desctos.

        read table tg_detalle_compra into tl_detalle_compra index 1.
        vg_endda_fin = tl_detalle_compra-fpend.

         select single plazos into vg_plazos_ant
           from (l_t777d_ant-dbtab)
         where pernr eq <campo_pernr> and
               subty eq <campo_subty> and
               objps eq <campo_objps> and
               sprps eq <campo_sprps> and
               endda eq <campo_endda> and
               begda eq <campo_begda> and
               seqnr eq <campo_seqnr>.

*          refresh it_pa0001.
*          call function 'HR_READ_INFOTYPE'
*            exporting
*              TCLAS           = 'A'
*              PERNR           = <campo_pernr>
*              INFTY           = '0001'
*              BEGDA           = '19000101'
*              ENDDA           = '99991231'
*              BYPASS_BUFFER   = 'X'
*            importing
*              SUBRC           = vg_subrc
*            tables
*              INFTY_TAB       = it_pa0001
*            exceptions
*              INFTY_NOT_FOUND = 1
*              OTHERS          = 2.
*          if SY-SUBRC EQ 0.
*            delete it_pa0001 where endda ne '99991231'.
*            read table it_pa0001 index 1 into wa_pa0001.
*            if sy-subrc eq 0.
*               select single *
*                 from t549t
*                 into wa_t549t
*               where sprsl eq sy-langu and abkrs eq wa_pa0001-abkrs.
*               if sy-subrc eq 0.
**SEM = Nominas Quincenales
**S-S = Nominas Sindicalizadas por Hora
*                 if wa_t549t-atext(3) = 'SEM' or wa_t549t-atext(3) = 'S-S'.
*                   vg_plazos_val = 12.
*                 else.
*                   vg_plazos_val = 6.
*                 endif.
*               endif.
*            endif.
*          endif.

          CALL FUNCTION 'ZCCRHMF001_COND'
            EXPORTING
              i_pernr    = <campo_pernr>
              i_datum    = <campo_fecha_compra>
           IMPORTING
              e_plazos   = vg_plazos_val
              e_return   = e_return.

          IF <campo_liq> EQ 'X'.
            MESSAGE e071(zhrcm_cc).
            exit.
*   La compra a crédito ya fue liquidada. No se puede modificar su plazo
          ENDIF.
          IF <campo_plazos> LE 0.
            MESSAGE e035(zhrcm_cc).
            exit.
*   El nuevo número de descuentos ha de ser una cantidad entera y positiva
          ELSEIF <campo_plazos> GT vg_plazos_val.
            MESSAGE e055(zhrcm_cc) WITH vg_plazos_val.
            exit.
*   El número de plazos máximo es &
*Si el nuevo No. de plazos es menor o igual al No. de descuentos ya hechos
          ELSEIF <campo_plazos> LE vg_desctos.
            MESSAGE e036(zhrcm_cc) WITH vg_desctos.
            exit.
*   El número de plazos no puede ser menor o igual a los desc. ya hechos: &
          ENDIF.

      ENDLOOP.
   ENDIF.


ENDENHANCEMENT.
