"Name: \PR:SAPLPT_GUI_SAP_TMW_DETAIL\FO:PAI_INDEX\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH011_INTY2001_2.
data: vl_kwert type abrwt,
      l_value type char04,
      v_err type c,
      v_horas type tdduration,
      v_fin type abrwt,
      vl_integ type i.

check p2001-subty is not initial.

if sy-ucomm = 'PICK'
or sy-ucomm is initial.

if ptm_detail_index-tdtype <> p2001-subty.

  call function 'ZCCHRMF002_LEE_T511K'
      exporting
        i_konst      = 'ZDIAU'
        i_datum      = ptm_detail_index-begda
      importing
        e_kwert      = vl_kwert
      exceptions
        no_hay_datos = 1.

    if sy-subrc ne 0.

      message w009(zhr01) with 'ZDIAU' ptm_detail_index-begda.
*   Error al leer la constante & para la fecha &

    else.

      vl_integ = ptm_detail_index-begda - sy-datum + vl_kwert.

      if vl_integ lt 0.

        message i010(zhr01) with vl_kwert. " type 'E'.
*   Ausentismo se está creando más de & días en el pasado. Contactar respons.
        ptm_detail_index-tdtype = p2001-subty.
      endif.
     endif.
    endif.
    endif.
*    ENDIF.
ENDENHANCEMENT.
