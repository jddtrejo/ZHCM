"Name: \PR:RPITRF00\FO:DISPLAY_LOG\SE:END\EI
ENHANCEMENT 0 ZHRENH016_DISNOM.
DATA: gr_table_alv   TYPE REF TO cl_salv_table,        " Objeto ALV
      gr_functions TYPE REF TO cl_salv_functions_list, " Funciones del ALV
      gr_content TYPE REF TO cl_salv_form_element.     " Cabecera

if t_log[] is not initial.
try.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = gr_table_alv
        CHANGING
          t_table      = t_log ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.
* Activar todas las funciones estandar del ALV
  gr_functions = gr_table_alv->get_functions( ).
  gr_functions->set_all( abap_true ).
* Defino cabecera
*  PERFORM build_header CHANGING gr_content.
  gr_table_alv->set_top_of_list( gr_content ).

* Mostrar ALV
  gr_table_alv->display( ).
endif.
ENDENHANCEMENT.
