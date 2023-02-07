"Name: \PR:RPITRF00\IC:RPITRF_I02\SE:END\EI
ENHANCEMENT 0 ZHRENH016_DISNOM.

types: begin of ty_log,
       pernr type P_PERNR,
       msj type string,
       type type string,
      end of ty_log.

Data: v_aumento  like p0014-betrg,
      v_batch type c,
      t_log type standard table of ty_log,
      wa_log like line of t_log.

selection-screen begin of block block_ss3 with frame title text-ss3.
selection-screen begin of line.
selection-screen comment 1(30) text-p01 for field mehrproz.
selection-screen position 33.
parameters mehrproz(4) type p decimals 3 default '000.000'.
selection-screen comment (1) text-prz.
selection-screen end   of line.
selection-screen begin of line.
selection-screen comment 1(30) text-p03 for field rudif.
selection-screen position 33.
parameters:
  rudif like t510-betrg default     '000.00'.
parameters rcurr like t510f-waers modif id dis default 'MXN'.
selection-screen end   of line.
*PARAMETERS:
selection-screen begin of line.
selection-screen position 33.
parameters rutyp_d like rpuxxxxx-aus_knopf1 radiobutton group rtp.
selection-screen comment 35(12) text-p05 for field rutyp_d.
selection-screen position 48.
parameters rutyp_du like rpuxxxxx-aus_knopf2 radiobutton group rtp
                                             default 'X'.
selection-screen comment 50(12) text-p06 for field rutyp_du.
selection-screen position 63.
parameters rutyp_u like rpuxxxxx-aus_knopf3 radiobutton group rtp.
selection-screen comment 65(12) text-p07 for field rutyp_u.
selection-screen end   of line.
selection-screen end  of block block_ss3.

ENDENHANCEMENT.
