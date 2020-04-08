//
//  CalendarLeaveController.swift
//  HrApp
//
//  Created by Goldmedal on 1/6/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarLeaveController: BaseViewController,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var btnChangeDate: UIButton!
    @IBOutlet weak var backButton: UIImageView!
    
    @IBOutlet weak var vwPunchInMain: UIView!
    @IBOutlet weak var vwPunchOutMain: UIView!
    
    @IBOutlet weak var lblPunchInTime: UILabel!
    @IBOutlet weak var lblPunchInAddr: UILabel!
    @IBOutlet weak var lblPunchOutTime: UILabel!
    @IBOutlet weak var lblPunchOutAddr: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    var strDate = ""
    var calDate = ""
    var currDate = ""
    var userId = ""
    
    var getCurrPunchDataApi = ""
    var getCurrPunchDataElement : PunchInDataElement!
    var getCurrPunchData : [PunchInData]?
    
    var getAllPunchDataApi = ""
    var getAllPunchDataElement : GetAllAttendanceElement!
    var errorData : [ErrorsData]?
    var getAllPunchData : [GetAllAttendanceData]?
    var arrAttendance : [GetAllAttendanceData]?
    var username = ""
    
    let fillDefaultColors = ["Present": UIColor.green, "Absent": UIColor.red, "Weekend": UIColor.white,"Checkout Missing": UIColor.orange, "Halfday": UIColor.yellow, "Holiday": UIColor.purple]
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone.current
        //  formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backClicked(tapGestureRecognizer:)))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapGestureRecognizer)
        lblUserName.text = username
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        //userId = loginData["EmployeeID"] as? String ?? "-"
        
        //currDate = self.dateFormatter1.string(from: Date())
        
        getAllPunchDataApi = AppConstants.PROD_BASE_URL + AppConstants.GET_ALL_PUNCH_DATA
        getCurrPunchDataApi = AppConstants.PROD_BASE_URL + AppConstants.GET_PUNCH_DATA
        
        var currDate = self.dateFormatter1.string(from: calendar?.selectedDate ?? Date())
        btnChangeDate.setTitle(currDate, for: .normal)
        
        self.arrAttendance = SQLiteDB.instance.GetAttendanceData()
        
        if((self.arrAttendance?.count ?? 0) == 0){
            if (Utility.isConnectedToNetwork()) {
                self.apiGetAllPunchData()
            }else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }else{
            if (Utility.isConnectedToNetwork()) {
                self.apiCurrentPunchData()
            }
        }
        
        calendar.dataSource = self
        calendar.delegate = self
        
        
    }
    
    //Button... 
    @objc func backClicked(tapGestureRecognizer: UITapGestureRecognizer)
    {
        dismiss(animated: true)
    }
    
    // - - - - - Get All Punch Data - - - - - - - - -
    func apiGetAllPunchData(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =  [
            "UserID": userId,
            "ClientID": AppConstants.CLIENT_ID,
            "ClientSecret": AppConstants.CLIENT_SECRET,
            "Isrecord": "LastThreeYears"
        ]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: getAllPunchDataApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("getAllPunchDataApi - - - - - ",self.getAllPunchDataApi,"-----",json)
            
            do {
                
                self.getAllPunchDataElement = try JSONDecoder().decode(GetAllAttendanceElement.self, from: data!)
                self.getAllPunchData = self.getAllPunchDataElement.data
                
                let statusCode = self.getAllPunchDataElement?.statusCode
                
                self.errorData = self.getAllPunchDataElement?.errors
                
                var errMsg = ""
                if(!(self.errorData?.isEmpty ?? true)){
                    errMsg = self.errorData?[0].errorMsg ?? "No Data Available"
                }
                
                if (statusCode == 200)
                {
                    for i in self.getAllPunchData ?? []
                    {
                        SQLiteDB.instance.addAttendanceData(objAttendance: i)
                    }
                    self.arrAttendance = SQLiteDB.instance.GetAttendanceData()
                    
                    self.calendar.dataSource = self
                    self.calendar.delegate = self
                    
                    var alert = UIAlertView(title: "Success", message: "Data inserted successfully", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    var alert = UIAlertView(title: "Error", message: errMsg, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
    }
    
    // - - - - - Get Current Punch Data - - - - - - - - -
    func apiCurrentPunchData(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =  [
            "UserID": userId,
            "ClientID": AppConstants.CLIENT_ID,
            "ClientSecret": AppConstants.CLIENT_SECRET,
        ]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: getCurrPunchDataApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("getCurrPunchDataApi - - - - - ",self.getCurrPunchDataApi,"-----",json)
            
            do {
                
                self.getCurrPunchDataElement = try JSONDecoder().decode(PunchInDataElement.self, from: data!)
                self.getCurrPunchData = self.getCurrPunchDataElement.data
                
                let statusCode = self.getCurrPunchDataElement?.statusCode
                
                self.errorData = self.getCurrPunchDataElement?.errors
                
                var errMsg = ""
                if(!(self.errorData?.isEmpty ?? true)){
                    errMsg = self.errorData?[0].errorMsg ?? "No Data Available"
                }
                
                if (statusCode == 200)
                {
                    
                    self.lblPunchInTime.text = "Punch In Time - \(self.getCurrPunchData?[0].punchInTime ?? "-")"
                    self.lblPunchOutTime.text = "Punch Out Time - \(self.getCurrPunchData?[0].punchOutTime ?? "-")"
                    
                    self.lblPunchInAddr.text = self.getCurrPunchData?[0].punchInLocation
                    self.lblPunchOutAddr.text = self.getCurrPunchData?[0].punchOutLocation
                    
                    var alert = UIAlertView(title: "Success", message: "Current Date Data Updated Successfully", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    var alert = UIAlertView(title: "Error", message: errMsg, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            
        }
    }
    
    
    //    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
    //         setDateColor(date: date)
    //    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return setDateColor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        strDate = self.dateFormatter1.string(from: date)
        btnChangeDate.setTitle(strDate, for: .normal)
        
        
        if(currDate.elementsEqual(strDate)){
                   if (Utility.isConnectedToNetwork()) {
                       apiCurrentPunchData()
                   }else{
                       if((self.arrAttendance?.count ?? 0) > 0){
                           setAttendanceDetails(date: date)
                       }
                   }
               }else{
                   if((self.arrAttendance?.count ?? 0) > 0){
                       setAttendanceDetails(date: date)
                   }
               }
        
//        if((self.arrAttendance?.count ?? 0) > 0){
//            setAttendanceDetails(date: date)
//        }else{
//            if(currDate.elementsEqual(strDate)){
//                apiCurrentPunchData()
//            }
//        }
    }
    
    func setDateColor(date: Date)-> UIColor?{
        //        if let color = self.fillDefaultColors[key] {
        //            return color
        //        }
        //        return nil
        calDate = self.dateFormatter1.string(from: date)
        
        if((self.arrAttendance?.count ?? 0) > 0){
            
            var index = self.arrAttendance?.firstIndex(where:{$0.date == calDate}) ?? -1
            
            if(index != -1){
                let status = self.arrAttendance?[index].statusPunch ?? ""
                
                if let color = self.fillDefaultColors[status] {
                    return color
                }else{
                    return nil
                    
                }
            }
        }
        
        return nil
    }
    
    func setAttendanceDetails(date: Date){
        calDate = self.dateFormatter1.string(from: date)
        print("Selected date - - - ",calDate)
        
        var index = self.arrAttendance?.firstIndex(where:{$0.date == calDate}) ?? -1
        
        if(index != -1){
            lblPunchInTime.text = "Punch In Time - \(self.arrAttendance?[index].firstIn ?? "-")"
            lblPunchOutTime.text = "Punch Out Time - \(self.arrAttendance?[index].lastOut ?? "-")"
            
            lblPunchInAddr.text = "erqwerqwer erqwerq ewrqwer ewrrtwer  rtwer  re rqwer Malad west"
            lblPunchOutAddr.text = "rqwer qe rqwerqr qwer qwe rqwerqwessfvsfv hgjnetr Andheri west"
        }else{
            lblPunchInTime.text = "Punch In Time -"
            lblPunchOutTime.text = "Punch Out Time -"
            
            lblPunchInAddr.text = "-"
            lblPunchOutAddr.text = "-"
        }
    }
    
    @IBAction func onDateChange(_ sender: Any) {
        print("Date TAPPED")
        
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.isFromDate = true
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    func updateDate(value: String, date: Date) {
        // strDate = Utility.formattedDateFromString(dateString: value, withFormat: "yyyy-MM-dd")!
        strDate = self.dateFormatter1.string(from: date)
        calendar.select(date, scrollToDate: true)
        btnChangeDate.setTitle(strDate, for: .normal)
        
        if(currDate.elementsEqual(strDate)){
            if (Utility.isConnectedToNetwork()) {
                apiCurrentPunchData()
            }else{
                if((self.arrAttendance?.count ?? 0) > 0){
                    setAttendanceDetails(date: date)
                }
            }
        }else{
            if((self.arrAttendance?.count ?? 0) > 0){
                setAttendanceDetails(date: date)
            }
        }
        
    }
    
}
