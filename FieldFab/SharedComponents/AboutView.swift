//
//  AboutView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
#if DEBUG
@_exported import HotSwiftUI
#endif

struct AboutView: View {
    @Binding var shown: Bool
    func bd() -> Date {
        if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[.modificationDate] as? Date {
            return infoDate
        }
        return Date()
    }

    func render(_ g: GeometryProxy) -> some View {
        let cmin = min(g.size.width, g.size.height)
        let copyrightFormat = DateFormatter()
        copyrightFormat.dateFormat = "YYYY"
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium

        return VStack(alignment: .center) {
            Image("FieldFab Logo")
                .scaleEffect(0.6)
                .frame(width: cmin * 0.6, height: cmin * 0.6)
            Text("Field Fab").font(.title)
            Text("By Robert M. Sale").padding(.bottom)
            VStack {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")
                }
                Divider()
                HStack {
                    Text("Build Date")
                    Spacer()
                    Text(df.string(from: bd()))
                }
                Divider()
                HStack {
                    Text("Website")
                    Spacer()
                    Link("Fieldfab.net", destination: URL(string: "https://fieldfab.net")!)
                }
                Divider()
                HStack {
                    Text("Developer Email")
                    Spacer()
                    Link("robert.sale@outlook.com", destination: URL(string: "mailto:robert.sale@outlook.com")!)
                }
            }
            Spacer()
            Text("© Copyright \(copyrightFormat.string(from: Date())), Robert M. Sale")
            Text("All rights reserved")
            Spacer()
            Button(action: {shown = false}) {
                Text("Close")
            }.tint(.red)
        }
        .padding()
        .padding(.top, 30)
    }

    var body: some View {
        GeometryReader { g in
            ScrollView {
                render(g)
            }
        }
        #if DEBUG
        .eraseToAnyView()
        #endif
    }

    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
}

