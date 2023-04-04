//
//  ChatModel.swift
//  ChatGPT
//
//  Created by Lazyloading on 2023/4/4.
//

import Foundation


// MARK: - ChatRowModel
struct ChatRowModel {
    let content : String
    let icon : String
    let role : String
}

// MARK: - ChatModel
struct ChatModel: Codable {
    let id, object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
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
