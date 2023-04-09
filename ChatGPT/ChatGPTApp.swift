//
//  ChatGPTApp.swift
//  ChatGPT
//
//  Created by Lazyloading on 2023/4/3.
//

import SwiftUI

@main
struct ChatGPTApp: App {
    init() {
        setting()
    }
    
    var body: some Scene {
        
        WindowGroup {
            ChatView()
        }
    }
    
    func setting()  {
        DBManager.shared().createTable(table: "key_tb", type: APIKeyModel.self)
    }
}
