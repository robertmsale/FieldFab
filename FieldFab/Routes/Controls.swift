//
//  Controls.swift
//  FieldFab
//
//  Created by Robert Sale on 9/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

func returnBinding(_ x: AppLogicField) -> Binding<AppLogicField> {
    return Binding.constant(x)
}

let INCREMENTS: Array<CGFloat> = [0.03125, 0.0625, 0.125, 0.25, 0.5]
let INCREMENT_STRINGS: Array<String> = ["1/32", "1/16", "1/8", "1/4", "1/2"]

struct Controls: View {
    @EnvironmentObject var aL: AppLogic
    @State var increments: CGFloat = 0.03125
    @State var incrementIndex: Int = 0
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 8.0) {
                Text("Settings").font(.title)
                Divider()
                VStack() {
                    HStack() {
                        Text("Increment by")
                        Spacer()
                        HStack(alignment: .center) {
                            Button(action: {
                                if self.incrementIndex == 0 { self.incrementIndex = 4 }
                                else { self.incrementIndex -= 1}
                                self.increments = INCREMENTS[self.incrementIndex]
                            }, label: {
                                Image(systemName: "arrow.left")
                            })
                            Spacer()
                            Text(INCREMENT_STRINGS[self.incrementIndex])
                            Spacer()
                            Button(action: {
                                if self.incrementIndex == 4 { self.incrementIndex = 0 }
                                else { self.incrementIndex += 1}
                                self.increments = INCREMENTS[self.incrementIndex]
                            }, label: {
                                Image(systemName: "arrow.right")
                            })
                        }
                        .padding(.horizontal, 16.0)
                        .padding(.vertical, 8.0)
                        .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.016, brightness: 0.51, opacity: 0.112)/*@END_MENU_TOKEN@*/)
                    }
                    ControlViewItem(data: $aL.width, increments: $increments, label: "Width")
                    ControlViewItem(data: $aL.depth, increments: $increments, label: "Depth")
                    ControlViewItem(data: $aL.length, increments: $increments, label: "Length")
                    ControlViewItem(data: $aL.offsetX, increments: $increments, label: "Offset X")
                    ControlViewItem(data: $aL.offsetY, increments: $increments, label: "Offset Y")
                    Toggle("Transition?", isOn: $aL.isTransition)
                        .gesture(TapGesture().onEnded({ _ in self.aL.toggleTransition() }))
                    if $aL.isTransition.wrappedValue {
                        ControlViewItem(data:$aL.tWidth, increments: $increments, label: "Transition Width")
                        ControlViewItem(data:$aL.tDepth, increments: $increments, label: "Transition Depth")
                    } else {
                        ControlViewItem(data:$aL.tWidth, increments: $increments, label: "Transition Width").disabled(true)
                        ControlViewItem(data:$aL.tDepth, increments: $increments, label: "Transition Depth").disabled(true)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20.0)
        }
    }
}

struct Controls_Previews: PreviewProvider {
    static var previews: some View {
        Controls().environmentObject(AppLogic())
    }
}
