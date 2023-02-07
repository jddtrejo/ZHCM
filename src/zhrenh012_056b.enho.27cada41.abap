"Name: \PR:RPTQTA00\FO:FILL_DATA_TAB\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH012_056B.
*
  DATA: vl_subrc type sy-subrc,
        vl_golive type char45,
        vl_datum type d.
  CONSTANTS: c_golive type char40 value 'ZCCHRTV001_GOLIVE'.

    call function 'ZCCHRMF003_TVARV'
    exporting
      p_nombre = c_golive
    importing
      v_value  = vl_golive
      subrc    = vl_subrc.
  condense vl_golive no-gaps.
  vl_datum = vl_golive.

*  check vl_subrc = 0.
*  check vl_subrc = 0 and sy-datum >= vl_datum.

  IF vl_datum(4) > PNPENDDA(4) and PNPENDDA is NOT INITIAL .
    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
  ELSEif vl_datum(4) > pnpendda(4) and pnpendda is NOT INITIAL ..
    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
*  ELSEif vl_datum(4) > pn-endda(4) and pn-endda is NOT INITIAL ..
*    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
*  ELSEif vl_datum(4) > pn-BEGPS(4) and pn-BEGPS is NOT INITIAL ..
*    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
*  ELSEif vl_datum(4) > pn-ENDPS(4) and pn-ENDPS is NOT INITIAL ..
*    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
  ENDIF.

    IF vl_datum(4) > PNPENDPS(4) and PNPENDPS is NOT INITIAL .
     MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
    ELSEif vl_datum(4) > PNPENDPS(4) and PNPENDPS is NOT INITIAL ..
    MESSAGE e024(zhr01) DISPLAY LIKE 'S'.
    ENDIF.

ENDENHANCEMENT.
