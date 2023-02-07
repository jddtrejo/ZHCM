"Name: \PR:HMXCALC0\FO:PNN-REGEL\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH006_P0014.
**********************************************************************
* Ampliación hecha por Federico Alvarez
  DATA: vl_V0ZNR TYPE	i,"V0ZNR,
        vl_V0ZNR_rec TYPE i,
        ol_ref TYPE REF TO cx_root.
  CONSTANTS: c_V0TYP TYPE V0TYP VALUE '*'.
**********************************************************************

  sw-pz = 'P'.
  IF cdatum_is_set EQ '0'.
    IF gl_sw-ruhend EQ ' '.
      cdatum = glvar-last_act_wpbp_endda.
    ELSE.
      cdatum = glvar-last_wpbp_endda.
    ENDIF.
  ENDIF.
  it = it0.
  PERFORM pos-wpbp.
  it-apznr = wpbp-apznr.
  it-abart = wpbp-abart.
  PERFORM pos-cntr.
  MOVE-CORRESPONDING split-natio TO it.
  it-lgart = p3-lgart.
  CASE as-funco.
    WHEN 'P0014'.
      CLEAR c1.
      CLEAR: c1-bukrs, c1-kostl.                          "WPWK11K109813
      CLEAR: psref.                                       "WPWK11K109813
      rp-get-psref pernr-pernr p0014-infty p0014-subty    "WPWK11K109813
                   p0014-objps p0014-sprps p0014-endda    "WPWK11K109813
                   p0014-begda p0014-seqnr p0014-refex.   "WPWK11K109813
      IF sy-subrc = 4.                                    "WPWK11K109813
        PERFORM log_cost_err IN PROGRAM h99plog0 TABLES error_ptext
                    USING 'P0014'.
        PERFORM errors TABLES error_ptext.
      ENDIF.                                              "WPWK11K109813
      IF sy-subrc EQ 0.                                   "WPWK11K109813
        MOVE-CORRESPONDING psref TO c1.                   "WPWK11K109813
        PERFORM pos-c1 USING    c1
                       CHANGING it-c1znr.                 "WPWK11K109813
      ENDIF.                                              "WPWK11K109813
**********************************************************************
* Ampliación hecha por Federico Alvarez
      TRY.
        LOOP AT V0 WHERE V0TYP EQ c_V0TYP.
          vl_V0ZNR_rec = V0-V0ZNR.
          IF vl_V0ZNR IS INITIAL OR vl_V0ZNR_rec GT vl_V0ZNR.
            vl_V0ZNR = vl_V0ZNR_rec.
          ENDIF.
        ENDLOOP.
        vl_V0ZNR = vl_V0ZNR + 1.
        CLEAR V0.
        v0-V0TYP = it-V0TYP = c_V0TYP.
        v0-V0ZNR = it-V0ZNR = vl_V0ZNR.
        v0-VINFO = p0014-ZUORD.
        APPEND V0.
      CATCH cx_root INTO ol_ref.
        BREAK falvarez.
      ENDTRY.
**********************************************************************
    WHEN 'P0015'.
      CLEAR c1.
      MOVE-CORRESPONDING p0015 TO c1.
      CLEAR: c1-bukrs, c1-kostl.                          "WPWK11K109813
      CLEAR: psref.                                       "WPWK11K109813
      rp-get-psref pernr-pernr p0015-infty p0015-subty    "WPWK11K109813
                   p0015-objps p0015-sprps p0015-endda    "WPWK11K109813
                   p0015-begda p0015-seqnr p0015-refex.   "WPWK11K109813
      IF sy-subrc = 4.                                    "WPWK11K109813
        PERFORM log_cost_err IN PROGRAM h99plog0 TABLES error_ptext
                    USING 'P0015'.
        PERFORM errors TABLES error_ptext.
      ENDIF.                                              "WPWK11K109813
      IF sy-subrc EQ 0.                                   "WPWK11K109813
        MOVE-CORRESPONDING psref TO c1.                   "WPWK11K109813
        PERFORM pos-c1 USING    c1
                       CHANGING it-c1znr.                 "WPWK11K109813
      ENDIF.                                              "WPWK11K109813
    WHEN 'P0267'.                                         "XYJP30K054892
      CLEAR c1.                                            "QEAK79539
      MOVE-CORRESPONDING p0267 TO c1.                      "QEAK79539
      CLEAR: c1-bukrs, c1-kostl.                          "WPWK11K109813
      CLEAR: psref.                                       "WPWK11K109813
      rp-get-psref pernr-pernr p0267-infty p0267-subty    "WPWK11K109813
                   p0267-objps p0267-sprps p0267-endda    "WPWK11K109813
                   p0267-begda p0267-seqnr p0267-refex.   "WPWK11K109813
      IF sy-subrc = 4.                                    "WPWK11K109813
        PERFORM log_cost_err IN PROGRAM h99plog0 TABLES error_ptext
                    USING 'P0267'.
        PERFORM errors TABLES error_ptext.
      ENDIF.                                              "WPWK11K109813
      IF sy-subrc EQ 0.                                   "WPWK11K109813
        MOVE-CORRESPONDING psref TO c1.                   "WPWK11K109813
        PERFORM pos-c1 USING    c1
                       CHANGING it-c1znr.                 "WPWK11K109813
      ENDIF.                                              "WPWK11K109813
    WHEN 'P0579'.                                             "GWY526684
      CLEAR c1.
      MOVE-CORRESPONDING p0579 TO c1.
      CLEAR: c1-bukrs, c1-kostl.
      CLEAR: psref.
      rp-get-psref pernr-pernr p0579-infty p0579-subty
                   p0579-objps p0579-sprps p0579-endda
                   p0579-begda p0579-seqnr p0579-refex.
      IF sy-subrc = 4.
        PERFORM log_cost_err IN PROGRAM h99plog0 TABLES error_ptext
                    USING 'P0579'.
        PERFORM errors TABLES error_ptext.
      ENDIF.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING psref TO c1.
        PERFORM pos-c1 USING    c1
                       CHANGING it-c1znr.
      ENDIF.
  ENDCASE.
  i52c5       = ccycl = as-parm1. "wg. variablem Argument
  MOVE-CORRESPONDING it TO i52c5.
  ot = it.
  plog5_perform plog_header_cycle_pnn(h99plog0)
           using it-lgart calcmolga i52c5-ccycl.
  PERFORM regel.
  PERFORM ot-in-it. "beinhaltet refresh ot.

EXIT.
ENDENHANCEMENT.
