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
            // 
    }
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppLogic())
    }
}
#endif
