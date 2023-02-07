"Name: \PR:HMXCALC0\FO:FUMXGAR\SE:END\EI
ENHANCEMENT 0 ZHRENH007_CC3002.
*Modifica valor de tabla BT de acuerdo a la cantidad de periodos de nómina***
DATA: v_perio TYPE i,
      st_grdbt LIKE pc2l7,
      v_cuota,
      v_fecha  TYPE t549q-endda.

CLEAR: v_perio, v_fecha.

CASE AS-PARM1.
    WHEN 'CALC'.

***Obtiene fecha final del periodo que se esta calculando***
***Obtiene fechas de tabla T549Q***
    SELECT SINGLE endda INTO v_fecha
             FROM t549q WHERE permo EQ aper-permo
                        AND   pabrj EQ aper-paper(4)
                        AND   pabrp EQ aper-paper+4(2).
IF v_fecha >= '20191101'.
***Obtiene cantidad de periodos
  SELECT COUNT(*) INTO v_perio
           FROM t54c1 WHERE datmo EQ t549a-datmo
                      AND   permo EQ aper-permo
                      AND   cumty EQ 'M'
                      AND   cumno EQ t54c1-cumno
                      AND   cumyr EQ t54c1-cumyr.

***Valida que sea cuota fija***
LOOP AT grrec WHERE lgart = '3002'.
  IF grrec-dbcod = 'CF'.
    IF sy-subrc EQ 0.
      IF grrec-rcamt < 0.
        grrec-rcamt = grrec-rcamt * -1.
      ENDIF.
      IF v_perio NE 0.
        grrec-rcamt = grrec-rcamt / v_perio.
      ENDIF.
      grrec-acprp = grrec-rcamt.
      MODIFY grrec.
***Busca registro en tabla temporal para modificarlo
      READ TABLE bt_grn_tmp WITH KEY btznr = grrec-btznr
                                     lgart = grrec-lgart.
      CHECK sy-subrc EQ 0.
      bt_grn_tmp-betrg = bt_grn_tmp-betrg / v_perio.
      MODIFY bt_grn_tmp INDEX sy-tabix.
    ENDIF.
  ENDIF.
ENDLOOP.
ENDIF.
ENDCASE.
ENDENHANCEMENT.
