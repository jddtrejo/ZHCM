"Name: \PR:ZRFFOM100\FO:MT100\SE:END\EI
ENHANCEMENT 0 ZHRENH010_027_WS.

  "10.11.2015 11:38:47 JLGF Comentarizado por el 4287 - Ahora se Envia desde un Proxy
  "en las funciones ZDME_MX_OMNI y ZDME_MX_OMNI_2

** obtiene archivo a enviar a omni por web service.
*  DATA:
*    jobname  LIKE tbtco-jobname,
*    jobcount LIKE tbtcjob-jobcount.
*  DATA: v_file(37) TYPE c.
*  DATA:    l_hora TYPE t.
*  DATA:    l_fecha TYPE d.
*  DATA:    l_message(60).
*  DATA:    p_time TYPE t VALUE '000010'.
*  DATA:    v_par TYPE FORMAT_100 VALUE 'OMNI'.
*
*  break fgarza.
*
*  CLEAR v_file.
*  IMPORT v_file FROM MEMORY ID 'ZFILE'.
*
*  IF v_file IS NOT INITIAL and
*     PAR_MOFI EQ v_par.
*
*    jobname = v_file.
*
*    GET TIME.
*    CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) INTO l_fecha.
*    WAIT UP TO 1 SECONDS.
*    GET TIME.
*
*    CALL FUNCTION 'C14B_ADD_TIME'
*      EXPORTING
*        i_starttime = sy-uzeit
*        i_startdate = sy-datum
*        i_addtime   = p_time
*      IMPORTING
*        e_endtime   = l_hora
*        e_enddate   = l_fecha.
*
*    CALL FUNCTION 'JOB_OPEN'
*      EXPORTING
*        jobname          = jobname
*        sdlstrtdt        = l_fecha
*        sdlstrttm        = l_hora
*      IMPORTING
*        jobcount         = jobcount
*      EXCEPTIONS
*        cant_create_job  = 1
*        invalid_job_data = 2
*        jobname_missing  = 3
*        OTHERS           = 4.
*
*    SUBMIT zcchrre026_ws_url AND RETURN
*       VIA JOB jobname NUMBER jobcount
*      WITH p_name = v_file.
*
*    CALL FUNCTION 'JOB_CLOSE'
*      EXPORTING
*        jobname              = jobname
*        jobcount             = jobcount
*        sdlstrtdt            = l_fecha
*        sdlstrttm            = l_hora
*        strtimmed            = 'X'
*      EXCEPTIONS
*        cant_start_immediate = 1
*        invalid_startdate    = 2
*        jobname_missing      = 3
*        job_close_failed     = 4
*        job_nosteps          = 5
*        job_notex            = 6
*        lock_failed          = 7
*        OTHERS               = 8.
*
*    FREE MEMORY ID 'ZFILE'.
*  ENDIF.

ENDENHANCEMENT.
