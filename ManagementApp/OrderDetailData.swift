//
//  OrderDetailData.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/16/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct OrderDetailElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OrderDetailData]
}

struct OrderDetailData: Codable {
    let itemid: Int?
    let categoryId,divisionId: String?
    var itemcode, mrp, dlp, discount: String?
    var taxtype,categorynm,divisionnm,colornm: String?
    var taxpercent, pramotionaldiscount,actualPromoDiscount,highestPromoAmnt: String?
    var subCategoryId,subcategorynm,approveQty,unapproveQty,cartoonQty,boxQty,unitnm: String?
    var itemQty: Int?
    var totalAmount,taxAmount,mrpAmnt,withTaxAmnt,dlpAmnt,promoAmnt,discountAmnt: String?
}

