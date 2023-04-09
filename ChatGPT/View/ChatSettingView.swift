//
//  ChatSettingView.swift
//  ChatGPT
//
//  Created by Lazyloading on 2023/4/4.
//

import SwiftUI

struct ChatSettingView: View {
    @Binding var isShow : Bool
    @State var key : String = ""
    var body: some View {
        VStack{
            VStack(alignment: .leading){
                Text("API KEY")
                TextField("key", text: $key)
                    .frame(minWidth: 0,maxWidth: 300)
                    .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.5))
                    }
            }.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .frame(width: 350,height: 330)
            HStack(alignment: .center){
                Button("关闭"){
                    isShow = !isShow
                }
                .foregroundColor(Color.white)
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
                .background(Color.gray.opacity(0.7))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
                
                Button("保存"){
                    print(key)
                    let model = APIKeyModel()
                    model.key = key
                    model.timestamp = Int(Date.now.timeIntervalSince1970)
                    model.isAutoIncrement = true
                    APIKeyModel.insertKey(model)
                    print(model.lastInsertedRowID)
    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        isShow = !isShow
                    })
                }
                .foregroundColor(Color.white)
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
                .background(Color.blue.opacity(0.8))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
            }
            
            Spacer()
        }
        Spacer()
    }
}

struct ChatSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSettingView(isShow: .constant(true))
    }
}
