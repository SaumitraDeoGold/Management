////
////  SQLiteDB.swift
////  DealorsApp
////
////  Created by Goldmedal on 12/20/18.
////  Copyright © 2018 Goldmedal. All rights reserved.
////
//
//import Foundation
//import SQLite
//
//class SQLiteDB {
//    static let instance = SQLiteDB()
//    private var db: Connection? = nil
//
//    let currentDate = NSDate()
//    let dateFormatter = DateFormatter()
//    var strDateTime = String()
//    var strCin = String()
//    var strClientSecret = String()
//    var strAppId = String()
//    var strDeviceId = String()
//    var strDeviceModel = String()
//    var strDeviceType = String()
//    var strOsVersion = String()
//
//    var analyticsData = [AnalyticsData]()
//    private let analyticsTable = Table("analyticsTable")
//
//    private let clientSecret = Expression<String>("clientSecret")
//    private let cin = Expression<String>("cin")
//    private let screenName = Expression<String>("screenName")
//    private let screenId = Expression<Int64>("screenId")
//    private let dateTime = Expression<String>("dateTime")
//    private let appId = Expression<String>("appId")
//    private let osVersion = Expression<String>("osVersion")
//    private let deviceId = Expression<String>("deviceId")
//    private let deviceModel = Expression<String>("deviceModel")
//    private let deviceType = Expression<String>("deviceType")
//
//    var notificationData = [NotificationData]()
//    private let notificationTable = Table("notificationTable")
//
//    private let notificationId = Expression<String>("notificationId")
//    private let informToServer = Expression<String>("informToServer")
//    private let cinNotif = Expression<String>("cinNotif")
//    private let redirectToActivity = Expression<String>("redirectToActivity")
//    private let redirecturl = Expression<String>("redirecturl")
//    private let imageUrl = Expression<String>("imageUrl")
//    private let title = Expression<String>("title")
//    private let body = Expression<String>("body")
//
//    private init() {
//        let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory, .userDomainMask, true
//            ).first!
//
//        do {
//            db = try Connection("\(path)/DB.sqlite3")
//        } catch {
//            db = nil
//            print ("Unable to open database")
//        }
//
//        strClientSecret = "Client Secret"
//
//        //        strDeviceId = ((UIApplication.shared.delegate as! AppDelegate).tokenString ?? "-")!
//        //        if(strDeviceId.isEqual("")){
//        //            strDeviceId = "-"
//        //        }
//
//        strDeviceId = UIDevice.current.identifierForVendor!.uuidString
//        if(strDeviceId.isEqual("")){
//            strDeviceId = "-"
//        }
//
//
//        strOsVersion = UIDevice.current.systemVersion
//        if(strOsVersion.isEqual("")){
//            strOsVersion = "-"
//        }
//
//        strDeviceModel = (UIDevice().type.rawValue ?? "-")
//
//        strDeviceType = "ios"
//
//        //        strAppId = Bundle.main.bundleIdentifier ?? "-"
//        //        if(strAppId.isEqual("")){
//        //            strAppId = "-"
//        //        }
//
//        strAppId = "1"
//
//        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
//        strCin = loginData["userlogid"] as? String ?? "-"
//
//        createTable()
//
//    }
//
//    //  - - - - -  -SQLite table for getting analytics data  - - - - - - - -
//    func createTable() {
//        do {
//            try db!.run(analyticsTable.create(ifNotExists: true) { table in
//                table.column(clientSecret)
//                table.column(cin)
//                table.column(screenName)
//                table.column(screenId)
//                table.column(dateTime)
//                table.column(appId)
//                table.column(osVersion)
//                table.column(deviceId)
//                table.column(deviceModel)
//                table.column(deviceType)
//            })
//            print("created analytics table")
//        } catch {
//            print("Unable to create analytics table")
//        }
//    }
//
//
//    func addAnalyticsData(ScreenName: String,ScreenId: Int64) -> Int64? {
//        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
//        strDateTime = dateFormatter.string(from: currentDate as Date)
//        print("DATE TIME - - - ",strDateTime)
//        do {
//            let insert = analyticsTable.insert(clientSecret <- strClientSecret, cin <- strCin, screenName <- ScreenName, screenId <- ScreenId, dateTime <- strDateTime, appId <- strAppId, osVersion <- strOsVersion, deviceId <- strDeviceId, deviceModel <- strDeviceModel, deviceType <- strDeviceType)
//
//            let id = try db!.run(insert)
//
//            return id
//            print("Item analytics inserted")
//        } catch {
//            print("Insert analytics failed")
//            return -1
//        }
//    }
//
//
//    func getAnalyticsData() -> [AnalyticsData] {
//        do {
//            for i in try db!.prepare(self.analyticsTable) {
//                analyticsData.append(AnalyticsData(
//                    clientSecret: i[clientSecret],
//                    cin: i[cin],
//                    screenName: i[screenName],
//                    screenId: i[screenId],
//                    dateTime: i[dateTime],
//                    appId: i[appId],
//                    osVersion: i[osVersion],
//                    deviceId: i[deviceId],
//                    deviceType: i[deviceType],
//                    deviceModel: i[deviceModel]))
//
//                print("cin:\(i[cin]) ,screenId:\(i[screenName]) ,screenName:\(i[screenName]), screenId:\(i[screenId]) ,dateTime:\(i[dateTime]) ,appId:\(i[appId]) ,osVersion:\(i[osVersion]), deviceId:\(i[deviceId]), deviceModel:\(i[deviceModel]), deviceType:\(i[deviceType])")
//            }
//        } catch {
//            print("Select failed")
//        }
//
//        return analyticsData
//    }
//
//
//    func deleteAnalyticsData() -> Bool {
//        do {
//            try db!.run(analyticsTable.delete())
//            return true
//        } catch {
//            print("Delete failed")
//        }
//        return false
//    }
//
//    //     //  - - - - -  - SQLite table for getting notification data  - - - - - - - -
//    //    func createNotificationTable() {
//    //
//    //        do {
//    //            try db!.run(notificationTable.create(ifNotExists: true) { table in
//    //                table.column(notificationId)
//    //                table.column(informToServer)
//    //                table.column(cinNotif)
//    //                table.column(redirectToActivity)
//    //                table.column(redirecturl)
//    //                table.column(imageUrl)
//    //                table.column(title)
//    //                table.column(body)
//    //            })
//    //            print("created notif table")
//    //        } catch {
//    //            print("Unable to create notif table")
//    //        }
//    //    }
//
//
//    //    func addNotification(NotificationId: String,InformToServer: String,CinNotif: String,RedirectToActivity: String,Redirecturl: String,ImageUrl: String,Title: String,Body: String) -> Int64? {
//    //        do {
//    //            let insert = notificationTable.insert(notificationId <- NotificationId, informToServer <- InformToServer, cinNotif <- CinNotif, redirectToActivity <- RedirectToActivity, redirecturl <- Redirecturl, imageUrl <- ImageUrl, title <- Title, body <- Body)
//    //            let id = try db!.run(insert)
//    //
//    //            return id
//    //            print("Item notif inserted")
//    //        } catch {
//    //            print("Insert notif failed")
//    //            return -1
//    //        }
//    //    }
//
//
//    //    func getNotificationData() -> [NotificationData] {
//    //        do {
//    //            for i in try db!.prepare(self.notificationTable) {
//    //                notificationData.append(NotificationData(
//    //                    notificationId: i[notificationId],
//    //                    informToServer: i[informToServer],
//    //                    cinNotif: i[cinNotif],
//    //                    redirectToActivity: i[redirectToActivity],
//    //                    redirecturl: i[redirecturl],
//    //                    imageUrl: i[imageUrl],
//    //                    title: i[title],
//    //                    body: i[body]
//    //                    ))
//    //
//    //                print("notificationId:\(i[notificationId]) ,informToServer:\(i[informToServer]) ,cin:\(i[cinNotif]) ,redirectToActivity:\(i[redirectToActivity]) ,redirecturl:\(i[redirecturl]),imageUrl:\(i[imageUrl]),title:\(i[title]),body:\(i[body])")
//    //            }
//    //        } catch {
//    //            print("Select failed")
//    //        }
//    //
//    //        return notificationData
//    //    }
//    //
//    //
//    //    func deleteNotificationData(nid: Int64) -> Bool {
//    ////        do {
//    ////            let notifData = notificationTable.filter(Int64(id) == nid)
//    ////            try db!.run(notifData.delete())
//    ////            return true
//    ////        } catch {
//    ////            print("Delete failed")
//    ////        }
//    //        return false
//    //    }
//
//
//}
