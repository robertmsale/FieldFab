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

struct ContentView : View {
    @EnvironmentObject var al: AppLogic
    var body: some View {
        TabView {
            TwoD()
                .tabItem {
                    Image(systemName: "view.2d").font(.title)
                }
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
        .sheet(isPresented: $al.shareSheetShown, content: {
            ActivityView(activityItems: al.shareSheetContent!, applicationActivities: nil)
        })
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
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppLogic())
    }
}
#endif
