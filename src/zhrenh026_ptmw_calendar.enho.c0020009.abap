"Name: \TY:CL_PT_GUI_TMW_TDTYPE_LIST\ME:ON_DRAG\SE:END\EI
ENHANCEMENT 0 ZHRENH026_PTMW_CALENDAR.
*
  data: l_value type char04.
  l_value = <fs>-tdtype.

  UPDATE TVARVC SET LOW = l_value
  WHERE NAME EQ 'ZPTMW_CALENDARIO_VALUE'.
  COMMIT WORK.

  "Este valor se utiliza en esta User Exit: ZXHRTIM00DVEXITU02 y enhancement: ZHR_PTMW

  break jddtrejo.

ENDENHANCEMENT.
