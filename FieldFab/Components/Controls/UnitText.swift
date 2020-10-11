//
//  UnitText.swift
//  FieldFab
//
//  Created by Robert Sale on 10/1/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

//struct UnitText: View {
//    var units: DistanceUnit
//    var number: CGFloat
//
//    init(_ n: CGFloat, units: DistanceUnit = .inches) {
//        number = n
//        self.units = units
//    }
//
//    func getFractionString() -> String {
//        let f = Fraction(number)
//        let isNegative = f.whole == 0 && f.original < 0 ? "-" : ""
//        let isWholeNotZero = (f.whole != 0) || (f.whole == 0 && f.parts.d == 1)
//            ? f.whole.description : ""
//        let shouldAddSpace = f.isFraction ? " " : ""
//        return "\(isNegative)\(isWholeNotZero)\(shouldAddSpace)"
//    }
//
//    func getText() -> Text {
//        switch units {
//            case .inches: Text(getFractionString())
//            case .feet: Text("\(number.description)")
//        }
//    }
//
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct UnitText_Previews: PreviewProvider {
//    static var previews: some View {
//        UnitText()
//    }
//}
