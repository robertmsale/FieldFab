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

    struct ChartData: Identifiable {
        let object: String
        let data: [(odt: Int, btu: Int)]
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

    var h26: Int {
        Int(houseAt26) ?? 1
    }
    var hp17: Int {
        Int(hpAt17) ?? 1
    }
    var hp47: Int {
        Int(hpAt47) ?? 1
    }

    var houseData: ChartData {
        ChartData(object: "House", data: [
            (70, 0),
            (26, h26),
            (1, (h26) / 44 * 70)
        ])
    }
    var hpm: Int {
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

    var bp: Int {
        let X1 = 26, X2 = 70, X3 = 17, X4 = 47, Y1 = Int(houseAt26) ?? 1, Y2 = 2, Y3 = Int(hpAt17) ?? 1, Y4 = Int(hpAt47) ?? 1

        return ((X1 * Y2 - Y1 * X2) * (X3 - X4) - (X3 * Y4 - Y3 * X4) * (X1 - X2)) / (((X1 - X2) * (Y3 - Y4)) - ((Y1 - Y2) * (X3 - X4)))
    }

    @ViewBuilder
    func helpAlert() -> some View {
        VStack(spacing: 25) {
            Text("This tool helps with finding the balance point for a particular system and for PTCS heat pump commissioning.")
                    .padding()
            Text("Look up the AHRI certificate for your equipment and use the BTUs at 17 and 47 degrees, then do a Manual J heat load calculation to determine the building's heat loss at 26 degrees to find the balance point.")
                    .padding()
        }
                .padding()
    }

    var body: some View {
        VStack {
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
                    .padding(.all, 30)
            Text("Balance Point: \(bp)℉")
            HStack(spacing: 0) {
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
