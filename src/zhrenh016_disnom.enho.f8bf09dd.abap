"Name: \PR:RPITRF00\FO:RE_T591S\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH016_DISNOM.
*AT SELECTION-SCREEN OUTPUT.
*PERFORM INVISIBLE.

*FORM INVISIBLE.
loop at screen.
if screen-name = '%FP01036_1000' or
screen-name = '%FP02042_1000' or
screen-name = 'MEHRPROZ' or
screen-name = 'RUDIF' or
screen-name = 'RCURR' or
screen-name = '%FP01037_1000' or
screen-name = 'RUTYP_D' or
screen-name = 'RUTYP_DU' or
screen-name = 'RUTYP_U' or
screen-name = '%_14SNS0000183671_%_%_%_%_%_%_' or
screen-name = '%FP02043_1000' OR
screen-name = '%FP01027_1000' OR
screen-name = '%FP02033_1000' OR
screen-name = '%_14SNS0000183671_%_%_%_%_%_%_'.
" screen-name = '%B006024_BLOCK_1000'.

IF  'S' in CPIND.
 screen-invisible = 0.

screen-input = 1.

%FP01249_1000 = 'Porcentaje'.

%FP03255_1000 = 'Importe Redondeo (moneda)'.

%FP05263_1000 = 'RedonDefec'.

%FP06266_1000 = 'Red.def/exc.'.

%FP07269_1000 = 'RedonEcxes'.

ELSE.
screen-invisible = 1.

screen-input = 0.

CLEAR: MEHRPROZ,
       RUDIF,
       RCURR,
       RUTYP_D,
       RUTYP_DU,
       RUTYP_U,
       HILFS_DATUM,
       %FP01249_1000,
       %FP03255_1000,
       %FP05263_1000,
       %FP06266_1000,
       %FP07269_1000.



ENDIF.
* screen-invisible = 1.
MODIFY SCREEN.
ENDIF.
endloop.

if B_INPUT = 'X'.
  v_batch = 'X'.
  clear B_INPUT.
else.
  clear v_batch.
endif.
*ENDFORM.
ENDENHANCEMENT.
