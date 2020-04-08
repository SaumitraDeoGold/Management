//
//  AppConstants.swift
//  HrApp
//
//  Created by Goldmedal on 1/15/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct AppConstants {
    
    public static let APP_VERSION = "V 1.0"
    
    //URLS - - -
    public static let PROD_BASE_URL  = "https://goldapi.goldmedalindia.in/api/hrm/v1.0/"
    public static let TESTING_BASE_URL = "https://goldapi.goldmedalindia.in/api/hrm/v1.0/"
    
    public static let DEVICE_TYPE = "ios"
    public static let APP_TYPE = "3"
    
    public static let CLIENT_ID = "HRM_347362"
    public static let CLIENT_SECRET = "8njmLe/g9ih+6wLxYx/O4D56N+1q7sR71CzZb4uJLhIeFQNiIzMnxm1kZAIUHyxtwM+CIkYw9ct7CCebDTIQPh9oyOBPz/bpdf+7oM6cU="
    
    //CONTROLLERS - - -
    public static let LOGIN = "Login/authenticate"
    public static let GET_OTP = "otp/sendotp"
    public static let VERIFY_OTP = "otp/verifyotp"
    public static let RESET_PASSWORD = "password/forgetpassword"
    public static let UPCOMING_BIRTHDAYS = "events/getBirthdaysInWeek"
    public static let UPCOMING_ANNIVERSARY = "events/getAnniversaryInWeek"
    public static let UPCOMING_HOLIDAY = "events/getHolidayList"
    public static let LEAVE_RECORDS = "leaves/getLeavesHistory"
    public static let LEAVE_TYPE = "leaves/getLeaveTypes"
    public static let LEAVE_APPLY = "leaves/applyLeave"
    public static let LEAVE_ACTUAL_APPLIED_COUNT = "leaves/getActualAppliedCount"
    public static let LEAVE_REASON =  "leaves/getLeaveReasons"
    public static let INSERT_PUNCH_DATA = "punchdata/InsertPunchInandOut"
    public static let GET_PUNCH_DATA = "punchdata/getPunchData"
    public static let GET_PUNCH_STATUS = "punchdata/punchInOutStatus"
    public static let GET_ALL_PUNCH_DATA = "punchdata/getAllPunchData"
}

