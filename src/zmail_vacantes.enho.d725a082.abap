"Name: \FU:RH_VACANCY_POPUP\SE:END\EI
ENHANCEMENT 0 ZMAIL_VACANTES.

*  BREAK prodriguez.

  CHECK ACT_OBJECT-OTYPE EQ 'S' AND ACT_OK_CODE = 'SUB'.

  CALL FUNCTION 'ZCCRHGF001_NOTIF_BAJA'
    EXPORTING
      i_plans       = OBJEC-OBJID
      i_datum       = ACT_CHANGE_DATE.

ENDENHANCEMENT.