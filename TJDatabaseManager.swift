//  TJDatabaseManager.swift
//  Database Demo
//
//  Created by Tejas Ardeshna on 09/08/17.
//  Copyright © 2017 Tejas Ardeshna. All rights reserved.
//

import UIKit
import FMDB

let kDataBaseName = "YOUR_DATABASENAME" //don't include file extention
class TJDatabaseManager {
    
    let applyDatabaseVersoning = false //if you want to create database copy for each new version release
    
    // static properties get lazy evaluation and dispatch_once_t for free
    struct Static {
        static let instance = TJDatabaseManager()
    }
    
    // this is the Swift way to do singletons
    class var databaseManager: TJDatabaseManager
    {
        return Static.instance
    }
    
    //
    //Copy database to diractory
    //
    
    func copyDatabaseIfNeeded() {
        //Using NSFileManager we can perform many file system operations.
        let bundlePath = Bundle.main.path(forResource: kDataBaseName, ofType: ".sqlite")
        let fileManager = FileManager.default
        let fullDestPath = URL(string : self.getDBPath())
        if fileManager.fileExists(atPath: (fullDestPath?.path)!){
            print("Database file is exist")
            print(fullDestPath!.path)
        }else{
            do{
                try fileManager.copyItem(atPath: bundlePath!, toPath: (fullDestPath?.path)!)
                print("DB Path:\(fullDestPath!.path)")
            }catch{
            }
        }
    }
    //
    // Find database path
    //
    func getDBPath() -> String {
        let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir: String = paths[0] as? String ?? ""
        let strDatabaseName: String = applyDatabaseVersoning ? self.getDatabaseNameWithVersionNumber() : kDataBaseName
        return URL(fileURLWithPath: documentsDir).appendingPathComponent(strDatabaseName).absoluteString + ".sqlite"
    }
    
    //
    // Execute update
    //
    func executeUpdate(_ query: String) -> Bool {
        var status: Bool
        let db = FMDatabase(path: self.getDBPath())
        db.open()
        
        do {
            try db.executeUpdate(query, values: nil)
            status = true
            
        } catch {
            print(error)
            status = false
        }
        db.close()
        return status
    }
    
    //
    // Execute custom query
    //
    func execute(_ query: String) -> [AnyObject]{
        var array = [AnyObject]()
        let db = FMDatabase(path: self.getDBPath())
        db.open()
        var rs: FMResultSet?
        do {
            rs = try db.executeQuery(query, values: nil)
        }
        catch{
            
        }
        if rs != nil{
            while rs!.next() {
                array.append(rs?.resultDictionary as AnyObject)
            }
            rs?.close()
        }
        defer {
        }
        db.close()
        return array
    }
    
    //
    // For database versoning
    //
    func getDatabaseNameWithVersionNumber() -> String {
        let buildVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        let strVersionNumber: String = buildVersion!.replacingOccurrences(of: ".", with: "_")
        let strDatabaseName: String = "\(strVersionNumber)\(kDataBaseName)"
        return strDatabaseName
    }
    
    //
    // Perform batch operations
    //
    func executeBatchOperations(_ arrQueries: [String]) {
        let queue = FMDatabaseQueue(path: self.getDBPath())
        queue.inTransaction({ (db, rollback) in
            for query: String in arrQueries {
                do {
                    try db.executeUpdate(query, values: nil)
                } catch {
                    print(error)
                }
            }
        })
    }
}
