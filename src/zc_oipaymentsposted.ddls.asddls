@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'OI Payments Posted CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_OIPAYMENTSPOSTED 
 provider contract transactional_query
  as projection on ZR_OIPAYMENTS
{
  key Companycode,
  key Documentdate,
  key Bpartner,
  key Createdtime,
  Postingdate,
  Accountingdocument,
  AccountingDocumenttype,
  Glamount,
  Businessplace,
  Sectioncode,
  Gltext,
  Glaccount,
  Housebank,
  Accountid,
  Profitcenter,
  @Semantics.currencyCode: true
  Currencycode,
  Isdeleted,
  Isposted,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
where Isposted = 'X' and Isdeleted = ''
