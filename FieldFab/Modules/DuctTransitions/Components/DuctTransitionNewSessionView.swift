//
//  DuctTransitionNewSessionView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/31/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI

extension DuctTransition {
    struct NewSessionView: View {
        @Binding var shown: Bool
        var body: some View {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        @ObserveInjection var redraw
    }
}

