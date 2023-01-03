//
//  DuctTransitionWorkshop.swift
//  FieldFab
//
//  Created by Robert Sale on 12/30/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI

extension DuctTransition {
    struct Workshop: View {
        @State var ductwork: DuctTransition.DuctData
        @EnvironmentObject var state: DuctTransition.ModuleState
        @State var tabSelected = 0
        @State var menuShown = false
        @State var saveCompleteShown = false
        @State var faceHit: String = ""
        @State var showSideFlatDialog: Bool = false
        var body: some View {
            TabView(selection: $tabSelected) {
                DuctTransition.DuctEditor(ductwork: $ductwork)
                    .tabItem {
                        Label("Workshop", systemImage: "hammer")
                    }
                    .tag(0)
                GeometryReader { g in
                    DuctTransition.SceneView(geo: g, textShown: false, ductwork: ductwork, ductSceneHitTest: {s in
                        faceHit = s
                        showSideFlatDialog = true
                    }, selectorShown: Binding.blank(false))
                }
                    .tabItem {
                        Label("3D", systemImage: "scale.3d")
                    }
                    .tag(1)
                GeometryReader { g in
                    DuctTransition.DuctAR(geo: g, textShown: false, ductwork: ductwork, ductSceneHitTest: {s in
                        faceHit = s
                        showSideFlatDialog = true
                    }, selectorShown: Binding.blank(false))
                }
                    .tabItem {
                        Label("AR", systemImage: "camera.viewfinder")
                    }
                    .tag(2)
            }
            .alert(String("Make \(faceHit) side flat?"), isPresented: $showSideFlatDialog) {
                Button(action: {
                    Task {
                        showSideFlatDialog = false
                    }
                }, label: {
                    Text("No")
                })
                Button(action: {
                    Task {
                        ductwork.makeSideFlat(faceHit)
                        showSideFlatDialog = false
                    }
                }, label: {
                    Text("Yes")
                })
            }
            .animation(.easeOut, value: tabSelected)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            .transition(.slide)
            .navigationTitle(ductwork.name)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(DuctTransition.ModuleToolbar(cameraHelpShown: $state.cameraHelpShown, arCameraHelpShown: $state.arCameraHelpShown, generalHelpShown: $state.generalHelpShown, settingsViewShown: $state.settingsViewShown))
            .toolbar {
                Button(action: {
                    Task {
                        if let idx = state.ductData.firstIndex(where: { $0.id == ductwork.id }) {
                            state.ductData[idx] = ductwork
                        }
                        saveCompleteShown = true
                    }
                }) {
                    Image(systemName: "tray.and.arrow.down")
                }.alert("Ductwork Saved", isPresented: $saveCompleteShown, actions: {
                    Button(action: {Task {saveCompleteShown = false}}) {
                        Text("Ok")
                    }
                })
            }
        }
    }
}

#if DEBUG
struct DuctTransitionWorkshop_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            DuctTransition.Workshop(ductwork: DuctTransition.DuctData())
                .environmentObject(DuctTransition.ModuleState())
                
        }
    }
}
#endif
