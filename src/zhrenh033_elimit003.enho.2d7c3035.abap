"Name: \PR:MP000100\FO:FCODE_EDYNR\SE:END\EI
ENHANCEMENT 0 ZHRENH033_ELIMIT003.

   BREAK:JDDTREJO.

   IF SY-TCODE EQ 'PA40' AND PSPAR-MASSN EQ 'Z2' AND PSPAR-BUKRS = 'NGRI'.

    CALL FUNCTION 'ZCCHRMF063_BORRA_IT0003_EVENT'
      EXPORTING
         I_PERNR = PSPAR-PERNR.
    ENDIF.
*
ENDENHANCEMENT.
