//
//  BalancePointCalcView.swift
//  FieldFab
//
//  Created by Robert Sale on 1/2/23.
//  Copyright © 2023 Robert Sale. All rights reserved.
//

import SwiftUI
import Charts
import simd
import Foundation
#if DEBUG
@_exported import HotSwiftUI
#endif

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

struct BalancePointCalcView: View {
    typealias V2 = SIMD2<Double>
    typealias Num = Int64

    struct ChartData: Identifiable {
        let object: String
        let data: [(odt: Num, btu: Num)]
        var id: String {
            object
        }
    }

    static let blankDD = DuctTransition.DuctData()
    var houseAt70: Int = 0
    @State var houseAt26: String = "25427"
    @State var hpAt17: String = "11000"
    @State var hpAt47: String = "36000"

    @State var showHelp: Bool = false

    @State var h26kbShown: Bool = false
    @State var hp17kbShown: Bool = false
    @State var hp47kbShown: Bool = false
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    
    var device: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }

    var h26: Num {
        Swift.max(1, Swift.min(999999, Num(houseAt26) ?? 1))
    }
    var hp17: Num {
        Swift.max(1, Swift.min(999999, Num(hpAt17) ?? 1))
    }
    var hp47: Num {
        Swift.max(1, Swift.min(999999, Num(hpAt47) ?? 1))
    }

    var houseData: ChartData {
        ChartData(object: "House", data: [
            (70, 0),
            (26, h26),
            (1, (h26) / 44 * 70)
        ])
    }
    var hpm: Num {
        (hp47 - hp17) / (47 - 17)
    }
    var hpData: ChartData {
        ChartData(object: "Heat Pump", data: [
            (0, max(hp47 - (hpm * 47), 0)),
            (17, hp17),
            (47, hp47),
            (70, hp47 - (hpm * -23))
        ])
    }
//    let getBP = () => {
//            let X1 = x1, X2 = x2, X3 = x3, X4 = x4, Y1 = _.toNumber(y1), Y2 = y2, Y3 = _.toNumber(y3), Y4 = _.toNumber(y4)//
//        }

    var bp: Num {
        let a = Num(houseAt26)
        let b = Num(hpAt17)
        let c = Num(hpAt47)
        let X1 = Num(26), X2 = Num(70), X3 = Num(17), X4 = Num(47), Y1 = Num(houseAt26) ?? Num(1), Y2 = Num(2), Y3 = Num(hpAt17) ?? Num(1), Y4 = Num(hpAt47) ?? Num(1)

        return ((X1 * Y2 - Y1 * X2) * (X3 - X4) - (X3 * Y4 - Y3 * X4) * (X1 - X2)) / (((X1 - X2) * (Y3 - Y4)) - ((Y1 - Y2) * (X3 - X4)))
    }

    @ViewBuilder
    func helpAlert() -> some View {
        VStack(spacing: 25) {
            Spacer()
            Text("This tool helps with finding the balance point for a particular system and for PTCS heat pump commissioning.")
                    .padding()
            Text("Look up the AHRI certificate for your equipment and use the BTUs at 17 and 47 degrees, then do a Manual J heat load calculation to determine the building's heat loss at 26 degrees to find the balance point.")
                    .padding()
            Spacer()
            Button(action: {showHelp = false}) {
                Text("Close")
            }.tint(.red)
        }
                .padding()
    }
    
    @ViewBuilder func drawChart() -> some View {
        GeometryReader { g in
            Chart([houseData, hpData]) { series in
                ForEach(series.data, id: \.odt) { element in
                    LineMark(
                        x: .value("Outdoor Temp", element.odt),
                        y: .value("BTUs", element.btu))
                }
                .foregroundStyle(by: .value("Object", series.object))
                .symbol(by: .value("Object", series.object))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values:
                        .stride(by: 10)
                )
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 5000))
            }
            .position(x: g.size.width / 2, y: g.size.height / 2)
            .frame(width: Swift.min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
            .padding(.all, 30)
        }
    }
    
    @ViewBuilder func drawForm() -> some View {
        VStack {
            Text("Balance Point: \(bp)℉")
            Form {
                Section("House @ 26℉") {
                    HStack {
                        Text(houseAt26)
                            .sheet(isPresented: $h26kbShown) {
                                DuctTransition.CustomKeyboard(
                                    canBeNegative: false,
                                    text: $houseAt26,
                                    shown: $h26kbShown,
                                    measure: .blank(.width),
                                    ductwork: .blank(BalancePointCalcView.blankDD),
                                    overrideMeasure: "House @ 26℉",
                                    showFractions: false,
                                    showPlusMinus: false,
                                    showDot: false
                                )
                            }
                        Spacer()
                        Text("BTUs")
                    }
                    .background { Color.white.opacity(0.000000001)}
                    .onTapGesture {
                        h26kbShown = true
                    }
                    
                }
                
                Section("HP @ 17℉") {
                    HStack {
                        Text(hpAt17)
                            .sheet(isPresented: $hp17kbShown) {
                                DuctTransition.CustomKeyboard(
                                    canBeNegative: false,
                                    text: $hpAt17,
                                    shown: $hp17kbShown,
                                    measure: .blank(.width),
                                    ductwork: .blank(BalancePointCalcView.blankDD),
                                    overrideMeasure: "Heat Pump @ 17℉",
                                    showFractions: false,
                                    showPlusMinus: false,
                                    showDot: false
                                )
                            }
                        Spacer()
                        Text("BTUs")
                    }
                    .background { Color.white.opacity(0.000000001)}
                    .onTapGesture {
                        hp17kbShown = true
                    }
                }
                
                Section("HP @ 47℉") {
                    HStack {
                        Text(hpAt47)
                            .sheet(isPresented: $hp47kbShown) {
                                DuctTransition.CustomKeyboard(
                                    canBeNegative: false,
                                    text: $hpAt47,
                                    shown: $hp47kbShown,
                                    measure: .blank(.width),
                                    ductwork: .blank(BalancePointCalcView.blankDD),
                                    overrideMeasure: "Heat Pump @ 47℉",
                                    showFractions: false,
                                    showPlusMinus: false,
                                    showDot: false
                                )
                            }
                        Spacer()
                        Text("BTUs")
                    }
                    .background { Color.white.opacity(0.000000001)}
                    .onTapGesture {
                        hp47kbShown = true
                    }
                }
            }
        }
        
    }

    @ViewBuilder func drawView(_ g: GeometryProxy) -> some View {
        if g.size.width > g.size.height {
            HStack {
                drawChart()
                    .scaleEffect(0.8)
                drawForm()
            }
        } else {
            VStack {
                drawChart()
                    .offset(x: -20, y: -30)
                drawForm()
            }
        }
    }
    
    var body: some View {
        GeometryReader { g in
            drawView(g)
        }
        .navigationTitle("BP Calculator")
            .onTapGesture {
                hideKeyboard()
            }
            .toolbar(content: {
                Button(action: {
                    showHelp = true
                }, label: {
                    Image(systemName: "questionmark.circle")
                })
            })
            .sheet(isPresented: $showHelp) {
                helpAlert()
            }

            #if DEBUG
            .eraseToAnyView()
            #endif
    }
    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
}
