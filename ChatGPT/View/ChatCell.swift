//
//  ChatCell.swift
//  ChatGPT
//
//  Created by lazyloading on 2023/4/9.
//

import SwiftUI

struct ChatCell: View {
    var content : String = ""
    var icon : String = ""
    
    var body: some View{
        HStack(alignment: .top,spacing: 15, content: {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30,height: 30)
            Text(content)
        }).padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
    }
}

struct ChatCell_Previews: PreviewProvider {
    static var previews: some View {
        ChatCell()
    }
}
