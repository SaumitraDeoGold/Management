//
//  AddCatalogueData.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct AddCatalogueListElement: Codable {
        let result: Bool?
        let message, servertime: String?
        let data: [AddCatalogueObj]
    }

struct AddCatalogueObj: Codable {
        let itemid: Int?
        let categoryID, categorynm, subCategoryID, subcategorynm: String?
        let divisionID, divisionnm, itemcode, colornm: String?
        let mrp, dlp, discount, taxtype: String?
        let taxpercent, pramotionaldiscount, approveQty, unapproveQty: String?
        let cartoonQty, boxQty, unitnm: String?
        var itemQty: Int?
    }

