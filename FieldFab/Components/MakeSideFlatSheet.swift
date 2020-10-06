//
//  MakeSideFlatSheet.swift
//  FieldFab
//
//  Created by Robert Sale on 10/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct MakeSideFlatSheet: View {
    var side: DuctSides
    @Binding var shown: Bool
    @EnvironmentObject var al: AppLogic
    @Environment(\.colorScheme) var colorScheme
    
    func getSideText() -> String {
        switch side {
            case .back: return "back"
            case .front: return "front"
            case .left: return "left"
            case .right: return "right"
        }
    }
    var body: some View {
        VStack {
            Text("Would you like to make the \(getSideText()) side flat?")
            HStack {
                Button(action: {shown = false}, label: {
                    Text("Cancel").foregroundColor(.red)
                })
                .padding()
                .background(AppColors.ControlBG[colorScheme])
                .cornerRadius(10)
                Spacer()
                Button(action: { al.makeSideFlat(side: side) }, label: {
                    Text("Confirm")
                })
                .padding()
                .background(AppColors.ControlBG[colorScheme])
                .cornerRadius(10)
            }
        }.padding()
    }
}

#if DEBUG
struct MakeSideFlatSheet_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) {
            MakeSideFlatSheet(side: .front, shown: $0).environmentObject(AppLogic())            
        }
    }
}
#endif
