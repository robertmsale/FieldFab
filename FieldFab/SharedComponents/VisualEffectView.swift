//
//  VisualEffectView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

struct BlurEffectView: View {
    @Environment(\.colorScheme) var colorScheme
    var style: UIBlurEffect.Style?
    
    var body: some View {
        if style != nil {
            return VisualEffectView(effect: UIBlurEffect(style: style!))
        } else {
            return VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
        }
    }
}
