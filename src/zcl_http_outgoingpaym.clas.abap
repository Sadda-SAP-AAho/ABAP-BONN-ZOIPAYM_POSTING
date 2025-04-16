class ZCL_HTTP_OUTGOINGPAYM definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .

   CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
   CLASS-METHODS saveData
    IMPORTING
      VALUE(request)  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .


protected section.
private section.
ENDCLASS.



CLASS zcl_http_outgoingpaym IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.

    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).

    ENDCASE.


  ENDMETHOD.


  METHOD saveData.

    TYPES: BEGIN OF ty_json_structure,
             companycode   TYPE c LENGTH 4,
             documentdate  TYPE c LENGTH 8,
             currencycode  TYPE c LENGTH 3,
             bpartner      TYPE c LENGTH 10,
             glamount      TYPE p LENGTH 16 DECIMALS 2,
             businessplace TYPE c LENGTH 10,
             sectioncode   TYPE c LENGTH 10,
             gltext        TYPE c LENGTH 100,
             glaccount     TYPE c LENGTH 10,
             housebank     TYPE c LENGTH 10,
             accountid     TYPE c LENGTH 10,
             profitcenter  TYPE c LENGTH 10,
           END OF ty_json_structure.

    DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

    TRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

          DATA(cid) = getcid( ).
          MODIFY ENTITIES OF zr_oipayments
         ENTITY ZrOipayments
         CREATE FIELDS (
              Companycode
              Documentdate
              Bpartner
              Currencycode
              Glamount
              Businessplace
              Sectioncode
              Gltext
              Glaccount
              Housebank
              Accountid
              Profitcenter
              Createdtime
              AccountingDocumenttype )
         WITH VALUE #( (
              %cid = cid
              Companycode = wa-Companycode
              Documentdate = wa-Documentdate
              Bpartner =  |{ wa-Bpartner ALPHA = IN }|
              Currencycode = wa-Currencycode
              Glamount = wa-Glamount
              Businessplace = wa-Businessplace
              Sectioncode = wa-Sectioncode
              Gltext = wa-Gltext
              Glaccount = wa-Glaccount
              Housebank = wa-Housebank
              Accountid = wa-Accountid
              Profitcenter = wa-Profitcenter
              Createdtime = cl_abap_context_info=>get_system_time( )
              AccountingDocumenttype = 'KZ'
              ) )
          REPORTED DATA(ls_po_reported)
          FAILED   DATA(ls_po_failed)
          MAPPED   DATA(ls_po_mapped).

          COMMIT ENTITIES BEGIN
             RESPONSE OF zr_oipayments
             FAILED DATA(ls_save_failed)
             REPORTED DATA(ls_save_reported).

          IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.


  ENDMETHOD.

  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
