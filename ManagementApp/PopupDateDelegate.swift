//
//  PopupDateDelegate.swift
//  
//
//  Created by Goldmedal on 4/23/18.
//

import Foundation

@objc protocol PopupDateDelegate {
    @objc optional func updateDate(value: String, date: Date)
    @objc optional func updateValue(value: String,from: String)
    @objc optional func updatePositionValue(value: String,position: Int,from: String)
    @objc optional func updateEnquiry(value: String,slNo: String)
    @objc optional func updateBankList(value: String,utrn: String,amount: String)
    @objc optional func showValue(value: String)
    @objc optional func showCartValue(value: String)
    @objc optional func updateOutsDaysValue(value: String,position: Int)
    @objc optional func updateBranch(value: String,position: Int)
    @objc optional func sortBy(value: String,position: Int)
    @objc optional func showBtnColor(value: Bool)
    @objc optional func showSemiFinal(value: Bool)
    @objc optional func showFinal(value: Bool)
    @objc optional func showParty(value: String,cin: String)
    @objc optional func showSearchValue(value: String)
    @objc optional func refreshApi()
}
