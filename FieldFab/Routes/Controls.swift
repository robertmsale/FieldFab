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
        
        HeaderView("Settings", opt: [.fillTopEdge, .overlay]) {
            ScrollView {
                VStack(alignment: .center, spacing: 8.0) {
                    VStack() {
                        HStack() {
                            Text("Increment by")
                            Spacer()
                            HStack(alignment: .center) {
                                Button(action: {
                                    switch self.aL.increments {
                                        case .half: self.aL.increments = .quarter
                                        case .quarter: self.aL.increments = .eighth
                                        case .eighth: self.aL.increments = .sixteenth
                                        case .sixteenth: self.aL.increments = .thirtysecond
                                        default: self.aL.increments = .half
                                    }
                                }, label: {
                                    Image(systemName: "arrow.left")
                                })
                                Spacer()
                                Text(Fraction(self.aL.increments.rawValue).text("n/d"))
                                Spacer()
                                Button(action: {
                                    switch self.aL.increments {
                                        case .half: self.aL.increments = .thirtysecond
                                        case .quarter: self.aL.increments = .half
                                        case .eighth: self.aL.increments = .quarter
                                        case .sixteenth: self.aL.increments = .eighth
                                        default: self.aL.increments = .sixteenth
                                    }
                                }, label: {
                                    Image(systemName: "arrow.right")
                                })
                            }
                            .padding(.horizontal, 16.0)
                            .padding(.vertical, 8.0)
                            .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.016, brightness: 0.51, opacity: 0.112)/*@END_MENU_TOKEN@*/)
                            .frame(width: 180)
                            .cornerRadius(10)
                        }
                        Spacer(minLength: 30)
                        VStack {
                            HStack {
                                Text("Width").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.width, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                            HStack {
                                Text("Depth").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.depth, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                            HStack {
                                Text("Length").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.length, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                            HStack {
                                Text("Offset X").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.offsetX, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                            HStack {
                                Text("Offset Y").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.offsetY, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                        }
                        Divider()
                        HStack {
                            Text("Is Transition?")
                            Spacer()
                            Toggle("", isOn: $aL.isTransition)
                                .gesture(TapGesture().onEnded({_ in
                                    self.aL.toggleTransition()
                                }))
                                .padding(.trailing, 2)
                        }
                        Divider()
                        VStack {
                            HStack {
                                Text("Transition Width").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.tWidth, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal).disabled(!self.aL.isTransition)
                            HStack {
                                Text("Transition Depth").font(.headline)
                                Spacer()
                            }
                            FStepper(val: $aL.tDepth, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal).disabled(!self.aL.isTransition)
                        }
                        //                        ControlViewItem(data: $aL.width, increments: $aL.increments, label: "Width")
                        //                        ControlViewItem(data: $aL.depth, increments: $aL.increments, label: "Depth")
                        //                        ControlViewItem(data: $aL.length, increments: $aL.increments, label: "Length")
                        //                        ControlViewItem(data: $aL.offsetX, increments: $aL.increments, label: "Offset X")
                        //                        ControlViewItem(data: $aL.offsetY, increments: $aL.increments, label: "Offset Y")
                        //                        Toggle("Transition?", isOn: $aL.isTransition)
                        //                            .gesture(TapGesture().onEnded({ _ in self.aL.toggleTransition() }))
                        //                        if $aL.isTransition.wrappedValue {
                        //                            ControlViewItem(data:$aL.tWidth, increments: $aL.increments, label: "Transition Width")
                        //                            ControlViewItem(data:$aL.tDepth, increments: $aL.increments, label: "Transition Depth")
                        //                        } else {
                        //                            ControlViewItem(data:$aL.tWidth, increments: $aL.increments, label: "Transition Width").disabled(true)
                        //                            ControlViewItem(data:$aL.tDepth, increments: $aL.increments, label: "Transition Depth").disabled(true)
                        //                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)
            }
        }
    }
}
    


struct Controls_Previews: PreviewProvider {
    static var previews: some View {
        Controls().environmentObject(AppLogic())
    }
}
