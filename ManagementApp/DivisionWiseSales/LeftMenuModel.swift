//
//  LeftMenuModel.swift
//  G-Management
//
//  Created by Goldmedal on 12/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
public func dataFromFile(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return nil
}

class LeftMenu{
    var reports = [Reports]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["data"] as? [String: Any] {
                
                if let reports = body["Reports"] as? [[String: Any]] {
                    self.reports = reports.map { Reports(json: $0) }
                }
                
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
}

class Reports {
    var key: String?
    //var value: String?
    
    init(json: [String: Any]) {
        self.key = json["name"] as? String
        //self.value = json["value"] as? String
    }
}
