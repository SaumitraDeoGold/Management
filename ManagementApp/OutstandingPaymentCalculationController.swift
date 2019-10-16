//
//  OutstandingPaymentCalculationController.swift
//  DealorsApp
//
//  Created by Goldmedal on 1/28/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import AMPopTip

//0 = red, 1 = green, 2 = gray

class OutstandingPaymentCalculationController: UIViewController,UITextFieldDelegate,OutstandingAmountDelegate,PopupDateDelegate{
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var edtAmount: UITextField!
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var vwCalculateAmount: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var lblDueAmount: UILabel!
    @IBOutlet weak var lblOverDueAmount: UILabel!
    @IBOutlet weak var lblBalanceAmount: UILabel!
    @IBOutlet weak var lblOutsAmount: UILabel!
    @IBOutlet weak var lblTotalSavings: UILabel!
    
    var OutstandingReportElementMain = [OutstandingReportElement]()
    var OutstandingReportDataMain = [OutstandingReportData]()
    var OutstandingReportArray = [OutstandingReportObject]()
    
    var OutstandingReportPaymentDummyArr = [OutstandingReportObject]()
    var OutstandingReportPaymentMainArr = [OutstandingPlacedObject]()
    
    var OutstandingReportMainArray = [[OutstandingReportObject]]()
    var OutstandingReportDueArray = [OutstandingReportObject]()
    var OutstandingReportOverdueArray = [OutstandingReportObject]()
    
    var OutstandingPaymentDetailElementMain = [OutstandingPaymentDetailReportElement]()
    var OutstandingPaymentDetailDataMain = [OutstandingPaymentDetailObj]()
    var OutstandingPaymentDetailArrayToPass = [OutsInvoiceObj]()
    
    var outsPaymentSectionArr = [String]()
    var arrOutsTotalAmount = [Int]()
    
    @IBOutlet weak var noDataView: NoDataView!
    
    var strCin = ""
    var outstandingReportApi=""
    var outstandingPaymentLocalApi=""
    var strDeviceId = ""
    var cinReceived = ""
    
    let MAX_LENGTH_QTY = 7
    let ACCEPTABLE_NUMBERS = "0123456789"
    var totalAmount = "0"
    var totalSavings = 0
    
    var remainingAmnt: Int = 0
    var showAmnt: Int = 0
    var dueAmnt: Double = 0
    var overdueAmnt: Double = 0
    var outsTotalAmnt: Int = 0
    var enteredAmnt: Int = 0
    var balanceAmnt: Int = 0
    var edtTotalAmount = "0"
    var calculatedDiscount = 0
    var maxValue = 0
    
    var payableAmount = 0
    
    var extraPercentValue = 0.0
    
    var maintainDueSequence = Bool()
    var isRegistered = Bool()
    
    var txtToolTip = "Amount on left side is the CD amount and Amount on the right side is the online payment launching discount"
    let popTip = PopTip()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        cinReceived = appDelegate.sendCin
        self.noDataView.hideView(view: self.noDataView)
        
        strDeviceId = UIDevice.current.identifierForVendor!.uuidString
        if(strDeviceId.isEqual("")){
            strDeviceId = "-"
        }
        
        print("DUE SEQUENCE - - - ",maintainDueSequence)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        outstandingReportApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["freepayOutstandingReport"] as? String ?? "")
        outstandingPaymentLocalApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["checkOutstandingPaymentDetails"] as? String ?? "")
        //        outstandingReportApi = "https://api.goldmedalindia.in//api/getFreepayOutstandingReport"
        //        outstandingPaymentLocalApi = "https://api.goldmedalindia.in/api/CheckOutstandingPaymentDetails"
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            self.apiOutstandingReport()
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.lblTotalSavings.text = Utility.formatRupee(amount: Double(0))
        
        payableAmount = 0
        btnPayment.setTitle("Actual Payable : \(Utility.formatRupee(amount: Double(payableAmount)))", for: .normal)
        
        edtAmount.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        
        edtAmount.delegate = self
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(OutstandingReportController.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
        
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunctionInfo))
        imvInfo.addGestureRecognizer(tapInfo)
        imvInfo.isUserInteractionEnabled = true
        
        
        Analytics.setScreenName("OUTSTANDING CALCULATE SCREEN", screenClass: "OutstandingReportController")
//        SQLiteDB.instance.addAnalyticsData(ScreenName: "OUTSTANDING CALCULATE SCREEN", ScreenId: Int64(GlobalConstants.init().OUTSTANDING_CALCULATION))
        
    }
    
    
    
    @objc func tapFunctionInfo(sender:UITapGestureRecognizer) {
        
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTip, direction: .none, maxWidth: 300, in: view, from: vwCalculateAmount
            .frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
    
    // - - -  - - Textfield change event  -  - - - - - - - - -
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("TEXT DID CHANGE")
        if(textField == self.edtAmount){
            totalAmount = textField.text!
            
            if(!totalAmount.isEmpty && !(Double(totalAmount)?.isNaN)!){
                calculateWithTotalAmount(amount: totalAmount)
            }else{
                totalAmount = "0"
                calculateWithTotalAmount(amount: totalAmount)
            }
        }
    }
    
    // - - - - - Prevent user from entering more then outstanding amount in textfield - - - -- --
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("TEXT RANGE")
        
        maxValue = textField.tag
        
        if(textField == self.edtAmount) {
            return validateMaxValue(textField: textField, maxValue: maxValue, range: range, replacementString: string)
        }
        else {
            return validateMaxValue(textField: textField, maxValue: maxValue, range: range, replacementString: string)
            
        }
        return true
        
    }
    
    func validateMaxValue(textField: UITextField, maxValue: Int, range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString.count == 0 && string == "0" {
            return false
        }
        
        //if delete all characteres from textfield
        if(newString.isEmpty) {
            return true
        }
        
        //check if the string is a valid number
        let numberValue = Int(newString)
        
        if(numberValue == nil) {
            return false
        }
        
        return (numberValue ?? 0) <= maxValue
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // - - - -  - - - Delegate method of amount in tableview for button checkbox - - - - - -  - -
    func UpdateCheckbox(cell: OutstandingReportCell) {
        var indexPath = self.tableView.indexPath(for: cell)
        
        if((OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].isBtnEnable ?? false)!){
            if((OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].isChecked ?? 0)! == 0){
                // checkbox is red
                var outsAmntReqd = self.OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].prevOutstandingAmt ?? "0"
                self.calculateWithTableAmount(cell: cell, amount: outsAmntReqd, section:(indexPath?.section)!, row:(indexPath?.row)!)
            }else if((OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].isChecked ?? 0)! == 1){
                // checkbox is green
                self.calculateWithTableAmount(cell: cell, amount: "0", section:(indexPath?.section)!, row:(indexPath?.row)!)
            }else{
                // checkbox is gray
                self.calculateWithTableAmount(cell: cell, amount: "0", section:(indexPath?.section)!, row:(indexPath?.row)!)
            }
        }else{
            alertClearDueOverdue()
        }
    }
    
    
    func alertClearDueOverdue(){
        
        var isPartialFilled = false
        var isOverDueEmpty = false
        var isDueEmpty = false
        
        if(OutstandingReportMainArray.count>0 && OutstandingReportMainArray[0].count > 0){
            for i in 0...((self.OutstandingReportMainArray[0].count) - 1){
                if((self.OutstandingReportMainArray[0][i].duestatus ?? "")!.elementsEqual("OverDue")){
                    //for overdue
                    if(self.OutstandingReportMainArray[0][i].isChecked == 0 || self.OutstandingReportMainArray[0][i].isChecked == 2){
                        isOverDueEmpty = true
                    }
                }else{
                    //for due
                    if(self.OutstandingReportMainArray[0][i].isChecked == 0){
                        isDueEmpty = true
                    }else if(self.OutstandingReportMainArray[0][i].isChecked == 2){
                        isPartialFilled = true
                    }
                }
            }
        }
        
        if(OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
            for i in 0...((self.OutstandingReportMainArray[1].count) - 1){
                //for due
                if(self.OutstandingReportMainArray[1][i].isChecked == 0){
                    isDueEmpty = true
                }else if(self.OutstandingReportMainArray[1][i].isChecked == 2){
                    isPartialFilled = true
                }
            }
        }
        
        if(isOverDueEmpty){
            var alert = UIAlertView(title: "Clear OverDue", message: "Make sure all your Overdues are cleared", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        
        if(isPartialFilled){
            var alert = UIAlertView(title: "Partial Amount", message: "Make sure only one partial payment is allowed", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        
        if(isDueEmpty){
            var alert = UIAlertView(title: "Clear Due", message: "Make sure all your dues are cleared", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        
    }
    
    // - - - -  - - - Delegate method of amount in tableview for textfield - - - - - -  - -
    func UpdateAmount(cell: OutstandingReportCell) {
        
        var indexPath = self.tableView.indexPath(for: cell)
        
        if((OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].isBtnEnable ?? false)!){
            var outsVarAmount = (self.OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].prevOutstandingAmt ?? "0")!
            
            let alertController = UIAlertController(title: "OUTSTANDING AMOUNT", message: "Required outstanding amount \(outsVarAmount)", preferredStyle: .alert)
            
            
            //the confirm action taking the inputs
            let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
                
                //getting the input values from user
                self.edtTotalAmount = (alertController.textFields?[0].text)!
                
                if(self.edtTotalAmount.count == 0){
                    self.edtTotalAmount = "0"
                }
                
                self.calculateWithTableAmount(cell: cell, amount: self.edtTotalAmount, section:(indexPath?.section)!, row:(indexPath?.row)!)
            }
            
            //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            //adding textfields to our dialog box
            alertController.addTextField { (textField) in
                textField.placeholder = "ENTER AMOUNT"
                textField.tag = Int(outsVarAmount)!
                textField.delegate = self
            }
            
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
        }else{
            alertClearDueOverdue()
        }
    }
    
    
    
    // - - - -  Calculate outstanding amount from table into lumsum amount  - - - - - - - -
    func calculateWithTableAmount(cell:OutstandingReportCell, amount:String, section:Int,row:Int){
        print("IN TABLE - - ",OutstandingReportMainArray)
        
        // - - - -  - logic for due to avoid multiple partial payment in no sequnetial flow - - - - - - -
        if(!self.maintainDueSequence && (self.OutstandingReportMainArray[section][row].duestatus ?? "")!.elementsEqual("Due")){
            if(OutstandingReportMainArray.count>0 && OutstandingReportMainArray[0].count > 0){
                if((self.OutstandingReportMainArray[0][0].duestatus)!.elementsEqual("Due")){
                    
                    var indexOfDue = -1
                    indexOfDue = self.OutstandingReportMainArray[0].index {($0.isChecked ?? 0)! == 2} ?? -1
                    
                    print("INDEX - - - ",indexOfDue," - - - - ",row)
                    
                    if(indexOfDue != -1 && row != indexOfDue){
                        if(Int(amount ?? "0")! > 0 && (Int(amount ?? "0")! < Int(self.OutstandingReportMainArray[section][row].prevOutstandingAmt ?? "0")!)){
                            
                            var alert = UIAlertView(title: "Partial Due", message: "Make sure only one partial is allowed", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                            
                            return
                        }
                    }
                }
            }
            
            if(OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
                if((self.OutstandingReportMainArray[1][0].duestatus ?? "")!.elementsEqual("Due")){
                    
                    var indexOfDue = -1
                    indexOfDue = self.OutstandingReportMainArray[1].index {($0.isChecked ?? 0)! == 2} ?? -1
                    
                    print("INDEX 1 - - - ",indexOfDue," - - - - ",row)
                    
                    if(indexOfDue != -1 && row != indexOfDue){
                        if(Int(amount ?? "0")! > 0 && (Int(amount ?? "0")! < Int(self.OutstandingReportMainArray[section][row].prevOutstandingAmt ?? "0")!)){
                            
                            var alert = UIAlertView(title: "Partial Due", message: "Make sure only one partial payment is allowed", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                            
                            return
                        }
                    }
                }
            }
        }
        
        
        
        // - - -  - - for changes in overdue amount  - - - - -  - -
        if(section == 0){
            self.OutstandingReportMainArray[section][row].totalAmount = amount
            
            var cdPercent = Double(self.OutstandingReportMainArray[section][row].percent ?? "0")!
            
            var totalSavedPercent = cdPercent + self.extraPercentValue
            
            var tempSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! * totalSavedPercent/100).rounded())
            
            var tempCdSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! * cdPercent/100).rounded())
            
            var tempExtraSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! * self.extraPercentValue/100).rounded())
            
            self.OutstandingReportMainArray[section][row].savedAmount =  String(tempSavedAmount)
            self.OutstandingReportMainArray[section][row].totalExtraSavedAmount =  String(tempExtraSavedAmount)
            self.OutstandingReportMainArray[section][row].totalCdSavedAmount =  String(tempCdSavedAmount)
            
            
            if(Int(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! == Int(self.OutstandingReportMainArray[section][row].prevOutstandingAmt ?? "0")!){
                self.OutstandingReportMainArray[section][row].isChecked = 1
            }else if(Int(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! > 0){
                self.OutstandingReportMainArray[section][row].isChecked = 2
            }else{
                self.OutstandingReportMainArray[section][row].isChecked = 0
            }
            
            if(OutstandingReportMainArray.count>0 && OutstandingReportMainArray[0].count > 0){
                
                // - - - - - setting overdue here is array has 2 element else due here - - - - - - -
                for i in 0...((self.OutstandingReportMainArray[0].count) - 1){
                    if(!self.maintainDueSequence){
                        if((self.OutstandingReportMainArray[0][0].duestatus ?? "")!.elementsEqual("Due")){
                            
                        }else{
                            if(i >= (row+1)){
                                self.OutstandingReportMainArray[0][i].totalAmount = "0"
                                
                                self.OutstandingReportMainArray[0][i].savedAmount = "0"
                                self.OutstandingReportMainArray[0][i].totalExtraSavedAmount = "0"
                                self.OutstandingReportMainArray[0][i].totalCdSavedAmount = "0"
                                
                                
                                self.OutstandingReportMainArray[0][i].isChecked = 0
                            }
                        }
                        
                    }else{
                        if(i >= (row+1)){
                            self.OutstandingReportMainArray[0][i].totalAmount = "0"
                            
                            self.OutstandingReportMainArray[0][i].savedAmount = "0"
                            self.OutstandingReportMainArray[0][i].totalExtraSavedAmount = "0"
                            self.OutstandingReportMainArray[0][i].totalCdSavedAmount = "0"
                            
                            self.OutstandingReportMainArray[0][i].isChecked = 0
                        }
                    }
                    
                }
            }
            
            // - - -- reset due here if overdue exist -  - - - - - -
            if(OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
                
                for j in 0...((self.OutstandingReportMainArray[1].count) - 1){
                    self.OutstandingReportMainArray[1][j].totalAmount = "0"
                    
                    self.OutstandingReportMainArray[1][j].savedAmount = "0"
                    self.OutstandingReportMainArray[1][j].totalExtraSavedAmount = "0"
                    self.OutstandingReportMainArray[1][j].totalCdSavedAmount = "0"
                    
                    self.OutstandingReportMainArray[1][j].isChecked = 0
                }
            }
        }
            // - - -  - - for changes in due amount  - - - - -  - -
        else{
            self.OutstandingReportMainArray[section][row].totalAmount = amount
            
            var cdPercent = Double(self.OutstandingReportMainArray[section][row].percent ?? "0")!
            
            var totalSavedPercent = cdPercent + self.extraPercentValue
            
            var tempSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! * totalSavedPercent/100).rounded())
            
            var tempCdSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! * cdPercent/100).rounded())
            
            var tempExtraSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! * self.extraPercentValue/100).rounded())
            
            self.OutstandingReportMainArray[section][row].savedAmount =  String(tempSavedAmount)
            self.OutstandingReportMainArray[section][row].totalExtraSavedAmount =  String(tempExtraSavedAmount)
            self.OutstandingReportMainArray[section][row].totalCdSavedAmount =  String(tempCdSavedAmount)
            
            
            if(Int(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! == Int(self.OutstandingReportMainArray[section][row].prevOutstandingAmt ?? "0")!){
                self.OutstandingReportMainArray[section][row].isChecked = 1
            }else if(Int(self.OutstandingReportMainArray[section][row].totalAmount ?? "0")! > 0){
                self.OutstandingReportMainArray[section][row].isChecked = 2
            }else{
                self.OutstandingReportMainArray[section][row].isChecked = 0
            }
            
            if(OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
                // - - - - - - setting due here - - - - - - - - -
                for i in 0...((self.OutstandingReportMainArray[1].count) - 1){
                    if(!self.maintainDueSequence){
                        
                    }else{
                        if(i >= (row+1)){
                            self.OutstandingReportMainArray[1][i].totalAmount = "0"
                            self.OutstandingReportMainArray[1][i].isChecked = 0
                        }
                    }
                }
            }
        }
        
        
        totalAmount = String(getRemainingAmountTotal().0)
        edtAmount.text = totalAmount
        
        balanceAmnt = outsTotalAmnt - getRemainingAmountTotal().0
        
        self.lblBalanceAmount.text = Utility.formatRupee(amount: Double(balanceAmnt))
        
        //self.totalSavings = Int(getRemainingAmountTotal().1) + Int(getRemainingAmountTotal().2)
        self.totalSavings = Int(getRemainingAmountTotal().3)
        
        self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().1))+" + "+Utility.formatRupee(amount: Double(getRemainingAmountTotal().2))
       // self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().3))
        //        if(extraPercentValue > 0){
        //             self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().1)) + " + " + Utility.formatRupee(amount: Double(getRemainingAmountTotal().2))
        //        }else{
        ////             self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().1))
        //            self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().3))
        //        }
        
        showHideButton()
        
        if(self.tableView != nil)
        {
            self.tableView.reloadData()
        }
        
        //        payableAmount = Int(totalAmount ?? "0")! - Int((getRemainingAmountTotal().1)) - Int((getRemainingAmountTotal().2))
        payableAmount = Int(totalAmount ?? "0")! - Int((getRemainingAmountTotal().3))
        
        print("TOTAL AMOUNT _____",Int(totalAmount ?? "0")!," - --  - -- - ",Int((getRemainingAmountTotal().1))," - --  - -- - ", Int((getRemainingAmountTotal().2)))
        
        btnPayment.setTitle("ACTUAL AMOUNT : \(Utility.formatRupee(amount: Double(payableAmount)))", for: .normal)
        
    }
    
    
    // - - - - - -  Calculate outstanding amount into table with lumsum amount - - -  - - - - - - - - - -
    func calculateWithTotalAmount(amount:String){
        print("IN LUMSUM - - ",OutstandingReportMainArray)
        
        showAmnt = Int(amount ?? "0")!
        enteredAmnt = Int(amount ?? "0")!
        
        for x in 0...((self.OutstandingReportMainArray.count) - 1){
            for y in 0...((self.OutstandingReportMainArray[x].count) - 1){
                self.OutstandingReportMainArray[x][y].totalAmount = "0"
                self.OutstandingReportMainArray[x][y].savedAmount = "0"
                self.OutstandingReportMainArray[x][y].totalExtraSavedAmount = "0"
                self.OutstandingReportMainArray[x][y].totalCdSavedAmount = "0"
                self.OutstandingReportMainArray[x][y].isChecked = 0
            }
        }
        
        // - - -  - - - Overdue amount  - - - - - - - -
        if(showAmnt > 0 && OutstandingReportMainArray.count>0 && OutstandingReportMainArray[0].count > 0){
            for i in 0...((self.OutstandingReportMainArray[0].count) - 1){
                if(showAmnt >= Int(self.OutstandingReportMainArray[0][i].prevOutstandingAmt ?? "0")!){
                    showAmnt -= Int(self.OutstandingReportMainArray[0][i].prevOutstandingAmt ?? "0")!
                    self.OutstandingReportMainArray[0][i].totalAmount = self.OutstandingReportMainArray[0][i].prevOutstandingAmt
                    self.OutstandingReportMainArray[0][i].isChecked = 1
                    
                    var cdPercent = Double(self.OutstandingReportMainArray[0][i].percent ?? "0")!
                    
                    var totalSavedPercent = (cdPercent + self.extraPercentValue)
                    
                    var tempSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[0][i].totalAmount ?? "0")! * totalSavedPercent/100).rounded())
                    
                    var tempCdSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[0][i].totalAmount ?? "0")! * cdPercent/100).rounded())
                    
                    var tempExtraSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[0][i].totalAmount ?? "0")! * self.extraPercentValue/100).rounded())
                    
                    self.OutstandingReportMainArray[0][i].savedAmount = String(tempSavedAmount)
                    self.OutstandingReportMainArray[0][i].totalExtraSavedAmount = String(tempExtraSavedAmount)
                    self.OutstandingReportMainArray[0][i].totalCdSavedAmount = String(tempCdSavedAmount)
                    
                }else{
                    self.OutstandingReportMainArray[0][i].totalAmount = String(showAmnt)
                    showAmnt -= Int(self.OutstandingReportArray[i].prevOutstandingAmt ?? "0")!
                    self.OutstandingReportMainArray[0][i].isChecked = 2
                    
                    var cdPercent = Double(self.OutstandingReportMainArray[0][i].percent ?? "0")!
                    
                    var totalSavedPercent = (cdPercent + self.extraPercentValue)
                    
                    var tempSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[0][i].totalAmount ?? "0")! * totalSavedPercent/100).rounded())
                    
                    var tempCdSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[0][i].totalAmount ?? "0")! * cdPercent/100).rounded())
                    
                    var tempExtraSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[0][i].totalAmount ?? "0")! * self.extraPercentValue/100).rounded())
                    
                    self.OutstandingReportMainArray[0][i].savedAmount = String(tempSavedAmount)
                    self.OutstandingReportMainArray[0][i].totalExtraSavedAmount = String(tempExtraSavedAmount)
                    self.OutstandingReportMainArray[0][i].totalCdSavedAmount = String(tempCdSavedAmount)
                    
                    break
                }
            }
        }
        
        print("SHOW AMOUNT - - -",showAmnt)
        
        // - - - - -  For due amount - - - - - -
        if(showAmnt > 0 && OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
            for i in 0...((self.OutstandingReportMainArray[1].count) - 1){
                if(showAmnt >= Int(self.OutstandingReportMainArray[1][i].prevOutstandingAmt ?? "0")!){
                    showAmnt -= Int(self.OutstandingReportMainArray[1][i].prevOutstandingAmt ?? "0")!
                    self.OutstandingReportMainArray[1][i].totalAmount = self.OutstandingReportMainArray[1][i].prevOutstandingAmt
                    self.OutstandingReportMainArray[1][i].isChecked = 1
                    
                    var cdPercent = Double(self.OutstandingReportMainArray[1][i].percent ?? "0")!
                    
                    var totalSavedPercent = (cdPercent + self.extraPercentValue)
                    
                    var tempSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[1][i].totalAmount ?? "0")! * totalSavedPercent/100).rounded())
                    
                    var tempCdSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[1][i].totalAmount ?? "0")! * cdPercent/100).rounded())
                    
                    var tempExtraSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[1][i].totalAmount ?? "0")! * self.extraPercentValue/100).rounded())
                    
                    self.OutstandingReportMainArray[1][i].savedAmount = String(tempSavedAmount)
                    self.OutstandingReportMainArray[1][i].totalExtraSavedAmount = String(tempExtraSavedAmount)
                    self.OutstandingReportMainArray[1][i].totalCdSavedAmount = String(tempCdSavedAmount)
                }else{
                    self.OutstandingReportMainArray[1][i].totalAmount = String(showAmnt)
                    self.OutstandingReportMainArray[1][i].isChecked = 2
                    
                    var cdPercent = Double(self.OutstandingReportMainArray[1][i].percent ?? "0")!
                    
                    var totalSavedPercent = (cdPercent + self.extraPercentValue)
                    
                    var tempSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[1][i].totalAmount ?? "0")! * totalSavedPercent/100).rounded())
                    
                    var tempCdSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[1][i].totalAmount ?? "0")! * cdPercent/100).rounded())
                    
                    var tempExtraSavedAmount = Int(Double(Double(self.OutstandingReportMainArray[1][i].totalAmount ?? "0")! * self.extraPercentValue/100).rounded())
                    
                    self.OutstandingReportMainArray[1][i].savedAmount = String(tempSavedAmount)
                    self.OutstandingReportMainArray[1][i].totalExtraSavedAmount = String(tempExtraSavedAmount)
                    self.OutstandingReportMainArray[1][i].totalCdSavedAmount = String(tempCdSavedAmount)
                    
                    break
                }
            }
        }
        
        balanceAmnt = outsTotalAmnt -  Int(amount ?? "0")!
        
        self.lblBalanceAmount.text = Utility.formatRupee(amount: Double(balanceAmnt))
        
        //   self.totalSavings = Int(getRemainingAmountTotal().1) + Int(getRemainingAmountTotal().2)
        self.totalSavings = Int(getRemainingAmountTotal().3)
        
        self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().1))+" + "+Utility.formatRupee(amount: Double(getRemainingAmountTotal().2))
        //        if(extraPercentValue > 0){
        //            self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().1)) + " + " + Utility.formatRupee(amount: Double(getRemainingAmountTotal().2))
        //        }else{
        //           // self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().1))
        //            self.lblTotalSavings.text = Utility.formatRupee(amount: Double(getRemainingAmountTotal().3))
        //        }
        
        
        showHideButton()
        if(self.tableView != nil)
        {
            self.tableView.reloadData()
        }
        
        //        payableAmount = Int(totalAmount ?? "0")! - Int((getRemainingAmountTotal().1)) - Int((getRemainingAmountTotal().2))
        payableAmount = Int(totalAmount ?? "0")! - Int((getRemainingAmountTotal().3))
        
        btnPayment.setTitle("ACTUAL AMOUNT : \(Utility.formatRupee(amount: Double(payableAmount)))", for: .normal)
    }
    
    
    func showHideButton(){
        
        print("IN SHOW HIDE - - ",OutstandingReportMainArray)
        
        if(OutstandingReportMainArray.count>0 && OutstandingReportMainArray[0].count > 0){
            
            for item in 0...((self.OutstandingReportMainArray[0].count) - 1){
                
                if(!self.maintainDueSequence && (self.OutstandingReportMainArray[0][item].duestatus ?? "")!.elementsEqual("Due")){
                    self.OutstandingReportMainArray[0][item].isBtnEnable = true
                }else{
                    if(item == 0){
                        self.OutstandingReportMainArray[0][item].isBtnEnable = true
                    }else{
                        if(self.OutstandingReportMainArray[0][item-1].isChecked == 1){
                            self.OutstandingReportMainArray[0][item].isBtnEnable = true
                        }else{
                            self.OutstandingReportMainArray[0][item].isBtnEnable = false
                        }
                    }
                }
                
            }
            
            if(OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
                
                for item in 0...((self.OutstandingReportMainArray[1].count) - 1){
                    if(self.OutstandingReportMainArray[0][self.OutstandingReportMainArray[0].count - 1].isChecked != 1)
                    {
                        self.OutstandingReportMainArray[1][item].isBtnEnable = false
                    }
                    else{
                        if(!self.maintainDueSequence && (self.OutstandingReportMainArray[1][item].duestatus ?? "")!.elementsEqual("Due")){
                            self.OutstandingReportMainArray[1][item].isBtnEnable = true
                        }else{
                            if(item == 0){
                                self.OutstandingReportMainArray[1][item].isBtnEnable = true
                            }else{
                                if(self.OutstandingReportMainArray[1][item-1].isChecked == 1){
                                    self.OutstandingReportMainArray[1][item].isBtnEnable = true
                                }else{
                                    self.OutstandingReportMainArray[1][item].isBtnEnable = false
                                }
                            }
                        }
                    }
                }
            }
        }
        
        print("NEW ARR - - ",self.OutstandingReportMainArray)
        
        let joined = Array(self.OutstandingReportMainArray.joined())
        OutstandingReportPaymentDummyArr.removeAll()
        OutstandingReportPaymentDummyArr.append(contentsOf: joined)
        
        
        if(self.tableView != nil)
        {
            self.tableView.reloadData()
        }
        
    }
    
    func getRemainingAmountTotal() -> (Int, Int, Int,Int) {
        
        var totalSaved = 0
        var totalCdAmount = 0
        var totalExtraAmount = 0
        var totalShowAmount = 0
        
        for x in 0...((self.OutstandingReportMainArray.count) - 1){
            for y in 0...((self.OutstandingReportMainArray[x].count) - 1){
                totalCdAmount += Int(self.OutstandingReportMainArray[x][y].totalCdSavedAmount ?? "0")!
                totalExtraAmount += Int(self.OutstandingReportMainArray[x][y].totalExtraSavedAmount ?? "0")!
                totalShowAmount += Int(self.OutstandingReportMainArray[x][y].totalAmount ?? "0")!
                totalSaved += Int(self.OutstandingReportMainArray[x][y].savedAmount ?? "0")!
                
                print("TOTAL SAVED  - - - - - ",totalSaved)
            }
        }
        //        print(self.OutstandingReportMainArray," -- - -  - - - - - ",totalShowAmount," -- - - ",totalCdAmount," -- - - ",totalExtraAmount," -- - - ",totalSaved)
        return (totalShowAmount,totalCdAmount,totalExtraAmount,totalSaved)
    }
    
    
    // - - -  - - - - - - API to get outstanding report list data  - - - -  - - - - - - -- - -
    func apiOutstandingReport() {
        
        //    ViewControllerUtils.sharedInstance.showViewLoader(view: vwCalculateAmount)
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        var cdPercent = 0.0
        var totalPercentValue = 0.0
        
        var overDueExist = false
        
        let json: [String: Any] = ["CIN":cinReceived,"ClientSecret":"201020","Division":0,"OutstangingDays":5000,"Index":0,"Count":5000]
        
        print("OUTSTANDING CALC DETAIL ----",json)
        
        DataManager.shared.makeAPICall(url: outstandingReportApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.OutstandingReportElementMain = try JSONDecoder().decode([OutstandingReportElement].self, from: data!)
                    self.OutstandingReportDataMain = self.OutstandingReportElementMain[0].data
                    self.OutstandingReportArray.append(contentsOf:self.OutstandingReportDataMain[0].outstandingdata)
                    
                    self.extraPercentValue = self.OutstandingReportArray[0].extraper ?? 0
                    
                    for i in 0...((self.OutstandingReportArray.count) - 1){
                        self.OutstandingReportArray[i].isChecked = 0
                        self.OutstandingReportArray[i].totalAmount = "0"
                        self.OutstandingReportArray[i].isBtnEnable = false
                        self.OutstandingReportArray[i].savedAmount = "0"
                        self.OutstandingReportArray[i].totalSavableAmount = "0"
                        self.OutstandingReportArray[i].totalExtraSavedAmount = "0"
                        self.OutstandingReportArray[i].totalCdSavedAmount = "0"
                        self.OutstandingReportArray[i].prevOutstandingAmt = self.OutstandingReportArray[i].ouststandingAmt
                        
                        if((self.OutstandingReportArray[i].duestatus ?? "")!.elementsEqual("OverDue")){
                            overDueExist = true
                        }
                        
                        if(!self.maintainDueSequence && !overDueExist){
                            self.OutstandingReportArray[i].isBtnEnable = true
                        }
                        
                        cdPercent = Double(self.OutstandingReportArray[i].percent ?? "0")!
                        totalPercentValue = cdPercent + self.extraPercentValue
                        
                        self.calculatedDiscount = Int(Double(Double(self.OutstandingReportArray[i].prevOutstandingAmt ?? "0")! * (totalPercentValue/100)).rounded())
                        self.OutstandingReportArray[i].ouststandingAmt =  String(Int(self.OutstandingReportArray[i].prevOutstandingAmt ?? "0")! - self.calculatedDiscount)
                        self.OutstandingReportArray[i].totalSavableAmount = String(self.calculatedDiscount)
                        
                        self.arrOutsTotalAmount.append(Int(self.OutstandingReportArray[i].prevOutstandingAmt ?? "0")!)
                        
                    }
                    
                    let groupedDictionary = Dictionary(grouping: self.OutstandingReportArray, by: { (payment) -> String in
                        return payment.duestatus!
                    })
                    
                    let keys = groupedDictionary.keys.sorted(by: >)
                    
                    self.outsPaymentSectionArr.append(contentsOf: keys)
                    
                    keys.forEach({ (key) in
                        self.OutstandingReportMainArray.append(groupedDictionary[key]!)
                    })
                    
                    print("MAIN ARR - - - ",self.OutstandingReportMainArray)
                    
                    self.dueAmnt = Double(self.OutstandingReportDataMain[0].totaldueoverdue[0].due ?? "0")!
                    self.overdueAmnt = Double(self.OutstandingReportDataMain[0].totaldueoverdue[0].overDue ?? "0")!
                    self.outsTotalAmnt = self.arrOutsTotalAmount.reduce(0,+)
                    
                    self.lblDueAmount.text = Utility.formatRupee(amount: Double(self.dueAmnt))
                    self.lblOverDueAmount.text = Utility.formatRupee(amount: Double(self.overdueAmnt))
                    self.lblOutsAmount.text = Utility.formatRupee(amount: Double(self.OutstandingReportDataMain[0].totaloutstanding[0].ouststandingAmt ?? "0")!)
                    
                    self.edtAmount.tag = self.outsTotalAmnt
                    
                    self.lblBalanceAmount.text = Utility.formatRupee(amount: Double(self.outsTotalAmnt))
                    
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    
                }
                
                
                if(self.OutstandingReportArray.count>0){
                    
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
            }
            
        }) { (Error) in
            //  ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
    
    
    
    
    // - - -  - - - - - - API to confirm payment to local server first  - - - -  - - - - - - -- - -
    func apiOutsPaymentLocal() {
        
        // ViewControllerUtils.sharedInstance.showLoader()
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        self.OutstandingReportPaymentMainArr.removeAll()
        
        var totalSavedAmountObj = 0
        var totalDiscountedAmountObj = 0
        var totalDiscountPercentObj = 0.0
        
        if(self.OutstandingReportPaymentDummyArr.count > 0){
            for i in 0...((self.OutstandingReportPaymentDummyArr.count) - 1){
                if(Int(self.OutstandingReportPaymentDummyArr[i].totalAmount ?? "0")! > 0){
                    
                    totalDiscountPercentObj = 0.0
                    totalDiscountPercentObj = (Double(self.OutstandingReportPaymentDummyArr[i].percent ?? "0")! + self.extraPercentValue)
                    
                    totalSavedAmountObj = 0
                    if(totalDiscountPercentObj > 0.0)
                    {
                        totalSavedAmountObj = Int(Double(Double(self.OutstandingReportPaymentDummyArr[i].totalAmount ?? "0")! * (totalDiscountPercentObj/100)).rounded())
                    }
                    
                    totalDiscountedAmountObj = Int(self.OutstandingReportPaymentDummyArr[i].totalAmount ?? "0")! - totalSavedAmountObj
                    
                    self.OutstandingReportPaymentMainArr.append(OutstandingPlacedObject(InvoiceId: (self.OutstandingReportPaymentDummyArr[i].invoiceId ?? 0)!, DiscountedAmount: String(totalDiscountedAmountObj), EnteredAmount: (self.OutstandingReportPaymentDummyArr[i].totalAmount ?? "0")!, SavedAmount: String(totalSavedAmountObj), Per: String(totalDiscountPercentObj),DueDate: self.OutstandingReportPaymentDummyArr[i].cddate ?? "-",InvoiceAmount: self.OutstandingReportPaymentDummyArr[i].invoiceAmt ?? "-",InvoiceNumber:self.OutstandingReportPaymentDummyArr[i].invoiceNo ?? "-",OutstandingAmount:(self.OutstandingReportPaymentDummyArr[i].prevOutstandingAmt ?? "0")!,CatId:(self.OutstandingReportPaymentDummyArr[i].catId ?? "1")!))
                    
                }
            }
            
        }
        
        let encoderToPass = JSONEncoder()
        encoderToPass.outputFormatting = []
        
        var outsPaymentJsonObj: [String: Any] = [:]
        var strOutsPaymentObj = ""
        
        if let data = try? encoderToPass.encode(self.OutstandingReportPaymentMainArr) {
            print(String(data: data, encoding: .utf8)!)
            
            strOutsPaymentObj = String(data: data, encoding: .utf8)!
            
            strOutsPaymentObj = strOutsPaymentObj.components(separatedBy: .whitespacesAndNewlines).joined()
            strOutsPaymentObj = strOutsPaymentObj.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
        }
        
        var totalSavedAmountToPass = 0
        // totalSavedAmountToPass = getRemainingAmountTotal().1 + getRemainingAmountTotal().2
        totalSavedAmountToPass = getRemainingAmountTotal().3
        
        let json: [String: Any] = ["CIN":cinReceived,"ClientSecret":"ClientSecret","grandtotal":totalAmount,"savedamounttotal":totalSavedAmountToPass,"withdiscountamounttotal":payableAmount,"Category":"Party","OrderDetails":strOutsPaymentObj,"devicetype":"IOS",
                                   "deviceid":strDeviceId]
        
        print("OUTSTANDING apiOutsPaymentLocal ----",json)
        
        DataManager.shared.makeAPICall(url: outstandingPaymentLocalApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.OutstandingPaymentDetailElementMain = try JSONDecoder().decode([OutstandingPaymentDetailReportElement].self, from: data!)
                    
                    let message = self.OutstandingPaymentDetailElementMain[0].message
                    
                    self.OutstandingPaymentDetailDataMain = self.OutstandingPaymentDetailElementMain[0].data
                    self.OutstandingPaymentDetailArrayToPass =  self.OutstandingPaymentDetailDataMain[0].invoices
                    
                    
                    // - - - - save tx no here - -  - - - -
                    if(self.OutstandingPaymentDetailElementMain[0].result ?? false){
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        
                        weak var pvc = self.presentingViewController
                        self.dismiss(animated: false, completion: {
                            let vcOutstandingPaymentSummary  = self.storyboard?.instantiateViewController(withIdentifier: "OutstandingSummary") as! OutstandingSummaryViewController
                            vcOutstandingPaymentSummary.strlocalTransactionId = self.OutstandingPaymentDetailDataMain[0].transno ?? "-"
                            vcOutstandingPaymentSummary.strGrandTotal = self.OutstandingPaymentDetailDataMain[0].grandtotal ?? "-"
                            
                            vcOutstandingPaymentSummary.strSavedAmountTotal = self.OutstandingPaymentDetailDataMain[0].savedamounttotal ?? "0"
                            vcOutstandingPaymentSummary.strDiscountAmountTotal = self.OutstandingPaymentDetailDataMain[0].withdiscountamounttotal ?? "0"
                            vcOutstandingPaymentSummary.intVerifyPayableAmount = self.payableAmount
                            vcOutstandingPaymentSummary.intVerifySavedAmount = self.totalSavings
                            
                            vcOutstandingPaymentSummary.delegateDismiss = self
                            vcOutstandingPaymentSummary.outsPaymentObject = self.OutstandingPaymentDetailArrayToPass
                            
                            pvc?.present(vcOutstandingPaymentSummary, animated: false, completion: nil)
                            
                        })
                        
                    }else{
                        var alert = UIAlertView(title: "Failed!!!", message: message, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        //  self.dismiss(animated: true, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            weak var pvc = self.presentingViewController
                            self.dismiss(animated: false, completion: {
                                let vcOutsPaymentSummaryListController =  self.storyboard?.instantiateViewController(withIdentifier: "OutsPaymentSummaryListController") as! OutsPaymentSummaryListController
                                vcOutsPaymentSummaryListController.callFrom = "otp"
                                
                                let navVc = UINavigationController(rootViewController: vcOutsPaymentSummaryListController)
                                pvc?.present(navVc, animated: true, completion: nil)
                            })
                        }
                        
                    }
                    self.noDataView.hideView(view: self.noDataView)
                } catch let errorData {
                    print(errorData.localizedDescription)
                    
                    self.noDataView.hideView(view: self.noDataView)
                    
                    var alert = UIAlertView(title: "Failed!!!", message: "One of your payment is already pending, Please try after some time !!!", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        weak var pvc = self.presentingViewController
                        self.dismiss(animated: false, completion: {
                            let vcOutsPaymentSummaryListController =  self.storyboard?.instantiateViewController(withIdentifier: "OutsPaymentSummaryListController") as! OutsPaymentSummaryListController
                            vcOutsPaymentSummaryListController.callFrom = "otp"
                            
                            let navVc = UINavigationController(rootViewController: vcOutsPaymentSummaryListController)
                            pvc?.present(navVc, animated: true, completion: nil)
                        })
                    }
                    //   self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }) { (Error) in
            self.noDataView.hideView(view: self.noDataView)
            
            print(Error?.localizedDescription)
            
            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            //   self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    // - - - - -  - click event of amount payable - - - - - - - - - - -
    @IBAction func clicked_confirmPayment(_ sender: UIButton) {
        print("CONFIRM")
        
        // - - - - - hit local api first and send data to server to revalidate - - -  --
        if (Utility.isConnectedToNetwork()) {
            if(self.OutstandingReportPaymentDummyArr.count > 0){
                if(Int(totalAmount ??
                    "0")! > 0)
                {
                    apiOutsPaymentLocal()
                }else{
                    var alert = UIAlertView(title: "No Amount", message: "Amount field cannot be empty", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }else{
                var alert = UIAlertView(title: "No Amount", message: "Amount field cannot be empty", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        else{
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension OutstandingPaymentCalculationController : UITableViewDelegate { }

extension OutstandingPaymentCalculationController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor.darkGray
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Roboto-Regular", size: 16.0)
        label.text = outsPaymentSectionArr[section]
        label.textColor = UIColor.white
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return outsPaymentSectionArr.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OutstandingReportMainArray[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutstandingReportCell", for: indexPath) as! OutstandingReportCell
        
        cell.lblDueDays.text = OutstandingReportMainArray[indexPath.section][indexPath.row].dueDays ?? "-"
        cell.lblInvoiceNo.text = (OutstandingReportMainArray[indexPath.section][indexPath.row].invoiceNo ?? "-")! + " (" + (OutstandingReportMainArray[indexPath.section][indexPath.row].invoiceDate ?? "-")! + ")"
        cell.btnEdtAmount.setTitle(OutstandingReportMainArray[indexPath.section][indexPath.row].totalAmount ?? "0", for: .normal)
        
        
        
        if(Int(OutstandingReportMainArray[indexPath.section][indexPath.row].catId ?? "1")! == 4){
            cell.lblInvoiceHeader.text = "Debit Note"
        }else{
            cell.lblInvoiceHeader.text = "Invoice No."
        }
        
        if var invoiceAmnt = OutstandingReportMainArray[indexPath.section][indexPath.row].invoiceAmt as? String {
            cell.lblinvoiceAmnt.text = Utility.formatRupee(amount: Double(invoiceAmnt)!)
        }
        
        var prevOutsAmnt = (OutstandingReportMainArray[indexPath.section][indexPath.row].prevOutstandingAmt ?? "0")!
        var OutsAmnt = (OutstandingReportMainArray[indexPath.section][indexPath.row].ouststandingAmt ?? "0")!
        var savedAmount = (OutstandingReportMainArray[indexPath.section][indexPath.row].savedAmount ?? "0")!
        var cdPercent = Double(OutstandingReportMainArray[indexPath.section][indexPath.row].percent ?? "0")!
        var percent = cdPercent + extraPercentValue
        var totalSavableAmount = (OutstandingReportMainArray[indexPath.section][indexPath.row].totalSavableAmount ?? "0")!
        
        if(cdPercent > 0){
            cell.btnInfoDetail.isHidden = false
            
            var str1 = Utility.formatRupee(amount: Double(prevOutsAmnt)!) +  " (" + Utility.formatRupee(amount: Double(OutsAmnt)!) + ") " +  " (Discount: \(percent)%)"
            var str2 = "\nPay Before: \((OutstandingReportMainArray[indexPath.section][indexPath.row].cddate ?? "-")!)"
            var str3 = "\nTotal Savings: \(Utility.formatRupee(amount: Double(totalSavableAmount)!))"
            var str4 = "\nYour Savings: \(Utility.formatRupee(amount: Double(savedAmount)!))"
            
            
            let attr1 = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "FontLightText"), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]
            let attr2 = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "ColorGreen"), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
            
            let partOne = NSMutableAttributedString(string: str1, attributes: attr1)
            let partTwo = NSMutableAttributedString(string: str2, attributes: attr1)
            let partThree = NSMutableAttributedString(string: str3, attributes: attr1)
            let partFour = NSMutableAttributedString(string: str4, attributes: attr1)
            
            partOne.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, Utility.formatRupee(amount: Double(prevOutsAmnt)!).count))
            
            partThree.addAttributes(attr2, range: NSRange(location: (str3.count) - Utility.formatRupee(amount: Double(totalSavableAmount)!).count, length: Utility.formatRupee(amount: Double(totalSavableAmount)!).count))
            
            partFour.addAttributes(attr2, range: NSRange(location: (str4.count) - Utility.formatRupee(amount: Double(savedAmount)!).count, length: Utility.formatRupee(amount: Double(savedAmount)!).count))
            
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            combination.append(partThree)
            combination.append(partFour)
            
            cell.lblOutsAmnt.attributedText = combination
            
        }else{
            cell.btnInfoDetail.isHidden = true
            
            var str1 = Utility.formatRupee(amount: Double(prevOutsAmnt)!) +  " (" + Utility.formatRupee(amount: Double(OutsAmnt)!) + ") " + " (Discount: \(percent)%)"
            
            var str2 = "\nTotal Savings: \(Utility.formatRupee(amount: Double(totalSavableAmount)!))"
            var str3 = "\nYour Savings: \(Utility.formatRupee(amount: Double(savedAmount)!))"
            
            let attr1 = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "FontLightText"), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]
            
            let attr2 = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "ColorGreen"), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
            
            let partOne = NSMutableAttributedString(string: str1, attributes: attr1)
            let partTwo = NSMutableAttributedString(string: str2, attributes: attr1)
            let partThree = NSMutableAttributedString(string: str3, attributes: attr1)
            
            partOne.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, Utility.formatRupee(amount: Double(prevOutsAmnt)!).count))
            
            partTwo.addAttributes(attr2, range: NSRange(location: (str2.count) - Utility.formatRupee(amount: Double(totalSavableAmount)!).count, length: Utility.formatRupee(amount: Double(totalSavableAmount)!).count))
            
            partThree.addAttributes(attr2, range: NSRange(location: (str3.count) - Utility.formatRupee(amount: Double(savedAmount)!).count, length: Utility.formatRupee(amount: Double(savedAmount)!).count))
            
            let combination = NSMutableAttributedString()
            combination.append(partOne)
            combination.append(partTwo)
            combination.append(partThree)
            cell.lblOutsAmnt.attributedText = combination
            
        }
        
        
        
        cell.lblDivision.text = OutstandingReportMainArray[indexPath.section][indexPath.row].divisionName?.capitalized ?? "-"
        
        if((OutstandingReportMainArray[indexPath.section][indexPath.row].isChecked ?? 0)! == 0){
            //  cell.btnCheckbox.backgroundColor = UIColor.red
            cell.btnCheckbox.setImage(UIImage(named: "red"), for: .normal)
            
        }else if((OutstandingReportMainArray[indexPath.section][indexPath.row].isChecked ?? 0)! == 1){
            //  cell.btnCheckbox.backgroundColor = UIColor.green
            cell.btnCheckbox.setImage(UIImage(named: "green"), for: .normal)
            
        }else{
            //  cell.btnCheckbox.backgroundColor = UIColor.gray
            cell.btnCheckbox.setImage(UIImage(named: "Partial"), for: .normal)
            
        }
        
        if(OutstandingReportMainArray.count>0 && OutstandingReportMainArray[0].count > 0){
            OutstandingReportMainArray[0][0].isBtnEnable = true
        }else {
            if(OutstandingReportMainArray.count>1 && OutstandingReportMainArray[1].count > 0){
                OutstandingReportMainArray[1][0].isBtnEnable = true
            }
        }
        
        cell.delegate = self
        
        
        return cell
    }
    
    
    // - - - -  - click on show info icon - - - -  - - - - -
    func showInfoCell(cell: OutstandingReportCell) {
        var indexPath = self.tableView.indexPath(for: cell)
        
        var strInvNo = OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].invoiceNo ?? "0"
        var strOutsAmount =  OutstandingReportMainArray[(indexPath?.section)!][(indexPath?.row)!].prevOutstandingAmt ?? "0"
        
        let sb = UIStoryboard(name: "OutsInvoiceWiseCDPopup", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? InvoiceWiseCDPopupController
        popup?.strInvNo = strInvNo
        popup?.outsAmount = strOutsAmount
        popup?.extraDiscount = self.extraPercentValue
        self.present(popup!, animated: true)
    }
    
    
}


