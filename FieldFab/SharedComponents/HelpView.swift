//
//  HelpView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import WebKit

struct HelpWebKitView: UIViewRepresentable {
    @EnvironmentObject var state: AppState
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        let url = URL(string: "https://fieldfab.net/how-to")
        let request = URLRequest(url: url!)
        webView.load(request)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if !state.sheetsShown.helpWeb {
            uiView.removeFromSuperview()
        }
    }
}

#if DEBUG
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpWebKitView().environmentObject(AppState())
    }
}
#endif
