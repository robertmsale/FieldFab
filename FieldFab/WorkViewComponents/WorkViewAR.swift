//
//  WorkViewAR.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct WorkViewAR: View {
    @EnvironmentObject var state: AppState
    
    var body: some View {
        ZStack {
            DuctAR().zIndex(1)
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text("Translation Mode")
                        Picker("", selection: $state.translationMode, content: {
                            Text("XZ").tag(AppState.TranslationMode.xz)
                            Text("Y").tag(AppState.TranslationMode.y)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Button(action: {
                        state.arEvents.arViewReset = true
                    }, label: { Text("Reset").font(.title2) })
                    Spacer()
                    Picker(state.flowDirection.text, selection: $state.flowDirection, content: {
                        Text("Upflow").tag(AppState.FlowDirection.up)
                        Text("Downflow").tag(AppState.FlowDirection.down)
                        Text("Leftflow").tag(AppState.FlowDirection.left)
                        Text("Rightflow").tag(AppState.FlowDirection.right)
                    }).pickerStyle(MenuPickerStyle())
                }
                .padding()
                .background(BlurEffectView())
                
            }.zIndex(2)
        }
    }
}

struct WorkViewAR_Previews: PreviewProvider {
    static var previews: some View {
        WorkViewAR()
    }
}
