"Name: \PR:RPCIP_DOCUMENT_ANALYSE\FO:SELECT_DOCS_AND_RUNS_DATA\SE:END\EI
ENHANCEMENT 0 ZHRENH001_CE_CFDI.
 "JLGF 21.11.2014 - Req 3640

*----------------------------------------------------------------------*
*   Declaracion Variables y Tablas
*----------------------------------------------------------------------*
DATA: wa_doc_analyse TYPE hrpp_document_analyse,
      tmp_doc_analyse TYPE hrpp_document_analyse_tab,
      it_zcfdi_timbre TYPE zcfdi_timbre OCCURS 0 WITH HEADER LINE.
DATA: p0001 TYPE p0001 OCCURS 0 WITH HEADER LINE,
      ls_datos TYPE t7mx24.
DATA: v_pernr TYPE hrpp_document_analyse-pernroix,
      v_seqno TYPE hrpp_document_analyse-seqnooix.
DATA: it_importes TYPE zhr_cfdi_importe OCCURS 0 WITH HEADER LINE,
      v_formapago TYPE zcfdi_forma,
      v_metodopago TYPE zcfdi_metodo,
      v_errores TYPE string.
DATA: it_t512w TYPE t512w OCCURS 0 WITH HEADER LINE,
      it_zce_cfdi_imss TYPE zce_cfdi_imss OCCURS 0 WITH HEADER LINE,
      it_zhr_cfdi_imss TYPE zhr_cfdi_imss OCCURS 0 WITH HEADER LINE,
      it_zhr_cfdi_filtros TYPE zhr_cfdi_filtros OCCURS 0 WITH HEADER LINE,
      it_zhr_cfdi_cuentas TYPE zhr_cfdi_cuentas OCCURS 0 WITH HEADER LINE.

DATA: wa_zccrh_infoxml TYPE zccrh_infoxml, "04.06.2015 4019 CCV info XML RH
      wa_zccrh_infoxml2 TYPE zccrh_infoxml, "23.06.2015 4019 CCV eliminar registros
      it_zccrh_infoxml TYPE STANDARD TABLE OF zccrh_infoxml,"04.06.2015 4019 CCV info XML RH
      it_zccrh_infoxml2 TYPE STANDARD TABLE OF zccrh_infoxml."23.06.2015 4019 CCV eliminar registros

DATA: v_mensual TYPE c,
      v_bimestral TYPE c,
      v_decimales TYPE glbpr,
      v_cantbimestre TYPE i,
      v_periodos_imss TYPE i,
      v_periodos_rcv TYPE i,
      vl_flag TYPE c.

DATA: it_payroll TYPE pay99_result,
      wa_wpbp TYPE pc205.

"Variables Usadas Para Sacar el Area de Nomina para Sacar el Numero del Periodo
DATA: it_pa0001 TYPE pa0001 OCCURS 0 WITH HEADER LINE,
      vl_abkrs TYPE pa0001-abkrs,
      l_t549a TYPE t549a,
      lw_t549q TYPE t549q,
      vl_inperoix LIKE wa_doc_analyse-inperoix.
*----------------------------------------------------------------------*
* Seleccion de Configuracion y Tablas de lectura
*----------------------------------------------------------------------*

SELECT * FROM t512w
  INTO CORRESPONDING FIELDS OF TABLE it_t512w "Agarra los CC Nominas para verificar su posicion 17
  WHERE molga EQ 32.
SORT it_t512w BY lgart.

SELECT * FROM zcfdi_timbre
  INTO CORRESPONDING FIELDS OF TABLE it_zcfdi_timbre "Selecciona el CFDI dependiendo del RUNID
  FOR ALL ENTRIES IN gt_doc_analyse
  WHERE pernr EQ gt_doc_analyse-pernroix
    AND seqnr EQ gt_doc_analyse-seqnooix.

*----------------------------------------------------------------------*INI JPM
  " 23.12.2014 JPM
SELECT * FROM zcfdi_timbre
  APPENDING CORRESPONDING FIELDS OF TABLE it_zcfdi_timbre "Selecciona el CFDI dependiendo del RUNID
  FOR ALL ENTRIES IN gt_doc_analyse
  WHERE pernr EQ gt_doc_analyse-pernroix
    AND runid EQ gt_doc_analyse-runid.          " 23.12.2014 JPM

SORT it_zcfdi_timbre BY pernr runid inper.                                           " 23.12.2014 JPM
DELETE ADJACENT DUPLICATES FROM it_zcfdi_timbre COMPARING ALL FIELDS.                " 23.12.2014 JPM
*----------------------------------------------------------------------*FIN JPM

SELECT * FROM zce_cfdi_imss
  INTO CORRESPONDING FIELDS OF TABLE it_zce_cfdi_imss. "Selecciona los registros de Cuentas Mayores del IMSS y RCV
SORT it_zce_cfdi_imss BY racct type.

SELECT * FROM zhr_cfdi_imss
  INTO CORRESPONDING FIELDS OF TABLE it_zhr_cfdi_imss. "Selecciona la configuracion de Cuentas Mayores del IMSS y RCV
SORT it_zhr_cfdi_imss BY repat inper type.

*----------------------------------------------------------------------*
* Selecciona los filtros para el reporte
*----------------------------------------------------------------------*


SELECT * FROM zhr_cfdi_filtros
  INTO CORRESPONDING FIELDS OF TABLE it_zhr_cfdi_filtros. "Selecciona los Filtros de la tabla zhr_cfdi_filtros

SELECT * FROM zhr_cfdi_cuentas
  INTO CORRESPONDING FIELDS OF TABLE it_zhr_cfdi_cuentas. "Selecciona los Filtros de la tabla zhr_cfdi_cuentas

DELETE it_zhr_cfdi_cuentas WHERE hkont IS INITIAL.
SORT it_zhr_cfdi_cuentas BY hkont.

RANGES: r_pernr FOR zhr_cfdi_filtros-pernr,
        r_werks FOR zhr_cfdi_filtros-werks,
        r_repat FOR zhr_cfdi_filtros-repat,
        r_rfcem FOR zhr_cfdi_filtros-rfcem,
        r_lgart FOR zhr_cfdi_filtros-lgart,
        r_hkont FOR zhr_cfdi_cuentas-hkont.

r_pernr-sign = 'I'.
r_werks-sign = 'I'.
r_repat-sign = 'I'.
r_rfcem-sign = 'I'.
r_lgart-sign = 'I'.
r_hkont-sign = 'I'.
r_pernr-option = 'EQ'.
r_werks-option = 'EQ'.
r_repat-option = 'EQ'.
r_rfcem-option = 'EQ'.
r_lgart-option = 'EQ'.
r_hkont-option = 'EQ'.

LOOP AT it_zhr_cfdi_filtros.
  IF it_zhr_cfdi_filtros-pernr IS NOT INITIAL.
    r_pernr-low = it_zhr_cfdi_filtros-pernr.
    APPEND r_pernr.
  ENDIF.
  IF it_zhr_cfdi_filtros-werks IS NOT INITIAL.
    r_werks-low = it_zhr_cfdi_filtros-werks.
    APPEND r_werks.
  ENDIF.
  IF it_zhr_cfdi_filtros-repat IS NOT INITIAL.
    r_repat-low = it_zhr_cfdi_filtros-repat.
    APPEND r_repat.
  ENDIF.
  IF it_zhr_cfdi_filtros-rfcem IS NOT INITIAL.
    r_rfcem-low = it_zhr_cfdi_filtros-rfcem.
    APPEND r_rfcem.
  ENDIF.
  IF it_zhr_cfdi_filtros-lgart IS NOT INITIAL.
    r_lgart-low = it_zhr_cfdi_filtros-lgart.
    APPEND r_lgart.
  ENDIF.
ENDLOOP.

LOOP AT it_zhr_cfdi_cuentas.
  r_hkont-low = it_zhr_cfdi_cuentas-hkont.
  APPEND r_hkont.
ENDLOOP.


*----------------------------------------------------------------------*
*   Procesos
*----------------------------------------------------------------------*

IF p_type EQ 'PP'. "Tiene que ser Tipo de Nomina
  IF gt_doc_analyse[] IS NOT INITIAL.

    LOOP AT gt_doc_analyse INTO wa_doc_analyse. "Barre la tbla de Resultados

      IF wa_doc_analyse-pernroix IS INITIAL OR wa_doc_analyse-pernroix EQ '00000000'.
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
        EXPORTING
          employeenumber          = wa_doc_analyse-pernroix
          sequencenumber          = wa_doc_analyse-seqnooix
          read_only_international = 'X'
        CHANGING
          payroll_result          = it_payroll.

      IF it_payroll IS NOT INITIAL.
        LOOP AT it_payroll-inter-wpbp INTO wa_wpbp. ENDLOOP.

        "Registro Patronal
        CALL FUNCTION 'ZCCHRMF006'
          EXPORTING
            werks    = wa_wpbp-werks
            btrtl    = wa_wpbp-btrtl
          IMPORTING
            wa_datos = ls_datos.

        MOVE ls_datos-repat TO wa_doc_analyse-repat.
      ELSE.
        CLEAR wa_doc_analyse-repat.
      ENDIF.

      "JLGF 20.01.2015 12:14:13
*      IF wa_doc_analyse-inperoix IS INITIAL OR wa_doc_analyse-inperoix EQ '000000'. "Si el Periodo EN es '000000' Toma la Fecha de Contabilizacion
        CLEAR: vl_abkrs.

        "Saca el Area de Nomina para Sacar el Numero del Periodo
        SELECT * FROM Pa0001 INTO CORRESPONDING FIELDS OF TABLE it_pa0001
          WHERE pernr EQ wa_doc_analyse-pernroix.

        LOOP AT it_pa0001.
          IF wa_doc_analyse-budat BETWEEN it_pa0001-begda AND it_pa0001-endda.
            vl_abkrs = it_pa0001-abkrs.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'HR_99S_GET_PERMO'
         EXPORTING
           P_ABKRS  = vl_abkrs
         IMPORTING
           P_T549A  = l_t549a.

         SELECT SINGLE * INTO lw_t549q FROM t549q
          WHERE permo EQ l_t549a-permo AND
                begda LE wa_doc_analyse-budat AND
                endda GE wa_doc_analyse-budat.
         IF sy-subrc = 0.
           CONCATENATE lw_t549q-pabrj lw_t549q-pabrp INTO vl_inperoix.
         ELSE.
           CLEAR vl_inperoix.
         ENDIF.
*      ELSE.
*        vl_inperoix = wa_doc_analyse-inperoix.
*      ENDIF.


********************************* Contabilidad Electronica IMSS REQ3656 **************************************************************************

      "Verifica en la tabla de Filtros de Cuentas de la vista de mantenimiento
      IF wa_doc_analyse-hkontdit IN r_hkont.
        READ TABLE it_zce_cfdi_imss WITH KEY racct = wa_doc_analyse-hkontdit BINARY SEARCH. "Revisamos si la Cuenta mayor existe en la configuracion
        IF sy-subrc EQ 0.
          CLEAR: v_periodos_imss,v_periodos_rcv,v_bimestral,v_mensual.
          LOOP AT it_zce_cfdi_imss WHERE racct = wa_doc_analyse-hkontdit. "Revisa si la Cuenta es de Tipo Bimestral,Mensual o Ambas
            IF it_zce_cfdi_imss-type EQ 'BIMESTRAL'.
              v_bimestral = 'X'.
            ELSEIF it_zce_cfdi_imss-type EQ 'MENSUAL'.
              v_mensual = 'X'.
            ENDIF.
          ENDLOOP.

          IF v_bimestral EQ 'X'. "Si es de tipo Bimestral se Trae los Periodos IMSS y RCV que tomara por Bimestre
            "Nota: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 4 tomara todos los periodos del bimestre
            "Ejemplo.- Bimestre 1 (201501,201502,201503,201504), Bimestre 2 (201505,201506,201507,201508)
            "Nota2: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 3 tomara los ultimos 3 periodos del bimestre
            "Ejemplo.- Bimestre 1 (201502,201503,201504), Bimestre 2 (201506,201507,201508)
            "Nota3: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 2 tomara los ultimos 2 periodos del bimestre
            "Ejemplo.- Bimestre 1 (201503,201504), Bimestre 2 (201507,201508)
            "Nota4: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 1 tomara el ultimo periodo del bimestre
            "Ejemplo.- Bimestre 1 (201504), Bimestre 2 (201508)

            READ TABLE it_zce_cfdi_imss WITH KEY racct = wa_doc_analyse-hkontdit
                                                 type  = 'BIMESTRAL' BINARY SEARCH.
            IF sy-subrc EQ 0.
              v_periodos_imss = it_zce_cfdi_imss-config_imss.
              v_periodos_rcv = it_zce_cfdi_imss-config_rcv.
            ELSE.
              v_periodos_imss = 0.
              v_periodos_rcv = 0.
            ENDIF.

            READ TABLE it_zhr_cfdi_imss WITH KEY repat = wa_doc_analyse-repat
                                                 inper = vl_inperoix
                                                 type  = 'BIMESTRAL' BINARY SEARCH.
            IF sy-subrc EQ 0.
                v_cantbimestre = vl_inperoix+4(2) MOD 4.
                IF v_cantbimestre EQ 0. v_cantbimestre = 4. ENDIF.

                IF ( v_periodos_imss EQ '2' AND ( v_cantbimestre EQ '3' OR v_cantbimestre EQ '4' ) ) OR
                   ( v_periodos_imss EQ '4' ).

                  wa_doc_analyse-imss = it_zhr_cfdi_imss-imss.    "IMSS Aplica solo en periodos de configuracion
                  wa_doc_analyse-uuid_imss = it_zhr_cfdi_imss-uuid.
                  MODIFY gt_doc_analyse FROM wa_doc_analyse.
                ENDIF.

                IF ( v_periodos_rcv EQ '2' AND ( v_cantbimestre EQ '3' OR v_cantbimestre EQ '4' ) ) OR
                   ( v_periodos_rcv EQ '4' ).

                  wa_doc_analyse-rcv = it_zhr_cfdi_imss-rcv.    "RCV Aplica solo en periodos de configuracion
                  wa_doc_analyse-uuid_rcv = it_zhr_cfdi_imss-uuid. "28.11.2016 JLGF 5079
                  MODIFY gt_doc_analyse FROM wa_doc_analyse.
                ENDIF.
            ENDIF.
          ENDIF.
          IF v_mensual EQ 'X'. "Si es de tipo Mensual se Trae los Periodos IMSS que tomara por Bimestre
            "Nota: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 4 tomara todos los periodos del bimestre
            "Ejemplo.- Bimestre 1 (201501,201502,201503,201504), Bimestre 2 (201505,201506,201507,201508)
            "Nota2: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 3 tomara los primeros 3 periodos del bimestre
            "Ejemplo.- Bimestre 1 (201501,201502,201503), Bimestre 2 (201505,201506,201507)
            "Nota3: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 2 tomara los primeros 2 periodos del bimestre
            "Ejemplo.- Bimestre 1 (201501,201502,), Bimestre 2 (201505,201506,)
            "Nota4: Si en el Periodo IMSS (it_zce_cfdi_imss-config_imss) le ponen 1 tomara el primer periodo del bimestre
            "Ejemplo.- Bimestre 1 (201501), Bimestre 2 (201505)

            READ TABLE it_zce_cfdi_imss WITH KEY racct = wa_doc_analyse-hkontdit
                                                 type  = 'MENSUAL' BINARY SEARCH.
            IF sy-subrc EQ 0.
              v_periodos_imss = it_zce_cfdi_imss-config_imss.
            ENDIF.

            READ TABLE it_zhr_cfdi_imss WITH KEY repat = wa_doc_analyse-repat
                                                 inper = vl_inperoix
                                                 type  = 'MENSUAL' BINARY SEARCH.
            IF SY-SUBRC EQ 0.
              v_cantbimestre = vl_inperoix+4(2) MOD 4.
              IF v_cantbimestre EQ 0. v_cantbimestre = 4. ENDIF.

              IF ( v_periodos_imss EQ '2' AND ( v_cantbimestre EQ '1' OR v_cantbimestre EQ '2' ) ) OR
                 ( v_periodos_imss EQ '4' ).

                wa_doc_analyse-imss = it_zhr_cfdi_imss-imss.
                wa_doc_analyse-uuid_imss = it_zhr_cfdi_imss-uuid.
                MODIFY gt_doc_analyse FROM wa_doc_analyse.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.




******************************* Contabilidad Electronica REQ3640 ****************************************************************

*        READ TABLE it_t512w WITH KEY lgart = wa_doc_analyse-lgartoix BINARY SEARCH.
*        IF it_t512w-aklas+36(1) EQ 0 and it_t512w-aklas+37(1) EQ 1. "En la clase de evaluacion del CC-Nomina debe tener 01 en la posicion 17
*        ELSE.
*          CONTINUE.
*        ENDIF.

      SORT it_zcfdi_timbre BY pernr runid inper.                                          " 23.12.2014 JPM
      DELETE ADJACENT DUPLICATES FROM it_zcfdi_timbre COMPARING ALL FIELDS.                " 23.12.2014 JPM

      READ TABLE it_zcfdi_timbre WITH KEY pernr = wa_doc_analyse-pernroix                 " 23.12.2014 JPM
                                          runid = wa_doc_analyse-runid                    " 23.12.2014 JPM
                                          inper = wa_doc_analyse-inperoix BINARY SEARCH.  " 23.12.2014 JPM
      IF sy-subrc NE 0.                                                                   " 23.12.2014 JPM
        SORT it_zcfdi_timbre BY pernr seqnr.                                              " 23.12.2014 JPM
        READ TABLE it_zcfdi_timbre WITH KEY pernr = wa_doc_analyse-pernroix
                                            seqnr = wa_doc_analyse-seqnooix BINARY SEARCH.
      ENDIF.                                                                              " 23.12.2014 JPM

      CHECK sy-subrc EQ 0.
      CLEAR: it_importes,it_importes[].
      CALL FUNCTION 'ZHRMF_CFDI_CE_NOMINA'  "Te trae todos los importes de los CC Nominas del CFDI
        EXPORTING
          xml_crypt_tim       = it_zcfdi_timbre-xml_crypt_tim
        IMPORTING
          formapago           = v_formapago
          metodopago          = v_metodopago
          errores             = v_errores
        TABLES
          i_importes          = it_importes.

      SORT it_importes BY lgart.

      READ TABLE it_importes WITH KEY lgart = wa_doc_analyse-lgartoix. "Lee los importes del CFDI
      IF sy-subrc EQ 0.
        MOVE it_importes-impor_grab TO wa_doc_analyse-imp_grabado.
        MOVE it_importes-impor_exe TO wa_doc_analyse-imp_exento.
        wa_doc_analyse-imp_suma = it_importes-impor_grab + it_importes-impor_exe.
      ELSE.
        IF wa_doc_analyse-lgartoix CS '/'.
          CLEAR wa_doc_analyse.
          CONTINUE.
        ENDIF.
      ENDIF.

      wa_doc_analyse-forma = v_formapago.
      wa_doc_analyse-metodo = v_metodopago.
      wa_doc_analyse-uuid = it_zcfdi_timbre-uuid.
      wa_doc_analyse-rfc = it_zcfdi_timbre-rfc_emp.

      READ TABLE it_zcfdi_timbre WITH KEY pernr = wa_doc_analyse-pernroix "18.08.2015 JLGF 4194
                                          runid = wa_doc_analyse-runid  BINARY SEARCH.
      IF sy-subrc EQ 0.
        wa_doc_analyse-uuid = it_zcfdi_timbre-uuid.
      ENDIF.

      MODIFY gt_doc_analyse FROM wa_doc_analyse.

*          "Verifica en la tabla de Filtros de la vista de mantenimiento
*          IF wa_doc_analyse-pernroix NOT IN r_pernr OR p0001-werks        NOT IN r_werks
*          OR wa_doc_analyse-repat    NOT IN r_repat OR wa_doc_analyse-rfc NOT IN r_rfcem
*          OR wa_doc_analyse-lgartoix NOT IN r_lgart.
*  *          DELETE gt_doc_analyse FROM wa_doc_analyse.
*            ELSE.
*              "Verifica en la tabla de Filtros de Cuentas de la vista de mantenimiento
*              IF wa_doc_analyse-hkontdit IN r_hkont.
*                APPEND wa_doc_analyse to tmp_doc_analyse.
*              ENDIF.
*          ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDIF.
*  REFRESH gt_doc_analyse.
*  gt_doc_analyse[] = tmp_doc_analyse[].
*Ini 04.06.2015 CCV XML poliza RH
CLEAR: wa_zccrh_infoxml.
REFRESH: it_zccrh_infoxml.
IF  gt_doc_analyse[] IS NOT INITIAL.
  LOOP AT gt_doc_analyse INTO wa_doc_analyse.
    MOVE-CORRESPONDING wa_doc_analyse  TO wa_zccrh_infoxml.
*    wa_zccrh_infoxml-mandt = sy-mandt.
    wa_zccrh_infoxml-gjahr =  wa_doc_analyse-budat(4).
    wa_zccrh_infoxml-monat =  wa_doc_analyse-budat+4(2).
    APPEND wa_zccrh_infoxml TO it_zccrh_infoxml.
    CLEAR wa_zccrh_infoxml .
  ENDLOOP.
  IF it_zccrh_infoxml[] IS NOT INITIAL.
    DELETE  it_zccrh_infoxml where LINUMDIX is INITIAL.
    REFRESH it_zccrh_infoxml2[].
*23.06.2015 CCV 4019 Borrar registros que existan para generar nuevos
    SELECT *
      FROM zccrh_infoxml
      INTO TABLE it_zccrh_infoxml2
      FOR ALL ENTRIES IN it_zccrh_infoxml
      WHERE docnum = it_zccrh_infoxml-docnum
        AND bukrs = it_zccrh_infoxml-bukrs
        AND runid = it_zccrh_infoxml-runid
        AND budat = it_zccrh_infoxml-budat
        AND bldat = it_zccrh_infoxml-bldat
        AND blart = it_zccrh_infoxml-blart
        AND gjahr = it_zccrh_infoxml-gjahr
        AND monat = it_zccrh_infoxml-monat
        AND doclindit = it_zccrh_infoxml-doclindit
        AND linumdix = it_zccrh_infoxml-linumdix
        AND hkontdit = it_zccrh_infoxml-hkontdit
        and KOSTLDIT = it_zccrh_infoxml-KOSTLDIT "CCV 4411 08.12.2015
        AND pernroix = it_zccrh_infoxml-pernroix
        and ACTSIGNOIX =  it_zccrh_infoxml-ACTSIGNOIX
        and LGARTOIX  = it_zccrh_infoxml-LGARTOIX.
    IF sy-subrc EQ 0.
      CLEAR: wa_zccrh_infoxml,wa_zccrh_infoxml2.
      LOOP AT it_zccrh_infoxml
         INTO wa_zccrh_infoxml.
        READ TABLE it_zccrh_infoxml2
              INTO wa_zccrh_infoxml2
          WITH KEY docnum = wa_zccrh_infoxml-docnum
                   bukrs = wa_zccrh_infoxml-bukrs
                   runid = wa_zccrh_infoxml-runid
                   budat = wa_zccrh_infoxml-budat
                   bldat = wa_zccrh_infoxml-bldat
                   blart = wa_zccrh_infoxml-blart
                   gjahr = wa_zccrh_infoxml-gjahr
                   monat = wa_zccrh_infoxml-monat
                   doclindit = wa_zccrh_infoxml-doclindit
                   linumdix = wa_zccrh_infoxml-linumdix
                   hkontdit = wa_zccrh_infoxml-hkontdit
                   KOSTLDIT = wa_zccrh_infoxml-KOSTLDIT "CCV 4411 08.12.2015
                   pernroix = wa_zccrh_infoxml-pernroix
                   ACTSIGNOIX = wa_zccrh_infoxml-ACTSIGNOIX
                   LGARTOIX  = WA_zccrh_infoxml-LGARTOIX.
        IF sy-subrc EQ 0.
          DELETE zccrh_infoxml FROM wa_zccrh_infoxml.
        ENDIF.
      ENDLOOP.
    ENDIF.

    MODIFY zccrh_infoxml FROM TABLE it_zccrh_infoxml.
    IF sy-subrc EQ 0. COMMIT WORK. ENDIF.
  ENDIF.
ENDIF.
*Fin 04.06.2015 CCV XML poliza RH

ENDENHANCEMENT.
