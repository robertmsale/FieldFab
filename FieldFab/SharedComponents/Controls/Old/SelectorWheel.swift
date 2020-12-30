//
//  SelectorWheel.swift
//  FieldFab
//
//  Created by Robert Sale on 10/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI



enum SelectorWheelSelection: Int, CaseIterable, Identifiable {
    case width = 0
    case depth
    case length
    case offsetX
    case offsetY
    case tWidth
    case tDepth
    var id: Int { self.rawValue }
}

struct SelectorWheel: View {
    typealias V2 = CGPoint
    @EnvironmentObject var al: AppLogic
    @Environment(\.colorScheme) var colorScheme
    @State var dragPosition: CGFloat = 0
    @Binding var shown: Bool
    let sMax: CGFloat = 100
    
    func getPosition() -> CGFloat {
        
        switch dragPosition {
            case let x where x <= 0:
                shown = false
                return 0
            case let x where x >= sMax:
                shown = true
                return sMax
            default: return dragPosition
        }
    }
    
    func getChevronAnimationRotation() -> Double {
        let newRot = Double(180 * dragPosition / 100)
        if newRot > 180 { return 180 }
        if newRot < 0 { return 0 }
        return newRot
    }
    
    func getStepper() -> AnyView {
        switch al.selectorWheelSelection {
            case .width: return AnyView(FStepper(val: Binding(get: {al.width}, set: {v in al.width = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false))
            case .depth: return AnyView(FStepper(val: Binding(get: {al.depth}, set: {v in al.depth = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false))
            case .length: return AnyView(FStepper(val: Binding(get: {al.length}, set: {v in al.length = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false))
            case .offsetX: return AnyView(FStepper(val: Binding(get: {al.offsetX}, set: {v in al.offsetX = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false))
            case .offsetY: return AnyView(FStepper(val: Binding(get: {al.offsetY}, set: {v in al.offsetY = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false))
            case .tWidth: return AnyView(FStepper(val: Binding(get: {al.tWidth}, set: {v in al.tWidth = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false).disabled(!al.isTransition))
            default: return AnyView(FStepper(val: Binding(get: {al.tDepth}, set: {v in al.tDepth = v}), fullStep: true, stepSize: al.increments, isMeasurement: true, big: false).disabled(!al.isTransition))
        }
    }
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Button(action: {
                    if dragPosition == 0 { dragPosition = 100 }
                    else { dragPosition = 0 }
                }, label: {
                    Image(systemName: "chevron.up")
                        .font(.largeTitle)
                        .frame(width: 128, height: 72)
                        .rotationEffect(Angle(degrees: getChevronAnimationRotation()))
                })
                    .position(x: g.size.width / 2, y: g.size.height - getPosition() - 36)
                    .zIndex(1000)
                
                HStack(alignment: .center) {
                    Spacer(minLength: 20)
                    Picker(selection: $al.selectorWheelSelection, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
                        Text("Width").tag(SelectorWheelSelection.width)
                        Text("Depth").tag(SelectorWheelSelection.depth)
                        Text("Length").tag(SelectorWheelSelection.length)
                        Text("Offset X").tag(SelectorWheelSelection.offsetX)
                        Text("Offset Y").tag(SelectorWheelSelection.offsetY)
                        Text("T-Width").tag(SelectorWheelSelection.tWidth)
                        Text("T-Depth").tag(SelectorWheelSelection.tDepth)
                    })
                    .frame(width: 80, height: 80)
                    .clipped()
                    Spacer()
                    getStepper()
                        .frame(width: 200, height: 40)
                    Spacer(minLength: 20)
                }
                .frame(width: g.size.width, height: 100)
                .background(BlurEffectView())
                .position(x: g.size.width / 2, y: 50 + g.size.height - (getPosition() == 0 ? -100 : getPosition()))
            }
            .animation(.easeIn)
        }
    }
}

#if DEBUG
struct SelectorWheel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectorWheel(shown: .constant(false)).environmentObject(AppLogic())
                .environment(\.colorScheme, .dark)
                .background(AppColors.ViewBG[.dark])
            SelectorWheel(shown: .constant(false)).environmentObject(AppLogic())
                .environment(\.colorScheme, .light)
                .background(AppColors.ViewBG[.light])
        }
    }
}
#endif
