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
        }
    }
}

#if DEBUG
struct DuctTransitionNewSessionView_Previews: PreviewProvider {
    struct Preview: View {
        @State var shown = true
        var body: some View {
            DuctTransition.NewSessionView(shown: $shown)
        }
    }
    static var previews: some View {
        Preview()
    }
}
#endif
