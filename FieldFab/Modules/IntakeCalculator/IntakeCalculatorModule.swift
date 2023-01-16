//
// Created by Robert Sale on 1/6/23.
// Copyright (c) 2023 Robert Sale. All rights reserved.
//

import Foundation
import SwiftUI
#if DEBUG && canImport(HotSwiftUI) && targetEnvironment(simulator)
@_exported import HotSwiftUI
#endif

struct IntakeCalculatorModule: View {
    typealias Num = Int64
    @State var width: String = "20"
    @State var depth: String = "10"
    @State var height: String = "10"
    
    @State var wkbShown: Bool = false
    @State var dkbShown: Bool = false
    @State var hkbShown: Bool = false
    
    @State var helpShown: Bool = false
    
    static let nf: NumberFormatter = {
        let f = NumberFormatter()
        f.groupingSeparator = ","
        f.groupingSize = 3
        f.usesGroupingSeparator = true
        return f
    }()
    
    var w: Num { Num(width) ?? 0 }
    var d: Num { Num(depth) ?? 0 }
    var h: Num { Num(height) ?? 0 }
    
    var maxBTUs: String {
        return Self.nf.string(from: NSNumber(value: (w * d * h) / 50 * 1000))!
    }
    
    @ViewBuilder func drawData(_ g: GeometryProxy) -> some View {
        HStack {
            Image(systemName: "cube.transparent").font(.system(size: 64))
            Spacer()
            VStack {
                HStack {
                    Text("Max BTUs: ")
                    Text(maxBTUs)
                        .foregroundColor(Color.green)
                }
                .font(.title)
            }
        }
        .padding()
        VStack {
            Text("Formula:")
            Text("( w 𝐱 d 𝐱 h ) / 50ft³ 𝐱 1,000 BTU/hr")
        }
        .font(.title2)
    }
    
    @ViewBuilder func drawForm() -> some View {
        Form {
            Section("Width") {
                HStack {
                    Text(width)
                        .sheet(isPresented: $wkbShown) {
                            DuctTransition.CustomKeyboard(
                                canBeNegative: false,
                                text: $width,
                                shown: $wkbShown,
                                measure: .blank(.width),
                                ductwork: .blank(BalancePointCalcView.blankDD),
                                overrideMeasure: "Width",
                                showFractions: false,
                                showPlusMinus: false,
                                showDot: false
                            )
                        }
                    Spacer()
                    Text("ft")
                }
                .background {
                    Color.white.opacity(0.000000001)
                }
                
                .onTapGesture {
                    wkbShown = true
                }
            }
            
            Section("Depth") {
                HStack {
                    Text(depth)
                        .sheet(isPresented: $dkbShown) {
                            DuctTransition.CustomKeyboard(
                                canBeNegative: false,
                                text: $depth,
                                shown: $dkbShown,
                                measure: .blank(.width),
                                ductwork: .blank(BalancePointCalcView.blankDD),
                                overrideMeasure: "Depth",
                                showFractions: false,
                                showPlusMinus: false,
                                showDot: false
                            )
                        }
                    Spacer()
                    Text("ft")
                }
                .background {
                    Color.white.opacity(0.000000001)
                }
                .onTapGesture {
                    dkbShown = true
                }
            }
            Section("Height") {
                HStack {
                    Text(height)
                        .sheet(isPresented: $hkbShown) {
                            DuctTransition.CustomKeyboard(
                                canBeNegative: false,
                                text: $height,
                                shown: $hkbShown,
                                measure: .blank(.width),
                                ductwork: .blank(BalancePointCalcView.blankDD),
                                overrideMeasure: "Height",
                                showFractions: false,
                                showPlusMinus: false,
                                showDot: false
                            )
                        }
                    Spacer()
                    Text("ft")
                }
                .background {
                    Color.white.opacity(0.000000001)
                }
                .onTapGesture {
                    hkbShown = true
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { g in
            if g.size.width > g.size.height {
                HStack {
                    VStack {
                        drawData(g)
                    }
                    Spacer()
                    drawForm()
                }
            } else {
                VStack {
                    drawData(g)
                    Spacer()
                    drawForm()
                }
            }
        }
        .toolbar {
            Button(action: { helpShown = true }) {
                Image(systemName: "questionmark.circle")
            }
        }
        .sheet(isPresented: $helpShown) {
            VStack(spacing: 25) {
                Spacer()
                Text("If you're installing a gas appliance in a space with no mechanical intake and do not want to run a dedicated intake pipe, you must take the sum of all the gas appliances in that space and ensure they do not exceed the maximum allowable BTUs given the volume.")
                    .padding()
                Text("If the sum of all the gas appliances exceeds the maximum BTUs, you have to run dedicated intake pipes for as many appliances as it takes to end up below the max BTUs.")
                    .padding()
                Spacer()
                Button(action: {helpShown = false}) {
                    Text("Close")
                }.tint(.red)
            }
            .padding()
        }
        .navigationTitle("Intake Calculator")
                #if DEBUG && canImport(HotSwiftUI) && targetEnvironment(simulator)
                .eraseToAnyView()
                #endif
    }
    #if DEBUG && canImport(HotSwiftUI) && targetEnvironment(simulator)
    @ObservedObject var iO = injectionObserver
    #endif
}
