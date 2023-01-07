//
//  DuctTransitionToPDF.swift
//  FieldFab
//
//  Created by Robert Sale on 1/6/23.
//  Copyright © 2023 Robert Sale. All rights reserved.
//

import SwiftUI
#if DEBUG
@_exported import HotSwiftUI
#endif

extension DuctTransition {
    struct DuctToPDF: View {
        var ductwork: DuctTransition.DuctData = .init(tabs: .init(repeating: .init(length: .inch, type: .foldOut), count: 16))
        static let logoScale: CGFloat = 0.4
        static let logoFrame: CGFloat = 192
        static let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateStyle = .long
            return df
        }()
        
        var body: some View {
            VStack {
                HStack {
                    Image("FieldFab Logo")
                        .resizable()
                        .frame(width: Self.logoFrame, height: Self.logoFrame)
                    VStack {
                        Text(ductwork.name).font(.title)
                        Text("Created on " + Self.dateFormatter.string(from: Date()))
                    }
                    .frame(maxWidth: .infinity)
                }
                Spacer()
                VStack {
                    HStack {
                        DuctSideView(ductwork: ductwork, face: .front, showTabInfo: true, showFaceInfo: true)
                        DuctSideView(ductwork: ductwork, face: .back, showTabInfo: true, showFaceInfo: true)
                    }
                    HStack {
                        DuctSideView(ductwork: ductwork, face: .left, showTabInfo: true, showFaceInfo: true)
                        DuctSideView(ductwork: ductwork, face: .right, showTabInfo: true, showFaceInfo: true)
                    }
                }
            }
            .padding()
//            .border(Color.blue)
#if DEBUG
                .eraseToAnyView()
#endif
        }
#if DEBUG
        @ObservedObject var iO = injectionObserver
#endif
    }
}
