"Name: \PR:HLACTRM0\FO:SELECT_FIRED_EE\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH024_FINIQUITOCOMPRASTEMP.

* Carga compras a credito pendientes en Omnitrans y Temporal
  CALL FUNCTION 'ZCCHRMF051_CREACOMP_FINI'
    EXPORTING
       P_PERNR = p_pernr.

** Carga compras a credito pendientes en Omnitrans y Temporal para Carnes Frias
*  CALL FUNCTION 'ZCCHRMF059_CREACOMP_FINI_CF'
*    EXPORTING
*       P_PERNR = p_pernr.

* Si no es opcion TEST bloquea el gafete
  IF PLATRM_S_OPTIONS-PTEST IS INITIAL.
   CALL FUNCTION 'ZCCHRMF054_GAFETE_OMNITRANS'
    EXPORTING
       P_PERNR = p_pernr.
  ENDIF.

ENDENHANCEMENT.
