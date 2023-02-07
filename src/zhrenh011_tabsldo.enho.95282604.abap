"Name: \PR:RPU51000\FO:KORREKTUR_ANSCHLUSS\SE:BEGIN\EI
ENHANCEMENT 0 ZHRENH011_TABSLDO.
*
* check whether 'V_T510' is marked as "Current settings"
  CHECK g_curset EQ space.

  CLEAR: t_ko200, t_e071k.

  t_ko200-pgmid    = 'R3TR'.
  t_ko200-object   = 'VDAT'.
  t_ko200-obj_name = 'V_T510'.
  t_ko200-objfunc  = 'K'.
  APPEND t_ko200.

  LOOP AT prt_tab WHERE note NE 'O'.
    t_e071k-pgmid      = 'R3TR'.
    t_e071k-object     = 'TABU'.
    t_e071k-objname    = 'T510'.
    t_e071k-mastertype = 'VDAT'.
    t_e071k-mastername = 'V_T510'.
    t_e071k-tabkey(32) = prt_tab(32).
    APPEND t_e071k.
  ENDLOOP.

EXIT.
ENDENHANCEMENT.
