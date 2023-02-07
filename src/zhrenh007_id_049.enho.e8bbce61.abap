"Name: \PR:SAPLHRBEN00SUBSCREENS\FO:BUILD_PERSON_TREE\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH007_ID_049.
*  BREAK prodriguez.

    data: _temp_error_table type table of rpbenerr with header line.

* Initialize
  refresh: g_selected_persons.

* Create tree
  if person_tree_created is initial.
    perform create_person_tree.
  endif.

* Generate tree
  call function 'HR_BEN_GENERATE_PERSON_TREE'
       exporting
            reaction    = no_msg
       importing
            subrc       = subrc
       tables
            node_table  = person_node_table
            item_table  = person_item_table
            person_list = g_person_list
            error_table = _temp_error_table.

* Delete nodes
  if person_tree_filled eq true.
    call method person_tree_control->delete_all_nodes
      exceptions
        failed            = 1
        cntl_system_error = 2.
    if sy-subrc <> 0.
      message a015(hrben00treereports).
    else.
      person_tree_filled = false.
    endif.
  endif.

* Fill tree control
  call method person_tree_control->add_nodes_and_items
    exporting
      node_table                = person_node_table
      item_table                = person_item_table
      item_table_structure_name = 'RPBENTREEITEM'
    exceptions
      failed                         = 1
      cntl_system_error              = 3
      error_in_tables                = 4
      dp_error                       = 5
      table_structure_name_not_found = 6.
  if sy-subrc <> 0.
    message a015(hrben00treereports).
  else.
    person_tree_filled = true.
  endif.

* Expand nodes
  if g_expand_table[] is initial.
    call method person_tree_control->expand_root_nodes
      exporting
        level_count    = 5
        expand_subtree = true
      exceptions
        failed              = 1
        illegal_level_count = 2
        cntl_system_error   = 3.
  else.
    loop at g_expand_table.
      read table node_table with key node_key = g_expand_table
        transporting no fields.
      if sy-subrc ne 0.
        delete g_expand_table.
      endif.
    endloop.
    call method person_tree_control->expand_nodes
      exporting
        node_key_table          = g_expand_table[]
      exceptions
        failed                  = 1
        dp_error                = 2
        cntl_system_error       = 3
        error_in_node_key_table = 4.
  endif.

  EXIT.

ENDENHANCEMENT.
