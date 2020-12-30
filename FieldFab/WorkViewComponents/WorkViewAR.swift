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
    @Environment(\.verticalSizeClass) var sizeClass
    
    var transpicker: some View {
        VStack {
            Text("Translation Mode")
            Picker("", selection: $state.translationMode, content: {
                Text("XZ").tag(AppState.TranslationMode.xz)
                Text("Y").tag(AppState.TranslationMode.y)
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 150)
        }
    }
    var helpButton: some View {
        Button(action: {state.sheetsShown.arHelp = true}, label: {
            Image(systemName: "questionmark")
                .padding()
                .background(Color.black.opacity(0.75))
                .clipShape(Circle())
        })
    }
    var resetButton: some View {
        Button(action: {
            state.arEvents.arViewReset = true
        }, label: { Text("Reset").font(.title2) })
    }
    var flowPicker: some View {
        Picker(state.flowDirection.text, selection: $state.flowDirection, content: {
            Text("Upflow").tag(AppState.FlowDirection.up)
            Text("Downflow").tag(AppState.FlowDirection.down)
            Text("Leftflow").tag(AppState.FlowDirection.left)
            Text("Rightflow").tag(AppState.FlowDirection.right)
        }).pickerStyle(MenuPickerStyle())
    }
    
    var portraitMode: some View {
        VStack {
            HStack {
                transpicker
                Spacer()
                helpButton
            }
            .padding(.all, 8)
            .frame(maxWidth: .infinity)
            .background(BlurEffectView(style: .prominent))
            Spacer()
            HStack {
                resetButton
                Spacer()
                flowPicker
            }
            .padding()
            .background(BlurEffectView())
            
        }.zIndex(2)
    }
    
    var compactMode: some View {
        HStack {
            VStack {
                helpButton
                Spacer()
                transpicker
            }
//            .padding(.all, 8)
            .frame(maxHeight: .infinity)
            .background(BlurEffectView(style: .prominent))
            Spacer()
            VStack {
                flowPicker
                Spacer()
                resetButton
            }
            .padding()
            .background(BlurEffectView())
            
        }.zIndex(2)
    }
    
    var body: some View {
        ZStack {
            DuctAR().zIndex(1)
            if sizeClass == .regular {
                portraitMode
            } else {
                compactMode
            }
        }
    }
}

struct WorkViewAR_Previews: PreviewProvider {
    static var previews: some View {
        WorkViewAR().environmentObject(AppState())
    }
}
