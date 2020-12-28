//
//  MeasurementField.swift
//  FieldFab
//
//  Created by Robert Sale on 12/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct MeasurementField: View {
    @Binding var measurement: Measurement<UnitLength>
    @State var text: String {
        didSet {
            measurement.value = Double(text) ?? 0
        }
    }
    func genText() -> Text {
        let mf = MeasurementFormatter()
        mf.unitOptions = [.providedUnit]
        return Text(mf.string(from: measurement))
    }
    var body: some View {
        VStack {
            Spacer()
            HStack {
                
                Spacer()
                Text("Ayyy")
                Spacer()
            }.padding()
            Spacer()
        }
        .padding()
        .background(BlurEffectView().clipShape(RoundedRectangle(cornerRadius: 10)))
    }
}

struct MeasurementField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            MeasurementField(measurement: .constant(.init(value: 5.5, unit: .inches)), text: "").frame(height: 100)
            Spacer()
        }.background(Image("TestBG"))
    }
}
