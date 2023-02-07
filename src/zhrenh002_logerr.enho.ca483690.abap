"Name: \PR:RPTEUP10\FO:SHOW_VERARBEITUNG\SE:END\EI
ENHANCEMENT 0 ZHRENH002_LOGERR.
* Inicio CCV Imprimir Log de Errores 13.05.2013
  DATA: outtab TYPE zcces001_err OCCURS 0 WITH HEADER LINE.
* Borrar el archivo del servidor
  DELETE DATASET file.

  IF protokol EQ 'X'.
    IF l_faulty_timeevents IS NOT INITIAL.

      CALL FUNCTION 'ZCCHRMF009_LOGERR'
        TABLES
          outtab = outtab.
      IF outtab[] IS NOT INITIAL.
        SUMMARY.
        FORMAT COLOR COL_BACKGROUND INTENSIFIED.
        WRITE:    'Log Err                     '
                  COLOR COL_BACKGROUND INTENSIFIED OFF.
        WRITE: /(161) sy-uline.
        FORMAT COLOR COL_HEADING.
        WRITE: / sy-vline NO-GAP.
        WRITE: (12) 'Not.CDP.   ' NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (10) 'Zeitausw. '(002) NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (10) 'Datum     '(003) NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (10) 'Uhrzeit   '(004) NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (10) 'Satzart   '(005) NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (10) 'Terminal  '(006) NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (10) 'An/Abw    '(007) NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: (80) 'Txt/Err    ' NO-GAP.
        WRITE:   sy-vline NO-GAP.
        WRITE: /(161) sy-uline.
        FORMAT COLOR COL_NORMAL.
        LOOP AT outtab.
          WRITE: / sy-vline NO-GAP.
          WRITE: (12) outtab-pdsnr no-zero no-gap,
                      sy-vline NO-GAP,
                 (10) outtab-zausw NO-ZERO NO-GAP,
                      sy-vline NO-GAP,
                 (10) outtab-ldate NO-GAP,
                      sy-vline NO-GAP,
                 (10) outtab-ltime NO-GAP,
                      sy-vline NO-GAP,
                 (10) outtab-satza NO-GAP,
                      sy-vline NO-GAP,
                 (10) outtab-terid NO-GAP,
                      sy-vline NO-GAP,
                 (10) outtab-abwgr NO-GAP,
                      sy-vline NO-GAP,
                 (80) outtab-errtext NO-GAP,
                      sy-vline NO-GAP     .
        ENDLOOP.
        WRITE: /(161) sy-uline.
      ENDIF.
    ENDIF.
  ENDIF.
* Fin CCV Imprimir Log de Errores
ENDENHANCEMENT.
