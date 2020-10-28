//
//  ObjectHitPopup.swift
//  FieldFab
//
//  Created by Robert Sale on 10/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct ObjectHitPopup: View {
    @EnvironmentObject var al: AppLogic
    @Environment(\.colorScheme) var colorScheme
    @Binding var shown: Bool
    var object: SceneObject
    
    func getSide() -> String {
        switch object {
            case .front: return "Front"
            case .back: return "Back"
            case .left: return "Left"
            case .right: return "Right"
        }
    }
    
    var body: some View {
        VStack {
            Text("\(getSide()) Selected").font(.title)
            Divider()
            Button(action: {
                switch object {
                    case .front: al.makeSideFlat(side: .front)
                    case .back: al.makeSideFlat(side: .back)
                    case .left: al.makeSideFlat(side: .left)
                    case .right: al.makeSideFlat(side: .right)
                }
                al.threeDObjectHitPopupShown = false
            }, label: {
                Text("Make Side Flat").font(.title)
                    .padding()
                    .background(AppColors.ControlBG[colorScheme])
                    .cornerRadius(15)
            })
            Divider()
            Button(action: {
                shown = false
            }, label: {
                Text("Cancel")
                    .padding()
                    .background(AppColors.ControlBG[colorScheme])
                    .cornerRadius(15)
                    .foregroundColor(.red)
            })
        }
        .padding()
        .frame(width: 256, height: 256)
        .background(BlurEffectView())
        .cornerRadius(15)
    }
}

struct ObjectHitPopup_Previews: PreviewProvider {
    static var previews: some View {
        ObjectHitPopup(shown: .constant(true), object: .front)
    }
}
