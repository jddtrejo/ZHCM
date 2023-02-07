"Name: \PR:MP018500\FO:RE5R05\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH001_MP018540.

  data: innnn like prelp.
  data: massn type massn.
  data: massg type massg.
  data: v_cuenta type zcchred_cta.

  IMPORT INNNN FROM MEMORY ID 'ZINNNN'.

*---------------
*Clase de medida
*---------------
   massn = innnn-data1(2).
*-------------------
*Motivo de la medida
*-------------------
   massg = innnn-data1+2(2).

" 15.01.2016 JPM 4330 MOD A MEDIDAS - IT0185 EN AUTOMATICO
   IF SY-TCODE EQ 'PA40'.

   IF MASSN = 'Z7' and  MASSG = 'G4'.

    ELSE.

      IF <PNNNN>-INFTY = '0185' and <PNNNN>-SUBTY eq '02'. "JPM
        CALL FUNCTION 'ZCCHRMF013_GENRFC'
          EXPORTING
            pvi_pernr       = p0185-PERNR
         IMPORTING
           PVE_RFC         = P0185-ICNUM.
      ENDIF. "JPM
*
   ENDIF.

   ELSEIF SY-TCODE EQ 'PA30'.

     IF <PNNNN>-INFTY = '0185' and <PNNNN>-SUBTY eq '02'.
      CALL FUNCTION 'ZCCHRMF013_GENRFC'
       EXPORTING
         pvi_pernr       = p0185-PERNR
      IMPORTING
         PVE_RFC         = P0185-ICNUM.
     ENDIF.

   ENDIF.


 "beg JPM
      IF <PNNNN>-INFTY = '0185' and <PNNNN>-SUBTY eq 'Z1'.
*     Funcion para sacar Cuenta Omnitrans
        call function 'ZCCHRMF001_CTAOMNITRANS'
          exporting
            pernr             = p0185-pernr
            begda             = p0185-begda
          importing
            cuenta            = v_cuenta
          exceptions
            werks_desconocido = 1
            others            = 2.
        if sy-subrc eq 0.
            p0185-icnum = v_cuenta .
        endif.

      ENDIF.
" end JPM

      IF <PNNNN>-INFTY = '0185' and <PNNNN>-SUBTY eq 'ZR' AND FCODE EQ SPACE.

          DATA: IT_ZHRTT_RECLUTAMIE TYPE STANDARD TABLE OF ZHRTT_RECLUTAMIE.
          DATA: WA_ZHRTT_RECLUTAMIE TYPE ZHRTT_RECLUTAMIE.

          DATA: BEGIN OF gt_help OCCURS 0,
                  CVERE LIKE ZHRTT_RECLUTAMIE-CVERE,
                  DESRE LIKE ZHRTT_RECLUTAMIE-DESRE,
                  box, " seleccion del alv
          END OF gt_help.

          DATA: lk_zuonr LIKE vbak-zuonr,
                lk_tabix LIKE sy-tabix,
                lt_cols LIKE help_value OCCURS 0 WITH HEADER LINE.

          REFRESH: IT_ZHRTT_RECLUTAMIE.
          CLEAR: IT_ZHRTT_RECLUTAMIE.

          SELECT * FROM ZHRTT_RECLUTAMIE INTO TABLE IT_ZHRTT_RECLUTAMIE ORDER BY CVERE.

          LOOP AT IT_ZHRTT_RECLUTAMIE INTO WA_ZHRTT_RECLUTAMIE.
             gt_help-CVERE = WA_ZHRTT_RECLUTAMIE-CVERE.
             gt_help-DESRE = WA_ZHRTT_RECLUTAMIE-DESRE.
             APPEND gt_help.
          ENDLOOP.

          CLEAR lk_tabix.

          lt_cols-tabname = 'ZHRTT_RECLUTAMIE'.
          lt_cols-fieldname = 'CVERE'.
          lt_cols-selectflag = 'X'.
          APPEND lt_cols.

          lt_cols-tabname = 'ZHRTT_RECLUTAMIE'.
          lt_cols-fieldname = 'DESRE'.
          APPEND lt_cols.

          CALL FUNCTION 'MD_POPUP_SHOW_INTERNAL_TABLE'
             EXPORTING
                 title = 'Cve. fuente reclutamiento'
             IMPORTING
                 index = lk_tabix " Línea seleccionada
             TABLES
                values = gt_help
                columns = lt_cols
             EXCEPTIONS
                leave = 1
                OTHERS = 2.
          IF lk_tabix ne 0.
             read table gt_help index lk_tabix.
             if sy-subrc eq 0.
                move gt_help-CVERE to p0185-icnum.
             endif.
          endif.

        ENDIF.


ENDENHANCEMENT.
