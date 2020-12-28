//
//  DigitWheel.swift
//  FieldFab
//
//  Created by Robert Sale on 12/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Foundation


struct DigitWheel: View {
    @Binding var value: Int
    var max: Int = 9
    
    
    var body: some View {
        VStack {
            Picker("", selection: $value, content: {
                ForEach(Range(0...max), id: \.self, content: { Text("\($0)").tag($0) })
            })
            .pickerStyle(InlinePickerStyle())
            .frame(width: 25, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

struct FractionWheel: View {
    @Binding var value: [Int]
    var body: some View {
        VStack {
            Picker("", selection: $value, content: {
                Group {
                    Text("")     .tag([0, 0, 0, 0])
                    Text("1/16") .tag([0, 6, 2, 5])
                    Text("1/8") .tag([1, 2, 5, 0])
                    Text("3/16") .tag([1, 8, 7, 5])
                    Text("1/4") .tag([2, 5, 0, 0])
                    Text("5/16") .tag([3, 1, 2, 5])
                    Text("3/8") .tag([3, 7, 5, 0])
                    Text("7/16") .tag([4, 3, 7, 5])
                    Text("1/2") .tag([5, 0, 0, 0])
                }.font(.caption)
                Group {
                    Text("9/16") .tag([5, 6, 2, 5])
                    Text("5/8").tag([6, 2, 5, 0])
                    Text("11/16").tag([6, 8, 7, 5])
                    Text("3/4").tag([7, 5, 0, 0])
                    Text("13/16").tag([8, 1, 2, 5])
                    Text("7/8").tag([8, 7, 5, 0])
                    Text("15/16").tag([9, 3, 7, 5])
                }.font(.caption)
            })
            .pickerStyle(InlinePickerStyle())
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
        }
    }
}

#if DEBUG
struct DigitWheel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatefulPreviewWrapper(5) {
                DigitWheel(value: $0)
            }
//            StatefulPreviewWrapper([0, 6, 2, 5]) {
//                FractionWheel(value: $0)
//            }
        }
    }
}
#endif
