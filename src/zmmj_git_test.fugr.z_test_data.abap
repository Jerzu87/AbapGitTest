FUNCTION z_test_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_DATE) TYPE  SY-DATUM
*"     REFERENCE(IV_TIME) TYPE  SY-UZEIT
*"     REFERENCE(IV_TZONE) TYPE  TZNZONE
*"     REFERENCE(GIT) TYPE  ZMMJ_E_GIT OPTIONAL
*"----------------------------------------------------------------------

  " Jeżeli parametr GIT jest ustawiony na 'X', to wychodzimy z modułu i nic nie wyświetlamy
  IF git = 'X'.
    RETURN.
  ENDIF.

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
        lx_msg      TYPE REF TO cx_salv_msg,
        lv_timestamp TYPE timestampl.

  " 1. Konwersja daty i czasu lokalnego na wewnętrzny znacznik czasu (UTC)
  " Uwzględnia strefę czasową podaną przez parametry wejściowe
  CONVERT DATE iv_date TIME iv_time INTO TIME STAMP lv_timestamp TIME ZONE iv_tzone.

  IF sy-subrc <> 0.
    WRITE: / 'Błąd: Nie można przetworzyć podanej daty/czasu dla strefy:', iv_tzone.
    RETURN.
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

ENDFUNCTION.