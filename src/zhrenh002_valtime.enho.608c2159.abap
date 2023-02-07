"Name: \PR:RPTEUP10\FO:SHOW_TIMEEVENT\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH002_VALTIME.
*Inicio CCV Validar tablas TEVEN y CC1TEV 13052013
DATA: it_teven TYPE teven OCCURS 0 WITH HEADER LINE.
DATA: it_cc1tev TYPE cc1tev OCCURS 0 WITH HEADER LINE.

"14.08.2013 08:00:19 JPM
DATA: time2 LIKE cc1_timeevent OCCURS 0 WITH HEADER LINE.
CLEAR time2.
REFRESH time2.
time2[] = timeevent[].

SELECT *
  FROM teven
  INTO TABLE it_teven
  FOR ALL ENTRIES IN  timeevent
  WHERE pernr EQ timeevent-pernr
    AND ldate EQ timeevent-ldate
    AND ltime EQ timeevent-ltime
    AND satza EQ timeevent-satza
    AND stokz EQ space.
IF sy-subrc EQ 0.
  LOOP AT timeevent.
    READ TABLE it_teven
      WITH KEY pernr = timeevent-pernr
               ldate = timeevent-ldate
               ltime = timeevent-ltime
               satza = timeevent-satza.
    IF sy-subrc EQ 0.
      DELETE timeevent
       WHERE pernr = it_teven-pernr
         AND ldate = it_teven-ldate
         AND ltime = it_teven-ltime
         AND satza = it_teven-satza.
    ENDIF.
  ENDLOOP.
*  ELSE.  "14.08.2013 07:59:04 JPM
ENDIF.

*  SELECT *
*  FROM cc1tev
*  INTO TABLE it_cc1tev
*  FOR ALL ENTRIES IN timeevent
*  WHERE pernr EQ timeevent-pernr
*    AND ldate EQ timeevent-ldate
*    AND ltime EQ timeevent-ltime
*    AND satza EQ timeevent-satza.
"14.08.2013 08:11:44 JPM
   SELECT *
    FROM cc1tev
    INTO TABLE it_cc1tev
    FOR ALL ENTRIES IN time2
    WHERE pernr EQ time2-pernr
      AND ldate EQ time2-ldate
      AND ltime EQ time2-ltime
      AND satza EQ time2-satza.
 IF sy-subrc eq 0.
  LOOP AT timeevent.
    READ TABLE it_cc1tev
      WITH KEY pernr = timeevent-pernr
               ldate = timeevent-ldate
               ltime = timeevent-ltime
               satza = timeevent-satza.
    IF sy-subrc EQ 0.
      DELETE timeevent
       WHERE pernr = it_teven-pernr
         AND ldate = it_teven-ldate
         AND ltime = it_teven-ltime
         AND satza = it_teven-satza.
    ENDIF.
  ENDLOOP.
 ENDIF.
*ENDIF.   "14.08.2013 07:59:20 JPM

*Fin CCV Validar tablas TEVEN y CC1TEV 13052013
ENDENHANCEMENT.
