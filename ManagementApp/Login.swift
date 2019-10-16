//
//  Login.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct LoginElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: LoginData?
}

struct LoginData: Decodable {
    let userlogid, usernm, mobile, firmname: String?
    let exname, exmobile, exhead, exheadmobile: String?
    let gstno, email: String?
    let slno, branchid: Int?
    let branchnm: String?
    let stateid: Int?
    let status: String?
    let issuccess, isblock: Bool?
    let lastsynclead, uniquekey, usercat, branchadd: String?
    let branchphone, branchemail, joiningdt, dob: String?
    let designation, lstlogin, workingarea, immediatehead: String?
    let immediatehdmobile, module: String?
}
