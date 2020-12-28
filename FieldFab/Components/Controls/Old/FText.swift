//
//  FText.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct FText: View {
    var fraction: Fraction
    var isMeasurement: Bool

    init(_ f: Fraction, _ im: Bool = false) {
        self.fraction = f
        self.isMeasurement = im
    }

    func getWholeText() -> String {
        let isNegative = self.fraction.whole == 0 && self.fraction.original < 0 ? "-" : ""
        let isWholeNotZero = (self.fraction.whole != 0) || (self.fraction.whole == 0 && self.fraction.parts.d == 1)
            ? self.fraction.whole.description : ""
        let shouldAddSpace = self.fraction.isFraction ? " " : ""
        return "\(isNegative)\(isWholeNotZero)\(shouldAddSpace)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0.0, content: {
            Text(getWholeText()).font(.headline)
            if self.fraction.isFraction {
                Text("\(self.fraction.parts.n)/\(self.fraction.parts.d)").font(.footnote)
            }
            if self.isMeasurement {
                Text("\"")
            }
        })
    }
}

struct FText_Previews: PreviewProvider {
    static var previews: some View {
        FText(Fraction(15.6, roundTo: 0.0625), true)
    }
}
