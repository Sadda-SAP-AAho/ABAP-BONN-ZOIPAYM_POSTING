@Metadata.allowExtensions: true
@EndUserText.label: 'Outgoing Incoming Payments'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_OIPAYMENTS
  provider contract transactional_query
  as projection on ZR_OIPAYMENTS
{
  key Companycode,
  key Documentdate,
  key Bpartner,
  key Createdtime,
  key SpecialGlCode,
  Postingdate,
  AccountingDocumenttype,
  Glamount,
  Type,
  Businessplace,
  Sectioncode,
  Gltext,
  Glaccount,
  Housebank,
  Accountid,
  Profitcenter,
  @Semantics.currencyCode: true
  Currencycode,
  Assignmentreference,
  Isdeleted,
  Isposted,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
}
where Isposted = '' and Isdeleted = ''
