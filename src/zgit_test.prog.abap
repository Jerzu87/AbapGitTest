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

  DATA: lv_timestamp TYPE timestampl,
        lv_jpn_date  TYPE sy-datum,
        lv_jpn_time  TYPE sy-uzeit.

  " 1. Konwersja daty i czasu lokalnego na wewnętrzny znacznik czasu (UTC)
  " Uwzględnia strefę czasową podaną na ekranie selekcji
  CONVERT DATE p_date TIME p_time INTO TIME STAMP lv_timestamp TIME ZONE p_tzone.

  IF sy-subrc <> 0.
    WRITE: / 'Błąd: Nie można przetworzyć podanej daty/czasu dla strefy:', p_tzone.
    EXIT.
  ENDIF.

  " 2. Konwersja znacznika czasu z powrotem na datę i czas, ale wymuszając strefę 'JAPAN'
  CONVERT TIME STAMP lv_timestamp TIME ZONE 'JAPAN'
          INTO DATE lv_jpn_date TIME lv_jpn_time.

  "--- Wyświetlenie wyników
  WRITE: / 'Dane wejściowe (', p_tzone, '):', p_date, p_time.
  ULINE.
  WRITE: / 'Wynik w formacie dla Japonii:'.
  WRITE: / 'Data Japonia:', lv_jpn_date.
  WRITE: / 'Czas Japonia:', lv_jpn_time.
