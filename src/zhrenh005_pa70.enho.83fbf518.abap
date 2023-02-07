"Name: \PR:MP200000\FO:DYNAMIC_VARIATION_TC\SE:END\EI
ENHANCEMENT 0 ZHRENH005_PA70.
*Ini CCV 15052013 Ampliacion dynpro ocultar columnas infotipo 2003

  LOOP AT <table_control>-cols INTO col.
    ASSIGN col-screen  TO <screen>.
     check <screen>-name eq 'P2003-VARIA' or <screen>-name eq 'P2003-SCHKZ' or <screen>-name eq 'P2003-ZEITY'
        or <screen>-name eq 'P2003-MODIF' or <screen>-name eq 'P2003-MOSID' or <screen>-name eq 'P2003-BEGUZ'
        or <screen>-name eq 'P2003-ENDUZ' or <screen>-name eq 'P2003-STDAZ' or <screen>-name eq 'P2003-TPKLA'
        or <screen>-name eq 'P2003-PAMOD' or <screen>-name eq 'P2003-PBEG1' or <screen>-name eq 'P2003-PEND1'
        or <screen>-name eq 'P2003-PBEZ1' or <screen>-name eq 'P2003-PUNB1' or <screen>-name eq 'P2003-PBEG2'
        or <screen>-name eq 'P2003-PEND2' or <screen>-name eq 'P2003-PBEZ2' or <screen>-name eq 'P2003-PUNB2'
        or <screen>-name eq 'P2003-TAGTY' or <screen>-name eq 'P2003-VPERN' or <screen>-name eq 'P2003-OTYPE'
        or <screen>-name eq 'P2003-PLANS' or <screen>-name eq 'P2003-SPRPS' or <screen>-name eq 'RP50M-OPERA'
        or <screen>-name eq 'RP50M-PAGEA' or <screen>-name eq 'RP50M-PAGEC' or <screen>-name eq 'P2003-MOFID'.
     col-invisible = 'X'.
     <screen>-input = off.
     <screen>-invisible = on.
    MODIFY <table_control>-cols FROM col.
  ENDLOOP.
*Fin CCV 15052013 Ampliacion dynpro ocultar columnas infotipo 2003
ENDENHANCEMENT.
