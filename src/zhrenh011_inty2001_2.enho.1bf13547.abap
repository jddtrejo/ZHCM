"Name: \PR:SAPLPT_GUI_SAP_TMW_DETAIL\FO:PAI_2100\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH011_INTY2001_2.
  DATA: l_timespec_blop1 TYPE REF TO if_pt_uia_tmw_timespec_blop,
        l_absence1       TYPE REF TO if_pt_uia_tmw_absence,
        l_p2001_1         TYPE p2001.
  DATA: V_HORAS TYPE TDDURATION,
      V_FIN TYPE abrwt,
      L_VALUE TYPE CHAR04.

data: vl_kwert type abrwt,
      vl_integ type i.

  PERFORM get_selected_timespec CHANGING l_timespec_blop1.
* Convert to absence
  CATCH SYSTEM-EXCEPTIONS move_cast_error = 1.
    l_absence1 ?= l_timespec_blop1->timespec_detail.
  ENDCATCH.

  IF sy-subrc = 0.

*   Fill p2001 structure from dynpro
    l_p2001_1 = l_absence1->p2001.

L_VALUE = p2001-awart.

  if (  l_value eq '2102' or l_value eq '2104').
IMPORT HORAS TO v_HORAS FROM memory id 'HORAS'.
IMPORT FIN TO v_FIN FROM memory id 'FIN'.

if V_HORAS IS NOT INITIAL.

IF  p2001-enduz <> l_p2001_1-enduz.
    p2001-enduz = l_p2001_1-enduz.
   message i010(zhr01) with v_FIN.

ENDIF.
endif.
  ENDIF.

    l_p2001_1-subty = l_p2001_1-awart = p2001-awart.
    l_p2001_1-beguz = p2001-beguz.
    l_p2001_1-enduz = p2001-enduz.
    l_p2001_1-stdaz = p2001-stdaz.
**** YJS V3S
    case cl_pt_v3s=>instance->is_active.
      when abap_false.
        l_p2001_1-vtken = p2001-vtken.
      when abap_true.
        cl_pt_dayass_util=>set_day_flags(
            EXPORTING im_dayassignment = ptm_detail_2001_dis-dayass
            IMPORTING ex_vtken  = l_p2001_1-vtken
                      ex_nxdfl  = l_p2001_1-nxdfl ).
    endcase.
**** END YJS V3S
    l_p2001_1-alldf = p2001-alldf.
    CALL METHOD l_absence1->set_data( l_p2001_1 ).
*   Write cursor to UIA object
    PERFORM set_cursor USING l_timespec_blop1.
  ELSE.
*   Customizing error: Use this dynpro only for IT2001
    MESSAGE x001(hrtim00_ui_tmw)
       WITH l_timespec_blop1->category
            l_timespec_blop1->type
            sy-dynnr.
  ENDIF.

  "JDDTS 31.07.2018
  UPDATE TVARVC SET LOW = l_value
  WHERE NAME EQ 'ZPTMW_CALENDARIO_VALUE'.
  COMMIT WORK.

  "Este valor se utiliza en esta User Exit: ZXHRTIM00DVEXITU02 y enhancement: ZHR_PTMW
  break jddtrejo.


exit.
ENDENHANCEMENT.
