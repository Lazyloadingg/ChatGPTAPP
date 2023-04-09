//
//  ChatView.swift
//  ChatGPT
//
//  Created by Lazyloading on 2023/4/4.
//

import SwiftUI
import Alamofire

struct ChatView: View {
    
    @State var contentText : String = ""
    @State var contentArray : Array<ChatRowModel> = []
    @State var isShow : Bool = false
    @State var key: String = {
        let model = APIKeyModel.getCurrentKey()
        return model!.key
    }()
    
    
    var body: some View {
        VStack{
            toolView()
            chatList()
            ChatInputView(contentText: $contentText) { keyword in
                requestData(keyword: keyword)
            }
        }
    }
    
    func toolView() -> some View {
        return HStack(alignment: .center){
            Spacer()
            
            Button("Key") {
                isShow.toggle()
            }.buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .background(.blue.opacity(0.7))
                .cornerRadius(10)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
                .sheet(isPresented: $isShow, content: {
                    ChatSettingView(isShow: $isShow)
                })
        }
        .padding(.horizontal,15)
        .background(Color.gray.opacity(0.2))
        
    }
    
    func chatList() -> some View {
        List{
            ForEach(0..<$contentArray.count,id: \.self) { index in
                let row = contentArray[index]
                ChatCell(content: row.content,icon: row.icon)
            }
        }
    }
    
    
    func requestData(keyword : String)  {
        print("请求\(keyword)")
        openai(keyword)
        let user = ChatRowModel(content: keyword, icon: "head", role: "我")
        contentArray.append(user)
        contentText = ""
    }
    
    func openai(_ keyword : String?)  {
        guard keyword != nil else{
            return
        }
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(self.key)",
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
                        let chatgpt = ChatRowModel(content: conetnt, icon: "Chatgpt", role: "OpenAI")
                        contentArray.append(chatgpt)
                    }
                }catch{
                    debugPrint("请求失败\(error)")
                    let chatgpt = ChatRowModel(content: error.localizedDescription, icon: "Chatgpt", role: "OpenAI")
                    contentArray.append(chatgpt)
                }
            case .failure(let error):
                debugPrint("请求失败\(error)")
                let chatgpt = ChatRowModel(content: error.localizedDescription, icon: "Chatgpt", role: "OpenAI")
                contentArray.append(chatgpt)
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
