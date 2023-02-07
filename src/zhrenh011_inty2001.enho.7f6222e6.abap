"Name: \PR:SAPLPT_GUI_SAP_TMW_TDE\FO:SET_DATA\SE:END\EI
ENHANCEMENT 0 ZHRENH011_INTY2001.
*data: v_horas type tdduration,
*      v_fin type abrwt,
*      l_value type char04.
*
*l_value = g_tde_tc_n1-data_mnt-tdtype.
*
*  if (  l_value eq '2102' or l_value eq '2104').
**    break fgarza.
*import horas to v_horas from memory id 'HORAS'.
*import fin to v_fin from memory id 'FIN'.
*
*if v_horas is not initial.
*
*if g_tde_tc_n1-data_mnt-tdduration <> v_horas.
**   g_tde_tc_n1-data_mnt-TDDURATION = V_HORAS.
*   message W010(zhr01) display like 'E' with v_fin.
**   stop.
*endif.
*endif.
*  endif.
break sgarcia_abap.
ENDENHANCEMENT.
