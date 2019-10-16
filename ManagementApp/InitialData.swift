//
//  InitialData.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/12/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct InitialElement:Decodable {
    let result: Bool?
    let servertime, message: String?
    let data: [InitialObj]
}

struct InitialObj:Decodable {
    let versionCode, versionNumber, divisionLastUpdated, enquiryLastUpdated, iosVersion: String?
    let baseAPI: String?
    let validateUserDealer, validateCIN, verifyOTP, setPassword: String?
    let divisionSalesReport, dispatchedMaterial, pendingOrders, pendingOrdersPDF: String?
    let outstanding, priceListCatalogue, outstandingReport, creditLimit: String?
    let activeScheme, salesPaymentReport, divisionList, priceList: String?
    let sendEnquiry, sendFeedback, subjectList, salesPaymentReportDetails: String?
    let policy, technicalSpecification, brandingImages, topProductDealer: String?
    let topProductDistrict, divisionWiseYSA, ysAreport, lastYearSales: String?
    let pendingOrderDivisionWise, outstandingDivisionWise, schemeDetails, salesSummary: String?
    let catalogue, aging, document, discoverWorld: String?
    let forceUpdate: Bool?
    let comboPlaceOrder, comboCompare, ledgerAmount, comboClaim, youtubeVideo, comboDetails, comboSchemes, ledgerAmountDebit, comboTotalQuantit:String?
    let sendNotification, amountConfirmation, wheelSpins, wheelSpinsDetails,applyCN ,creditNoteDetails ,logToServer:String?
 
}


