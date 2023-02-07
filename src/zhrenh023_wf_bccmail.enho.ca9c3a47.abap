"Name: \PR:RPTARQEMAIL\FO:SEND_MAIL\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH023_WF_BCCMAIL.
* " 03.11.2016 JPM 5185 marcar campo para que envie correos como copia oculta

  DATA: zdocument_data    LIKE sodocchgi1,
        zpacking_list     TYPE TABLE OF sopcklsti1,
        zcount            TYPE i,
        zsize             TYPE i,
        zindex1           TYPE i,
        zindex2           TYPE i,
        zreceivers_max    TYPE TABLE OF somlreci1 WITH HEADER LINE.

  IF update IS INITIAL.

    DESCRIBE TABLE contents LINES zcount.

    PERFORM fill_packing_list TABLES zpacking_list
                               USING zcount.
    PERFORM fill_document_data USING contents
                                     zcount
                                     subject
                               CHANGING zdocument_data.

    DATA: zsent TYPE char1.

* check max_upd, devide into blocks if necessary
    DESCRIBE TABLE receivers LINES zsize.

    zindex1 = 1.
    IF zsize > max_upd.
*   1. block
      zindex2 = max_upd.
    ELSE.
*   all
      zindex2 = zsize.
    ENDIF.

    WHILE zindex2 <= zsize.
      REFRESH zreceivers_max.
      APPEND LINES OF receivers FROM zindex1 TO zindex2 TO zreceivers_max.

      LOOP AT zreceivers_max.
        MOVE 'X' to zreceivers_max-BLIND_COPY.
        MODIFY zreceivers_max.
      ENDLOOP.

      CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
        EXPORTING
          document_data                    = zdocument_data
          put_in_outbox                    = ' '
          commit_work                      = 'X'
       IMPORTING
          sent_to_all                      = zsent
*         NEW_OBJECT_ID              =
        TABLES
          packing_list               = zpacking_list
*         object_header              =
*         CONTENTS_BIN               =
          contents_txt               = contents
*         CONTENTS_HEX               =
*         OBJECT_PARA                =
*         OBJECT_PARB                =
          receivers                        = zreceivers_max[]
        EXCEPTIONS
          too_many_receivers               = 1
          document_not_zsent                = 2
          document_type_not_exist          = 3
          operation_no_authorization       = 4
          parameter_error                  = 5
          x_error                          = 6
          enqueue_error                    = 7
          OTHERS                           = 8.

      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


      IF zindex2 = zsize.
*     all messages zsent
        EXIT.
      ELSE.
*     get next block
        zindex1 = zindex2 + 1.
        zindex2 = zindex2 + max_upd.
        IF zindex2 > zsize.
          zindex2 = zsize.
        ENDIF.
      ENDIF.

    ENDWHILE.
  ENDIF.
  Exit.
ENDENHANCEMENT.
