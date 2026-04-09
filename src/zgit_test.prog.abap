*&---------------------------------------------------------------------*
*& Report ZGIT_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgit_test.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_date  TYPE sy-datum DEFAULT sy-datum,   " Data użytkownika
            p_time  TYPE sy-uzeit DEFAULT sy-uzeit,   " Czas użytkownika
            p_tzone TYPE tznzone DEFAULT sy-zonlo.    " Strefa czasowa (domyślnie systemowa)
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  " Wywołanie głównej logiki umieszczonej w module funkcyjnym
  CALL FUNCTION 'Z_TEST_DATA'
    EXPORTING
      iv_date  = p_date
      iv_time  = p_time
      iv_tzone = p_tzone.
