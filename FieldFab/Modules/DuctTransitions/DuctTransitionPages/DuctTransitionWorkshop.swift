//
//  DuctTransitionWorkshop.swift
//  FieldFab
//
//  Created by Robert Sale on 12/30/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
#if DEBUG
@_exported import HotSwiftUI
#endif

extension DuctTransition {
    struct Workshop: View {
        @State var ductwork: DuctTransition.DuctData
        @EnvironmentObject var state: DuctTransition.ModuleState
        @EnvironmentObject var appState: AppState
        @State var tabSelected = 0
        @State var menuShown = false
        @State var saveCompleteShown = false
        @State var faceHit: String = ""
        @State var showSideFlatDialog: Bool = false
        @State var resetARSession: Bool = false
        
        func generateShareLink() -> String {
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(ductwork)
            let b64 = encoded.base64EncodedString()
            let urle = b64.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return "fieldfab://data?encoded=\(urle!)"
        }
        
        var renderPDF: URL {
            let w: CGFloat = 1276
            let h: CGFloat = 1648
            let renderer = ImageRenderer(content: DuctToPDF(ductwork: ductwork).frame(width: w, height: h))
            let url = URL.documentsDirectory.appending(path: "\(ductwork.name).pdf")
            
            renderer.render { size, context in
                var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                    return
                }
                
                pdf.beginPDFPage(nil)
                
                context(pdf)
                pdf.endPDFPage()
                pdf.closePDF()
            }
            
            return url
        }
        
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
                    ZStack {
                        DuctTransition.DuctAR(geo: g, textShown: false, ductwork: ductwork, ductSceneHitTest: {s in
                            faceHit = s
                            showSideFlatDialog = true
                        }, resetARSession: $resetARSession, selectorShown: Binding.blank(false))
                        VStack {
                            HStack {
                                Menu("Translation Mode") {
                                    Picker("Translation Mode", selection: $state.translationMode) {
                                        ForEach(DuctTransition.ModuleState.TranslationMode.allCases) { tm in
                                            Text(tm.localizedString).tag(tm)
                                        }
                                    }
                                }
                                Spacer()
                                Menu("Flow Direction") {
                                    Picker("Flow Direction", selection: $state.flowDirection) {
                                        ForEach(DuctTransition.ModuleState.FlowDirection.allCases) { fd in
                                            Text(fd.localizedString).tag(fd)
                                        }
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    Task {
                                        resetARSession = true
                                    }
                                }) {
                                    Image(systemName: "arrow.counterclockwise")
                                }
                                .font(.title)
                            }
                            .padding(.all)
                            .background {
                                BlurEffectView()
                            }
                            Spacer()
                        }
                    }
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
                Menu(content: {
                    ShareLink("Share Link", item: generateShareLink())
                    ShareLink("Share PDF", item: renderPDF)
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
            }
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        #if DEBUG
        @ObservedObject var iO = injectionObserver
        #endif
    }
}

