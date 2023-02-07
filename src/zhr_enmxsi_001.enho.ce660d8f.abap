"Name: \PR:HMXCALC0\FO:FUMXSI\SE:BEGIN\EI
ENHANCEMENT 0 ZHR_ENMXSI_001.

*FS02052017 EN CAMBIO DE BIMESTRE GENERAR CC-NOMINA INFORMATIVO
    DATA: tmp_per(02) TYPE C,
          tmp_cumno   LIKE t54c1-cumno,
          tmp_cumnoa  LIKE t54c1-cumno,
          tmp_cumyr   LIKE t54c1-cumyr,
          tmp_cumyra  LIKE t54c1-cumyr.
* Constantes
    DATA: c_6210  like t512w-lgart value '6210'.   "Indicador fin de bismestre

* Limpiar variables
      CLEAR: tmp_per,
      tmp_cumno,
      tmp_cumnoa,
      tmp_cumyr,
      tmp_cumyra.

* Excluye nominas extraordinarias y nominas quincenales
      IF aper-paper NE '000000' AND
      aper-permo NE '02'.
*        BREAK-POINT. "03.05.2017 JLGF 5519

* Trae mes de acumulacion
        PERFORM re54c1 USING t549a-datmo
              aper-permo
              aper-paper(4)
              aper-paper+4(2)
              'M'.
        tmp_cumno = t54c1-cumno.
        tmp_cumyr = t54c1-cumyr.

* Solo para meses de acumulacion reelevantes para bimestre
        IF tmp_cumno EQ '02' OR tmp_cumno EQ '04' OR
        tmp_cumno EQ '06' OR tmp_cumno EQ '08' OR
        tmp_cumno EQ '10' OR tmp_cumno EQ '12'.

* Verifica si es el último periodo del bimestre
          tmp_per = aper-paper+4(2) + 1.
*          PERFORM re54c1 USING t549a-datmo
*                aper-permo
*                aper-paper(4)
*                tmp_per
*                'M'.
          SELECT SINGLE * FROM t54c1 "03.05.2017 JLGF 5519
            WHERE datmo = t549a-datmo
              AND permo = aper-permo
              AND pabrj = aper-paper(4)
              AND pabrp = tmp_per
              AND cumty = 'M'.
          IF SY-SUBRC EQ 0.
            tmp_cumnoa = t54c1-cumno.
            tmp_cumyra = t54c1-cumyr.
          ENDIF.
          IF tmp_cumno NE tmp_cumnoa.
            CLEAR it.
            it-abart = '*'.
            it-lgart = c_6210.
            it-anzhl = 1.
*            it-apznr = wpbp-apznr. "03.05.2017 JLGF 5519
            COLLECT it.
          ENDIF.
        ENDIF.
      ENDIF.

ENDENHANCEMENT.
