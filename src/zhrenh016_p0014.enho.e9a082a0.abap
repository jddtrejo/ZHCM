"Name: \PR:MP001400\FO:MOVE_PNNNN_TO_CPREL\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH016_P0014.
"Ini 101 CCV 19.08.2013
  DATA: vl_anzhl TYPE char13,
        vl_anzhl2 TYPE char13.
    DATA: vl_vetext TYPE t538t-etext,
        vl_permo TYPE t549a-permo,
        vl_pabrp TYPE t549q-pabrp,
        vl_endda TYPE t549q-endda,
        vl_endda2 TYPE t549q-endda,
        vl_rudiv TYPE t511-rudiv,
        v_cont type i,
        V_ANIO TYPE T549Q-pabrj.
  DATA: el_p0001 TYPE p0001,
        lt_0001 TYPE STANDARD TABLE OF p0001,
        lt_t549q TYPE STANDARD TABLE OF t549q,
        lw_0014 TYPE p0014,
        return_struct TYPE bapireturn1,
        personaldatakey TYPE bapipakey,
        el_return  TYPE bapireturn1,
        el_return2  TYPE bapiret2.


  IF sy-tcode = 'PA30'.
    IF    fcode = 'UPD'
      AND pspar-actio = 'INS'
      AND <pnnnn>-betrg NE '0.00'
      AND q0014-eitxt = '$ per pp'
      AND <pnnnn>-opken = 'A'
      AND <pnnnn>-anzhl IS NOT INITIAL.

      WRITE <pnnnn>-anzhl TO vl_anzhl DECIMALS 0.
      vl_anzhl2 = vl_anzhl - 1.

      CONDENSE: vl_anzhl2, vl_anzhl.
*      ZANZHL = VL_ANZHL.
*      ZANZHL_2 = ZANZHL2.

MOVE-CORRESPONDING <PNNNN> TO lw_0014.

* Calcular fecha fin de periodo en base a descuento en reg original
  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr           = lw_0014-pernr
      infty           = '0001'
      begda           = lw_0014-endda
      endda           = lw_0014-endda
    TABLES
      infty_tab       = lt_0001
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.
  IF sy-subrc EQ 0.
    READ TABLE lt_0001 INTO el_p0001 INDEX 1.
    IF sy-subrc EQ 0.
      SELECT SINGLE permo
        FROM t549a INTO vl_permo
        WHERE abkrs = el_p0001-abkrs.
      IF sy-subrc EQ 0.
        SELECT SINGLE pabrp endda
          FROM t549q INTO (vl_pabrp, vl_endda2)
          WHERE permo = vl_permo
            AND pabrj = lw_0014-begda(4)
            AND begda <= lw_0014-begda
            AND endda >= lw_0014-begda.
        IF sy-subrc EQ 0.
          vl_pabrp = vl_pabrp  + VL_anzhl2.
          select * from t549q into TABLE lt_t549q
            WHERE permo = vl_permo
            AND pabrj = lw_0014-begda(4).
          DESCRIBE TABLE lt_t549q lines v_cont.
          IF v_cont > vl_pabrp.
            SELECT SINGLE endda FROM t549q INTO vl_endda
             WHERE permo = vl_permo
               AND pabrj = lw_0014-begda(4)
               AND pabrp = vl_pabrp.
             IF sy-subrc EQ 0.
               <PNNNN>-ENDDA = vl_endda.
             ENDIF.
          ELSE.
             vl_pabrp = vl_pabrp - v_cont.
             V_ANIO = lw_0014-begda(4) + 1.
             SELECT SINGLE endda FROM t549q INTO vl_endda
             WHERE permo = vl_permo
               AND pabrj = V_ANIO
               AND pabrp = vl_pabrp.
             IF sy-subrc EQ 0.
               <PNNNN>-ENDDA = vl_endda.
             ENDIF.
          ENDIF.


*      CALL FUNCTION 'ZCCRHGF040_CREA_IT0014_2'
*        EXPORTING
*          zanzhl         = vl_anzhl
*          zanzhl_2       = vl_anzhl2
*        changing
*          pnnnn          = <pnnnn>.
*            ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
    ENDIF.
  ENDIF.
**"Fin 101 CCV 19.08.2013
ENDENHANCEMENT.
