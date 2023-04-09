//
//  ChatInputView.swift
//  ChatGPT
//
//  Created by lazyloading on 2023/4/9.
//

import SwiftUI

struct ChatInputView: View {
    @Binding var contentText : String
    var requestAction : (String)->(Void)
    
    var body: some View {
        HStack{
            TextField("请输入内容", text: $contentText){value in
                print(value)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .overlay(content: {
                RoundedRectangle(cornerRadius: 15,style: .continuous).stroke(.gray,lineWidth: 2)
            })
            .textFieldStyle(.plain)
            .cornerRadius(15)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
            Button("请求") {
                requestAction(contentText)
//                requestData(keyword: contentText)
            }.buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .background(.blue.opacity(0.7))
                .cornerRadius(10)
        }
        .padding(.horizontal,15)
    }
}

//struct ChatInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatInputView()
//    }
//}
