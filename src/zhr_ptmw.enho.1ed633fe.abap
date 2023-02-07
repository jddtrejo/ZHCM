"Name: \TY:CL_PT_UIA_TMW_APPT_READER\IN:IF_PT_UIA_TMW_APPT_READER\ME:REFRESH_APPOINTMENTS\SE:END\EI
ENHANCEMENT 0 ZHR_PTMW.
*FSWABAP: Eliminar registros de tabla "Calendario" En Trx. PTMW cuando
*         dan error en validaciones de EXIT: ZXHRTIM00DVEXITU02 .
  DATA: vl_value TYPE string,
        vl_date  TYPE datum,
        lo_appointment TYPE REF TO if_pt_appointment,
        vl_index TYPE sy-tabix,
        vl_no_delete  TYPE xfeld.

  "Importar CC Nomina desde Memoria.
  IMPORT vl_value TO vl_value FROM MEMORY ID 'ZPTMW_CCNOM'.
  "Importar Fecha CC Nomina desde Memoria.
  IMPORT im_date  TO vl_date FROM MEMORY ID 'ZPTMW_DATE'.
  "Importar Flag de eliminación de appointment.
  IMPORT vl_no_delete  TO vl_no_delete FROM MEMORY ID 'ZPTMW_DELETE'.

  IF vl_no_delete IS INITIAL.
"-- Eliminar Registro de tabla appointments.
    IF vl_value IS NOT INITIAL AND vl_date IS NOT INITIAL.

      "Seleccionar registro a borrar.
      LOOP AT ex_appointments INTO lo_appointment.

        IF    lo_appointment->date_from EQ vl_date
          AND lo_appointment->descr_1_s EQ vl_value.
          vl_index = sy-tabix.
          EXIT.
        ENDIF.
        CLEAR: lo_appointment.
      ENDLOOP.

      IF vl_index GT 0.
        "Flag Para No Pasar por la eliminacion del appointment.
        vl_no_delete = 'X'.
        EXPORT vl_no_delete FROM vl_no_delete TO MEMORY ID 'ZPTMW_DELETE'.

        "Marcar Appointment para Borrado.
        CALL METHOD me->if_pt_uia_tmw_appt_reader~delete_appointment
           EXPORTING
             im_appointment          = lo_appointment.

        "Refrescar la tabla para aplicar el borrado del appointment.
        CALL METHOD me->if_pt_uia_tmw_appt_reader~refresh_appointments
          EXPORTING
            im_employee             = im_employee
            im_date_from            = im_date_from                    "YJS V3S
            im_date_to              = im_date_to                    "YJS V3S
            im_view                 = im_view
            im_force_refresh        = im_force_refresh
          IMPORTING
            ex_appointments         = ex_appointments
            ex_appointments_changed = ex_appointments_changed
            ex_calendar_definition  = ex_calendar_definition
            ex_message_tab          = ex_message_tab
          EXCEPTIONS
            failed                  = 1.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: vl_value, vl_date, vl_index, lo_appointment, vl_no_delete.
  FREE MEMORY ID: 'ZPTMW_CCNOM', 'ZPTMW_DATE', 'ZPTMW_DELETE'.
ENDENHANCEMENT.
