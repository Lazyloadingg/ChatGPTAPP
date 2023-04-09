//
//  APIKeyModel.swift
//  ChatGPT
//
//  Created by lazyloading on 2023/4/8.
//

import Foundation
import WCDBSwift

final class APIKeyModel: TableCodable {
    var identifier : Int? = nil
    var key : String = ""
    var timestamp : Int? = 0
    var current : Bool = false
    var isAutoIncrement: Bool = true
    var lastInsertedRowID: Int64 = 0

    enum CodingKeys : String,CodingTableKey {
        typealias Root = APIKeyModel
 
        case key
        case timestamp
        case identifier
        static let objectRelationalMapping = TableBinding(CodingKeys.self){
            BindColumnConstraint(identifier, isPrimary: true)
            BindColumnConstraint(identifier, orderBy: .ascending,isAutoIncrement: true)
            BindColumnConstraint(key,isNotNull: true)
        }
        
    }

    static func insertKey(_ key : APIKeyModel){
        do{       
            try DBManager.shared().db.insert(key, intoTable: "key_tb")
            debugPrint("插入成功")
        }catch{
            debugPrint("插入失败: \(key) error: \(error)")
        }
    }
    
    static func getCurrentKey() -> APIKeyModel? {
        do{
            let model : APIKeyModel? = try DBManager.shared().db.getObject(fromTable: "key_tb",orderBy: [APIKeyModel.Properties.timestamp.order(.descending)])
            debugPrint("查询成功\(model!)")
            return model
        }catch{
            debugPrint("查询失败\(error)")
            return nil
        }
    }
}
