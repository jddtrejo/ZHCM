"Name: \PR:HMXCALC0\FO:DEQUEUE_PERNR\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH021_GUARDASDI.
*
  TABLES ZHRTT_SDI.
  DATA unlock_pernr LIKE pernr-pernr.

  IF counter_cw GE counter_cw_limit.
    COMMIT WORK.
    LOOP AT pernr_lock_tab INTO unlock_pernr.
      PERFORM dequeue_pernr_prel    USING unlock_pernr.
      PERFORM dequeue_pernr_epcalac USING unlock_pernr.
      PERFORM dequeue_pernr_natio   IN PROGRAM (sy-repid)
*                                   USING l_unlock_pernr
                                    IF FOUND.
    ENDLOOP.
    PERFORM dequeue_pa03          USING 'X'.         "dequeue temp lock
    CLEAR: pernr_lock_tab[], counter_cw.
*--------------------------------------------------------------------*BEG 3423
   "IF sdi_tmse IS NOT INITIAL and sy-tcode eq 'ZHRTR142'.
*   DATA: p_sdi_tmse TYPE c. " 09.06.2016 IRM 4767 "10.05.2017 JLGF 4767
*   IMPORT p_sdi_tmse FROM MEMORY ID 'ZSDI_TMSE'.
*   IF p_sdi_tmse IS NOT INITIAL and sy-tcode eq 'ZHRTR142'.
*       CALL FUNCTION 'DB_TRUNCATE_TABLE'
*         EXPORTING
*           tabname                = 'ZHRTT_SDI'.
*   ENDIF.

   IF sdi_test IS NOT INITIAL and sy-tcode eq 'ZHRTR142'.
     SORT LT_SDI BY PERNR ENAME WERKS AEDAT.
     DELETE ADJACENT DUPLICATES FROM LT_SDI COMPARING PERNR ENAME WERKS AEDAT.
     MODIFY ZHRTT_SDI FROM TABLE LT_SDI.
     COMMIT WORK AND WAIT.
   ENDIF.
*--------------------------------------------------------------------*END 3423
  ENDIF.

  EXIT.
ENDENHANCEMENT.
