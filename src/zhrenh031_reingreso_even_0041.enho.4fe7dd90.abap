"Name: \PR:MP004100\FO:UPDATE_REFPERNR\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH031_REINGRESO_EVEN_0041.
*

  IF SY-TCODE EQ 'PA40' AND PSPAR-INFTY EQ '0041' AND PSPAR-MASSN EQ 'Z2' AND PSPAR-ENDDA NE '99991231'.

    CALL FUNCTION 'ZCCHRMF058_BORRA_IT0041_EVENT'
      EXPORTING
         I_PERNR = PSPAR-PERNR.

  ENDIF.

ENDENHANCEMENT.
