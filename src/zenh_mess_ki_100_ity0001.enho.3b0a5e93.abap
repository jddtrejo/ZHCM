"Name: \PR:MP000100\FO:CHECK_PLAN_INPUT\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_MESS_KI_100_ITY0001.
* 31.08.2016 JPM 4971 implementacion para mensaje KI 100 Marcar como WARNING solo para
* 31.08.2016 JPM 4971 sociedad configurada en TVARV parametro ZHCMCONSTANTE_MESSEGEKI100
  data: lvi_datum like p0001-begda.
  data: lvi_key like pskey.
  data: lv_endda like p0001-endda.                           "YSFN375504
  data: lv_begda like p0001-begda.                           "YSFN375504
  data: lvno_plans_chan.                                    "YSFN375504
  data: lsv_current_plans type hri_position_tab.            "MELN1152988
  DATA  lvv_tabix TYPE sytabix.                             "SERN1309695
  CHECK plog-active EQ 0.
*------------- begin -------- XFYAHRK040220 --------------------------
  perform re77s0(mstt77s0) using 'PLOGI' 'BINPT' plogi_binpt binpt_subrc
  .
  "VWMBINPT
* check sy-binpt eq space.                                "VWMBINPT
  check ( sy-binpt eq space or plogi_binpt ne space ).    "VWMBINPT
**if fcode eq save.                                      "XFYAHRK055007
* IF FCODE = SAVE OR FCODE = 'UPDL'.      "XFYAHRK055007    "YSFN426915
  if fcode = save or fcode = 'UPDL' or                      "YSFN426915
   ( pspar-supdg ne space and pspar-dmsnr > 0 and fcode eq space ). "6915
    if psyst-ioper eq insert or psyst-ioper eq copy or
       psyst-ioper eq delete or psyst-ioper eq modify.

      clear postab. refresh postab.
      describe table new_ass_postab lines numpos.
      if numpos gt 0.                  "Zuordn.sollen angelegt werden
*
        loop at new_ass_postab.
*--------- begin --------- XFYAHRK058132 ---------------------------
          if new_ass_postab-otype = ot_position and
             new_ass_postab-objid = p0001-plans and
             new_ass_postab-opera(3) = 'INS'.
            if new_ass_postab-prozt <> pprhpr-prozt.
*             percentage is changed AFTER calling the assignm.screen
              new_ass_postab-prozt = pprhpr-prozt.
              modify new_ass_postab.
            endif.
          endif.
*--------- end ----------- XFYAHRK058132 ---------------------------
          if new_ass_postab-opera = 'LIS'.
            read table old_postab
                       with key otype = new_ass_postab-otype
                                objid = new_ass_postab-objid
                                begda = new_ass_postab-begda.
            if sy-subrc = 0.
              new_ass_postab-endda = old_postab-endda.
              modify new_ass_postab.
            endif.
          endif.
        endloop.
*
        call function 'HR_CONVERT_OPERA_TO_CHECK'
          exporting
            reference_date    = p0001-begda
            reference_enddate = p0001-endda "Note 0411663 STRO
          tables
            position_action   = new_ass_postab
            position_opera    = posdistab.

        loop at posdistab.
          move-corresponding posdistab to postab.
          if postab-otype eq space.
            postab-otype = ot_position.
          endif.
          append postab.
        endloop.
      elseif ( p0001-plans is initial or p0001-plans eq plan_default )
         and not p0001-orgeh is initial and psyst-ioper <> delete.
*         assignment to an orgunit
        postab-otype = ot_orgunit.
        postab-objid = p0001-orgeh.
        clear postab-prozt.
        postab-begda = p0001-begda.
        postab-endda = p0001-endda.
        postab-opera = 'INSN'.         "INSert New
        append postab.
*             Planstellen für den gesamten Zeitraum lesen
        clear get_position_tab. refresh get_position_tab.
        call function 'RH_GET_POSITION_TAB'
          exporting
            getperson     = p0001-pernr
            getbegda      = p0001-begda
            getendda      = p0001-endda
            bypass_buffer = 'X'                  "N1832575
          tables
            position_tab  = get_position_tab
          exceptions
            nothing_found = 1
            others        = 2.

        loop at get_position_tab.
**************** begin of YSFN37504 ************************************
*         if get_position_tab-begda < p0001-begda.
*           postab = get_position_tab.
*           postab-opera = 'DEL '.
*           append postab.
*           postab-endda = p0001-begda - 1.
*           postab-opera = 'INSO'.
*            append postab.
*          elseif get_position_tab-begda ge p0001-begda.
*            postab = get_position_tab.
*            postab-opera = 'DEL '.
*            append postab.
*          endif.
          postab = get_position_tab.
          postab-opera = 'DEL '.
          append postab.

          if get_position_tab-begda < p0001-begda.
            postab = get_position_tab.
            postab-endda = p0001-begda - 1.
            postab-opera = 'INSO'.
            append postab.
          endif.
          if get_position_tab-endda > p0001-endda.
            postab = get_position_tab.
            postab-begda = p0001-endda + 1.
            postab-opera = 'INSO'.
            append postab.
          endif.
*************** end of YSFN37504 **************************************
        endloop.
*------------------ begin ------- XFYAHRK055007 -------------------
      elseif ( p0001-plans is initial or p0001-plans eq plan_default )
         and p0001-orgeh is initial and psyst-ioper <> delete.
*         no assignment -> default position
        clear get_position_tab. refresh get_position_tab.
        call function 'RH_GET_POSITION_TAB'
          exporting
            getperson     = p0001-pernr
            getbegda      = p0001-begda
            getendda      = p0001-endda
            bypass_buffer = 'X'                  "N1832575
          tables
            position_tab  = get_position_tab
          exceptions
            nothing_found = 1
            others        = 2.

        loop at get_position_tab.
**************** begin of YSFN37504 ************************************
*        if get_position_tab-begda < p0001-begda.
*           postab = get_position_tab.
*           postab-opera = 'DEL '.
*           append postab.
*           postab-endda = p0001-begda - 1.
*           postab-opera = 'INSO'.
*           append postab.
*         elseif get_position_tab-begda ge p0001-begda.
*           postab = get_position_tab.
*           postab-opera = 'DEL '.
*           append postab.
*         endif.
          postab = get_position_tab.
          postab-opera = 'DEL '.
          append postab.

          if get_position_tab-begda < p0001-begda.
            postab = get_position_tab.
            postab-endda = p0001-begda - 1.
            postab-opera = 'INSO'.
            append postab.
          endif.
          if get_position_tab-endda > p0001-endda.
            postab = get_position_tab.
            postab-begda = p0001-endda + 1.
            postab-opera = 'INSO'.
            append postab.
          endif.
*************** end of YSFN37504 **************************************
        endloop.
*------------------ end - ----------- XFYAHRK055007 -------------------
      elseif ( not p0001-plans is initial and
                 p0001-plans ne plan_default ) OR ( p0001-plans EQ plan_default AND psyst-ioper EQ delete ).
* Note 2057868: Correctly create POSTAB even if default position.
*       no assignment
*-- ANDPH9K003496 -----------------------------------------------------*
* Für die Fälle psyst-ioper = delete oder insert oder modify wird die
* postab gefüllt. Diese wird später dem FB update_org_structure
* übergeben, der dann die Planstellenzuordnung gemäß dieser Tabelle ins
* OM überträgt. Wichtig ist, daß auch Planstellenzuordnungen, die sich
* nicht verändern übergeben werden (mit OPERA = 'HOLD'). Nur dann kann
* im update_org_structure ermittelt werden, welche Planstellen im IT1
* angezeigt wird und ob der IT1 evtl. weitere Splits bekommt.

        data: v_pred_endda like p0001-endda,
              lget_position_tab2 like hri_position_tab occurs 0
                                        with header line,
              lv_flag type flag,
              vsave_tabix like sy-tabix,
              lvpostab_buf like hri_position_tab occurs 0 with
                                               header line,
              lvold_pernr like p0001,
              lvdelete_index like sy-tabix,
              lvmin_date like sy-datum,
              lvmax_date like sy-datum,
              lvvpostab_buf_begda_minus_1 like sy-datum,    "ANDR99K000146
              lvvpostab_buf_endda_plus_1 like sy-datum,     "ANDR99K000146
              vlines_count type i.                        "ANDR99K000146

        data: begin of ltold_it1 occurs 0.
                include structure p0001.
        data: end of ltold_it1.
        "ANDPH9K010026
        data: ltmes_tab like HRRHAD_MSG occurs 2 with header line,
              vcheck_subrc like sy-subrc.

        data: lvobject_begda like p0001-begda,                "YSFN384099
              lvobject_endda like p0001-endda.                "YSFN384099

        case psyst-ioper.
          when delete.
            v_pred_endda = p0001-begda - 1.
*           Vorgänger-IT1 lesen wegen Planstelle und Zeitraum
*   hier evtl direkter select auf die PA0001 ???
            call function 'HR_INITIALIZE_BUFFER'
              exporting
                tclas = 'A'
                pernr = p0001-pernr.
*
            call function 'HR_READ_INFOTYPE'
              exporting
                pernr           = p0001-pernr
                infty           = '0001'
                begda           = v_pred_endda
                endda           = v_pred_endda
              tables
                infty_tab       = ltold_it1
              exceptions
                infty_not_found = 1
                others          = 2.
*
            if sy-subrc <> 0.
              clear postab.
              refresh postab.
            else.
              describe table ltold_it1 lines vlines_count.
              if vlines_count > 0.                           "gleich 1
                read table ltold_it1 index 1.
                lvmin_date = ltold_it1-begda.
              endif.
              lvmax_date = p0001-endda.
*             Planstellen für den gesamten Zeitraum lesen
              call function 'RH_GET_POSITION_TAB'
                exporting
                  getperson     = p0001-pernr
                  getbegda      = lvmin_date
                  getendda      = lvmax_date
                  bypass_buffer = 'X'                  "N1832575
                tables
                  position_tab  = lget_position_tab2
                exceptions
                  nothing_found = 1
                  others        = 2.
*
              if sy-subrc <> 0.
                clear postab.
                refresh postab.
                clear lget_position_tab2.
                refresh lget_position_tab2.
              endif.
*             Prozentsatz der bestehenden Verknüpfung nachlesen
              loop at lget_position_tab2
                      where otype = ot_position
                      and   objid = ltold_it1-plans
                      and   begda le ltold_it1-begda
                      and   endda ge ltold_it1-endda.
                vsave_tabix = sy-tabix.
* Zeile in lget_position_tab2, in der der Vorgänger ist
                exit.
              endloop.
*
              if ltold_it1-plans = p0001-plans and
                 lget_position_tab2-prozt = pprhpr-prozt.
*               Planstelle Vorgänger-IT1 und zu löschender IT1 sind
*               gleich. Keine Verknüpfungen verändern -> alle Einträge
*               mit HOLD !!!
                loop at lget_position_tab2.
                  postab = lget_position_tab2.
                  postab-opera = 'HOLD'.
                  append postab.
                endloop.
              else.
*               Planstelle Vorgänger-IT1 und zu löschender IT1 sind
*               verschieden -> Verknüpfung zu Planstelle im zu lö.
*               IT1 löschen und die zur Planstelle im Vörganger-IT1
*               verlängern.
                loop at lget_position_tab2.
                  if lget_position_tab2-otype = ot_position
                     and lget_position_tab2-objid = p0001-plans
                     and lget_position_tab2-begda le p0001-begda
                     and lget_position_tab2-endda ge p0001-endda.
                    postab = lget_position_tab2.
*                   Verknüpfung zu Planstelle nur im Zeitr. "YSFN590384
*                   des zu löschenden IT1 löschen..         "YSFN590384
                    postab-begda = p0001-begda.             "YSFN590384
                    postab-endda = p0001-endda.             "YSFN590384
                    postab-opera = 'DEL '.
                    append postab.
                  elseif lget_position_tab2-otype = ot_position
                         and lget_position_tab2-objid = ltold_it1-plans
                         and lget_position_tab2-begda le ltold_it1-begda
                         and lget_position_tab2-endda ge ltold_it1-endda.
                    if lget_position_tab2-endda ge p0001-endda.
*                     Es besteht schon eine Verknüpfung, wie sie
*                     angelegt werden soll -> Diese behalten -> HOLD.
                      postab = lget_position_tab2.
                      postab-opera = 'HOLD'.
                      append postab.
                    else.
************** begin of deactivating YSFN384099 ************************
*                     Verknüpfung verlängern -> DEL, INSO
*                     postab = lget_position_tab2.
*                     postab-opera = 'DEL '.
*                     append postab.
*                     postab-endda = p0001-endda.
*                     postab-opera = 'INSO'.
*                     append postab.
*                   endif.
************** end of deactivating YSFN384099 **************************
************** begin of inserting YSFN384099 ***************************
* Lesen des Gültigkeitszeitraumes der Planstelle.
                      call function 'RH_READ_OBJECT'
                        exporting
                          plvar     = planvar
*                                  OTYPE     = OT_POSITION  "MELN1001919
                                  otype     = ltold_it1-otype "MELN1001919
                          objid     = ltold_it1-plans
                          istat     = '1'
                          ointerval = 'X'
                        importing
                          obeg      = lvobject_begda
                          oend      = lvobject_endda
                        exceptions
                          not_found = 1
                          others    = 2.
                      if sy-subrc <> 0.
                        postab = lget_position_tab2.
                        postab-opera = 'DEL'.
                        append postab.
                        continue.
                      elseif sy-subrc = 0.
                        if not ( lvobject_begda le p0001-begda )
                           or not ( lvobject_endda ge p0001-endda ).
* Gültigkeitszeitraum der Planstelle außerhalb es IT 1 Satzes
* dann postab mit drei Sätzen füllen:
* 1. Satz alte Planstelle mit OPERA = DEL
* 2. Satz alte Planstellemit endda =  lvobject_endda OPERA = INSO und

                          postab = lget_position_tab2.
                          postab-opera = 'DEL '.
                          append postab.
                          postab-endda = lvobject_endda.
                          postab-opera = 'INSO'.
                          append postab.
                        else.
*                     Verknüpfung verlängern -> DEL, INSO
                          postab = lget_position_tab2.
                          postab-opera = 'DEL '.
                          append postab.
                          postab-endda = p0001-endda.
                          postab-opera = 'INSO'.
                          append postab.
                        endif.
                      endif.
                    endif.
************** end of inserting YSFN384099 *****************************
                  else.
*                    Verknüpfungen zu Planstellen, die nicht im IT1
*                    stehen erhalten -> HOLD
                    postab = lget_position_tab2.
                    postab-opera = 'HOLD'.
                    append postab.
                  endif.
                endloop.
              endif.
            endif.
*         when insert.                       "XFYL9CK005900 "YSFN515507
*           postab-otype = ot_position.      "XFYL9CK005900 "YSFN515507
*           postab-objid = p0001-plans.      "XFYL9CK005900 "YSFN515507
*           postab-prozt = pprhpr-prozt.     "XFYL9CK005900 "YSFN515507
*           postab-begda = p0001-begda.      "XFYL9CK005900 "YSFN515507
*           postab-endda = p0001-endda.      "XFYL9CK005900 "YSFN515507
*           postab-opera = 'INSN'."INSert New"XFYL9CK005900 "YSFN515507
*           append postab.                   "XFYL9CK005900 "YSFN515507
*         when copy or modify.                       "XWSL9CK012678
*********************** begin of YSFN375504 ****************************
          when modify.
            if pskey-begda < p0001-begda.
              lv_begda = pskey-begda - 1.
            else.
              lv_begda = p0001-begda.
            endif.

            lv_endda = p0001-endda.

            call function 'HR_INITIALIZE_BUFFER'
              exporting
                tclas = 'A'
                pernr = p0001-pernr.
*
* alle betroffenen IT0001 records lesen
            call function 'HR_READ_INFOTYPE'
              exporting
                pernr           = p0001-pernr
                infty           = '0001'
                begda           = lv_begda
                endda           = lv_endda
              tables
                infty_tab       = ltold_it1
              exceptions
                infty_not_found = 1
                others          = 2.
            if sy-subrc <> 0.
              clear postab.
              refresh postab.
            else.
*             Alle im Zeitraum der betroffenen IT1 liegenden Planstellen
*             lesen.
              sort ltold_it1 by begda ascending.
              describe table ltold_it1 lines vlines_count.
              read table ltold_it1 index 1.
              lvmin_date = ltold_it1-begda.
              read table ltold_it1 index vlines_count.
              lvmax_date = ltold_it1-endda.
*  alle Verknüpfungen in dem relevanten Zeitraum
              call function 'RH_GET_POSITION_TAB'
                exporting
                  getperson     = p0001-pernr
                  getbegda      = lvmin_date
                  getendda      = lvmax_date
                  bypass_buffer = 'X'                  "N1832575
                tables
                  position_tab  = lget_position_tab2
                exceptions
                  nothing_found = 1
                  others        = 2.
*
              if sy-subrc <> 0.
                clear postab.
                refresh postab.
                clear lget_position_tab2.
                refresh lget_position_tab2.
              endif.
              sort ltold_it1 by pernr begda.
              loop at ltold_it1.
*               Prozentsatz der bestehenden Verknüpfung nachlesen
                if ltold_it1-plans eq plan_default
                               or ltold_it1 is initial.
                  clear lvno_plans_chan.
                  exit.
                endif.
                loop at lget_position_tab2
                        where otype = ot_position
                        and objid = ltold_it1-plans
                        and begda le ltold_it1-begda
                        and endda ge ltold_it1-endda.
                  exit.
                endloop.
*                 Verknüpfung zur alten Planstelle existiert
                if ltold_it1-plans = p0001-plans and
                   lget_position_tab2-prozt = pprhpr-prozt.
*                     Prozentsätze stimmen auch überein -> nichts tun!
                  lvno_plans_chan = 'X'.
                else.
                  clear lvno_plans_chan .
                  exit.
                endif.
              endloop.
              if lvno_plans_chan = 'X'.
                loop at lget_position_tab2.
                  postab = lget_position_tab2.
                  postab-opera = 'HOLD'.
                  append postab.
                endloop.
              endif.
            endif.
************************ end of YSFN375504 *****************************
*       when copy.                           "XWSL9CK012678 "YSFN515507
          when copy or insert.                              "YSFN515507
            clear: lv_flag.
*         Alle betroffenen IT1 lesen.
*  hier evtl direkter select auf die PA0001 ???
            call function 'HR_INITIALIZE_BUFFER'
              exporting
                tclas = 'A'
                pernr = p0001-pernr.
*
* alle betroffenen IT0001 records lesen
            call function 'HR_READ_INFOTYPE'
              exporting
                pernr           = p0001-pernr
                infty           = '0001'
                begda           = p0001-begda
                endda           = p0001-endda
              tables
                infty_tab       = ltold_it1
              exceptions
                infty_not_found = 1
                others          = 2.
            if sy-subrc <> 0.
              clear postab.
              refresh postab.
            else.
*             Alle im Zeitraum der betroffenen IT1 liegenden Planstellen
*             lesen.
              if not ltold_it1[] is initial.                  "YSFN515507
* wenn ltold_it1 initial ist, dann ist man wahrscheinlich in der
* Eintrittsmaßnahme und muß die folgenden Checks nicht durchlaufen.
                sort ltold_it1 by begda ascending.
                describe table ltold_it1 lines vlines_count.
                read table ltold_it1 index 1.
*           lvmin_date = ltold_it1-begda.                       "YSFN426040
                lvmin_date = ltold_it1-begda - 1.               "YSFN426040
                read table ltold_it1 index vlines_count.
*           lvmax_date = ltold_it1-endda.                       "YSFN426040
                if ltold_it1-endda eq high_date.              "YSFN426040
                  lvmax_date = ltold_it1-endda.                 "YSFN426040
                else.                                       "YSFN426040
                  lvmax_date = ltold_it1-endda + 1.             "YSFN426040
                endif.                                      "YSFN426040
*  alle Verknüpfungen in dem relevanten Zeitraum
                call function 'RH_GET_POSITION_TAB'
                  exporting
                    getperson     = p0001-pernr
                    getbegda      = lvmin_date
                    getendda      = lvmax_date
                    bypass_buffer = 'X'                  "N1832575
                  tables
                    position_tab  = lget_position_tab2
                  exceptions
                    nothing_found = 1
                    others        = 2.
*
                if sy-subrc <> 0.
                  clear postab.
                  refresh postab.
                  clear lget_position_tab2.
                  refresh lget_position_tab2.
                endif.
                sort ltold_it1 by pernr begda.
                clear lvold_pernr.
*             Gleiche IT1 (nur Planstelle ist relevant) vereinen.
                loop at ltold_it1.
                  if lvold_pernr-plans = ltold_it1-plans and
                     ltold_it1-plans <> initial and
                     ltold_it1-plans <> plan_default.
                    lvdelete_index = sy-tabix - 1.
                    if lvdelete_index > 0.
                      ltold_it1-begda = lvold_pernr-begda.
                      modify ltold_it1.
                      delete ltold_it1 index lvdelete_index.
                    endif.
                  endif.
                  lvold_pernr = ltold_it1.
                endloop.
*
                loop at ltold_it1.
                  if ltold_it1-begda = p0001-begda and
                     ltold_it1-endda = p0001-endda.
*                 Prozentsatz der bestehenden Verknüpfung nachlesen
                    loop at lget_position_tab2
                            where otype = ot_position
                            and objid = ltold_it1-plans
                            and begda le ltold_it1-begda
                            and endda ge ltold_it1-endda.
                      vsave_tabix = sy-tabix.
                      exit.
                    endloop.
*
                    if sy-subrc = 0.
*                 Verknüpfung zur alten Planstelle existiert
                      if ltold_it1-plans = p0001-plans and
                         lget_position_tab2-prozt = pprhpr-prozt.
*                     Prozentsätze stimmen auch überein -> nichts tun!
                        lv_flag = 'X'.
                        lget_position_tab2-opera = 'HOLD'.
                        modify lget_position_tab2 index vsave_tabix.
                        exit.           "loop at ltold_it1.
                      else.
*                     Planstellen oder Prozentsätze stimmen
*                     nicht überein -> Verknüpfung löschen!
* Kopieren auf einen existierenden Zeitraum
* 0001       I-------------I---S1----I------------I
* 1001 P-S1    I------------------------------I
* 1001 P-S1    I---INSO----I-DEL-----I--INSO--I
*
                        postab = lget_position_tab2.
                        postab-opera = 'DEL'.
                        append postab.
                        if lget_position_tab2-endda gt p0001-endda.
                          postab = lget_position_tab2.
                          postab-begda = p0001-endda + 1.
                          postab-opera = 'INSO'.
                          append postab.
                        endif.
                        if lget_position_tab2-begda lt p0001-begda.
                          postab = lget_position_tab2.
                          postab-endda = p0001-begda - 1.
                          postab-opera = 'INSO'.
                          append postab.
                        endif.
                        lget_position_tab2-opera = 'OK  '.
                        modify lget_position_tab2 index vsave_tabix.
                      endif.
                    endif.
                  elseif ltold_it1-begda le p0001-begda and
                         ltold_it1-endda ge p0001-endda.
*                 Bestehender IT1 umfaßt neuen IT1 -> Alten am Ende
*                 und/oder Beginn abgrenzen.
* 0001      I-------------I------ S1-----I------------I
*                             I--COP--I
*
                    loop at lget_position_tab2
                            where otype = ot_position
                            and objid = ltold_it1-plans
                            and begda le ltold_it1-begda
                            and endda ge ltold_it1-endda.
*
                      if p0001-begda ge lget_position_tab2-begda
                         and p0001-endda le lget_position_tab2-endda
                         and pprhpr-prozt = lget_position_tab2-prozt
                         and p0001-plans = lget_position_tab2-objid.
*                      Es existiert schon eine Verknüpfung zur Plan-
*                      stelle, die die hinzuzufügende komplett um-
*                      faßt -> HOLD
                        lv_flag = 'X'.
                        lget_position_tab2-opera = 'HOLD'.
                        modify lget_position_tab2.
                        exit.
                      endif.
*                   Bisherige Verknüpfung löschen
                      postab = lget_position_tab2.
                      postab-opera = 'DEL'.
                      append postab.
*                   und abgegrenzt hinzufügen
                      if lget_position_tab2-endda gt p0001-endda.
                        postab = lget_position_tab2.
                        postab-begda = p0001-endda + 1.
                        postab-opera = 'INSO'.
                        append postab.
                      endif.
                      if lget_position_tab2-begda lt p0001-begda.
                        postab = lget_position_tab2.
                        postab-endda = p0001-begda - 1.
                        postab-opera = 'INSO'.
                        append postab.
                      endif.
                      lget_position_tab2-opera = 'OK  '.
                      modify lget_position_tab2.
                    endloop.
                  elseif ltold_it1-begda ge p0001-begda and
                         ltold_it1-endda le p0001-endda.
*                 Neuer IT1 umfaßt bestehenden IT1 -> alten löschen
* 0001      I-------------I------ S1-----I------------I
* p0001              I-----------COP-------------I
*
                    loop at lget_position_tab2
                            where otype = ot_position
                            and objid = ltold_it1-plans
                            and begda le ltold_it1-begda
                            and endda ge ltold_it1-endda.
*
                      if p0001-begda ge lget_position_tab2-begda
                         and p0001-endda le lget_position_tab2-endda
                         and pprhpr-prozt = lget_position_tab2-prozt
                         and p0001-plans = lget_position_tab2-objid.
*                      Es existiert schon eine Verknüpfung zur Plan-
*                      stelle, die die hinzuzufügende komplett um-
*                      faßt -> HOLD
                        lv_flag = 'X'.
                        lget_position_tab2-opera = 'HOLD'.
                        modify lget_position_tab2.
                        exit.
                      endif.
                      if lget_position_tab2-opera is initial.
                        postab = lget_position_tab2.
                        postab-opera = 'DEL '.
                        append postab.
                      endif.
*                   Die Teile der Verknüpfung, die über ltold_it1
*                   überstehen, wieder einfügen.
                      clear lvpostab_buf.                    "ANDR99K000146
                      refresh lvpostab_buf.                  "ANDR99K000146
                      if lget_position_tab2-endda gt ltold_it1-endda.
                        lvpostab_buf = lget_position_tab2.
                        lvpostab_buf-begda = ltold_it1-endda + 1.
                        lvpostab_buf-opera = 'INSO'.
                        append lvpostab_buf.
                      endif.
                      if lget_position_tab2-begda lt ltold_it1-begda.
                        lvpostab_buf = lget_position_tab2.
                        lvpostab_buf-endda = ltold_it1-begda - 1.
                        lvpostab_buf-opera = 'INSO'.
                        append lvpostab_buf.
                      endif.
                      perform append_postab tables postab
                                                   lvpostab_buf.
                      lget_position_tab2-opera = 'OK  '.
                      modify lget_position_tab2.
                    endloop.
                  else.
*                 Bestehender und neuer IT1 schneiden sich
*                 -> Alten am Ende oder Beginn abgrenzen.
* 0001      I-------------I------ S1-----I------------I
* p0001                      I---COP-------------I
* oder            I---COP-------------I
                    loop at lget_position_tab2 where
                                              begda le ltold_it1-begda
                                          and endda ge ltold_it1-endda
                                          and objid = ltold_it1-plans
                                          and otype = ot_position.

                      if p0001-begda ge lget_position_tab2-begda
                         and p0001-endda le lget_position_tab2-endda
                         and pprhpr-prozt = lget_position_tab2-prozt
                         and p0001-plans = lget_position_tab2-objid.
*                      Es existiert schon eine Verknüpfung zur Plan-
*                      stelle, die die hinzuzufügende komplett um-
*                      faßt -> HOLD
                        lv_flag = 'X'.
                        lget_position_tab2-opera = 'HOLD'.
                        modify lget_position_tab2.
                        exit.
                      endif.
*                   Bisherige Verknüpfung löschen
                      if lget_position_tab2-opera is initial.
                        postab = lget_position_tab2.
                        postab-opera = 'DEL'.
                        append postab.
                      endif.
*                   und abgegrenzt hinzufügen
                      clear lvpostab_buf.
                      refresh lvpostab_buf.
                      if p0001-endda > ltold_it1-endda.
                        if lget_position_tab2-endda gt ltold_it1-endda.
                          lvpostab_buf = lget_position_tab2.
                          lvpostab_buf-begda = ltold_it1-endda + 1.
                          lvpostab_buf-opera = 'INSO'.
                          append lvpostab_buf.
                        endif.
                        if lget_position_tab2-begda lt p0001-begda.
                          lvpostab_buf = lget_position_tab2.
                          lvpostab_buf-endda = p0001-begda - 1.
                          lvpostab_buf-opera = 'INSO'.
                          append lvpostab_buf.
                        endif.
                      else.
                        if lget_position_tab2-endda gt p0001-endda.
                          lvpostab_buf = lget_position_tab2.
                          lvpostab_buf-begda = p0001-endda + 1.
                          lvpostab_buf-opera = 'INSO'.
                          append lvpostab_buf.
                        endif.
                        if lget_position_tab2-begda lt ltold_it1-begda.
                          lvpostab_buf = lget_position_tab2.
                          lvpostab_buf-endda = ltold_it1-begda - 1.
                          lvpostab_buf-opera = 'INSO'.
                          append lvpostab_buf.
                        endif.
                      endif.
                      perform append_postab tables postab
                                                   lvpostab_buf.

                      lget_position_tab2-opera = 'OK  '.
                      modify lget_position_tab2.
                    endloop.
                  endif.
                endloop.
                loop at lget_position_tab2 where opera is initial.
                  postab = lget_position_tab2.
                  postab-opera = 'HOLD'.
                  append postab.
                endloop.
              endif.                                        "YSFN515507
              if lv_flag is initial.
*             Neuen Satz hinzufügen.
                clear lvpostab_buf.
                lvpostab_buf-begda = p0001-begda.
                lvpostab_buf-endda = lv_contr_endda.         "MELN1483226
                "ANDR99K000146
                lvvpostab_buf_begda_minus_1 = lvpostab_buf-begda - 1.   "AND
                if not lvpostab_buf-endda = '99991231'.              "AND
                  lvvpostab_buf_endda_plus_1  = lvpostab_buf-endda + 1. "AND
                else.                                              "AND
                  lvvpostab_buf_endda_plus_1 = lvpostab_buf-endda.      "AND
                endif.                                             "AND
                "ANDR99K000146
*              lvpostab_buf-OTYPE = OT_POSITION.             "MELN1001919
                lvpostab_buf-otype = p0001-otype.              "MELN1001919
                lvpostab_buf-objid = p0001-plans.
                lvpostab_buf-prozt = pprhpr-prozt.
                loop at postab where otype = ot_position
                                 and objid = lvpostab_buf-objid
                                 and prozt = lvpostab_buf-prozt
                                                          "ANDR99K000146
                                 and begda le lvvpostab_buf_endda_plus_1
                                 and endda ge lvvpostab_buf_begda_minus_1
                                                          "ANDR99K000146
                                 and ( opera = 'INSO' or
                                       opera = 'INSN' or
                                       opera = 'HOLD' ) .

                  if postab-endda gt lvpostab_buf-endda.
                    lvpostab_buf-endda = postab-endda.
                  endif.
                  if postab-begda lt lvpostab_buf-begda.
                    lvpostab_buf-begda = postab-begda.
                  endif.
                  if postab-opera = 'HOLD'.
                    postab-opera = 'DEL '.
                    modify postab.
                  else.
                    delete postab.
                  endif.
                endloop.
*               Prüfen, ob der Satz abgegrenzt/verlängert/verändert
*               oder neu hinzugefügt wird. Abhängig davon dann OPERA
*               INSO oder INSN setzen.
                loop at postab where otype = ot_position
                                 and objid = lvpostab_buf-objid
                                 and prozt = lvpostab_buf-prozt
                                 and begda le lvpostab_buf-endda
                                 and endda ge lvpostab_buf-begda
                                 and opera = 'DEL '.
                  exit.
                endloop.
                if sy-subrc = 0.
                  lvpostab_buf-opera = 'INSO'.
                else.
                  lvpostab_buf-opera = 'INSN'.
                endif.
                append lvpostab_buf to postab.
              else.
                loop at lget_position_tab2 where opera = 'HOLD'.
                  postab = lget_position_tab2.
                  append postab.
                endloop.
              endif.
            endif.
          when others.
*-- ANDPH9K003496 -----------------------------------------------------*
        endcase.
*-- ANDPH9K010026 -----------------------------------------------------*
*       Mit postab Kostenstellenverprobung, Prozentprüfung und
*       Zeitbindungsprüfung durchführen
**************** begin of YSFN366571 ***********************************
        case psyst-fstat.
          when fcode_lo.
            ch_tcode = 'DEL'.
          when fcode_hz or fcode_ae or fcode_hv.
            ch_tcode = 'INS'.
          when others.                     "should not happen
            clear ch_tcode.
        endcase.

        if not ch_tcode is initial.
*************** end of YSFN366571 **************************************

          call function 'RH_CHECK_POSITION_FOR_UPDATE'
               exporting
                   checkposition       = p0001-plans        "YSFN366571
                    checkotype          = p0001-otype       "MELN990694
                    checkbegda          = p0001-begda      "MELN1724617
                    checkendda          = lv_contr_endda
                    checkperson         = p0001-pernr
                    checkit0001         = p0001
                    checkcode           = ch_tcode           "YSFN366571
                    pos_tab_cc_check    = 'X'
                    prozent             = 'X'
                    check_timco         = 'X'
               importing
                    checksubrc          = vcheck_subrc
               tables
                    position_tab        = postab
                    SUBRC_MESSAGE_TAB   = ltmes_tab[].

          if vcheck_subrc ne 0.                             "ANDAHRK057835
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

    LOOP AT ltmes_tab. " 18.08.2016 JPM 4971
      IF ltmes_tab-MSGV4 eq lt_tvarv-low
        or ltmes_tab-MSGV2 eq lt_tvarv-low.
        CASE ltmes_tab-MSGID.
          WHEN 'KI'.
            IF ltmes_tab-MSGNO eq '100'.
             move 'W' to ltmes_tab-MSGTY.
             MODIFY ltmes_tab.
            ENDIF.
          WHEN 'KM'.
            IF ltmes_tab-MSGNO eq '183'.
              move 'W' to ltmes_tab-MSGTY.
              MODIFY ltmes_tab.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

*------------------------------------------------------------*  JPM FIN 4971
            if not ltmes_tab[] is initial.
              loop at ltmes_tab.
                message id     ltmes_tab-msgid
                        type   ltmes_tab-msgty
                        number ltmes_tab-msgno
                        with   ltmes_tab-msgv1 ltmes_tab-msgv2
                               ltmes_tab-msgv3 ltmes_tab-msgv4.
              endloop.
            endif.
          endif.
        endif.                                              "YSFN366571
*------ ANDPH9K010026 ------------------------------------------------*
      endif.
      call function 'RH_CLEAR_BUFFER'.
      call function 'RH_CLEAR_PLOG_TAB'.
      call function 'RH_UPDATE_OLD_RELATIONS'
        exporting
          updateperson          = p0001-pernr
          update_dialog_check   = ' '
          update_lock_positions = ' '
          no_message            = ' '
        importing
          updatesubrc           = ch_subrc
        tables
          position_tab          = postab
        exceptions
          plvar_not_found       = 1
          otype_plste_not_found = 2
          others                = 3.

      if sy-subrc eq 0.
        case ch_subrc.
          when 0.                      "alles hat geklappt
          when 1.                      "Fehler beim Delete oder Insert
          when 2.       "Sperren einer Planstelle hat nicht geklappt
          when others.
        endcase.
* { begin MELN1152988
* avoid that the position displayed and stored in IT0001 is changed
* during a copy of IT0001 and if the pernr is assigned to multiple
* positions with the same staffing percentage
* => always put the current position from IT0001 to POSTAB INDEX 1
        LOOP AT postab INTO lsv_current_plans WHERE otype = p0001-otype    "SERN1309695
                                               AND objid = p0001-plans    "SERN1309695
                                               AND opera = 'HOLD'         "SERN1309695
                                               AND begda <= p0001-endda   "SERN1309695
                                               AND endda >= p0001-begda.  "SERN1309695
          lvv_tabix = sy-tabix.                                            "SERN1309695
          EXIT.                                                           "SERN1309695
        ENDLOOP.                                                          "SERN1309695
        IF sy-subrc = 0 AND lvv_tabix > 1.                                 "SERN1309695
          delete table postab from lsv_current_plans.
          insert lsv_current_plans into postab index 1.
        endif.
* } end MELN1152988
        export postab to memory id 'POSTAB'.
        clear postab. refresh postab.
      else.
        clear postab. refresh postab.
      endif.
    endif.
  endif.
*------------- end ---------- XFYAHRK040220 --------------------------

  case psyst-ioper.
    when delete.
      if p0001-begda eq pskey-begda and p0001-endda le pskey-endda.
        perform read_infotype(sapfp50p) using
          pspar-pernr '0001' space space space low_date high_date
          all nop seltab.
        read table seltab with key pskey binary search.
        if sy-subrc eq 0.
          move 'D' to seltab-opera.    "alten Satz loeschen
          modify seltab index sy-tabix.
          if p0001-endda lt pskey-endda.          "Rumpfsatz einfuegen
            seltab-begda = p0001-endda + 1.
            move 'I' to seltab-opera.
            move seltab to lvi_key.
            read table seltab with key lvi_key binary search
                              transporting no fields.
            if seltab-endda >= seltab-begda.
              insert seltab index sy-tabix.
            endif.
          endif.
        endif.
        lvi_datum = pskey-begda - 1.   "Endedatum des Vorgaengers
        loop at seltab where endda eq lvi_datum and opera ne 'D'.
          move 'D' to seltab-opera.
          modify seltab.
          seltab-endda = p0001-endda.
          move 'I' to seltab-opera.
          move seltab to lvi_key.
          read table seltab with key lvi_key binary search
                            transporting no fields.
          if seltab-endda >= seltab-begda.
            insert seltab index sy-tabix.
          endif.
          exit.
        endloop.
        perform rh_input_check(sapfhpin) tables seltab.
      endif.
    when modify.
      if p0001-begda ne pskey-begda or p0001-endda ne pskey-endda.
        perform read_infotype(sapfp50p) using
          pspar-pernr '0001' space space space low_date high_date
          all nop seltab.
        read table seltab with key pskey binary search.
        if sy-subrc eq 0.
          move 'D' to seltab-opera.    "alten Satz loeschen
          modify seltab index sy-tabix.
          seltab-begda = p0001-begda.
          seltab-endda = p0001-endda.
          move 'I' to seltab-opera.
          move seltab to lvi_key.
          read table seltab with key lvi_key binary search
                            transporting no fields.
          insert seltab index sy-tabix.
        endif.
        lvi_datum = pskey-begda - 1.   "Endedatum des Vorgaengers
        loop at seltab where endda eq lvi_datum and opera ne 'D'.
          move 'D' to seltab-opera.
          modify seltab.
          seltab-endda = p0001-begda - 1.
          move 'I' to seltab-opera.
          move seltab to lvi_key.
          read table seltab with key lvi_key binary search
                            transporting no fields.
          if seltab-endda >= seltab-begda.
            insert seltab index sy-tabix.
          endif.
          exit.
        endloop.
        lvi_datum = pskey-endda + 1.   "Beginndatum des Nachfolgers
        loop at seltab where begda eq lvi_datum and opera ne 'D'.
          move 'D' to seltab-opera.
          modify seltab.
          if p0001-endda ne '99991231'."XFYAHRK025363
            seltab-begda = p0001-endda + 1.
            move 'I' to seltab-opera.
            move seltab to lvi_key.
            read table seltab with key lvi_key binary search
                              transporting no fields.
            if seltab-endda >= seltab-begda.
              insert seltab index sy-tabix.
            endif.
          endif.                       "XFYAHRK025363
          exit.
        endloop.
        perform rh_input_check(sapfhpin) tables seltab.
      endif.
  endcase.
EXIT.
ENDENHANCEMENT.
