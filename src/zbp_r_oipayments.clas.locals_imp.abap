CLASS LHC_ZR_OIPAYMENTS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrOipayments
        RESULT result.

      METHODS falsedelete FOR MODIFY
      IMPORTING keys FOR ACTION ZrOipayments~falsedelete.


ENDCLASS.

CLASS LHC_ZR_OIPAYMENTS IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD falsedelete.

    MODIFY ENTITIES OF zr_oipayments IN LOCAL MODE
            ENTITY ZrOipayments
            UPDATE FIELDS ( Isdeleted )
            WITH VALUE #( FOR key in keys INDEX INTO i (
                %tky       = key-%tky
                Isdeleted = abap_true
              ) )
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).



  ENDMETHOD.


ENDCLASS.
