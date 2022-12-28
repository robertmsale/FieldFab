//
//  WorkView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/20/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import VectorExtensions
import VectorProtocol
import PopupView
import ARKit

extension CGPoint {
    mutating func lerp(v: Self, alpha: CGFloat) {
        x += (v.x - x) * alpha
        y += (v.y - y) * alpha
    }
    func lerped(v: Self, alpha: CGFloat) -> Self { var x = self; x.lerp(v: v, alpha: alpha); return x }
}

struct WorkView: View {
    @EnvironmentObject var state: AppState
    @State var settingsViewActive = false
    
    func renderBody() -> some View {
        let cwb = Binding<Duct>(get: {
            state.currentWork ?? Duct()
        }, set: {
            state.currentWork = $0
        })
        let cw = state.currentWork ?? Duct()
        
        return TabView(selection: $state.currentWorkTab) {
            WorkShopView(data: cwb).tag(0).tabItem {
                Image(systemName: "hammer")
                Text("Workshop")
            }
            Work3DView().tag(1).tabItem {
                Image(systemName: "perspective")
                Text("3D")
            }.edgesIgnoringSafeArea(.horizontal)
            #if !os(macOS)
            WorkViewAR().tag(2).tabItem {
                Image(systemName: "camera.viewfinder")
                Text("AR")
            }
            #endif
        }
        .navigationBarTitle("\(cw.data.name)")
        .navigationBarItems(trailing: HStack {
            Button(action: {
                if let index = state.ductData.firstIndex(where: { $0.id == cw.data.id }) {
                    state.ductData[index] = cw.data
                    state.popupSaveSuccessful = true
                }
            }, label: {
                Text("Save")
            })
            NavigationLink(destination: SettingsPage(), label: {Image(systemName: "gear")})
        })
        .popup(isPresented: Binding<Bool>(get: {
            switch state.ductSceneHitTest {
                case "Front","Back","Left","Right": return true
                default: return false
            }
        }, set: {
            if !$0 { state.ductSceneHitTest = nil }
        }), closeOnTap: false, view: {
            VStack {
                Text("Would you like to make the \(state.ductSceneHitTest ?? "") side flat?")
                HStack {
                    Button(action: {
                        Task {
                            state.ductSceneHitTest = nil
                        }
                    }, label: { Text("No").padding() } )
                    Spacer()
                    Button(action: {
                        Task {
                            state.currentWork?.makeSideFlat(state.ductSceneHitTest ?? "")
                            state.ductSceneHitTest = nil
                            state.sceneEvents.measurementsChanged = true
                            state.arEvents.measurementsChanged = true
                        }
                    }, label: { Text("Yes").padding() })
                }
            }
            .font(.title2)
            .padding()
            .background(BlurEffectView())
            .clipShape(RoundedRectangle(cornerRadius: 15))
        })
        
    }
    
    var body: some View {
        renderBody()
    }
}

#if DEBUG
//struct WorkView_Previews: PreviewProvider {
//    static var previews: some View {
//        var td = DuctTabContainer()
//        td.ft = DuctTab(length: .inch, type: .tapered)
//        td.fb = DuctTab(length: .inch, type: .tapered)
//        td.fl = DuctTab(length: .inch, type: .tapered)
//        td.fr = DuctTab(length: .inch, type: .tapered)
//        let appstate = AppState()
//        appstate.currentWork = Duct()
//        return VStack {
//            Work3DView().environmentObject(appstate)
//        }
//    }
//}
#endif
