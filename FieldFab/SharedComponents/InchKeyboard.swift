//
//  CustomKeyboard.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
import StringFix

extension DuctTransition {
    struct CustomKeyboard: View {
        @Environment(\.colorScheme) var colorScheme
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
        var canBeNegative: Bool
        @Binding var text: String
        @Binding var shown: Bool
        @Binding var measure: UserMeasurement
        @Binding var ductwork: DuctData
        
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
        
        
        func closeAction() -> some Gesture {
            return TapGesture().onEnded { Task {
                var newValue = 0.0
                if ductwork.unit == .inch {
                    if let frac = MeasurementUnit.fracVals[String(text.last ?? " ")] {
                        newValue += frac
                        let _ = text.popLast()
                    }
                }
                newValue += Double(text) ?? 0.0
                
                ductwork[measure] = newValue
                withAnimation {
                    shown = false
                }
            }}
        }
        
        var body: some View {
            GeometryReader { g in
                VStack {
                    Spacer()
                    Text(measure.localizedString).font(.title)
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
                    Text(ductwork.unit.localizedString)
                    Spacer()
                    HStack(alignment: .center) {
                        VStack {
                            HStack {
                                ForEach(CustomKeyboard.nums[10...12], id: \.self) { ch in
                                    KBButton(gesture: TapGesture().onEnded {
                                        if disabled || ductwork.unit != .inch { return }
                                        btnPress(str: ch)
                                    }, disabled: disabled || ductwork.unit != .inch) {
                                        Text(ch)
                                    }
                                }
                            }
                            HStack {
                                ForEach(CustomKeyboard.nums[13...15], id: \.self) { ch in
                                    KBButton(gesture: TapGesture().onEnded {
                                        if disabled || ductwork.unit != .inch { return }
                                        btnPress(str: ch)
                                    }, disabled: disabled || ductwork.unit != .inch) {
                                        Text(ch)
                                    }
                                }
                            }
                            KBButton(gesture: TapGesture().onEnded {
                                if disabled || ductwork.unit != .inch { return }
                                btnPress(str: Self.nums[16])
                            }, disabled: disabled || ductwork.unit != .inch) {
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
                                    if ductwork.unit == .inch || ductwork.unit == .millimeters { return }
                                    if (text.contains {$0 == Character(".")}) { return }
                                    btnPress(str: ".")
                                }, disabled: ductwork.unit == .inch || ductwork.unit == .millimeters || text.contains(where: {$0 == Character(".")})) {
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
//                Rectangle()
                BlurEffectView(style: .systemUltraThinMaterialLight).opacity(shown ? 1.0 : 0.0)
            }
            .ignoresSafeArea(.all)
            .gesture(closeAction())
            
            
        }
    }
}

//struct CustomKeyboard_PreviewHelper: View {
//    @State var textNum = "1234"
//    @State var shown = true
//    var body: some View {
//        ZStack {
//            if (shown) {
//                CustomKeyboard( text: $textNum, shown: $shown)
//                    .zIndex(2)
//                    .transition(AnyTransition.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
//            }
//
//            HStack {
//                Button(action: {
//                    withAnimation {
//                        shown = true
//                    }
//                }) {
//                    Text("Show keyboard")
//                }
//            }.zIndex(1)
//        }.background {
//            Image("TestBG")
//        }
//    }
//}

//struct CustomKeyboard_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomKeyboard_PreviewHelper()
//    }
//}
