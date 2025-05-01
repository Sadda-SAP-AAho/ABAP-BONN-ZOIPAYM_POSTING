


sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/odata/v2/ODataModel",
    "sap/m/MessageToast",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/core/BusyIndicator"
], function (Controller, ODataModel, MessageToast, Filter, FilterOperator,BusyIndicator) {
    "use strict";
    return Controller.extend("zincopaymupd.controller.Upload", {

        onInit() {
            this.oDataModel = new ODataModel("/sap/opu/odata/sap/ZUI_OIPAYMENTS_O2/", {
                defaultCountMode: "None"
            });
        },
        onClickDelete() {
            let selectedData = this.byId("RespTable").getSelectedItems(),
                that = this;
            BusyIndicator.show();

            this.oDataModel.setDeferredGroups(["deleteItems"]);
            for (let index = 0; index < selectedData.length; index++) {
                const element = selectedData[index].getBindingContext()?.getObject() || {};

                if (!element) continue;

                this.oDataModel.create("/falsedelete", {}, {
                    urlParameters: {
                        "Companycode": `'${element.Companycode}'`,
                        "Documentdate": `'${element.Documentdate}'`,
                        // "Documentdate": `datetime'${element.Documentdate.toISOString().replace("Z", "")}'`,
                        "Bpartner": `'${element.Bpartner}'`,
                        "Createdtime": `time'PT${Math.floor(element.Createdtime.ms / 3600000)}H${Math.floor(element.Createdtime.ms / 60000) % 60}M${Math.floor(element.Createdtime.ms / 1000) % 60}S'`,
                        "SpecialGlCode": `'${element.SpecialGlCode}'`,

                    },
                    headers: {
                        "If-Match": "*"
                    },
                    success: function () {
                        that.byId("_IDGenSmartTable").rebindTable(true);
                        BusyIndicator.hide();
                    }

                })

            }

        },
        onClickPost() {
            let selectedData = this.byId("RespTable").getSelectedItems(),
                that = this;

            let data = selectedData.map((item) => {
                const element = item.getBindingContext()?.getObject() || {};


                return {
                    "Companycode": element.Companycode,
                    "Documentdate": element.Documentdate,//.toISOString().replace("T00:00:00.000Z", "").replace(/-/g, ""),
                    "Bpartner": element.Bpartner,
                    "Createdtime": `${Math.floor(element.Createdtime.ms / 3600000).toString().padStart(2, '0')}${(Math.floor(element.Createdtime.ms / 60000) % 60).toString().padStart(2, '0')}${(Math.floor(element.Createdtime.ms / 1000) % 60).toString().padStart(2, '0')}`
                }
            })

            BusyIndicator.show();

            $.ajax({
                url: '/sap/bc/http/sap/ZHTTP_OIPAYMPOST',
                method: "POST",
                contentType: "application/json",
                data: JSON.stringify(data),
                success: function (response) {
                    MessageToast.show(response);
                    that.byId("_IDGenSmartTable").rebindTable(true);
                    BusyIndicator.hide();
                },
                error: function (error) {
                    MessageToast.show("Upload failed: " + (error.responseText || "Unknown error"));
                    BusyIndicator.hide();
                }
            });

        },
        browseAndUpload(oEvent) {
            var that = this;
            var file = oEvent.getParameter("files") && oEvent.getParameter("files")[0];
            if (!file) {
                console.error("No file selected.");
                return;
            }
            if (window.FileReader) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var data = e.target.result;
                    try {
                        var workbook = XLSX.read(data, {
                            type: 'binary'
                        });
                        if (!workbook.SheetNames || workbook.SheetNames.length === 0) {
                            MessageToast.show("No sheets found in the Excel file.");
                            return;
                        }
                        var excelData = [];
                        var headers = [];
                        let datas = [];
                        workbook.SheetNames.forEach(function (sheetName) {
                            var worksheet = workbook.Sheets[sheetName];
                            excelData = XLSX.utils.sheet_to_row_object_array(worksheet);
                            headers = XLSX.utils.sheet_to_json(worksheet, { header: 1 })[0];
                            excelData.forEach((element) => {
                                 // const [day, month, year] = element["Document Date"].toString().split("-");
                                // const formattedDate = `${year}${month}${day}`;
                                // const [day1, month1, year1] = element["Posting Date"].toString().split("-");
                                // const formattedDate2 = `${year1}${month1}${day1}`;
                                datas.push({
                                    Companycode: element["Company Code"].toString(),
                                    Documentdate: element["Document Date"].toString(),
                                    Postingdate: element["Posting Date"].toString(),
                                    Currencycode: element["Currency Code"].toString(),
                                    Bpartner: element["Customer"].toString(),
                                    Glamount: element["Amount"],
                                    Businessplace: element["Business Place"].toString(),
                                    Sectioncode: element["Section Code"].toString(),
                                    Gltext: element["Text"].toString(),
                                    Glaccount: element["G/L Account"].toString(),
                                    Housebank: element["House Bank"].toString(),
                                    Accountid: element["Account Id"].toString(),
                                    Profitcenter: element["Profit Center"].toString(),
                                    AssignmentReference: element["Assignment"].toString(),

                                });
                            });

                            BusyIndicator.show();
                            $.ajax({
                                url: '/sap/bc/http/sap/ZHTTP_INCOMINGPAYM',
                                method: "POST",
                                contentType: "application/json",
                                data: JSON.stringify(datas),
                                success: function (response) {
                                    MessageToast.show(response);
                                    that.byId("_IDGenSmartTable").rebindTable(true);
                                    BusyIndicator.hide();
                                },
                                error: function (error) {
                                    MessageToast.show("Upload failed: " + (error.responseText || "Unknown error"));
                                    BusyIndicator.hide();
                                }
                            });

                        });

                    } catch (error) {
                        console.error("Error parsing the Excel file: ", error);
                        BusyIndicator.hide();
                    }
                };
                reader.onerror = function (error) {
                    console.error("Error reading file: ", error);
                };
                reader.readAsBinaryString(file);
            } else {
                console.error("FileReader is not supported in this browser.");
            }
        },
        beforerRebind(e) {
            var b = e.getParameter("bindingParams");
            var aDateFilters = []

            aDateFilters.push(new Filter("Type", FilterOperator.EQ, 'INCO'))
            if (!aDateFilters.length) return
            var oOwnMultiFilter = new Filter(aDateFilters, true);

            if (b.filters[0] && b.filters[0].aFilters) {
                var oSmartTableMultiFilter = b.filters[0];
                b.filters[0] = new Filter([oSmartTableMultiFilter, oOwnMultiFilter], true);
            } else {
                b.filters.push(oOwnMultiFilter);
            }

        }

    })
})
