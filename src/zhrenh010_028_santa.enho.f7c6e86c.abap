"Name: \PR:ZRFFOM100\FO:MT100\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH010_028_SANTA.
* Sortieren des Datenbestandes unter Beachtung von Gut-/Lastschrift
* sort of extract considering incoming and outgoing payments.
  " 21.07.2017 JPM 5727 se comentariza para regresar version y pasar a PRO
*  DATA:
*        vup_len              TYPE i,
*        vup_waers(3)         TYPE c,
*        vup_auftr_geb_1(35),
*        vup_auftr_geb_2(35),
*        vup_auftr_geb_3(35),
*        vup_auftr_geb_4(35),
*        vup_zahl_empf_1(35),
*        vup_zahl_empf_2(35),
*        vup_zahl_empf_3(35),
*        vup_zahl_empf_4(35),
*        vup_lfdnr(8) TYPE n,
*        vup_filecnt  TYPE i,
*        vflg_unix(1) TYPE c,
*        v_open_fi(1) TYPE c.
*
*
**---------------------------------------------------------------------*
*  SORT BY
*    reguh-zbukr                        "paying company code
*    reguh-ubnks                        "country of house bank
*    reguh-ubnky                        "bank key (for sort)
*    reguh-ubnkl                        "bank number of house bank
*    reguh-rzawe                        "X - incoming payment
*    reguh-ubknt                        "account number at house bank
*    reguh-zbnks                        "country of payee's bank
*    reguh-zbnky                        "bank key (for sort)
*    reguh-zbnkl                        "bank number of payee's bank
*    reguh-zbnkn                        "account number of payee
*    reguh-lifnr                        "creditor number
*    reguh-kunnr                        "debitor number
*    reguh-empfg                        "payee is CPD / alternative payee
*    reguh-vblnr                        "payment document number
*    hlp_sortp1                         "sort field for single items
*    hlp_sortp2                         "sort field for single items
*    hlp_sortp3                         "sort field for single items
*    regup-belnr.                       "invoice document number
*
** Dateiformat bestimmen
*  IF t042ofi-formt IS INITIAL.
*    hlp_dtfor      = 'MT100'.
*    hlp_dtfor_long = 'MT100'.
*  ELSE.
*    hlp_dtfor      = t042ofi-formt.
*    hlp_dtfor_long = t042ofi-formt.
*  ENDIF.
*
** Falls kein TemSe-Eintrag und falls kein Dateiname angegeben, Namen
** der sequentiellen Files vorbelegen: DTAUS0.Datum.Uhrzeit.lfdNr
** If no file-name is specified and no name will be generated later
** (because of TemSe), a new name is generated here: DTAUS0.Date.Time.nn
*  IF par_unix NE space.
*    vflg_unix = 1.
*  ENDIF.
*  IF hlp_temse NA par_dtyp.            "Kein TemSe-Format / No TemSe
*    IF par_unix EQ space.              "kein Name   / unspecified name
*      par_unix    = hlp_dtfor.
*      par_unix+6  = '.'.
*      WRITE sy-datum TO par_unix+7(6) DDMMYY.
*      par_unix+13 = '.'.
*      par_unix+14 = sy-uzeit.
*      par_unix+20 = '.'.
*    ELSE.
*      IF par_cbxx IS INITIAL.          "Einzelzahlung
*        CLEAR vup_filecnt.
*        LOOP AT dta_filecnt.
*          vup_filecnt = vup_filecnt + dta_filecnt-anzahl.
*        ENDLOOP.
*        dta_filecnt-anzahl = vup_filecnt.
*      ELSE.                            "Sammelzahlung
*        DESCRIBE TABLE dta_filecnt LINES dta_filecnt-anzahl.
*      ENDIF.
*
*      CALL FUNCTION 'GET_SHORTKEY_FOR_FEBKO'
*           EXPORTING
*                i_tname             = 'MT100'
*                i_anznr             = dta_filecnt-anzahl
*           IMPORTING
*                e_kukey             = vup_lfdnr
*           EXCEPTIONS
*                febkey_update_error = 1.
*
*      vup_lfdnr = vup_lfdnr - dta_filecnt-anzahl.
*      IF sy-subrc = 1.
*        IF sy-batch EQ space.
*          MESSAGE a228 WITH 'FEBKEY'.
*        ELSE.
*          MESSAGE s228 WITH 'FEBKEY'.
*          STOP.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*  cnt_filenr = 0.
*
*  CALL FUNCTION 'NAMETAB_GET'
*       EXPORTING
*            tabname = 'DTAM100'
*       TABLES
*            nametab = nametab.
*
**----------------------------------------------------------------------*
** Abarbeiten der extrahierten Daten                                    *
** loop at extracted data                                               *
**----------------------------------------------------------------------*
*if T042OFI-FORMT = 'SANTANDER_TRA'.
*  SORT IT_REGUH_sant BY
*    zbukr                        "paying company code
*    ubnks                        "country of house bank
*    ubnky                        "bank key (for sort)
*    ubnkl                        "bank number of house bank
*    rzawe                        "X - incoming payment
*    ubknt                        "account number at house bank
*    zbnks                        "country of payee's bank
*    zbnky                        "bank key (for sort)
*    zbnkl                        "bank number of payee's bank
*    zbnkn                        "account number of payee
*    lifnr                        "creditor number
*    kunnr                        "debitor number
*    empfg                        "payee is CPD / alternative payee
*    vblnr.                       "payment document number
*
**  LOOP AT it_reguh_sant.
*  LOOP AT IT_REGUH_SANT.
**loop.
**      WHERE pernr eq it_reguh_sant-pernr and zbnky eq it_reguh_sant-zbnky.
*
**  read table IT_REGUH_sant
**    WITH KEY pernr = reguh-pernr
**             zbnky = reguh-zbnky.
**   if sy-subrc eq 0.
*
*    MOVE-CORRESPONDING IT_REGUH_SANT TO REGUH.
**   if reguh-pernr eq it_reguh_sant-pernr and reguh-zbnky eq it_reguh_sant-zbnky.
*
**-- Neuer zahlender Buchungskreis --------------------------------------
**-- new paying company code --------------------------------------------
*    AT NEW zbukr.
*
*      PERFORM buchungskreis_daten_lesen.
*
*    ENDAT.                             "AT NEW REGUH-ZBUKR
*
*
**-- Neue Hausbank ------------------------------------------------------
**-- new house bank -----------------------------------------------------
*    AT NEW ubnkl.
*
*      PERFORM hausbank_daten_lesen.
*      IF NOT par_cbxx IS INITIAL.
*        PERFORM zusatzfeld_fuellen USING *regut-dtkey 'D  '.
*        IF hlp_temse NA par_dtyp AND   "Kein TemSe-Format / No TemSe
*           vflg_unix NE space.          "kein Name   / unspecified name
*          PERFORM datei_oeffnen_1 USING vup_lfdnr.
*          vup_lfdnr = vup_lfdnr + 1.
*        ELSE.
*          PERFORM datei_oeffnen.
*        ENDIF.
*
**------ Prepare Open FI und User-Exit for multi payments
*        CLEAR dta_filecnt.
*        dta_filecnt-zbukr = reguh-zbukr.
*        dta_filecnt-ubnks = reguh-ubnks.
*        dta_filecnt-ubnkl = reguh-ubnkl.
*        READ TABLE dta_filecnt.
*        dtam100s-s00   = dta_filecnt-szbnkn.
*        dtam100s-s01   = dta_filecnt-svbetr.
*        dtam100s-s02   = dta_filecnt-anzahl.
*        dtam100s-s03   = hlp_resultat.
*        dtam100s-s04   = par_sbnk.     "sending bank of MT101
*        dtam100h-xcrlf_supp = space.
*
**       Open FI / BTE (multi payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive1 IS INITIAL.
*            REFRESH tab_sum_per_currency.
*            LOOP AT tab_sum_per_currency_ext
*                               WHERE zbukr EQ reguh-zbukr
*                                 AND ubnks EQ reguh-ubnks
*                                 AND ubnky EQ reguh-ubnky
*                                 and zbnky eq reguh-zbnky."CCV 5088
*              tab_sum_per_currency = tab_sum_per_currency_ext.
*              APPEND tab_sum_per_currency.
*              DELETE tab_sum_per_currency_ext.
*            ENDLOOP.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002010_P'
*                 EXPORTING
*                      i_format           = t042ofi-formt
*                      i_reguh            = reguh
*                      i_dtam100s         = dtam100s
*                      i_dtam100h         = dtam100h
*                      i_cbxx             = par_cbxx
*                 IMPORTING
*                      e_dtam100h         = dtam100h
*                 TABLES
*                      t_sum_per_currency = tab_sum_per_currency
*                 EXCEPTIONS
*                      no_add_on_found    = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit for header (multi payments)
*        PERFORM exit_901(rffoexit)
*                USING reguh
*                      dtam100s
*                      dtam100h
*                      par_cbxx
*                      up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100h-h01 IS INITIAL.
*            vup_len = strlen( dtam100h-h00 ).
*          ELSE.
*            vup_len = dtam100h-h01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100h-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100h-h00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100h-h00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100h.
*        ENDIF.
*
*      ENDIF.
*
**     Lesen des Default-Weisungsschlüssels der Hausbank
**     Read parameters in T012D
*      SELECT SINGLE * FROM t012d
*        WHERE bukrs EQ reguh-zbukr
*        AND   hbkid EQ reguh-hbkid.
*      IF sy-subrc NE 0.
*        CLEAR t012d.
*      ENDIF.
*
*      CLEAR sum_regut.
*
*    ENDAT.
*
*
**-- Neuer Zahlweg ------------------------------------------------------
**-- new payment method -------------------------------------------------
*    AT NEW rzawe.
*
*      PERFORM zahlweg_daten_lesen.
*
*    ENDAT.
*
*
**-- Neue Empfängerbank -------------------------------------------------
**-- new bank of payee --------------------------------------------------
*    AT NEW zbnkl.
*
*      PERFORM empfbank_daten_lesen.
*
*    ENDAT.
*
*
**-- Neue Kontonummer bei der Empfängerbank------------------------------
**-- new bank account number of payee -----------------------------------
*    AT NEW zbnkn.
*
*      hlp_zbnkn = reguh-zbnkn.
*
*    ENDAT.
*
*
**-- Neue Zahlungsbelegnummer -------------------------------------------
**-- new payment document number ----------------------------------------
*    AT NEW vblnr.
*
*      IF par_cbxx IS INITIAL.          "Einzelzahlung
*        PERFORM zusatzfeld_fuellen USING *regut-dtkey 'D  '.
*        IF hlp_temse NA par_dtyp AND   "Kein TemSe-Format / No TemSe
*           vflg_unix NE space.          "kein Name   / unspecified name
*          PERFORM datei_oeffnen_1 USING vup_lfdnr.
*          vup_lfdnr = vup_lfdnr + 1.
*        ELSE.
*          PERFORM datei_oeffnen.
*        ENDIF.
*        dtam100h-xcrlf_supp = space.
*
**------ Open FI / BTE and User-Exit for single payments
**       Update tab_sum_per_currency for single payments
*        REFRESH tab_sum_per_currency.
*        tab_sum_per_currency-waers = reguh-waers.
*        tab_sum_per_currency-rwbtr = reguh-rwbtr.
*        APPEND tab_sum_per_currency.
**       Update DTAM100S for single payments
*        dtam100s-s00 = reguh-zbnkn.
*        PERFORM dta_vorkomma(rffod__l) USING reguh-waers reguh-rwbtr.
*        dtam100s-s01 = spell-number.
*        dtam100s-s02 = 1.
*        dtam100s-s03 = hlp_resultat.
*        dtam100s-s04 = par_sbnk.       "Sending bank of MT101
*
**       Open-FI / BTE (single payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive1 IS INITIAL.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002010_P'
*                 EXPORTING
*                      i_format           = t042ofi-formt
*                      i_reguh            = reguh
*                      i_dtam100s         = dtam100s
*                      i_dtam100h         = dtam100h
*                      i_cbxx             = par_cbxx
*                 IMPORTING
*                      e_dtam100h         = dtam100h
*                 TABLES
*                      t_sum_per_currency = tab_sum_per_currency
*                 EXCEPTIONS
*                      no_add_on_found    = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit for header (single payments)
*        PERFORM exit_901(rffoexit)
*                USING reguh
*                      dtam100s
*                      dtam100h
*                      par_cbxx
*                      up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100h-h01 IS INITIAL.
*            vup_len = strlen( dtam100h-h00 ).
*          ELSE.
*            vup_len = dtam100h-h01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100h-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100h-h00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100h-h00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100h.
*        ENDIF.
*
*        CLEAR sum_regut.
*      ENDIF.
*
*      PERFORM zahlungs_daten_lesen.
*      PERFORM summenfelder_initialisieren.
*      PERFORM belegdaten_schreiben.
*      SET LANGUAGE hlp_sprache.        " Buchungskreis-/Empfängersprache
*      IF sy-subrc <> 0.
*        SET LANGUAGE sy-langu.         " Anmeldesprache
*      ENDIF.
*
**     Verwendungszweck auf Segmenttext untersuchen
**     examine whether note to payee has to be filled with segment text
*      flg_sgtxt = 0.
*      IF text-703 CS '&SGTXT'.
*        flg_sgtxt = 1.                 "Global für Segmenttext existiert
*      ENDIF.                           "global for segment text exists
*
**     Weisungsschlüssel lesen
**     Read instruction key
*      IF NOT ( t012d-dtaws IS INITIAL AND reguh-dtaws IS INITIAL ).
*        PERFORM weisungsschluessel_lesen.
*      ELSE.
*        CLEAR t015w.
*      ENDIF.
*
*      vup_auftr_geb_1  = regud-aust1.   "Name des Auftraggebers
*      IF regud-abstx EQ space.
*        vup_auftr_geb_2 = regud-aust2.
*        vup_auftr_geb_3 = regud-aust3.
*        vup_auftr_geb_4 = regud-austo.
*      ELSE.
*        vup_auftr_geb_2 = regud-austo.
*        vup_auftr_geb_3 = regud-abstx.
*        vup_auftr_geb_4 = regud-absor.
*      ENDIF.
*
*      vup_zahl_empf_1 = reguh-koinh.
*      IF reguh-koinh EQ reguh-znme1 AND
*         NOT reguh-znme2 IS INITIAL AND
*         hlp_laufk NE 'P'.
*        vup_zahl_empf_2 = reguh-znme2.
*      ELSE.
*        CLEAR vup_zahl_empf_2.
*      ENDIF.
*      vup_zahl_empf_3 = regud-zpfst.
*      vup_zahl_empf_4 = regud-zplor.
*      CLEAR up_wschl.
**     interne Tabelle DTA_MT100 initialisieren
**     initialize internal table DTA_MT100
*      PERFORM mt100_init.
*
**     Interne Tabelle DTA_MT100 füllen
**     fill internal table DTA_MT100
*      PERFORM get_value_date.   " Set reguh-valut, if initial
*      PERFORM isocode_umsetzen USING reguh-waers vup_waers.
*      PERFORM put_mt100 USING: '20'    reguh-vblnr     1,
*                               '32A'   reguh-valut     1,
*                               '32A'   vup_waers        2,
*                               '32A'   reguh-rwbtr     3,
*                               '50_1'  vup_auftr_geb_1  1,
*                               '50_2'  vup_auftr_geb_2  1,
*                               '50_3'  vup_auftr_geb_3  1,
*                               '50_4'  vup_auftr_geb_4  1,
*                               '53_1'  reguh-ubknt     1.
*      IF NOT reguh-zswif IS INITIAL.
*        PERFORM put_mt100 USING '57A' reguh-zswif 1.
*      ELSEIF NOT reguh-zbnkl IS INITIAL.
*        PERFORM put_mt100 USING '57A' reguh-zbnkl 2.
*      ELSE.
*        PERFORM put_mt100 USING: '57_1' bnka-banka 1,
*                                 '57_2' bnka-stras 1,
*                                 '57_3' bnka-ort01 1,
*                                 '57_4' bnka-provz 1.
*      ENDIF.
*      PERFORM put_mt100 USING: '59_1'  reguh-zbnkn     1,
*                               '59_2'  vup_zahl_empf_1  1,
*                               '59_3'  vup_zahl_empf_2  1,
*                               '59_4'  vup_zahl_empf_3  1,
*                               '59_5'  vup_zahl_empf_4  1,
*                               '71A'   t015w-dtkvs     1,
*                               '72_1'  t015w-dtws1     1,
*                               '72_2'  t015w-dtws2     1,
*                               '72_3'  t015w-dtws3     1,
*                               '72_4'  t015w-dtws4     1,
*                               '99'    '-'             1.
*
**     Fill DME fields for sender's and receiver's correspondent
**     and intermediary
*      CALL FUNCTION 'FI_GET_CORRESP_INTERMED_BANKS'
*           EXPORTING
*                i_reguh     = reguh
*                i_dtaformat = hlp_dtfor_long
*           TABLES
*                t_dtamt100  = dta_mt100.
*
*
**     Prüfung, ob Avishinweis erforderlich
**     check if advice note is necessary
*      IF flg_sgtxt = 1.
*        cnt_zeilen = reguh-rpost + reguh-rtext.
*      ELSE.
*        cnt_zeilen = reguh-rpost.
*      ENDIF.
*      CLEAR dta_zeilen.
*      REFRESH tab_dtam100v.
*      IF cnt_zeilen GT par_zeil.       "Avishinweis ausgeben
*                                       "print advice note
*        PERFORM dta_erweiterungsteil USING text-704.
*        PERFORM dta_erweiterungsteil USING text-705.
*        ADD 1 TO cnt_hinweise.
*        dtam100-xavis_req = 'X'.
*      ELSE.
*        dtam100-xavis_req = ' '.
*      ENDIF.
*
*    ENDAT.
*
*
**-- Verarbeitung der Einzelposten-Informationen ------------------------
**-- single item information --------------------------------------------
**loop.
**    AT daten.
**loop at daten.
**      v_index = reguh-vblnr.
**      READ TABLE daten index v_index.
**      IF sy-subrc eq 0.
*    LOOP AT it_regup into regup "CCV 21.10.2016 5088
*         where laufd = reguh-laufd
*           and laufi = reguh-laufi
*           and lifnr = reguh-lifnr
*           and vblnr = reguh-vblnr.
*
*       PERFORM einzelpostenfelder_fuellen.
*
**     Externe Belegnummer mit interner füllen, falls externe leer ist
**     fill external doc.no. with internal, if external is empty
*      IF regup-xblnr EQ space.
*        regup-xblnr = regup-belnr.
*      ENDIF.
*
**     Ausgabe der Einzelposten, falls kein Avishinweis augegeben wurde
**     single item information if no advice note
*      IF cnt_zeilen LE par_zeil.
*        IF hlp_laufk NA 'JP'           "keine Rechungsinfo bei HR und IS
*            AND regup-vertn EQ space.  "HR/IS: no invoice information
*          PERFORM dta_erweiterungsteil USING text-702.
*        ENDIF.
*        IF flg_sgtxt = 1 AND regup-sgtxt NE space.
*          PERFORM dta_erweiterungsteil USING text-703.
*        ENDIF.
*      ENDIF.
*
*      PERFORM summenfelder_fuellen.
*
**    ENDAT.
*    endloop.
**     ENDIF.
*
*
**-- Ende der Zahlungsbelegnummer ---------------------------------------
**-- end of payment document number -------------------------------------
*    AT END OF vblnr.
*
**---- Prepare Open FI and User-Exits
*      PERFORM fill_dtam100.
*      CLEAR dtam100-xcrlf_supp.
*      CLEAR dtam100-xchar_nrep.
*
**     Open FI / BTE (transaction record)
*      IF par_mofi NE space.
*        IF NOT t042ofi-xactive2 IS INITIAL.
*          CALL FUNCTION 'OPEN_FI_PERFORM_00002020_P'
*               EXPORTING
*                    i_format        = t042ofi-formt
*                    i_reguh         = reguh
*                    i_dtam100       = dtam100
*               IMPORTING
*                    e_dtam100       = dtam100
*               TABLES
*                    t_regup         = tab_regup
*                    t_dtam100v      = tab_dtam100v
*               EXCEPTIONS
*                    no_add_on_found = 1.
*          IF sy-subrc NE 0.
*            MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ELSE.
*            v_open_fi = 'X'.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
**     User-Exit (transaction record)
*      PERFORM exit_900(rffoexit)
*              TABLES tab_regup
*                     tab_dtam100v
*              USING  reguh
*                     dtam100
*                     up_usrex.
*      IF NOT up_usrex IS INITIAL OR    "modifiziert / modified by user
*         NOT v_open_fi IS INITIAL.
*         *regut-usrex+1(1) = up_usrex.
*        IF up_usrex EQ '1' OR up_usrex EQ '3' OR
*           NOT v_open_fi IS INITIAL.
*          PERFORM read_dtam100.
*        ENDIF.
*        IF up_usrex EQ '2' OR up_usrex EQ '3' OR
*           NOT v_open_fi IS INITIAL.
*          PERFORM read_dtam100v.
*        ENDIF.
*      ENDIF.
*
**     Sortierung nach Tag (Für Format MT101 nicht erwünscht)
*      IF t042ofi-formt <> 'MT101'.
*        SORT dta_mt100 BY tag.
*      ENDIF.
*
**     Kein Avis gefordert
*      IF dtam100-xavis_req IS INITIAL.
*        MOVE-CORRESPONDING reguh TO tab_kein_avis.
*        APPEND tab_kein_avis.
*      ENDIF.
*
**     Aufbereitung und Schreiben der Daten aus DTA_MT100
*      LOOP AT dta_mt100.
*        IF dtam100-xchar_nrep IS INITIAL.
*          PERFORM: dta_text_aufbereiten USING dta_mt100-value,
*                   mt100_gueltige_zeichen USING dta_mt100-value.
*        ENDIF.
*        IF dta_mt100-len IS INITIAL.
*          dta_mt100-len = strlen( dta_mt100-value ).
*        ENDIF.
*        IF  dta_mt100-maxlen gt 0
*        AND dta_mt100-len GT dta_mt100-maxlen.
**       maximum length is known (standard SWIFT fields only)
**       and field is too long
*          IF par_mofi = space
*          OR par_mofi = 'MT100'
*          OR par_mofi = 'MT101'.
*            dta_mt100-len = dta_mt100-maxlen.
*          ENDIF.
*        ENDIF.
*
*        IF dta_mt100-len GT 5 OR
*           dta_mt100-len GT 0 AND dta_mt100-value NP ':*:'.
*          IF NOT dtam100-xcrlf_supp IS INITIAL.
*            PERFORM store_on_file USING dta_mt100-value(dta_mt100-len).
*          ELSE.
*            PERFORM store_on_file USING:
*              dta_mt100-value(dta_mt100-len), hlp_crlf.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*      CLEAR: up_usrex, v_open_fi.
*
*      ADD reguh-rbetr TO sum_regut.
*
*      IF par_cbxx IS INITIAL.          "Einzelzahlung
*        dtam100t-xcrlf_supp = space.
*
**       Open FI / BTE (trailer for single payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive3 IS INITIAL.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002030_P'
*                 EXPORTING
*                      i_format        = t042ofi-formt
*                      i_reguh         = reguh
*                      i_dtam100s      = dtam100s
*                      i_dtam100t      = dtam100t
*                 IMPORTING
*                      e_dtam100t      = dtam100t
*                 EXCEPTIONS
*                      no_add_on_found = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit (trailer for single payments)
*        PERFORM exit_902(rffoexit)
*               TABLES tab_regup
*               USING  reguh
*                      dtam100s
*                      dtam100t
*                      par_cbxx
*                      up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modifiziert / modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex+2 = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100t-t01 IS INITIAL.
*            vup_len = strlen( dtam100t-t00 ).
*          ELSE.
*            vup_len = dtam100t-t01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100t-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100t-t00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100t-t00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100t.
*        ENDIF.
*
*        PERFORM datei_schliessen.
*      ENDIF.
*      SET LANGUAGE sy-langu.           " Anmeldesprache
*    ENDAT.
*
*    AT END OF ubnkl.
*      IF NOT par_cbxx IS INITIAL.      "mehrere Zahlungen
*        dtam100t-xcrlf_supp = space.
*
**       Open FI / BTE (trailer for multi payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive3 IS INITIAL.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002030_P'
*                 EXPORTING
*                      i_format        = t042ofi-formt
*                      i_reguh         = reguh
*                      i_dtam100s      = dtam100s
*                      i_dtam100t      = dtam100t
*                 IMPORTING
*                      e_dtam100t      = dtam100t
*                 EXCEPTIONS
*                      no_add_on_found = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit for trailer (trailer for multi payment)
*        PERFORM exit_902(rffoexit)
*                TABLES tab_regup
*                USING  reguh
*                       dtam100s
*                       dtam100t
*                       par_cbxx
*                       up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modifiziert / modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex+2 = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100t-t01 IS INITIAL.
*            vup_len = strlen( dtam100t-t00 ).
*          ELSE.
*            vup_len = dtam100t-t01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100t-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100t-t00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100t-t00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100t.
*        ENDIF.
*
*        PERFORM datei_schliessen.
*      ENDIF.
*    ENDAT.
*
*    AT END OF zbukr.
*    ENDAT.
**    endif.
**  endloop.
*  ENDLOOP.
*
*elseif  T042OFI-FORMT = 'HSBC_TRA'.
*    SORT IT_REGUH_hsbc BY
*    zbukr                        "paying company code
*    ubnks                        "country of house bank
*    ubnky                        "bank key (for sort)
*    ubnkl                        "bank number of house bank
*    rzawe                        "X - incoming payment
*    ubknt                        "account number at house bank
*    zbnks                        "country of payee's bank
*    zbnky                        "bank key (for sort)
*    zbnkl                        "bank number of payee's bank
*    zbnkn                        "account number of payee
*    lifnr                        "creditor number
*    kunnr                        "debitor number
*    empfg                        "payee is CPD / alternative payee
*    vblnr.                        "payment document number
*
*  LOOP AT it_reguh_hsbc .
**  LOOP.
*    MOVE-CORRESPONDING it_reguh_hsbc TO REGUH.
**   if reguh-pernr eq it_reguh_hsbc-pernr and reguh-zbnky eq it_reguh_hsbc-zbnky.
**  read table IT_REGUH_sant
**    WITH KEY pernr = reguh-pernr
**             zbnky = reguh-zbnky.
**   if sy-subrc eq 0.
**-- Neuer zahlender Buchungskreis --------------------------------------
**-- new paying company code --------------------------------------------
*    AT NEW zbukr.
*
*      PERFORM buchungskreis_daten_lesen.
*
*    ENDAT.                             "AT NEW REGUH-ZBUKR
*
*
**-- Neue Hausbank ------------------------------------------------------
**-- new house bank -----------------------------------------------------
*    AT NEW ubnkl.
*
*      PERFORM hausbank_daten_lesen.
*      IF NOT par_cbxx IS INITIAL.
*        PERFORM zusatzfeld_fuellen USING *regut-dtkey 'D  '.
*        IF hlp_temse NA par_dtyp AND   "Kein TemSe-Format / No TemSe
*           vflg_unix NE space.          "kein Name   / unspecified name
*          PERFORM datei_oeffnen_1 USING vup_lfdnr.
*          vup_lfdnr = vup_lfdnr + 1.
*        ELSE.
*          PERFORM datei_oeffnen.
*        ENDIF.
*
**------ Prepare Open FI und User-Exit for multi payments
*        CLEAR dta_filecnt.
*        dta_filecnt-zbukr = reguh-zbukr.
*        dta_filecnt-ubnks = reguh-ubnks.
*        dta_filecnt-ubnkl = reguh-ubnkl.
*        READ TABLE dta_filecnt.
*        dtam100s-s00   = dta_filecnt-szbnkn.
*        dtam100s-s01   = dta_filecnt-svbetr.
*        dtam100s-s02   = dta_filecnt-anzahl.
*        dtam100s-s03   = hlp_resultat.
*        dtam100s-s04   = par_sbnk.     "sending bank of MT101
*        dtam100h-xcrlf_supp = space.
*
**       Open FI / BTE (multi payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive1 IS INITIAL.
*            REFRESH tab_sum_per_currency.
*            LOOP AT tab_sum_per_currency_ext
*                               WHERE zbukr EQ reguh-zbukr
*                                 AND ubnks EQ reguh-ubnks
*                                 AND ubnky EQ reguh-ubnky
*                                 AND zbnky EQ reguh-zbnky.
*              tab_sum_per_currency = tab_sum_per_currency_ext.
*              APPEND tab_sum_per_currency.
*              DELETE tab_sum_per_currency_ext.
*            ENDLOOP.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002010_P'
*                 EXPORTING
*                      i_format           = t042ofi-formt
*                      i_reguh            = reguh
*                      i_dtam100s         = dtam100s
*                      i_dtam100h         = dtam100h
*                      i_cbxx             = par_cbxx
*                 IMPORTING
*                      e_dtam100h         = dtam100h
*                 TABLES
*                      t_sum_per_currency = tab_sum_per_currency
*                 EXCEPTIONS
*                      no_add_on_found    = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit for header (multi payments)
*        PERFORM exit_901(rffoexit)
*                USING reguh
*                      dtam100s
*                      dtam100h
*                      par_cbxx
*                      up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100h-h01 IS INITIAL.
*            vup_len = strlen( dtam100h-h00 ).
*          ELSE.
*            vup_len = dtam100h-h01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100h-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100h-h00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100h-h00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100h.
*        ENDIF.
*
*      ENDIF.
*
**     Lesen des Default-Weisungsschlüssels der Hausbank
**     Read parameters in T012D
*      SELECT SINGLE * FROM t012d
*        WHERE bukrs EQ reguh-zbukr
*        AND   hbkid EQ reguh-hbkid.
*      IF sy-subrc NE 0.
*        CLEAR t012d.
*      ENDIF.
*
*      CLEAR sum_regut.
*
*    ENDAT.
*
*
**-- Neuer Zahlweg ------------------------------------------------------
**-- new payment method -------------------------------------------------
*    AT NEW rzawe.
*
*      PERFORM zahlweg_daten_lesen.
*
*    ENDAT.
*
*
**-- Neue Empfängerbank -------------------------------------------------
**-- new bank of payee --------------------------------------------------
*    AT NEW zbnkl.
*
*      PERFORM empfbank_daten_lesen.
*
*    ENDAT.
*
*
**-- Neue Kontonummer bei der Empfängerbank------------------------------
**-- new bank account number of payee -----------------------------------
*    AT NEW zbnkn.
*
*      hlp_zbnkn = reguh-zbnkn.
*
*    ENDAT.
*
*
**-- Neue Zahlungsbelegnummer -------------------------------------------
**-- new payment document number ----------------------------------------
*    AT NEW vblnr.
*
*      IF par_cbxx IS INITIAL.          "Einzelzahlung
*        PERFORM zusatzfeld_fuellen USING *regut-dtkey 'D  '.
*        IF hlp_temse NA par_dtyp AND   "Kein TemSe-Format / No TemSe
*           vflg_unix NE space.          "kein Name   / unspecified name
*          PERFORM datei_oeffnen_1 USING vup_lfdnr.
*          vup_lfdnr = vup_lfdnr + 1.
*        ELSE.
*          PERFORM datei_oeffnen.
*        ENDIF.
*        dtam100h-xcrlf_supp = space.
*
**------ Open FI / BTE and User-Exit for single payments
**       Update tab_sum_per_currency for single payments
*        REFRESH tab_sum_per_currency.
*        tab_sum_per_currency-waers = reguh-waers.
*        tab_sum_per_currency-rwbtr = reguh-rwbtr.
*        APPEND tab_sum_per_currency.
**       Update DTAM100S for single payments
*        dtam100s-s00 = reguh-zbnkn.
*        PERFORM dta_vorkomma(rffod__l) USING reguh-waers reguh-rwbtr.
*        dtam100s-s01 = spell-number.
*        dtam100s-s02 = 1.
*        dtam100s-s03 = hlp_resultat.
*        dtam100s-s04 = par_sbnk.       "Sending bank of MT101
*
**       Open-FI / BTE (single payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive1 IS INITIAL.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002010_P'
*                 EXPORTING
*                      i_format           = t042ofi-formt
*                      i_reguh            = reguh
*                      i_dtam100s         = dtam100s
*                      i_dtam100h         = dtam100h
*                      i_cbxx             = par_cbxx
*                 IMPORTING
*                      e_dtam100h         = dtam100h
*                 TABLES
*                      t_sum_per_currency = tab_sum_per_currency
*                 EXCEPTIONS
*                      no_add_on_found    = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit for header (single payments)
*        PERFORM exit_901(rffoexit)
*                USING reguh
*                      dtam100s
*                      dtam100h
*                      par_cbxx
*                      up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100h-h01 IS INITIAL.
*            vup_len = strlen( dtam100h-h00 ).
*          ELSE.
*            vup_len = dtam100h-h01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100h-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100h-h00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100h-h00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100h.
*        ENDIF.
*
*        CLEAR sum_regut.
*      ENDIF.
*
*      PERFORM zahlungs_daten_lesen.
*      PERFORM summenfelder_initialisieren.
*      PERFORM belegdaten_schreiben.
*      SET LANGUAGE hlp_sprache.        " Buchungskreis-/Empfängersprache
*      IF sy-subrc <> 0.
*        SET LANGUAGE sy-langu.         " Anmeldesprache
*      ENDIF.
*
**     Verwendungszweck auf Segmenttext untersuchen
**     examine whether note to payee has to be filled with segment text
*      flg_sgtxt = 0.
*      IF text-703 CS '&SGTXT'.
*        flg_sgtxt = 1.                 "Global für Segmenttext existiert
*      ENDIF.                           "global for segment text exists
*
**     Weisungsschlüssel lesen
**     Read instruction key
*      IF NOT ( t012d-dtaws IS INITIAL AND reguh-dtaws IS INITIAL ).
*        PERFORM weisungsschluessel_lesen.
*      ELSE.
*        CLEAR t015w.
*      ENDIF.
*
*      vup_auftr_geb_1  = regud-aust1.   "Name des Auftraggebers
*      IF regud-abstx EQ space.
*        vup_auftr_geb_2 = regud-aust2.
*        vup_auftr_geb_3 = regud-aust3.
*        vup_auftr_geb_4 = regud-austo.
*      ELSE.
*        vup_auftr_geb_2 = regud-austo.
*        vup_auftr_geb_3 = regud-abstx.
*        vup_auftr_geb_4 = regud-absor.
*      ENDIF.
*
*      vup_zahl_empf_1 = reguh-koinh.
*      IF reguh-koinh EQ reguh-znme1 AND
*         NOT reguh-znme2 IS INITIAL AND
*         hlp_laufk NE 'P'.
*        vup_zahl_empf_2 = reguh-znme2.
*      ELSE.
*        CLEAR vup_zahl_empf_2.
*      ENDIF.
*      vup_zahl_empf_3 = regud-zpfst.
*      vup_zahl_empf_4 = regud-zplor.
*      CLEAR up_wschl.
**     interne Tabelle DTA_MT100 initialisieren
**     initialize internal table DTA_MT100
*      PERFORM mt100_init.
*
**     Interne Tabelle DTA_MT100 füllen
**     fill internal table DTA_MT100
*      PERFORM get_value_date.   " Set reguh-valut, if initial
*      PERFORM isocode_umsetzen USING reguh-waers vup_waers.
*      PERFORM put_mt100 USING: '20'    reguh-vblnr     1,
*                               '32A'   reguh-valut     1,
*                               '32A'   vup_waers        2,
*                               '32A'   reguh-rwbtr     3,
*                               '50_1'  vup_auftr_geb_1  1,
*                               '50_2'  vup_auftr_geb_2  1,
*                               '50_3'  vup_auftr_geb_3  1,
*                               '50_4'  vup_auftr_geb_4  1,
*                               '53_1'  reguh-ubknt     1.
*      IF NOT reguh-zswif IS INITIAL.
*        PERFORM put_mt100 USING '57A' reguh-zswif 1.
*      ELSEIF NOT reguh-zbnkl IS INITIAL.
*        PERFORM put_mt100 USING '57A' reguh-zbnkl 2.
*      ELSE.
*        PERFORM put_mt100 USING: '57_1' bnka-banka 1,
*                                 '57_2' bnka-stras 1,
*                                 '57_3' bnka-ort01 1,
*                                 '57_4' bnka-provz 1.
*      ENDIF.
*      PERFORM put_mt100 USING: '59_1'  reguh-zbnkn     1,
*                               '59_2'  vup_zahl_empf_1  1,
*                               '59_3'  vup_zahl_empf_2  1,
*                               '59_4'  vup_zahl_empf_3  1,
*                               '59_5'  vup_zahl_empf_4  1,
*                               '71A'   t015w-dtkvs     1,
*                               '72_1'  t015w-dtws1     1,
*                               '72_2'  t015w-dtws2     1,
*                               '72_3'  t015w-dtws3     1,
*                               '72_4'  t015w-dtws4     1,
*                               '99'    '-'             1.
*
**     Fill DME fields for sender's and receiver's correspondent
**     and intermediary
*      CALL FUNCTION 'FI_GET_CORRESP_INTERMED_BANKS'
*           EXPORTING
*                i_reguh     = reguh
*                i_dtaformat = hlp_dtfor_long
*           TABLES
*                t_dtamt100  = dta_mt100.
*
*
**     Prüfung, ob Avishinweis erforderlich
**     check if advice note is necessary
*      IF flg_sgtxt = 1.
*        cnt_zeilen = reguh-rpost + reguh-rtext.
*      ELSE.
*        cnt_zeilen = reguh-rpost.
*      ENDIF.
*      CLEAR dta_zeilen.
*      REFRESH tab_dtam100v.
*      IF cnt_zeilen GT par_zeil.       "Avishinweis ausgeben
*                                       "print advice note
*        PERFORM dta_erweiterungsteil USING text-704.
*        PERFORM dta_erweiterungsteil USING text-705.
*        ADD 1 TO cnt_hinweise.
*        dtam100-xavis_req = 'X'.
*      ELSE.
*        dtam100-xavis_req = ' '.
*      ENDIF.
*
*    ENDAT.
*
*
**-- Verarbeitung der Einzelposten-Informationen ------------------------
**-- single item information --------------------------------------------
**loop.
**    AT daten.
**LOOP AT daten..
**      v_index = reguh-vblnr.
**      READ TABLE daten index v_index.
**      IF sy-subrc eq 0.
*    LOOP AT it_regup into regup "CCV 21.10.2016 5088
*         where laufd = reguh-laufd
*           and laufi = reguh-laufi
*           and lifnr = reguh-lifnr
*           and vblnr = reguh-vblnr.
*
*      PERFORM einzelpostenfelder_fuellen.
*
**     Externe Belegnummer mit interner füllen, falls externe leer ist
**     fill external doc.no. with internal, if external is empty
*      IF regup-xblnr EQ space.
*        regup-xblnr = regup-belnr.
*      ENDIF.
*
**     Ausgabe der Einzelposten, falls kein Avishinweis augegeben wurde
**     single item information if no advice note
*      IF cnt_zeilen LE par_zeil.
*        IF hlp_laufk NA 'JP'           "keine Rechungsinfo bei HR und IS
*            AND regup-vertn EQ space.  "HR/IS: no invoice information
*          PERFORM dta_erweiterungsteil USING text-702.
*        ENDIF.
*        IF flg_sgtxt = 1 AND regup-sgtxt NE space.
*          PERFORM dta_erweiterungsteil USING text-703.
*        ENDIF.
*      ENDIF.
*
*      PERFORM summenfelder_fuellen.
*
**    ENDAT.
*ENDLOOP.
**endif.
*
**-- Ende der Zahlungsbelegnummer ---------------------------------------
**-- end of payment document number -------------------------------------
*    AT END OF vblnr.
*
**---- Prepare Open FI and User-Exits
*      PERFORM fill_dtam100.
*      CLEAR dtam100-xcrlf_supp.
*      CLEAR dtam100-xchar_nrep.
*
**     Open FI / BTE (transaction record)
*      IF par_mofi NE space.
*        IF NOT t042ofi-xactive2 IS INITIAL.
*          CALL FUNCTION 'OPEN_FI_PERFORM_00002020_P'
*               EXPORTING
*                    i_format        = t042ofi-formt
*                    i_reguh         = reguh
*                    i_dtam100       = dtam100
*               IMPORTING
*                    e_dtam100       = dtam100
*               TABLES
*                    t_regup         = tab_regup
*                    t_dtam100v      = tab_dtam100v
*               EXCEPTIONS
*                    no_add_on_found = 1.
*          IF sy-subrc NE 0.
*            MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ELSE.
*            v_open_fi = 'X'.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
**     User-Exit (transaction record)
*      PERFORM exit_900(rffoexit)
*              TABLES tab_regup
*                     tab_dtam100v
*              USING  reguh
*                     dtam100
*                     up_usrex.
*      IF NOT up_usrex IS INITIAL OR    "modifiziert / modified by user
*         NOT v_open_fi IS INITIAL.
*         *regut-usrex+1(1) = up_usrex.
*        IF up_usrex EQ '1' OR up_usrex EQ '3' OR
*           NOT v_open_fi IS INITIAL.
*          PERFORM read_dtam100.
*        ENDIF.
*        IF up_usrex EQ '2' OR up_usrex EQ '3' OR
*           NOT v_open_fi IS INITIAL.
*          PERFORM read_dtam100v.
*        ENDIF.
*      ENDIF.
*
**     Sortierung nach Tag (Für Format MT101 nicht erwünscht)
*      IF t042ofi-formt <> 'MT101'.
*        SORT dta_mt100 BY tag.
*      ENDIF.
*
**     Kein Avis gefordert
*      IF dtam100-xavis_req IS INITIAL.
*        MOVE-CORRESPONDING reguh TO tab_kein_avis.
*        APPEND tab_kein_avis.
*      ENDIF.
*
**     Aufbereitung und Schreiben der Daten aus DTA_MT100
*      LOOP AT dta_mt100.
*        IF dtam100-xchar_nrep IS INITIAL.
*          PERFORM: dta_text_aufbereiten USING dta_mt100-value,
*                   mt100_gueltige_zeichen USING dta_mt100-value.
*        ENDIF.
*        IF dta_mt100-len IS INITIAL.
*          dta_mt100-len = strlen( dta_mt100-value ).
*        ENDIF.
*        IF  dta_mt100-maxlen gt 0
*        AND dta_mt100-len GT dta_mt100-maxlen.
**       maximum length is known (standard SWIFT fields only)
**       and field is too long
*          IF par_mofi = space
*          OR par_mofi = 'MT100'
*          OR par_mofi = 'MT101'.
*            dta_mt100-len = dta_mt100-maxlen.
*          ENDIF.
*        ENDIF.
*
*        IF dta_mt100-len GT 5 OR
*           dta_mt100-len GT 0 AND dta_mt100-value NP ':*:'.
*          IF NOT dtam100-xcrlf_supp IS INITIAL.
*            PERFORM store_on_file USING dta_mt100-value(dta_mt100-len).
*          ELSE.
*            PERFORM store_on_file USING:
*              dta_mt100-value(dta_mt100-len), hlp_crlf.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*      CLEAR: up_usrex, v_open_fi.
*
*      ADD reguh-rbetr TO sum_regut.
*
*      IF par_cbxx IS INITIAL.          "Einzelzahlung
*        dtam100t-xcrlf_supp = space.
*
**       Open FI / BTE (trailer for single payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive3 IS INITIAL.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002030_P'
*                 EXPORTING
*                      i_format        = t042ofi-formt
*                      i_reguh         = reguh
*                      i_dtam100s      = dtam100s
*                      i_dtam100t      = dtam100t
*                 IMPORTING
*                      e_dtam100t      = dtam100t
*                 EXCEPTIONS
*                      no_add_on_found = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit (trailer for single payments)
*        PERFORM exit_902(rffoexit)
*               TABLES tab_regup
*               USING  reguh
*                      dtam100s
*                      dtam100t
*                      par_cbxx
*                      up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modifiziert / modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex+2 = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100t-t01 IS INITIAL.
*            vup_len = strlen( dtam100t-t00 ).
*          ELSE.
*            vup_len = dtam100t-t01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100t-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100t-t00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100t-t00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100t.
*        ENDIF.
*
*        PERFORM datei_schliessen.
*      ENDIF.
*      SET LANGUAGE sy-langu.           " Anmeldesprache
*    ENDAT.
*
*    AT END OF ubnkl.
*      IF NOT par_cbxx IS INITIAL.      "mehrere Zahlungen
*        dtam100t-xcrlf_supp = space.
*
**       Open FI / BTE (trailer for multi payments)
*        IF par_mofi NE space.
*          IF NOT t042ofi-xactive3 IS INITIAL.
*            CALL FUNCTION 'OPEN_FI_PERFORM_00002030_P'
*                 EXPORTING
*                      i_format        = t042ofi-formt
*                      i_reguh         = reguh
*                      i_dtam100s      = dtam100s
*                      i_dtam100t      = dtam100t
*                 IMPORTING
*                      e_dtam100t      = dtam100t
*                 EXCEPTIONS
*                      no_add_on_found = 1.
*            IF sy-subrc NE 0.
*              MESSAGE ID sy-msgid TYPE 'S'  NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            ELSE.
*              v_open_fi = 'X'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
**       User-Exit for trailer (trailer for multi payment)
*        PERFORM exit_902(rffoexit)
*                TABLES tab_regup
*                USING  reguh
*                       dtam100s
*                       dtam100t
*                       par_cbxx
*                       up_usrex.
*        IF NOT up_usrex IS INITIAL OR  "modifiziert / modified by user
*           NOT v_open_fi IS INITIAL.
*           *regut-usrex+2 = up_usrex.
*          CLEAR: up_usrex, v_open_fi.
*          IF dtam100t-t01 IS INITIAL.
*            vup_len = strlen( dtam100t-t00 ).
*          ELSE.
*            vup_len = dtam100t-t01.
*          ENDIF.
*          IF vup_len GT 0.
*            IF NOT dtam100t-xcrlf_supp IS INITIAL.
*              PERFORM store_on_file USING dtam100t-t00(vup_len).
*            ELSE.
*              PERFORM store_on_file USING:
*                      dtam100t-t00(vup_len), hlp_crlf.
*            ENDIF.
*          ENDIF.
*          CLEAR dtam100t.
*        ENDIF.
*
*        PERFORM datei_schliessen.
*      ENDIF.
*    ENDAT.
*
*    AT END OF zbukr.
*    ENDAT.
**    endif.
**  endloop.
*  ENDLOOP.
*endif.
*
*  exit.




ENDENHANCEMENT.
