//
//  ContentView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import ARKit
import UIKit
import WebKit


struct ContentView: View {
    @EnvironmentObject var al: AppLogic
    @EnvironmentObject var db: DB
    @EnvironmentObject var lsd: LoadSharedDimensions
    @State var selectedTab = 0
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ThreeD()
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "view.3d").font(.title)
                    }
                    .onTapGesture {
                        selectedTab = 0
                    }
                    .tag(0)
                ARContentView()
                    .tabItem {
                        Image(systemName: "camera.viewfinder").font(.title)
                    }
                    .onTapGesture {
                        selectedTab = 1
                    }
                    .tag(1)
                Controls()
                    .tabItem {
                        Image(systemName: "gear").font(.title)
                    }
                    .onTapGesture {
                        selectedTab = 2
                    }
                    .tag(2)
            }
            .padding(0)
            .zIndex(1.0)
            if selectedTab == 0 {
                ZStack {
                    GeometryReader { g in
                        ObjectHitPopup(shown: $al.threeDObjectHitPopupShown, object: al.threeDObjectHit)
                            .position(x: g.size.width / 2, y: al.threeDObjectHitPopupShown ? g.size.height / 2 : CGFloat(2000))
                            .animation(.easeIn)
                    }
                }
                .zIndex(2.0)
                .onDisappear {
                    al.threeDObjectHitPopupShown = false
                }
            }
            ZStack {
                EmptyView()
                    .sheet(isPresented: $al.shareSheetShown, content: {
                        ActivityView(activityItems: al.shareSheetContent!, applicationActivities: nil)
                    })
                EmptyView()
                    .sheet(isPresented: $al.threeDMenuShown, content: {
                        ThreeDMenuSheet().environmentObject(al)
                    })
                EmptyView()
                    .sheet(isPresented: $al.helpViewShown, content: {
                        HelpView()
                    })
                EmptyView()
                    .sheet(isPresented: $al.aboutViewShown, content: {
                        AboutView()
                    })
                EmptyView()
                    .sheet(isPresented: $al.loadDuctworkViewShown, content: {
                        LoadDuctworkView().environmentObject(al).environmentObject(db)
                    })
                EmptyView()
                    .sheet(isPresented: $al.arMenuSheetShown, content: {
                        ARMenuSheet()
                    })
                EmptyView()
                    .sheet(isPresented: $al.loadSharedSheetShown, content: {
                        LoadSharedView().environmentObject(al).environmentObject(lsd)
                    })
                EmptyView()
                    .sheet(isPresented: $al.advancedSettingsSheetShown, content: {
                        AdvancedSettingsSheet().environmentObject(al)
                    })
                EmptyView()
                    .sheet(isPresented: $al.helpWebViewShown, content: {
                        VStack {
                            HStack {
                                Text("FieldFab How-to").font(.title)
                                Spacer()
                                Button(action: {
                                    al.helpWebViewShown = false
                                }, label: {
                                    Image(systemName: "xmark").font(.title)
                                })
                            }.padding()
                            HelpWebKitView().environmentObject(al)
                        }
                    })
            }
        }
        //
    }
}

struct HelpWebKitView: UIViewRepresentable {
    @EnvironmentObject var al: AppLogic
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        let url = URL(string: "https://fieldfab.net/how-to")
        let request = URLRequest(url: url!)
        webView.load(request)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if !al.helpWebViewShown {
            uiView.removeFromSuperview()
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {

    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppLogic())
    }
}
#endif
