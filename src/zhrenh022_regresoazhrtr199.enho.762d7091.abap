"Name: \PR:RPU51000\FO:USER_COMMAND\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH022_REGRESOAZHRTR199.
* " 20.10.2016 JPM 4994 regreso a transaccion ZHRTR199
  DATA: v_tran TYPE sy-tcode.
  import v_tran from MEMORY id 'ZHRENH022_REGRESOAZHRTR199'.
  IF v_tran eq 'ZHRTR199'.
    "export alv_output = alv_output to memory id 'PNZ4_ALV'.
    export alv_output to memory id 'PNZ4_ALV'.
    "free MEMORY id 'ZHRENH022_REGRESOAZHRTR199'.
    "LEAVE TO SCREEN 0.
  ENDIF.
ENDENHANCEMENT.
