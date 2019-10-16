//
//  CatalogueList.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/8/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct CatalogueListElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CatalogueObj]
}

struct CatalogueObj: Codable {
    let categoryID: String?
    let categorynm: String?
    let subCategoryID: String?
    let subcategorynm: String?
    let divisionID: String?
    let divisionnm: String?
    let itemcode, itemnm, subcategoryurl: String?
}
