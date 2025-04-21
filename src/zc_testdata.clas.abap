CLASS zc_testdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_TESTDATA IMPLEMENTATION.


    METHOD if_oo_adt_classrun~main.
      delete from  zoipayments where isdeleted =''." set isdeleted = ''.
    ENDMETHOD.
ENDCLASS.
