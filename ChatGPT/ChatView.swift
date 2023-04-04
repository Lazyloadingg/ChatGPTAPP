//
//  ChatView.swift
//  ChatGPT
//
//  Created by Lazyloading on 2023/4/4.
//

import SwiftUI
import Alamofire

struct ChatView: View {
    static let OPENAI_SCRECT_KEY  = ""
    @State var contentText : String = ""
    @State var contentArray : Array<ChatRowModel> = []
    var body: some View {
        VStack{
            chatList()
            chatField()
            Spacer()
        }
    }
    func chatList() -> some View {
        List{
            ForEach(0..<$contentArray.count,id: \.self) { index in
                let row = contentArray[index]
                ChatRow(content: row.content,icon: row.icon)
            }
        }
    }
    
    func chatField() -> some View {
        TextField("请输入内容", text: $contentText){value in
            print(value)
        }
        .onSubmit {
            requestData(keyword: contentText)
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 15,style: .continuous).stroke(.gray,lineWidth: 2)
        })
        .textFieldStyle(.plain)
        .cornerRadius(15)
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
    }
    
    func requestData(keyword : String)  {
        print("请求\(keyword)")
        openai(keyword)
        let user = ChatRowModel(content: keyword, icon: "Chat_mention_all", role: "我")
        contentArray.append(user)
        contentText = ""
    }
    
    func openai(_ keyword : String?)  {
        guard keyword != nil else{
            return
        }
        let headers : HTTPHeaders = [
            "Authorization" : "Bearer \(ChatView.OPENAI_SCRECT_KEY)",
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
                }
            case .failure(let error):
                debugPrint("请求失败\(error)")
            }
        }
    }
}

struct ChatRow : View {
    var content : String = ""
    var icon : String = ""
    var body: some View{
        HStack(alignment: .top,spacing: 15, content: {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25,height: 25)
            Text(content)
        }).padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
