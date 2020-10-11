//
//  NumberField.swift
//  FieldFab
//
//  Created by Robert Sale on 9/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Foundation

struct NumberField: View {
    @Binding var data: Double

    var body: some View {
        TextField(
            "type something...",
            value: $data,
            formatter: NumberFormatter()
        ).frame(width: 180.0).textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct NumberField_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
