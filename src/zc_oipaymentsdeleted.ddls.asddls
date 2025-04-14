@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'OI Payments Deleted CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_OIPAYMENTSDELETED
provider contract transactional_query
  as projection on ZR_OIPAYMENTS
{
  key Companycode,
  key Documentdate,
  key Bpartner,
  Postingdate,
  Glamount,
  Businessplace,
  Sectioncode,
  Gltext,
  Glaccount,
  Buamount,
  Housebank,
  Accountid,
  Profitcenter,
  Butext,
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
where Isposted = '' and Isdeleted = 'X'

