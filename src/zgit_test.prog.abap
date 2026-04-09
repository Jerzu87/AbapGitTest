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

  DATA: lv_timestamp TYPE timestampl.

  " 1. Konwersja daty i czasu lokalnego na wewnętrzny znacznik czasu (UTC)
  " Uwzględnia strefę czasową podaną na ekranie selekcji
  CONVERT DATE p_date TIME p_time INTO TIME STAMP lv_timestamp TIME ZONE p_tzone.

  IF sy-subrc <> 0.
    WRITE: / 'Błąd: Nie można przetworzyć podanej daty/czasu dla strefy:', p_tzone.
    EXIT.
  ENDIF.

  " 2. Pobranie wszystkich dostępnych stref czasowych i ich opisów
  SELECT * FROM ttzz INTO TABLE @lt_ttzz.
  IF sy-subrc = 0.
    SELECT * FROM ttzzt INTO TABLE @lt_ttzzt
      FOR ALL ENTRIES IN @lt_ttzz
      WHERE tzone = @lt_ttzz-tzone
        AND langu = @sy-langu.
  ENDIF.

  " 3. Przeliczenie czasu dla każdej strefy
  LOOP AT lt_ttzz INTO ls_ttzz.
    CLEAR ls_result.
    ls_result-tzone = ls_ttzz-tzone.

    " Szukamy opisu dla strefy
    READ TABLE lt_ttzzt INTO ls_ttzzt WITH KEY tzone = ls_ttzz-tzone.
    IF sy-subrc = 0.
      ls_result-descript = ls_ttzzt-descript.
    ENDIF.

    " Konwersja czasu na daną strefę
    CONVERT TIME STAMP lv_timestamp TIME ZONE ls_result-tzone
            INTO DATE ls_result-date TIME ls_result-time.

    " Jeśli system zwróci sy-subrc <> 0, dodajemy rekord z wyczyszczoną datą/czasem,
    " co już zostało obsłużone przez CLEAR na początku pętli. Ale dodajemy tylko poprawne.
    IF sy-subrc = 0.
      APPEND ls_result TO lt_result.
    ENDIF.
  ENDLOOP.

  " 4. Wyświetlenie wyników przy pomocy ALV
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = lt_result ).

      " Dodanie standardowych funkcji do ALV (sortowanie, filtrowanie itp.)
      lo_alv->get_functions( )->set_all( abap_true ).

      lo_alv->display( ).

    CATCH cx_salv_msg INTO lx_msg.
      WRITE: / 'Błąd podczas tworzenia ALV'.
  ENDTRY.

  CALL FUNCTION 'Z_TEST_DATA'.
