//
//  Popup.swift
//  FieldFab
//
//  Created by Robert Sale on 10/28/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct Popup: ViewModifier {
    @Binding var shown: Bool
    var title: String = ""
    
    var titleView: AnyView {
        if title == "" {
            return AnyView(EmptyView())
        } else {
            return AnyView(
                TupleView(
                    (
                        Text(title).font(.title)
                    )
                )
            )
        }
    }
    
    func body(content: Content) -> some View {
        GeometryReader { g in
            ZStack {
                Rectangle()
                    .onTapGesture {
                        shown = false
                    }
                    .opacity(0.1)
                    .zIndex(1)
                VStack {
                    titleView
                    content
                }
                .padding()
                .frame(
                    minWidth: g.size.width * 0.5,
                    idealWidth: 200,
                    maxWidth: g.size.width * 0.8,
                    minHeight: g.size.height * 0.5,
                    idealHeight: 200,
                    maxHeight: g.size.height * 0.8,
                    alignment: .center)
                .background(BlurEffectView())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .zIndex(2)
            }
        }
    }
}

#if DEBUG
struct Popup_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) {
            Text("Ayyyy")
                .modifier(Popup(shown: $0, title: "Popup"))
        }
    }
}
#endif
