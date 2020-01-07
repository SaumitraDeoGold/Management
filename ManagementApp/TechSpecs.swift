//
//  TechSpecs.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct TechSpecsElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TechSpecsData]
}

// MARK: - Datum
struct TechSpecsData: Codable {
    let division, subCat: String?
    let urlimg: String?
    let urlpdf: String?
}
