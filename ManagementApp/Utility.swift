//
//  CheckConnection.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/26/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

public class Utility: UIViewController {
    
    var RegistrationElementMain = [GetOtpFreePayElement]()
    var RegistrationObjMain = [GetOtpFreePayObj]()
    
    func activityIndicator(_ title: String) {
        var activityIndicator = UIActivityIndicatorView()
        var strLabel = UILabel()
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        print(#function)
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
     func removeEffectView() {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        print(#function)
        DispatchQueue.main.async {
            effectView.removeFromSuperview()
        }
    }
    
  //Picker Related....
    class func quarterlyStartDate() -> Array<String>{
        return ["04/01/","07/01/","10/01/","01/01/"]
    }
    
    class func quarterlyEndDate() -> Array<String>{
        return ["06/30/","09/30/","12/31/","03/31/"]
    }
    
    class func getMonths() -> Array<String>{
        return ["01/","02/","03/","04/","05/","06/","07/","08/","09/","10/","11/","12/"]
    }
    
    class func getMonthEndDate() -> Array<String>{
        return ["31/","29/","31/","30/","31/","30/","31/","31/","30/","31/","30/","31/"]
    }
    //.......
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
    class func getAllFlags() -> [FlagData]{
        //Get flag data
        var flagData = [FlagData]()
        
        flagData.append(FlagData(flag: "ind_flag", teamName: "INDIA", teamId: 1, points:0))
        flagData.append(FlagData(flag: "ban_flag", teamName: "BANGLADESH", teamId: 2, points:0))
        flagData.append(FlagData(flag: "eng_flag", teamName: "ENGLAND", teamId: 3, points:0))
        flagData.append(FlagData(flag: "aus_flag", teamName: "AUSTRALIA", teamId: 4, points:0))
        flagData.append(FlagData(flag: "nz_flag", teamName: "NEW ZEALAND", teamId: 5, points:0))
        flagData.append(FlagData(flag: "pak_flag", teamName: "PAKISTAN", teamId: 6, points:0))
        flagData.append(FlagData(flag: "rsa_flag", teamName: "SOUTH AFRICA", teamId: 7, points:0))
        flagData.append(FlagData(flag: "sl_flag", teamName: "SRILANKA", teamId: 8, points:0))
        flagData.append(FlagData(flag: "wi_flag", teamName: "WEST INDIES", teamId: 9, points:0))
        flagData.append(FlagData(flag: "afg_flag", teamName: "AFGHANISTAN", teamId: 10, points:0))
        
        
        return flagData
    }
    
    class func getFlags() -> [FlagData]{
        //Get flag data
        var flagData = [FlagData]()
        
        flagData.append(FlagData(flag: "ban_flag", teamName: "BANGLADESH", teamId: 2, points:0))
        flagData.append(FlagData(flag: "eng_flag", teamName: "ENGLAND", teamId: 3, points:0))
        flagData.append(FlagData(flag: "aus_flag", teamName: "AUSTRALIA", teamId: 4, points:0))
        flagData.append(FlagData(flag: "nz_flag", teamName: "NEW ZEALAND", teamId: 5, points:0))
        flagData.append(FlagData(flag: "pak_flag", teamName: "PAKISTAN", teamId: 6, points:0))
        flagData.append(FlagData(flag: "rsa_flag", teamName: "SOUTH AFRICA", teamId: 7, points:0))
        flagData.append(FlagData(flag: "sl_flag", teamName: "SRILANKA", teamId: 8, points:0))
        flagData.append(FlagData(flag: "wi_flag", teamName: "WEST INDIES", teamId: 9, points:0))
        flagData.append(FlagData(flag: "afg_flag", teamName: "AFGHANISTAN", teamId: 10, points:0))
        
        
        return flagData
    }
    
    
    class func formatRupee(amount: Double) -> String{
        let formatter = NumberFormatter()              // Cache this, NumberFormatter creation is expensive.
        formatter.locale = Locale(identifier: "en_IN") // Here indian locale with english language is used
        formatter.numberStyle = .decimal               // Change to `.currency` if needed
        
        if(!amount.isNaN && amount.isFinite){
            let formattedAmount = "\u{20B9}" + formatter.string(from: NSNumber(value: Int(amount)))! // "10,00,000"
            return formattedAmount
        }
        else{
            return "-"
        }
    }
    
    class func formatRupeeWithDecimal(amount: Double) -> String{
        let formatter = NumberFormatter()              // Cache this, NumberFormatter creation is expensive.
        formatter.numberStyle = .decimal // Here indian locale with english language is used
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        formatter.locale = Locale.current
        
        if(!amount.isNaN && amount.isFinite){
            let formattedAmount = "\u{20B9}" + formatter.string(from: NSNumber(value: Double(amount)))!
            return formattedAmount
        }
        else{
            return "-"
        }
    }
    
    
    class func formattedDateFromString(dateString: String, withFormat format: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        
        return nil
    }
    
    class func formattedDateTimeWorldCup(dateString: String, withFormat format: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        
        return "-"
    }
    
    class func currFinancialYear() -> String{
        var finYear = "2018-2019"
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        if (month >= 4) {
            finYear = String(String(year) + "-" + String(year + 1))
        } else {
            finYear = String(String(year - 1) + "-" + String(year))
        }
        return finYear
    }
    
    
    
    class func currQuarter() -> String{
          var quarter = ""
          let date = Date()
          let calendar = Calendar.current
          
          let month = calendar.component(.month, from: date)
          if (month >= 4 && month <= 6) {
              quarter = "Q1 (APR - JUN)"
          } else if(month >= 7 && month <= 9){
              quarter = "Q2 (JUL - SEP)"
          }else if(month >= 10 && month <= 12){
              quarter = "Q3 (OCT - DEC)"
        }else{
        quarter = "Q4 (JAN - MAR)"
        }
          return quarter
      }
    
    class func setupHierarchy(strCin : String,viewAs : Bool) -> String{
        
        var hierarchy = "1"
        
        if (strCin.isEmpty) {
        if (viewAs){
                  hierarchy = "1"
        }
        else{
        hierarchy = "0"
        }
          } else {
        hierarchy = "0"
          }
        
        return hierarchy
    }
    
    class func showAlertMsg(_title: String?,_message: String,_cancelButtonTitle: String){
        
        
        let alert = UIAlertView(title: _title, message: _message, delegate: nil, cancelButtonTitle: _cancelButtonTitle)
        alert.show()
        
    }
    
    //Pending Order PDF
    class func apiDownloadPendingOrder(strCin: String,strCurrDate: String,intOrderType: Int) -> String? {
        
        var PendingOrderPdfMain = [PendingOrderPDFElement]()
        var PendingOrderPdfData = [PendingOrderPdfObj]()
        var strPdfUrl = ""
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        var pendingOrdersPDFApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["pendingOrdersPDF"] as? String ?? "")
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","AsonDate":strCurrDate,"Type":intOrderType]
        
        print("PENDING PDF JSON -- ",json)
        
        DataManager.shared.makeAPICall(url: pendingOrdersPDFApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    PendingOrderPdfMain = try JSONDecoder().decode([PendingOrderPDFElement].self, from: data!)
                    PendingOrderPdfData = PendingOrderPdfMain[0].data
                    
                    strPdfUrl = PendingOrderPdfData[0].url ?? ""
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
        return strPdfUrl
    }
    
    class func currDate() -> String{
        //Get current date
        let currDate = Date()
        var dateFormatter = DateFormatter()
        var strCurrDate = ""
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strCurrDate = dateFormatter.string(from: currDate)
        strCurrDate = Utility.formattedDateFromString(dateString: strCurrDate, withFormat: "MM/dd/yyyy")!
        
        return strCurrDate
    }
    
    //For downloading pdf file
    private static var session:URLSession = URLSession(configuration: .default)
    private static var downloadTask: URLSessionDownloadTask?
    
    private static func getLocalDirectory() -> URL? {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentPath = paths.first
        let directoryPath = documentPath?.appendingPathComponent("Downloads")
        
        guard let path = directoryPath else {
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: path.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            }catch {
                
            }
            
        }
        print("Path -- -- ",path)
        return path
    }
    
    
    
    public static func downloadFile(fileName:String, url:URL) {
        downloadTask = session.downloadTask(with: url, completionHandler: { (_location, _response, _error) in
            if _error == nil {
                guard  let location = _location, var folderPath = getLocalDirectory() else {
                    return
                }
                
                folderPath = folderPath.appendingPathComponent(fileName)
                folderPath.appendPathExtension(".pdf")
                
                print("Filename -- -- ",fileName," -- --",url)
                
                do {
                    try FileManager.default.moveItem(at: location, to: folderPath)
                }catch {
                    
                }
            }
        })
        
        downloadTask?.resume()
    }
    
    //get current financial date....
    class func yearDate() -> (String, String){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MM"
        let currYear = dateFormatter.string(from: now)
        let currMonth = dayFormatter.string(from: now)
        let nextYear = Int(currYear)! + 1
        let prevYear = Int(currYear)! - 1
        var fromdate = ""
        var todate = ""
        print("-------------->CurrYear : \(currYear) currMonth : \(currMonth) nextYear : \(nextYear)  prevYear : \(prevYear)")
        if currMonth == "01" || currMonth == "02" || currMonth == "03"{
            fromdate = "04/01/" + String(prevYear)
            todate = "03/31/" + String(currYear)
            print("-------------->Fromdate : \(fromdate) ToDate : \(todate)")
        }else{
            fromdate = "04/01/" + currYear
            todate = "03/31/" + String(nextYear)
            print("-------------->Fromdate : \(fromdate) ToDate : \(todate)")
        }
        
        return (fromdate, todate)
    }
    
    //get current month...
    class func getMonthly() -> (String, String) {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currMonth = dateFormatter.string(from: now)
        let currYear = yearFormatter.string(from: now)
        let monthEnds = Utility.getMonthEndDate()
        let fromdate = "\(currMonth)/01/\(currYear)"
        let todate = "\(currMonth)/\(monthEnds[Int(currMonth)!-1])\(currYear)"
        return (fromdate, todate)
    }
    
    
    // - - - -  - - - GET Otp request - - -  - - - - -
    func apiFreePayRegistration(vc: UIViewController, dueSequence: Bool){
        //   var outsPaymentRegistrationApi = "https://api.goldmedalindia.in/api/GetFreePayOTP"
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        var outsPaymentRegistrationApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["freePayOTP"] as? String ?? "")
        
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        var strCin = ""
        
        if(!loginData.isEmpty){
            strCin = loginData["userlogid"] as! String
        }
        
        let json: [String: Any] =  ["CIN":strCin,"ClientSecret":"201020"]
        
        print("GET REG OTP - - - - -",json)
        
        ViewControllerUtils.init().showLoader()
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outsPaymentRegistrationApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async  { do
            {
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.RegistrationElementMain = try JSONDecoder().decode([GetOtpFreePayElement].self, from: data!)
                self.RegistrationObjMain = self.RegistrationElementMain[0].data
                
                let message = self.RegistrationElementMain[0].message
                
                let result = self.RegistrationElementMain[0].result
                
                let isRegistered = self.RegistrationObjMain[0].isRegistered
                
                let mobileNo = self.RegistrationObjMain[0].mobile ?? ""
                let emailId = self.RegistrationObjMain[0].email ?? ""
                
                
                if(result ?? false){
                    
                    if(isRegistered ?? false){
                        var alert = UIAlertView(title: "Success", message: message, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        let vcOutstandingCalculationReport  = vc.storyboard?.instantiateViewController(withIdentifier: "OutstandingPaymentCalculation") as! OutstandingPaymentCalculationController
                        vcOutstandingCalculationReport.maintainDueSequence = dueSequence
                        vc.present(vcOutstandingCalculationReport, animated: false, completion: nil)
                    }else{
                        var alert = UIAlertView(title: "Success", message: message, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        // - - - - user is not registered on freepay - - -  - - -
                        let vcOutstandingPaymentRegistration  = vc.storyboard?.instantiateViewController(withIdentifier: "OutstandingPaymentRegistration") as! OutstandingPaymentOtpController
                        vcOutstandingPaymentRegistration.dueSequence = dueSequence
                        
                        vcOutstandingPaymentRegistration.strMobileNumber = mobileNo
                        vcOutstandingPaymentRegistration.strEmailid = emailId
                        
                        vc.present(vcOutstandingPaymentRegistration, animated: true, completion: nil)
                        
                    }
                    
                }else{
                    var alert = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
                ViewControllerUtils.init().removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                
                ViewControllerUtils.init().removeLoader()
                
                var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                }}
        }) { (Error) in
            print(Error?.localizedDescription)
            
            ViewControllerUtils.init().removeLoader()
            
            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }
        
    }
    
}
