@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Outgoing Incoming Payments'
define root view entity ZR_OIPAYMENTS
  as select from zoipayments
{
  key companycode as Companycode,
  key documentdate as Documentdate,
  key bpartner as Bpartner,
  postingdate as Postingdate,
  @Semantics.amount.currencyCode: 'Currencycode'
  glamount as Glamount,
  accountingdocument as Accountingdocument,
  businessplace as Businessplace,
  sectioncode as Sectioncode,
  gltext as Gltext,
  glaccount as Glaccount,
  @Semantics.amount.currencyCode: 'Currencycode'
  buamount as Buamount,
  housebank as Housebank,
  accountid as Accountid,
  profitcenter as Profitcenter,
  butext as Butext,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currencycode as Currencycode,
  isdeleted as Isdeleted,
  isposted as Isposted,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
