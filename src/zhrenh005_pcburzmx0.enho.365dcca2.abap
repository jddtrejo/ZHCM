"Name: \PR:HMXCALC0\IC:PCBURZMX0\SE:END\EI
ENHANCEMENT 0 ZHRENH005_PCBURZMX0.

include zhrpy_fn_hrxd.

INCLUDE ZHRPY_FN_Z_LLB.

INCLUDE ZHRPY_FN_Z_VAL.

FORM FU_SIND.

*Para el requerimiento de sindicatos se van a requerir de los datos que
*vienen en las tablas P0001, P0014 y P0057, de los correspondientes
*infotipos.
*Para introducir resultados de la nómina se trabaja con la tabla IT que
*es una tabla interna con cabecera Tiene el tipo de línea PC207

ENDFORM.

FORM fu_paca.

  DATA: tl_it TYPE PC207_TAB.

  CALL FUNCTION 'ZCCRHGF040_PAGOS_CA_NOM'
    EXPORTING
      i_pernr       = pernr
      i_p0001       = p0001[]
      i_p0015       = p0015[]
      i_p0045       = p0045[]
      i_p0078       = p0078[]
      i_rgdir       = rgdir[]
      i_bondt       = aper-bondt
   IMPORTING
     E_IT          = tl_it.

  APPEND LINES OF tl_it TO it.

ENDFORM.

FORM fu_ccfi.

  DATA: vl_V0ZNR TYPE	i,
        vl_V0ZNR_rec TYPE i,
        vl_subrc TYPE sy-subrc,
        tl_p9002 TYPE STANDARD TABLE OF p9002,
        el_p9002 TYPE p9002.

  CONSTANTS: c_V0TYP TYPE V0TYP VALUE '*'..

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr     = pernr-pernr
      infty     = '9002'
    IMPORTING
      subrc     = vl_subrc
    TABLES
      infty_tab = tl_p9002.

   CHECK vl_subrc EQ 0.

   LOOP AT V0 WHERE V0TYP EQ c_V0TYP.
     vl_V0ZNR_rec = V0-V0ZNR.
     IF vl_V0ZNR IS INITIAL OR vl_V0ZNR_rec GT vl_V0ZNR.
       vl_V0ZNR = vl_V0ZNR_rec.
     ENDIF.
   ENDLOOP.

   LOOP AT tl_p9002 INTO el_p9002 WHERE liq IS INITIAL.
     CLEAR: it, V0.
     it-abart = '*'.
     CASE el_p9002-subty.
       WHEN '0001'. it-lgart = '3026'.
       WHEN '0002'. it-lgart = '3014'.
     ENDCASE.
     it-betrg = el_p9002-sdo_pend * '-1'.
     vl_V0ZNR = vl_V0ZNR + 1.
     v0-V0TYP = it-V0TYP = c_V0TYP.
     v0-V0ZNR = it-V0ZNR = vl_V0ZNR.
     v0-VINFO = p0014-ZUORD.
     APPEND: it, V0.
   ENDLOOP.

ENDFORM.
ENDENHANCEMENT.
