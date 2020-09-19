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

struct Controls: View {
    @EnvironmentObject var aL: AppLogic
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
                                self.aL.increments = MathUtils.INCREMENTS[self.incrementIndex]
                            }, label: {
                                Image(systemName: "minus")
                            })
                            Spacer()
                            Text(MathUtils.INCREMENTSTRINGS[self.incrementIndex])
                            Spacer()
                            Button(action: {
                                if self.incrementIndex == 4 { self.incrementIndex = 0 }
                                else { self.incrementIndex += 1}
                                self.aL.increments = MathUtils.INCREMENTS[self.incrementIndex]
                            }, label: {
                                Image(systemName: "plus")
                            })
                        }
                        .padding(.horizontal, 16.0)
                        .padding(.vertical, 8.0)
                        .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.016, brightness: 0.51, opacity: 0.112)/*@END_MENU_TOKEN@*/)
                        .frame(width: 180)
                    }
                    ControlViewItem(data: $aL.width, increments: $aL.increments, label: "Width")
                    ControlViewItem(data: $aL.depth, increments: $aL.increments, label: "Depth")
                    ControlViewItem(data: $aL.length, increments: $aL.increments, label: "Length")
                    ControlViewItem(data: $aL.offsetX, increments: $aL.increments, label: "Offset X")
                    ControlViewItem(data: $aL.offsetY, increments: $aL.increments, label: "Offset Y")
                    Toggle("Transition?", isOn: $aL.isTransition)
                        .gesture(TapGesture().onEnded({ _ in self.aL.toggleTransition() }))
                    if $aL.isTransition.wrappedValue {
                        ControlViewItem(data:$aL.tWidth, increments: $aL.increments, label: "Transition Width")
                        ControlViewItem(data:$aL.tDepth, increments: $aL.increments, label: "Transition Depth")
                    } else {
                        ControlViewItem(data:$aL.tWidth, increments: $aL.increments, label: "Transition Width").disabled(true)
                        ControlViewItem(data:$aL.tDepth, increments: $aL.increments, label: "Transition Depth").disabled(true)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20.0)
            .onAppear() {
                switch self.aL.increments {
                    case 0.03125:
                    self.incrementIndex = 0
                    case 0.0625:
                    self.incrementIndex = 1
                    case 0.125:
                    self.incrementIndex = 2
                    case 0.25:
                    self.incrementIndex = 3
                    case 0.5:
                    self.incrementIndex = 4
                    default:
                    self.incrementIndex = 0
                }
            }
        }
    }
}

struct Controls_Previews: PreviewProvider {
    static var previews: some View {
        Controls().environmentObject(AppLogic())
    }
}
