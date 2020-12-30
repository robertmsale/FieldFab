//
//  NumberSlider.swift
//  FieldFab
//
//  Created by Robert Sale on 12/20/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct NumberPicker: View {
    @Binding var value: Int
    var max: Int = 9
    var body: some View {
        VStack {
            Text("Ayyy")
        }
        .background(Color.gray)
    }
}

extension BinaryFloatingPoint {
    var inchFrac: Self {
        let derp = self - self.floor
        switch derp {
            case let x where x > 0.03125 && x < 0.09375: return 0.0625
            case let x where x > 0.0625 && x < 0.1875: return 0.125
            case let x where x > 0.09375 && x < 0.28125: return 0.1875
            case let x where x > 0.125 && x < 0.375: return 0.25
            case let x where x > 0.15625 && x < 0.46875: return 0.3125
            case let x where x > 0.1875 && x < 0.5625: return 0.375
            case let x where x > 0.21875 && x < 0.65625: return 0.4375
            case let x where x > 0.25 && x < 0.75: return 0.5
            case let x where x > 0.28125 && x < 0.84375: return 0.5625
            case let x where x > 0.3125 && x < 0.9375: return 0.625
            case let x where x > 0.34375 && x < 1.03125: return 0.6875
            case let x where x > 0.375 && x < 1.125: return 0.75
            case let x where x > 0.40625 && x < 1.21875: return 0.8125
            case let x where x > 0.4375 && x < 1.3125: return 0.875
            case let x where x > 0.46875 && x < 1.40625: return 0.9375
            default: return 0
        }
    }
}

class NumberSliderState: ObservableObject {
    @Binding var value: DuctMeasurement
    @Published var whole: [Int] { didSet { setValue() }}
    @Published var frac: [Int] { didSet { setValue() }}
    @Published var isNegative: Bool { didSet { setValue() }}
    
    init(_ v: Binding<DuctMeasurement>, isNegatable: Bool = false) {
        _value = v
        let val = abs(v.wrappedValue.value.value)
        isNegative = v.wrappedValue.value.value < 0
        let vstr = String(val).split(separator: ".")
        if v.wrappedValue.value.unit == .inches {
            let fracVal = val - val.rounded(.towardZero)
            switch fracVal {
                case let x where x > 0.0624 && x < 0.0626: frac = [0, 6, 2, 5]
                case let x where x > 0.1249 && x < 0.1251: frac = [1, 2, 5, 0]
                case let x where x > 0.1874 && x < 0.1876: frac = [1, 8, 7, 5]
                case let x where x > 0.2499 && x < 0.2501: frac = [2, 5, 0, 0]
                case let x where x > 0.3124 && x < 0.3126: frac = [3, 1, 2, 5]
                case let x where x > 0.3749 && x < 0.3751: frac = [3, 7, 5, 0]
                case let x where x > 0.4374 && x < 0.4376: frac = [4, 3, 7, 5]
                case let x where x > 0.4999 && x < 0.5001: frac = [5, 0, 0, 0]
                case let x where x > 0.5624 && x < 0.5626: frac = [5, 6, 2, 5]
                case let x where x > 0.6249 && x < 0.6251: frac = [6, 2, 5, 0]
                case let x where x > 0.6874 && x < 0.6876: frac = [6, 8, 7, 5]
                case let x where x > 0.7499 && x < 0.7501: frac = [7, 5, 0, 0]
                case let x where x > 0.8124 && x < 0.8126: frac = [8, 1, 2, 5]
                case let x where x > 0.8749 && x < 0.8751: frac = [8, 7, 5, 0]
                case let x where x > 0.9374 && x < 0.9376: frac = [9, 3, 7, 5]
                default: frac = [0, 0, 0, 0]
            }
        } else {
            var fstr = vstr[1].map({$0.wholeNumberValue ?? 0})
            if fstr.count < 4 {
                for _ in 1...4-fstr.count {
                    fstr.append(0)
                }
            }
            frac = fstr            
        }
        var whstr = vstr[0].map({$0.wholeNumberValue ?? 0})
        if whstr.count < 4 {
            for _ in 1...4-whstr.count {
                whstr.insert(0, at: 0)
            }
        }
        whole = whstr
//        let th: Double = (val/1000).rounded()
//        let rth: Double = th * 1000
//        let h: Double = (val / 100 - rth).rounded()
//        let rh: Double = h * 100
//        let t: Double = (val / 10 - rth - rh).rounded()
//        let rt: Double = t * 10
//        let o: Double = (val - rth - rh - rt).rounded()
//        let teth: Double = ((val - rth - rh - rt - o) * 10).rounded()
//        let rteth: Double = teth / 10
//        let hth: Double = ((val - rth - rh - rt - o - rteth) * 100).rounded()
//        let rhth: Double = hth / 100
//        let thth: Double = ((val - rth - rh - rt - o - rteth - rhth) * 1000).rounded()
//        let rthth: Double = thth / 1000
//        let tth: Double = ((val - rth - rh - rt - o - rteth - rhth - rthth) * 10000).rounded()
//        whole = [o, t, h, th].map {$0.clamp(min: 0, max: 9).int}
//        frac = [teth, hth, thth, tth].map {$0.clamp(min: 0, max: 9).int}
    }
    
    func setValue() {
        var res = Double(0)
        let whole = self.whole
        let frac = self.frac
        res += whole[0].d * pow(10.0, 3)
        res += whole[1].d * pow(10.0, 2)
        res += whole[2].d * pow(10.0, 1)
        res += whole[3].d * pow(10.0, 0)
        res += frac[0].d * pow(10.0, -1)
        res += frac[1].d * pow(10.0, -2)
        res += frac[2].d * pow(10.0, -3)
        res += frac[3].d * pow(10.0, -4)
        value.value.value = isNegative ? -res : res
    }
}

struct NumberSlider: View {
    @ObservedObject var state: NumberSliderState
    var isNegatable: Bool
    
    init(_ value: Binding<DuctMeasurement>, isNegatable: Bool = false) {
        state = NumberSliderState(value, isNegatable: isNegatable)
        self.isNegatable = isNegatable
    }
    
    func renderInches() -> some View {
        return HStack {
            if isNegatable {
                Button(action: {
                    state.isNegative.toggle()
                }, label: {
                    Image(systemName: state.isNegative ? "minus" : "plus")
                })
            }
            DigitWheel(value: $state.whole[2]/*, max: 6*/)
            DigitWheel(value: $state.whole[3]/*, max: abs(value.value.value >= 60 ? 0 : 9)*/)
            FractionWheel(value: $state.frac)
            Text(state.value.value.unit.symbol)
        }
    }
    
    func renderFeet() -> some View {
        return HStack {
            if isNegatable {
                Button(action: {
                    state.isNegative.toggle()
                }, label: {
                    Image(systemName: state.isNegative ? "minus" : "plus")
                })
            }
            DigitWheel(value: $state.whole[3]/*, max: 5*/)
            Text(".")
            DigitWheel(value: $state.frac[0]/*, max: abs(value.value.value) >= 5 ? 0 : 9 */)
            DigitWheel(value: $state.frac[1]/*, max: abs(value.value.value) >= 5 ? 0 : 9 */)
            Text(state.value.value.unit.symbol)
        }
    }
    
    func renderMeters() -> some View {
        return HStack {
            if isNegatable {
                Button(action: {
                    state.isNegative.toggle()
                }, label: {
                    Image(systemName: state.isNegative ? "minus" : "plus")
                })
            }
            DigitWheel(value: $state.whole[3]/*, max: 1*/)
            Text(".")
            DigitWheel(value: $state.frac[0]/*, max: abs(value.value.value) >= 1 ? 8 : 9*/)
            DigitWheel(value: $state.frac[1]/*, max: abs(value.value.value) >= 1 ? 2 : 9*/)
            DigitWheel(value: $state.frac[2]/*, max: abs(value.value.value) >= 1 ? 8 : 9*/)
            Text(state.value.value.unit.symbol)
        }
    }
    
    func renderCentimeters() -> some View {
        return HStack {
            if isNegatable {
                Button(action: {
                    state.isNegative.toggle()
                }, label: {
                    Image(systemName: state.isNegative ? "minus" : "plus")
                })
            }
            DigitWheel(value: $state.whole[1]/*, max: 1*/)
            DigitWheel(value: $state.whole[2]/*, max: abs(value.value.value) >= 100 ? 8 : 9*/)
            DigitWheel(value: $state.whole[3]/*, max: abs(value.value.value) >= 180 ? 2 : 9*/)
            Text(".")
            DigitWheel(value: $state.frac[0]/*, max: abs(value.value.value) >= 182 ? 8 : 9*/)
            Text(state.value.value.unit.symbol)
        }
    }
    
    func renderMillimeters() -> some View {
        return HStack {
            if isNegatable {
                Button(action: {
                    state.isNegative.toggle()
                }, label: {
                    Image(systemName: state.isNegative ? "minus" : "plus")
                })
            }
            DigitWheel(value: $state.whole[0]/*, max: 1*/)
            DigitWheel(value: $state.whole[1]/*, max: abs(value.value.value) >= 1000 ? 8 : 9*/)
            DigitWheel(value: $state.whole[2]/*, max: abs(value.value.value) >= 1800 ? 2 : 9*/)
            DigitWheel(value: $state.whole[3]/*, max: abs(value.value.value) >= 1820 ? 8 : 9*/)
            Text(state.value.value.unit.symbol)
        }
    }
    
    var body: some View {
        if state.value.value.unit == UnitLength.inches        { renderInches() }
        if state.value.value.unit == UnitLength.feet          { renderFeet() }
        if state.value.value.unit == UnitLength.meters        { renderMeters() }
        if state.value.value.unit == UnitLength.centimeters   { renderCentimeters() }
        if state.value.value.unit == UnitLength.millimeters   { renderMillimeters() }
    }
}

struct NumberSlider_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(0) { (v) -> AnyView in
            return AnyView(VStack {
                Text("Value: \(v.wrappedValue)")
//                NumberPicker(value: v)
            })
        }
    }
}
