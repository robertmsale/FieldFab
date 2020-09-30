//
//  Colors.swift
//  FieldFab
//
//  Created by Robert Sale on 9/27/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

enum AppColors {
    case ControlBG
    case ControlFG
    case ButtonFG
    case ViewFG
    case ViewBG
    subscript(_ s: ColorScheme) -> Color {
        if s == .dark {
            switch self {
                case .ControlBG: return Color(hue: 0.0, saturation: 0.0, brightness: 0.07)
                case .ControlFG: return Color(hue: 0.0, saturation: 0.0, brightness: 0.98)
                case .ButtonFG: return Color.red
                case .ViewFG: return Color(hue: 0.0, saturation: 0.0, brightness: 1.0)
                case .ViewBG: return Color(hue: 0.0, saturation: 0.0, brightness: 0.0)
            }
        }
        else {
            switch self {
                case .ControlBG: return Color(hue: 0.0, saturation: 0.0, brightness: 0.97)
                case .ControlFG: return Color(hue: 0.0, saturation: 0.0, brightness: 0.0)
                case .ButtonFG: return Color.blue
                case .ViewFG: return Color(hue: 0.0, saturation: 0.0, brightness: 0.0)
                case .ViewBG: return Color(hue: 0.0, saturation: 0.0, brightness: 1.0)
            }
        }
    }
}


struct Colors_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/.foregroundColor(AppColors.ButtonFG[.dark])
    }
}
