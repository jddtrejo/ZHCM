"Name: \PR:MP001400\FO:FCODE_EDYNR\SE:END\EI
ENHANCEMENT 0 ZHRENH016_P0014.

"Ini 101 CCV 19.08.2013
DATA: vl_anzhl TYPE char13,
      vl_anzhl2 TYPE char13,
      lt_0001 TYPE STANDARD TABLE OF p0001,
      lt_0014 TYPE STANDARD TABLE OF p0014,
      wa_0014 LIKE p0014,
      el_p0001 TYPE p0001.
DATA: vl_permo TYPE t549a-permo,
      vl_pabrp TYPE t549q-pabrp,
      vl_endda TYPE t549q-endda,
      vl_rudiv type t511-rudiv ,
      l_rudiv type BDCDATA-FVAL ,
      lv_beg LIKE  BDCDATA-FVAL ,
      l_betrg LIKE  BDCDATA-FVAL ,
      lv_end LIKE  BDCDATA-FVAL,
      l_pernr LIKE  BDCDATA-FVAL.
DATA: lv_subrc TYPE syst-subrc,
      messtab TYPE STANDARD TABLE OF bdcmsgcoll,
      el_return  type bapireturn1,
      el_return2  type bapiret2.

  "21.08.2013 21:30:05 & JPM
IF sy-tcode = 'PA30' AND psyst-ioper = 'INS'.
*    IF    fcode = 'UPD'
*      AND pspar-actio = 'INS'
      IF PSYST-IOPEr = 'INS'
      AND <pnnnn>-betrg NE '0.00'
      AND q0014-eitxt = '$ per pp'
      AND <pnnnn>-opken = 'A'
      AND <pnnnn>-anzhl IS NOT INITIAL.


*   Valida si ya se genero registro original
  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr           = <pnnnn>-pernr
      infty           = '0014'
      begda           = <pnnnn>-endda
      endda           = <pnnnn>-endda
    TABLES
      infty_tab       = lt_0014
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.
  IF sy-subrc EQ 0.
    READ TABLE lt_0014 INTO wa_0014 WITH KEY subty = <pnnnn>-subty
                                             endda = <pnnnn>-endda
                                             begda = <pnnnn>-begda
                                             seqnr = <pnnnn>-seqnr .

* Calcular fecha fin de periodo en base a descuento en reg original
    CALL FUNCTION 'HR_READ_INFOTYPE'
      EXPORTING
        pernr           = wa_0014-pernr
        infty           = '0001'
        begda           = wa_0014-endda
        endda           = wa_0014-endda
      TABLES
        infty_tab       = lt_0001
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.
    IF sy-subrc EQ 0.
      READ TABLE lt_0001 INTO el_p0001 INDEX 1.

      SELECT SINGLE permo
        FROM t549a INTO vl_permo
        WHERE abkrs = el_p0001-abkrs.
      IF sy-subrc EQ 0.
        SELECT SINGLE pabrp endda
          FROM t549q INTO (vl_pabrp, vl_endda)
          WHERE permo = vl_permo
            AND pabrj = wa_0014-begda(4)
            AND begda <= wa_0014-begda
            AND endda >= wa_0014-begda.
        IF sy-subrc EQ 0.

          SELECT SINGLE rudiv FROM t511 INTO vl_rudiv
                        WHERE molga = '32'
                          AND lgart = wa_0014-lgart.
          IF sy-subrc EQ 0.
            PACK vl_rudiv TO l_rudiv.
            wa_0014-betrg = ( wa_0014-betrg * wa_0014-anzhl ) / 100.
            move: wa_0014-pernr to l_pernr,
                  wa_0014-betrg to l_betrg .
            wa_0014-endda = vl_endda.
            CONCATENATE wa_0014-begda+6(2) '.'
                        wa_0014-begda+4(2) '.'
                        wa_0014-begda(4) into lv_beg.
            CONCATENATE wa_0014-endda+6(2) '.'
                        wa_0014-endda+4(2) '.'
                        wa_0014-endda(4) into lv_end.
*            CLEAR: wa_0014-anzhl, wa_0014-zeinh.
            CONDENSE: lv_beg, lv_end, l_rudiv, l_betrg.
          ENDIF.


*         Desbloqueo del empleado
              call function 'BAPI_EMPLOYEE_DEQUEUE'
                exporting
                  number = wa_0014-pernr
                importing
                  return = el_return.

          CALL FUNCTION 'ZCCHRMF023_014'
            EXPORTING
*              CTU           = 'X'
*              MODE          = 'A'
*              UPDATE        = 'L'
              p_begda       = lv_beg
              p_endda       = lv_end
              P_PERNR       = l_pernr
              p_lgart       =  l_rudiv
              p_betrg       =  l_betrg
*        NODATA        = '/'
           IMPORTING
             subrc         = lv_subrc
            TABLES
              messtab       = messtab.

          IF  lv_subrc EQ 0.
            call function 'BAPI_TRANSACTION_COMMIT'
                importing
                  return = el_return2.
            COMMIT WORK AND WAIT.

            CALL FUNCTION 'HR_PSBUFFER_INITIALIZE'.

          ENDIF.

*         Bloqueo del empleado
            call function 'BAPI_EMPLOYEE_ENQUEUE'
              exporting
                number = wa_0014-pernr
              importing
                return = el_return.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
ENDIF.
*"Fin 101 CCV 19.08.2013

ENDENHANCEMENT.
