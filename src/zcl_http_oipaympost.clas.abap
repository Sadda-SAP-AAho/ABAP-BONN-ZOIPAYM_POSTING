class ZCL_HTTP_OIPAYMPOST definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .



  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
   CLASS-METHODS postData
    IMPORTING
      VALUE(request)  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .


   CLASS-METHODS  postCustomerPayment
       IMPORTING
        VALUE(wa_data)  TYPE zr_oipayments
        RETURNING
        VALUE(message)  TYPE STRING .

    CLASS-METHODS  postSupplierPayment
       IMPORTING
        VALUE(wa_data)  TYPE zr_oipayments
        RETURNING
        VALUE(message)  TYPE STRING .



protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_OIPAYMPOST IMPLEMENTATION.

      METHOD IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

        CASE request->get_method(  ).
          WHEN CONV string( if_web_http_client=>post ).
           response->set_text( postData( request ) ).

        ENDCASE.


      ENDMETHOD.

      METHOD postData.

        DATA: lv_oipaym TYPE TABLE OF zr_oipayments,
              wa_oipaym TYPE zr_oipayments.

        TYPES: BEGIN OF ty_json_structure,
                 companycode  TYPE c LENGTH 4,
                 documentdate TYPE c LENGTH 8,
                 bpartner     TYPE c LENGTH 10,
                 createdtime  TYPE c LENGTH 6,
               END OF ty_json_structure.

        DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

        wa-bpartner = |{ wa-bpartner ALPHA = IN }|.

          SELECT SINGLE * FROM zr_oipayments
          WHERE Companycode = @wa-companycode AND Documentdate = @wa-documentdate
                AND Bpartner = @wa-bpartner  AND Createdtime = @wa-createdtime
             INTO @DATA(wa_data).

          IF wa_data-AccountingDocumenttype = 'DZ'.
            message = postCustomerPayment( wa_data ).
          ELSEIF wa_data-AccountingDocumenttype = 'KZ'.
            message = postSupplierPayment( wa_data ).
          ENDIF.

        ENDLOOP.


      ENDMETHOD.

      METHOD postCustomerPayment.
        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
              document   TYPE string.


        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
        <je_deep>-%cid = getCid(  ).
        <je_deep>-%param = VALUE #(
        companycode = wa_data-Companycode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = 'DZ'
        CreatedByUser = sy-uname
        documentdate = wa_data-Documentdate
        postingdate = cl_abap_context_info=>get_system_date( )

        _aritems = VALUE #( ( glaccountlineitem = |001|
                                Customer = wa_data-Bpartner

                                BusinessPlace = wa_data-Businessplace
                              _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-Glamount * -1
                                                currency = wa_data-Currencycode ) ) )
                           )
        _glitems = VALUE #(
                            ( glaccountlineitem = |002|

                            glaccount = wa_data-Glaccount
                            HouseBank = wa_data-Housebank
                            HouseBankAccount = wa_data-Accountid
                            BusinessPlace = wa_data-Businessplace
                              ProfitCenter = wa_data-Profitcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-Glamount
                                                currency = wa_data-Currencycode ) ) ) )
        ).

        MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
        ENTITY journalentry
        EXECUTE post FROM lt_je_deep
        FAILED DATA(ls_failed_deep)
        REPORTED DATA(ls_reported_deep)
        MAPPED DATA(ls_mapped_deep).

        IF ls_failed_deep IS NOT INITIAL.

          LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
            message = <ls_reported_deep>-%msg->if_message~get_text( ).
          ENDLOOP.
          RETURN.
        ELSE.

          COMMIT ENTITIES BEGIN
          RESPONSE OF i_journalentrytp
          FAILED DATA(lt_commit_failed)
          REPORTED DATA(lt_commit_reported).

          IF lt_commit_reported IS NOT INITIAL.
            LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
              document = <ls_reported>-AccountingDocument.
            ENDLOOP.
          ELSE.
            LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
              message = <ls_failed>-%fail-cause.
            ENDLOOP.
            RETURN.
          ENDIF.

          COMMIT ENTITIES END.

          IF document IS NOT INITIAL.
            message = |Document Created Successfully: { document }|.
            MODIFY ENTITIES OF zr_oipayments
            ENTITY ZrOipayments
            UPDATE FIELDS ( Accountingdocument Postingdate Isposted )
            WITH VALUE #(  (
                Accountingdocument = document
                Postingdate = cl_abap_context_info=>get_system_date( )
                Isposted = abap_true
                Companycode = wa_data-Companycode
                Documentdate = wa_data-Documentdate
                Bpartner = wa_data-Bpartner
                Createdtime = wa_data-Createdtime
                )  )
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).
            COMMIT ENTITIES BEGIN
               RESPONSE OF zr_oipayments
               FAILED DATA(lt_commit_failed2)
               REPORTED DATA(lt_commit_reported2).
            ...
            COMMIT ENTITIES END.
          ELSE.
            message = |Document Creation Failed: { message }|.
          ENDIF.

        ENDIF.

      ENDMETHOD.

      METHOD postSupplierPayment.
        DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
              document   TYPE string.

        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
        <je_deep>-%cid = getCid(  ).
        <je_deep>-%param = VALUE #(
        companycode = wa_data-Companycode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = 'KZ'
        CreatedByUser = sy-uname
        documentdate = wa_data-Documentdate
        postingdate = cl_abap_context_info=>get_system_date( )

        _apitems = VALUE #( ( glaccountlineitem = |001|
                                Supplier = wa_data-Bpartner
                                BusinessPlace = wa_data-Businessplace
                              _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-Glamount
                                                currency = wa_data-Currencycode ) ) )
                           )
        _glitems = VALUE #(
                            ( glaccountlineitem = |002|
                            glaccount = wa_data-Glaccount
                            HouseBank = wa_data-Housebank
                            HouseBankAccount = wa_data-Accountid
                              ProfitCenter = wa_data-Profitcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-Glamount * -1
                                                currency = wa_data-Currencycode ) ) ) )
        ).

        MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
        ENTITY journalentry
        EXECUTE post FROM lt_je_deep
        FAILED DATA(ls_failed_deep)
        REPORTED DATA(ls_reported_deep)
        MAPPED DATA(ls_mapped_deep).

        IF ls_failed_deep IS NOT INITIAL.

          LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
            message = <ls_reported_deep>-%msg->if_message~get_text( ).
          ENDLOOP.
          RETURN.
        ELSE.

          COMMIT ENTITIES BEGIN
          RESPONSE OF i_journalentrytp
          FAILED DATA(lt_commit_failed)
          REPORTED DATA(lt_commit_reported).

          IF lt_commit_reported IS NOT INITIAL.
            LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
              document = <ls_reported>-AccountingDocument.
            ENDLOOP.
          ELSE.
            LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
              message = <ls_failed>-%fail-cause.
            ENDLOOP.
            RETURN.
          ENDIF.

          COMMIT ENTITIES END.

          IF document IS NOT INITIAL.
            message = |Document Created Successfully: { document }|.
            MODIFY ENTITIES OF zr_oipayments
            ENTITY ZrOipayments
            UPDATE FIELDS ( Accountingdocument Postingdate Isposted )
            WITH VALUE #(  (
               Accountingdocument = document
                Postingdate = cl_abap_context_info=>get_system_date( )
                Isposted = abap_true
                Companycode = wa_data-Companycode
                Documentdate = wa_data-Documentdate
                Bpartner = wa_data-Bpartner
                Createdtime = wa_data-Createdtime
                )  )
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).

          COMMIT ENTITIES BEGIN
          RESPONSE OF zr_oipayments
          FAILED DATA(lt_commit_failed2)
          REPORTED DATA(lt_commit_reported2).

          ...
          COMMIT ENTITIES END.
          ELSE.
            message = |Document Creation Failed: { message }|.
          ENDIF.

        ENDIF.

      ENDMETHOD.


      METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
      ENDMETHOD.
ENDCLASS.
