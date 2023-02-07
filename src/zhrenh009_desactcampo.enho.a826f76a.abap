"Name: \PR:RHCMPCOMPARE_ACTUAL_PLANNED\FO:VARIANT_INIT\SE:END\EI
ENHANCEMENT 0 ZHRENH009_DESACTCAMPO.
*Tuesday, May 21, 2013 10:14:14 GC-DES-074 Reporte Empleados por debajo de banda salarial.
CHECK sy-tcode EQ 'ZHRTR014A'.

sy-title = 'Comparación sueldo base vs sueldo mínimo puesto'.

LOOP AT ITAB.
IF ITAB-BASAL GE ITAB-CP_MIN.
DELETE ITAB.
ENDIF.
ENDLOOP.

ENDENHANCEMENT.
