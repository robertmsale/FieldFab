//
//  CustomKeyboard.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
import StringFix

struct CustomKeyboard: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var state: AppState
    var bg: Color {
        colorScheme == .dark ?
        Color(red: 0.16862745, green: 0.16862745, blue: 0.16862745) :
        Color(red: 0.81568627, green: 0.82745098, blue: 0.85490196)
    }
    static let nums: [String] = [
        "0", "1", "2",
        "3", "4", "5",
        "6", "7", "8",
        "9",
        "⅛", "¼", "⅜",
        "½", "⅝", "¾",
        "⅞"]
    static let fracs: Set<String> = Set([
        "⅛", "¼", "⅜",
        "½", "⅝", "¾",
        "⅞"
    ])
    var canBeNegative: Bool {
        state.measureToEdit == .offsetx || state.measureToEdit == .offsety
    }
    @Binding var text: String
    @Binding var shown: Bool
    
    var measureText: String {
        switch state.measureToEdit {
        case .width: return "Width"
        case .depth: return "Depth"
        case .length: return "Length"
        case .offsetx: return "Offset X"
        case .offsety: return "Offset Y"
        case .twidth: return "T Width"
        case .tdepth: return "T Depth"
        }
    }
    
    var disabled: Bool {
        text.reduce(false, {res, next in res || Self.fracs.contains(String(next))})
    }
    
    func btnPress(str: String) {
        withAnimation {
            if disabled {return}
            text.append(str)
        }
    }
    
    func btnGesture(_ str: String) -> some Gesture {
        return TapGesture()
            .onEnded({
                withAnimation {
                    if disabled {return}
                    let ztest = ["0", "0.", ""]
                    if text == "0" || text == "-0" { text = "" }
                    text.append(str)
                }
            })
    }
    
    var measurementText: String {
        switch state.currentWork?.data.width.value.unit {
            
        case UnitLength.inches:
            return "Inches"
        case UnitLength.feet:
            return "Feet"
        case UnitLength.meters:
            return "Meters"
        case UnitLength.millimeters:
            return "Millimeters"
        case UnitLength.centimeters:
            return "Centimeters"
        default: return "Inches"
        }
    }
    
    func closeAction() -> some Gesture {
        TapGesture().onEnded({
            var newValue = 0.0
            if state.currentWork?.data.width.value.unit == .inches {
                if let frac = AppState.fracsVals[state.numberToEdit.last ?? Character(" ")] {
                    newValue += frac
                    let _ = state.numberToEdit.popLast()
                }
            }
            newValue += Double(state.numberToEdit) ?? 0.0
            
            switch state.measureToEdit {
            case .width:
                state.currentWork?.data.width.value.value = newValue
            case .depth:
                state.currentWork?.data.depth.value.value = newValue
            case .length:
                state.currentWork?.data.length.value.value = newValue
            case .offsetx:
                state.currentWork?.data.offsetx.value.value = newValue
            case .offsety:
                state.currentWork?.data.offsety.value.value = newValue
            case .twidth:
                state.currentWork?.data.twidth.value.value = newValue
            case .tdepth:
                state.currentWork?.data.tdepth.value.value = newValue
            }
            withAnimation {
                shown = false
            }
        })
    }
    
    var body: some View {
        GeometryReader { g in
            VStack {
                Spacer()
                Text(measureText).font(.title)
                HStack {
                    Spacer()
                    Text(text)
                        .font(.title2)
                        .animation(.easeInOut(duration: 0.1), value: text)
                }
                .padding()
                .frame(width: g.size.width - 64, height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(colorScheme == .dark ?
                              Color(red: 0.31372549, green: 0.31372549, blue: 0.31372549) :
                                Color.white)
                        
                }
                .gesture(TapGesture())
                Text(measurementText)
                Spacer()
                HStack(alignment: .center) {
                    VStack {
                        HStack {
                            ForEach(CustomKeyboard.nums[10...12], id: \.self) { ch in
                                KBButton(gesture: TapGesture().onEnded {
                                    if disabled || state.currentWork?.data.width.value.unit != UnitLength.inches { return }
                                    btnPress(str: ch)
                                }, disabled: disabled || state.currentWork?.data.width.value.unit != UnitLength.inches) {
                                    Text(ch)
                                }
                            }
                        }
                        HStack {
                            ForEach(CustomKeyboard.nums[13...15], id: \.self) { ch in
                                KBButton(gesture: TapGesture().onEnded {
                                    if disabled || state.currentWork?.data.width.value.unit != UnitLength.inches { return }
                                    btnPress(str: ch)
                                }, disabled: disabled || state.currentWork?.data.width.value.unit != UnitLength.inches) {
                                    Text(ch)
                                }
                            }
                        }
                        KBButton(gesture: TapGesture().onEnded {
                            if disabled || state.currentWork?.data.width.value.unit != UnitLength.inches { return }
                            btnPress(str: Self.nums[16])
                        }, disabled: disabled || state.currentWork?.data.width.value.unit != UnitLength.inches) {
                            Text(Self.nums[16])
                        }
                    }
                    Spacer()
                    VStack {
                        HStack {
                            ForEach(CustomKeyboard.nums[7...9], id: \.self) { ch in
                                KBButton(gesture: btnGesture(ch), disabled: disabled) {
                                    Text(ch)
                                }
                            }
                        }
                        HStack {
                            ForEach(CustomKeyboard.nums[4...6], id: \.self) { ch in
                                KBButton(gesture: btnGesture(ch), disabled: disabled) {
                                    Text(ch)
                                }
                            }
                        }
                        HStack {
                            ForEach(CustomKeyboard.nums[1...3], id: \.self) { ch in
                                KBButton(gesture: btnGesture(ch), disabled: disabled) {
                                    Text(ch)
                                }
                            }
                        }
                        HStack {
                            KBButton(gesture: TapGesture().onEnded {
                                if !canBeNegative || text == "0" { return }
                                if text[0] == Character("-") {
                                    text = String(text[1...])
                                } else {
                                    text = "-" + text
                                }
                            }, disabled: !canBeNegative || text == "0") {
                                Image(systemName: "plusminus")
                            }
                            KBButton(gesture: btnGesture(Self.nums[0]), disabled: disabled) {
                                Text(CustomKeyboard.nums[0])
                            }
                            KBButton(gesture: TapGesture().onEnded {
                                if state.currentWork?.data.width.value.unit == UnitLength.inches || state.currentWork?.data.width.value.unit == UnitLength.millimeters { return }
                                if (text.contains {$0 == Character(".")}) { return }
                                btnPress(str: ".")
                            }, disabled: state.currentWork?.data.width.value.unit == UnitLength.inches || state.currentWork?.data.width.value.unit == UnitLength.millimeters || text.contains(where: {$0 == Character(".")})) {
                                Text(".")
                            }
                        }
                        
                    }
                    Spacer()
                    VStack {
                        KBButton(
                            gesture: TapGesture().onEnded {
                                if (text.count > 0) {text = String(text.prefix(text.count - 1))}
                                if (text == "-") { text = "" }
                            },
                            type: .Control) {
                            Image(systemName: "delete.left")
                        }
                        Spacer(minLength: 5).frame(height: 20)
                        KBButton(gesture: closeAction(),type: .Primary) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .padding(.horizontal)
                .frame(width: g.size.width, height: 200)
                .padding(.bottom, 40)
                .background(bg.opacity(0.7).ignoresSafeArea(.all))
                .gesture(TapGesture())
            }
            
        }
        .background {
            BlurEffectView().opacity(shown ? 1.0 : 0.0)
        }
        .ignoresSafeArea(.all)
        .gesture(closeAction())
        
        
    }
}

struct CustomKeyboard_PreviewHelper: View {
    @State var textNum = "1234"
    @State var shown = true
    var body: some View {
        ZStack {
            if (shown) {
                CustomKeyboard( text: $textNum, shown: $shown)
                    .zIndex(2)
                    .transition(AnyTransition.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
            
            HStack {
                Button(action: {
                    withAnimation {
                        shown = true
                    }
                }) {
                    Text("Show keyboard")
                }
            }.zIndex(1)
        }.background {
            Image("TestBG")
        }
    }
}

struct CustomKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        CustomKeyboard_PreviewHelper()
    }
}
