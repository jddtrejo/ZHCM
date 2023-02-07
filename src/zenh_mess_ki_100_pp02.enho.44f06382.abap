"Name: \PR:SAPLRHPR\FO:KOSTL_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_MESS_KI_100_PP02.
*
   data: zcostc_tab like csks_hr occurs 0 with header line.

  data: begin of zchbkrs_tab occurs 0,
          otype like kc_compare_tab-otype,
          objid like kc_compare_tab-objid,
          flag_chbkrs type flag,
          flag_contrychange type flag,
         end of zchbkrs_tab.

  data: zkc_flag.
  data: zexit_flag.                     "ANDCOOPER
  data: zkc_kokrs like pkeyk-kokrs.
  data: zp_country like t500p-molga.
  data: zo_country like t500p-molga.
  data: zcountry_flag type flag.
  data: zbkrs_prog like t77eo-prog.
  data: ztarget_bukrs like p1008-bukrs.
  data: zsubrc like sy-subrc.
  data: zkstl_key like pkeyk.

  data: begin of zcostcenter_info.
*          include structure csksv.
  data:   bukrs like hrca_costc-companycode.
  data:   bkzkp like hrca_costc-primary_costs.
  data: end   of zcostcenter_info.

*  data: bkzkp_flag.                    "QPXALRK009367

  data: zerror_person like plog-objid.

  data: zl_cobl like cobl_ex.           "ANDAHRK030634
  data: begin of zl_cobl_messages occurs 0.               "ANDAHRK030634
          include structure bapireturn1.                 "ANDAHRK030634
  data: end of zl_cobl_messages.        "ANDAHRK030634

  data: ZPOPUPTITLE(30) TYPE C,                             "note 957990
        ZPOPUP_ANSWER TYPE CHAR1.                           "note 957990

  data: zsent_messages like zl_cobl_messages occurs 0      "ANDPH9K004190
                                  with header line.      "ANDPH9K004190

  clear kc_subrc.                      "ANDCOOPER

* pernr_change_tab collects the pernrs to be checked in this routine
* -> the kostl of these pernrs will change
* -> these pernrs are candidates for "enhanced integration"

  loop at kc_compare_tab.              "QPXP40K025108
    move kc_compare_tab-objid to pernr_change_tab-objid.  "QPXP40K025108
    collect pernr_change_tab.          "QPXP40K025108
  endloop.                             "QPXP40K025108

  CHECK RHPR_COST_CENTER_CHECK EQ 'X'.                       "ARN308875

* Kostl and person must belong to same controlling area
  refresh zchbkrs_tab.
  loop at stc_tabelle1.
    check zkc_flag is initial.
    loop at kc_compare_tab.
      clear zsubrc.
*     Nur wenn sich die entsprechenden Einträge aus STC_TABELLE1 "AND
*     und KC_COMPARE_TAB schneiden.                              "AND
      check kc_compare_tab-begda le stc_tabelle1-endda.     "AND
      check kc_compare_tab-endda ge stc_tabelle1-begda.     "AND

*     OBJID: 8 digits, cost center: 10 digits
      if not ( stc_tabelle1-otype is initial )
         and not ( kc_compare_tab-bukrs is initial ).
        if kc_old-bukrs ne kc_compare_tab-bukrs
           or kc_old-gsber ne kc_compare_tab-gsber.

*         Via T77S0 and T77EO
          if $kostl is initial.
            perform re77s0(mstt77s0) using 'OTYPE' 'KOSTL' $kostl zsubrc.
          endif.
          select single * from t77eo where otype = $kostl.
          if sy-subrc = 0.
            perform kokrs_find in program (t77eo-prog)
                                          using kc_compare_tab-bukrs
                                                kc_compare_tab-gsber
                                                zkc_kokrs
                                                zsubrc.
          else.
            if no_msg is initial.      "ANDCOOPER
              message e001(5a) with 'T77EO' $kostl.
            else.                      "ANDCOOPER
* Fehler aufgetreten aber kein Fall für die erweiterte       "ANDCOOPER
* Integration, deshalb auch zexit_flag auf 'X'.               "ANDCOOPER
              msg_tab_global-msgty = 'E'.                    "ANDCOOPER
              msg_tab_global-msgid = '5A'.                 "MELN1474407
              msg_tab_global-msgno = 001.                    "ANDCOOPER
              msg_tab_global-msgv1 = 'T77EO'.                "ANDCOOPER
              msg_tab_global-msgv2 = $kostl.                 "ANDCOOPER
              msg_tab_global-pernr = kc_compare_tab-objid.   "ANDCOOPER
              append msg_tab_global.   "ANDCOOPER
              zkc_flag = 'X'.           "ANDCOOPER
              zexit_flag = 'X'.         "ANDCOOPER
              exit.                    "ANDCOOPER
            endif.                     "ANDCOOPER
          endif.

          kc_old-bukrs = kc_compare_tab-bukrs.
          kc_old-gsber = kc_compare_tab-gsber.
          kc_old-kokrs = zkc_kokrs.
        else.
          zkc_kokrs = kc_old-kokrs.
        endif.
        if zkc_kokrs ne stc_tabelle1-kokrs.
          zkc_flag = 'X'.
* save in zchbkrs_tab with person and which kind of event
          zchbkrs_tab-otype = kc_compare_tab-otype.      "XMBgz_40A300697
          zchbkrs_tab-objid = kc_compare_tab-objid.
          zchbkrs_tab-flag_chbkrs = 'X'.
          append zchbkrs_tab.
          exit.
        endif.

        if stc_tabelle1-bukrs is initial.

*          CALL FUNCTION 'RK_KOSTL_READ'
*               EXPORTING
*                    DATUM              = STC_TABELLE1-BEGDA
*                    KOKRS              = STC_TABELLE1-KOKRS
*                    KOSTL              = STC_TABELLE1-OBJID
*                    KOSTS              = '3'
*               IMPORTING
*                    XCSKSV             = zcostcenter_info
*               EXCEPTIONS
*                    KOSTL_NOT_COMPLETE = 1
*                    KOSTL_NOT_FOUND    = 2
*                    TEXT_NOT_FOUND     = 3
*                    OTHERS             = 4.

*--------------------------------------------------- START ANDAHRK030634
*Buchungskreis zu Kostenrechnungskreis und Kostenstelle finden
          call function 'HRCA_COSTCENTER_GETDETAIL'
                 exporting
                      controllingarea = stc_tabelle1-kokrs
                      costcenter      = stc_tabelle1-objid
                      read_date       = stc_tabelle1-begda
                 importing
                      companycode     = zcostcenter_info-bukrs
*                     PRIMARY_COSTS   = zcostcenter_info-BKZKP
                 exceptions
                      nothing_found   = 1
                      others          = 2.

          if sy-subrc ne 0.
            if no_msg is initial.
              message e307(pb) with stc_tabelle1-objid
                                    stc_tabelle1-kokrs.
            else.
*Fehler aufgetreten aber kein Fall für die erweiterte        "ANDCOOPER
*Integration, deshalb auch zexit_flag auf 'X'.                "ANDCOOPER
              msg_tab_global-msgty = 'E'.
              msg_tab_global-msgid = 'PB'.
              msg_tab_global-msgno = 307.
              msg_tab_global-msgv1 = stc_tabelle1-objid.
              msg_tab_global-msgv2 = stc_tabelle1-kokrs.
              msg_tab_global-pernr = kc_compare_tab-objid.
              append msg_tab_global.
              zkc_flag = 'X'.
              zexit_flag = 'X'.         "ANDCOOPER
              exit.
            endif.
          else.
*Buchungskreis wurde ermittelt. Noch absichern, daß der Buchungskreis
*nicht initial ist. Dann Kostenstelle prüfen.
            if zcostcenter_info-bukrs is initial.
              if no_msg is initial.
                message e307(pb) with stc_tabelle1-objid
                                      stc_tabelle1-kokrs.
              else.
*Fehler aufgetreten aber kein Fall für die erweiterte        "ANDCOOPER
*Integration, deshalb auch zexit_flag auf 'X'.                "ANDCOOPER
                msg_tab_global-msgty = 'E'.
                msg_tab_global-msgid = 'PB'.
                msg_tab_global-msgno = 307.
                msg_tab_global-msgv1 = stc_tabelle1-objid.
                msg_tab_global-msgv2 = stc_tabelle1-kokrs.
                msg_tab_global-pernr = kc_compare_tab-objid.
                append msg_tab_global.
                zkc_flag = 'X'.
                zexit_flag = 'X'.       "ANDCOOPER
                exit.
              endif.
            endif.
*Buchungskreis der Kostenstelle ist nicht initial.
            clear zl_cobl.
            zl_cobl-kokrs = stc_tabelle1-kokrs.
            zl_cobl-bukrs = zcostcenter_info-bukrs.
            zl_cobl-kostl = stc_tabelle1-objid.
*           FISTL und GEBER müssen mitverprobt werden,   "ANDPH9K014241
*           wegen Haushaltsmanagement.                   "ANDPH9K014241
            zl_cobl-FISTL = kc_compare_tab-fistl.         "ANDPH9K014241
            zl_cobl-GEBER = kc_compare_tab-geber.         "ANDPH9K014241

*           STRO FUND ACCOUNTING
            zl_cobl-fkber = kc_compare_tab-fkber.
            zl_cobl-grant_nbr = kc_compare_tab-grant_nbr.

*           GSBER wird nicht mehr verprobt!
*            zl_cobl-GSBER = kc_compare_tab-gsber.         "ANDPH9K014241
            zl_cobl-budat = kc_compare_tab-begda.       "STRO Note 519088
*            zl_cobl-budat = stc_tabelle1-begda.         "SRON1031026  "SRON1957959
            zl_cobl-vorgn = 'HRBV'.
            zl_cobl-glvor = 'RFBU'.

*Kostenstelle selbst checken.
            call function 'HRCA_COBL_CHECK'
                 exporting
                      i_cobl        = zl_cobl
                 importing
                      e_cobl        = zl_cobl
                 tables
                      cobl_messages = zl_cobl_messages
                 exceptions
                      others        = 1.

            if sy-subrc eq 0.
*Alle Meldungen ausgeben oder in Tabelle schreiben.
              if no_msg is initial.
                loop at zl_cobl_messages.
*Verhindern, daß gleiche Meldungen mehrfach ausgegeben werden.
                  read table zsent_messages                "ANDPH9K004190
                             with key zl_cobl_messages.    "ANDPH9K004190
                  if sy-subrc <> 0.                       "ANDPH9K004190
                    message id     zl_cobl_messages-id
                            type   zl_cobl_messages-type
                            number zl_cobl_messages-number
                            with   zl_cobl_messages-message_v1
                                   zl_cobl_messages-message_v2
                                   zl_cobl_messages-message_v3
                                   zl_cobl_messages-message_v4.
                    append zl_cobl_messages                "ANDPH9K004190
                                       to zsent_messages.  "ANDPH9K004190
                  endif.                                  "ANDPH9K004190
                endloop.
              else.
                loop at zl_cobl_messages.
                  msg_tab_global-msgty = zl_cobl_messages-type.
                  msg_tab_global-msgid = zl_cobl_messages-id.
                  msg_tab_global-msgno = zl_cobl_messages-number.
                  msg_tab_global-msgv1 = zl_cobl_messages-message_v1.
                  msg_tab_global-msgv2 = zl_cobl_messages-message_v2.
                  msg_tab_global-msgv3 = zl_cobl_messages-message_v3.
                  msg_tab_global-msgv4 = zl_cobl_messages-message_v4.
                  msg_tab_global-pernr = kc_compare_tab-objid.
                  append msg_tab_global.
                endloop.
              endif.
*Wenn in zl_cobl_MESSAGES eine E-Meldung enthalten ist, wird die Ver-
*arbeitung hier abgebrochen.
              read table zl_cobl_messages with key type = 'E'.
              if sy-subrc eq 0.
*Fehler aufgetreten aber kein Fall für die erweiterte        "ANDCOOPER
*Integration, deshalb auch zexit_flag auf 'X'.                "ANDCOOPER
                zkc_flag = 'X'.
                zexit_flag = 'X'.       "ANDCOOPER
                exit.
              endif.
            endif.
*Kostenstelle scheint OK zu sein. Prüfen ob die Buchungskreise von
*Kostenstelle und Person übereinstimmen.

*zcostcenter_info-bukrs kann nicht inital sein.
*            IF NOT ( zcostcenter_info-BUKRS IS INITIAL ).

            if kc_compare_tab-bukrs ne zcostcenter_info-bukrs.
*Buchungskreisproblem. Mit FB HRCA_COBL_CHECK nochmals testen. Dieser
*FB berücksichtigt auch ob die Buchungskreisverprobung aktiviert ist
*oder nicht. Wenn auch dieser Check fehlerhaft ended wird das zkc_flag
*auf 'X' gesetzt.

              clear zl_cobl.
              zl_cobl-kokrs = stc_tabelle1-kokrs.
              zl_cobl-bukrs = kc_compare_tab-bukrs.
              zl_cobl-kostl = stc_tabelle1-objid.
*             FISTL und GEBER müssen mitverprobt werden, "ANDPH9K014241
*             wegen Haushaltsmanagement.                 "ANDPH9K014241
              zl_cobl-FISTL = kc_compare_tab-fistl.
              zl_cobl-GEBER = kc_compare_tab-geber.

*             STRO FUND ACCOUNTING
              zl_cobl-fkber = kc_compare_tab-fkber.
              zl_cobl-grant_nbr = kc_compare_tab-grant_nbr.

*             GSBER wird nicht mehr verprobt!
*              zl_cobl-GSBER = kc_compare_tab-gsber.
              zl_cobl-budat = kc_compare_tab-begda.    "STRO Note 519088
              zl_cobl-vorgn = 'HRBV'.
              zl_cobl-glvor = 'RFBU'.

*Kostenstelle mit Buchungskreis der Person verproben.
              call function 'HRCA_COBL_CHECK'
                   exporting
                        i_cobl        = zl_cobl
                   importing
                        e_cobl        = zl_cobl
                   tables
                        cobl_messages = zl_cobl_messages
                   exceptions
                        others        = 1.

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

    LOOP AT zl_cobl_messages. " 18.08.2016 JPM 4971
      IF zl_cobl_messages-MESSAGE_V4 eq lt_tvarv-low
        or zl_cobl_messages-MESSAGE_V2 eq lt_tvarv-low.
        CASE zl_cobl_messages-ID.
          WHEN 'KI'.
            IF zl_cobl_messages-NUMBER eq '100'.
             move 'W' to zl_cobl_messages-type.
             MODIFY zl_cobl_messages.
            ENDIF.
          WHEN 'KM'.
            IF zl_cobl_messages-NUMBER eq '183'.
              move 'W' to zl_cobl_messages-type.
              MODIFY zl_cobl_messages.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

*------------------------------------------------------------*  JPM FIN 4971
              if sy-subrc eq 0.
                read table zl_cobl_messages with key type = 'E'.
                if sy-subrc eq 0.
                  if btci_create = 'X'.
*                 Die Meldung nur in msg_tab_global aufnehmen, wenn
*                 Report RHINTE30 läuft. Ansonsten braucht keine Mel-
*                 dung ausgegeben werden, da diese Aktion entweder
*                 durch die erw. Integration abefangen wird oder statt-
*                 dessen später eine andere Meldung ausgegeben wird.
                    msg_tab_global-msgty = 'E'.
                    msg_tab_global-msgid = 'PB'.
                    msg_tab_global-msgno = 317.
                    msg_tab_global-msgv1 = kc_compare_tab-objid.
                    msg_tab_global-msgv2 = kc_compare_tab-bukrs.
                    msg_tab_global-msgv3 = stc_tabelle1-objid.
                    msg_tab_global-msgv4 = zcostcenter_info-bukrs.
                    msg_tab_global-pernr = kc_compare_tab-objid.
                    append msg_tab_global.
                  endif.
                  zkc_flag = 'X'.
* save in zchbkrs_tab with person and which kind of event
                  zchbkrs_tab-otype = kc_compare_tab-otype.
                  zchbkrs_tab-objid = kc_compare_tab-objid.
                  zchbkrs_tab-flag_chbkrs = 'X'.
                  append zchbkrs_tab.
                  exit.
                else.
*Keine E-Meldungen vorhanden, also alle Meldungen ausgeben.
                  loop at zl_cobl_messages.
* begin of insertion note 957990
                 IF SY-TCODE = 'PPOME' AND
                    zl_cobl_MESSAGES-TYPE = 'W'.
*                  Jede Warnung nur einmal ausgeben!
                   READ TABLE SEND_MESSAGES WITH KEY
                                            zl_cobl_MESSAGES
                              TRANSPORTING NO FIELDS.
                   IF SY-SUBRC = 0.
                     CONTINUE.
                   ELSE.
                     APPEND zl_cobl_MESSAGES TO SEND_MESSAGES.
                   ENDIF.
*                  Einfache Pflege -> Listverarbeitung, deshalb
*                  Sonderbehandlung für Warnungen.
                   CONCATENATE 'Warnung'(WAR)
                               zl_cobl_MESSAGES-ID
                               zl_cobl_MESSAGES-NUMBER
                          INTO ZPOPUPTITLE
                               SEPARATED BY SPACE.

                   CALL FUNCTION 'POPUP_TO_CONFIRM'
                     EXPORTING
                       TITLEBAR              = ZPOPUPTITLE
                       TEXT_QUESTION         = zl_cobl_MESSAGES-MESSAGE
                       TEXT_BUTTON_1         = 'Weiter'(WEI)
                       ICON_BUTTON_1         = 'ICON_CHECKED'
                       TEXT_BUTTON_2         = 'Abbrechen'(ABB)
                       ICON_BUTTON_2         = 'ICON_INCOMPLETE'
                       DISPLAY_CANCEL_BUTTON = ' '
                       POPUP_TYPE            = 'ICON_MESSAGE_WARNING'
                     IMPORTING
                       ANSWER                = ZPOPUP_ANSWER
                     EXCEPTIONS
                       TEXT_NOT_FOUND        = 1
                       OTHERS                = 2.

                   IF SY-SUBRC <> 0.
                     CONTINUE.
                   ELSE.
                     IF ZPOPUP_ANSWER = '2'.
                        msg_tab_global-msgty = 'I'.
                        msg_tab_global-msgid = '5A'.
                        msg_tab_global-msgno = 124.
                        append msg_tab_global.
                        zkc_flag = 'X'.
                        zexit_flag = 'X'.
                        exit.
                     ENDIF.
                   ENDIF.
                 ELSE.
* end of insertion note 957990
                    message id     zl_cobl_messages-id
                            type   zl_cobl_messages-type
                            number zl_cobl_messages-number
                            with   zl_cobl_messages-message_v1
                                   zl_cobl_messages-message_v2
                                   zl_cobl_messages-message_v3
                                   zl_cobl_messages-message_v4.
                  endif.                                   "note 957990
                  endloop.
                endif.
              endif.
            endif.
          endif.
*----------------------------------------------------- END ANDAHRK030634
        endif.
      endif.
    endloop.
  endloop.

  if zkc_flag = 'X'.
* Kostenstellenproblem mit Bukrs/Werk/Kokrs ist aufgetreten: kein
* Update auf PLOG und PREL, da sonst Versetzungen nötig wären

*   error: dequeue persons
*   loop at pernr_tab.                                   "QPXALRK009367
    loop at pernr_tab where objid = kc_compare_tab-objid.   "QPXALR9367
      CALL FUNCTION 'HR_DEQUEUE_OBJECT'              "SRON1455954
        EXPORTING                                    "SRON1455954
          plvar                  = plvar             "SRON1455954
          otype                  = 'P '              "SRON1455954
          objid                  =  pernr_tab-objid  "SRON1455954
          DEQUEUE_ONCE           = 'X'               "SRON1455954
        EXCEPTIONS                                   "SRON1455954
         ILLEGAL_OTYPE          = 1                  "SRON1455954
         OBJID_IS_INITIAL       = 2                  "SRON1455954
         INTERNAL_ERROR         = 3                  "SRON1455954
         OTHERS                 = 4.                 "SRON1455954
      perform dequeue_pernr(sapfp50g) using pernr_tab-objid.
      delete pernr_tab.                "QPXALR9376
    endloop.
*   refresh pernr_tab.                                      "QPXALR9376

* RHINTE30-Lauf: Person festhalten, keine Meldungen         "ANDinte30
*    if btci_create = 'X' and p1001-otype = $pernr.         "ANDinte30
*      clear zkc_flag.                                       "ANDinte30
*      zerror_person = kc_compare_tab-objid.                 "ANDinte30
*      export zerror_person to memory id 'INTEBATCH'.        "ANDinte30
*      check 1 = 0.                                         "ANDinte30
*    endif.                                                 "ANDinte30

* Bearbeitung abbrechen, wenn zexit_flag den Wert 'X' hat.    "ANDCOOPER
    if zexit_flag = 'X'.                "ANDCOOPER
      kc_subrc = 1.                    "ANDCOOPER
      exit.                            "ANDCOOPER
    endif.                             "ANDCOOPER

* in case of integration including change of cost center
    if flag_int = 'X'.

      loop at kc_compare_tab.
        loop at stc_tabelle1.

          if stc_tabelle1-bukrs is initial.

            select single prog from t77eo into zbkrs_prog
                                       where otype = stc_tabelle1-otype.

            zkstl_key-kostl = stc_tabelle1-objid.
            zkstl_key-kokrs = stc_tabelle1-kokrs.

            perform list_companycode_of_costcenter
                                       in program (zbkrs_prog)
                                       tables zcostc_tab
                                       using zkstl_key
                                             stc_tabelle1-begda
                                             stc_tabelle1-endda
                                             zsubrc.

            sort zcostc_tab by startdate.

            loop at zcostc_tab where
                  ( startdate >= stc_tabelle1-begda ) or
                  ( ( startdate <= stc_tabelle1-begda ) and
                  ( enddate >= stc_tabelle1-endda ) ).
              ztarget_bukrs = zcostc_tab-companycode.
            endloop.

            if sy-subrc = 4.
              if no_msg is initial.                          "ANDCOOPER
                message e003(pd) with zkstl_key-kokrs zkstl_key-kostl
                                     stc_tabelle1-begda.
              else.                                          "ANDCOOPER
                msg_tab_global-msgty = 'E'.                  "ANDCOOPER
                msg_tab_global-msgid = 'PD'.                 "ANDCOOPER
                msg_tab_global-msgno = 003.                  "ANDCOOPER
                msg_tab_global-msgv1 = zkstl_key-kokrs.       "ANDCOOPER
                msg_tab_global-msgv2 = zkstl_key-kostl.       "ANDCOOPER
                msg_tab_global-msgv3 = stc_tabelle1-begda.   "ANDCOOPER
                msg_tab_global-pernr = kc_compare_tab-objid. "ANDCOOPER
                append msg_tab_global.                       "ANDCOOPER
                kc_subrc = 1.                                "ANDCOOPER
                exit.                                        "ANDCOOPER
              endif.                                         "ANDCOOPER
            endif.
          endif.

* check PA country of old bukrs
          select single molga from t500p into zp_country
                                   where bukrs = kc_compare_tab-bukrs.
          if sy-subrc <> 0.
            clear zp_country.
            if no_msg is initial.                            "ANDCOOPER
              message e024(pd) with kc_compare_tab-bukrs
                                    kc_compare_tab-objid.
            else.                                            "ANDCOOPER
              msg_tab_global-msgty = 'E'.                    "ANDCOOPER
              msg_tab_global-msgid = 'PD'.                   "ANDCOOPER
              msg_tab_global-msgno = 024.                    "ANDCOOPER
              msg_tab_global-msgv1 = kc_compare_tab-bukrs.   "ANDCOOPER
              msg_tab_global-msgv2 = kc_compare_tab-objid.   "ANDCOOPER
              msg_tab_global-pernr = kc_compare_tab-objid.   "ANDCOOPER
              append msg_tab_global.                         "ANDCOOPER
              kc_subrc = 1.                                  "ANDCOOPER
              exit.                                          "ANDCOOPER
            endif.                                           "ANDCOOPER
          endif.

* check PA country of new bukrs
          select single molga from t500p into zo_country
                                   where bukrs = ztarget_bukrs.
          if sy-subrc <> 0.
            clear zo_country.
            if no_msg is initial.                            "ANDCOOPER
              message e025(pd) with ztarget_bukrs
                                    kc_compare_tab-objid.
            else.                                            "ANDCOOPER
              msg_tab_global-msgty = 'E'.                    "ANDCOOPER
              msg_tab_global-msgid = 'PD'.                   "ANDCOOPER
              msg_tab_global-msgno = 025.                    "ANDCOOPER
              msg_tab_global-msgv1 = ztarget_bukrs.           "ANDCOOPER
              msg_tab_global-msgv2 = kc_compare_tab-objid.   "ANDCOOPER
              msg_tab_global-pernr = kc_compare_tab-objid.   "ANDCOOPER
              append msg_tab_global.                         "ANDCOOPER
              kc_subrc = 1.                                  "ANDCOOPER
              exit.                                          "ANDCOOPER
            endif.                                           "ANDCOOPER
          endif.

          if ( zo_country <> zp_country ).
* check if country change is allowed in system
            clear zcountry_flag.

            perform re77s0(mstt77s0) using 'ADMIN'
                                           'CNTRY'
                                           zcountry_flag
                                           zsubrc.
* country change not allowed yet.
            clear zcountry_flag.

            if zcountry_flag is initial.
* country change is not allowed
              if no_msg is initial.                          "ANDCOOPER
                message e002(pd).
              else.                                          "ANDCOOPER
                msg_tab_global-msgty = 'E'.                  "ANDCOOPER
                msg_tab_global-msgid = 'PD'.                 "ANDCOOPER
                msg_tab_global-msgno = 002.                  "ANDCOOPER
                msg_tab_global-pernr = kc_compare_tab-objid. "ANDCOOPER
                append msg_tab_global.                       "ANDCOOPER
                kc_subrc = 1.                                "ANDCOOPER
                exit.                                        "ANDCOOPER
              endif.                                         "ANDCOOPER
            else.
* action for country change
              act_intgrat-countrychange = 'X'.
              read table zchbkrs_tab with key
                                    otype = kc_compare_tab-otype
                                    objid = kc_compare_tab-objid.
              if sy-subrc = 0.
                zchbkrs_tab-flag_contrychange = 'X'.
                modify zchbkrs_tab index sy-tabix.
              else.
                zchbkrs_tab-otype = kc_compare_tab-otype.
                zchbkrs_tab-objid = kc_compare_tab-objid.
                zchbkrs_tab-flag_contrychange = 'X'.
                clear act_intgrat-pooltype.
                append zchbkrs_tab.
              endif.
            endif.
          endif.
        endloop.
        if kc_subrc ne 0.                                    "ANDCOOPER
          exit.                                              "ANDCOOPER
        endif.                                               "ANDCOOPER

* check which event has taken place and put it in act_intgrat
        read table zchbkrs_tab with key otype = kc_compare_tab-otype
                                   objid = kc_compare_tab-objid.

        if zchbkrs_tab-flag_chbkrs = 'X'.
          read table massn_tab with key semid = c_evccc.
        endif.

        if zchbkrs_tab-flag_contrychange = 'X'.
* in case of country change no massn in t77s0, only flag has to be set
          clear massn_tab-gsval.
        endif.

* check if entry is already in act_intgrat
        sort act_intgrat by pernr.
        read table act_intgrat with key pernr = kc_compare_tab-objid
                               binary search.

        if sy-subrc <> 0.
          clear act_intgrat-massg.
          clear act_intgrat-autoundo.
          clear act_intgrat-changetype.
          act_intgrat-pernr = kc_compare_tab-objid.
          act_intgrat-orgdat = kc_compare_tab-begda.
          act_intgrat-massn = massn_tab-gsval.
          act_intgrat-plvar = plvar.
          act_intgrat-otype = $plste.
          act_intgrat-objid = kc_compare_tab-plste.
          act_intgrat-aedtm = sy-datum.
          act_intgrat-uname = sy-uname.
          append act_intgrat.
        endif.
      endloop.

* person may only be once in act_intgrat to write down in t77int
      sort act_intgrat by pernr orgdat massn plvar otype objid.
      delete adjacent duplicates from act_intgrat
                                 comparing pernr orgdat massn plvar
                                           otype objid.

    else.
*   no message; extended integration is not active
      if no_msg is initial.
        message e195 with $kostl stc_tabelle1-objid
                          $pernr kc_compare_tab-objid.
      else.
        msg_tab_global-msgty = 'E'.
        msg_tab_global-msgid = '5A'.
        msg_tab_global-msgno = '195'.
        msg_tab_global-msgv1 = $kostl.
        msg_tab_global-msgv2 = stc_tabelle1-objid.
        msg_tab_global-msgv3 = $pernr.
        msg_tab_global-msgv4 = kc_compare_tab-objid.
        msg_tab_global-pernr = kc_compare_tab-objid.
        append msg_tab_global.
        kc_subrc = 1.                                        "ANDCOOPER
      endif.
    endif.
  endif.
  EXIT.
ENDENHANCEMENT.
