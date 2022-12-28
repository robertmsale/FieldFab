//
//  Work3DView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct Work3DView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.verticalSizeClass) var sizeClass
    var body: some View {
        ZStack {
            if true {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            state.sheetsShown.cameraHelp = true
                        }, label: {
                            Image(systemName: "questionmark")
                                .padding()
                                .background(BlurEffectView())
                                .clipShape(Circle())
                        })
                    }
                    Spacer()
                }.zIndex(4).padding()
                
            }
            DuctSCN().zIndex(1)
        }
        .edgesIgnoringSafeArea(.horizontal)
//        .popup(isPresented: Binding<Bool>(get: {
//            state.showHitTestTips && state.showHitTestTipsAgain
//        }, set: {
//            state.showHitTestTips = $0
//        }), type: .toast, position: .top, animation: .easeInOut, autohideIn: 8, closeOnTap: true, closeOnTapOutside: true, view: {
//            VStack {
//                Spacer().frame(width: 40, height: 140, alignment: .center)
//                VStack {
//                    Text("Try long-pressing one of the faces to make that side flat")
//                    Button(action: {
//                        state.showHitTestTipsAgain = false
//                    }, label: {Text("Don't show this again")})
//                }
//                .padding(.all, 4)
//                .background(BlurEffectView())
//                .clipShape(RoundedRectangle(cornerRadius: 5))
//            }
//        })
    }
}

struct Work3DView_Previews: PreviewProvider {
    static var previews: some View {
        Work3DView().environmentObject(AppState())
    }
}
