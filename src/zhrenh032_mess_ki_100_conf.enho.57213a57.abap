"Name: \FU:RH_WORKTAB_SPLIT\SE:END\EI
ENHANCEMENT 0 ZHRENH032_MESS_KI_100_CONF.
*
   break jddtrejo.
   DATA: lt_tvarv TYPE STANDARD TABLE OF TVARVC WITH HEADER LINE.
    CALL FUNCTION 'ZSELECT_OPTIONS_TVARVC'
      EXPORTING
        NAME             = 'ZHCMCONSTANTE_MESSEGEKI100'
      TABLES
        R_TVARVC         = lt_tvarv
     EXCEPTIONS
       NO_VARIANT       = 1
       OTHERS           = 2.

    READ TABLE lt_tvarv INDEX 1.

    IF SY-TCODE EQ 'PA40' AND SY-CPROG EQ 'MP000100' AND RHI_SELTAB IS NOT INITIAL.

      FIELD-SYMBOLS: <campopernr>,
                     <campodata>.

      DATA: campopernr(20),
            campodata(20),
            pernr      TYPE pernr_d,
            data       type string,
            TG_0001    TYPE STANDARD TABLE OF P0001,
            TL_0001    TYPE P0001,
            VL_LINES   TYPE I.

      MOVE 'RHI_SELTAB-PERNR' TO campopernr.
      ASSIGN (campopernr) TO <campopernr>.
      IF <campopernr> IS ASSIGNED.
        move <campopernr> to pernr.
        if pernr is not initial.

          MOVE 'RHI_SELTAB-DATA1' TO campodata.
          ASSIGN (campodata) TO <campodata>.
          IF sy-subrc eq 0.
            IF <campodata> IS ASSIGNED.
              move <campodata> to data.
              if data is not initial.

                CALL FUNCTION 'HR_READ_INFOTYPE'
                  EXPORTING
                    PERNR           = pernr
                    INFTY           = '0001'
                    BEGDA           = SY-DATUM
                    ENDDA           = SY-DATUM
                  TABLES
                    INFTY_TAB       = TG_0001
                  EXCEPTIONS
                    INFTY_NOT_FOUND = 1
                    OTHERS          = 2.
                IF SY-SUBRC EQ 0.
                  DELETE TG_0001 WHERE ENDDA NE '99991231'.
                  READ TABLE TG_0001 INTO TL_0001 INDEX 1.
                  IF SY-SUBRC EQ 0.
                    IF lt_tvarv-LOW EQ TL_0001-BUKRS AND
                       lt_tvarv-LOW EQ data(4).
                      DESCRIBE TABLE WORKTABLE_OUT LINES VL_LINES.

                      READ TABLE WORKTABLE_OUT INDEX VL_LINES.
                      CLEAR: WORKTABLE_OUT-SUBRC.

                      MODIFY WORKTABLE_OUT INDEX VL_LINES
                      TRANSPORTING SUBRC.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
   ENDIF.

ENDENHANCEMENT.
