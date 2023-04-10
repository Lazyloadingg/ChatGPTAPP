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
    @State var isShow : Bool = false
    @State var contentArray : Array<ChatRowModel> = {
        if var chats = ChatRowModel.getObjetcs(){
            return chats
        }
        return []
    }()
    
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
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                ChatCell(content: row.content,icon: row.icon,timestamp: row.timeDesc).onTapGesture {
                    print("点击\(index)")
                }
            }
        }
        .listStyle(.plain)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    
    func requestData(keyword : String)  {
        print("请求\(keyword)")
        
        let user = ChatModel.createChatRow(content: keyword, role: .user("我"))
        contentArray.append(user)
        ChatRowModel.insertRecord(user)
        contentText = ""
        
        ChatModel.openai(keyword, key) {
            contentArray.append($0)
        }
    }
 
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
