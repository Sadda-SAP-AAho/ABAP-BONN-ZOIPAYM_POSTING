CLASS zc_testdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zc_testdata IMPLEMENTATION.

    METHOD if_oo_adt_classrun~main.
      delete from  zoipayments." set isdeleted = ''.
    ENDMETHOD.

ENDCLASS.
