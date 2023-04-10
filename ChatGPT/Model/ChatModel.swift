//
//  ChatModel.swift
//  ChatGPT
//
//  Created by Lazyloading on 2023/4/4.
//

import Foundation
import WCDBSwift
import Alamofire

// MARK: - ChatRowModel
final class ChatRowModel : TableCodable{
    var content : String = ""
    var icon : String = ""
    var role : String = ""
    var timestamp : Int = 0
    var identifier : Int? = nil
    var isAutoIncrement: Bool = true
    var lastInsertedRowID: Int64 = 0
    
    lazy var timeDesc : String = {
        let format = DateFormatter()
        format.dateFormat = "yyyy/M/dd HH:mm:ss"
        return format.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }()
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = ChatRowModel

        case content
        case icon
        case role
        case timestamp
        case identifier
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self){
            BindColumnConstraint(identifier,isPrimary: true,isAutoIncrement: true)
            BindColumnConstraint(timestamp,orderBy: .ascending)
        }
    }
    
    static func insertRecord(_ record : ChatRowModel){
        record.isAutoIncrement = true
        do{
           try DBManager.shared().db.insert(record, intoTable: "record_tb")
            debugPrint("插入记录成功")
        }catch{
            debugPrint("插入记录失败: \(error)")
        }
    }
    
    static func getObjetcs() -> [ChatRowModel]?{
        do{
            let res : [ChatRowModel] = try DBManager.shared().db.getObjects(fromTable: "record_tb")
            debugPrint("查询记录成功")
            return res
        }catch{
            debugPrint("查询记录失败\(error)")
            return nil
        }
    }
    
}

enum ChatRole {
    case user(String)
    case openai
}


// MARK: - ChatModel
struct ChatModel: Codable {
    let id, object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
    
    
    static func openai(_ keyword : String, _ key : String,completed : @escaping (ChatRowModel)->Void)  {
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(key)",
            "Content-Type": "application/json"
        ]
        let params : [String : Any] = [
            "model" : "gpt-3.5-turbo",
            "messages" : [
                ["role" : "user","content" : keyword]
            ]
        ]
        print("headers: \(headers)\n body : \(params)")
        AF.request("https://api.openai.com/v1/chat/completions",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: headers
        ){request in
            request.timeoutInterval = 30.0;
        }.responseData { response in
            print(response)
            switch response.result{
            case .success(let data):
                do{
                    let model = try JSONDecoder().decode(ChatModel.self, from: data)
                    if let conetnt = model.choices.first?.message.content{
                        let chatgpt = ChatModel.createChatRow(content: conetnt, role: .openai)
                        ChatRowModel.insertRecord(chatgpt)
                        completed(chatgpt)
                    }
                }catch{
                    debugPrint("请求失败\(error)")
                    let chatgpt = ChatModel.createChatRow(content: error.localizedDescription, role: .openai)
                    ChatRowModel.insertRecord(chatgpt)
                    completed(chatgpt)
                }
            case .failure(let error):
                debugPrint("请求失败\(error)")
                let chatgpt = ChatModel.createChatRow(content: error.localizedDescription, role: .openai)
                ChatRowModel.insertRecord(chatgpt)
                completed(chatgpt)
            }
        }
    }
    static func createChatRow(content : String,role : ChatRole) -> ChatRowModel {
        let chatgpt = ChatRowModel()
        chatgpt.content = content
        chatgpt.timestamp = Int(Date.now.timeIntervalSince1970)
        
        switch role {
        case .user(let string):
            chatgpt.role = string
            chatgpt.icon = "head"
        case .openai:
            chatgpt.role = "OpenAI"
            chatgpt.icon = "Chatgpt"
        }
        
        return chatgpt
    }
}

// MARK: - Choice
struct Choice: Codable {
    let message: Message
    let finishReason: String
    let index: Int

    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
        case index
    }
}

// MARK: - Message
struct Message: Codable {
    let role, content: String
}

// MARK: - Usage
struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
