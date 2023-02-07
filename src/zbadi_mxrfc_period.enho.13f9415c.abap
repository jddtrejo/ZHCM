"Name: \TY:CL_EX_MXRFC_PERIOD\IN:IF_EX_BADI_MXRFC_PERIOD\ME:SELECT_PERIOD\SE:BEGIN\EI
ENHANCEMENT 0 ZBADI_MXRFC_PERIOD.
DATA: t0001 TYPE TABLE OF p0001,
      W0001 TYPE p0001.
  REFRESH t0001.
  CALL FUNCTION 'HR_READ_INFOTYPE'
       EXPORTING
            pernr           = pernr
            infty           = '0001'
            begda           = '18000101'
            endda           = '99991231'
       TABLES
            infty_tab       = t0001
       EXCEPTIONS
            infty_not_found = 1
            OTHERS          = 2.
  IF t0001[] is not initial.
    SORT  t0001 BY begda.
    LOOP AT t0001 INTO W0001.
      IF W0001-begda LT '20130101'.
          rbegda = '20130101'.
      ELSE.
          rbegda = W0001-begda.
      ENDIF.
      EXIT.
    ENDLOOP.
  ENDIF.

rendda = pendda. " valor queda como esta actualmente
EXIT. " se sale de la rutina
ENDENHANCEMENT.
