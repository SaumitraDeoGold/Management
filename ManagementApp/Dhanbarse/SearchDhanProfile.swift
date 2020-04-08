//
//  SearchDhanProfile.swift
//  ManagementApp
//
//  Created by Goldmedal on 05/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SearchDhanProfile: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SearchDhanProfileObj]
}

// MARK: - Datum
struct SearchDhanProfileObj: Codable {
    let slNo, userCat, categorynm, userName: String?
    let userSurname, mobileNo, dateOfBirth, sex: String?
    let refCode, email, hmaddress, hmaddress1: String?
    let hmstate, statenm, hmdistrict, distrctnm: String?
    let hmcity, citynm, hmpincode, cin: String?
    let addressTypeID, shopName, gstNo, deluid: String?
    let gstscan: String?
    let shopPhoto, shopEstCerti, profilephoto: String?
    let wrkaddress, wrkaddress1, wrkstate, wrkdistrict: String?
    let wrkcity, wrkpincode, workAddressTypeID, wrkstatenm: String?
    let wrkdistrictnm, wrkcitynm, kycdocumentNo1: String?
    let documentimglink1: String?
    let kycDocMasterId1, kycdocumentNo2, documentimglink2, kycDocMasterId2: String?
    let approvalStatus, addressTypeId, workAddressTypeId: String?
    
}
