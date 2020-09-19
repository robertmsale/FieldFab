//
//  ControlView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/6/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct ControlButtonImage: View {
    let icon: String
    
    var body: some View {
        Image(systemName: self.icon)
            .font(.title)
//            .padding(10)
//            .background(Color.blue)
//            .cornerRadius(40)
//            .foregroundColor(Color.white)
        
    }
}

struct ControlViewItem: View {
    @Binding var data: Fraction
    @Binding var increments: CGFloat
    var label: String
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text(self.label).font(.system(size: 24.0))
                Spacer()
            }
//            Divider()
            HStack(alignment: .center) {
                Button(action: {
                    self.data.original = self.data.original - 1.0
                }, label: {
                    ControlButtonImage(icon: "arrow.left.to.line.alt")
                }).buttonStyle(DefaultButtonStyle())
                Button(action: {
                    self.data.original = self.data.original - self.increments
                }, label: {
                    ControlButtonImage(icon: "arrow.left")
                })
                Spacer()
                HStack() {
                    Text("\(self.data.whole)").font(.system(size: 20.0))
                    if self.data.parts.d != 1 {
                        Text("\(self.data.parts.n)/\(self.data.parts.d)").font(.system(size: 14.0))
                    }
                }
                .padding(.all, 5.0)
                .frame(width: 100.0, height: 32.0)
                .background(/*@START_MENU_TOKEN@*/Color.white/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color.black)
                .gesture(TapGesture().onEnded({
                    self.data.original = CGFloat(self.data.whole)
                }))
                Spacer()
                Button(action: {
                    self.data.original = self.data.original + self.increments
                }, label: {
                    ControlButtonImage(icon: "arrow.right")
                }).buttonStyle(DefaultButtonStyle())
                Button(action: {
                    self.data.original = self.data.original + 1.0
                }, label: {
                    ControlButtonImage(icon: "arrow.right.to.line.alt")
                })
            }
            .padding(.all, 6.0)
            .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.016, brightness: 0.51, opacity: 0.112)/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        let d = Binding.constant(Fraction(16.5))
        let i = Binding.constant(CGFloat(0.03125))
        return ControlViewItem(data: d, increments: i, label: "Width")
    }
}
