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

struct ContentView: View {
    @EnvironmentObject var al: AppLogic
    @EnvironmentObject var db: DB
    @EnvironmentObject var lsd: LoadSharedDimensions
    var body: some View {
        ZStack {
            TabView {
                GeometryReader {g in
                    ThreeD()
                        .edgesIgnoringSafeArea(.top)
                        .frame(width: g.size.width, height: g.size.height)
                }
                .tabItem {
                    Image(systemName: "view.3d").font(.title)
                }
                ARContentView()
                    .tabItem {
                        Image(systemName: "camera.viewfinder").font(.title)
                    }
                Controls()
                    .tabItem {
                        Image(systemName: "gear").font(.title)
                    }
            }
            .padding(0)
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
        }
        //
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
