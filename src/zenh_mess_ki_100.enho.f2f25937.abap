"Name: \PR:MP000000\FO:CHECK_CONTROL_AREA\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_MESS_KI_100.
* 18.08.2016 JPM 4971 implementacion para mensaje KI 100 Marcar como WARNING solo para
* 18.08.2016 JPM 4971 sociedad configurada en TVARV parametro ZHCMCONSTANTE_MESSEGEKI100
DATA: ls_cobl LIKE cobl_ex.           "XFYAHRK030948
  DATA: BEGIN OF ls_cobl_messages OCCURS 0.               "XFYAHRK030948
          INCLUDE STRUCTURE bapireturn1.                 "XFYAHRK030948
  DATA: END OF ls_cobl_messages.        "XFYAHRK030948

  DATA: BEGIN OF Ls_structab OCCURS 2,
            pernr LIKE p0001-pernr,
            prozt LIKE p1001-prozt,
            otype LIKE p1001-otype,
            plste LIKE p1001-objid,
            orgeh LIKE p1001-objid,
            kostl LIKE p0001-kostl,
            stell LIKE p1001-objid,
            begda LIKE p1001-begda,
            endda LIKE p1001-endda,
*           kokrs like tka01-kokrs,                  (del) QICALRK008243
            kokrs LIKE p0001-kokrs,    "QICALRK008243
            gsber LIKE p0001-gsber,
        END OF ls_structab.

  CLEAR: pd_kostl, pd_bukrs, pd_kokrs, co_kokrs.         "XFYALRK053925
*----------- bestimmen CO-KOKRS ----------------------------------
  IF NOT pspar-bukrs IS INITIAL.       " Buchungskreis vorhanden

    CALL FUNCTION 'HRCA_CONTROLLINGAREA_FIND'            "QICALRK029194
         EXPORTING                     "QICALRK029194
              companycode  = pspar-bukrs                 "QICALRK029194
*             businessarea = p0001-gsber   "QICALRK029194"XFYPH9K011235
         IMPORTING                     "QICALRK029194
              contrlarea   = co_kokrs  "QICALRK029194
         EXCEPTIONS                    "QICALRK029194
              not_found    = 1         "QICALRK029194
              OTHERS       = 2.        "QICALRK029194

    IF sy-subrc NE 0.
      co_kokrs = space.
    ENDIF.
  ELSE.                                " Buchungskreis nicht vorhanden
*     --Buchungskreis fehlt ---
    MESSAGE e166.                      "Buchungskreis nicht vorhanden
  ENDIF.

  CLEAR: ls_structab.
  REFRESH: ls_structab.
  CALL FUNCTION 'RH_READ_PERS_ORG_STRU'
       EXPORTING
            begda                  = p0000-begda            "N215691
            endda                  = p0000-begda            "N215691
            imported_plvar         = planvar
            plste                  = pspar-plans
       TABLES
            stru_tab               = ls_structab
       EXCEPTIONS
            integration_not_active = 1
            parameters_missing     = 2
            OTHERS                 = 3.

  IF sy-subrc NE 0.
    CLEAR: pd_kostl, pd_kokrs.
  ELSE.
    MOVE ls_structab-kostl TO pd_kostl.
    MOVE ls_structab-kokrs TO pd_kokrs.
    IF NOT pd_kokrs IS INITIAL AND co_kokrs NE pd_kokrs.    "XFYK000973
      MESSAGE e163.
    ENDIF.
*---------- begin ----------- XFYAHRK030948 ---------------------------
    CHECK NOT pd_kostl IS INITIAL.
    ls_cobl-kokrs = co_kokrs.
    ls_cobl-bukrs = pspar-bukrs.
    ls_cobl-kostl = pd_kostl.
    ls_cobl-budat = p0000-begda.
    ls_cobl-vorgn = 'HRBV'.
    ls_cobl-glvor = 'RFBU'.

    CALL FUNCTION 'HRCA_COBL_CHECK'
      EXPORTING
        i_cobl        = ls_cobl
      IMPORTING
        e_cobl        = ls_cobl
      TABLES
        cobl_messages = ls_cobl_messages.
*------------------------------------------------------------*  JPM INI 4971
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

    LOOP AT ls_cobl_messages. " 18.08.2016 JPM 4971
      IF LS_COBL_MESSAGES-MESSAGE_V4 eq lt_tvarv-low
        or LS_COBL_MESSAGES-MESSAGE_V2 eq lt_tvarv-low.
        CASE LS_COBL_MESSAGES-ID.
          WHEN 'KI'.
            IF LS_COBL_MESSAGES-NUMBER eq '100'.
             move 'W' to lS_cobl_messages-type.
             MODIFY ls_cobl_messages.
            ENDIF.
          WHEN 'KM'.
            IF LS_COBL_MESSAGES-NUMBER eq '183'.
              move 'W' to lS_cobl_messages-type.
              MODIFY ls_cobl_messages.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

*------------------------------------------------------------*  JPM FIN 4971

    LOOP AT ls_cobl_messages.
      IF ls_cobl_messages-id     = 'RP'  AND                 "XFYN165011
         ls_cobl_messages-number = '182' AND                 "XFYN165011
         ls_cobl_messages-type   = 'E'.                      "XFYN165011
        CONTINUE.                                           "XFYN165011
      ENDIF.                                                "XFYN165011

      MESSAGE ID     ls_cobl_messages-id
              TYPE   ls_cobl_messages-type
              NUMBER ls_cobl_messages-number
              WITH   ls_cobl_messages-message_v1
                     ls_cobl_messages-message_v2
                     ls_cobl_messages-message_v3
                     ls_cobl_messages-message_v4.
      EXIT.
    ENDLOOP.
*(del)  call function 'HRCA_COSTCENTER_GETDETAIL'
*(del)       exporting
*(del)            controllingarea = pd_kokrs
*(del)            costcenter      = pd_kostl
*(del)            read_date       = pspar-begda
*(del)       importing
*(del)            companycode     = pd_bukrs
*(del)       exceptions
*(del)            nothing_found   = 1
*(del)            others          = 2.
*(del)  if sy-subrc eq 0.
*(del)    if pd_bukrs ne pspar-bukrs.
*(del)      message e174.
*(del)    endif.
*(del)  endif.
*----------- end ------------ XFYAHRK030948 ---------------------------
  ENDIF.
  exit.


ENDENHANCEMENT.
