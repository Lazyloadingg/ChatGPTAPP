//
//  DBManager.swift
//  ChatGPT
//
//  Created by lazyloading on 2023/4/8.
//

import Foundation
import WCDBSwift

private let database = DBManager()


class DBManager {

    
    
    let db : Database = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let database = Database(at: path! + "/chat.db")
        print("数据库路径\(database.path)")
        return database
    }()
    
    
    static func shared() -> DBManager {
        return database
    }
    
    
    func createTable<T : TableDecodable>(table tableName : String, type : T.Type)  {
        do{
            try db.create(table: tableName, of: type)
            debugPrint("建表成功")
        }catch{
            debugPrint("建表失败\(error)")
        }
    }
    
}
