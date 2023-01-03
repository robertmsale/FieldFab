//
//  KBButton.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI

enum KBBtnType {
    case Normal, Primary, Control
    func getTextColor(_ colorScheme: ColorScheme) -> Color {
        if (self == .Primary) {return Color.white}
        return colorScheme == .dark ? Color.white : Color.black
    }
    func getBtnColor(_ colorScheme: ColorScheme) -> Color {
        switch (self) {
        case .Normal:
            return colorScheme == .dark ?
                Color(red: 0.41960784, green: 0.41960784, blue: 0.41960784) :
                Color.white
        case .Primary:
            return Color(red: 0.00392157, green: 0.47843137, blue: 1.0)
        case .Control:
            return colorScheme == .dark ?
            Color(red: 0.27843137, green: 0.27843137, blue: 0.27843137) :
            Color(red: 0.6627451, green: 0.68235294, blue: 0.7372549)
        }
    }
}

struct KBButton<Content: View, KBGesture: Gesture>: View {
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    let type: KBBtnType
    let content: Content
    let gesture: KBGesture
    @State var tapOpacity: Double = 1.0
    init(gesture: KBGesture, type: KBBtnType = .Normal, disabled: Bool = false, @ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.disabled = disabled
        self.type = type
        self.gesture = gesture
    }
    var body: some View {
        content
            .foregroundColor(type.getTextColor(colorScheme))
            .font(.title)
            .frame(width: 40, height: 40)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(type.getBtnColor(colorScheme))
            }
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.black)
                    .opacity(0.8)
                    .offset(y: 0.8)
            }
            .opacity(tapOpacity)
            .opacity(disabled ? 0.5 : 1.0)
            .animation(.easeInOut, value: disabled)
            .animation(.easeInOut, value: tapOpacity)
            .gesture(SimultaneousGesture(TapGesture().onEnded {
                if disabled { return }
                let delay = 0.05
                withAnimation(.easeOut(duration: delay)) {
                    tapOpacity = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
                    withAnimation(.easeIn(duration: delay)) {
                        tapOpacity = 1
                    }
                }
            }, gesture))
            
    }
}

#if DEBUG
struct KBButton_PreviewHelper: View {
    @Environment(\.colorScheme) var colorScheme
    var bg: Color {
        colorScheme == .dark ?
        Color(red: 0.16862745, green: 0.16862745, blue: 0.16862745) :
        Color(red: 0.81568627, green: 0.82745098, blue: 0.85490196)
    }
    var body: some View {
        VStack {
            KBButton(gesture: TapGesture(), type: .Primary) {
                Text("a")
            }
            TextField("Ayyy", text: Binding<String>(get: {return ""}, set: {_ in}))
        }.background(bg)
    }
}

struct KBButton_Previews: PreviewProvider {
    static var previews: some View {
        KBButton_PreviewHelper()
    }
}
#endif
