"Name: \FU:HR_PROGRAM_CHECK_AUTHORIZATION\SE:END\EI
ENHANCEMENT 0 ZEN_AUTHORITY_FDTA.

    IF REPID EQ 'SAPMFDTA'.
      AUTHORITY-CHECK OBJECT 'P_ABAP'
      ID 'REPID' FIELD REPID
      ID 'COARS' FIELD '1'.
      SUBRC = SY-SUBRC.
    ENDIF.
ENDENHANCEMENT.