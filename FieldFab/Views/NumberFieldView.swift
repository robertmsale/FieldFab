//
//  NumberFieldView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Guitar
import Combine

func numFmt () -> NumberFormatter {
    let n = NumberFormatter()
    n.allowsFloats = true
    n.maximumFractionDigits = 6
    n.maximumSignificantDigits = 6
    n.usesSignificantDigits = true
    return n
}

struct NumberFieldView: View {
    var binding: Binding<Fraction>
    
    init(binding: Binding<Fraction>) {
        self.binding = binding
    }
    
    var body: some View {
        TextField("Ayyyy", text: self.binding.asString)
            .frame(width: 180.0)
            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .disabled(true)
    }
    
    
}

struct NumberFieldView_Previews: PreviewProvider {
    static var previews: some View {
//        NumberFieldView()
        Text("Must preview parent element")
    }
}
