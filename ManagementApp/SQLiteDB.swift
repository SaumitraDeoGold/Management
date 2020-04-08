//
//  SQLiteDB.swift
//  ManagementApp
//
//  Created by Goldmedal on 2/5/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//


import Foundation
import SQLite

class SQLiteDB {
    static let instance = SQLiteDB()
    private var db: Connection? = nil
    
    var strPunchDate = String()
    var strFirstPunchIn = String()
    var strLastPunchOut = String()
    var strPunchInOutTime = String()
    var strPunchStatus = String()
    var strTotalHours = String()
    var strPunchType = String()
    var strPunchInAddress = String()
    var strPunchOutAddress = String()
    
    var getAttendanceData = [GetAllAttendanceData]()
    private let attendanceTable = Table("attendanceTable")
    
    private let punchDate = Expression<String>("punchDate")
    private let firstPunchIn = Expression<String>("firstPunchIn")
    private let lastPunchOut = Expression<String>("lastPunchOut")
    private let punchInOutTime = Expression<String>("punchInOutTime")
    private let punchStatus = Expression<String>("punchStatus")
    private let totalHours = Expression<String>("totalHours")
    private let punchType = Expression<String>("punchType")
    private let punchInAddress = Expression<String>("punchInAddress")
    private let punchOutAddress = Expression<String>("punchOutAddress")
    
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/DB.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
        
    }
    
    //  - - - - -  -SQLite table for getting analytics data  - - - - - - - -
    func createTable() {
        do {
            try db!.run(attendanceTable.create(ifNotExists: true) { table in
                table.column(punchDate)
                table.column(punchInOutTime)
                table.column(punchType)
                table.column(punchStatus)
                table.column(firstPunchIn)
                table.column(lastPunchOut)
                table.column(totalHours)
                table.column(punchInAddress)
                table.column(punchOutAddress)
            })
            print("created analytics table")
        } catch {
            print("Unable to create analytics table")
        }
    }
    
    
    func addAttendanceData(objAttendance: GetAllAttendanceData) -> Int64? {
        
        do {
            let insert = attendanceTable.insert(punchDate <- objAttendance.date ?? "-", punchInOutTime <- objAttendance.punchInPunchOut ?? "-", punchType <- objAttendance.type ?? "-", punchStatus <- objAttendance.statusPunch ?? "-", firstPunchIn <- objAttendance.firstIn ?? "-", lastPunchOut <- objAttendance.lastOut ?? "-", totalHours <- objAttendance.totalHours ?? "-", punchInAddress <- "sdhfauyghf asjudfgasy asdhfasu malad west 400064", punchOutAddress <- "sdhfauyghf asjudfgasy asdhfasu malad west 400064")
            
            let id = try db!.run(insert)
            
            return id
            print("Item attendance inserted")
        } catch {
            print("Insert attendance failed")
            return -1
        }
    }
    
    func GetAttendanceData() -> [GetAllAttendanceData] {
        do {
            for i in try db!.prepare(self.attendanceTable) {
                
                getAttendanceData.append(GetAllAttendanceData(date: i[punchDate], firstIn: i[firstPunchIn], lastOut: i[lastPunchOut], totalHours: i[totalHours], punchInPunchOut: i[punchInOutTime], statusPunch: i[punchStatus], type: i[punchType]))
                
                print("punchDate:\(i[punchDate]) ,firstPunchIn:\(i[firstPunchIn]) ,punchInOutTime:\(i[punchInOutTime]), totalHours:\(i[totalHours]) ,punchType:\(i[punchType]) ,totalHours:\(i[totalHours])")
            }
        } catch {
            print("Select failed")
        }
        print("Attendance data - - - - - -",getAttendanceData)
        return getAttendanceData
    }
    
    
    func deleteAttendanceData() -> Bool {
        do {
            try db!.run(attendanceTable.delete())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
}
