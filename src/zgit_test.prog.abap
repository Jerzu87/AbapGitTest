*&---------------------------------------------------------------------*
*& Report ZGIT_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgit_test.

TYPES: BEGIN OF ty_result,
         tzone    TYPE tznzone,
         descript TYPE ttzzt-descript,
         date     TYPE sy-datum,
         time     TYPE sy-uzeit,
       END OF ty_result.

DATA: lt_result   TYPE TABLE OF ty_result,
      ls_result   TYPE ty_result,
      lt_ttzz     TYPE TABLE OF ttzz,
      ls_ttzz     TYPE ttzz,
      lt_ttzzt    TYPE TABLE OF ttzzt,
      ls_ttzzt    TYPE ttzzt,
      lo_alv      TYPE REF TO cl_salv_table,
      lx_msg      TYPE REF TO cx_salv_msg.

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
