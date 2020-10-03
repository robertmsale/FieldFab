//
//  FStepper.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct FStepper: View {
    @Binding var val: Fraction
    @State var prevStep: CGPoint = CGPoint.zero
    var fullStep: Bool = false
    var stepSize: FractionStepAmount = .thirtysecond
    var isMeasurement: Bool = true
    var big: Bool = true
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                HStack {
                    if self.fullStep {
                        Button(action: {
                            self.val.mutate(.whole, .decrement)
                        }, label: {
                            Image(systemName: "arrow.left.to.line.alt").font(self.big ? .title : .title2)
                        })
                    }
                    Button(action: {
                        self.val.mutate(self.stepSize, .decrement)
                    }, label: {
                        Image(systemName: "arrow.left").font(self.big ? .title : .title2)
                    })
                    Spacer()
                    FText(self.val, self.isMeasurement)
                        .frame(height: 32)
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .gesture(DragGesture().onChanged({v in
                            if prevStep == CGPoint.zero {
                                prevStep = v.location
                                if v.translation.width > 1 { val.mutate(.whole, .increment) }
                                else { val.mutate(.whole, .decrement) }
                            } else {
                                switch (prevStep, v.location) {
                                    case let (x, y) where x.x < y.x && Int(y.x) % 3 == 0:
                                        val.mutate(.whole, .increment)
                                        prevStep = v.location
                                    case let (x, y) where x.x > y.x && Int(y.x) % 3 == 0:
                                        val.mutate(.whole, .decrement)
                                        prevStep = v.location
                                    default: break
                                }
                            }
                        }).onEnded({v in
                            prevStep = CGPoint.zero
                        }))
                    Spacer()
                    Button(action: {
                        self.val.mutate(self.stepSize, .increment)
                    }, label: {
                        Image(systemName: "arrow.right").font(self.big ? .title : .title2)
                    })
                    if self.fullStep {
                        Button(action: {
                            self.val.mutate(.whole, .increment)
                        }, label: {
                            Image(systemName: "arrow.right.to.line.alt").font(self.big ? .title : .title2)
                        })
                    }
                }
                .frame(width: g.size.width, height: g.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding(.horizontal)
                .background(Color(hue: 1, saturation: 0, brightness: 0.5, opacity: 0.1))
                .cornerRadius(15)
                .zIndex(2.0)
            }
            .frame(width: g.size.width, height: g.size.height)
        }
    }
}

struct FStepper_Previews: PreviewProvider {
    static var previews: some View {
        
        return VStack {
            StatefulPreviewWrapper(Fraction(22.5)) {
                FStepper(val: $0, fullStep: true, big: false)
            }
        }.frame(width: 300, height: 64, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
