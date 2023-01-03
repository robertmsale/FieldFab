//
//  HelpView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import WebKit

extension DuctTransition {
    struct HelpWebKitView: UIViewRepresentable {
        @Binding var shown: Bool
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView(frame: .zero)
            let url = URL(string: "https://fieldfab.net/how-to")
            let request = URLRequest(url: url!)
            webView.load(request)
            return webView
        }
        func updateUIView(_ uiView: WKWebView, context: Context) {
            if !shown {
                uiView.removeFromSuperview()
            }
        }
    }
    
    struct GeneralHelpView: View {
        @Binding var shown: Bool
        var body: some View {
            VStack {
                Rectangle().frame(height: 42)
                DuctTransition.HelpWebKitView(shown: $shown)
            }
        }
    }
}

#if DEBUG
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        DuctTransition.GeneralHelpView(shown: Binding(get: {true}, set: {_ in}))
    }
}
#endif
